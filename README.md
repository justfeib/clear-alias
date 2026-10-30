# clear-alias

![Platform](https://img.shields.io/badge/platform-Windows%2010%20%7C%2011-0078D6)
![License](https://img.shields.io/badge/license-MIT-green)

Il comando `clear` anche su Windows.

Su Linux e macOS `clear` pulisce il terminale. Su Windows `cls` fa la stessa cosa,
ma la parola `clear` non esiste: in `cmd.exe` viene ignorata come comando
sconosciuto. Questo script aggiunge `clear` a `cmd.exe` creando un piccolo shim
`clear.cmd` in una cartella che e' **gia'** nel PATH dell'utente.

Niente registro, niente `setx`, niente modifiche al PATH, niente privilegi di
amministratore.

## Cosa fa

| Shell | Stato prima | Cosa fa questo script |
| --- | --- | --- |
| `cmd.exe` | `clear` non esiste (`cls` si') | crea lo shim `clear.cmd` |
| PowerShell | `clear` e' gia' un alias di `Clear-Host` | non tocca nulla, lo segnala |
| Git Bash / MSYS2 | `clear` esiste gia' (`/usr/bin/clear`) | non tocca nulla |

## Requisiti

- Windows 10 o 11
- Nessun privilegio di amministratore
- Nessuna dipendenza esterna

## Installazione

Scarica il repository e lancia lo script da `cmd`:

```bat
git clone https://github.com/justfeib/clear-alias.git
cd clear-alias
clear-alias.bat
```

In alternativa, doppio click su `clear-alias.bat` da Esplora file.

Output atteso:

```
[OK] Creato lo shim:
     C:\Users\<utente>\AppData\Local\Microsoft\WindowsApps\clear.cmd

     Contenuto:
       @echo off
       cls

Verifica - dove risolve "clear" in questo momento:
C:\Users\<utente>\AppData\Local\Microsoft\WindowsApps\clear.cmd
  [OK] Trovato. ...
```

Non serve riavviare nulla: la cartella di destinazione era gia' nel PATH,
quindi `clear` funziona anche nei `cmd` gia' aperti.

## Uso

```bat
clear-alias.bat              :: installa (o ripara)
clear-alias.bat /uninstall   :: rimuove
clear-alias.bat /?           :: aiuto
```

Poi, in un qualsiasi `cmd`:

```bat
clear
```

## Verifica

```bat
where clear
```

Deve puntare a `%LOCALAPPDATA%\Microsoft\WindowsApps\clear.cmd`. Se compaiono
piu' righe, in `cmd` vince la **prima**: un eventuale `clear.exe` piu' avanti nel
PATH verrebbe eseguito al posto dello shim (lo script te lo segnala).

## Disinstallazione

```bat
clear-alias.bat /uninstall
```

Oppure cancella a mano `%LOCALAPPDATA%\Microsoft\WindowsApps\clear.cmd`.
Non viene lasciato nient'altro sul sistema: `cls`, PowerShell e Git Bash non
sono stati modificati.

## Come funziona

Lo shim non e' un programma: e' un file di due righe.

```bat
@echo off
cls
```

Viene scritto in `%LOCALAPPDATA%\Microsoft\WindowsApps`, una cartella che Windows
mette gia' nel PATH utente per gli alias delle app dello Store; e' scrivibile
senza elevazione ed e' la destinazione con l'impatto minore. `cmd` risolve i
comandi cercando nel PATH a ogni invocazione, quindi non serve riavviare la
shell.

Lo script e' idempotente: rilanciato, riscrive un file identico e non duplica
niente. Prima di scrivere verifica che la cartella esista e sia scrivibile con un
file di prova temporaneo.

## Note

- **PowerShell 7 (`pwsh`)**: non e' installato su tutte le macchine. Se lo
  installi, ha un profilo separato (`Documents\PowerShell\...`): se `clear` non
  c'e', aggiungi al profilo `Set-Alias -Name clear -Value Clear-Host`.
- **PowerShell 5.1** include gia' l'alias `clear`, quindi non serve alcuna
  configurazione.
- Il file e' in ASCII puro con fine riga CRLF, per non incorrere in problemi di
  codepage o di `\n` in `cmd`.

## Test

Verificati manualmente su Windows 11 (PowerShell 5.1 + cmd.exe):

| Caso | Esito |
| --- | --- |
| Installazione a shim assente | crea il file, exit `0` |
| Installazione a shim presente | riscrive il file, exit `0` |
| `/uninstall` | rimuove il file, exit `0` |
| Argomento sconosciuto | messaggio d'errore, exit `2` |
| `/?` | aiuto, exit `0` |
| Risoluzione con PATH persistente reale | solo lo shim, `clear` exit `0` |

## Licenza

[MIT](LICENSE)
