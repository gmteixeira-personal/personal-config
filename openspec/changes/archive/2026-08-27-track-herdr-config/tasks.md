## 1. Diagnosis

- [x] 1.1 Confirm the configuration file was ignored by the deny-by-default rule and named by no allowlist entry
- [x] 1.2 Confirm the file herdr wrote on this machine carried no keys section, leaving the shipped `ctrl+b` prefix in effect

## 2. Configuration

- [x] 2.1 Add a keys section binding the prefix to `ctrl+f`
- [x] 2.2 Validate the configuration with herdr's own check
- [x] 2.3 Reload the running server so the binding applies without restarting it

## 3. Repository

- [x] 3.1 Allowlist `.config/herdr/config.toml` in block 3, beside the gh and caveman entries
- [x] 3.2 Confirm the sockets, logs, session record and plugin lock in that directory remain ignored
- [x] 3.3 Confirm the only path from that directory that git offers to track is the configuration file

## 4. Verification

- [x] 4.1 Confirm herdr reports the configuration as valid
- [x] 4.2 Confirm the reload is reported as applied
- [x] 4.3 Confirm the file is tracked after the commit
