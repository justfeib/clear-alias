# Changelog

Il formato segue [Keep a Changelog](https://keepachangelog.com/it/1.1.0/) e il
progetto adotta il [versionamento semantico](https://semver.org/lang/it/).

## [1.0.0] - 2026-10-30

### Aggiunto

- Comando `clear` in `cmd.exe` tramite shim `clear.cmd` scritto in
  `%LOCALAPPDATA%\Microsoft\WindowsApps`.
- Installazione idempotente: rilanciare lo script ripara lo shim senza creare
  duplicati.
- Opzione `/uninstall` per rimuovere lo shim e `/?` per l'aiuto.
- Controllo di scrivibilita' della cartella di destinazione prima della
  scrittura, con file di prova temporaneo.
- Verifica finale con `where clear` e segnalazione di eventuali `clear.exe` che
  precedono lo shim nel PATH.
- Rilevamento dello stato di PowerShell: segnala se `clear` e' gia' disponibile,
  altrimenti stampa la riga da aggiungere al profilo senza modificarlo.
