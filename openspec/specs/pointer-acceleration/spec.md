# pointer-acceleration Specification

## Purpose
Defines how the session turns physical movement of a pointing device into movement of the cursor: whether the ratio between the two is constant or varies with speed, and why that answer is not the same for a mouse as for a touchpad.

## Requirements

### Requirement: Mouse movement maps to cursor movement at a constant ratio

The cursor distance produced by a given movement of the mouse SHALL depend only on the distance the mouse was moved, and SHALL NOT depend on the speed it was moved at.

A ratio that varies with speed makes the same hand movement land the cursor in a different place each time, so no hand movement can be learned as reaching a given point on the screen and every aim becomes a correction loop. A constant ratio can be learned once.

#### Scenario: The same distance crossed at different speeds

- **WHEN** the mouse is moved across a fixed physical distance slowly, and then across the same distance quickly
- **THEN** the cursor SHALL travel the same distance on screen both times

#### Scenario: The ratio is declared rather than inherited

- **WHEN** the compositor's pointer configuration is read
- **THEN** it SHALL state the acceleration profile for the mouse explicitly
- **AND** the profile SHALL NOT be whichever one the compositor or its input library happens to default to

### Requirement: Mouse movement is not scaled away from the device's own resolution

Beyond removing the speed dependency, the session SHALL NOT scale pointer movement up or down. The distance the cursor travels for a given movement SHALL be decided by the resolution the mouse reports at.

Speed and acceleration are separate settings and separate decisions. A machine that has fixed the ratio has not thereby chosen to change it, and a pointer scaled by the compositor as well as by the device has two places to look when it feels wrong.

#### Scenario: No speed adjustment is configured for the mouse

- **WHEN** the compositor's mouse configuration is read
- **THEN** no pointer speed adjustment SHALL be set on it
- **AND** the pointer SHALL move at the unscaled ratio

### Requirement: The touchpad keeps a speed-dependent ratio

The touchpad SHALL continue to move the cursor further for a fast movement than for a slow one of the same distance. The mouse's constant ratio SHALL NOT be applied to it.

A touchpad is a surface a few centimetres across that has to reach every part of the screen, and at a constant ratio it either cannot cross the screen in one movement or is too coarse to aim with. That is the case a speed-dependent ratio exists to solve, so the argument that removes it from the mouse does not carry across.

#### Scenario: The touchpad still accelerates

- **WHEN** a finger crosses a fixed distance on the touchpad slowly, and then the same distance quickly
- **THEN** the cursor SHALL travel further on the fast movement

#### Scenario: The two devices are configured separately

- **WHEN** the compositor's input configuration is read
- **THEN** the profile set for the mouse SHALL appear only in the mouse's own configuration
- **AND** the touchpad's configuration SHALL NOT carry it

### Requirement: The pointer profile costs no added software and no restart

The profile SHALL be set through configuration the session already reads, and SHALL NOT introduce a package, a daemon, or a privileged process that reads input devices.

Changing it SHALL take effect on the running session without logging out, so that finding the right setting is a matter of saving a file rather than of ending the session once per attempt.

#### Scenario: No new dependency is required

- **WHEN** the tracked documentation's list of software the configuration expects is compared before and after
- **THEN** no entry SHALL have been added for the pointer profile

#### Scenario: The setting applies on save

- **WHEN** the pointer profile is changed in the tracked configuration and the file is saved
- **THEN** the running session SHALL adopt it
- **AND** no logout, restart, or reconnection of the device SHALL be needed
