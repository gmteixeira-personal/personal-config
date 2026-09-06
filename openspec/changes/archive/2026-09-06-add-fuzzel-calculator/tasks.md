## 1. The evaluator

- [x] 1.1 Establish what the machine can evaluate with — confirm no `qalc` and no `bc`, and that `python3`, `wl-copy` and `notify-send` are present
- [x] 1.2 Write the AST walk over an allowlist of node types, refusing attribute access, subscripts, comprehensions, starred and keyword arguments, and every name outside the constants and functions it defines
- [x] 1.3 Cap integer exponentiation and verify `9**9**9` returns a refusal rather than consuming the machine
- [x] 1.4 Render results so an integer keeps its digits, an integral float loses its `.0`, and `0.1+0.2` shows `0.3`
- [x] 1.5 Map `^` to exponentiation and strip a trailing `=`, and verify `2^10 =` evaluates to `1024`
- [x] 1.6 Separate the messages for division by zero, an unsupported expression and a malformed one, and verify each is reached by an expression that produces it
- [x] 1.7 Verify the evaluator against a set of expressions covering the operators, constants, functions, and the refusals — including `__import__("os").system("id")`

## 2. The window loop

- [x] 2.1 Write the fuzzel call: dmenu mode, `= ` prompt, the single entry on stdin, the pre-fill through `--search`, and the session's menu width
- [x] 2.2 Hold the last expression, result and error across iterations, and render exactly one of them as the entry
- [x] 2.3 Detect a picked result by comparing the returned text to the offered entry, and verify the entry is the bare result so that no expression collides with it
- [x] 2.4 Copy on a picked result, notify with the application name the radio menus use, and exit
- [x] 2.5 Treat an empty return as dismissal and exit without touching the clipboard
- [x] 2.6 Verify the loop end to end against a stubbed `fuzzel` — compute then copy, chain from a result, error then correction, dismissal, and a result of `0`
- [x] 2.7 Verify the real window opens against the running compositor and stays open

## 3. Reachability

- [x] 3.1 Add the desktop entry with a bare `Exec` name, and verify it with `desktop-file-validate`
- [x] 3.2 Draw the icon on the same 16px grid and in the same colour as the two existing launcher icons, and verify it parses as XML
- [x] 3.3 Link the script into `.local/bin` with a relative target, and verify the link resolves
- [x] 3.4 Verify the launcher lists the calculator and that no file among the four names this machine's home directory

## 4. Tracking

- [x] 4.1 Add the block 3 entry for the script and the three block 5 entries for the entry, the icon and the link, and amend the comments that describe two scripts
- [x] 4.2 Verify `git status --short` names the four files individually rather than collapsing them into an ignored directory
- [x] 4.3 Run `openspec validate add-fuzzel-calculator --strict` and verify it passes
