## ADDED Requirements

### Requirement: A binding does not depend on which terminal is in use

Where a key reaches the shell under more than one encoding, this configuration SHALL bind the action under every one of them, so that the key performs its action on any terminal the configuration is used from. A terminal SHALL NOT be a silent precondition of a binding: replacing the terminal SHALL NOT remove a capability the configuration declares.

Ctrl+Enter is the case this exists for. A terminal that speaks the kitty keyboard protocol reports it as a key distinct from Enter; a terminal that does not sends the same byte as Ctrl+J and the modifier is lost. Binding only the encoding measured on the terminal of the day leaves the key unbound on every other terminal, and — because a shell that reports the key under an unbound name may still resolve it to a preset action — the failure is not an error but a wrong action, which is why it can go unnoticed.

#### Scenario: The action is bound under every encoding of its key

- **WHEN** the bindings in effect at a prompt are inspected for the accept-and-run action
- **THEN** it SHALL be bound under the name a terminal speaking the kitty keyboard protocol reports for the key
- **AND** it SHALL be bound under the name a terminal without that protocol reports for the same key
- **AND** neither name SHALL resolve to a preset action instead

#### Scenario: The terminal is replaced

- **WHEN** the graphical session's terminal is replaced by one that encodes modified keys differently
- **THEN** the accept-and-run key SHALL still accept the autosuggestion and run it
- **AND** no change to this configuration SHALL be required for that to hold

#### Scenario: A measured encoding is recorded with the terminal class it was measured on

- **WHEN** a binding's documentation states which encoding a key arrives under
- **THEN** it SHALL attribute that encoding to a class of terminal rather than to the terminal the machine happens to run
- **AND** a reader SHALL be able to tell from it whether the statement still applies after the terminal has changed
