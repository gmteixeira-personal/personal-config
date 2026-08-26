## ADDED Requirements

### Requirement: A server's workspace is a project that server belongs to

A language server SHALL be given a workspace root only when the directory it names is a project for that server's own technology, identified by a configuration file that technology defines. The presence of a version-control directory SHALL NOT by itself qualify a directory as a workspace root, because a directory can be a repository without being a project of any particular kind — the home directory in this environment is one.

When no qualifying root is found, the server SHALL NOT attach, and SHALL NOT fall back to the buffer's own directory.

This requirement governs where a server attaches. It does not narrow the filetypes a server supports: a filetype in which that technology's markup genuinely appears SHALL remain supported inside a qualifying project.

#### Scenario: A file inside a project of that technology

- **WHEN** the user opens a file of a supported filetype inside a directory tree carrying that technology's configuration file
- **THEN** the server attaches
- **AND** its features are available in that buffer

#### Scenario: A file inside a repository that is not such a project

- **WHEN** the user opens a file of a supported filetype inside a git repository that carries no configuration file for that technology
- **THEN** that server does not attach
- **AND** no error is raised
- **AND** the buffer is fully editable

#### Scenario: A file in the home directory

- **WHEN** the user opens a file of a supported filetype directly in the home directory, which is itself a git repository
- **THEN** no server takes the home directory as its workspace root
- **AND** no server walks the home directory tree or registers file watches over it
- **AND** the editor keeps redrawing and the cursor keeps responding to motions

#### Scenario: The configuration file is above the buffer

- **WHEN** the buffer is nested several directories below the one carrying the configuration file
- **THEN** the search proceeds upward from the buffer's own path
- **AND** the directory carrying that file becomes the workspace root

#### Scenario: Declining is not the same as rooting at the buffer

- **WHEN** no qualifying configuration file is found above the buffer
- **THEN** the server is not started at all
- **AND** the buffer's own directory is not used as a substitute root
