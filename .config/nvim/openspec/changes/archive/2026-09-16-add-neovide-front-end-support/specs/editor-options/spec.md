## ADDED Requirements

### Requirement: A setting only a graphical front end reads is set here, behind a guard

Where a graphical front end that opens this configuration reads a setting from the editor and offers no other way to set it, that setting SHALL be set in the general options module, inside a block that runs only under that front end.

The general options module opens by declaring that it holds general editing options and that a plugin's own settings live with the plugin. A front end is neither, which is what makes this worth stating rather than assuming: without a rule, such a setting has no home at all and is simply lost. It is admitted here only on the condition that there is nowhere else — a front end that carries its own configuration file SHALL be configured there instead.

The block SHALL be guarded so that it has no effect when the editor is started in a terminal, and SHALL record why the setting is not with the front end's own configuration. Where the front end does have a configuration file, that file SHALL name this one, so that neither is a dead end for a reader looking for the setting.

#### Scenario: The setting takes effect under the front end

- **WHEN** the editor is started under the graphical front end
- **THEN** the setting SHALL be in effect

#### Scenario: A terminal start is unaffected

- **WHEN** the editor is started in a terminal
- **THEN** the block SHALL have no effect
- **AND** no error SHALL be raised

#### Scenario: The exception is explained at both ends

- **WHEN** the block is read
- **THEN** it SHALL state that the front end offers no other interface for the setting
- **AND** the front end's own configuration file SHALL name the file carrying it

#### Scenario: A setting with another home does not come here

- **WHEN** a front-end setting can be made in the front end's own configuration file
- **THEN** it SHALL NOT be set in the general options module
