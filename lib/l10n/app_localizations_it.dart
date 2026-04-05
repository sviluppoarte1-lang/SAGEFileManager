// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get appTitle => 'SAGE File Manager';

  @override
  String get menuTooltip => 'Menu';

  @override
  String get menuTopFile => 'File';

  @override
  String get menuTopEdit => 'Modifica';

  @override
  String get menuTopView => 'Visualizza';

  @override
  String get menuTopFavorites => 'Preferiti';

  @override
  String get menuTopThemes => 'Temi';

  @override
  String get menuTopTools => 'Strumenti';

  @override
  String get menuTopHelp => 'Aiuto';

  @override
  String get menuNewTab => 'Apri nuova scheda (F2)';

  @override
  String get menuNewFolder => 'Crea nuova cartella';

  @override
  String get menuNewTextFile => 'Crea nuovo documento di testo';

  @override
  String get menuNetworkDrive => 'Connetti unità di rete';

  @override
  String get menuBulkRename => 'Rinomina file';

  @override
  String get menuEmptyTrash => 'Svuota cestino';

  @override
  String get menuExit => 'Esci';

  @override
  String get menuCut => 'Taglia (CTRL+X)';

  @override
  String get menuCopy => 'Copia (CTRL+C)';

  @override
  String get menuPaste => 'Incolla (CTRL+V)';

  @override
  String get menuUndo => 'Annulla (Ctrl+Z)';

  @override
  String get menuRedo => 'Ripeti (Ctrl+Y)';

  @override
  String get menuRefresh => 'Aggiorna (F5)';

  @override
  String get menuSelectAll => 'Seleziona tutto';

  @override
  String get menuDeselectAll => 'Deseleziona tutto';

  @override
  String get menuFind => 'Trova (F1)';

  @override
  String get menuPreferences => 'Preferenze';

  @override
  String get snackOneFileCut => '1 file tagliato negli appunti';

  @override
  String snackManyFilesCut(int count) {
    return '$count file tagliati negli appunti';
  }

  @override
  String get snackOneFileCopied => '1 file copiato negli appunti';

  @override
  String snackManyFilesCopied(int count) {
    return '$count file copiati negli appunti';
  }

  @override
  String get sortArrangeIcons => 'Disponi icone';

  @override
  String get sortManual => 'Manualmente';

  @override
  String get sortByName => 'Per nome';

  @override
  String get sortBySize => 'Per dimensione';

  @override
  String get sortByType => 'Per tipo';

  @override
  String get sortByDetailedType => 'Per tipo dettagliato';

  @override
  String get sortByDate => 'Per data di modifica';

  @override
  String get sortReverse => 'Ordine inverso';

  @override
  String get viewShowHidden => 'Mostra file nascosti';

  @override
  String get viewHideHidden => 'Nascondi file nascosti';

  @override
  String get viewSplitScreen => 'Dividi schermo (F3)';

  @override
  String get viewShowPreview => 'Mostra anteprima';

  @override
  String get viewHidePreview => 'Nascondi anteprima';

  @override
  String get viewShowRightPanel => 'Mostra barra laterale destra';

  @override
  String get viewHideRightPanel => 'Nascondi barra laterale destra';

  @override
  String get favAdd => 'Aggiungi ai preferiti';

  @override
  String get favManage => 'Gestisci preferiti';

  @override
  String get themesManage => 'Gestione temi';

  @override
  String get toolsPackages => 'Disinstalla/Installa app';

  @override
  String get toolsUpdates => 'Cerca aggiornamenti';

  @override
  String get toolsBulkRenamePattern => 'Rinomina multipla (schema)';

  @override
  String get toolsExtractArchive => 'Estrai archivio';

  @override
  String get helpShortcuts => 'Scorciatoie da tastiera';

  @override
  String get helpUserGuide => 'Guida utente';

  @override
  String get helpUserGuideTitle => 'Guida all\'applicazione';

  @override
  String get helpUserGuideBlock1 =>
      'NAVIGAZIONE\n• Barra laterale: Home, cartelle standard (Desktop, Documenti, …), percorsi aggiunti, preferiti, rete e dischi montati. Trascina le righe per cambiare l\'ordine.\n• Barra strumenti e barra del percorso: cartella superiore, aggiorna e ricerca globale.\n• Backspace torna indietro nella cronologia. Se abilitato nelle Preferenze, doppio clic su area vuota nell\'elenco file porta alla cartella superiore.\n• Doppio clic su una cartella per aprirla; doppio clic su un file per aprirlo con l\'applicazione predefinita.';

  @override
  String get helpUserGuideBlock2 =>
      'FILE E APPUNTI\n• Clic per selezionare; trascina un rettangolo per selezionare più elementi. Ctrl per selezione multipla, Maiusc per intervalli. Esc deseleziona tutto.\n• Ctrl+C, Ctrl+X, Ctrl+V copiano, tagliano e incollano. Puoi trascinare gli elementi selezionati fuori dalla finestra verso il desktop o altre app.\n• Tasto destro per il menu contestuale (rinomina, elimina, proprietà, ecc.). I menu File e Modifica offrono le stesse azioni.';

  @override
  String get helpUserGuideBlock3 =>
      'VISTE E RICERCA\n• Menu Visualizza: elenco, griglia o dettagli; file nascosti; doppio pannello (F3); anteprima e pannello destro (F6).\n• F5 aggiorna la cartella corrente. F2 apre una nuova finestra.\n• Strumenti → Trova (F1) apre la ricerca file: filtri per nome, estensione, dimensione, tipo e data; ricerca sotto un percorso o, se abilitato, su tutti i volumi montati.';

  @override
  String get helpUserGuideBlock4 =>
      'IMPOSTAZIONI E ALTRO\n• Preferiti e Gestione temi nel menu in alto (apre l\'editor completo dei temi). Le Preferenze regolano clic, lingua, menu compatto, doppio pannello e operazioni sui file.\n• Computer elenca i dischi. Aggiungi percorsi di rete dalla barra laterale; per SMB l\'app può suggerire dipendenze da installare.\n• Strumenti: trova file (F1), gestione pacchetti e controllo aggiornamenti quando disponibili.\n• Aiuto → Scorciatoie da tastiera elenca tutte le combinazioni; questa guida riassume le funzioni principali.';

  @override
  String get helpAbout => 'Informazioni';

  @override
  String get helpGitHubProject => 'Progetto su GitHub';

  @override
  String get helpDonateNow => 'DONA ORA';

  @override
  String get helpCheckAppUpdate => 'Cerca aggiornamento app';

  @override
  String appUpdateNewVersionAvailable(Object version) {
    return 'È disponibile la versione $version.';
  }

  @override
  String get appUpdateViewRelease => 'Vedi release';

  @override
  String get appUpdateCheckFailed =>
      'Impossibile verificare gli aggiornamenti (rete o GitHub).';

  @override
  String get appUpdateAlreadyLatest =>
      'Stai usando l\'ultima versione disponibile.';

  @override
  String get navBack => 'Indietro';

  @override
  String get navForward => 'Avanti';

  @override
  String get navUp => 'Sali';

  @override
  String get prefsGeneral => 'Generale';

  @override
  String get prefsSingleClickOpen => 'Singolo clic per aprire';

  @override
  String get prefsSingleClickOpenSubtitle =>
      'Apri file e cartelle con un singolo clic';

  @override
  String get prefsDoubleClickRename => 'Doppio clic per rinominare';

  @override
  String get prefsDoubleClickRenameSubtitle =>
      'Rinomina file e cartelle con doppio clic sul nome';

  @override
  String get prefsDoubleClickEmptyUp =>
      'Doppio clic su area vuota per andare su';

  @override
  String get prefsDoubleClickEmptyUpSubtitle =>
      'Vai alla cartella superiore con doppio clic su spazio vuoto';

  @override
  String get prefsLanguage => 'Lingua';

  @override
  String get prefsLanguageLabel => 'Lingua dell\'interfaccia';

  @override
  String get prefsMenuCompactTitle => 'Menu compatto';

  @override
  String get prefsMenuCompactSubtitle =>
      'Raggruppa le voci di menu dietro l\'icona a tre linee invece della barra classica';

  @override
  String get smbShellLimitedModeGvfsFallback =>
      'Mount CIFS non riuscito: cartelle visibili solo via smbclient. Installa cifs-utils e assicurati di poter eseguire mount.cifs, poi riprova.';

  @override
  String get smbShellFileOpenUnavailable =>
      'Percorso solo smbclient (senza mount CIFS). Monta la condivisione con mount.cifs o disattiva l’opzione se il mount CIFS funziona.';

  @override
  String get prefsExecTextTitle => 'File di testo eseguibili';

  @override
  String get prefsExecAuto => 'Esegui automaticamente';

  @override
  String get prefsExecAlwaysShow => 'Mostra sempre';

  @override
  String get prefsExecAlwaysAsk => 'Chiedi sempre';

  @override
  String get prefsDefaultFmTitle => 'File Manager predefinito';

  @override
  String get prefsDefaultFmBody =>
      'Imposta questo file manager come applicazione predefinita per aprire le cartelle.';

  @override
  String get prefsDefaultFmButton => 'Imposta come File Manager predefinito';

  @override
  String get langItalian => 'Italiano';

  @override
  String get langEnglish => 'Inglese';

  @override
  String get langFrench => 'Francese';

  @override
  String get langSpanish => 'Spagnolo';

  @override
  String get langPortuguese => 'Portoghese';

  @override
  String get langGerman => 'Tedesco';

  @override
  String get fileListTypeFolder => 'Cartella';

  @override
  String get fileListTypeFile => 'File';

  @override
  String get fileListEmpty => 'Nessun file';

  @override
  String get copyProgressTitle => 'Copia in corso';

  @override
  String get copyProgressCancelTooltip => 'Annulla';

  @override
  String copySpeed(String speed) {
    return 'Velocità: $speed';
  }

  @override
  String copyRemaining(String time) {
    return 'Tempo rimanente: $time';
  }

  @override
  String copyProgressDestLine(String name) {
    return '→ $name';
  }

  @override
  String statusItems(int count) {
    return 'Elementi: $count';
  }

  @override
  String statusFree(String size) {
    return 'Libero: $size';
  }

  @override
  String statusUsed(String size) {
    return 'Usato: $size';
  }

  @override
  String statusTotal(String size) {
    return 'Totale: $size';
  }

  @override
  String statusCopyLine(String source, String dest) {
    return 'Copia: $source → $dest';
  }

  @override
  String statusCurrentFile(String name) {
    return 'File: $name';
  }

  @override
  String get dialogCloseWhileCopyTitle => 'Operazione in corso';

  @override
  String get dialogCloseWhileCopyBody =>
      'È in corso una copia o uno spostamento. Chiudere potrebbe interromperla. Continuare?';

  @override
  String get dialogCancel => 'Annulla';

  @override
  String get dialogOverwriteTitle => 'Sostituire l\'elemento esistente?';

  @override
  String dialogOverwriteBody(String name) {
    return '\"$name\" esiste già in questa cartella. Sostituirlo?';
  }

  @override
  String get dialogOverwriteReplace => 'Sostituisci';

  @override
  String get dialogOverwriteSkip => 'Salta';

  @override
  String get dialogCloseAnyway => 'Chiudi comunque';

  @override
  String get commonClose => 'Chiudi';

  @override
  String get commonSave => 'Salva';

  @override
  String get commonDelete => 'Elimina';

  @override
  String get commonRename => 'Rinomina';

  @override
  String get commonAdd => 'Aggiungi';

  @override
  String commonError(String message) {
    return 'Errore: $message';
  }

  @override
  String get errorFolderRequiresOpenAsRoot =>
      'Per entrare in questa cartella attiva la funzione «Apri come root».';

  @override
  String get sidebarAddNetworkTitle => 'Aggiungi percorso di rete';

  @override
  String get sidebarNetworkPathLabel => 'Percorso di rete';

  @override
  String get sidebarNetworkHint =>
      'smb://server/condivisione oppure //server/condivisione';

  @override
  String get sidebarNetworkHelp =>
      'Esempi:\n• smb://192.168.1.100/condiviso\n• //server/condivisione\n• /mnt/rete';

  @override
  String get sidebarBrowseTooltip => 'Sfoglia';

  @override
  String get sidebarRenameShareTitle => 'Rinomina condivisione di rete';

  @override
  String get sidebarRemoveShareTitle => 'Elimina condivisione di rete';

  @override
  String sidebarRemoveShareConfirm(String name) {
    return 'Rimuovere \"$name\" dalla lista?';
  }

  @override
  String get sidebarUnmountTitle => 'Smonta disco';

  @override
  String sidebarUnmountConfirm(String name) {
    return 'Smontare \"$name\"?';
  }

  @override
  String get sidebarUnmount => 'Smonta';

  @override
  String sidebarUnmountOk(String name) {
    return '\"$name\" smontato';
  }

  @override
  String sidebarUnmountFail(String name) {
    return 'Errore smontando \"$name\"';
  }

  @override
  String get sidebarEmptyTrash => 'Svuota cestino';

  @override
  String get sidebarRemoveFromList => 'Rimuovi dalla lista';

  @override
  String get sidebarMenuChangeColor => 'Cambia colore';

  @override
  String sidebarChangeColorDialogTitle(String name) {
    return 'Cambia colore: $name';
  }

  @override
  String get sidebarProperties => 'Proprietà';

  @override
  String sidebarPropertiesFolderTitle(String name) {
    return 'Proprietà: $name';
  }

  @override
  String get sidebarChangeFolderColor => 'Cambia colore cartella:';

  @override
  String get sidebarRemoveCustomColor => 'Rimuovi colore personalizzato';

  @override
  String get sidebarChangeAllFoldersColor => 'Cambia colore cartelle';

  @override
  String get sidebarPickDefaultColor =>
      'Seleziona un colore predefinito per tutte le cartelle:';

  @override
  String get sidebarEmptyTrashTitle => 'Svuota cestino';

  @override
  String get sidebarEmptyTrashBody =>
      'Svuotare definitivamente il cestino? Questa azione non può essere annullata.';

  @override
  String get sidebarEmptyTrashConfirm => 'Svuota';

  @override
  String get sidebarTrashEmptied => 'Cestino svuotato';

  @override
  String sidebarCredentialsTitle(String server) {
    return 'Credenziali per $server';
  }

  @override
  String get sidebarGuestAccess => 'Accesso guest (anonimo)';

  @override
  String get sidebarConnect => 'Connetti';

  @override
  String sidebarConnecting(String name) {
    return 'Connessione a $name...';
  }

  @override
  String sidebarConnectionError(String name) {
    return 'Errore durante la connessione a $name';
  }

  @override
  String get sidebarRetry => 'Riprova';

  @override
  String get copyCancelled => 'Copia interrotta';

  @override
  String get fileCopiedSuccess => 'File copiato';

  @override
  String get folderCopiedSuccess => 'Cartella copiata';

  @override
  String get extractionComplete => 'Estrazione completata';

  @override
  String snackInitError(String error) {
    return 'Errore di inizializzazione: $error';
  }

  @override
  String snackPathRemoved(String name) {
    return 'Rimosso dalla lista: $name';
  }

  @override
  String get labelChoosePath => 'Scegli percorso';

  @override
  String get ctxOpenTerminal => 'Apri il terminale';

  @override
  String get ctxNewFolder => 'Crea nuova cartella';

  @override
  String get ctxOpenAsRoot => 'Apri come root';

  @override
  String get ctxOpenWith => 'Apri con…';

  @override
  String get ctxCopyTo => 'Copia in…';

  @override
  String get ctxMoveTo => 'Sposta in…';

  @override
  String get ctxCopy => 'Copia';

  @override
  String get ctxCut => 'Taglia';

  @override
  String get ctxPaste => 'Incolla';

  @override
  String get ctxCreateNew => 'Crea nuovo';

  @override
  String get ctxNewTextDocumentShort => 'Documento di testo (.txt)';

  @override
  String get ctxNewWordDocument => 'Documento Word (.docx)';

  @override
  String get ctxNewExcelSpreadsheet => 'Foglio Excel (.xlsx)';

  @override
  String get ctxExtract => 'Estrai';

  @override
  String get ctxExtractTo => 'Estrai archivio in…';

  @override
  String get ctxCompressToZip => 'Comprimi in file .zip';

  @override
  String snackZipCreated(Object name) {
    return 'Archivio creato: \"$name\".';
  }

  @override
  String snackZipFailed(Object message) {
    return 'Impossibile creare lo ZIP: $message';
  }

  @override
  String get ctxChangeColor => 'Cambia colore';

  @override
  String get ctxMoveToTrash => 'Sposta nel cestino';

  @override
  String get ctxRestoreFromTrash => 'Ripristina nella cartella originale';

  @override
  String get menuRestoreFromTrash => 'Ripristina dal cestino';

  @override
  String get trashRestorePickFolderTitle =>
      'Scegli la cartella in cui ripristinare';

  @override
  String trashRestoreTargetExists(String name) {
    return 'Impossibile ripristinare: \"$name\" esiste già nella destinazione.';
  }

  @override
  String trashRestoredCount(int count) {
    return '$count elementi ripristinati';
  }

  @override
  String get trashRestoreFailed =>
      'Impossibile ripristinare gli elementi selezionati.';

  @override
  String dialogOpenWithTitle(String name) {
    return 'Apri \"$name\" con…';
  }

  @override
  String get hintSearchApp => 'Cerca applicazione…';

  @override
  String get openWithDefaultApp => 'Applicazione predefinita';

  @override
  String get browseEllipsis => 'Sfoglia…';

  @override
  String get tooltipSetAsDefaultApp => 'Imposta come applicazione predefinita';

  @override
  String get openWithOpenAndSetDefault => 'Apri e imposta come predefinita';

  @override
  String get openWithFooterHint =>
      'Usa la stella o il menu ⋮ per modificare l\'applicazione predefinita per questo tipo di file quando vuoi.';

  @override
  String snackDefaultAppSet(String appName, String mimeType) {
    return '$appName impostata come predefinita per $mimeType';
  }

  @override
  String snackSetDefaultAppError(String error) {
    return 'Impossibile impostare il predefinito: $error';
  }

  @override
  String snackOpenFileError(String error) {
    return 'Impossibile aprire: $error';
  }

  @override
  String get dialogTitleCreateFolder => 'Crea nuova cartella';

  @override
  String get dialogTitleNewFolder => 'Nuova cartella';

  @override
  String get labelFolderName => 'Nome cartella';

  @override
  String get hintFolderName => 'Inserisci il nome della cartella';

  @override
  String get labelFileName => 'Nome file';

  @override
  String get hintTextDocument => 'documento.txt';

  @override
  String get buttonCreate => 'Crea';

  @override
  String snackMoveError(String error) {
    return 'Errore durante lo spostamento: $error';
  }

  @override
  String dialogChangeColorFor(String name) {
    return 'Cambia colore: $name';
  }

  @override
  String get dialogPickFolderColor => 'Seleziona un colore per la cartella:';

  @override
  String get shortcutTitle => 'Scorciatoie da tastiera';

  @override
  String get shortcutCopy => 'Copia file/cartelle selezionati';

  @override
  String get shortcutPaste => 'Incolla file/cartelle';

  @override
  String get shortcutCut => 'Taglia file/cartelle selezionati';

  @override
  String get shortcutUndo => 'Annulla ultima operazione';

  @override
  String get shortcutRedo => 'Ripeti ultima operazione';

  @override
  String get shortcutNewTab => 'Apri nuova scheda';

  @override
  String get shortcutSplitView => 'Dividi schermo in due';

  @override
  String get shortcutRefresh => 'Aggiorna directory corrente';

  @override
  String get shortcutRightPanel => 'Mostra/Nascondi barra laterale destra';

  @override
  String get shortcutDeselect => 'Deseleziona tutti i file';

  @override
  String get shortcutBackNav => 'Torna indietro nella navigazione';

  @override
  String get shortcutFindFiles => 'Trova file e cartelle';

  @override
  String get aboutTitle => 'Informazioni';

  @override
  String get aboutAppName => 'File Manager';

  @override
  String get aboutTagline => 'File manager avanzato';

  @override
  String aboutVersionLabel(String version) {
    return 'Versione: $version';
  }

  @override
  String get aboutAuthor => 'Autore: Marco Di Giangiacomo';

  @override
  String get aboutYear => '© 2026';

  @override
  String get aboutDescriptionHeading => 'Descrizione:';

  @override
  String get aboutDescription =>
      'SAGE File Manager: file manager moderno per Linux con viste multiple, anteprime, temi, ricerca, copia ottimizzata, vista divisa, SMB/LAN e altro.';

  @override
  String get aboutFeaturesHeading => 'Caratteristiche principali:';

  @override
  String get aboutFeaturesList =>
      '• Gestione completa di file e cartelle\n• Viste multiple (lista, griglia, dettagli)\n• Anteprima file (immagini, PDF, documenti, testo)\n• Gestione temi (predefiniti e personalizzazione)\n• Ricerca avanzata\n• Copia/incolla ottimizzata\n• Split view\n• Preferiti e percorsi personalizzati\n• Supporto eseguibili e script\n• Interfaccia moderna';

  @override
  String snackDocumentCreated(String name) {
    return 'Documento \"$name\" creato';
  }

  @override
  String get dialogInsufficientPermissions => 'Permessi insufficienti';

  @override
  String get snackFolderCreated => 'Cartella creata';

  @override
  String get snackTerminalUnavailable => 'Terminale non disponibile';

  @override
  String get snackTerminalRootError =>
      'Impossibile aprire il terminale come root';

  @override
  String get snackRootHelperMissing =>
      'Impossibile aprire come root. Installa pkexec o sudo.';

  @override
  String get snackOpenAsRootNoFolder =>
      'Apri prima una cartella, poi scegli Apri come root.';

  @override
  String get snackOpenAsRootBadFolder => 'Impossibile aprire quella cartella.';

  @override
  String snackPasteItemError(String name, String error) {
    return 'Errore incollando $name: $error';
  }

  @override
  String get snackFileMoved => 'File spostato';

  @override
  String get dialogRenameFileTitle => 'Rinomina';

  @override
  String dialogRenameManySubtitle(int count) {
    return '$count elementi selezionati. Imposta un nuovo nome per ciascuna riga.';
  }

  @override
  String get labelNewName => 'Nuovo nome';

  @override
  String get snackFileRenamed => 'File rinominato';

  @override
  String snackRenameError(String error) {
    return 'Errore durante la rinomina: $error';
  }

  @override
  String get snackRenameSameFolder =>
      'Tutti gli elementi devono essere nella stessa cartella.';

  @override
  String get snackRenameEmptyName =>
      'Ogni elemento deve avere un nome nuovo non vuoto.';

  @override
  String get snackRenameDuplicateNames =>
      'I nuovi nomi devono essere tutti diversi tra loro.';

  @override
  String get snackRenameTargetExists =>
      'Esiste già un file o una cartella con questo nome.';

  @override
  String get snackSelectPathFirst => 'Seleziona prima un percorso';

  @override
  String get snackAlreadyFavorite => 'Percorso già nei preferiti';

  @override
  String snackAddedFavorite(String name) {
    return 'Aggiunto ai preferiti: $name';
  }

  @override
  String get favoritesEmptyList => 'Nessun preferito aggiunto';

  @override
  String snackNewTabOpened(String name) {
    return 'Nuova scheda aperta: $name';
  }

  @override
  String get snackSelectForSymlink =>
      'Seleziona un file o cartella per creare un collegamento';

  @override
  String get dialogCreateSymlinkTitle => 'Crea collegamento';

  @override
  String get labelSymlinkName => 'Nome collegamento';

  @override
  String get snackSymlinkCreated => 'Collegamento creato';

  @override
  String get snackConnectingNetwork => 'Connessione alla rete in corso…';

  @override
  String get snackNewInstanceStarted => 'Nuova istanza dell\'app avviata';

  @override
  String snackNewInstanceError(String error) {
    return 'Errore nell\'avvio della nuova istanza: $error';
  }

  @override
  String get snackSelectFilesRename => 'Seleziona almeno un file da rinominare';

  @override
  String get bulkRenameTitle => 'Rinomina file in massa';

  @override
  String bulkRenameSelectedCount(int count) {
    return '$count file selezionati';
  }

  @override
  String get bulkRenamePatternLabel => 'Pattern di rinomina';

  @override
  String get bulkRenamePatternHelper =>
      'Usa i segnaposto name e num racchiusi tra parentesi graffe (vedi esempio sotto).';

  @override
  String get bulkRenameAutoNumber => 'Usa numerazione automatica';

  @override
  String get bulkRenameStartNumber => 'Numero iniziale';

  @override
  String get bulkRenameKeepExt => 'Mantieni estensione originale';

  @override
  String trashEmptyError(String error) {
    return 'Errore nello svuotamento del cestino: $error';
  }

  @override
  String labelNItems(int count) {
    return '$count elementi';
  }

  @override
  String get dialogTitleDeletePermanent => 'Eliminare permanentemente?';

  @override
  String get dialogTitleMoveToTrashConfirm => 'Spostare nel cestino?';

  @override
  String get dialogBodyPermanentDeleteOne =>
      'Eliminare permanentemente un elemento?';

  @override
  String dialogBodyPermanentDeleteMany(int count) {
    return 'Eliminare permanentemente $count elementi?';
  }

  @override
  String get dialogBodyTrashOne => 'Spostare un elemento nel cestino?';

  @override
  String dialogBodyTrashMany(int count) {
    return 'Spostare $count elementi nel cestino?';
  }

  @override
  String get snackDeletedPermanentOne =>
      'Un elemento eliminato definitivamente';

  @override
  String snackDeletedPermanentMany(int count) {
    return '$count elementi eliminati definitivamente';
  }

  @override
  String get snackMovedToTrashOne => 'Un elemento spostato nel cestino';

  @override
  String snackMovedToTrashMany(int count) {
    return '$count elementi spostati nel cestino';
  }

  @override
  String snackDeleteErrorsSuffix(int errors) {
    return ', $errors errori';
  }

  @override
  String get dialogOpenAsRootBody =>
      'Non hai i permessi per creare file o cartelle in questa cartella. Aprire il file manager come root?';

  @override
  String get dialogOpenAsRootAuthTitle => 'Apri come amministratore';

  @override
  String get dialogOpenAsRootAuthBody =>
      'Dopo Continua il sistema chiederà la password di amministratore. Solo dopo un accesso riuscito verrà avviata una nuova finestra del file manager in questa cartella.';

  @override
  String get dialogOpenAsRootContinue => 'Continua';

  @override
  String get paneSelectPathHint => 'Seleziona un percorso';

  @override
  String get emptyFolderLabel => 'Cartella vuota';

  @override
  String get sidebarMountPointOptional => 'Punto di mount (opzionale)';

  @override
  String snackBulkRenameManyDone(int count) {
    return '$count file rinominati';
  }

  @override
  String get commonOk => 'OK';

  @override
  String get prefsPageTitle => 'Preferenze';

  @override
  String get snackPrefsSaved => 'Preferenze salvate';

  @override
  String get prefsNavView => 'Visualizzazione';

  @override
  String get prefsNavPreview => 'Anteprima';

  @override
  String get prefsNavFileOps => 'Operazioni file';

  @override
  String get prefsNavTrash => 'Cestino';

  @override
  String get prefsNavMedia => 'Supporti rimovibili';

  @override
  String get prefsNavCache => 'Cache';

  @override
  String get prefsDefaultFmSuccess =>
      'File manager impostato come predefinito.';

  @override
  String get prefsShowHiddenTitle => 'Mostra file nascosti';

  @override
  String get prefsShowHiddenSubtitle =>
      'Mostra file e cartelle il cui nome inizia con un punto';

  @override
  String get prefsShowPreviewPanelTitle => 'Mostra pannello anteprima';

  @override
  String get prefsShowPreviewPanelSubtitle =>
      'Mostra il pannello di anteprima a destra';

  @override
  String get prefsAlwaysDoublePaneTitle =>
      'Inizia sempre con vista a doppio riquadro';

  @override
  String get prefsAlwaysDoublePaneSubtitle =>
      'Apri sempre la vista divisa all’avvio';

  @override
  String get prefsIgnoreViewPerFolderTitle =>
      'Ignora preferenze vista per cartella';

  @override
  String get prefsIgnoreViewPerFolderSubtitle =>
      'Non salvare le preferenze di visualizzazione per ogni cartella';

  @override
  String get prefsDefaultViewModeTitle =>
      'Modalità visualizzazione predefinita';

  @override
  String get prefsViewModeList => 'Lista';

  @override
  String get prefsViewModeGrid => 'Griglia';

  @override
  String get prefsViewModeDetails => 'Dettagli';

  @override
  String get prefsGridZoomTitle => 'Livello zoom griglia predefinito';

  @override
  String prefsGridZoomLevel(int current) {
    return 'Livello: $current/10';
  }

  @override
  String get prefsFontSection => 'Font';

  @override
  String get prefsFontFamilyLabel => 'Famiglia font';

  @override
  String get labelSelectFont => 'Seleziona font';

  @override
  String get fontFamilyDefaultSystem => 'Predefinito (sistema)';

  @override
  String get prefsFontSizeTitle => 'Dimensione font';

  @override
  String prefsFontSizeValue(String size) {
    return 'Dimensione: $size';
  }

  @override
  String get prefsFontWeightTitle => 'Peso font';

  @override
  String get prefsFontWeightNormal => 'Normale';

  @override
  String get prefsFontWeightBold => 'Grassetto';

  @override
  String get prefsFontWeightSemiBold => 'Semi-grassetto';

  @override
  String get prefsFontWeightMedium => 'Medio';

  @override
  String get prefsTextShadowSection => 'Ombreggiatura testo';

  @override
  String get prefsTextShadowEnableTitle => 'Abilita ombreggiatura';

  @override
  String get prefsTextShadowEnableSubtitle =>
      'Aggiunge un’ombra al testo per migliorare la leggibilità';

  @override
  String get prefsShadowIntensityTitle => 'Intensità ombra';

  @override
  String get prefsShadowOffsetXTitle => 'Offset ombra X';

  @override
  String get prefsShadowOffsetYTitle => 'Offset ombra Y';

  @override
  String get prefsShadowColorTitle => 'Colore ombra';

  @override
  String prefsShadowColorValue(String value) {
    return 'Colore: $value';
  }

  @override
  String get prefsShadowColorBlack => 'Nero';

  @override
  String get dialogPickShadowColor => 'Seleziona colore ombra';

  @override
  String get prefsPickColor => 'Scegli colore';

  @override
  String get prefsTextPreviewLabel => 'Anteprima testo';

  @override
  String get prefsDisableFileQueueTitle => 'Disattiva coda operazioni file';

  @override
  String get prefsDisableFileQueueSubtitle =>
      'Esegui operazioni in sequenza senza coda';

  @override
  String get prefsAskTrashTitle => 'Chiedi prima di spostare nel cestino';

  @override
  String get prefsAskTrashSubtitle =>
      'Richiedi conferma prima di spostare file nel cestino';

  @override
  String get prefsAskEmptyTrashTitle => 'Chiedi prima di svuotare il cestino';

  @override
  String get prefsAskEmptyTrashSubtitle =>
      'Richiedi conferma prima di eliminare definitivamente';

  @override
  String get prefsIncludeDeleteTitle => 'Includi comando Elimina';

  @override
  String get prefsIncludeDeleteSubtitle =>
      'Mostra opzione per eliminare senza cestino';

  @override
  String get prefsSkipTrashDelKeyTitle => 'Salta cestino con tasto Canc';

  @override
  String get prefsSkipTrashDelKeySubtitle =>
      'Elimina direttamente i file quando premi Canc';

  @override
  String get prefsAutoMountTitle =>
      'Monta automaticamente dispositivi rimovibili';

  @override
  String get prefsAutoMountSubtitle =>
      'Monta USB e altri dispositivi quando collegati';

  @override
  String get prefsOpenWindowMountedTitle =>
      'Apri finestra per dispositivi montati';

  @override
  String get prefsOpenWindowMountedSubtitle =>
      'Apri automaticamente una finestra per i dispositivi montati';

  @override
  String get prefsWarnRemovableTitle =>
      'Avvisa quando si collega un dispositivo';

  @override
  String get prefsWarnRemovableSubtitle =>
      'Mostra notifica quando viene collegato un dispositivo rimovibile';

  @override
  String get prefsPreviewExtensionsIntro =>
      'Seleziona le estensioni per cui abilitare l’anteprima:';

  @override
  String get prefsPreviewRightPanelNote =>
      'Le anteprime complete per PDF, Office, testo e altri tipi sono disponibili nel pannello laterale destro quando è attivo. Se la barra laterale è nascosta, nella lista file compaiono solo le anteprime delle immagini.';

  @override
  String get prefsAdminPasswordSection => 'Password amministratore';

  @override
  String get prefsSaveAdminPasswordTitle => 'Salva password amministratore';

  @override
  String get prefsSaveAdminPasswordSubtitle =>
      'Salva la password per gli aggiornamenti (non consigliato)';

  @override
  String get labelAdminPassword => 'Password amministratore';

  @override
  String get hintAdminPassword => 'Inserisci la password';

  @override
  String get prefsCacheSectionTitle => 'Cache e anteprime';

  @override
  String get prefsCacheSizeTitle => 'Dimensione cache';

  @override
  String prefsCacheSizeCurrent(String size) {
    return 'Dimensione attuale: $size';
  }

  @override
  String get labelNetworkShareName => 'Nome personalizzato';

  @override
  String get hintNetworkShareName =>
      'Inserisci un nome per questa condivisione';

  @override
  String get sidebarTooltipRemoveNetwork => 'Rimuovi percorso di rete';

  @override
  String get sidebarTooltipUnmount => 'Smonta disco';

  @override
  String sidebarUnmountSuccess(String name) {
    return '\"$name\" smontato con successo';
  }

  @override
  String sidebarUnmountError(String name) {
    return 'Errore durante lo smontaggio di \"$name\"';
  }

  @override
  String get previewSelectFile => 'Seleziona un file per l’anteprima';

  @override
  String get previewPanelTitle => 'Anteprima';

  @override
  String previewPanelSizeLine(String value) {
    return 'Dimensione: $value';
  }

  @override
  String previewPanelModifiedLine(String value) {
    return 'Modificato: $value';
  }

  @override
  String get dialogErrorTitle => 'Errore';

  @override
  String get propsLoadError => 'Impossibile caricare le proprietà del file';

  @override
  String get snackPermissionsUpdated => 'Permessi modificati con successo';

  @override
  String dialogEditFieldTitle(String label) {
    return 'Modifica $label';
  }

  @override
  String snackFieldUpdated(String label) {
    return '$label modificato con successo';
  }

  @override
  String get propsEditPermissionsTitle => 'Modifica permessi';

  @override
  String get permOwner => 'Proprietario:';

  @override
  String get permGroup => 'Gruppo:';

  @override
  String get permOthers => 'Altri:';

  @override
  String get permRead => 'Lettura';

  @override
  String get permWrite => 'Scrittura';

  @override
  String get permExecute => 'Eseguibile';

  @override
  String get previewNotAvailable => 'Anteprima non disponibile';

  @override
  String get previewImageError => 'Errore nel caricamento dell’immagine';

  @override
  String get previewDocLoadError => 'Errore nel caricamento del documento';

  @override
  String get previewOpenExternally => 'Apri con visualizzatore esterno';

  @override
  String get previewDocumentTitle => 'Anteprima documento';

  @override
  String get previewDocLegacyFormat =>
      'Il formato .doc non è supportato. Usa .docx o apri con un visualizzatore esterno.';

  @override
  String get previewSheetLoadError =>
      'Errore nel caricamento del foglio di calcolo';

  @override
  String get previewSheetTitle => 'Anteprima foglio di calcolo';

  @override
  String get previewXlsLegacyFormat =>
      'Il formato .xls non è supportato. Usa .xlsx o apri con un visualizzatore esterno.';

  @override
  String get previewPresentationLoadError =>
      'Errore nel caricamento della presentazione';

  @override
  String get previewOpenOfficeTitle => 'Anteprima OpenOffice';

  @override
  String get previewOpenOfficeBody =>
      'I file OpenOffice richiedono un visualizzatore esterno.';

  @override
  String themeApplied(String name) {
    return 'Tema \"$name\" applicato';
  }

  @override
  String get themeDark => 'Tema scuro';

  @override
  String themeFontSizeTitle(String size) {
    return 'Dimensione font: $size';
  }

  @override
  String get themeFontWeightSection => 'Peso font';

  @override
  String get themeBoldLabel => 'Grassetto';

  @override
  String get themeTextShadowSection => 'Ombreggiatura testo';

  @override
  String themeShadowIntensity(String percent) {
    return 'Intensità ombreggiatura: $percent%';
  }

  @override
  String get themeColorPicked => 'Colore selezionato';

  @override
  String get themeSelectToCustomize => 'Seleziona un tema per personalizzarlo';

  @override
  String get themeFontFamilySection => 'Famiglia font';

  @override
  String get searchNeedCriterion => 'Inserisci almeno un criterio di ricerca';

  @override
  String get searchCurrentPath => 'Percorso corrente';

  @override
  String get searchButton => 'Cerca';

  @override
  String get pkgConfirmUninstallTitle => 'Conferma disinstallazione';

  @override
  String pkgConfirmUninstallBody(String name) {
    return 'Disinstallare $name?';
  }

  @override
  String get pkgDependenciesTitle => 'Dipendenze trovate';

  @override
  String get pkgUninstallError => 'Errore durante la disinstallazione';

  @override
  String get pkgManagerTitle => 'Gestione applicazioni';

  @override
  String get pkgInstallTitle => 'Installa pacchetto';

  @override
  String pkgInstallBody(String name) {
    return 'Installare \"$name\"?';
  }

  @override
  String pkgMadeExecutable(String name) {
    return '$name reso eseguibile';
  }

  @override
  String get pkgUnsupportedFormat => 'Formato pacchetto non supportato';

  @override
  String pkgInstallErrorOutput(String output) {
    return 'Errore durante l’installazione: $output';
  }

  @override
  String updateItemSuccess(String name) {
    return '$name aggiornato con successo';
  }

  @override
  String updateItemError(String name) {
    return 'Errore durante l’aggiornamento di $name';
  }

  @override
  String get updateAllError =>
      'Errore durante l’installazione degli aggiornamenti';

  @override
  String get updateInstallAllButton => 'Installa tutti';

  @override
  String get previewCatImages => 'Immagini';

  @override
  String get previewCatDocuments => 'Documenti';

  @override
  String get previewCatText => 'Testo';

  @override
  String get previewCatWeb => 'Web';

  @override
  String get previewCatOffice => 'Office';

  @override
  String previewExtTitle(String ext, String name) {
    return '.$ext — $name';
  }

  @override
  String bulkRenamePatternExample(String a, String b) {
    return '$a, ${a}_$b, Documento_$b';
  }

  @override
  String get tableColumnName => 'Nome';

  @override
  String get tableColumnPath => 'Percorso';

  @override
  String get tableColumnSize => 'Dimensione';

  @override
  String get tableColumnModified => 'Modificato';

  @override
  String get tableColumnType => 'Tipo';

  @override
  String get networkBrowserTitle => 'Esplora rete';

  @override
  String get networkSearchingServers => 'Ricerca server di rete…';

  @override
  String get networkNoServersFound => 'Nessun server di rete trovato';

  @override
  String get networkServersSharesHeader => 'Server e condivisioni';

  @override
  String get labelUsername => 'Nome utente';

  @override
  String get labelPassword => 'Password';

  @override
  String get networkRefreshTooltip => 'Aggiorna';

  @override
  String get networkNoSharesAvailable => 'Nessuna condivisione disponibile';

  @override
  String get networkInfoTitle => 'Informazioni';

  @override
  String networkServersFoundCount(int count) {
    return 'Server trovati: $count';
  }

  @override
  String get networkConnectShareInstructions =>
      'Per connetterti a una condivisione, espandi un server e clicca sulla condivisione desiderata.';

  @override
  String get networkSelectedServerLabel => 'Server selezionato:';

  @override
  String networkSharesCount(int count) {
    return 'Condivisioni: $count';
  }

  @override
  String get sidebarTooltipBrowseNetworkPaths => 'Sfoglia percorsi di rete';

  @override
  String get sidebarTooltipAddNetworkPath => 'Aggiungi percorso di rete';

  @override
  String get sidebarSectionNetwork => 'Rete';

  @override
  String get sidebarSectionDisks => 'Dischi';

  @override
  String get sidebarAddPath => 'Aggiungi percorso';

  @override
  String get sidebarUserFolderHome => 'Home';

  @override
  String get sidebarUserFolderDesktop => 'Desktop';

  @override
  String get sidebarUserFolderDocuments => 'Documenti';

  @override
  String get sidebarUserFolderPictures => 'Immagini';

  @override
  String get sidebarUserFolderMusic => 'Musica';

  @override
  String get sidebarUserFolderVideos => 'Video';

  @override
  String get sidebarUserFolderDownloads => 'Scaricati';

  @override
  String get sidebarSectionFavorites => 'Preferiti';

  @override
  String get commonUnknown => 'Sconosciuto';

  @override
  String get prefsClearCacheButton => 'Svuota cache';

  @override
  String get prefsClearCacheTitle => 'Svuota cache';

  @override
  String get prefsClearCacheBody => 'Vuoi svuotare la cache delle anteprime?';

  @override
  String get prefsClearCacheConfirm => 'Svuota';

  @override
  String get snackPrefsCacheCleared => 'Cache svuotata';

  @override
  String get previewFmtJpeg => 'Immagine JPEG';

  @override
  String get previewFmtPng => 'Immagine PNG';

  @override
  String get previewFmtGif => 'Immagine GIF';

  @override
  String get previewFmtBmp => 'Immagine BMP';

  @override
  String get previewFmtWebp => 'Immagine WebP';

  @override
  String get previewFmtPdf => 'Documento PDF';

  @override
  String get previewFmtPlainText => 'File di testo';

  @override
  String get previewFmtMarkdown => 'Markdown';

  @override
  String get previewFmtNfo => 'File info';

  @override
  String get previewFmtShell => 'Script shell';

  @override
  String get previewFmtHtml => 'Documento HTML';

  @override
  String get previewFmtDocx => 'Documento Word';

  @override
  String get previewFmtXlsx => 'Foglio Excel';

  @override
  String get previewFmtPptx => 'Presentazione PowerPoint';

  @override
  String themeAppliedSnackbar(String name) {
    return 'Tema \"$name\" applicato';
  }

  @override
  String get themeEditTitle => 'Modifica tema';

  @override
  String get themeNewTitle => 'Nuovo tema';

  @override
  String get themeFieldName => 'Nome tema';

  @override
  String get themeDarkThemeSwitch => 'Tema scuro';

  @override
  String get themeColorPrimary => 'Colore primario';

  @override
  String get themeColorSecondary => 'Colore secondario';

  @override
  String get themeColorFile => 'Colore file';

  @override
  String get themeColorLocation => 'Colore barra percorso';

  @override
  String get themeColorBackground => 'Colore sfondo';

  @override
  String get themeColorFolder => 'Colore cartelle';

  @override
  String get themeFolderIconsHint =>
      'Le icone vengono applicate automaticamente in base al tipo di cartella.';

  @override
  String get themeFolderIconPickColor =>
      'Seleziona un colore per le icone delle cartelle';

  @override
  String get themeColorPickedSnack => 'Colore selezionato';

  @override
  String get themeManagerTitle => 'Gestione temi';

  @override
  String get themeBuiltinHeader => 'Temi predefiniti';

  @override
  String get themeCustomHeader => 'Temi personalizzati';

  @override
  String get themeCustomizationHeader => 'Personalizzazione';

  @override
  String get themeSelectPrompt => 'Seleziona un tema per personalizzarlo';

  @override
  String get themeVariantLight => 'Chiaro';

  @override
  String get themeVariantDark => 'Scuro';

  @override
  String get themeColorsHeader => 'Colori';

  @override
  String get themeFontHeader => 'Font';

  @override
  String get themeFontFamilyRow => 'Famiglia font';

  @override
  String themeFontSizeRow(String size) {
    return 'Dimensione font: $size';
  }

  @override
  String get themeFontWeightHeader => 'Peso font';

  @override
  String get themeTextShadow => 'Ombreggiatura testo';

  @override
  String get themeIconShadowTitle => 'Ombra icone (griglia)';

  @override
  String get themeIconShadowSubtitle =>
      'Ombreggiatura sotto icone file e cartelle in vista griglia';

  @override
  String themeIconShadowIntensity(String percent) {
    return 'Intensità ombra icone: $percent%';
  }

  @override
  String themeShadowIntensityRow(String percent) {
    return 'Intensità ombreggiatura: $percent%';
  }

  @override
  String get themeFolderIconFolder => 'Cartella';

  @override
  String get themeFolderIconFolderOpen => 'Cartella aperta';

  @override
  String get themeFolderIconFolderSpecial => 'Cartella speciale';

  @override
  String get themeFolderIconFolderShared => 'Cartella condivisa';

  @override
  String get themeFolderIconFolderCopy => 'Copia cartella';

  @override
  String get themeFolderIconFolderDelete => 'Elimina cartella';

  @override
  String get themeFolderIconFolderZip => 'Cartella zip';

  @override
  String get themeFolderIconFolderOff => 'Cartella off';

  @override
  String get themeFolderIconFolderPlus => 'Nuova cartella';

  @override
  String get themeFolderIconFolderHome => 'Home';

  @override
  String get themeFolderIconFolderDrive => 'Unità';

  @override
  String get themeFolderIconFolderCloud => 'Cloud';

  @override
  String get propsTitle => 'Proprietà';

  @override
  String get propsTimeoutLoading => 'Timeout nel caricamento delle proprietà';

  @override
  String propsLoadErrorDetail(String detail) {
    return 'Errore nel caricamento delle proprietà: $detail';
  }

  @override
  String get propsFieldName => 'Nome';

  @override
  String get propsFieldPath => 'Percorso';

  @override
  String get propsFieldType => 'Tipo';

  @override
  String get propsFieldSize => 'Dimensione';

  @override
  String get propsFieldSizeOnDisk => 'Dimensione su disco';

  @override
  String get propsFieldModified => 'Modificato';

  @override
  String get propsFieldAccessed => 'Accesso';

  @override
  String get propsFieldCreated => 'Creato';

  @override
  String get propsFieldOwner => 'Proprietario';

  @override
  String get propsFieldGroup => 'Gruppo';

  @override
  String get propsFieldPermissions => 'Permessi';

  @override
  String get propsFieldInode => 'Inode';

  @override
  String get propsFieldLinks => 'Link';

  @override
  String get propsFieldFilesInside => 'File contenuti';

  @override
  String get propsFieldDirsInside => 'Cartelle contenute';

  @override
  String get propsTypeFolder => 'Cartella';

  @override
  String get propsTypeFile => 'File';

  @override
  String propsMultiSelectionTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count elementi selezionati',
      one: '1 elemento selezionato',
    );
    return '$_temp0';
  }

  @override
  String get propsMultiTypeMixed => 'Selezione mista (file e cartelle)';

  @override
  String get propsMultiCombinedSize => 'Dimensione totale su disco';

  @override
  String get propsMultiLoadingSizes => 'Calcolo dimensioni…';

  @override
  String get propsMultiPerItemTitle => 'Ogni elemento';

  @override
  String propsMultiCountSummary(int folderCount, int fileCount) {
    return '$folderCount cartelle, $fileCount file';
  }

  @override
  String get propsEditTooltip => 'Modifica';

  @override
  String get propsHintNewValue => 'Inserisci nuovo valore';

  @override
  String get propsPermissionsDialogTitle => 'Modifica permessi';

  @override
  String get propsPermOwnerSection => 'Proprietario:';

  @override
  String get propsPermGroupSection => 'Gruppo:';

  @override
  String get propsPermOtherSection => 'Altri:';

  @override
  String get propsInvalidPermissionsFormat => 'Formato permessi non valido';

  @override
  String propsChmodFailed(String detail) {
    return 'Impossibile modificare i permessi: $detail';
  }

  @override
  String get pkgPageTitle => 'Gestione applicazioni';

  @override
  String get pkgInstallFromFileTooltip => 'Installa pacchetto da file';

  @override
  String get pkgFilterAll => 'Tutte';

  @override
  String get pkgSearchHint => 'Cerca applicazioni…';

  @override
  String get pkgUninstallTitle => 'Conferma disinstallazione';

  @override
  String pkgUninstallConfirm(String name) {
    return 'Vuoi disinstallare $name?';
  }

  @override
  String get pkgUninstallButton => 'Disinstalla';

  @override
  String get pkgDepsTitle => 'Dipendenze trovate';

  @override
  String pkgDepsUsedByBody(String list) {
    return 'Questo pacchetto è utilizzato da:\n$list';
  }

  @override
  String get pkgProceedAnyway => 'Procedi comunque';

  @override
  String pkgUninstalled(Object name) {
    return '$name disinstallato';
  }

  @override
  String get pkgUninstallFailed => 'Errore durante la disinstallazione';

  @override
  String get pkgInstallDialogTitle => 'Installa pacchetto';

  @override
  String pkgInstallConfirm(String name) {
    return 'Vuoi installare \"$name\"?';
  }

  @override
  String get pkgInstallButton => 'Installa';

  @override
  String get pkgInstallProgressTitle => 'Installazione pacchetto';

  @override
  String get pkgInstallRunningStatus => 'Avvio installer…';

  @override
  String get zipProgressPanelTitle => 'Compressione ZIP';

  @override
  String get zipProgressSubtitle => 'Aggiunta file all\'archivio';

  @override
  String get zipProgressEncoding => 'Scrittura archivio…';

  @override
  String pkgExecutableMade(String name) {
    return '$name reso eseguibile';
  }

  @override
  String get pkgUnsupportedPackage => 'Formato pacchetto non supportato';

  @override
  String pkgInstalledSuccess(String name) {
    return '$name installato con successo';
  }

  @override
  String pkgInstallFailedWithError(String detail) {
    return 'Errore durante l\'installazione: $detail';
  }

  @override
  String get updateTitle => 'Aggiornamenti';

  @override
  String updateTitleWithCount(int count) {
    return 'Aggiornamenti ($count)';
  }

  @override
  String get updateInstallAll => 'Installa tutti';

  @override
  String get updateNoneAvailable => 'Nessun aggiornamento disponibile';

  @override
  String updateTypeLine(String type) {
    return 'Tipo: $type';
  }

  @override
  String updateCurrentVersionLine(String v) {
    return 'Versione corrente: $v';
  }

  @override
  String updateAvailableVersionLine(String v) {
    return 'Versione disponibile: $v';
  }

  @override
  String get updateInstallTooltip => 'Installa aggiornamento';

  @override
  String updateUpdatedSuccess(String name) {
    return '$name aggiornato con successo';
  }

  @override
  String updateOneFailed(String name) {
    return 'Errore durante l\'aggiornamento di $name';
  }

  @override
  String get updateInstallAllTitle => 'Installa tutti gli aggiornamenti';

  @override
  String updateInstallAllBody(int count) {
    return 'Vuoi installare $count aggiornamenti?';
  }

  @override
  String get updateAllSuccess =>
      'Tutti gli aggiornamenti installati con successo';

  @override
  String get updateAllFailed =>
      'Errore durante l\'installazione degli aggiornamenti';

  @override
  String get searchDialogTitle => 'Trova file';

  @override
  String searchPathLabel(String path) {
    return 'Percorso: $path';
  }

  @override
  String get searchSelectDiskTooltip => 'Seleziona disco';

  @override
  String get searchAllMountsLabel => 'Cerca su tutti i volumi montati';

  @override
  String get searchAllMountsHint =>
      'Chiavette USB, partizioni aggiuntive, GVFS/rete (se accessibili). Più lento di una singola cartella.';

  @override
  String searchAllMountsActive(int count) {
    return 'Ricerca in $count percorsi (tutti i mount)';
  }

  @override
  String get searchPathCurrentMenu => 'Percorso corrente';

  @override
  String get searchPathRootMenu => 'Radice filesystem';

  @override
  String get searchLabelQuery => 'Cerca';

  @override
  String get searchHintQuery => 'Nome file, *.mp4, *.txt…';

  @override
  String get searchHelperPatterns =>
      'Supporta pattern: *.mp4, *.txt, document*.pdf';

  @override
  String get searchLabelNameFilter => 'Filtro nome';

  @override
  String get searchHintNameFilter => 'Es: documento';

  @override
  String get searchLabelExtension => 'Estensione';

  @override
  String get searchHintExtension => 'Es: pdf';

  @override
  String get searchLabelSizeMin => 'Dimensione min (bytes)';

  @override
  String get searchLabelSizeMax => 'Dimensione max (bytes)';

  @override
  String get searchLabelFileType => 'Tipo file';

  @override
  String get searchLabelDateFilter => 'Filtro data';

  @override
  String get searchIncludeSystemFiles => 'Includi file di sistema';

  @override
  String get searchChoosePath => 'Scegli percorso';

  @override
  String get searchStop => 'Interrompi';

  @override
  String get searchSearchButton => 'Cerca';

  @override
  String get searchNoCriteriaSnack => 'Inserisci almeno un criterio di ricerca';

  @override
  String searchError(String error) {
    return 'Errore durante la ricerca: $error';
  }

  @override
  String get searchNoResults => 'Nessun risultato trovato';

  @override
  String get searchResultsOne => '1 risultato trovato';

  @override
  String searchResultsMany(int count) {
    return '$count risultati trovati';
  }

  @override
  String get searchTooltipViewList => 'Lista';

  @override
  String get searchTooltipViewGrid => 'Griglia';

  @override
  String get searchTooltipViewDetails => 'Dettagli';

  @override
  String get searchZoomOut => 'Zoom indietro';

  @override
  String get searchZoomIn => 'Zoom avanti';

  @override
  String get searchTypeAll => 'Tutti';

  @override
  String get searchTypeImages => 'Immagini';

  @override
  String get searchTypeVideo => 'Video';

  @override
  String get searchTypeAudio => 'Audio';

  @override
  String get searchTypeDocuments => 'Documenti';

  @override
  String get searchTypeArchives => 'Archivi';

  @override
  String get searchTypeExecutables => 'Eseguibili';

  @override
  String get searchDateAll => 'Tutti';

  @override
  String get searchDateToday => 'Oggi';

  @override
  String get searchDateWeek => 'Ultima settimana';

  @override
  String get searchDateMonth => 'Ultimo mese';

  @override
  String get searchDateYear => 'Ultimo anno';

  @override
  String statusDiskPercent(String value) {
    return '$value%';
  }

  @override
  String get depsDialogTitle => 'Componenti di sistema';

  @override
  String get depsDialogIntro =>
      'Mancano i seguenti componenti. L\'app funziona meglio se sono installati. Puoi installarli ora con la password di amministratore (PolicyKit).';

  @override
  String get depsInstallButton => 'Installa ora (password amministratore)';

  @override
  String get depsContinueButton => 'Continua senza installare';

  @override
  String get depsInstalling => 'Installazione pacchetti…';

  @override
  String get depsInstallSuccess => 'Installazione completata.';

  @override
  String depsInstallFailed(String message) {
    return 'Installazione non riuscita: $message';
  }

  @override
  String get depsUnknownDistro =>
      'Installazione automatica non disponibile per questa distribuzione Linux. Installa i pacchetti manualmente da terminale.';

  @override
  String get depsManualCommandLabel => 'Comando suggerito';

  @override
  String get depsPkexecNotFound => 'pkexec non trovato. Esegui nel terminale:';

  @override
  String get depsRustUnavailable =>
      'Libreria nativa (Rust) non caricata. La copia di file grandi può essere più lenta. Reinstalla l\'applicazione se il problema persiste.';

  @override
  String get depLabelXdgOpen =>
      'xdg-open — apri file con le applicazioni predefinite';

  @override
  String get depLabelMountCifs =>
      'mount.cifs — monta condivisioni SMB (cifs-utils)';

  @override
  String get depsCifsInstallTitle => 'Installare cifs-utils?';

  @override
  String get depsCifsInstallBody =>
      'Per montare le condivisioni SMB serve mount.cifs dal pacchetto cifs-utils. Installarlo ora con il gestore pacchetti (password di amministratore)?';

  @override
  String get depLabelSmbclient => 'smbclient — esplora condivisioni SMB/CIFS';

  @override
  String get depLabelNmblookup =>
      'nmblookup — trova computer sulla LAN (NetBIOS)';

  @override
  String get depLabelAvahiBrowse =>
      'avahi-browse — trova computer tramite mDNS';

  @override
  String get depLabelAvahiResolve =>
      'avahi-resolve-address — risolve i nomi host in LAN (mDNS)';

  @override
  String get depsNetworkBannerHint =>
      'Mancano alcuni strumenti opzionali per trovare i PC in rete e montare le condivisioni. Puoi installarli in automatico (serve la password di amministratore).';

  @override
  String get depsNetworkBannerLater => 'Non ora';

  @override
  String get depsSomeStillMissing =>
      'Alcuni strumenti mancano ancora. Prova il comando da terminale suggerito sotto.';

  @override
  String get depsPolkitAuthFailed =>
      'Autenticazione amministratore annullata, negata, oppure pkexec non ha potuto eseguire l\'installer.';

  @override
  String get depsInstallOutputIntro => 'Output del gestore pacchetti:';

  @override
  String get depsInstallUnexpected => 'errore imprevisto';

  @override
  String get depsDialogIntroRustOnly =>
      'Non è disponibile l\'accelerazione nativa per alcune operazioni sui file (libreria Rust).';

  @override
  String get depsDialogIntroToolsOk =>
      'Gli strumenti da riga di comando richiesti risultano installati.';

  @override
  String get depsCloseButton => 'Chiudi';

  @override
  String get computerTitle => 'Computer';

  @override
  String get computerOnDevice => 'Su questo dispositivo';

  @override
  String get computerNetworks => 'Rete';

  @override
  String get computerNoVolumes => 'Nessun volume trovato';

  @override
  String get computerNoServers => 'Nessun server rilevato';

  @override
  String get computerTools => 'Strumenti';

  @override
  String get computerToolFindFiles => 'Trova file e cartelle';

  @override
  String get computerToolPackages => 'Disinstalla/Installa app';

  @override
  String get computerToolSystemUpdates => 'Cerca aggiornamenti di sistema';

  @override
  String get computerRefresh => 'Aggiorna';

  @override
  String computerFreeShort(String size) {
    return '$size disponibili';
  }

  @override
  String computerNetworkHint(String name) {
    return 'Collegati dalla barra laterale → Rete per $name';
  }

  @override
  String get computerVolumeOpen => 'Apri';

  @override
  String get computerFormatVolume => 'Formatta…';

  @override
  String get computerFormatTitle => 'Formatta volume';

  @override
  String get computerFormatWarning =>
      'Tutti i dati su questo volume verranno eliminati. Operazione irreversibile.';

  @override
  String get computerFormatFilesystem => 'File system';

  @override
  String get computerFormatConfirm => 'Formatta';

  @override
  String get computerFormatNotSupported =>
      'La formattazione da questa schermata è supportata solo su Linux con udisks2.';

  @override
  String get computerFormatNoDevice =>
      'Impossibile determinare il dispositivo a blocchi per questo volume.';

  @override
  String get computerFormatSystemBlockedTitle => 'Formattazione non consentita';

  @override
  String get computerFormatSystemBlockedBody =>
      'Questo è un volume di sistema (root, avvio o stesso disco del sistema). Non può essere formattato da qui.';

  @override
  String get computerFormatRunning => 'Formattazione in corso…';

  @override
  String get computerFormatDone => 'Formattazione completata.';

  @override
  String computerFormatFailed(String error) {
    return 'Formattazione non riuscita: $error';
  }

  @override
  String get computerMounting => 'Connessione…';

  @override
  String get computerMountNoShares =>
      'Nessuna condivisione trovata. Controlla credenziali, firewall o SMB sul server.';

  @override
  String get computerMountFailed =>
      'Impossibile montare la condivisione. Prova altre credenziali, installa cifs-utils o verifica i permessi di mount.';

  @override
  String get computerMountMissingGio =>
      'mount.cifs non trovato. Installa il pacchetto cifs-utils. Potrebbero servire privilegi di root o voci in /etc/fstab per montare.';

  @override
  String get computerMountNeedPassword =>
      'Questa condivisione richiede utente e password. Riprova e inserisci le credenziali.';

  @override
  String get networkRememberPassword =>
      'Ricorda le credenziali per questo computer (archivio sicuro)';

  @override
  String get dialogRootPasswordTitle => 'Password amministratore';

  @override
  String get dialogRootPasswordLabel => 'Password per sudo';

  @override
  String get computerSelectShare => 'Seleziona condivisione';

  @override
  String get computerConnect => 'Connetti';

  @override
  String get computerCredentialsTitle => 'Accesso di rete';

  @override
  String get computerUsername => 'Nome utente';

  @override
  String get computerPassword => 'Password';

  @override
  String get computerDiskProperties => 'Proprietà';

  @override
  String get diskPropsOpenInDisks => 'Apri in Dischi';

  @override
  String get diskPropsFsUnknown => 'File system sconosciuto';

  @override
  String diskPropsFsLine(String type) {
    return 'File system $type';
  }

  @override
  String diskPropsTotalLine(String size) {
    return 'Totale: $size';
  }

  @override
  String diskPropsUsedLine(String size) {
    return 'Usato: $size';
  }

  @override
  String diskPropsFreeLine(String size) {
    return 'Libero: $size';
  }

  @override
  String get diskPropsFileAccessRow => 'Accesso ai file';

  @override
  String get snackExternalDropDone =>
      'Operazione sui file trascinati completata.';

  @override
  String get snackDropUnreadable => 'Impossibile leggere i file trascinati.';

  @override
  String get snackOpenAsRootLaunched =>
      'Finestra amministratore avviata (separata da questa).';

  @override
  String computerNetworkIpLine(String ip) {
    return 'IP: $ip';
  }
}
