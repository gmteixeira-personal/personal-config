## MODIFIED Requirements

### Requirement: Fuzzy completion is available on a key

An interactive shell SHALL offer a key that opens the fuzzy finder over the completions for the current token, so that a long candidate list can be narrowed by typing any part of a candidate rather than only its prefix. The chosen candidate SHALL replace the current token.

This SHALL NOT replace the shell's own completion key, which SHALL keep its prefix-matching behavior.

Where the key carrying this action is one a terminal may consume before the shell sees it, the action SHALL additionally be bound to a key that no terminal intercepts, so that the capability does not depend on which terminal, multiplexer or remote session the shell is running under. Both keys SHALL open the same picker; neither SHALL replace the other.

This is the same argument the accept-and-run binding makes about encodings, arriving from the other side. There the key reaches the shell under more than one name and every name has to be bound; here the key may not reach the shell at all, and a second key is what covers it. In both cases the failure is silent in the same way — a modified key that is swallowed arrives as its unmodified self, so what happens is the shell's own completion, which is a plausible outcome and prompts nobody to look for a missing binding.

A second key MAY displace a preset binding. Where it does, the configuration SHALL record which preset it displaced, and the function that preset provided SHALL remain reachable by another key.

#### Scenario: Narrowing a long completion list

- **WHEN** the current token has many completions and the fuzzy completion key is pressed
- **THEN** a picker over those completions SHALL open
- **AND** the chosen candidate SHALL replace the current token

#### Scenario: The ordinary completion key is untouched

- **WHEN** the shell's own completion key is pressed
- **THEN** it SHALL complete as it did before this configuration added the fuzzy finder

#### Scenario: The action survives a terminal that swallows one of its keys

- **WHEN** the shell runs under a terminal that consumes the primary fuzzy completion key before the shell receives it
- **THEN** the fuzzy completion picker SHALL still be reachable by a key the terminal does not consume

#### Scenario: Both keys reach the same picker

- **WHEN** each key bound to fuzzy completion is pressed in turn on a terminal that delivers both
- **THEN** the same picker SHALL open for each

#### Scenario: A displaced preset is recorded and its function is still reachable

- **WHEN** a key bound for this action was preset to another function
- **THEN** the configuration SHALL name the preset it displaced
- **AND** that function SHALL remain reachable by another key
