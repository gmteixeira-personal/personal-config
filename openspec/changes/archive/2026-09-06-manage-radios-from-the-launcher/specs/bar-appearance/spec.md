## ADDED Requirements

### Requirement: A module reporting a radio opens that radio's controls

Where the bar carries a module reporting the state of a radio, clicking that module SHALL open the session's interface for managing that radio. The click SHALL perform that action alone.

This is the debt left by the requirement that a module earns its place by being acted on. That requirement names the bar itself as where the acting happens, and the network module was carried in breach of it — a reading with nothing behind it, because the packaged configuration it inherits from defines no click at all. The Bluetooth module had a click, but one that opened a terminal REPL: a way out of the bar rather than a way to act on it.

A module whose click both runs a command and toggles its own label is the failure mode to avoid here, and it is the default rather than an unlikely mistake: the bar's own implementation fires an alternate-format toggle and the configured command on the same button. The label then reads differently depending on how many times it has been clicked, which makes a glanceable module unreadable in exactly the situation it is being used.

#### Scenario: The Bluetooth module opens Bluetooth management

- **WHEN** the bar's Bluetooth module is clicked
- **THEN** the session's Bluetooth management interface SHALL open

#### Scenario: The network module opens wireless management

- **WHEN** the bar's network module is clicked
- **THEN** the session's wireless management interface SHALL open

#### Scenario: The click does not also change the label

- **WHEN** a module reporting a radio is clicked
- **THEN** the text that module displays SHALL be unchanged by the click
