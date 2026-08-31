## Purpose

Defines how a Python virtual environment becomes the one a shell uses: it takes effect while the working directory is inside the project that declares it, stops taking effect on leaving, behaves the same in every shell this configuration supports, and never requires the shell to execute a script it found in a directory it walked into.

## Requirements

### Requirement: A declared environment is active anywhere in its tree

A directory MAY declare a Python virtual environment for itself and everything beneath it. While the working directory is that directory or any descendant of it, the shell SHALL resolve `python`, `pip`, and every other executable the environment provides to that environment's copy, and `VIRTUAL_ENV` SHALL name it.

The declaration SHALL be found by searching the working directory and then each ancestor in turn. Where more than one ancestor declares an environment, the nearest one SHALL be the one that takes effect; declarations SHALL NOT combine.

#### Scenario: Activated on entering the project root

- **WHEN** the working directory becomes a directory that declares an environment
- **THEN** `VIRTUAL_ENV` SHALL name that environment
- **AND** `python` SHALL resolve to the interpreter inside it

#### Scenario: Still active in a subdirectory

- **WHEN** the working directory becomes a descendant of a directory that declares an environment, and no directory between them declares one of its own
- **THEN** the ancestor's environment SHALL remain active
- **AND** `python` SHALL resolve to the same interpreter it did at the project root

#### Scenario: The nearest declaration wins

- **WHEN** the working directory is inside a project that declares an environment and is itself nested inside another project that declares a different one
- **THEN** the inner project's environment SHALL be the active one
- **AND** the outer project's environment SHALL contribute nothing

#### Scenario: Moving between two projects

- **WHEN** the working directory changes directly from one project that declares an environment to another that declares a different one
- **THEN** the second project's environment SHALL be active
- **AND** no part of the first project's environment SHALL remain in `PATH`

### Requirement: Leaving restores what was there before

On the working directory leaving the tree of the directory that declared the active environment, the shell's environment SHALL be restored to exactly what it was before that environment took effect. `VIRTUAL_ENV` and the environment's `PATH` entry SHALL both be gone.

Restoration SHALL be by returning the captured previous values, not by undoing individual edits. An environment a person activated by hand SHALL therefore survive a walk through a project that declares its own: it is part of the captured state, and is put back.

#### Scenario: Leaving a project

- **WHEN** the working directory moves from inside a project that declares an environment to a directory outside its tree that declares none
- **THEN** `VIRTUAL_ENV` SHALL be unset
- **AND** `PATH` SHALL be what it was before the project was entered

#### Scenario: A hand-activated environment is not taken away

- **WHEN** a person activates an environment by hand, then enters and leaves a project that declares a different one
- **THEN** the hand-activated environment SHALL be active again on leaving
- **AND** `VIRTUAL_ENV` SHALL name it

#### Scenario: An environment does not outlive its directory

- **WHEN** any shell is at a working directory that declares no environment and whose ancestors declare none
- **THEN** `VIRTUAL_ENV` SHALL be unset, unless a person set it by hand in that shell

### Requirement: The behaviour is the same in bash and fish

Both interactive shells this configuration supports SHALL apply the requirements above, and SHALL reach the same environment for the same working directory. A project SHALL declare its environment once, in one form, and SHALL NOT carry a per-shell variant of that declaration.

#### Scenario: The same project in either shell

- **WHEN** the same project directory is entered from an interactive bash and from an interactive fish
- **THEN** both shells SHALL have `VIRTUAL_ENV` naming the same environment
- **AND** `python` SHALL resolve to the same interpreter in both

#### Scenario: One declaration serves both shells

- **WHEN** a project's environment declaration is inspected
- **THEN** it SHALL be a single file
- **AND** it SHALL contain nothing specific to either shell

### Requirement: A declaration takes effect only once approved on that machine

A directory's environment declaration SHALL have no effect until it has been approved on the machine the shell is running on. Until then, entering the directory SHALL change nothing about the environment, and the shell SHALL say that an unapproved declaration is present and what to run to approve it.

An approval SHALL be invalidated when the declaration's content changes, so that an edit is approved on its own terms rather than inheriting the approval of what it replaced.

Approvals SHALL be recorded per machine and SHALL NOT be carried between machines by this configuration.

#### Scenario: An unapproved declaration does nothing

- **WHEN** the working directory becomes a directory holding a declaration that has not been approved on this machine
- **THEN** `VIRTUAL_ENV` SHALL be unchanged
- **AND** the shell SHALL report that the declaration is present and not approved

#### Scenario: Approval is required again after an edit

- **WHEN** an approved declaration is edited
- **THEN** it SHALL stop taking effect until it is approved again

#### Scenario: A clone does not inherit approvals

- **WHEN** this configuration is cloned into a fresh environment
- **THEN** no declaration SHALL be approved there
- **AND** each SHALL require its own approval on that machine

### Requirement: No project-supplied script is executed

Activating an environment SHALL NOT run any script that the environment itself supplies. The environment SHALL be brought into effect by naming the values it contributes — the path to the environment and the directory to prepend to `PATH` — so that the content of the environment's own activation scripts is never a factor in what the shell does.

#### Scenario: An environment's activation script is never run

- **WHEN** a project's virtual environment contains an activation script with an observable side effect, and the project is entered
- **THEN** the environment SHALL be activated
- **AND** the side effect SHALL NOT have occurred

#### Scenario: Activation does not depend on the shell's dialect

- **WHEN** an environment is activated in fish
- **THEN** it SHALL be activated without reference to any fish-specific activation script the environment may or may not contain

### Requirement: A declaration naming an absent environment is reported

Where a directory declares a virtual environment that is not present, the shell SHALL report it in a single line naming the path it looked for, and SHALL leave the environment unchanged. It SHALL NOT create the environment, and SHALL NOT fail silently.

#### Scenario: The environment has not been created yet

- **WHEN** a directory declares an environment and that environment does not exist on disk
- **THEN** a single-line message SHALL be printed naming the missing path
- **AND** `VIRTUAL_ENV` SHALL be unchanged
- **AND** nothing SHALL be created

### Requirement: The active environment is reported once in the prompt

While an environment is active, the prompt SHALL say so, and SHALL name the environment and the interpreter version it provides. While none is active, the prompt SHALL carry no indicator of one.

The prompt SHALL report it in one place. Where two prompt items would both stand for the same active environment — one naming it and one merely marking that the machinery which activated it is engaged — only the item that names it SHALL be drawn. A mark that is present exactly when a named item is present tells the reader nothing the named item has not already said, and costs them a glyph to recognise.

This governs what the prompt draws, not what is active. An environment SHALL be activated, and deactivated, exactly as the requirements above specify, whether or not any prompt item reports it.

#### Scenario: Inside a project that declares an environment

- **WHEN** the prompt is drawn with the working directory inside a project whose environment is active
- **THEN** it SHALL show one item naming the environment and the interpreter version
- **AND** it SHALL show no second item standing for the same environment

#### Scenario: Outside any such project

- **WHEN** the prompt is drawn with no environment active
- **THEN** it SHALL show no item reporting one

#### Scenario: Reporting is not activation

- **WHEN** a project that declares an approved environment is entered
- **THEN** `VIRTUAL_ENV` SHALL name that environment regardless of which prompt items are configured

### Requirement: Activation is silent unless something needs attention

Activating an environment, keeping it active while the working directory moves within its tree, and restoring the previous environment on leaving SHALL each produce no output. A shell that is doing what it is supposed to do SHALL say nothing about it.

This is a rule about the success path only. It SHALL NOT suppress any report this capability already requires: a declaration that has not been approved on this machine, and a declaration naming an environment that is not present, SHALL each still be reported in full, naming the path concerned and, where an action is needed, the command that takes it. Silence SHALL be the absence of routine reporting, not the loss of a diagnostic.

The distinction SHALL be drawn by what the message is, not by which shell is running or which directory it is in. Both interactive shells this configuration supports SHALL be silent on the same events and loud on the same ones.

#### Scenario: Entering a working project says nothing

- **WHEN** the working directory becomes a directory whose approved declaration names an environment that exists
- **THEN** the environment SHALL be active
- **AND** no output SHALL be produced

#### Scenario: Moving within and leaving say nothing

- **WHEN** the working directory moves to a descendant of such a directory, and then out of its tree entirely
- **THEN** the environment SHALL remain active and then be restored as the requirements above specify
- **AND** no output SHALL be produced by either move

#### Scenario: An unapproved declaration is still reported

- **WHEN** the working directory becomes a directory holding a declaration that has not been approved on this machine
- **THEN** the report SHALL still be printed, naming the declaration and the command that approves it

#### Scenario: A missing environment is still reported

- **WHEN** a directory's approved declaration names an environment that does not exist on disk
- **THEN** the single-line report naming the missing path SHALL still be printed

#### Scenario: Both shells are quiet on the same events

- **WHEN** the same working project is entered from an interactive bash and from an interactive fish
- **THEN** neither SHALL produce output
- **AND** an unapproved declaration entered from either SHALL be reported by both

### Requirement: Only interactive shells are affected

This behaviour SHALL apply to interactive shells alone. A script, hook, or tool runner that changes directory SHALL see no environment activated or deactivated on its behalf, and SHALL start with no error about it.

#### Scenario: A script changes directory

- **WHEN** a non-interactive shell changes its working directory into a project that declares an environment
- **THEN** its environment SHALL be unchanged
- **AND** it SHALL produce no output about the declaration

### Requirement: The machinery is optional and inert when absent

Where the machine does not provide the tool this behaviour is built on, every shell SHALL start normally, report no error, and behave as it did before this capability existed. Environments SHALL then be activated by hand. This configuration SHALL NOT carry a second implementation of the behaviour for that case, and SHALL name the tool's install command in the bootstrap documentation.

#### Scenario: The tool is not installed

- **WHEN** an interactive shell starts on a machine where the tool is absent
- **THEN** the shell SHALL start with no error or warning about it
- **AND** entering a project that declares an environment SHALL change nothing

#### Scenario: Hand activation still works

- **WHEN** a person activates an environment by hand on a machine where the tool is absent
- **THEN** it SHALL take effect and remain in effect for that shell

#### Scenario: The dependency is documented

- **WHEN** the bootstrap documentation is read
- **THEN** it SHALL name the command that installs the tool
