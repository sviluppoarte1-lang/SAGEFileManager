// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'SAGE File Manager';

  @override
  String get menuTooltip => 'Menü';

  @override
  String get menuTopFile => 'Datei';

  @override
  String get menuTopEdit => 'Bearbeiten';

  @override
  String get menuTopView => 'Ansicht';

  @override
  String get menuTopFavorites => 'Favoriten';

  @override
  String get menuTopThemes => 'Designs';

  @override
  String get menuTopTools => 'Werkzeuge';

  @override
  String get menuTopHelp => 'Hilfe';

  @override
  String get menuNewTab => 'Neuer Tab (F2)';

  @override
  String get menuNewFolder => 'Neuer Ordner';

  @override
  String get menuNewTextFile => 'Neues Textdokument';

  @override
  String get menuNetworkDrive => 'Netzlaufwerk verbinden';

  @override
  String get menuBulkRename => 'Umbenennen';

  @override
  String get menuEmptyTrash => 'Papierkorb leeren';

  @override
  String get menuExit => 'Beenden';

  @override
  String get menuCut => 'Ausschneiden (Strg+X)';

  @override
  String get menuCopy => 'Kopieren (Strg+C)';

  @override
  String get menuPaste => 'Einfügen (Strg+V)';

  @override
  String get menuUndo => 'Rückgängig (Strg+Z)';

  @override
  String get menuRedo => 'Wiederholen (Strg+Y)';

  @override
  String get menuRefresh => 'Aktualisieren (F5)';

  @override
  String get menuSelectAll => 'Alles auswählen';

  @override
  String get menuDeselectAll => 'Auswahl aufheben';

  @override
  String get menuFind => 'Suchen (F1)';

  @override
  String get menuPreferences => 'Einstellungen';

  @override
  String get snackOneFileCut =>
      '1 Element in die Zwischenablage ausgeschnitten';

  @override
  String snackManyFilesCut(int count) {
    return '$count Elemente in die Zwischenablage ausgeschnitten';
  }

  @override
  String get snackOneFileCopied => '1 Element in die Zwischenablage kopiert';

  @override
  String snackManyFilesCopied(int count) {
    return '$count Elemente in die Zwischenablage kopiert';
  }

  @override
  String get sortArrangeIcons => 'Symbole anordnen';

  @override
  String get sortManual => 'Manuell';

  @override
  String get sortByName => 'Nach Name';

  @override
  String get sortBySize => 'Nach Größe';

  @override
  String get sortByType => 'Nach Typ';

  @override
  String get sortByDetailedType => 'Nach detailliertem Typ';

  @override
  String get sortByDate => 'Nach Änderungsdatum';

  @override
  String get sortReverse => 'Reihenfolge umkehren';

  @override
  String get viewShowHidden => 'Versteckte Dateien anzeigen';

  @override
  String get viewHideHidden => 'Versteckte Dateien ausblenden';

  @override
  String get viewSplitScreen => 'Geteilte Ansicht (F3)';

  @override
  String get viewShowPreview => 'Vorschau anzeigen';

  @override
  String get viewHidePreview => 'Vorschau ausblenden';

  @override
  String get viewShowRightPanel => 'Rechte Seitenleiste anzeigen';

  @override
  String get viewHideRightPanel => 'Rechte Seitenleiste ausblenden';

  @override
  String get favAdd => 'Zu Favoriten hinzufügen';

  @override
  String get favManage => 'Favoriten verwalten';

  @override
  String get themesManage => 'Designverwaltung';

  @override
  String get toolsPackages => 'Apps deinstallieren / installieren';

  @override
  String get toolsUpdates => 'Nach Updates suchen';

  @override
  String get toolsBulkRenamePattern => 'Massenumbenennung (Muster)';

  @override
  String get toolsExtractArchive => 'Archiv entpacken';

  @override
  String get helpShortcuts => 'Tastenkürzel';

  @override
  String get helpUserGuide => 'Benutzerhandbuch';

  @override
  String get helpUserGuideTitle => 'Benutzerhandbuch';

  @override
  String get helpUserGuideBlock1 =>
      'NAVIGATION\n• Seitenleiste: Startordner, Standardordner (Desktop, Dokumente …), eigene Pfade, Favoriten, Netzwerk und eingehängte Laufwerke. Zeilen zum Sortieren ziehen.\n• Symbolleiste und Pfadleiste: übergeordneter Ordner, Aktualisieren und globale Suche.\n• Rücktaste: zurück in der Chronologie. Wenn in den Einstellungen aktiviert, öffnet Doppelklick auf leeren Bereich den übergeordneten Ordner.\n• Doppelklick auf Ordner öffnet ihn; Doppelklick auf Datei startet die Standardanwendung.';

  @override
  String get helpUserGuideBlock2 =>
      'DATEIEN UND ZWISCHENABLAGE\n• Klick zum Auswählen; Rahmen ziehen für Mehrfachauswahl. Strg für mehrere Einträge, Umschalt für Bereiche. Esc hebt alles ab.\n• Strg+C, Strg+X, Strg+V kopieren, ausschneiden und einfügen. Ausgewählte Elemente aus dem Fenster ziehen (Desktop oder andere Apps).\n• Rechtsklick: Kontextmenü (Umbenennen, Löschen, Eigenschaften …). Die Menüs Datei und Bearbeiten bieten dieselben Aktionen.';

  @override
  String get helpUserGuideBlock3 =>
      'ANSICHTEN UND SUCHE\n• Menü Ansicht: Liste, Raster oder Details; versteckte Dateien; geteilter Modus (F3); Vorschau und rechtes Panel (F6).\n• F5 aktualisiert den aktuellen Ordner. F2 öffnet ein neues Fenster.\n• Extras → Suchen (F1) öffnet die Dateisuche: Filter nach Name, Erweiterung, Größe, Typ und Datum; ein Unterbaum oder optional alle eingehängten Datenträger.';

  @override
  String get helpUserGuideBlock4 =>
      'EINSTELLUNGEN UND MEHR\n• Favoriten und Themenverwaltung im oberen Menü (öffnet den Theme-Editor). Einstellungen für Klicks, Sprache, kompaktes Menü, geteilte Ansicht und Dateioperationen.\n• Computer zeigt Laufwerke. Netzwerkpfade über die Seitenleiste hinzufügen; für SMB kann die App Abhängigkeiten vorschlagen.\n• Extras: Dateisuche (F1), Paketverwaltung und Update-Prüfung, falls verfügbar.\n• Hilfe → Tastenkürzel listet alle Tasten; dieses Handbuch fasst die Hauptfunktionen zusammen.';

  @override
  String get helpAbout => 'Info';

  @override
  String get helpGitHubProject => 'GitHub-Projekt';

  @override
  String get helpDonateNow => 'Jetzt spenden';

  @override
  String get helpCheckAppUpdate => 'Nach App-Updates suchen';

  @override
  String appUpdateNewVersionAvailable(Object version) {
    return 'Neue Version $version ist verfügbar.';
  }

  @override
  String get appUpdateViewRelease => 'Release ansehen';

  @override
  String get appUpdateCheckFailed =>
      'Update-Prüfung fehlgeschlagen (Netzwerk oder GitHub).';

  @override
  String get appUpdateAlreadyLatest =>
      'Sie nutzen bereits die neueste Version.';

  @override
  String get navBack => 'Zurück';

  @override
  String get navForward => 'Vor';

  @override
  String get navUp => 'Nach oben';

  @override
  String get prefsGeneral => 'Allgemein';

  @override
  String get prefsSingleClickOpen => 'Einfacher Klick zum Öffnen';

  @override
  String get prefsSingleClickOpenSubtitle =>
      'Dateien und Ordner mit einem Klick öffnen';

  @override
  String get prefsDoubleClickRename => 'Doppelklick zum Umbenennen';

  @override
  String get prefsDoubleClickRenameSubtitle =>
      'Dateien und Ordner per Doppelklick auf den Namen umbenennen';

  @override
  String get prefsDoubleClickEmptyUp =>
      'Doppelklick auf leeren Bereich: eine Ebene hoch';

  @override
  String get prefsDoubleClickEmptyUpSubtitle =>
      'Zum übergeordneten Ordner per Doppelklick auf leeren Bereich';

  @override
  String get prefsLanguage => 'Sprache';

  @override
  String get prefsLanguageLabel => 'Oberflächensprache';

  @override
  String get prefsMenuCompactTitle => 'Kompaktes Menü';

  @override
  String get prefsMenuCompactSubtitle =>
      'Menüeinträge hinter dem Drei-Striche-Symbol statt klassischer Leiste';

  @override
  String get smbShellLimitedModeGvfsFallback =>
      'CIFS-Mount fehlgeschlagen: Ordner nur per smbclient sichtbar. Installieren Sie cifs-utils und stellen Sie sicher, dass mount.cifs ausführbar ist, dann erneut versuchen.';

  @override
  String get smbShellFileOpenUnavailable =>
      'Nur smbclient (ohne CIFS-Mount). Freigabe mit mount.cifs einbinden oder Option deaktivieren, wenn CIFS funktioniert.';

  @override
  String get prefsExecTextTitle => 'Ausführbare Textdateien';

  @override
  String get prefsExecAuto => 'Automatisch ausführen';

  @override
  String get prefsExecAlwaysShow => 'Immer anzeigen';

  @override
  String get prefsExecAlwaysAsk => 'Immer fragen';

  @override
  String get prefsDefaultFmTitle => 'Standard-Dateimanager';

  @override
  String get prefsDefaultFmBody =>
      'Diesen Dateimanager als Standard-App zum Öffnen von Ordnern festlegen.';

  @override
  String get prefsDefaultFmButton => 'Als Standard-Dateimanager festlegen';

  @override
  String get langItalian => 'Italienisch';

  @override
  String get langEnglish => 'Englisch';

  @override
  String get langFrench => 'Französisch';

  @override
  String get langSpanish => 'Spanisch';

  @override
  String get langPortuguese => 'Portugiesisch';

  @override
  String get langGerman => 'Deutsch';

  @override
  String get fileListTypeFolder => 'Ordner';

  @override
  String get fileListTypeFile => 'Datei';

  @override
  String get fileListEmpty => 'Keine Dateien';

  @override
  String get copyProgressTitle => 'Kopieren';

  @override
  String get copyProgressCancelTooltip => 'Abbrechen';

  @override
  String copySpeed(String speed) {
    return 'Geschwindigkeit: $speed';
  }

  @override
  String copyRemaining(String time) {
    return 'Verbleibende Zeit: $time';
  }

  @override
  String copyProgressDestLine(String name) {
    return '→ $name';
  }

  @override
  String statusItems(int count) {
    return 'Elemente: $count';
  }

  @override
  String statusFree(String size) {
    return 'Frei: $size';
  }

  @override
  String statusUsed(String size) {
    return 'Belegt: $size';
  }

  @override
  String statusTotal(String size) {
    return 'Gesamt: $size';
  }

  @override
  String statusCopyLine(String source, String dest) {
    return 'Kopie: $source → $dest';
  }

  @override
  String statusCurrentFile(String name) {
    return 'Datei: $name';
  }

  @override
  String get dialogCloseWhileCopyTitle => 'Vorgang läuft';

  @override
  String get dialogCloseWhileCopyBody =>
      'Eine Kopier- oder Verschiebeaktion läuft. Beenden kann sie unterbrechen. Fortfahren?';

  @override
  String get dialogCancel => 'Abbrechen';

  @override
  String get dialogOverwriteTitle => 'Vorhandenes Element ersetzen?';

  @override
  String dialogOverwriteBody(String name) {
    return '\"$name\" ist in diesem Ordner bereits vorhanden. Ersetzen?';
  }

  @override
  String get dialogOverwriteReplace => 'Ersetzen';

  @override
  String get dialogOverwriteSkip => 'Überspringen';

  @override
  String get dialogCloseAnyway => 'Trotzdem schließen';

  @override
  String get commonClose => 'Schließen';

  @override
  String get commonSave => 'Speichern';

  @override
  String get commonDelete => 'Löschen';

  @override
  String get commonRename => 'Umbenennen';

  @override
  String get commonAdd => 'Hinzufügen';

  @override
  String commonError(String message) {
    return 'Fehler: $message';
  }

  @override
  String get errorFolderRequiresOpenAsRoot =>
      'Um diesen Ordner zu öffnen, nutzen Sie „Als Root öffnen“.';

  @override
  String get sidebarAddNetworkTitle => 'Netzwerkpfad hinzufügen';

  @override
  String get sidebarNetworkPathLabel => 'Netzwerkpfad';

  @override
  String get sidebarNetworkHint =>
      'smb://server/freigabe oder //server/freigabe';

  @override
  String get sidebarNetworkHelp =>
      'Beispiele:\n• smb://192.168.1.100/gemeinsam\n• //server/freigabe\n• /mnt/netzwerk';

  @override
  String get sidebarBrowseTooltip => 'Durchsuchen';

  @override
  String get sidebarRenameShareTitle => 'Netzwerkfreigabe umbenennen';

  @override
  String get sidebarRemoveShareTitle => 'Netzwerkfreigabe entfernen';

  @override
  String sidebarRemoveShareConfirm(String name) {
    return '„$name“ aus der Liste entfernen?';
  }

  @override
  String get sidebarUnmountTitle => 'Datenträger auswerfen';

  @override
  String sidebarUnmountConfirm(String name) {
    return '„$name“ auswerfen?';
  }

  @override
  String get sidebarUnmount => 'Auswerfen';

  @override
  String sidebarUnmountOk(String name) {
    return '„$name“ ausgeworfen';
  }

  @override
  String sidebarUnmountFail(String name) {
    return 'Auswerfen von „$name“ fehlgeschlagen';
  }

  @override
  String get sidebarEmptyTrash => 'Papierkorb leeren';

  @override
  String get sidebarRemoveFromList => 'Aus Liste entfernen';

  @override
  String get sidebarMenuChangeColor => 'Farbe ändern';

  @override
  String sidebarChangeColorDialogTitle(String name) {
    return 'Farbe ändern: $name';
  }

  @override
  String get sidebarProperties => 'Eigenschaften';

  @override
  String sidebarPropertiesFolderTitle(String name) {
    return 'Eigenschaften: $name';
  }

  @override
  String get sidebarChangeFolderColor => 'Ordnerfarbe ändern:';

  @override
  String get sidebarRemoveCustomColor => 'Benutzerdefinierte Farbe entfernen';

  @override
  String get sidebarChangeAllFoldersColor => 'Alle Ordnerfarben ändern';

  @override
  String get sidebarPickDefaultColor => 'Standardfarbe für alle Ordner wählen:';

  @override
  String get sidebarEmptyTrashTitle => 'Papierkorb leeren';

  @override
  String get sidebarEmptyTrashBody =>
      'Papierkorb endgültig leeren? Dies kann nicht rückgängig gemacht werden.';

  @override
  String get sidebarEmptyTrashConfirm => 'Leeren';

  @override
  String get sidebarTrashEmptied => 'Papierkorb geleert';

  @override
  String sidebarCredentialsTitle(String server) {
    return 'Anmeldedaten für $server';
  }

  @override
  String get sidebarGuestAccess => 'Gastzugriff (anonym)';

  @override
  String get sidebarConnect => 'Verbinden';

  @override
  String sidebarConnecting(String name) {
    return 'Verbindung mit $name...';
  }

  @override
  String sidebarConnectionError(String name) {
    return 'Fehler bei Verbindung zu $name';
  }

  @override
  String get sidebarRetry => 'Erneut versuchen';

  @override
  String get copyCancelled => 'Kopieren abgebrochen';

  @override
  String get fileCopiedSuccess => 'Datei kopiert';

  @override
  String get folderCopiedSuccess => 'Ordner kopiert';

  @override
  String get extractionComplete => 'Entpacken abgeschlossen';

  @override
  String snackInitError(String error) {
    return 'Initialisierungsfehler: $error';
  }

  @override
  String snackPathRemoved(String name) {
    return 'Aus Liste entfernt: $name';
  }

  @override
  String get labelChoosePath => 'Pfad wählen';

  @override
  String get ctxOpenTerminal => 'Terminal öffnen';

  @override
  String get ctxNewFolder => 'Neuer Ordner';

  @override
  String get ctxOpenAsRoot => 'Als root öffnen';

  @override
  String get ctxOpenWith => 'Öffnen mit…';

  @override
  String get ctxCopyTo => 'Kopieren nach…';

  @override
  String get ctxMoveTo => 'Verschieben nach…';

  @override
  String get ctxCopy => 'Kopieren';

  @override
  String get ctxCut => 'Ausschneiden';

  @override
  String get ctxPaste => 'Einfügen';

  @override
  String get ctxCreateNew => 'Neu';

  @override
  String get ctxNewTextDocumentShort => 'Textdokument (.txt)';

  @override
  String get ctxNewWordDocument => 'Word-Dokument (.docx)';

  @override
  String get ctxNewExcelSpreadsheet => 'Excel-Arbeitsmappe (.xlsx)';

  @override
  String get ctxExtract => 'Entpacken';

  @override
  String get ctxExtractTo => 'Archiv entpacken nach…';

  @override
  String get ctxCompressToZip => 'Als .zip-Datei komprimieren';

  @override
  String snackZipCreated(Object name) {
    return 'Archiv erstellt: \"$name\".';
  }

  @override
  String snackZipFailed(Object message) {
    return 'ZIP konnte nicht erstellt werden: $message';
  }

  @override
  String get ctxChangeColor => 'Farbe ändern';

  @override
  String get ctxMoveToTrash => 'In den Papierkorb legen';

  @override
  String get ctxRestoreFromTrash => 'Am ursprünglichen Ort wiederherstellen';

  @override
  String get menuRestoreFromTrash => 'Aus Papierkorb wiederherstellen';

  @override
  String get trashRestorePickFolderTitle =>
      'Ordner zum Wiederherstellen wählen';

  @override
  String trashRestoreTargetExists(String name) {
    return 'Wiederherstellung nicht möglich: „$name“ existiert am Ziel bereits.';
  }

  @override
  String trashRestoredCount(int count) {
    return '$count Elemente wiederhergestellt';
  }

  @override
  String get trashRestoreFailed =>
      'Ausgewählte Elemente konnten nicht wiederhergestellt werden.';

  @override
  String dialogOpenWithTitle(String name) {
    return '„$name“ öffnen mit…';
  }

  @override
  String get hintSearchApp => 'Anwendung suchen…';

  @override
  String get openWithDefaultApp => 'Standardanwendung';

  @override
  String get browseEllipsis => 'Durchsuchen…';

  @override
  String get tooltipSetAsDefaultApp => 'Als Standardanwendung festlegen';

  @override
  String get openWithOpenAndSetDefault => 'Öffnen und als Standard festlegen';

  @override
  String get openWithFooterHint =>
      'Mit Stern oder ⋮-Menü können Sie die Standardanwendung für diesen Dateityp jederzeit ändern.';

  @override
  String snackDefaultAppSet(String appName, String mimeType) {
    return '$appName als Standard für $mimeType festgelegt';
  }

  @override
  String snackSetDefaultAppError(String error) {
    return 'Standard konnte nicht gesetzt werden: $error';
  }

  @override
  String snackOpenFileError(String error) {
    return 'Konnte nicht geöffnet werden: $error';
  }

  @override
  String get dialogTitleCreateFolder => 'Neuen Ordner erstellen';

  @override
  String get dialogTitleNewFolder => 'Neuer Ordner';

  @override
  String get labelFolderName => 'Ordnername';

  @override
  String get hintFolderName => 'Ordnernamen eingeben';

  @override
  String get labelFileName => 'Dateiname';

  @override
  String get hintTextDocument => 'dokument.txt';

  @override
  String get buttonCreate => 'Erstellen';

  @override
  String snackMoveError(String error) {
    return 'Fehler beim Verschieben: $error';
  }

  @override
  String dialogChangeColorFor(String name) {
    return 'Farbe ändern: $name';
  }

  @override
  String get dialogPickFolderColor => 'Wählen Sie eine Farbe für den Ordner:';

  @override
  String get shortcutTitle => 'Tastenkürzel';

  @override
  String get shortcutCopy => 'Ausgewählte Dateien/Ordner kopieren';

  @override
  String get shortcutPaste => 'Dateien/Ordner einfügen';

  @override
  String get shortcutCut => 'Ausgewählte Dateien/Ordner ausschneiden';

  @override
  String get shortcutUndo => 'Letzte Aktion rückgängig';

  @override
  String get shortcutRedo => 'Letzte Aktion wiederholen';

  @override
  String get shortcutNewTab => 'Neuen Tab öffnen';

  @override
  String get shortcutSplitView => 'Bildschirm teilen';

  @override
  String get shortcutRefresh => 'Aktuellen Ordner aktualisieren';

  @override
  String get shortcutRightPanel => 'Rechte Seitenleiste ein-/ausblenden';

  @override
  String get shortcutDeselect => 'Alle Dateien abwählen';

  @override
  String get shortcutBackNav => 'Zurück in der Navigation';

  @override
  String get shortcutFindFiles => 'Dateien und Ordner suchen';

  @override
  String get aboutTitle => 'Info';

  @override
  String get aboutAppName => 'Dateimanager';

  @override
  String get aboutTagline => 'Erweiterter Dateimanager';

  @override
  String aboutVersionLabel(String version) {
    return 'Version: $version';
  }

  @override
  String get aboutAuthor => 'Autor: Marco Di Giangiacomo';

  @override
  String get aboutYear => '© 2026';

  @override
  String get aboutDescriptionHeading => 'Beschreibung:';

  @override
  String get aboutDescription =>
      'SAGE File Manager: moderner Dateimanager für Linux mit Mehrfachansicht, Vorschau, Designs, Suche, optimiertem Kopieren, geteilter Ansicht, SMB/LAN und mehr.';

  @override
  String get aboutFeaturesHeading => 'Hauptfunktionen:';

  @override
  String get aboutFeaturesList =>
      '• Vollständige Datei- und Ordnerverwaltung\n• Mehrere Ansichten (Liste, Raster, Details)\n• Dateivorschau (Bilder, PDF, Dokumente, Text)\n• Themenverwaltung (Vorlagen und Anpassung)\n• Erweiterte Suche\n• Optimiertes Kopieren/Einfügen\n• Geteilte Ansicht\n• Favoriten und eigene Pfade\n• Unterstützung für ausführbare Dateien und Skripte\n• Moderne Oberfläche';

  @override
  String snackDocumentCreated(String name) {
    return 'Dokument „$name“ erstellt';
  }

  @override
  String get dialogInsufficientPermissions => 'Unzureichende Berechtigungen';

  @override
  String get snackFolderCreated => 'Ordner erstellt';

  @override
  String get snackTerminalUnavailable => 'Terminal nicht verfügbar';

  @override
  String get snackTerminalRootError =>
      'Terminal konnte nicht als root geöffnet werden';

  @override
  String get snackRootHelperMissing =>
      'Konnte nicht als root öffnen. Bitte pkexec oder sudo installieren.';

  @override
  String get snackOpenAsRootNoFolder =>
      'Öffnen Sie zuerst einen Ordner und wählen Sie dann Als root öffnen.';

  @override
  String get snackOpenAsRootBadFolder =>
      'Dieser Ordner kann nicht geöffnet werden.';

  @override
  String snackPasteItemError(String name, String error) {
    return 'Fehler beim Einfügen von $name: $error';
  }

  @override
  String get snackFileMoved => 'Datei verschoben';

  @override
  String get dialogRenameFileTitle => 'Umbenennen';

  @override
  String dialogRenameManySubtitle(int count) {
    return '$count Elemente ausgewählt. Geben Sie für jede Zeile einen neuen Namen ein.';
  }

  @override
  String get labelNewName => 'Neuer Name';

  @override
  String get snackFileRenamed => 'Datei umbenannt';

  @override
  String snackRenameError(String error) {
    return 'Fehler beim Umbenennen: $error';
  }

  @override
  String get snackRenameSameFolder =>
      'Alle ausgewählten Elemente müssen im selben Ordner liegen.';

  @override
  String get snackRenameEmptyName =>
      'Jedes Element braucht einen nicht leeren neuen Namen.';

  @override
  String get snackRenameDuplicateNames =>
      'Die neuen Namen müssen sich unterscheiden.';

  @override
  String get snackRenameTargetExists =>
      'Eine Datei oder ein Ordner mit diesem Namen existiert bereits.';

  @override
  String get snackSelectPathFirst => 'Zuerst einen Pfad auswählen';

  @override
  String get snackAlreadyFavorite => 'Bereits in den Favoriten';

  @override
  String snackAddedFavorite(String name) {
    return 'Zu Favoriten hinzugefügt: $name';
  }

  @override
  String get favoritesEmptyList => 'Noch keine Favoriten';

  @override
  String snackNewTabOpened(String name) {
    return 'Neuer Tab geöffnet: $name';
  }

  @override
  String get snackSelectForSymlink =>
      'Datei oder Ordner für Verknüpfung auswählen';

  @override
  String get dialogCreateSymlinkTitle => 'Verknüpfung erstellen';

  @override
  String get labelSymlinkName => 'Name der Verknüpfung';

  @override
  String get snackSymlinkCreated => 'Verknüpfung erstellt';

  @override
  String get snackConnectingNetwork => 'Verbindung mit Netzwerk…';

  @override
  String get snackNewInstanceStarted => 'Neue App-Instanz gestartet';

  @override
  String snackNewInstanceError(String error) {
    return 'Neue Instanz konnte nicht gestartet werden: $error';
  }

  @override
  String get snackSelectFilesRename =>
      'Mindestens eine Datei zum Umbenennen auswählen';

  @override
  String get bulkRenameTitle => 'Massenumbenennung';

  @override
  String bulkRenameSelectedCount(int count) {
    return '$count Dateien ausgewählt';
  }

  @override
  String get bulkRenamePatternLabel => 'Umbenennungsmuster';

  @override
  String get bulkRenamePatternHelper =>
      'Verwenden Sie die Platzhalter name und num in geschweiften Klammern (siehe Beispiel unten).';

  @override
  String get bulkRenameAutoNumber => 'Automatische Nummerierung';

  @override
  String get bulkRenameStartNumber => 'Startnummer';

  @override
  String get bulkRenameKeepExt => 'Original-Erweiterung beibehalten';

  @override
  String trashEmptyError(String error) {
    return 'Fehler beim Leeren des Papierkorbs: $error';
  }

  @override
  String labelNItems(int count) {
    return '$count Elemente';
  }

  @override
  String get dialogTitleDeletePermanent => 'Endgültig löschen?';

  @override
  String get dialogTitleMoveToTrashConfirm => 'In den Papierkorb legen?';

  @override
  String get dialogBodyPermanentDeleteOne => 'Ein Element endgültig löschen?';

  @override
  String dialogBodyPermanentDeleteMany(int count) {
    return '$count Elemente endgültig löschen?';
  }

  @override
  String get dialogBodyTrashOne => 'Ein Element in den Papierkorb verschieben?';

  @override
  String dialogBodyTrashMany(int count) {
    return '$count Elemente in den Papierkorb verschieben?';
  }

  @override
  String get snackDeletedPermanentOne => 'Ein Element endgültig gelöscht';

  @override
  String snackDeletedPermanentMany(int count) {
    return '$count Elemente endgültig gelöscht';
  }

  @override
  String get snackMovedToTrashOne => 'Ein Element in den Papierkorb verschoben';

  @override
  String snackMovedToTrashMany(int count) {
    return '$count Elemente in den Papierkorb verschoben';
  }

  @override
  String snackDeleteErrorsSuffix(int errors) {
    return ', $errors Fehler';
  }

  @override
  String get dialogOpenAsRootBody =>
      'Sie haben keine Berechtigung, hier Dateien oder Ordner anzulegen. Dateimanager als root öffnen?';

  @override
  String get dialogOpenAsRootAuthTitle => 'Als Administrator öffnen';

  @override
  String get dialogOpenAsRootAuthBody =>
      'Nach „Weiter“ fragt das System nach dem Administratorpasswort. Erst nach erfolgreicher Anmeldung öffnet sich ein neues Dateimanager-Fenster in diesem Ordner.';

  @override
  String get dialogOpenAsRootContinue => 'Weiter';

  @override
  String get paneSelectPathHint => 'Pfad auswählen';

  @override
  String get emptyFolderLabel => 'Ordner leer';

  @override
  String get sidebarMountPointOptional => 'Einhängepunkt (optional)';

  @override
  String snackBulkRenameManyDone(int count) {
    return '$count Dateien umbenannt';
  }

  @override
  String get commonOk => 'OK';

  @override
  String get prefsPageTitle => 'Einstellungen';

  @override
  String get snackPrefsSaved => 'Einstellungen gespeichert';

  @override
  String get prefsNavView => 'Darstellung';

  @override
  String get prefsNavPreview => 'Vorschau';

  @override
  String get prefsNavFileOps => 'Dateioperationen';

  @override
  String get prefsNavTrash => 'Papierkorb';

  @override
  String get prefsNavMedia => 'Wechselmedien';

  @override
  String get prefsNavCache => 'Cache';

  @override
  String get prefsDefaultFmSuccess =>
      'Dateimanager erfolgreich als Standard festgelegt.';

  @override
  String get prefsShowHiddenTitle => 'Versteckte Dateien anzeigen';

  @override
  String get prefsShowHiddenSubtitle =>
      'Dateien und Ordner anzeigen, deren Name mit einem Punkt beginnt';

  @override
  String get prefsShowPreviewPanelTitle => 'Vorschau-Panel anzeigen';

  @override
  String get prefsShowPreviewPanelSubtitle => 'Vorschau-Panel rechts anzeigen';

  @override
  String get prefsAlwaysDoublePaneTitle =>
      'Immer mit geteilter Ansicht starten';

  @override
  String get prefsAlwaysDoublePaneSubtitle =>
      'Geteilte Ansicht beim Start immer öffnen';

  @override
  String get prefsIgnoreViewPerFolderTitle =>
      'Ansichtseinstellungen pro Ordner ignorieren';

  @override
  String get prefsIgnoreViewPerFolderSubtitle =>
      'Keine Ansichtseinstellungen pro Ordner speichern';

  @override
  String get prefsDefaultViewModeTitle => 'Standard-Ansichtsmodus';

  @override
  String get prefsViewModeList => 'Liste';

  @override
  String get prefsViewModeGrid => 'Raster';

  @override
  String get prefsViewModeDetails => 'Details';

  @override
  String get prefsGridZoomTitle => 'Standard-Raster-Zoom';

  @override
  String prefsGridZoomLevel(int current) {
    return 'Stufe: $current/10';
  }

  @override
  String get prefsFontSection => 'Schrift';

  @override
  String get prefsFontFamilyLabel => 'Schriftfamilie';

  @override
  String get labelSelectFont => 'Schriftart wählen';

  @override
  String get fontFamilyDefaultSystem => 'Standard (System)';

  @override
  String get prefsFontSizeTitle => 'Schriftgröße';

  @override
  String prefsFontSizeValue(String size) {
    return 'Größe: $size';
  }

  @override
  String get prefsFontWeightTitle => 'Schriftstärke';

  @override
  String get prefsFontWeightNormal => 'Normal';

  @override
  String get prefsFontWeightBold => 'Fett';

  @override
  String get prefsFontWeightSemiBold => 'Halbfett';

  @override
  String get prefsFontWeightMedium => 'Medium';

  @override
  String get prefsTextShadowSection => 'Textschatten';

  @override
  String get prefsTextShadowEnableTitle => 'Textschatten aktivieren';

  @override
  String get prefsTextShadowEnableSubtitle => 'Schatten für bessere Lesbarkeit';

  @override
  String get prefsShadowIntensityTitle => 'Schatten-Unschärfe';

  @override
  String get prefsShadowOffsetXTitle => 'Schattenversatz X';

  @override
  String get prefsShadowOffsetYTitle => 'Schattenversatz Y';

  @override
  String get prefsShadowColorTitle => 'Schattenfarbe';

  @override
  String prefsShadowColorValue(String value) {
    return 'Farbe: $value';
  }

  @override
  String get prefsShadowColorBlack => 'Schwarz';

  @override
  String get dialogPickShadowColor => 'Schattenfarbe wählen';

  @override
  String get prefsPickColor => 'Farbe wählen';

  @override
  String get prefsTextPreviewLabel => 'Textvorschau';

  @override
  String get prefsDisableFileQueueTitle =>
      'Dateioperations-Warteschlange deaktivieren';

  @override
  String get prefsDisableFileQueueSubtitle =>
      'Operationen nacheinander ohne Warteschlange';

  @override
  String get prefsAskTrashTitle => 'Vor Papierkorb nachfragen';

  @override
  String get prefsAskTrashSubtitle => 'Bestätigung vor Papierkorb';

  @override
  String get prefsAskEmptyTrashTitle => 'Vor Leeren des Papierkorbs nachfragen';

  @override
  String get prefsAskEmptyTrashSubtitle =>
      'Bestätigung vor endgültigem Löschen';

  @override
  String get prefsIncludeDeleteTitle => 'Befehl „Löschen“ anzeigen';

  @override
  String get prefsIncludeDeleteSubtitle => 'Option zum Löschen ohne Papierkorb';

  @override
  String get prefsSkipTrashDelKeyTitle => 'Papierkorb mit Entf überspringen';

  @override
  String get prefsSkipTrashDelKeySubtitle => 'Dateien direkt mit Entf löschen';

  @override
  String get prefsAutoMountTitle => 'Wechseldatenträger automatisch einhängen';

  @override
  String get prefsAutoMountSubtitle =>
      'USB und andere beim Anschließen einhängen';

  @override
  String get prefsOpenWindowMountedTitle =>
      'Fenster für eingehängte Geräte öffnen';

  @override
  String get prefsOpenWindowMountedSubtitle => 'Automatisch Fenster öffnen';

  @override
  String get prefsWarnRemovableTitle => 'Beim Anschließen benachrichtigen';

  @override
  String get prefsWarnRemovableSubtitle => 'Benachrichtigung bei Wechselmedium';

  @override
  String get prefsPreviewExtensionsIntro => 'Dateierweiterungen für Vorschau:';

  @override
  String get prefsPreviewRightPanelNote =>
      'Vollständige Vorschauen für PDF, Office, Text und andere Typen erscheinen in der rechten Seitenleiste, wenn sie sichtbar ist. Ist die Leiste ausgeblendet, werden in der Dateiliste nur Bildvorschauen angezeigt.';

  @override
  String get prefsAdminPasswordSection => 'Administratorpasswort';

  @override
  String get prefsSaveAdminPasswordTitle => 'Administratorpasswort speichern';

  @override
  String get prefsSaveAdminPasswordSubtitle =>
      'Passwort für Updates speichern (nicht empfohlen)';

  @override
  String get labelAdminPassword => 'Administratorpasswort';

  @override
  String get hintAdminPassword => 'Passwort eingeben';

  @override
  String get prefsCacheSectionTitle => 'Cache und Vorschauen';

  @override
  String get prefsCacheSizeTitle => 'Cache-Größe';

  @override
  String prefsCacheSizeCurrent(String size) {
    return 'Aktuelle Größe: $size';
  }

  @override
  String get labelNetworkShareName => 'Benutzerdefinierter Name';

  @override
  String get hintNetworkShareName => 'Name für diese Freigabe';

  @override
  String get sidebarTooltipRemoveNetwork => 'Netzwerkpfad entfernen';

  @override
  String get sidebarTooltipUnmount => 'Laufwerk auswerfen';

  @override
  String sidebarUnmountSuccess(String name) {
    return '„$name“ ausgehängt';
  }

  @override
  String sidebarUnmountError(String name) {
    return 'Fehler beim Auswerfen von „$name“';
  }

  @override
  String get previewSelectFile => 'Datei für Vorschau wählen';

  @override
  String get previewPanelTitle => 'Vorschau';

  @override
  String previewPanelSizeLine(String value) {
    return 'Größe: $value';
  }

  @override
  String previewPanelModifiedLine(String value) {
    return 'Geändert: $value';
  }

  @override
  String get dialogErrorTitle => 'Fehler';

  @override
  String get propsLoadError => 'Eigenschaften konnten nicht geladen werden';

  @override
  String get snackPermissionsUpdated => 'Berechtigungen aktualisiert';

  @override
  String dialogEditFieldTitle(String label) {
    return '$label bearbeiten';
  }

  @override
  String snackFieldUpdated(String label) {
    return '$label aktualisiert';
  }

  @override
  String get propsEditPermissionsTitle => 'Berechtigungen bearbeiten';

  @override
  String get permOwner => 'Eigentümer:';

  @override
  String get permGroup => 'Gruppe:';

  @override
  String get permOthers => 'Andere:';

  @override
  String get permRead => 'Lesen';

  @override
  String get permWrite => 'Schreiben';

  @override
  String get permExecute => 'Ausführen';

  @override
  String get previewNotAvailable => 'Keine Vorschau';

  @override
  String get previewImageError => 'Fehler beim Laden des Bildes';

  @override
  String get previewDocLoadError => 'Fehler beim Laden des Dokuments';

  @override
  String get previewOpenExternally => 'Mit externem Viewer öffnen';

  @override
  String get previewDocumentTitle => 'Dokumentvorschau';

  @override
  String get previewDocLegacyFormat =>
      '.doc wird nicht unterstützt. Nutzen Sie .docx oder einen externen Viewer.';

  @override
  String get previewSheetLoadError => 'Fehler beim Laden der Tabelle';

  @override
  String get previewSheetTitle => 'Tabellenvorschau';

  @override
  String get previewXlsLegacyFormat =>
      '.xls wird nicht unterstützt. Nutzen Sie .xlsx oder einen externen Viewer.';

  @override
  String get previewPresentationLoadError =>
      'Fehler beim Laden der Präsentation';

  @override
  String get previewOpenOfficeTitle => 'OpenOffice-Vorschau';

  @override
  String get previewOpenOfficeBody =>
      'OpenOffice-Dateien benötigen einen externen Viewer.';

  @override
  String themeApplied(String name) {
    return 'Design „$name“ angewendet';
  }

  @override
  String get themeDark => 'Dunkles Design';

  @override
  String themeFontSizeTitle(String size) {
    return 'Schriftgröße: $size';
  }

  @override
  String get themeFontWeightSection => 'Schriftstärke';

  @override
  String get themeBoldLabel => 'Fett';

  @override
  String get themeTextShadowSection => 'Textschatten';

  @override
  String themeShadowIntensity(String percent) {
    return 'Schattendichte: $percent %';
  }

  @override
  String get themeColorPicked => 'Farbe ausgewählt';

  @override
  String get themeSelectToCustomize => 'Design zum Anpassen wählen';

  @override
  String get themeFontFamilySection => 'Schriftfamilie';

  @override
  String get searchNeedCriterion => 'Mindestens ein Suchkriterium eingeben';

  @override
  String get searchCurrentPath => 'Aktueller Pfad';

  @override
  String get searchButton => 'Suchen';

  @override
  String get pkgConfirmUninstallTitle => 'Deinstallation bestätigen';

  @override
  String pkgConfirmUninstallBody(String name) {
    return '$name deinstallieren?';
  }

  @override
  String get pkgDependenciesTitle => 'Abhängigkeiten gefunden';

  @override
  String get pkgUninstallError => 'Fehler bei der Deinstallation';

  @override
  String get pkgManagerTitle => 'Anwendungsverwaltung';

  @override
  String get pkgInstallTitle => 'Paket installieren';

  @override
  String pkgInstallBody(String name) {
    return '„$name“ installieren?';
  }

  @override
  String pkgMadeExecutable(String name) {
    return '$name ausführbar gemacht';
  }

  @override
  String get pkgUnsupportedFormat => 'Nicht unterstütztes Paketformat';

  @override
  String pkgInstallErrorOutput(String output) {
    return 'Installationsfehler: $output';
  }

  @override
  String updateItemSuccess(String name) {
    return '$name erfolgreich aktualisiert';
  }

  @override
  String updateItemError(String name) {
    return 'Fehler beim Aktualisieren von $name';
  }

  @override
  String get updateAllError => 'Fehler beim Installieren der Updates';

  @override
  String get updateInstallAllButton => 'Alle installieren';

  @override
  String get previewCatImages => 'Bilder';

  @override
  String get previewCatDocuments => 'Dokumente';

  @override
  String get previewCatText => 'Text';

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
    return '$a, ${a}_$b, Dokument_$b';
  }

  @override
  String get tableColumnName => 'Name';

  @override
  String get tableColumnPath => 'Pfad';

  @override
  String get tableColumnSize => 'Größe';

  @override
  String get tableColumnModified => 'Geändert';

  @override
  String get tableColumnType => 'Typ';

  @override
  String get networkBrowserTitle => 'Netzwerk durchsuchen';

  @override
  String get networkSearchingServers => 'Suche nach Servern…';

  @override
  String get networkNoServersFound => 'Keine Server gefunden';

  @override
  String get networkServersSharesHeader => 'Server und Freigaben';

  @override
  String get labelUsername => 'Benutzername';

  @override
  String get labelPassword => 'Passwort';

  @override
  String get networkRefreshTooltip => 'Aktualisieren';

  @override
  String get networkNoSharesAvailable => 'Keine Freigaben verfügbar';

  @override
  String get networkInfoTitle => 'Informationen';

  @override
  String networkServersFoundCount(int count) {
    return 'Gefundene Server: $count';
  }

  @override
  String get networkConnectShareInstructions =>
      'Um eine Freigabe zu öffnen, klappen Sie einen Server auf und tippen Sie auf die gewünschte Freigabe.';

  @override
  String get networkSelectedServerLabel => 'Ausgewählter Server:';

  @override
  String networkSharesCount(int count) {
    return 'Freigaben: $count';
  }

  @override
  String get sidebarTooltipBrowseNetworkPaths => 'Netzwerkpfade durchsuchen';

  @override
  String get sidebarTooltipAddNetworkPath => 'Netzwerkpfad hinzufügen';

  @override
  String get sidebarSectionNetwork => 'Netzwerk';

  @override
  String get sidebarSectionDisks => 'Laufwerke';

  @override
  String get sidebarAddPath => 'Pfad hinzufügen';

  @override
  String get sidebarUserFolderHome => 'Persönlicher Ordner';

  @override
  String get sidebarUserFolderDesktop => 'Schreibtisch';

  @override
  String get sidebarUserFolderDocuments => 'Dokumente';

  @override
  String get sidebarUserFolderPictures => 'Bilder';

  @override
  String get sidebarUserFolderMusic => 'Musik';

  @override
  String get sidebarUserFolderVideos => 'Videos';

  @override
  String get sidebarUserFolderDownloads => 'Downloads';

  @override
  String get sidebarSectionFavorites => 'Favoriten';

  @override
  String get commonUnknown => 'Unbekannt';

  @override
  String get prefsClearCacheButton => 'Cache leeren';

  @override
  String get prefsClearCacheTitle => 'Cache leeren';

  @override
  String get prefsClearCacheBody => 'Gesamten Vorschau-Miniatur-Cache leeren?';

  @override
  String get prefsClearCacheConfirm => 'Leeren';

  @override
  String get snackPrefsCacheCleared => 'Cache geleert';

  @override
  String get previewFmtJpeg => 'JPEG-Bild';

  @override
  String get previewFmtPng => 'PNG-Bild';

  @override
  String get previewFmtGif => 'GIF-Bild';

  @override
  String get previewFmtBmp => 'BMP-Bild';

  @override
  String get previewFmtWebp => 'WebP-Bild';

  @override
  String get previewFmtPdf => 'PDF-Dokument';

  @override
  String get previewFmtPlainText => 'Textdatei';

  @override
  String get previewFmtMarkdown => 'Markdown';

  @override
  String get previewFmtNfo => 'Info-Datei';

  @override
  String get previewFmtShell => 'Shell-Skript';

  @override
  String get previewFmtHtml => 'HTML-Dokument';

  @override
  String get previewFmtDocx => 'Word-Dokument';

  @override
  String get previewFmtXlsx => 'Excel-Tabelle';

  @override
  String get previewFmtPptx => 'PowerPoint-Präsentation';

  @override
  String themeAppliedSnackbar(String name) {
    return 'Design „$name“ angewendet';
  }

  @override
  String get themeEditTitle => 'Design bearbeiten';

  @override
  String get themeNewTitle => 'Neues Design';

  @override
  String get themeFieldName => 'Designname';

  @override
  String get themeDarkThemeSwitch => 'Dunkles Design';

  @override
  String get themeColorPrimary => 'Primary color';

  @override
  String get themeColorSecondary => 'Secondary color';

  @override
  String get themeColorFile => 'File color';

  @override
  String get themeColorLocation => 'Location bar color';

  @override
  String get themeColorBackground => 'Background color';

  @override
  String get themeColorFolder => 'Folder color';

  @override
  String get themeFolderIconsHint =>
      'Icons are applied automatically based on folder type.';

  @override
  String get themeFolderIconPickColor => 'Pick a color for folder icons';

  @override
  String get themeColorPickedSnack => 'Color selected';

  @override
  String get themeManagerTitle => 'Designverwaltung';

  @override
  String get themeBuiltinHeader => 'Eingebaute Designs';

  @override
  String get themeCustomHeader => 'Eigene Designs';

  @override
  String get themeCustomizationHeader => 'Anpassung';

  @override
  String get themeSelectPrompt => 'Wählen Sie ein Design zum Anpassen';

  @override
  String get themeVariantLight => 'Light';

  @override
  String get themeVariantDark => 'Dark';

  @override
  String get themeColorsHeader => 'Colors';

  @override
  String get themeFontHeader => 'Font';

  @override
  String get themeFontFamilyRow => 'Font family';

  @override
  String themeFontSizeRow(String size) {
    return 'Font size: $size';
  }

  @override
  String get themeFontWeightHeader => 'Font weight';

  @override
  String get themeTextShadow => 'Text shadow';

  @override
  String get themeIconShadowTitle => 'Symbolschattierung (Raster)';

  @override
  String get themeIconShadowSubtitle =>
      'Schlagschatten unter Datei- und Ordnersymbolen in der Rasteransicht';

  @override
  String themeIconShadowIntensity(String percent) {
    return 'Symbolschattierung: $percent %';
  }

  @override
  String themeShadowIntensityRow(String percent) {
    return 'Shadow intensity: $percent%';
  }

  @override
  String get themeFolderIconFolder => 'Folder';

  @override
  String get themeFolderIconFolderOpen => 'Folder open';

  @override
  String get themeFolderIconFolderSpecial => 'Folder special';

  @override
  String get themeFolderIconFolderShared => 'Folder shared';

  @override
  String get themeFolderIconFolderCopy => 'Folder copy';

  @override
  String get themeFolderIconFolderDelete => 'Folder delete';

  @override
  String get themeFolderIconFolderZip => 'Folder zip';

  @override
  String get themeFolderIconFolderOff => 'Folder off';

  @override
  String get themeFolderIconFolderPlus => 'New folder';

  @override
  String get themeFolderIconFolderHome => 'Home';

  @override
  String get themeFolderIconFolderDrive => 'Drive';

  @override
  String get themeFolderIconFolderCloud => 'Cloud';

  @override
  String get propsTitle => 'Eigenschaften';

  @override
  String get propsTimeoutLoading =>
      'Zeitüberschreitung beim Laden der Eigenschaften';

  @override
  String propsLoadErrorDetail(String detail) {
    return 'Fehler beim Laden der Eigenschaften: $detail';
  }

  @override
  String get propsFieldName => 'Name';

  @override
  String get propsFieldPath => 'Path';

  @override
  String get propsFieldType => 'Type';

  @override
  String get propsFieldSize => 'Size';

  @override
  String get propsFieldSizeOnDisk => 'Size on disk';

  @override
  String get propsFieldModified => 'Modified';

  @override
  String get propsFieldAccessed => 'Accessed';

  @override
  String get propsFieldCreated => 'Created';

  @override
  String get propsFieldOwner => 'Owner';

  @override
  String get propsFieldGroup => 'Group';

  @override
  String get propsFieldPermissions => 'Permissions';

  @override
  String get propsFieldInode => 'Inode';

  @override
  String get propsFieldLinks => 'Links';

  @override
  String get propsFieldFilesInside => 'Files inside';

  @override
  String get propsFieldDirsInside => 'Folders inside';

  @override
  String get propsTypeFolder => 'Folder';

  @override
  String get propsTypeFile => 'File';

  @override
  String propsMultiSelectionTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Elemente ausgewählt',
      one: '1 Element ausgewählt',
    );
    return '$_temp0';
  }

  @override
  String get propsMultiTypeMixed => 'Gemischt (Dateien und Ordner)';

  @override
  String get propsMultiCombinedSize => 'Gesamtgröße auf der Festplatte';

  @override
  String get propsMultiLoadingSizes => 'Größen werden berechnet…';

  @override
  String get propsMultiPerItemTitle => 'Einzelne Elemente';

  @override
  String propsMultiCountSummary(int folderCount, int fileCount) {
    return '$folderCount Ordner, $fileCount Dateien';
  }

  @override
  String get propsEditTooltip => 'Edit';

  @override
  String get propsHintNewValue => 'Enter new value';

  @override
  String get propsPermissionsDialogTitle => 'Edit permissions';

  @override
  String get propsPermOwnerSection => 'Owner:';

  @override
  String get propsPermGroupSection => 'Group:';

  @override
  String get propsPermOtherSection => 'Others:';

  @override
  String get propsInvalidPermissionsFormat => 'Invalid permissions format';

  @override
  String propsChmodFailed(String detail) {
    return 'Could not change permissions: $detail';
  }

  @override
  String get pkgPageTitle => 'Anwendungen';

  @override
  String get pkgInstallFromFileTooltip => 'Install package from file';

  @override
  String get pkgFilterAll => 'Alle';

  @override
  String get pkgSearchHint => 'Anwendungen suchen…';

  @override
  String get pkgUninstallTitle => 'Confirm uninstall';

  @override
  String pkgUninstallConfirm(String name) {
    return 'Uninstall $name?';
  }

  @override
  String get pkgUninstallButton => 'Uninstall';

  @override
  String get pkgDepsTitle => 'Dependencies found';

  @override
  String pkgDepsUsedByBody(String list) {
    return 'This package is used by:\n$list';
  }

  @override
  String get pkgProceedAnyway => 'Proceed anyway';

  @override
  String pkgUninstalled(Object name) {
    return '$name uninstalled';
  }

  @override
  String get pkgUninstallFailed => 'Error during uninstall';

  @override
  String get pkgInstallDialogTitle => 'Install package';

  @override
  String pkgInstallConfirm(String name) {
    return 'Install \"$name\"?';
  }

  @override
  String get pkgInstallButton => 'Install';

  @override
  String get pkgInstallProgressTitle => 'Paket wird installiert';

  @override
  String get pkgInstallRunningStatus => 'Installer wird gestartet…';

  @override
  String get zipProgressPanelTitle => 'ZIP-Komprimierung';

  @override
  String get zipProgressSubtitle => 'Dateien werden dem Archiv hinzugefügt';

  @override
  String get zipProgressEncoding => 'Archiv wird geschrieben…';

  @override
  String pkgExecutableMade(String name) {
    return '$name is now executable';
  }

  @override
  String get pkgUnsupportedPackage => 'Unsupported package format';

  @override
  String pkgInstalledSuccess(String name) {
    return '$name installed successfully';
  }

  @override
  String pkgInstallFailedWithError(String detail) {
    return 'Install error: $detail';
  }

  @override
  String get updateTitle => 'Aktualisierungen';

  @override
  String updateTitleWithCount(int count) {
    return 'Aktualisierungen ($count)';
  }

  @override
  String get updateInstallAll => 'Install all';

  @override
  String get updateNoneAvailable => 'Keine Aktualisierungen verfügbar';

  @override
  String updateTypeLine(String type) {
    return 'Type: $type';
  }

  @override
  String updateCurrentVersionLine(String v) {
    return 'Current version: $v';
  }

  @override
  String updateAvailableVersionLine(String v) {
    return 'Available version: $v';
  }

  @override
  String get updateInstallTooltip => 'Install update';

  @override
  String updateUpdatedSuccess(String name) {
    return '$name updated successfully';
  }

  @override
  String updateOneFailed(String name) {
    return 'Error updating $name';
  }

  @override
  String get updateInstallAllTitle => 'Install all updates';

  @override
  String updateInstallAllBody(int count) {
    return 'Install $count updates?';
  }

  @override
  String get updateAllSuccess => 'All updates installed successfully';

  @override
  String get updateAllFailed => 'Error installing updates';

  @override
  String get searchDialogTitle => 'Dateien finden';

  @override
  String searchPathLabel(String path) {
    return 'Pfad: $path';
  }

  @override
  String get searchSelectDiskTooltip => 'Select drive';

  @override
  String get searchAllMountsLabel => 'Alle gemounteten Laufwerke durchsuchen';

  @override
  String get searchAllMountsHint =>
      'USB, weitere Partitionen, GVFS/Netzwerk (wenn zugänglich). Langsamer als ein einzelner Ordner.';

  @override
  String searchAllMountsActive(int count) {
    return 'Suche in $count Pfaden (alle Mounts)';
  }

  @override
  String get searchPathCurrentMenu => 'Current path';

  @override
  String get searchPathRootMenu => 'Dateisystem-Root';

  @override
  String get searchLabelQuery => 'Search';

  @override
  String get searchHintQuery => 'File name, *.mp4, *.txt…';

  @override
  String get searchHelperPatterns => 'Patterns: *.mp4, *.txt, document*.pdf';

  @override
  String get searchLabelNameFilter => 'Name filter';

  @override
  String get searchHintNameFilter => 'e.g. document';

  @override
  String get searchLabelExtension => 'Extension';

  @override
  String get searchHintExtension => 'e.g. pdf';

  @override
  String get searchLabelSizeMin => 'Min size (bytes)';

  @override
  String get searchLabelSizeMax => 'Max size (bytes)';

  @override
  String get searchLabelFileType => 'File type';

  @override
  String get searchLabelDateFilter => 'Date filter';

  @override
  String get searchIncludeSystemFiles => 'Include system files';

  @override
  String get searchChoosePath => 'Choose path';

  @override
  String get searchStop => 'Stop';

  @override
  String get searchSearchButton => 'Search';

  @override
  String get searchNoCriteriaSnack => 'Mindestens ein Suchkriterium eingeben';

  @override
  String searchError(String error) {
    return 'Suchfehler: $error';
  }

  @override
  String get searchNoResults => 'No results';

  @override
  String get searchResultsOne => '1 result found';

  @override
  String searchResultsMany(int count) {
    return '$count results found';
  }

  @override
  String get searchTooltipViewList => 'Liste';

  @override
  String get searchTooltipViewGrid => 'Raster';

  @override
  String get searchTooltipViewDetails => 'Details';

  @override
  String get searchZoomOut => 'Zoom out';

  @override
  String get searchZoomIn => 'Zoom in';

  @override
  String get searchTypeAll => 'All';

  @override
  String get searchTypeImages => 'Images';

  @override
  String get searchTypeVideo => 'Video';

  @override
  String get searchTypeAudio => 'Audio';

  @override
  String get searchTypeDocuments => 'Documents';

  @override
  String get searchTypeArchives => 'Archives';

  @override
  String get searchTypeExecutables => 'Executables';

  @override
  String get searchDateAll => 'Any time';

  @override
  String get searchDateToday => 'Today';

  @override
  String get searchDateWeek => 'Last week';

  @override
  String get searchDateMonth => 'Last month';

  @override
  String get searchDateYear => 'Last year';

  @override
  String statusDiskPercent(String value) {
    return '$value%';
  }

  @override
  String get depsDialogTitle => 'Systemkomponenten';

  @override
  String get depsDialogIntro =>
      'Folgende Komponenten fehlen. Sie können sie jetzt mit dem Administratorpasswort installieren (PolicyKit).';

  @override
  String get depsInstallButton => 'Jetzt installieren (Admin-Passwort)';

  @override
  String get depsContinueButton => 'Ohne Installation fortfahren';

  @override
  String get depsInstalling => 'Pakete werden installiert…';

  @override
  String get depsInstallSuccess => 'Installation abgeschlossen.';

  @override
  String depsInstallFailed(String message) {
    return 'Installation fehlgeschlagen: $message';
  }

  @override
  String get depsUnknownDistro =>
      'Automatische Installation für diese Distribution nicht verfügbar. Bitte Pakete manuell im Terminal installieren.';

  @override
  String get depsManualCommandLabel => 'Vorgeschlagener Befehl';

  @override
  String get depsPkexecNotFound =>
      'pkexec nicht gefunden. Im Terminal ausführen:';

  @override
  String get depsRustUnavailable =>
      'Native Bibliothek (Rust) nicht geladen. Kopieren kann langsamer sein. App ggf. neu installieren.';

  @override
  String get depLabelXdgOpen =>
      'xdg-open — Dateien mit Standardanwendungen öffnen';

  @override
  String get depLabelMountCifs =>
      'mount.cifs — SMB-Freigaben einbinden (cifs-utils)';

  @override
  String get depsCifsInstallTitle => 'cifs-utils installieren?';

  @override
  String get depsCifsInstallBody =>
      'Zum Einbinden von SMB-Freigaben wird mount.cifs aus dem Paket cifs-utils benötigt. Jetzt mit dem Paketmanager installieren (Administratorpasswort erforderlich)?';

  @override
  String get depLabelSmbclient => 'smbclient — SMB/CIFS-Freigaben durchsuchen';

  @override
  String get depLabelNmblookup => 'nmblookup — Rechner im LAN finden (NetBIOS)';

  @override
  String get depLabelAvahiBrowse => 'avahi-browse — Netzwerkerkennung (mDNS)';

  @override
  String get depLabelAvahiResolve =>
      'avahi-resolve-address — löst Rechnernamen im LAN auf (mDNS)';

  @override
  String get depsNetworkBannerHint =>
      'Optionale Werkzeuge zum Finden von PCs im Netzwerk und zum Einbinden von Freigaben fehlen. Sie können sie automatisch installieren (Administratorpasswort erforderlich).';

  @override
  String get depsNetworkBannerLater => 'Später';

  @override
  String get depsSomeStillMissing =>
      'Einige Werkzeuge fehlen noch. Versuchen Sie den vorgeschlagenen Terminalbefehl unten.';

  @override
  String get depsPolkitAuthFailed =>
      'Administrator-Authentifizierung abgebrochen oder verweigert, oder pkexec konnte den Installer nicht ausführen.';

  @override
  String get depsInstallOutputIntro => 'Ausgabe des Paketmanagers:';

  @override
  String get depsInstallUnexpected => 'unerwarteter Fehler';

  @override
  String get depsDialogIntroRustOnly =>
      'Native Beschleunigung für einige Dateioperationen ist nicht verfügbar (Rust-Bibliothek).';

  @override
  String get depsDialogIntroToolsOk =>
      'Die benötigten Befehlszeilenwerkzeuge sind installiert.';

  @override
  String get depsCloseButton => 'Schließen';

  @override
  String get computerTitle => 'Computer';

  @override
  String get computerOnDevice => 'Auf diesem Gerät';

  @override
  String get computerNetworks => 'Netzwerk';

  @override
  String get computerNoVolumes => 'Keine Datenträger gefunden';

  @override
  String get computerNoServers => 'Keine Server gefunden';

  @override
  String get computerTools => 'Werkzeuge';

  @override
  String get computerToolFindFiles => 'Dateien und Ordner suchen';

  @override
  String get computerToolPackages => 'Apps deinstallieren/installieren';

  @override
  String get computerToolSystemUpdates => 'Nach Systemupdates suchen';

  @override
  String get computerRefresh => 'Aktualisieren';

  @override
  String computerFreeShort(String size) {
    return '$size frei';
  }

  @override
  String computerNetworkHint(String name) {
    return 'Verbinden über die Seitenleiste → Netzwerk: $name';
  }

  @override
  String get computerVolumeOpen => 'Öffnen';

  @override
  String get computerFormatVolume => 'Formatieren…';

  @override
  String get computerFormatTitle => 'Volume formatieren';

  @override
  String get computerFormatWarning =>
      'Alle Daten auf diesem Volume werden gelöscht. Das kann nicht rückgängig gemacht werden.';

  @override
  String get computerFormatFilesystem => 'Dateisystem';

  @override
  String get computerFormatConfirm => 'Formatieren';

  @override
  String get computerFormatNotSupported =>
      'Formatieren wird hier nur unter Linux mit udisks2 unterstützt.';

  @override
  String get computerFormatNoDevice =>
      'Blockgerät für dieses Volume konnte nicht ermittelt werden.';

  @override
  String get computerFormatSystemBlockedTitle => 'Formatieren nicht möglich';

  @override
  String get computerFormatSystemBlockedBody =>
      'Dies ist ein Systemvolume (Root, Boot oder gleiches Laufwerk wie das System). Formatieren ist hier nicht erlaubt.';

  @override
  String get computerFormatRunning => 'Formatierung läuft…';

  @override
  String get computerFormatDone => 'Formatierung abgeschlossen.';

  @override
  String computerFormatFailed(String error) {
    return 'Formatierung fehlgeschlagen: $error';
  }

  @override
  String get computerMounting => 'Verbinden…';

  @override
  String get computerMountNoShares =>
      'Keine Freigaben gefunden. Prüfen Sie Zugangsdaten, Firewall oder SMB.';

  @override
  String get computerMountFailed =>
      'Freigabe konnte nicht eingebunden werden. Andere Zugangsdaten, cifs-utils installieren oder Mount-Berechtigungen prüfen.';

  @override
  String get computerMountMissingGio =>
      'mount.cifs wurde nicht gefunden. Installieren Sie cifs-utils. Root-Rechte oder /etc/fstab-Einträge können nötig sein.';

  @override
  String get computerMountNeedPassword =>
      'Diese Freigabe erfordert Benutzername und Passwort. Verbinden Sie sich erneut und geben Sie Ihre Zugangsdaten ein.';

  @override
  String get networkRememberPassword =>
      'Anmeldedaten für diesen Rechner merken (sichere Speicherung)';

  @override
  String get dialogRootPasswordTitle => 'Administratorpasswort';

  @override
  String get dialogRootPasswordLabel => 'Passwort für sudo';

  @override
  String get computerSelectShare => 'Freigabe wählen';

  @override
  String get computerConnect => 'Verbinden';

  @override
  String get computerCredentialsTitle => 'Netzwerk-Anmeldung';

  @override
  String get computerUsername => 'Benutzername';

  @override
  String get computerPassword => 'Passwort';

  @override
  String get computerDiskProperties => 'Eigenschaften';

  @override
  String get diskPropsOpenInDisks => 'In „Datenträger“ öffnen';

  @override
  String get diskPropsFsUnknown => 'Dateisystem unbekannt';

  @override
  String diskPropsFsLine(String type) {
    return 'Dateisystem $type';
  }

  @override
  String diskPropsTotalLine(String size) {
    return 'Gesamt: $size';
  }

  @override
  String diskPropsUsedLine(String size) {
    return 'Belegt: $size';
  }

  @override
  String diskPropsFreeLine(String size) {
    return 'Frei: $size';
  }

  @override
  String get diskPropsFileAccessRow => 'Dateizugriff';

  @override
  String get snackExternalDropDone => 'Abgelegte Elemente verarbeitet.';

  @override
  String get snackDropUnreadable =>
      'Abgelegte Dateien konnten nicht gelesen werden.';

  @override
  String get snackOpenAsRootLaunched =>
      'Administratorfenster gestartet (separat von diesem).';

  @override
  String computerNetworkIpLine(String ip) {
    return 'IP: $ip';
  }
}
