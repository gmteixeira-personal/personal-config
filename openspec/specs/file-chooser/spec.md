# file-chooser Specification

## Purpose
Defines that an application asking this session for a file dialog gets a working one, because the desktop portal backend this compositor uses implements no file chooser itself and delegates to another program — making that program part of what the session must provide rather than an optional convenience.

## Requirements

### Requirement: An application asking for a file dialog gets one

When an application requests a file open or save dialog from the desktop portal, the session SHALL present a dialog the user can complete or cancel.

This is not automatic on a session assembled from parts. The portal backend selected for this compositor answers the file chooser interface by delegating to a file manager it does not depend on, so a session without that file manager advertises a file chooser and provides none. Every application that asks — a browser attaching a file, an editor saving one — is affected at once.

#### Scenario: A dialog appears

- **WHEN** an application requests a file dialog through the desktop portal
- **THEN** a file dialog SHALL be presented

#### Scenario: The user's choice reaches the application

- **WHEN** a file is chosen in that dialog
- **THEN** the requesting application SHALL receive the chosen path

#### Scenario: Cancelling returns to the application

- **WHEN** the dialog is cancelled
- **THEN** the requesting application SHALL be told, and SHALL NOT be left waiting

### Requirement: The delegate the portal backend requires is provided

Where the session's portal backend implements the file chooser interface by delegating to another program, that program SHALL be installed and SHALL be named in the tracked required-software documentation.

The failure without it is silent in both directions: the portal is running and answers on the bus, so nothing looks broken, while the delegated call fails and the application shows no window and no error. Nothing at the point of use names the missing package, and the same absence breaks every application at once, which reads as "file dialogs are broken on Linux" rather than as one uninstalled program.

#### Scenario: The delegate is present

- **WHEN** the session is running
- **THEN** the program the portal backend delegates the file chooser to SHALL be installed

#### Scenario: The dependency is discoverable

- **WHEN** the tracked required-software documentation is read
- **THEN** that program SHALL be named
- **AND** the documentation SHALL state that file dialogs stop appearing without it
