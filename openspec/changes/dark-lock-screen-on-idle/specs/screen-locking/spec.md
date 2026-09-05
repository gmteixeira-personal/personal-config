## Purpose

Defines when the graphical session covers itself with a lock screen — on demand, after an idle period, and before the machine sleeps — and what that screen must look like and report while a password is being typed, so that walking away from an unlocked machine is not the only thing standing between the session and whoever reaches the keyboard next.

## ADDED Requirements

### Requirement: The session's lock screen is swaylock

The screen SHALL be locked by swaylock, and every path that locks the session SHALL reach it through the same tracked configuration file rather than through options passed at each call site.

One file behind every trigger is what makes the appearance requirements below testable at all. Options spread across a compositor binding, an idle daemon's argument list and a sleep hook would let the three paths drift apart, and the screen that appears would depend on why it appeared.

#### Scenario: One configuration serves every trigger

- **WHEN** the session is locked by any of its triggers
- **THEN** the screen presented SHALL be swaylock's
- **AND** its appearance SHALL come from the tracked swaylock configuration rather than from arguments given at the point of invocation

### Requirement: The session locks on demand

A compositor binding SHALL lock the screen immediately when pressed, and the label the compositor shows for that binding SHALL name the program that locks it.

#### Scenario: The binding locks the session

- **WHEN** the on-demand lock binding is pressed
- **THEN** the lock screen SHALL appear
- **AND** the session SHALL remain locked until a correct password is accepted

#### Scenario: The binding names what it runs

- **WHEN** the compositor configuration is inspected for the lock binding
- **THEN** its hotkey-overlay title SHALL name swaylock

### Requirement: The session locks after five minutes of idle

An idle daemon SHALL run for the whole graphical session and SHALL lock the screen after five minutes without input.

Five minutes is short enough that an unattended machine is not left open for a meeting's length, and long enough that reading something on screen without touching the keyboard does not trigger it. The daemon SHALL be started by the compositor with the session, so that it is present whenever there is a session to lock and absent when there is not.

#### Scenario: An idle session locks itself

- **WHEN** the session receives no input for five minutes
- **THEN** the lock screen SHALL appear without anything having been pressed

#### Scenario: The daemon starts with the session

- **WHEN** the compositor's startup entries are inspected
- **THEN** one SHALL start the idle daemon
- **AND** the idle timeout it declares SHALL be 300 seconds

#### Scenario: Activity defers the lock

- **WHEN** input is received before the idle period elapses
- **THEN** the idle period SHALL start over
- **AND** the screen SHALL NOT lock on account of the elapsed time

### Requirement: The session locks before the machine sleeps

The screen SHALL be locked before the system suspends, and the lock SHALL be in place before the machine actually goes to sleep rather than raced against it.

Suspend is the case an idle timeout cannot cover. A machine that suspends on a lid close or a timer before the idle period elapses would otherwise resume straight into an unlocked session, which is the failure the idle lock exists to prevent, reached by a different route.

#### Scenario: A suspend resumes locked

- **WHEN** the machine suspends and is then resumed
- **THEN** the lock screen SHALL be present

### Requirement: The lock screen is dark

The lock screen SHALL fill the display with a dark background, and SHALL NOT present swaylock's unconfigured light-grey default.

The screen is shown at the moments a bright display is least wanted — an idle timeout at night, a resume in a dark room — and it is shown for as long as the machine stays locked. A lock screen that is unpleasant to trigger is one that gets triggered less, so its brightness is a property of whether the session gets locked at all.

#### Scenario: Locking does not flash the display

- **WHEN** the lock screen appears
- **THEN** its background SHALL be dark
- **AND** nothing on it SHALL be brighter than the indicator that reports typing

### Requirement: The unlock indicator reports what the password field is doing

The lock screen SHALL show an indicator that distinguishes, by colour, at least: at rest, a key accepted, a character deleted, a password being verified, a password rejected, the field cleared, and Caps Lock active.

Typing blind into a screen that gives no feedback produces the failure this addresses — a password rejected because a modifier was stuck, retried identically, and rejected again. Caps Lock in particular SHALL be reported on the indicator itself and not only as text, so the reason for a rejection is visible at the place the rejection is.

#### Scenario: Each state is told apart

- **WHEN** the password field is at rest, receiving a key, receiving a backspace, verifying, rejecting, cleared, or under an active Caps Lock
- **THEN** the indicator SHALL render each of those states distinguishably from the others

#### Scenario: Caps Lock is visible on the indicator

- **WHEN** Caps Lock is active while the screen is locked
- **THEN** the indicator itself SHALL report it

### Requirement: An empty password is not a failed attempt

Submitting an empty password SHALL clear the field rather than be validated, and the count of failed attempts SHALL be shown.

A key pressed against a sleeping display, or an Enter struck to wake it, is the ordinary way an empty submission happens. Counting those as failures inflates the number the screen reports and, where an authentication policy counts them too, spends real attempts on nothing.

#### Scenario: Enter on an empty field does not count

- **WHEN** the password field is empty and submitted
- **THEN** the field SHALL clear
- **AND** the failed-attempt count SHALL NOT increase

#### Scenario: Real failures are counted visibly

- **WHEN** an incorrect password is submitted
- **THEN** the screen SHALL show the current number of failed attempts
