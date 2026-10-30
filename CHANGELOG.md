# Changelog

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/)
and this project follows [semantic versioning](https://semver.org/).

## [1.0.0] - 2026-10-30

### Added

- The `clear` command in `cmd.exe`, via a `clear.cmd` shim written to
  `%LOCALAPPDATA%\Microsoft\WindowsApps`.
- Idempotent install: running the script again repairs the shim without
  creating duplicates.
- `/uninstall` to remove the shim and `/?` for help.
- A writability check on the target folder before writing, using a temporary
  probe file.
- A final `where clear` check that reports any `clear.exe` coming before the
  shim in PATH.
- PowerShell detection: reports whether `clear` is already available, otherwise
  prints the profile line to add, without editing the profile.
