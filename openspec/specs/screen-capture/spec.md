# screen-capture Specification

## Purpose
Defines how a screenshot is taken and where it goes: that a region of the screen is reachable from a chord the machine's keyboard actually has, that the capture can be drawn on before it is delivered, and that the clipboard is the delivery — so a screenshot with an arrow on it is one gesture rather than a capture, a file, an editor and a copy.

## Requirements

### Requirement: A region screenshot is reachable from the keyboard

The session SHALL bind a region screenshot to a key combination that exists on the keyboard of the machine the configuration is running on.

A binding on a key the keyboard does not have is indistinguishable from no binding at all, and worse than none: the configuration records that screenshots work, so the absence is discovered only by pressing a key and watching nothing happen. Dedicated screenshot keys are exactly the keys a compact keyboard drops, so the binding cannot rely on one being present.

#### Scenario: The chord is pressable

- **WHEN** the configuration is loaded on this machine
- **THEN** the region screenshot SHALL be bound to a combination of keys the keyboard has

#### Scenario: A dedicated screenshot key still works where it exists

- **WHEN** the configuration is loaded on a machine whose keyboard has a dedicated screenshot key
- **THEN** that key SHALL still take a screenshot

### Requirement: The capture is annotatable before it is delivered

Taking a region screenshot SHALL open the captured region for annotation, and the annotated result SHALL be what is delivered.

Annotation is the reason the screenshot is being taken in the common case — an arrow at the thing being asked about, a line over an address that should not travel with it. A capture path that delivers first and offers editing afterwards has already put the unannotated image where it was going, which for a redaction is the whole failure.

#### Scenario: Annotation reaches the output

- **WHEN** a region is captured and annotated
- **THEN** the delivered image SHALL include the annotations

#### Scenario: Annotation is optional

- **WHEN** a region is captured and delivered with nothing drawn on it
- **THEN** the delivered image SHALL be the captured region unchanged

### Requirement: The clipboard is the delivery and no file is written

A completed region screenshot SHALL be placed on the system clipboard, and SHALL NOT be written to disk.

These screenshots are pasted once, into a message or a compose window, and are not wanted again. Writing every one to a directory produces a folder that only ever grows and that nobody prunes; the deliberate cost of not writing them is that a screenshot lost before pasting is gone, which is recoverable by taking it again.

#### Scenario: The result is pastable

- **WHEN** a region screenshot is completed
- **THEN** the image SHALL be on the clipboard
- **AND** an application accepting a pasted image SHALL receive it

#### Scenario: Nothing accumulates on disk

- **WHEN** region screenshots have been taken
- **THEN** no screenshot file SHALL have been written by that path

### Requirement: Cancelling produces nothing and says nothing

Abandoning the region selection SHALL leave the clipboard unchanged, write nothing, and report no error to the user.

Cancelling is a normal outcome rather than a fault — the region was mis-started, or the thing to capture moved — and an error dialog or a notification for it would fire on an ordinary gesture. The clipboard in particular must survive: its previous contents are frequently what the user was about to paste.

#### Scenario: The selection is abandoned

- **WHEN** the region selection is cancelled
- **THEN** no image SHALL be placed on the clipboard
- **AND** the clipboard's previous contents SHALL be intact
- **AND** no error SHALL be presented
