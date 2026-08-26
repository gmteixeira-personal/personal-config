-- Fuzzy pickers over files, file contents, buffers, help, and the git repository. Loaded by its
-- keys alone:
-- nothing but a keypress needs it.
--
-- telescope-fzf-native is deliberately NOT a dependency: it needs make and a C compiler, which
-- would put a build toolchain in this config's prerequisites. Telescope's Lua sorter is adequate
-- here; revisit when a picker actually feels slow.
--
-- The layout strategy is "flex" rather than the stock "horizontal" with a lowered preview_cutoff.
-- Under "horizontal", a window narrower than the cutoff loses the preview pane entirely, and
-- lowering the cutoff only squeezes the preview into a column too thin to read code in. "flex"
-- flips to the vertical layout instead, so narrowing the window moves the preview below the
-- results rather than removing it -- there is always a preview, only its position changes.
--
-- Because the two arrangements butt the three windows together along different edges, the border
-- glyphs that join them into one frame differ per arrangement, and are re-picked on VimResized.
return {
  "nvim-telescope/telescope.nvim",
  dependencies = { "nvim-lua/plenary.nvim" },
  -- A function rather than a table, so telescope.actions is required when the plugin loads rather
  -- than when this spec is evaluated. This is the file's first opts, which means lazy.nvim now
  -- calls require("telescope").setup() where it previously called nothing -- Telescope's defaults
  -- become applied rather than lazy. They should be identical, but this is the change that would
  -- expose it if they are not, so the pickers below are worth re-checking too.
  opts = function()
    local actions = require("telescope.actions")
    local action_state = require("telescope.actions.state")

    -- The width at which flex swaps the side-by-side arrangement for the stacked one. Named once
    -- because the border glyphs below have to flip at exactly the same width flex does.
    local flip_columns = 120

    -- Telescope draws the prompt, the results and the preview as three separate floating windows,
    -- each with its own border row or column. Adjacent windows therefore meet as a doubled line --
    -- two border rows between the prompt text and the first result, and two border columns between
    -- the results and a side-by-side preview. Neither row can be removed; the fix is to blank one
    -- side of each junction and give the other side a tee, so the three frames read as one.
    --
    -- Which side gets blanked depends on which way the windows are stacked, so there is a set per
    -- arrangement. Order is { top, right, bottom, left, top-left, top-right, bottom-right,
    -- bottom-left }.
    local borderchars = {
      -- Preview beside the results: prompt and results keep the single divider column, and the
      -- preview blanks its own left edge and continues the top and bottom lines through it.
      horizontal = {
        prompt = { "─", "│", " ", "│", "╭", "┬", "│", "│" },
        results = { "─", "│", "─", "│", "├", "┤", "┴", "╰" },
        preview = { "─", "│", "─", " ", "─", "╮", "╯", "─" },
      },
      -- Preview under the results: each window above blanks its bottom edge and the window below
      -- closes it with tees, so one continuous frame runs from the prompt to the preview.
      vertical = {
        prompt = { "─", "│", " ", "│", "╭", "╮", "│", "│" },
        results = { "─", "│", " ", "│", "├", "┤", "│", "│" },
        preview = { "─", "│", "─", "│", "├", "┤", "╯", "╰" },
      },
    }
    local function borderchars_for_window()
      return vim.o.columns < flip_columns and borderchars.vertical or borderchars.horizontal
    end

    -- A picker reads borderchars out of Telescope's own config when it is built, which happens
    -- every time one is opened -- so writing the new set back here is enough for the next picker
    -- to open with glyphs matching the arrangement flex will pick for it.
    vim.api.nvim_create_autocmd("VimResized", {
      group = vim.api.nvim_create_augroup("telescope_border_arrangement", { clear = true }),
      callback = function()
        require("telescope.config").values.borderchars = borderchars_for_window()
      end,
      desc = "Match Telescope's joined border glyphs to the flex arrangement",
    })

    -- Backs <C-d> in the buffer picker. It resolves the save/discard/cancel dialogs for every
    -- modified buffer in the set about to go, then hands the whole delete off to
    -- actions.delete_buffer, which does considerably more than delete: it drops the deleted
    -- entries from the result list, clears the marks, refreshes the picker, and walks the
    -- jumplist to move the window the picker was opened from off a buffer it just deleted. The
    -- alternative -- passing a callback of our own to picker:delete_selection -- would oblige this
    -- file to carry a copy of that jumplist walk, some twenty-five lines that would then be frozen
    -- at the version they were copied from. Every buffer still in the set by the time it is
    -- delegated is unmodified, which is the one case actions.delete_buffer already handles: its
    -- delete is unforced and wrapped in a pcall, so a modified buffer raises E89, is swallowed,
    -- and simply stays in the list with nothing said about it.
    --
    -- The dialog is vim.fn.confirm -- the same dialog :confirm bdelete raises behind <leader>bd,
    -- asking the same question in the same three ways. It blocks until answered, and that is what
    -- keeps the walk below a plain loop rather than a chain of callbacks; vim.ui.select would be
    -- asynchronous and, under a custom UI handler, answerable in any order or not at all while the
    -- picker is still open. Cancel is the default answer, so a dismissed dialog keeps the buffer.
    local function delete_buffers_with_confirmation(prompt_bufnr)
      local picker = action_state.get_current_picker(prompt_bufnr)

      -- picker._multi is the marked set, and it is picker-internal state rather than a documented
      -- API. It is reached into for one reason: a cancelled entry has to be dropped from it so the
      -- delegated delete proceeds without that buffer, since cancel is per-buffer and must not
      -- take the rest of a marked set with it. The surface is narrow -- read the set, drop one
      -- entry -- and an upstream rename breaks here as a Lua error naming the field rather than as
      -- silent misbehaviour. The unmarked path never touches it.
      local marked = picker._multi:get()
      local used_marks = not vim.tbl_isempty(marked)
      local entries = used_marks and marked or { picker:get_selection() }

      -- The buffers that survive the walk, as a set, for the window sweep below.
      local doomed = {}

      for _, entry in ipairs(entries) do
        local bufnr = entry.bufnr
        local keep = false

        -- Nothing is asked about a buffer with no unsaved changes.
        if vim.bo[bufnr].modified then
          local name = vim.api.nvim_buf_get_name(bufnr)
          local display = name ~= "" and vim.fn.fnamemodify(name, ":~:.") or "[No Name]"
          local choice = vim.fn.confirm(("Save changes to %s?"):format(display), "&Save\n&Discard\n&Cancel", 3)

          if choice == 1 then
            -- On success the buffer is unmodified and falls through to the delete below. On
            -- failure -- a buffer that has never been named raises E32 -- say so and treat it as
            -- cancelled: kept, changes intact, 'modified' untouched. Prompting for a name inside a
            -- picker prompt would be a second dialog for a case rare enough to be better handled
            -- in the buffer itself.
            local ok, err = pcall(vim.api.nvim_buf_call, bufnr, function()
              vim.cmd("write")
            end)
            if not ok then
              vim.notify(("Cannot write %s: %s"):format(display, err), vim.log.levels.ERROR)
              keep = true
            end
          elseif choice == 2 then
            -- Discard clears 'modified' rather than force-deleting the buffer here. A force-delete
            -- would strand the entry: the buffer would already be invalid by the time
            -- actions.delete_buffer ran, its unforced delete would fail, its callback would return
            -- false, and delete_selection keeps an entry whose callback returns false -- leaving a
            -- row in the list describing a buffer that no longer exists. Clearing the flag instead
            -- leaves exactly one deletion path, upstream's, for all three answers.
            vim.bo[bufnr].modified = false
          else
            -- Cancel, or a dismissed dialog, which confirm reports as 0.
            keep = true
          end
        end

        if keep then
          -- With no marks there was nothing else to delete, so the whole operation is off.
          if not used_marks then
            return
          end
          picker._multi:drop(entry)
        else
          doomed[bufnr] = true
        end
      end

      -- If the walk started from a marked set and every entry was cancelled, that set is now
      -- empty -- and delete_selection falls back to the current selection when the marked set is
      -- empty, which would delete a buffer nobody was asked about. Return before delegating.
      if used_marks and vim.tbl_isempty(picker._multi:get()) then
        return
      end

      -- No window may still be displaying a buffer that is about to go. nvim_buf_delete with
      -- force unset does nothing at all to a buffer displayed in a window other than the current
      -- one -- it reports success and leaves the buffer listed and loaded. A picker always runs
      -- from its own floating prompt, so the buffer in the window it was opened from is always in
      -- exactly that position, and delegating without this sweep deletes every buffer in the set
      -- except the ones on screen, while the picker drops all of their rows because the delete
      -- reported success. Worse, upstream's rescue then moves the invoking window onto the next
      -- buffer in the set, which spares that one from its own delete for the same reason.
      --
      -- Moving each such window onto a buffer that is staying is also the invoking-window rescue
      -- this capability asks for, so picker.original_bufnr is pointed at the replacement too --
      -- that is the field upstream's own rescue keys off, and leaving it on a deleted buffer would
      -- have it fire afterwards and swap the window's buffer a second time.
      local fallback
      local function keep_buffer()
        if fallback and vim.api.nvim_buf_is_valid(fallback) then
          return fallback
        end
        for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
          if not doomed[bufnr] and vim.fn.buflisted(bufnr) == 1 then
            fallback = bufnr
            return fallback
          end
        end
        -- Every listed buffer is going: the window needs an empty one, as :bdelete would leave.
        fallback = vim.api.nvim_create_buf(true, false)
        return fallback
      end

      for _, win in ipairs(vim.api.nvim_list_wins()) do
        if doomed[vim.api.nvim_win_get_buf(win)] then
          vim.api.nvim_win_set_buf(win, keep_buffer())
        end
      end
      if doomed[picker.original_bufnr] then
        picker.original_bufnr = keep_buffer()
      end

      actions.delete_buffer(prompt_bufnr)
    end

    return {
      defaults = {
        -- Set explicitly even though the preview is enabled upstream by default: a preview is now
        -- a requirement of these pickers rather than an incidental default, and this is the line a
        -- future reader greps for. Same reasoning as binding <Esc> explicitly below.
        preview = { check_mime_type = true },
        layout_strategy = "flex",
        -- Sizes come from the Neovim window rather than from fixed row and column counts: 0.85 of
        -- each dimension leaves a rim of the underlying buffer visible for orientation, and the
        -- min floors stop the picker shrinking past the point where the prompt and a handful of
        -- results stay readable in a small split. flip_columns is the width at which flex swaps
        -- horizontal for vertical -- 120 is the same threshold as the preview_cutoff it replaces,
        -- so the arrangement now changes where the preview used to disappear.
        layout_config = {
          width = { 0.85, min = 80 },
          height = { 0.85, min = 20 },
          flex = { flip_columns = flip_columns },
          -- prompt_position is per-strategy and flex reads it from whichever strategy it flipped
          -- to, so both entries set it; otherwise the prompt jumps ends on a resize.
          horizontal = {
            prompt_position = "top",
            preview_width = 0.55,
            -- Both cutoffs are zeroed so that neither arrangement ever drops the preview pane on
            -- its own: flip_columns above is the only thing that reacts to a small window, and it
            -- moves the preview rather than removing it. It also keeps the joined border honest --
            -- the glyphs assume all three windows are on screen.
            preview_cutoff = 0,
          },
          vertical = {
            prompt_position = "top",
            preview_height = 0.5,
            preview_cutoff = 0,
            -- Without this the vertical layout orders itself preview, prompt, results, which puts
            -- the preview above the prompt and splits the prompt from its own frame. Mirrored, it
            -- reads prompt, results, preview.
            mirror = true,
          },
        },
        -- Follows from moving the prompt to the top. Telescope's default is "descending", which
        -- puts the best match at the bottom of the list -- with a top prompt that is the far end
        -- of the list from what is being typed, and it makes move_selection_next walk up the
        -- screen. "ascending" puts the best match on the first row, under the prompt, and makes
        -- <C-j> move visually downwards.
        sorting_strategy = "ascending",
        -- Keyed per window rather than one flat list, which is the other form resolve.win_option
        -- accepts, and picked for the arrangement the current window width will get. See the sets
        -- defined above for why the glyphs are what they are.
        borderchars = borderchars_for_window(),
        mappings = {
          -- Insert mode, prompt buffer only. That scoping is what lets <C-j>/<C-k> mean result
          -- navigation here and window navigation everywhere else: normal-mode window navigation
          -- is never reachable from a prompt in insert mode, so the two never contend.
          i = {
            -- Bound explicitly rather than left to the default, which is `close` in recent
            -- Telescope but has historically been "drop to the picker's normal mode".
            ["<Esc>"] = actions.close,
            -- Alongside Telescope's own <C-n>/<C-p>, which stay bound.
            ["<C-j>"] = actions.move_selection_next,
            ["<C-k>"] = actions.move_selection_previous,
          },
        },
      },
      -- <C-d> is bound here rather than beside <Esc> and <C-j> in defaults.mappings above.
      -- Telescope's own <C-d> is preview_scrolling_down, and a preview is a requirement of these
      -- pickers rather than an incidental default -- so taking <C-d> globally would cost the
      -- preview scroll in the file, grep, help, symbol and git pickers to give a delete to the one
      -- picker that can use it. A pickers.<name> block is merged over the defaults for that picker
      -- alone, and it is where a reader looks for a mapping only one picker has.
      pickers = {
        buffers = {
          mappings = {
            i = {
              ["<C-d>"] = delete_buffers_with_confirmation,
            },
          },
        },
      },
    }
  end,
  keys = {
    -- <leader><leader>, not <leader>ff: <leader>f is a prefix only, so nothing under it has to
    -- wait out 'timeoutlen' first. Each lives here, never in lua/config/keymaps.lua. The one
    -- <leader>f mapping not declared in this file is <leader>ft, which opens the theme switcher
    -- and so belongs to themes/themery.lua, the plugin it invokes.
    {
      "<leader><leader>",
      function()
        require("telescope.builtin").find_files()
      end,
      desc = "Find files",
    },
    {
      "<leader>fg",
      function()
        require("telescope.builtin").live_grep() -- needs ripgrep; :checkhealth telescope reports it
      end,
      desc = "Live grep",
    },
    {
      "<leader>fb",
      function()
        require("telescope.builtin").buffers()
      end,
      desc = "Find buffers",
    },
    -- The same picker as <leader>fb, on the unprefixed key beside <leader><leader>: switching
    -- buffers is as frequent as opening a file, and , is unbound under <leader>. The prefixed form
    -- stays, so the picker is still where the rest of <leader>f is.
    {
      "<leader>,",
      function()
        require("telescope.builtin").buffers()
      end,
      desc = "Find buffers",
    },
    {
      "<leader>fh",
      function()
        require("telescope.builtin").help_tags()
      end,
      desc = "Find help tags",
    },

    -- Symbols come from whichever language server attached to the buffer, so this picker is empty
    -- in a buffer with no server -- Telescope reports that rather than failing. Neovim's built-in
    -- gO puts the same list in the location list; this is the fuzzy-searchable form of it.
    {
      "<leader>fs",
      function()
        require("telescope.builtin").lsp_document_symbols()
      end,
      desc = "Find document symbols",
    },
    {
      "<leader>fS",
      function()
        require("telescope.builtin").lsp_dynamic_workspace_symbols() -- the whole workspace, queried as you type
      end,
      desc = "Find workspace symbols",
    },

    -- Git pickers under <leader>g. Like <leader>f, the prefix is never bound in its own right, so
    -- nothing under it waits out 'timeoutlen'. Outside a repository each of these reports that the
    -- directory is not a git repository and leaves the editor alone.
    {
      "<leader>gf",
      function()
        require("telescope.builtin").git_files() -- what git tracks, as distinct from what is on disk: ignored and untracked files are excluded
      end,
      desc = "Git tracked files",
    },
    {
      "<leader>gs",
      function()
        require("telescope.builtin").git_status()
      end,
      desc = "Git status",
    },
    {
      "<leader>gc",
      function()
        require("telescope.builtin").git_commits()
      end,
      desc = "Git commits",
    },
    {
      "<leader>gb",
      function()
        require("telescope.builtin").git_branches()
      end,
      desc = "Git branches",
    },
  },
}
