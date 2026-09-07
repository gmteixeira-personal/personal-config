# workspace-overview Specification

## Purpose

Defines how the session's zoomed-out view of workspaces and windows is reached from the keyboard: which chords open and close it, what a chord bound to it has to carry to behave while it is held, and which chord is deliberately left unbound so that applications keep it.

## Requirements

### Requirement: The Overview is reachable from the modifier and Tab

The compositor SHALL open and close the Overview on the modifier key held with Tab, and SHALL keep the chord it is already bound to working alongside it.

The chord that reached the Overview first, the modifier with O, names the feature by its initial. That is a good way to write a binding down and a poor way to reach for one: nothing about the letter says what it does, so the chord has to be recalled rather than found. The modifier held with Tab is where the hand goes without being told, because every other desktop puts a view of everything open on that chord. Adding it is therefore not a rename — the initial stays useful to anyone who already learned it, and a binding that costs nothing to keep is not worth taking away.

Both chords SHALL perform the same action, so that neither is a partial version of the other and a user who learns one has learned the feature.

#### Scenario: The new chord opens the Overview

- **WHEN** the modifier is held and Tab is pressed with the Overview closed
- **THEN** the Overview SHALL open

#### Scenario: The new chord closes the Overview

- **WHEN** the modifier is held and Tab is pressed with the Overview open
- **THEN** the Overview SHALL close

#### Scenario: The original chord is unaffected

- **WHEN** the modifier is held and O is pressed
- **THEN** the Overview SHALL open and close exactly as the modifier with Tab does

### Requirement: A chord that toggles the Overview does not act again while held

Every chord this capability binds to the Overview SHALL be marked as not repeating.

The action is a toggle, and the keyboard repeats a held chord several times a second. A toggle driven by key repeat opens and closes the view once per repeat for as long as the chord is down, which is not a slow version of the feature but a different and useless one: the view flickers, and whether it is open when the key is released depends on how long it was held. The chord this one duplicates already carries the marking, and the two behaving differently on a held key would be the kind of difference nobody thinks to look for.

#### Scenario: The chord is held down

- **WHEN** a chord bound to the Overview is held past the keyboard's repeat delay
- **THEN** the Overview SHALL toggle exactly once
- **AND** its state when the chord is released SHALL NOT depend on how long the chord was held

### Requirement: Alt with Tab is left to applications

The compositor SHALL NOT bind Alt held with Tab, so that the chord reaches the window that has focus.

This is a decision, not an omission. The chord is the one a user is most likely to expect the compositor to take, and taking it would silently remove a keystroke that applications — browsers, editors, terminals with their own tabs — bind for themselves. The session's answer to "show me everything open" is the modifier with Tab; Alt with Tab is not a second answer to that question and is not answered at all here.

Where the compositor's modifier resolves to Alt — which it does when the compositor runs nested inside another session's window rather than on a virtual console — the two chords are the same chord and this requirement cannot hold alongside the first. That configuration is for development and is not the session this capability describes. The documentation SHALL record the collision so that it is read as a known consequence of the modifier's definition rather than as a broken binding.

#### Scenario: An application receives the chord

- **WHEN** Alt is held and Tab is pressed with an application focused that binds the chord
- **THEN** the application SHALL receive it
- **AND** the compositor SHALL take no action of its own

#### Scenario: The nested case is recorded

- **WHEN** the documentation for the Overview bindings is read
- **THEN** it SHALL state that the modifier resolves to Alt when the compositor runs nested
- **AND** it SHALL state that the two chords coincide there

### Requirement: No chord this capability binds is left as a commented example

Where the configuration binds a chord, any commented-out binding for that same chord elsewhere in the file SHALL be removed rather than left in place.

The compositor rejects a configuration that binds one chord twice: it does not shadow the earlier binding or the later one, it refuses to load the file and the session keeps running on the configuration it already had. A commented example for a chord that is now bound is therefore not an inert suggestion. It is a line that takes the whole file down for anyone who uncomments it, and it reads as an available option precisely because it is commented out.

#### Scenario: The example for the bound chord is gone

- **WHEN** the configuration is searched for the chord this capability binds
- **THEN** it SHALL appear once, as a live binding
- **AND** no commented-out binding for the same chord SHALL remain

#### Scenario: The reason the example cannot stay is recorded

- **WHEN** the configuration is read around the binding
- **THEN** it SHALL record that a duplicate binding is a config-loading error rather than a shadowed binding
