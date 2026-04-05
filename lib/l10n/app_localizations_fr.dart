// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'SAGE File Manager';

  @override
  String get menuTooltip => 'Menu';

  @override
  String get menuTopFile => 'Fichier';

  @override
  String get menuTopEdit => 'Modifier';

  @override
  String get menuTopView => 'Affichage';

  @override
  String get menuTopFavorites => 'Favoris';

  @override
  String get menuTopThemes => 'Thèmes';

  @override
  String get menuTopTools => 'Outils';

  @override
  String get menuTopHelp => 'Aide';

  @override
  String get menuNewTab => 'Nouvel onglet (F2)';

  @override
  String get menuNewFolder => 'Nouveau dossier';

  @override
  String get menuNewTextFile => 'Nouveau document texte';

  @override
  String get menuNetworkDrive => 'Connecter un lecteur réseau';

  @override
  String get menuBulkRename => 'Renommer';

  @override
  String get menuEmptyTrash => 'Vider la corbeille';

  @override
  String get menuExit => 'Quitter';

  @override
  String get menuCut => 'Couper (Ctrl+X)';

  @override
  String get menuCopy => 'Copier (Ctrl+C)';

  @override
  String get menuPaste => 'Coller (Ctrl+V)';

  @override
  String get menuUndo => 'Annuler (Ctrl+Z)';

  @override
  String get menuRedo => 'Rétablir (Ctrl+Y)';

  @override
  String get menuRefresh => 'Actualiser (F5)';

  @override
  String get menuSelectAll => 'Tout sélectionner';

  @override
  String get menuDeselectAll => 'Tout désélectionner';

  @override
  String get menuFind => 'Rechercher (F1)';

  @override
  String get menuPreferences => 'Préférences';

  @override
  String get snackOneFileCut => '1 élément coupé dans le presse-papiers';

  @override
  String snackManyFilesCut(int count) {
    return '$count éléments coupés dans le presse-papiers';
  }

  @override
  String get snackOneFileCopied => '1 élément copié dans le presse-papiers';

  @override
  String snackManyFilesCopied(int count) {
    return '$count éléments copiés dans le presse-papiers';
  }

  @override
  String get sortArrangeIcons => 'Disposer les icônes';

  @override
  String get sortManual => 'Manuellement';

  @override
  String get sortByName => 'Par nom';

  @override
  String get sortBySize => 'Par taille';

  @override
  String get sortByType => 'Par type';

  @override
  String get sortByDetailedType => 'Par type détaillé';

  @override
  String get sortByDate => 'Par date de modification';

  @override
  String get sortReverse => 'Ordre inverse';

  @override
  String get viewShowHidden => 'Afficher les fichiers cachés';

  @override
  String get viewHideHidden => 'Masquer les fichiers cachés';

  @override
  String get viewSplitScreen => 'Diviser l\'écran (F3)';

  @override
  String get viewShowPreview => 'Afficher l\'aperçu';

  @override
  String get viewHidePreview => 'Masquer l\'aperçu';

  @override
  String get viewShowRightPanel => 'Afficher le panneau droit';

  @override
  String get viewHideRightPanel => 'Masquer le panneau droit';

  @override
  String get favAdd => 'Ajouter aux favoris';

  @override
  String get favManage => 'Gérer les favoris';

  @override
  String get themesManage => 'Gestion des thèmes';

  @override
  String get toolsPackages => 'Désinstaller / installer des applications';

  @override
  String get toolsUpdates => 'Rechercher des mises à jour';

  @override
  String get toolsBulkRenamePattern => 'Renommage groupé (modèle)';

  @override
  String get toolsExtractArchive => 'Extraire l\'archive';

  @override
  String get helpShortcuts => 'Raccourcis clavier';

  @override
  String get helpUserGuide => 'Guide utilisateur';

  @override
  String get helpUserGuideTitle => 'Guide de l\'application';

  @override
  String get helpUserGuideBlock1 =>
      'NAVIGATION\n• Barre latérale : dossier personnel, dossiers standards (Bureau, Documents…), chemins ajoutés, favoris, réseau et disques montés. Glissez les lignes pour réorganiser.\n• Barre d\'outils et barre de chemin : dossier parent, actualiser et recherche globale.\n• Retour arrière : historique. Si activé dans les Préférences, double-clic sur une zone vide remonte au dossier parent.\n• Double-clic sur un dossier pour l\'ouvrir ; double-clic sur un fichier pour l\'ouvrir avec l\'application par défaut.';

  @override
  String get helpUserGuideBlock2 =>
      'FICHIERS ET PRESSE-PAPIERS\n• Clic pour sélectionner ; glisser un rectangle pour plusieurs éléments. Ctrl pour multi-sélection, Maj pour des plages. Échap tout désélectionne.\n• Ctrl+C, Ctrl+X, Ctrl+V copient, coupent et collent. Faites glisser la sélection hors de la fenêtre.\n• Clic droit : menu contextuel (renommer, supprimer, propriétés…). Les menus Fichier et Édition proposent les mêmes actions.';

  @override
  String get helpUserGuideBlock3 =>
      'VUES ET RECHERCHE\n• Menu Affichage : liste, grille ou détails ; fichiers masqués ; double panneau (F3) ; aperçu et panneau droit (F6).\n• F5 actualise le dossier courant. F2 ouvre une nouvelle fenêtre.\n• Outils → Rechercher (F1) ouvre la recherche de fichiers : filtres nom, extension, taille, type et date ; une arborescence ou tous les volumes montés si l\'option est activée.';

  @override
  String get helpUserGuideBlock4 =>
      'RÉGLAGES ET PLUS\n• Favoris et Gestion des thèmes dans le menu du haut (ouvre l\'éditeur de thème). Préférences : clics, langue, menu compact, double panneau et opérations sur fichiers.\n• Poste de travail liste les disques. Ajoutez des chemins réseau depuis la barre latérale ; pour SMB l\'app peut indiquer des dépendances.\n• Outils : recherche de fichiers (F1), gestionnaire de paquets et vérificateur de mises à jour si disponibles.\n• Aide → Raccourcis clavier liste toutes les touches ; ce guide résume l\'essentiel.';

  @override
  String get helpAbout => 'À propos';

  @override
  String get helpGitHubProject => 'Projet GitHub';

  @override
  String get helpDonateNow => 'Faire un don';

  @override
  String get helpCheckAppUpdate =>
      'Vérifier les mises à jour de l\'application';

  @override
  String appUpdateNewVersionAvailable(Object version) {
    return 'La version $version est disponible.';
  }

  @override
  String get appUpdateViewRelease => 'Voir la version';

  @override
  String get appUpdateCheckFailed =>
      'Impossible de vérifier les mises à jour (réseau ou GitHub).';

  @override
  String get appUpdateAlreadyLatest =>
      'Vous utilisez déjà la dernière version.';

  @override
  String get navBack => 'Retour';

  @override
  String get navForward => 'Avancer';

  @override
  String get navUp => 'Remonter';

  @override
  String get prefsGeneral => 'Général';

  @override
  String get prefsSingleClickOpen => 'Clic simple pour ouvrir';

  @override
  String get prefsSingleClickOpenSubtitle =>
      'Ouvrir fichiers et dossiers d\'un clic';

  @override
  String get prefsDoubleClickRename => 'Double-clic pour renommer';

  @override
  String get prefsDoubleClickRenameSubtitle =>
      'Renommer en double-cliquant sur le nom';

  @override
  String get prefsDoubleClickEmptyUp =>
      'Double-clic sur zone vide pour remonter';

  @override
  String get prefsDoubleClickEmptyUpSubtitle =>
      'Aller au dossier parent en double-cliquant sur l\'espace vide';

  @override
  String get prefsLanguage => 'Langue';

  @override
  String get prefsLanguageLabel => 'Langue de l\'interface';

  @override
  String get prefsMenuCompactTitle => 'Menu compact';

  @override
  String get prefsMenuCompactSubtitle =>
      'Regrouper le menu derrière l\'icône à trois lignes';

  @override
  String get smbShellLimitedModeGvfsFallback =>
      'Échec du montage CIFS : dossiers visibles seulement via smbclient. Installez cifs-utils et assurez-vous que mount.cifs est disponible, puis réessayez.';

  @override
  String get smbShellFileOpenUnavailable =>
      'Chemin smbclient seul (sans montage CIFS). Montez le partage avec mount.cifs ou désactivez l’option si le montage CIFS fonctionne.';

  @override
  String get prefsExecTextTitle => 'Fichiers texte exécutables';

  @override
  String get prefsExecAuto => 'Exécuter automatiquement';

  @override
  String get prefsExecAlwaysShow => 'Toujours afficher';

  @override
  String get prefsExecAlwaysAsk => 'Toujours demander';

  @override
  String get prefsDefaultFmTitle => 'Gestionnaire de fichiers par défaut';

  @override
  String get prefsDefaultFmBody =>
      'Définir ce gestionnaire comme application par défaut pour ouvrir les dossiers.';

  @override
  String get prefsDefaultFmButton => 'Définir comme gestionnaire par défaut';

  @override
  String get langItalian => 'Italien';

  @override
  String get langEnglish => 'Anglais';

  @override
  String get langFrench => 'Français';

  @override
  String get langSpanish => 'Espagnol';

  @override
  String get langPortuguese => 'Portugais';

  @override
  String get langGerman => 'Allemand';

  @override
  String get fileListTypeFolder => 'Dossier';

  @override
  String get fileListTypeFile => 'Fichier';

  @override
  String get fileListEmpty => 'Aucun fichier';

  @override
  String get copyProgressTitle => 'Copie en cours';

  @override
  String get copyProgressCancelTooltip => 'Annuler';

  @override
  String copySpeed(String speed) {
    return 'Vitesse : $speed';
  }

  @override
  String copyRemaining(String time) {
    return 'Temps restant : $time';
  }

  @override
  String copyProgressDestLine(String name) {
    return '→ $name';
  }

  @override
  String statusItems(int count) {
    return 'Éléments : $count';
  }

  @override
  String statusFree(String size) {
    return 'Libre : $size';
  }

  @override
  String statusUsed(String size) {
    return 'Utilisé : $size';
  }

  @override
  String statusTotal(String size) {
    return 'Total : $size';
  }

  @override
  String statusCopyLine(String source, String dest) {
    return 'Copie : $source → $dest';
  }

  @override
  String statusCurrentFile(String name) {
    return 'Fichier : $name';
  }

  @override
  String get dialogCloseWhileCopyTitle => 'Opération en cours';

  @override
  String get dialogCloseWhileCopyBody =>
      'Une copie ou un déplacement est en cours. Fermer peut l’interrompre. Continuer ?';

  @override
  String get dialogCancel => 'Annuler';

  @override
  String get dialogOverwriteTitle => 'Remplacer l\'élément existant ?';

  @override
  String dialogOverwriteBody(String name) {
    return '« $name » existe déjà dans ce dossier. Le remplacer ?';
  }

  @override
  String get dialogOverwriteReplace => 'Remplacer';

  @override
  String get dialogOverwriteSkip => 'Ignorer';

  @override
  String get dialogCloseAnyway => 'Fermer quand même';

  @override
  String get commonClose => 'Fermer';

  @override
  String get commonSave => 'Enregistrer';

  @override
  String get commonDelete => 'Supprimer';

  @override
  String get commonRename => 'Renommer';

  @override
  String get commonAdd => 'Ajouter';

  @override
  String commonError(String message) {
    return 'Erreur : $message';
  }

  @override
  String get errorFolderRequiresOpenAsRoot =>
      'Pour ouvrir ce dossier, utilisez « Ouvrir en tant que root ».';

  @override
  String get sidebarAddNetworkTitle => 'Ajouter un emplacement réseau';

  @override
  String get sidebarNetworkPathLabel => 'Chemin réseau';

  @override
  String get sidebarNetworkHint => 'smb://serveur/partage ou //serveur/partage';

  @override
  String get sidebarNetworkHelp =>
      'Exemples :\n• smb://192.168.1.100/partage\n• //serveur/partage\n• /mnt/reseau';

  @override
  String get sidebarBrowseTooltip => 'Parcourir';

  @override
  String get sidebarRenameShareTitle => 'Renommer le partage réseau';

  @override
  String get sidebarRemoveShareTitle => 'Supprimer le partage réseau';

  @override
  String sidebarRemoveShareConfirm(String name) {
    return 'Retirer « $name » de la liste ?';
  }

  @override
  String get sidebarUnmountTitle => 'Démonter le disque';

  @override
  String sidebarUnmountConfirm(String name) {
    return 'Démonter « $name » ?';
  }

  @override
  String get sidebarUnmount => 'Démonter';

  @override
  String sidebarUnmountOk(String name) {
    return '« $name » démonté';
  }

  @override
  String sidebarUnmountFail(String name) {
    return 'Échec du démontage de « $name »';
  }

  @override
  String get sidebarEmptyTrash => 'Vider la corbeille';

  @override
  String get sidebarRemoveFromList => 'Retirer de la liste';

  @override
  String get sidebarMenuChangeColor => 'Changer la couleur';

  @override
  String sidebarChangeColorDialogTitle(String name) {
    return 'Changer la couleur : $name';
  }

  @override
  String get sidebarProperties => 'Propriétés';

  @override
  String sidebarPropertiesFolderTitle(String name) {
    return 'Propriétés : $name';
  }

  @override
  String get sidebarChangeFolderColor => 'Couleur du dossier :';

  @override
  String get sidebarRemoveCustomColor => 'Supprimer la couleur personnalisée';

  @override
  String get sidebarChangeAllFoldersColor => 'Couleur de tous les dossiers';

  @override
  String get sidebarPickDefaultColor =>
      'Choisir une couleur par défaut pour tous les dossiers :';

  @override
  String get sidebarEmptyTrashTitle => 'Vider la corbeille';

  @override
  String get sidebarEmptyTrashBody =>
      'Vider définitivement la corbeille ? Cette action est irréversible.';

  @override
  String get sidebarEmptyTrashConfirm => 'Vider';

  @override
  String get sidebarTrashEmptied => 'Corbeille vidée';

  @override
  String sidebarCredentialsTitle(String server) {
    return 'Identifiants pour $server';
  }

  @override
  String get sidebarGuestAccess => 'Accès invité (anonyme)';

  @override
  String get sidebarConnect => 'Se connecter';

  @override
  String sidebarConnecting(String name) {
    return 'Connexion à $name...';
  }

  @override
  String sidebarConnectionError(String name) {
    return 'Erreur de connexion à $name';
  }

  @override
  String get sidebarRetry => 'Réessayer';

  @override
  String get copyCancelled => 'Copie annulée';

  @override
  String get fileCopiedSuccess => 'Fichier copié';

  @override
  String get folderCopiedSuccess => 'Dossier copié';

  @override
  String get extractionComplete => 'Extraction terminée';

  @override
  String snackInitError(String error) {
    return 'Erreur d\'initialisation : $error';
  }

  @override
  String snackPathRemoved(String name) {
    return 'Retiré de la liste : $name';
  }

  @override
  String get labelChoosePath => 'Choisir un emplacement';

  @override
  String get ctxOpenTerminal => 'Ouvrir le terminal';

  @override
  String get ctxNewFolder => 'Nouveau dossier';

  @override
  String get ctxOpenAsRoot => 'Ouvrir en root';

  @override
  String get ctxOpenWith => 'Ouvrir avec…';

  @override
  String get ctxCopyTo => 'Copier vers…';

  @override
  String get ctxMoveTo => 'Déplacer vers…';

  @override
  String get ctxCopy => 'Copier';

  @override
  String get ctxCut => 'Couper';

  @override
  String get ctxPaste => 'Coller';

  @override
  String get ctxCreateNew => 'Nouveau';

  @override
  String get ctxNewTextDocumentShort => 'Document texte (.txt)';

  @override
  String get ctxNewWordDocument => 'Document Word (.docx)';

  @override
  String get ctxNewExcelSpreadsheet => 'Classeur Excel (.xlsx)';

  @override
  String get ctxExtract => 'Extraire';

  @override
  String get ctxExtractTo => 'Extraire l\'archive vers…';

  @override
  String get ctxCompressToZip => 'Compresser en fichier .zip';

  @override
  String snackZipCreated(Object name) {
    return 'Archive créée : « $name ».';
  }

  @override
  String snackZipFailed(Object message) {
    return 'Impossible de créer le ZIP : $message';
  }

  @override
  String get ctxChangeColor => 'Changer la couleur';

  @override
  String get ctxMoveToTrash => 'Mettre à la corbeille';

  @override
  String get ctxRestoreFromTrash => 'Restaurer dans le dossier d’origine';

  @override
  String get menuRestoreFromTrash => 'Restaurer depuis la corbeille';

  @override
  String get trashRestorePickFolderTitle =>
      'Choisir le dossier de restauration';

  @override
  String trashRestoreTargetExists(String name) {
    return 'Impossible de restaurer : « $name » existe déjà à la destination.';
  }

  @override
  String trashRestoredCount(int count) {
    return '$count éléments restaurés';
  }

  @override
  String get trashRestoreFailed =>
      'Impossible de restaurer les éléments sélectionnés.';

  @override
  String dialogOpenWithTitle(String name) {
    return 'Ouvrir « $name » avec…';
  }

  @override
  String get hintSearchApp => 'Rechercher une application…';

  @override
  String get openWithDefaultApp => 'Application par défaut';

  @override
  String get browseEllipsis => 'Parcourir…';

  @override
  String get tooltipSetAsDefaultApp => 'Définir comme application par défaut';

  @override
  String get openWithOpenAndSetDefault => 'Ouvrir et définir par défaut';

  @override
  String get openWithFooterHint =>
      'Utilisez l’étoile ou le menu ⋮ pour changer l’application par défaut pour ce type de fichier à tout moment.';

  @override
  String snackDefaultAppSet(String appName, String mimeType) {
    return '$appName définie par défaut pour $mimeType';
  }

  @override
  String snackSetDefaultAppError(String error) {
    return 'Impossible de définir le défaut : $error';
  }

  @override
  String snackOpenFileError(String error) {
    return 'Impossible d\'ouvrir : $error';
  }

  @override
  String get dialogTitleCreateFolder => 'Créer un dossier';

  @override
  String get dialogTitleNewFolder => 'Nouveau dossier';

  @override
  String get labelFolderName => 'Nom du dossier';

  @override
  String get hintFolderName => 'Saisir le nom du dossier';

  @override
  String get labelFileName => 'Nom du fichier';

  @override
  String get hintTextDocument => 'document.txt';

  @override
  String get buttonCreate => 'Créer';

  @override
  String snackMoveError(String error) {
    return 'Erreur lors du déplacement : $error';
  }

  @override
  String dialogChangeColorFor(String name) {
    return 'Couleur : $name';
  }

  @override
  String get dialogPickFolderColor =>
      'Choisissez une couleur pour le dossier :';

  @override
  String get shortcutTitle => 'Raccourcis clavier';

  @override
  String get shortcutCopy => 'Copier fichiers/dossiers sélectionnés';

  @override
  String get shortcutPaste => 'Coller fichiers/dossiers';

  @override
  String get shortcutCut => 'Couper fichiers/dossiers sélectionnés';

  @override
  String get shortcutUndo => 'Annuler la dernière opération';

  @override
  String get shortcutRedo => 'Rétablir la dernière opération';

  @override
  String get shortcutNewTab => 'Nouvel onglet';

  @override
  String get shortcutSplitView => 'Diviser l\'écran en deux';

  @override
  String get shortcutRefresh => 'Actualiser le dossier';

  @override
  String get shortcutRightPanel => 'Afficher/masquer le panneau droit';

  @override
  String get shortcutDeselect => 'Tout désélectionner';

  @override
  String get shortcutBackNav => 'Retour dans l\'historique';

  @override
  String get shortcutFindFiles => 'Rechercher fichiers et dossiers';

  @override
  String get aboutTitle => 'À propos';

  @override
  String get aboutAppName => 'Gestionnaire de fichiers';

  @override
  String get aboutTagline => 'Gestionnaire de fichiers avancé';

  @override
  String aboutVersionLabel(String version) {
    return 'Version : $version';
  }

  @override
  String get aboutAuthor => 'Auteur : Marco Di Giangiacomo';

  @override
  String get aboutYear => '© 2026';

  @override
  String get aboutDescriptionHeading => 'Description :';

  @override
  String get aboutDescription =>
      'SAGE File Manager : gestionnaire moderne pour Linux (vues multiples, aperçus, thèmes, recherche, copie optimisée, vue fractionnée, SMB/LAN, etc.).';

  @override
  String get aboutFeaturesHeading => 'Fonctions principales :';

  @override
  String get aboutFeaturesList =>
      '• Gestion complète des fichiers\n• Vues multiples (liste, grille, détails)\n• Aperçu (images, PDF, documents, texte)\n• Gestion des thèmes (préréglages et personnalisation)\n• Recherche avancée\n• Copier/coller optimisé\n• Vue fractionnée\n• Favoris et chemins personnalisés\n• Scripts et exécutables\n• Interface moderne';

  @override
  String snackDocumentCreated(String name) {
    return 'Document « $name » créé';
  }

  @override
  String get dialogInsufficientPermissions => 'Permissions insuffisantes';

  @override
  String get snackFolderCreated => 'Dossier créé';

  @override
  String get snackTerminalUnavailable => 'Terminal indisponible';

  @override
  String get snackTerminalRootError =>
      'Impossible d\'ouvrir le terminal en root';

  @override
  String get snackRootHelperMissing =>
      'Impossible d\'ouvrir en root. Installez pkexec ou sudo.';

  @override
  String get snackOpenAsRootNoFolder =>
      'Ouvrez d\'abord un dossier, puis choisissez Ouvrir en root.';

  @override
  String get snackOpenAsRootBadFolder => 'Impossible d\'ouvrir ce dossier.';

  @override
  String snackPasteItemError(String name, String error) {
    return 'Erreur lors du collage de $name : $error';
  }

  @override
  String get snackFileMoved => 'Fichier déplacé';

  @override
  String get dialogRenameFileTitle => 'Renommer';

  @override
  String dialogRenameManySubtitle(int count) {
    return '$count éléments sélectionnés. Saisissez un nouveau nom pour chaque ligne.';
  }

  @override
  String get labelNewName => 'Nouveau nom';

  @override
  String get snackFileRenamed => 'Fichier renommé';

  @override
  String snackRenameError(String error) {
    return 'Erreur de renommage : $error';
  }

  @override
  String get snackRenameSameFolder =>
      'Tous les éléments sélectionnés doivent être dans le même dossier.';

  @override
  String get snackRenameEmptyName =>
      'Chaque élément doit avoir un nouveau nom non vide.';

  @override
  String get snackRenameDuplicateNames =>
      'Les nouveaux noms doivent être tous différents.';

  @override
  String get snackRenameTargetExists =>
      'Un fichier ou dossier porte déjà ce nom.';

  @override
  String get snackSelectPathFirst => 'Sélectionnez d\'abord un emplacement';

  @override
  String get snackAlreadyFavorite => 'Déjà dans les favoris';

  @override
  String snackAddedFavorite(String name) {
    return 'Ajouté aux favoris : $name';
  }

  @override
  String get favoritesEmptyList => 'Aucun favori';

  @override
  String snackNewTabOpened(String name) {
    return 'Nouvel onglet : $name';
  }

  @override
  String get snackSelectForSymlink =>
      'Sélectionnez un fichier ou dossier pour le raccourci';

  @override
  String get dialogCreateSymlinkTitle => 'Créer un raccourci';

  @override
  String get labelSymlinkName => 'Nom du raccourci';

  @override
  String get snackSymlinkCreated => 'Raccourci créé';

  @override
  String get snackConnectingNetwork => 'Connexion au réseau…';

  @override
  String get snackNewInstanceStarted => 'Nouvelle instance démarrée';

  @override
  String snackNewInstanceError(String error) {
    return 'Impossible de lancer une nouvelle instance : $error';
  }

  @override
  String get snackSelectFilesRename =>
      'Sélectionnez au moins un fichier à renommer';

  @override
  String get bulkRenameTitle => 'Renommage en lot';

  @override
  String bulkRenameSelectedCount(int count) {
    return '$count fichiers sélectionnés';
  }

  @override
  String get bulkRenamePatternLabel => 'Modèle de renommage';

  @override
  String get bulkRenamePatternHelper =>
      'Utilisez les jetons name et num entre accolades (voir l’exemple ci-dessous).';

  @override
  String get bulkRenameAutoNumber => 'Numérotation automatique';

  @override
  String get bulkRenameStartNumber => 'Numéro de départ';

  @override
  String get bulkRenameKeepExt => 'Conserver l\'extension d\'origine';

  @override
  String trashEmptyError(String error) {
    return 'Erreur lors du vidage de la corbeille : $error';
  }

  @override
  String labelNItems(int count) {
    return '$count éléments';
  }

  @override
  String get dialogTitleDeletePermanent => 'Supprimer définitivement ?';

  @override
  String get dialogTitleMoveToTrashConfirm => 'Déplacer vers la corbeille ?';

  @override
  String get dialogBodyPermanentDeleteOne =>
      'Supprimer définitivement un élément ?';

  @override
  String dialogBodyPermanentDeleteMany(int count) {
    return 'Supprimer définitivement $count éléments ?';
  }

  @override
  String get dialogBodyTrashOne => 'Déplacer un élément vers la corbeille ?';

  @override
  String dialogBodyTrashMany(int count) {
    return 'Déplacer $count éléments vers la corbeille ?';
  }

  @override
  String get snackDeletedPermanentOne => 'Un élément supprimé définitivement';

  @override
  String snackDeletedPermanentMany(int count) {
    return '$count éléments supprimés définitivement';
  }

  @override
  String get snackMovedToTrashOne => 'Un élément déplacé vers la corbeille';

  @override
  String snackMovedToTrashMany(int count) {
    return '$count éléments déplacés vers la corbeille';
  }

  @override
  String snackDeleteErrorsSuffix(int errors) {
    return ', $errors erreurs';
  }

  @override
  String get dialogOpenAsRootBody =>
      'Vous n\'avez pas la permission de créer des fichiers ou dossiers ici. Ouvrir le gestionnaire de fichiers en root ?';

  @override
  String get dialogOpenAsRootAuthTitle => 'Ouvrir en tant qu\'administrateur';

  @override
  String get dialogOpenAsRootAuthBody =>
      'Après Continuer, le système demandera le mot de passe administrateur. Ce n\'est qu\'après une authentification réussie qu\'une nouvelle fenêtre du gestionnaire de fichiers s\'ouvrira dans ce dossier.';

  @override
  String get dialogOpenAsRootContinue => 'Continuer';

  @override
  String get paneSelectPathHint => 'Sélectionnez un chemin';

  @override
  String get emptyFolderLabel => 'Dossier vide';

  @override
  String get sidebarMountPointOptional => 'Point de montage (facultatif)';

  @override
  String snackBulkRenameManyDone(int count) {
    return '$count fichiers renommés';
  }

  @override
  String get commonOk => 'OK';

  @override
  String get prefsPageTitle => 'Préférences';

  @override
  String get snackPrefsSaved => 'Préférences enregistrées';

  @override
  String get prefsNavView => 'Affichage';

  @override
  String get prefsNavPreview => 'Aperçu';

  @override
  String get prefsNavFileOps => 'Opérations sur les fichiers';

  @override
  String get prefsNavTrash => 'Corbeille';

  @override
  String get prefsNavMedia => 'Médias amovibles';

  @override
  String get prefsNavCache => 'Cache';

  @override
  String get prefsDefaultFmSuccess =>
      'Gestionnaire de fichiers défini par défaut.';

  @override
  String get prefsShowHiddenTitle => 'Afficher les fichiers cachés';

  @override
  String get prefsShowHiddenSubtitle =>
      'Afficher les fichiers et dossiers dont le nom commence par un point';

  @override
  String get prefsShowPreviewPanelTitle => 'Afficher le panneau d’aperçu';

  @override
  String get prefsShowPreviewPanelSubtitle =>
      'Afficher le panneau d’aperçu à droite';

  @override
  String get prefsAlwaysDoublePaneTitle =>
      'Toujours démarrer avec la vue fractionnée';

  @override
  String get prefsAlwaysDoublePaneSubtitle =>
      'Toujours ouvrir la vue fractionnée au démarrage';

  @override
  String get prefsIgnoreViewPerFolderTitle =>
      'Ignorer les préférences d’affichage par dossier';

  @override
  String get prefsIgnoreViewPerFolderSubtitle =>
      'Ne pas enregistrer les préférences d’affichage pour chaque dossier';

  @override
  String get prefsDefaultViewModeTitle => 'Mode d’affichage par défaut';

  @override
  String get prefsViewModeList => 'Liste';

  @override
  String get prefsViewModeGrid => 'Grille';

  @override
  String get prefsViewModeDetails => 'Détails';

  @override
  String get prefsGridZoomTitle => 'Niveau de zoom de la grille par défaut';

  @override
  String prefsGridZoomLevel(int current) {
    return 'Niveau : $current/10';
  }

  @override
  String get prefsFontSection => 'Police';

  @override
  String get prefsFontFamilyLabel => 'Famille de polices';

  @override
  String get labelSelectFont => 'Choisir la police';

  @override
  String get fontFamilyDefaultSystem => 'Par défaut (système)';

  @override
  String get prefsFontSizeTitle => 'Taille de police';

  @override
  String prefsFontSizeValue(String size) {
    return 'Taille : $size';
  }

  @override
  String get prefsFontWeightTitle => 'Graisse de police';

  @override
  String get prefsFontWeightNormal => 'Normal';

  @override
  String get prefsFontWeightBold => 'Gras';

  @override
  String get prefsFontWeightSemiBold => 'Demi-gras';

  @override
  String get prefsFontWeightMedium => 'Moyen';

  @override
  String get prefsTextShadowSection => 'Ombre du texte';

  @override
  String get prefsTextShadowEnableTitle => 'Activer l’ombre du texte';

  @override
  String get prefsTextShadowEnableSubtitle =>
      'Ajoute une ombre au texte pour la lisibilité';

  @override
  String get prefsShadowIntensityTitle => 'Flou de l’ombre';

  @override
  String get prefsShadowOffsetXTitle => 'Décalage ombre X';

  @override
  String get prefsShadowOffsetYTitle => 'Décalage ombre Y';

  @override
  String get prefsShadowColorTitle => 'Couleur de l’ombre';

  @override
  String prefsShadowColorValue(String value) {
    return 'Couleur : $value';
  }

  @override
  String get prefsShadowColorBlack => 'Noir';

  @override
  String get dialogPickShadowColor => 'Choisir la couleur de l’ombre';

  @override
  String get prefsPickColor => 'Choisir la couleur';

  @override
  String get prefsTextPreviewLabel => 'Aperçu du texte';

  @override
  String get prefsDisableFileQueueTitle => 'Désactiver la file d’opérations';

  @override
  String get prefsDisableFileQueueSubtitle =>
      'Exécuter les opérations séquentiellement sans file';

  @override
  String get prefsAskTrashTitle => 'Demander avant la corbeille';

  @override
  String get prefsAskTrashSubtitle =>
      'Confirmer avant d’envoyer à la corbeille';

  @override
  String get prefsAskEmptyTrashTitle => 'Demander avant de vider la corbeille';

  @override
  String get prefsAskEmptyTrashSubtitle =>
      'Confirmer avant suppression définitive';

  @override
  String get prefsIncludeDeleteTitle => 'Inclure la commande Supprimer';

  @override
  String get prefsIncludeDeleteSubtitle =>
      'Option pour supprimer sans corbeille';

  @override
  String get prefsSkipTrashDelKeyTitle => 'Ignorer la corbeille avec Suppr';

  @override
  String get prefsSkipTrashDelKeySubtitle => 'Supprimer directement avec Suppr';

  @override
  String get prefsAutoMountTitle => 'Monter automatiquement les périphériques';

  @override
  String get prefsAutoMountSubtitle => 'Monter USB et autres à la connexion';

  @override
  String get prefsOpenWindowMountedTitle =>
      'Ouvrir une fenêtre pour les volumes montés';

  @override
  String get prefsOpenWindowMountedSubtitle =>
      'Ouvrir automatiquement une fenêtre';

  @override
  String get prefsWarnRemovableTitle =>
      'Alerter à la connexion d’un périphérique';

  @override
  String get prefsWarnRemovableSubtitle =>
      'Notification pour périphérique amovible';

  @override
  String get prefsPreviewExtensionsIntro =>
      'Extensions pour lesquelles activer l’aperçu :';

  @override
  String get prefsPreviewRightPanelNote =>
      'Les aperçus complets pour PDF, Office, texte et autres types s’affichent dans le panneau latéral droit lorsqu’il est visible. Si la barre latérale est masquée, seules les miniatures d’images apparaissent dans la liste des fichiers.';

  @override
  String get prefsAdminPasswordSection => 'Mot de passe administrateur';

  @override
  String get prefsSaveAdminPasswordTitle => 'Enregistrer le mot de passe admin';

  @override
  String get prefsSaveAdminPasswordSubtitle =>
      'Mot de passe pour les mises à jour (déconseillé)';

  @override
  String get labelAdminPassword => 'Mot de passe administrateur';

  @override
  String get hintAdminPassword => 'Saisir le mot de passe';

  @override
  String get prefsCacheSectionTitle => 'Cache et aperçus';

  @override
  String get prefsCacheSizeTitle => 'Taille du cache';

  @override
  String prefsCacheSizeCurrent(String size) {
    return 'Taille actuelle : $size';
  }

  @override
  String get labelNetworkShareName => 'Nom personnalisé';

  @override
  String get hintNetworkShareName => 'Nom pour ce partage';

  @override
  String get sidebarTooltipRemoveNetwork => 'Retirer le chemin réseau';

  @override
  String get sidebarTooltipUnmount => 'Démonter le disque';

  @override
  String sidebarUnmountSuccess(String name) {
    return '« $name » démonté';
  }

  @override
  String sidebarUnmountError(String name) {
    return 'Erreur lors du démontage de « $name »';
  }

  @override
  String get previewSelectFile => 'Sélectionnez un fichier pour l’aperçu';

  @override
  String get previewPanelTitle => 'Aperçu';

  @override
  String previewPanelSizeLine(String value) {
    return 'Taille : $value';
  }

  @override
  String previewPanelModifiedLine(String value) {
    return 'Modifié : $value';
  }

  @override
  String get dialogErrorTitle => 'Erreur';

  @override
  String get propsLoadError => 'Impossible de charger les propriétés';

  @override
  String get snackPermissionsUpdated => 'Permissions mises à jour';

  @override
  String dialogEditFieldTitle(String label) {
    return 'Modifier $label';
  }

  @override
  String snackFieldUpdated(String label) {
    return '$label mis à jour';
  }

  @override
  String get propsEditPermissionsTitle => 'Modifier les permissions';

  @override
  String get permOwner => 'Propriétaire :';

  @override
  String get permGroup => 'Groupe :';

  @override
  String get permOthers => 'Autres :';

  @override
  String get permRead => 'Lecture';

  @override
  String get permWrite => 'Écriture';

  @override
  String get permExecute => 'Exécution';

  @override
  String get previewNotAvailable => 'Aperçu indisponible';

  @override
  String get previewImageError => 'Erreur de chargement de l’image';

  @override
  String get previewDocLoadError => 'Erreur de chargement du document';

  @override
  String get previewOpenExternally => 'Ouvrir avec un lecteur externe';

  @override
  String get previewDocumentTitle => 'Aperçu du document';

  @override
  String get previewDocLegacyFormat =>
      'Le .doc n’est pas pris en charge. Utilisez .docx ou un lecteur externe.';

  @override
  String get previewSheetLoadError => 'Erreur de chargement de la feuille';

  @override
  String get previewSheetTitle => 'Aperçu de la feuille de calcul';

  @override
  String get previewXlsLegacyFormat =>
      'Le .xls n’est pas pris en charge. Utilisez .xlsx ou un lecteur externe.';

  @override
  String get previewPresentationLoadError =>
      'Erreur de chargement de la présentation';

  @override
  String get previewOpenOfficeTitle => 'Aperçu OpenOffice';

  @override
  String get previewOpenOfficeBody =>
      'Les fichiers OpenOffice nécessitent un lecteur externe.';

  @override
  String themeApplied(String name) {
    return 'Thème « $name » appliqué';
  }

  @override
  String get themeDark => 'Thème sombre';

  @override
  String themeFontSizeTitle(String size) {
    return 'Taille de police : $size';
  }

  @override
  String get themeFontWeightSection => 'Graisse de police';

  @override
  String get themeBoldLabel => 'Gras';

  @override
  String get themeTextShadowSection => 'Ombre du texte';

  @override
  String themeShadowIntensity(String percent) {
    return 'Intensité de l’ombre : $percent %';
  }

  @override
  String get themeColorPicked => 'Couleur sélectionnée';

  @override
  String get themeSelectToCustomize => 'Sélectionnez un thème à personnaliser';

  @override
  String get themeFontFamilySection => 'Famille de polices';

  @override
  String get searchNeedCriterion => 'Saisissez au moins un critère';

  @override
  String get searchCurrentPath => 'Chemin actuel';

  @override
  String get searchButton => 'Rechercher';

  @override
  String get pkgConfirmUninstallTitle => 'Confirmer la désinstallation';

  @override
  String pkgConfirmUninstallBody(String name) {
    return 'Désinstaller $name ?';
  }

  @override
  String get pkgDependenciesTitle => 'Dépendances trouvées';

  @override
  String get pkgUninstallError => 'Erreur lors de la désinstallation';

  @override
  String get pkgManagerTitle => 'Gestionnaire d’applications';

  @override
  String get pkgInstallTitle => 'Installer le paquet';

  @override
  String pkgInstallBody(String name) {
    return 'Installer « $name » ?';
  }

  @override
  String pkgMadeExecutable(String name) {
    return '$name rendu exécutable';
  }

  @override
  String get pkgUnsupportedFormat => 'Format de paquet non pris en charge';

  @override
  String pkgInstallErrorOutput(String output) {
    return 'Erreur d’installation : $output';
  }

  @override
  String updateItemSuccess(String name) {
    return '$name mis à jour';
  }

  @override
  String updateItemError(String name) {
    return 'Erreur lors de la mise à jour de $name';
  }

  @override
  String get updateAllError => 'Erreur lors des mises à jour';

  @override
  String get updateInstallAllButton => 'Tout installer';

  @override
  String get previewCatImages => 'Images';

  @override
  String get previewCatDocuments => 'Documents';

  @override
  String get previewCatText => 'Texte';

  @override
  String get previewCatWeb => 'Web';

  @override
  String get previewCatOffice => 'Bureautique';

  @override
  String previewExtTitle(String ext, String name) {
    return '.$ext — $name';
  }

  @override
  String bulkRenamePatternExample(String a, String b) {
    return '$a, ${a}_$b, Document_$b';
  }

  @override
  String get tableColumnName => 'Nom';

  @override
  String get tableColumnPath => 'Chemin';

  @override
  String get tableColumnSize => 'Taille';

  @override
  String get tableColumnModified => 'Modifié';

  @override
  String get tableColumnType => 'Type';

  @override
  String get networkBrowserTitle => 'Parcourir le réseau';

  @override
  String get networkSearchingServers => 'Recherche de serveurs…';

  @override
  String get networkNoServersFound => 'Aucun serveur trouvé';

  @override
  String get networkServersSharesHeader => 'Serveurs et partages';

  @override
  String get labelUsername => 'Nom d’utilisateur';

  @override
  String get labelPassword => 'Mot de passe';

  @override
  String get networkRefreshTooltip => 'Actualiser';

  @override
  String get networkNoSharesAvailable => 'Aucun partage disponible';

  @override
  String get networkInfoTitle => 'Informations';

  @override
  String networkServersFoundCount(int count) {
    return 'Serveurs trouvés : $count';
  }

  @override
  String get networkConnectShareInstructions =>
      'Pour vous connecter à un partage, développez un serveur et appuyez sur le partage souhaité.';

  @override
  String get networkSelectedServerLabel => 'Serveur sélectionné :';

  @override
  String networkSharesCount(int count) {
    return 'Partages : $count';
  }

  @override
  String get sidebarTooltipBrowseNetworkPaths => 'Parcourir les chemins réseau';

  @override
  String get sidebarTooltipAddNetworkPath => 'Ajouter un chemin réseau';

  @override
  String get sidebarSectionNetwork => 'Réseau';

  @override
  String get sidebarSectionDisks => 'Disques';

  @override
  String get sidebarAddPath => 'Ajouter un chemin';

  @override
  String get sidebarUserFolderHome => 'Dossier personnel';

  @override
  String get sidebarUserFolderDesktop => 'Bureau';

  @override
  String get sidebarUserFolderDocuments => 'Documents';

  @override
  String get sidebarUserFolderPictures => 'Images';

  @override
  String get sidebarUserFolderMusic => 'Musique';

  @override
  String get sidebarUserFolderVideos => 'Vidéos';

  @override
  String get sidebarUserFolderDownloads => 'Téléchargements';

  @override
  String get sidebarSectionFavorites => 'Favoris';

  @override
  String get commonUnknown => 'Inconnu';

  @override
  String get prefsClearCacheButton => 'Vider le cache';

  @override
  String get prefsClearCacheTitle => 'Vider le cache';

  @override
  String get prefsClearCacheBody =>
      'Vider tout le cache des miniatures d’aperçu ?';

  @override
  String get prefsClearCacheConfirm => 'Vider';

  @override
  String get snackPrefsCacheCleared => 'Cache vidée';

  @override
  String get previewFmtJpeg => 'Image JPEG';

  @override
  String get previewFmtPng => 'Image PNG';

  @override
  String get previewFmtGif => 'Image GIF';

  @override
  String get previewFmtBmp => 'Image BMP';

  @override
  String get previewFmtWebp => 'Image WebP';

  @override
  String get previewFmtPdf => 'Document PDF';

  @override
  String get previewFmtPlainText => 'Fichier texte';

  @override
  String get previewFmtMarkdown => 'Markdown';

  @override
  String get previewFmtNfo => 'Fichier info';

  @override
  String get previewFmtShell => 'Script shell';

  @override
  String get previewFmtHtml => 'Document HTML';

  @override
  String get previewFmtDocx => 'Document Word';

  @override
  String get previewFmtXlsx => 'Classeur Excel';

  @override
  String get previewFmtPptx => 'Présentation PowerPoint';

  @override
  String themeAppliedSnackbar(String name) {
    return 'Thème « $name » appliqué';
  }

  @override
  String get themeEditTitle => 'Modifier le thème';

  @override
  String get themeNewTitle => 'Nouveau thème';

  @override
  String get themeFieldName => 'Nom du thème';

  @override
  String get themeDarkThemeSwitch => 'Thème sombre';

  @override
  String get themeColorPrimary => 'Couleur primaire';

  @override
  String get themeColorSecondary => 'Couleur secondaire';

  @override
  String get themeColorFile => 'Couleur des fichiers';

  @override
  String get themeColorLocation => 'Couleur de la barre d’emplacement';

  @override
  String get themeColorBackground => 'Couleur d’arrière-plan';

  @override
  String get themeColorFolder => 'Couleur des dossiers';

  @override
  String get themeFolderIconsHint =>
      'Les icônes s’appliquent automatiquement selon le type de dossier.';

  @override
  String get themeFolderIconPickColor =>
      'Choisir une couleur pour les icônes de dossiers';

  @override
  String get themeColorPickedSnack => 'Couleur sélectionnée';

  @override
  String get themeManagerTitle => 'Gestion des thèmes';

  @override
  String get themeBuiltinHeader => 'Thèmes intégrés';

  @override
  String get themeCustomHeader => 'Thèmes personnalisés';

  @override
  String get themeCustomizationHeader => 'Personnalisation';

  @override
  String get themeSelectPrompt => 'Sélectionnez un thème à personnaliser';

  @override
  String get themeVariantLight => 'Clair';

  @override
  String get themeVariantDark => 'Sombre';

  @override
  String get themeColorsHeader => 'Couleurs';

  @override
  String get themeFontHeader => 'Police';

  @override
  String get themeFontFamilyRow => 'Famille de police';

  @override
  String themeFontSizeRow(String size) {
    return 'Taille de police : $size';
  }

  @override
  String get themeFontWeightHeader => 'Graisse de police';

  @override
  String get themeTextShadow => 'Ombre du texte';

  @override
  String get themeIconShadowTitle => 'Ombre des icônes (grille)';

  @override
  String get themeIconShadowSubtitle =>
      'Ombre portée sous les icônes de fichiers et dossiers en vue grille';

  @override
  String themeIconShadowIntensity(String percent) {
    return 'Intensité ombre icônes : $percent %';
  }

  @override
  String themeShadowIntensityRow(String percent) {
    return 'Intensité de l’ombre : $percent %';
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
  String get propsTitle => 'Propriétés';

  @override
  String get propsTimeoutLoading =>
      'Délai dépassé lors du chargement des propriétés';

  @override
  String propsLoadErrorDetail(String detail) {
    return 'Erreur de chargement des propriétés : $detail';
  }

  @override
  String get propsFieldName => 'Nom';

  @override
  String get propsFieldPath => 'Chemin';

  @override
  String get propsFieldType => 'Type';

  @override
  String get propsFieldSize => 'Taille';

  @override
  String get propsFieldSizeOnDisk => 'Taille sur disque';

  @override
  String get propsFieldModified => 'Modifié';

  @override
  String get propsFieldAccessed => 'Accès';

  @override
  String get propsFieldCreated => 'Créé';

  @override
  String get propsFieldOwner => 'Propriétaire';

  @override
  String get propsFieldGroup => 'Groupe';

  @override
  String get propsFieldPermissions => 'Permissions';

  @override
  String get propsFieldInode => 'Inode';

  @override
  String get propsFieldLinks => 'Liens';

  @override
  String get propsFieldFilesInside => 'Fichiers contenus';

  @override
  String get propsFieldDirsInside => 'Dossiers contenus';

  @override
  String get propsTypeFolder => 'Dossier';

  @override
  String get propsTypeFile => 'Fichier';

  @override
  String propsMultiSelectionTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count éléments sélectionnés',
      one: '1 élément sélectionné',
    );
    return '$_temp0';
  }

  @override
  String get propsMultiTypeMixed => 'Sélection mixte (fichiers et dossiers)';

  @override
  String get propsMultiCombinedSize => 'Taille totale sur disque';

  @override
  String get propsMultiLoadingSizes => 'Calcul des tailles…';

  @override
  String get propsMultiPerItemTitle => 'Chaque élément';

  @override
  String propsMultiCountSummary(int folderCount, int fileCount) {
    return '$folderCount dossiers, $fileCount fichiers';
  }

  @override
  String get propsEditTooltip => 'Modifier';

  @override
  String get propsHintNewValue => 'Saisir une nouvelle valeur';

  @override
  String get propsPermissionsDialogTitle => 'Modifier les permissions';

  @override
  String get propsPermOwnerSection => 'Propriétaire :';

  @override
  String get propsPermGroupSection => 'Groupe :';

  @override
  String get propsPermOtherSection => 'Autres :';

  @override
  String get propsInvalidPermissionsFormat => 'Format de permissions invalide';

  @override
  String propsChmodFailed(String detail) {
    return 'Impossible de modifier les permissions : $detail';
  }

  @override
  String get pkgPageTitle => 'Applications';

  @override
  String get pkgInstallFromFileTooltip =>
      'Installer un paquet depuis un fichier';

  @override
  String get pkgFilterAll => 'Toutes';

  @override
  String get pkgSearchHint => 'Rechercher des applications…';

  @override
  String get pkgUninstallTitle => 'Confirmer la désinstallation';

  @override
  String pkgUninstallConfirm(String name) {
    return 'Désinstaller $name ?';
  }

  @override
  String get pkgUninstallButton => 'Désinstaller';

  @override
  String get pkgDepsTitle => 'Dépendances détectées';

  @override
  String pkgDepsUsedByBody(String list) {
    return 'Ce paquet est utilisé par :\n$list';
  }

  @override
  String get pkgProceedAnyway => 'Continuer quand même';

  @override
  String pkgUninstalled(Object name) {
    return '$name désinstallé';
  }

  @override
  String get pkgUninstallFailed => 'Erreur lors de la désinstallation';

  @override
  String get pkgInstallDialogTitle => 'Installer le paquet';

  @override
  String pkgInstallConfirm(String name) {
    return 'Installer « $name » ?';
  }

  @override
  String get pkgInstallButton => 'Installer';

  @override
  String get pkgInstallProgressTitle => 'Installation du paquet';

  @override
  String get pkgInstallRunningStatus => 'Démarrage de l’installateur…';

  @override
  String get zipProgressPanelTitle => 'Compression ZIP';

  @override
  String get zipProgressSubtitle => 'Ajout des fichiers à l’archive';

  @override
  String get zipProgressEncoding => 'Écriture de l’archive…';

  @override
  String pkgExecutableMade(String name) {
    return '$name est maintenant exécutable';
  }

  @override
  String get pkgUnsupportedPackage => 'Format de paquet non pris en charge';

  @override
  String pkgInstalledSuccess(String name) {
    return '$name installé avec succès';
  }

  @override
  String pkgInstallFailedWithError(String detail) {
    return 'Erreur d’installation : $detail';
  }

  @override
  String get updateTitle => 'Mises à jour';

  @override
  String updateTitleWithCount(int count) {
    return 'Mises à jour ($count)';
  }

  @override
  String get updateInstallAll => 'Tout installer';

  @override
  String get updateNoneAvailable => 'Aucune mise à jour disponible';

  @override
  String updateTypeLine(String type) {
    return 'Type : $type';
  }

  @override
  String updateCurrentVersionLine(String v) {
    return 'Version actuelle : $v';
  }

  @override
  String updateAvailableVersionLine(String v) {
    return 'Version disponible : $v';
  }

  @override
  String get updateInstallTooltip => 'Installer la mise à jour';

  @override
  String updateUpdatedSuccess(String name) {
    return '$name mis à jour avec succès';
  }

  @override
  String updateOneFailed(String name) {
    return 'Erreur lors de la mise à jour de $name';
  }

  @override
  String get updateInstallAllTitle => 'Installer toutes les mises à jour';

  @override
  String updateInstallAllBody(int count) {
    return 'Installer $count mises à jour ?';
  }

  @override
  String get updateAllSuccess => 'Toutes les mises à jour ont été installées';

  @override
  String get updateAllFailed =>
      'Erreur lors de l’installation des mises à jour';

  @override
  String get searchDialogTitle => 'Rechercher des fichiers';

  @override
  String searchPathLabel(String path) {
    return 'Chemin : $path';
  }

  @override
  String get searchSelectDiskTooltip => 'Sélectionner le lecteur';

  @override
  String get searchAllMountsLabel => 'Rechercher sur tous les volumes montés';

  @override
  String get searchAllMountsHint =>
      'Clés USB, partitions supplémentaires, GVFS/réseau (si accessible). Plus lent qu’un seul dossier.';

  @override
  String searchAllMountsActive(int count) {
    return 'Recherche dans $count emplacements (tous les montages)';
  }

  @override
  String get searchPathCurrentMenu => 'Chemin actuel';

  @override
  String get searchPathRootMenu => 'Racine du système de fichiers';

  @override
  String get searchLabelQuery => 'Rechercher';

  @override
  String get searchHintQuery => 'Nom de fichier, *.mp4, *.txt…';

  @override
  String get searchHelperPatterns => 'Motifs : *.mp4, *.txt, document*.pdf';

  @override
  String get searchLabelNameFilter => 'Filtre nom';

  @override
  String get searchHintNameFilter => 'ex. : document';

  @override
  String get searchLabelExtension => 'Extension';

  @override
  String get searchHintExtension => 'ex. : pdf';

  @override
  String get searchLabelSizeMin => 'Taille min (octets)';

  @override
  String get searchLabelSizeMax => 'Taille max (octets)';

  @override
  String get searchLabelFileType => 'Type de fichier';

  @override
  String get searchLabelDateFilter => 'Filtre de date';

  @override
  String get searchIncludeSystemFiles => 'Inclure les fichiers système';

  @override
  String get searchChoosePath => 'Choisir le chemin';

  @override
  String get searchStop => 'Arrêter';

  @override
  String get searchSearchButton => 'Rechercher';

  @override
  String get searchNoCriteriaSnack =>
      'Saisissez au moins un critère de recherche';

  @override
  String searchError(String error) {
    return 'Erreur de recherche : $error';
  }

  @override
  String get searchNoResults => 'Aucun résultat';

  @override
  String get searchResultsOne => '1 résultat trouvé';

  @override
  String searchResultsMany(int count) {
    return '$count résultats trouvés';
  }

  @override
  String get searchTooltipViewList => 'Liste';

  @override
  String get searchTooltipViewGrid => 'Grille';

  @override
  String get searchTooltipViewDetails => 'Détails';

  @override
  String get searchZoomOut => 'Zoom arrière';

  @override
  String get searchZoomIn => 'Zoom avant';

  @override
  String get searchTypeAll => 'Tous';

  @override
  String get searchTypeImages => 'Images';

  @override
  String get searchTypeVideo => 'Vidéo';

  @override
  String get searchTypeAudio => 'Audio';

  @override
  String get searchTypeDocuments => 'Documents';

  @override
  String get searchTypeArchives => 'Archives';

  @override
  String get searchTypeExecutables => 'Exécutables';

  @override
  String get searchDateAll => 'Tout';

  @override
  String get searchDateToday => 'Aujourd’hui';

  @override
  String get searchDateWeek => '7 derniers jours';

  @override
  String get searchDateMonth => '30 derniers jours';

  @override
  String get searchDateYear => '12 derniers mois';

  @override
  String statusDiskPercent(String value) {
    return '$value%';
  }

  @override
  String get depsDialogTitle => 'Composants système';

  @override
  String get depsDialogIntro =>
      'Les composants suivants sont absents. Installez-les pour un fonctionnement optimal (mot de passe administrateur via PolicyKit).';

  @override
  String get depsInstallButton => 'Installer maintenant (mot de passe admin)';

  @override
  String get depsContinueButton => 'Continuer sans installer';

  @override
  String get depsInstalling => 'Installation des paquets…';

  @override
  String get depsInstallSuccess => 'Installation terminée.';

  @override
  String depsInstallFailed(String message) {
    return 'Échec de l\'installation : $message';
  }

  @override
  String get depsUnknownDistro =>
      'Installation automatique indisponible pour cette distribution. Installez les paquets manuellement dans un terminal.';

  @override
  String get depsManualCommandLabel => 'Commande suggérée';

  @override
  String get depsPkexecNotFound =>
      'pkexec introuvable. Exécutez dans un terminal :';

  @override
  String get depsRustUnavailable =>
      'Bibliothèque native (Rust) non chargée. La copie peut être plus lente. Réinstallez l\'application si nécessaire.';

  @override
  String get depLabelXdgOpen =>
      'xdg-open — ouvrir les fichiers avec les applications par défaut';

  @override
  String get depLabelMountCifs =>
      'mount.cifs — monter les partages SMB (cifs-utils)';

  @override
  String get depsCifsInstallTitle => 'Installer cifs-utils ?';

  @override
  String get depsCifsInstallBody =>
      'Le montage des partages SMB nécessite mount.cifs (paquet cifs-utils). L’installer maintenant avec le gestionnaire de paquets (mot de passe administrateur requis) ?';

  @override
  String get depLabelSmbclient => 'smbclient — parcourir les partages SMB/CIFS';

  @override
  String get depLabelNmblookup =>
      'nmblookup — trouver des ordinateurs sur le LAN (NetBIOS)';

  @override
  String get depLabelAvahiBrowse => 'avahi-browse — découverte réseau (mDNS)';

  @override
  String get depLabelAvahiResolve =>
      'avahi-resolve-address — résolution des noms d’hôte sur le LAN (mDNS)';

  @override
  String get depsNetworkBannerHint =>
      'Des outils optionnels pour trouver des PC sur le réseau et monter des partages sont absents. Vous pouvez les installer automatiquement (mot de passe administrateur requis).';

  @override
  String get depsNetworkBannerLater => 'Plus tard';

  @override
  String get depsSomeStillMissing =>
      'Certains outils manquent encore. Essayez la commande terminal suggérée ci-dessous.';

  @override
  String get depsPolkitAuthFailed =>
      'Authentification administrateur annulée, refusée, ou pkexec n\'a pas pu lancer l\'installateur.';

  @override
  String get depsInstallOutputIntro => 'Sortie du gestionnaire de paquets :';

  @override
  String get depsInstallUnexpected => 'erreur inattendue';

  @override
  String get depsDialogIntroRustOnly =>
      'L\'accélération native pour certaines opérations sur les fichiers n\'est pas disponible (bibliothèque Rust).';

  @override
  String get depsDialogIntroToolsOk =>
      'Les utilitaires en ligne de commande requis sont installés.';

  @override
  String get depsCloseButton => 'Fermer';

  @override
  String get computerTitle => 'Ordinateur';

  @override
  String get computerOnDevice => 'Sur cet appareil';

  @override
  String get computerNetworks => 'Réseau';

  @override
  String get computerNoVolumes => 'Aucun volume trouvé';

  @override
  String get computerNoServers => 'Aucun serveur détecté';

  @override
  String get computerTools => 'Outils';

  @override
  String get computerToolFindFiles => 'Rechercher des fichiers et dossiers';

  @override
  String get computerToolPackages => 'Désinstaller/Installer des apps';

  @override
  String get computerToolSystemUpdates => 'Rechercher des mises à jour système';

  @override
  String get computerRefresh => 'Actualiser';

  @override
  String computerFreeShort(String size) {
    return '$size libres';
  }

  @override
  String computerNetworkHint(String name) {
    return 'Connectez-vous via la barre latérale → Réseau : $name';
  }

  @override
  String get computerVolumeOpen => 'Ouvrir';

  @override
  String get computerFormatVolume => 'Formater…';

  @override
  String get computerFormatTitle => 'Formater le volume';

  @override
  String get computerFormatWarning =>
      'Toutes les données de ce volume seront effacées. Action irréversible.';

  @override
  String get computerFormatFilesystem => 'Système de fichiers';

  @override
  String get computerFormatConfirm => 'Formater';

  @override
  String get computerFormatNotSupported =>
      'Le formatage depuis cet écran n’est pris en charge que sous Linux avec udisks2.';

  @override
  String get computerFormatNoDevice =>
      'Impossible de déterminer le périphérique bloc.';

  @override
  String get computerFormatSystemBlockedTitle => 'Formatage impossible';

  @override
  String get computerFormatSystemBlockedBody =>
      'Volume système (racine, démarrage ou même disque que le système). Le formatage n’est pas autorisé ici.';

  @override
  String get computerFormatRunning => 'Formatage…';

  @override
  String get computerFormatDone => 'Formatage terminé.';

  @override
  String computerFormatFailed(String error) {
    return 'Échec du formatage : $error';
  }

  @override
  String get computerMounting => 'Connexion…';

  @override
  String get computerMountNoShares =>
      'Aucun partage trouvé. Vérifiez identifiants, pare-feu ou SMB.';

  @override
  String get computerMountFailed =>
      'Impossible de monter le partage. Essayez d’autres identifiants, installez cifs-utils ou vérifiez les permissions de montage.';

  @override
  String get computerMountMissingGio =>
      'mount.cifs est introuvable. Installez cifs-utils. Des droits root ou des entrées /etc/fstab peuvent être nécessaires.';

  @override
  String get computerMountNeedPassword =>
      'Ce partage nécessite un identifiant et un mot de passe. Reconnectez-vous et saisissez vos identifiants.';

  @override
  String get networkRememberPassword =>
      'Mémoriser les identifiants pour cet ordinateur (stockage sécurisé)';

  @override
  String get dialogRootPasswordTitle => 'Mot de passe administrateur';

  @override
  String get dialogRootPasswordLabel => 'Mot de passe pour sudo';

  @override
  String get computerSelectShare => 'Choisir un partage';

  @override
  String get computerConnect => 'Se connecter';

  @override
  String get computerCredentialsTitle => 'Connexion réseau';

  @override
  String get computerUsername => 'Nom d’utilisateur';

  @override
  String get computerPassword => 'Mot de passe';

  @override
  String get computerDiskProperties => 'Propriétés';

  @override
  String get diskPropsOpenInDisks => 'Ouvrir dans Disques';

  @override
  String get diskPropsFsUnknown => 'Système de fichiers inconnu';

  @override
  String diskPropsFsLine(String type) {
    return 'Système de fichiers $type';
  }

  @override
  String diskPropsTotalLine(String size) {
    return 'Total : $size';
  }

  @override
  String diskPropsUsedLine(String size) {
    return 'Utilisé : $size';
  }

  @override
  String diskPropsFreeLine(String size) {
    return 'Libre : $size';
  }

  @override
  String get diskPropsFileAccessRow => 'Accès aux fichiers';

  @override
  String get snackExternalDropDone =>
      'Opération sur les éléments déposés terminée.';

  @override
  String get snackDropUnreadable => 'Impossible de lire les fichiers déposés.';

  @override
  String get snackOpenAsRootLaunched =>
      'Fenêtre administrateur lancée (séparée de celle-ci).';

  @override
  String computerNetworkIpLine(String ip) {
    return 'IP : $ip';
  }
}
