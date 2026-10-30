# clear-alias

![Platform](https://img.shields.io/badge/platform-Windows%2010%20%7C%2011-0078D6)
![License](https://img.shields.io/badge/license-MIT-green)

The `clear` command, on Windows too.

On Linux and macOS `clear` wipes the terminal. On Windows `cls` does the same
thing, but the word `clear` does not exist: `cmd.exe` treats it as an unknown
command. This script adds `clear` to `cmd.exe` by creating a tiny `clear.cmd`
shim in a folder that is **already** in the user PATH.

No registry, no `setx`, no PATH changes, no administrator privileges.

## What it does

| Shell | Before | What this script does |
| --- | --- | --- |
| `cmd.exe` | `clear` does not exist (`cls` does) | creates the `clear.cmd` shim |
| PowerShell | `clear` is already an alias for `Clear-Host` | touches nothing, reports it |
| Git Bash / MSYS2 | `clear` already exists (`/usr/bin/clear`) | touches nothing |

## Requirements

- Windows 10 or 11
- No administrator privileges
- No external dependencies

## Installation

Clone the repository and run the script from `cmd`:

```bat
git clone https://github.com/justfeib/clear-alias.git
cd clear-alias
clear-alias.bat
```

Or just double-click `clear-alias.bat` in File Explorer.

Expected output:

```
[OK] Shim created:
     C:\Users\<user>\AppData\Local\Microsoft\WindowsApps\clear.cmd

     Contents:
       @echo off
       cls

Checking where "clear" resolves right now:
C:\Users\<user>\AppData\Local\Microsoft\WindowsApps\clear.cmd
  [OK] Found. ...
```

Nothing needs to restart: the target folder was already in PATH, so `clear`
works in cmd windows that are already open too.

## Usage

```bat
clear-alias.bat              :: install or repair
clear-alias.bat /uninstall   :: remove
clear-alias.bat /?           :: help
```

Then, in any `cmd`:

```bat
clear
```

## Verification

```bat
where clear
```

It must point to `%LOCALAPPDATA%\Microsoft\WindowsApps\clear.cmd`. If more than
one line is listed, `cmd` uses the **first** one: a `clear.exe` earlier in PATH
would run instead of the shim (the script warns you about that).

## Uninstalling

```bat
clear-alias.bat /uninstall
```

Or delete `%LOCALAPPDATA%\Microsoft\WindowsApps\clear.cmd` by hand.
Nothing else is left behind on the system: `cls`, PowerShell and Git Bash were
never modified.

## How it works

The shim is not a program: it is a two-line file.

```bat
@echo off
cls
```

It is written to `%LOCALAPPDATA%\Microsoft\WindowsApps`, a folder Windows
already puts in the user PATH for Store app aliases; it is writable without
elevation and it is the lowest-impact destination. `cmd` resolves commands by
searching PATH on every invocation, so the shell does not need a restart.

The script is idempotent: run again, it rewrites an identical file and never
duplicates anything. Before writing, it checks that the folder exists and is
writable using a temporary probe file.

## Notes

- **PowerShell 7 (`pwsh`)**: it is not installed everywhere. If you install it,
  it has a separate profile (`Documents\PowerShell\...`): if `clear` is missing
  there, add `Set-Alias -Name clear -Value Clear-Host` to that profile.
- **PowerShell 5.1** already ships the `clear` alias, so no configuration is
  needed.
- The file is pure ASCII with CRLF line endings, to avoid codepage issues or
  `\n` problems in `cmd`.

## Testing

Verified by hand on Windows 11 (PowerShell 5.1 + cmd.exe):

| Case | Result |
| --- | --- |
| Install with no shim | creates the file, exit `0` |
| Install with shim present | rewrites the file, exit `0` |
| `/uninstall` | removes the file, exit `0` |
| Unknown option | error message, exit `2` |
| `/?` | help, exit `0` |
| Resolution against the real persistent PATH | only the shim, `clear` exit `0` |

## License

[MIT](LICENSE)
