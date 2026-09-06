# expression-calculator Specification

## Purpose
Defines what the session must be able to compute and how the answer is delivered — that arithmetic is reachable from the session's own launcher rather than from an interpreter in a terminal, that a result can be carried away on the clipboard rather than only read, that an expression typed into a surface anyone at the keyboard can reach evaluates as arithmetic and never as a program, and that an expression the session cannot evaluate is answered rather than silently dropped.

## Requirements

### Requirement: Arithmetic is evaluated from the session's launcher

The session SHALL provide an interface, reached from the session's own launcher, that evaluates an arithmetic expression typed into it and shows the result, without a terminal.

The expression SHALL support the four operations, integer division, remainder, exponentiation, parentheses, the constants `pi`, `e` and `tau`, and the common mathematical functions. The interface SHALL remain open after a result so that a second expression can be asked without reopening it, and SHALL make the result available as the starting point of that second expression.

The session installs no calculator, no `qalc` and no `bc`, so arithmetic meant starting an interpreter in a terminal window — more setup than the question, and a window left behind afterwards. The radio menus already established that the launcher is where a task of this size belongs.

Staying open is what separates a calculator from a single-shot evaluator. A sum is rarely asked once: the second question is usually the first one's answer times something, and an interface that closes on each result makes the user retype a number the session already has.

#### Scenario: An expression is evaluated

- **WHEN** `2*(2+2)` is typed into the calculator and confirmed
- **THEN** `8` SHALL be shown
- **AND** no terminal window SHALL be opened

#### Scenario: A second expression continues from the first result

- **WHEN** a result is shown and further operators and operands are typed after it
- **THEN** the expression evaluated SHALL be the one beginning with that result
- **AND** the result SHALL NOT have to be retyped

#### Scenario: A result is shown as a reader would write it

- **WHEN** an expression whose exact value is not representable as a binary fraction is evaluated
- **THEN** the result SHALL be shown rounded to a precision a reader can use
- **AND** it SHALL NOT expose the interpreter's full floating-point expansion

### Requirement: A result can be taken away, not only read

Confirming a shown result SHALL place that result on the clipboard and close the interface, and SHALL report that it did so. Dismissing the interface SHALL NOT change the clipboard.

A number that can only be read has to be copied by hand into whatever asked for it, which is the transcription error the calculator was opened to avoid. The clipboard is also the only channel this interface has: it draws over the session and leaves nothing behind, so a result not carried out on the clipboard is gone when the window closes.

#### Scenario: A result is copied

- **WHEN** a shown result is confirmed without being edited
- **THEN** the clipboard SHALL contain exactly that result
- **AND** the session SHALL show a notification naming what was copied

#### Scenario: Dismissal leaves the clipboard alone

- **WHEN** the calculator is dismissed without a result being confirmed
- **THEN** the clipboard SHALL hold what it held before the calculator was opened

### Requirement: A typed expression cannot execute anything

The calculator SHALL evaluate only arithmetic. It SHALL NOT pass the typed text to a general-purpose evaluator, and SHALL reject any expression naming anything outside the operators, constants and functions it defines.

The input box is reachable by anyone at the keyboard of an unlocked session and by anything that can synthesise keystrokes into it, and the launcher is the surface this session opens most. An evaluator that reaches the interpreter's builtins turns that box into a shell prompt — `__import__("os").system(…)` is a working command in every language whose evaluation function is the obvious way to build this.

An expression whose result cannot be computed in bounded time or memory SHALL be refused rather than attempted. The interface has no cancel: it is a modal surface with no progress and no way out, so a computation that does not return is indistinguishable from a hung session and is ended by killing the process.

#### Scenario: An expression naming an unknown name is refused

- **WHEN** an expression referring to a name the calculator does not define is confirmed
- **THEN** the calculator SHALL show that the expression is not supported
- **AND** nothing named in the expression SHALL be executed, imported or read

#### Scenario: An unbounded computation is refused

- **WHEN** an expression is confirmed whose evaluation would exhaust the machine's memory
- **THEN** the calculator SHALL refuse it and stay usable
- **AND** it SHALL NOT begin the computation

### Requirement: A wrong expression is answered rather than swallowed

An expression the calculator cannot evaluate SHALL produce a message in place of a result, and the text that produced it SHALL remain available for correction. The calculator SHALL stay open.

Every mistake here is a typing mistake, and a typing mistake in a window that closes on Enter costs the whole expression. Distinguishing division by zero from a malformed expression matters for the same reason: the two are corrected differently, and a single "error" makes the user re-read text that is fine.

#### Scenario: A malformed expression keeps its text

- **WHEN** `2+` is confirmed
- **THEN** a message SHALL be shown instead of a result
- **AND** the text `2+` SHALL still be present for editing
- **AND** the calculator SHALL stay open

#### Scenario: Division by zero is named

- **WHEN** an expression dividing by zero is confirmed
- **THEN** the message SHALL say that the division is by zero
- **AND** it SHALL be distinguishable from the message for a malformed expression

### Requirement: The calculator is reproducible from tracked files

Every file the calculator needs in order to be reachable and to run SHALL be tracked, and none of them SHALL name the home directory of the machine it was written on.

The calculator is not one file: the script computes, the launcher entry is how it is found, the icon is what the entry names, and the link on `PATH` is what the entry resolves. Tracking the script alone produces a clone where the program exists and nothing opens it — the same gap the launcher entries for the radio menus were added to close.

#### Scenario: A clone has a working calculator

- **WHEN** the repository is cloned into a home directory with a different name and the session is started
- **THEN** the calculator SHALL be reachable from the launcher
- **AND** no file SHALL have to be recreated by hand for that to hold

#### Scenario: No tracked file names this machine

- **WHEN** the tracked files that make up the calculator are inspected for an absolute path naming a home directory
- **THEN** none SHALL contain one
