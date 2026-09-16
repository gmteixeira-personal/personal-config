## Context

See proposal.md — Why. The constraints that shape the approach:

- The message UI's component runs its own health check on a one-second interval and raises what it finds through `vim.notify`. The switch that turns the interval off, `health.checker`, turns off every finding it makes, not one.
- The check reads `nvim_list_uis()` and errors on `ext_cmdline`, `ext_popupmenu` or `ext_messages`. Measured under the front end: all three false on forty consecutive samples from launch onward, including when started through its desktop entry rather than from a shell; `:checkhealth noice` answers "You're using a GUI that should work ok".
- The component's route filters support both a substring match on the message and a `cond` predicate, so a route can be scoped to one front end.
- The front end reads window padding from four `vim.g` variables. A `[padding]` table in its own configuration file is accepted and then ignored — measured: the grid does not change.

## Goals / Non-Goals

**Goals:**

- Stop showing one specific false claim without stopping the check that makes it.
- Keep the terminal's behaviour identical.
- Leave the evidence in the file, so the suppression is re-examinable rather than folklore.

**Non-Goals:**

- Finding the root cause of the race inside the front end's UI attach. It is upstream, it is transient, and the measurements bound it well enough to suppress the symptom.
- Anything else about the front end. The launcher entry, the font, and the rasterization belong to the home repository's `gui-text-editor` capability.
- Taking the padding values out of this configuration once the front end grows a setting for them. If it does, that is a change, not a cleanup to do silently.

## Decisions

**A `routes` entry, not `health = { checker = false }`.** Turning the checker off is the documented switch and was rejected: it also drops the `lazyredraw` warning and the missing-parser findings, which are real. The route drops one notification and leaves the poller running, so `:checkhealth` still reports what it found. The trade is that a future front end that really does enable `ext_cmdline` would be suppressed too — which is why the route is scoped rather than unconditional.

**Scoped with `cond` on the front-end variable, not written unconditionally.** The claim is only known to be wrong here. Under a front end that genuinely drives the command line, the component really is broken and should say so.

**Matched on the message text rather than on the component's source.** A filter has no access to which check raised a message; the substring is the only handle. It is the invariant half of both strings — the part naming the conflict rather than the extension — so one entry covers the `ext_cmdline` and `ext_messages` pair without matching anything else. Verified against synthetic messages inside the running front end: both warnings match, an unrelated error does not, and with the front-end variable unset none of them do.

**The comment above `views` is rewritten rather than left.** It stated that no route was present and explained at length why the default `msg_showmode` skip is not re-displayed. That reasoning is still correct and is kept; only the claim that the table is empty is wrong, and a comment that contradicts the file below it is worse than no comment.

**Padding in the general options module, guarded.** The alternative was to leave the setting unmade. The front end's own configuration file cannot carry it, so the choice was a guarded block here or a window that frames its grid differently from the terminal beside it. Both ends are annotated so a reader landing on either file is sent to the other.

## Risks / Trade-offs

- **A real conflict under this front end would now be silent in the notification.** → It is not silent in `:checkhealth`, and the route's comment says so and says where to look.
- **The match is on message text, which upstream can reword.** → The route would then stop matching and the notification would come back — a visible failure rather than a silent one, and the same evidence in the comment applies to re-scoping it.
- **The first GUI-specific branch in a file that declares it holds general options.** → One guarded block, stated as the exception, with the condition under which another one is admitted written into the requirement rather than left to judgement.
