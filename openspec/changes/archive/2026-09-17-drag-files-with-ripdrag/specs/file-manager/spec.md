## ADDED Requirements

### Requirement: A file shown in the file manager can be dragged into another application

The file manager SHALL provide a way to start a drag carrying the files it is showing, so that a file found there can be dropped into any other window on the session without leaving the file manager to find it a second time.

The file manager draws its listing in a terminal, and a terminal grid is not a drag source: the compositor starts a drag from a surface, and there is no surface here to start one from. The consequence is not that dragging is awkward but that it is absent — the file is on screen, the target window is next to it, and the only routes between them are a second file manager opened to the same directory or a path copied as text into an application that was asking for a file. Both are the session admitting that its file manager cannot do the one thing the other application is asking of it.

The drag SHALL carry every selected file, and SHALL carry the file under the cursor when nothing is selected. Those are the two ways a user says which files they mean, and a binding that honoured only one of them would be a binding the user has to remember the state of before pressing.

#### Scenario: A selection is draggable

- **WHEN** files are selected in the file manager and the drag binding is pressed
- **THEN** a window SHALL appear holding exactly those files
- **AND** dragging from it into another application SHALL deliver those files

#### Scenario: Nothing selected drags the hovered file

- **WHEN** no file is selected and the drag binding is pressed
- **THEN** the window SHALL hold the file under the cursor

#### Scenario: A name with a space arrives whole

- **WHEN** a dragged file's name contains a space
- **THEN** it SHALL be delivered as one file rather than split into two

### Requirement: The drag survives the file manager being closed

The window that carries a drag SHALL keep running after the file manager exits.

Closing the file manager to uncover the window being dropped into is not misuse; it is what a user does when the two overlap, and on a tiling compositor it is often the only way to see the target at all. A drag window tied to the file manager's lifetime dies at exactly that moment, which reads as the drag failing rather than as the file manager taking it down.

#### Scenario: The file manager exits mid-drag

- **WHEN** a drag window is open and the file manager is quit
- **THEN** the drag window SHALL remain open
- **AND** dropping from it SHALL still deliver the files

### Requirement: Files can be dropped into the directory the file manager is showing

The file manager SHALL provide a way to accept files dragged from another application, placing them in the directory currently on screen.

The absence runs both ways. A file dragged off a browser or out of another file manager has nowhere to land: dropping it on the terminal makes the terminal insert the path as input, which against the file manager's keymap is a run of keypresses rather than a file. Accepting the drop where the user is already looking is what makes the file manager a destination rather than only a viewer.

The files SHALL arrive in the directory on screen at the time of the drop, and SHALL appear in the listing without the user refreshing it.

#### Scenario: A drop lands in the current directory

- **WHEN** the drop binding is pressed and files are dropped on the window that appears
- **THEN** those files SHALL be copied into the directory the file manager is showing

#### Scenario: The listing shows them

- **WHEN** files arrive by drop
- **THEN** they SHALL appear in the listing with no refresh step

#### Scenario: A dropped directory arrives with its contents

- **WHEN** a directory is dropped
- **THEN** it SHALL be copied with everything inside it

### Requirement: A drop never overwrites a file already there

Where a dropped file has the same name as one already in the directory, the existing file SHALL be kept under another name rather than written over.

A drop is aimed with a mouse at a window that shows no listing of the destination, so the user cannot see the collision coming. A key that silently replaces a file under those conditions is a key that loses work, and the loss is discovered later by someone who has no reason to connect it to a drag. Keeping the existing file costs a name that is easy to spot and easy to delete.

#### Scenario: A name collides

- **WHEN** a file is dropped whose name already exists in the destination directory
- **THEN** the dropped file SHALL be written under that name
- **AND** the file that was there SHALL still be present under a name derived from it

#### Scenario: A cancelled drop changes nothing

- **WHEN** the drop window is closed without anything being dropped on it
- **THEN** no file SHALL be created, replaced or removed in the destination directory

### Requirement: The drag bindings are the file manager's own, and do not displace its defaults

Both bindings SHALL be declared in the file manager's own keymap, prepended to its defaults rather than replacing them, and the keys chosen SHALL NOT be keys the file manager already binds.

The alternative is a wrapper launched outside the file manager — a compositor binding, or a script the user runs beside it — which would have to be told which files are meant and would be reading that from somewhere other than the program that knows. Declaring the bindings in the keymap is what lets the drag name the selection at all.

Replacing rather than prepending would silently discard every default binding the file manager ships, which is a much larger change than the one intended and one whose damage shows up days later on a key nobody thought about. Choosing a key the file manager already uses would do the same thing on a smaller scale.

The keymap file SHALL be tracked in this repository. Held only on the machine it was written on it is indistinguishable from not existing: a checkout gets a file manager that cannot drag, with nothing recording that it once could.

#### Scenario: The bindings are in the checkout

- **WHEN** the repository is inspected for the file manager's keymap
- **THEN** a tracked file SHALL declare both bindings

#### Scenario: The defaults survive

- **WHEN** the file manager is started with the keymap in place
- **THEN** every binding it ships by default SHALL still work
- **AND** neither chosen key SHALL be one the defaults already bind

#### Scenario: A fresh checkout can drag

- **WHEN** the repository is checked out on a machine where the file manager and the drag helper are installed
- **THEN** both bindings SHALL work with no further step

### Requirement: The keymap states the file selection syntax it depends on

The keymap SHALL record which of the file manager's selection syntaxes it uses, and that the older syntax is not merely deprecated but silently wrong.

The file manager substitutes the selected paths into a shell command through placeholders, and an earlier version of the program passed them as shell positional parameters instead. A binding written the old way still parses and still runs — it opens the drag window holding no files at all. That failure presents as the helper program ignoring the selection, and every obvious next step, from checking the selection to reinstalling the helper, investigates the wrong thing.

#### Scenario: The syntax is recorded

- **WHEN** the keymap is read
- **THEN** it SHALL state which selection syntax the bindings use
- **AND** it SHALL state that the superseded syntax runs with no files rather than failing
