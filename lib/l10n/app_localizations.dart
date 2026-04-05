import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_it.dart';
import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('it'),
    Locale('pt'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'SAGE File Manager'**
  String get appTitle;

  /// No description provided for @menuTooltip.
  ///
  /// In en, this message translates to:
  /// **'Menu'**
  String get menuTooltip;

  /// No description provided for @menuTopFile.
  ///
  /// In en, this message translates to:
  /// **'File'**
  String get menuTopFile;

  /// No description provided for @menuTopEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get menuTopEdit;

  /// No description provided for @menuTopView.
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get menuTopView;

  /// No description provided for @menuTopFavorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get menuTopFavorites;

  /// No description provided for @menuTopThemes.
  ///
  /// In en, this message translates to:
  /// **'Themes'**
  String get menuTopThemes;

  /// No description provided for @menuTopTools.
  ///
  /// In en, this message translates to:
  /// **'Tools'**
  String get menuTopTools;

  /// No description provided for @menuTopHelp.
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get menuTopHelp;

  /// No description provided for @menuNewTab.
  ///
  /// In en, this message translates to:
  /// **'Open new tab (F2)'**
  String get menuNewTab;

  /// No description provided for @menuNewFolder.
  ///
  /// In en, this message translates to:
  /// **'New folder'**
  String get menuNewFolder;

  /// No description provided for @menuNewTextFile.
  ///
  /// In en, this message translates to:
  /// **'New text document'**
  String get menuNewTextFile;

  /// No description provided for @menuNetworkDrive.
  ///
  /// In en, this message translates to:
  /// **'Connect network drive'**
  String get menuNetworkDrive;

  /// No description provided for @menuBulkRename.
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get menuBulkRename;

  /// No description provided for @menuEmptyTrash.
  ///
  /// In en, this message translates to:
  /// **'Empty trash'**
  String get menuEmptyTrash;

  /// No description provided for @menuExit.
  ///
  /// In en, this message translates to:
  /// **'Exit'**
  String get menuExit;

  /// No description provided for @menuCut.
  ///
  /// In en, this message translates to:
  /// **'Cut (Ctrl+X)'**
  String get menuCut;

  /// No description provided for @menuCopy.
  ///
  /// In en, this message translates to:
  /// **'Copy (Ctrl+C)'**
  String get menuCopy;

  /// No description provided for @menuPaste.
  ///
  /// In en, this message translates to:
  /// **'Paste (Ctrl+V)'**
  String get menuPaste;

  /// No description provided for @menuUndo.
  ///
  /// In en, this message translates to:
  /// **'Undo (Ctrl+Z)'**
  String get menuUndo;

  /// No description provided for @menuRedo.
  ///
  /// In en, this message translates to:
  /// **'Redo (Ctrl+Y)'**
  String get menuRedo;

  /// No description provided for @menuRefresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh (F5)'**
  String get menuRefresh;

  /// No description provided for @menuSelectAll.
  ///
  /// In en, this message translates to:
  /// **'Select all'**
  String get menuSelectAll;

  /// No description provided for @menuDeselectAll.
  ///
  /// In en, this message translates to:
  /// **'Deselect all'**
  String get menuDeselectAll;

  /// No description provided for @menuFind.
  ///
  /// In en, this message translates to:
  /// **'Find (F1)'**
  String get menuFind;

  /// No description provided for @menuPreferences.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get menuPreferences;

  /// No description provided for @snackOneFileCut.
  ///
  /// In en, this message translates to:
  /// **'1 item cut to clipboard'**
  String get snackOneFileCut;

  /// No description provided for @snackManyFilesCut.
  ///
  /// In en, this message translates to:
  /// **'{count} items cut to clipboard'**
  String snackManyFilesCut(int count);

  /// No description provided for @snackOneFileCopied.
  ///
  /// In en, this message translates to:
  /// **'1 item copied to clipboard'**
  String get snackOneFileCopied;

  /// No description provided for @snackManyFilesCopied.
  ///
  /// In en, this message translates to:
  /// **'{count} items copied to clipboard'**
  String snackManyFilesCopied(int count);

  /// No description provided for @sortArrangeIcons.
  ///
  /// In en, this message translates to:
  /// **'Arrange icons'**
  String get sortArrangeIcons;

  /// No description provided for @sortManual.
  ///
  /// In en, this message translates to:
  /// **'Manually'**
  String get sortManual;

  /// No description provided for @sortByName.
  ///
  /// In en, this message translates to:
  /// **'By name'**
  String get sortByName;

  /// No description provided for @sortBySize.
  ///
  /// In en, this message translates to:
  /// **'By size'**
  String get sortBySize;

  /// No description provided for @sortByType.
  ///
  /// In en, this message translates to:
  /// **'By type'**
  String get sortByType;

  /// No description provided for @sortByDetailedType.
  ///
  /// In en, this message translates to:
  /// **'By detailed type'**
  String get sortByDetailedType;

  /// No description provided for @sortByDate.
  ///
  /// In en, this message translates to:
  /// **'By modification date'**
  String get sortByDate;

  /// No description provided for @sortReverse.
  ///
  /// In en, this message translates to:
  /// **'Reverse order'**
  String get sortReverse;

  /// No description provided for @viewShowHidden.
  ///
  /// In en, this message translates to:
  /// **'Show hidden files'**
  String get viewShowHidden;

  /// No description provided for @viewHideHidden.
  ///
  /// In en, this message translates to:
  /// **'Hide hidden files'**
  String get viewHideHidden;

  /// No description provided for @viewSplitScreen.
  ///
  /// In en, this message translates to:
  /// **'Split view (F3)'**
  String get viewSplitScreen;

  /// No description provided for @viewShowPreview.
  ///
  /// In en, this message translates to:
  /// **'Show preview'**
  String get viewShowPreview;

  /// No description provided for @viewHidePreview.
  ///
  /// In en, this message translates to:
  /// **'Hide preview'**
  String get viewHidePreview;

  /// No description provided for @viewShowRightPanel.
  ///
  /// In en, this message translates to:
  /// **'Show right sidebar'**
  String get viewShowRightPanel;

  /// No description provided for @viewHideRightPanel.
  ///
  /// In en, this message translates to:
  /// **'Hide right sidebar'**
  String get viewHideRightPanel;

  /// No description provided for @favAdd.
  ///
  /// In en, this message translates to:
  /// **'Add to favorites'**
  String get favAdd;

  /// No description provided for @favManage.
  ///
  /// In en, this message translates to:
  /// **'Manage favorites'**
  String get favManage;

  /// No description provided for @themesManage.
  ///
  /// In en, this message translates to:
  /// **'Theme manager'**
  String get themesManage;

  /// No description provided for @toolsPackages.
  ///
  /// In en, this message translates to:
  /// **'Uninstall / install apps'**
  String get toolsPackages;

  /// No description provided for @toolsUpdates.
  ///
  /// In en, this message translates to:
  /// **'Check for updates'**
  String get toolsUpdates;

  /// No description provided for @toolsBulkRenamePattern.
  ///
  /// In en, this message translates to:
  /// **'Bulk rename (pattern)'**
  String get toolsBulkRenamePattern;

  /// No description provided for @toolsExtractArchive.
  ///
  /// In en, this message translates to:
  /// **'Extract archive'**
  String get toolsExtractArchive;

  /// No description provided for @helpShortcuts.
  ///
  /// In en, this message translates to:
  /// **'Keyboard shortcuts'**
  String get helpShortcuts;

  /// No description provided for @helpUserGuide.
  ///
  /// In en, this message translates to:
  /// **'User guide'**
  String get helpUserGuide;

  /// No description provided for @helpUserGuideTitle.
  ///
  /// In en, this message translates to:
  /// **'User guide'**
  String get helpUserGuideTitle;

  /// No description provided for @helpUserGuideBlock1.
  ///
  /// In en, this message translates to:
  /// **'NAVIGATION\n• Sidebar: open Home, standard folders (Desktop, Documents, …), custom paths, favorites, network locations and mounted disks. Drag rows to reorder places and favorites.\n• Toolbar and path bar: parent folder, refresh, and global search.\n• Backspace goes back in history. If enabled in Preferences, double-click empty space in the file list to go to the parent folder.\n• Double-click a folder to open it; double-click a file to open it with the default application.'**
  String get helpUserGuideBlock1;

  /// No description provided for @helpUserGuideBlock2.
  ///
  /// In en, this message translates to:
  /// **'FILES AND CLIPBOARD\n• Click to select; drag a rectangle to select multiple items. Use Ctrl for multi-select and Shift for ranges. Esc deselects all.\n• Ctrl+C, Ctrl+X, Ctrl+V copy, cut and paste files. Drag selected items out of the window to copy to the desktop or other apps.\n• Right-click for the context menu (rename, delete, properties, etc.). The File and Edit menus offer the same actions.'**
  String get helpUserGuideBlock2;

  /// No description provided for @helpUserGuideBlock3.
  ///
  /// In en, this message translates to:
  /// **'VIEWS AND SEARCH\n• View menu: list, grid or details; hidden files; split view (F3); preview and right panel (F6).\n• F5 refreshes the current folder. F2 opens a new window instance.\n• Tools → Find (F1) opens file search: filter by name, extension, size, type and date; search under one path or, when enabled, across mounted volumes.'**
  String get helpUserGuideBlock3;

  /// No description provided for @helpUserGuideBlock4.
  ///
  /// In en, this message translates to:
  /// **'SETTINGS AND MORE\n• Favorites and Theme management in the top menu (opens the full theme editor). Preferences adjust clicks, language, compact menu, split view defaults and file-operation options.\n• Computer lists disks. Add network paths from the sidebar; the app may prompt to install tools for SMB or similar.\n• Tools: find files (F1), package manager and update checker when available.\n• Help → Keyboard shortcuts lists every shortcut; this guide summarizes the main features.'**
  String get helpUserGuideBlock4;

  /// No description provided for @helpAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get helpAbout;

  /// No description provided for @helpGitHubProject.
  ///
  /// In en, this message translates to:
  /// **'GitHub project'**
  String get helpGitHubProject;

  /// No description provided for @helpDonateNow.
  ///
  /// In en, this message translates to:
  /// **'Donate now'**
  String get helpDonateNow;

  /// No description provided for @helpCheckAppUpdate.
  ///
  /// In en, this message translates to:
  /// **'Check for app update'**
  String get helpCheckAppUpdate;

  /// No description provided for @appUpdateNewVersionAvailable.
  ///
  /// In en, this message translates to:
  /// **'New version {version} is available.'**
  String appUpdateNewVersionAvailable(Object version);

  /// No description provided for @appUpdateViewRelease.
  ///
  /// In en, this message translates to:
  /// **'View release'**
  String get appUpdateViewRelease;

  /// No description provided for @appUpdateCheckFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not check for updates (network or GitHub).'**
  String get appUpdateCheckFailed;

  /// No description provided for @appUpdateAlreadyLatest.
  ///
  /// In en, this message translates to:
  /// **'You are using the latest version.'**
  String get appUpdateAlreadyLatest;

  /// No description provided for @navBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get navBack;

  /// No description provided for @navForward.
  ///
  /// In en, this message translates to:
  /// **'Forward'**
  String get navForward;

  /// No description provided for @navUp.
  ///
  /// In en, this message translates to:
  /// **'Up'**
  String get navUp;

  /// No description provided for @prefsGeneral.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get prefsGeneral;

  /// No description provided for @prefsSingleClickOpen.
  ///
  /// In en, this message translates to:
  /// **'Single click to open'**
  String get prefsSingleClickOpen;

  /// No description provided for @prefsSingleClickOpenSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Open files and folders with a single click'**
  String get prefsSingleClickOpenSubtitle;

  /// No description provided for @prefsDoubleClickRename.
  ///
  /// In en, this message translates to:
  /// **'Double click to rename'**
  String get prefsDoubleClickRename;

  /// No description provided for @prefsDoubleClickRenameSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Rename files and folders by double-clicking the name'**
  String get prefsDoubleClickRenameSubtitle;

  /// No description provided for @prefsDoubleClickEmptyUp.
  ///
  /// In en, this message translates to:
  /// **'Double click empty area to go up'**
  String get prefsDoubleClickEmptyUp;

  /// No description provided for @prefsDoubleClickEmptyUpSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Go to parent folder by double-clicking empty space'**
  String get prefsDoubleClickEmptyUpSubtitle;

  /// No description provided for @prefsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get prefsLanguage;

  /// No description provided for @prefsLanguageLabel.
  ///
  /// In en, this message translates to:
  /// **'Interface language'**
  String get prefsLanguageLabel;

  /// No description provided for @prefsMenuCompactTitle.
  ///
  /// In en, this message translates to:
  /// **'Compact menu'**
  String get prefsMenuCompactTitle;

  /// No description provided for @prefsMenuCompactSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Group menu items behind the three-line icon instead of the classic bar'**
  String get prefsMenuCompactSubtitle;

  /// No description provided for @smbShellLimitedModeGvfsFallback.
  ///
  /// In en, this message translates to:
  /// **'CIFS mount failed: showing folders via smbclient only. Install cifs-utils and ensure you can run mount.cifs, then try again to open, copy or edit files on this share.'**
  String get smbShellLimitedModeGvfsFallback;

  /// No description provided for @smbShellFileOpenUnavailable.
  ///
  /// In en, this message translates to:
  /// **'This path is smbclient-only (no CIFS mount). Mount the share with mount.cifs or turn off the smbclient option if CIFS mounting works on your system.'**
  String get smbShellFileOpenUnavailable;

  /// No description provided for @prefsExecTextTitle.
  ///
  /// In en, this message translates to:
  /// **'Executable text files'**
  String get prefsExecTextTitle;

  /// No description provided for @prefsExecAuto.
  ///
  /// In en, this message translates to:
  /// **'Run automatically'**
  String get prefsExecAuto;

  /// No description provided for @prefsExecAlwaysShow.
  ///
  /// In en, this message translates to:
  /// **'Always show'**
  String get prefsExecAlwaysShow;

  /// No description provided for @prefsExecAlwaysAsk.
  ///
  /// In en, this message translates to:
  /// **'Always ask'**
  String get prefsExecAlwaysAsk;

  /// No description provided for @prefsDefaultFmTitle.
  ///
  /// In en, this message translates to:
  /// **'Default file manager'**
  String get prefsDefaultFmTitle;

  /// No description provided for @prefsDefaultFmBody.
  ///
  /// In en, this message translates to:
  /// **'Set this file manager as the default app to open folders.'**
  String get prefsDefaultFmBody;

  /// No description provided for @prefsDefaultFmButton.
  ///
  /// In en, this message translates to:
  /// **'Set as default file manager'**
  String get prefsDefaultFmButton;

  /// No description provided for @langItalian.
  ///
  /// In en, this message translates to:
  /// **'Italian'**
  String get langItalian;

  /// No description provided for @langEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get langEnglish;

  /// No description provided for @langFrench.
  ///
  /// In en, this message translates to:
  /// **'French'**
  String get langFrench;

  /// No description provided for @langSpanish.
  ///
  /// In en, this message translates to:
  /// **'Spanish'**
  String get langSpanish;

  /// No description provided for @langPortuguese.
  ///
  /// In en, this message translates to:
  /// **'Portuguese'**
  String get langPortuguese;

  /// No description provided for @langGerman.
  ///
  /// In en, this message translates to:
  /// **'German'**
  String get langGerman;

  /// No description provided for @fileListTypeFolder.
  ///
  /// In en, this message translates to:
  /// **'Folder'**
  String get fileListTypeFolder;

  /// No description provided for @fileListTypeFile.
  ///
  /// In en, this message translates to:
  /// **'File'**
  String get fileListTypeFile;

  /// No description provided for @fileListEmpty.
  ///
  /// In en, this message translates to:
  /// **'No files'**
  String get fileListEmpty;

  /// No description provided for @copyProgressTitle.
  ///
  /// In en, this message translates to:
  /// **'Copying'**
  String get copyProgressTitle;

  /// No description provided for @copyProgressCancelTooltip.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get copyProgressCancelTooltip;

  /// No description provided for @copySpeed.
  ///
  /// In en, this message translates to:
  /// **'Speed: {speed}'**
  String copySpeed(String speed);

  /// No description provided for @copyRemaining.
  ///
  /// In en, this message translates to:
  /// **'Time left: {time}'**
  String copyRemaining(String time);

  /// No description provided for @copyProgressDestLine.
  ///
  /// In en, this message translates to:
  /// **'→ {name}'**
  String copyProgressDestLine(String name);

  /// No description provided for @statusItems.
  ///
  /// In en, this message translates to:
  /// **'Items: {count}'**
  String statusItems(int count);

  /// No description provided for @statusFree.
  ///
  /// In en, this message translates to:
  /// **'Free: {size}'**
  String statusFree(String size);

  /// No description provided for @statusUsed.
  ///
  /// In en, this message translates to:
  /// **'Used: {size}'**
  String statusUsed(String size);

  /// No description provided for @statusTotal.
  ///
  /// In en, this message translates to:
  /// **'Total: {size}'**
  String statusTotal(String size);

  /// No description provided for @statusCopyLine.
  ///
  /// In en, this message translates to:
  /// **'Copy: {source} → {dest}'**
  String statusCopyLine(String source, String dest);

  /// No description provided for @statusCurrentFile.
  ///
  /// In en, this message translates to:
  /// **'File: {name}'**
  String statusCurrentFile(String name);

  /// No description provided for @dialogCloseWhileCopyTitle.
  ///
  /// In en, this message translates to:
  /// **'Operation in progress'**
  String get dialogCloseWhileCopyTitle;

  /// No description provided for @dialogCloseWhileCopyBody.
  ///
  /// In en, this message translates to:
  /// **'A copy or move is in progress. Closing may interrupt it. Continue?'**
  String get dialogCloseWhileCopyBody;

  /// No description provided for @dialogCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get dialogCancel;

  /// No description provided for @dialogOverwriteTitle.
  ///
  /// In en, this message translates to:
  /// **'Replace existing item?'**
  String get dialogOverwriteTitle;

  /// No description provided for @dialogOverwriteBody.
  ///
  /// In en, this message translates to:
  /// **'\"{name}\" already exists in this folder. Replace it?'**
  String dialogOverwriteBody(String name);

  /// No description provided for @dialogOverwriteReplace.
  ///
  /// In en, this message translates to:
  /// **'Replace'**
  String get dialogOverwriteReplace;

  /// No description provided for @dialogOverwriteSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get dialogOverwriteSkip;

  /// No description provided for @dialogCloseAnyway.
  ///
  /// In en, this message translates to:
  /// **'Close anyway'**
  String get dialogCloseAnyway;

  /// No description provided for @commonClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get commonClose;

  /// No description provided for @commonSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get commonSave;

  /// No description provided for @commonDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get commonDelete;

  /// No description provided for @commonRename.
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get commonRename;

  /// No description provided for @commonAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get commonAdd;

  /// No description provided for @commonError.
  ///
  /// In en, this message translates to:
  /// **'Error: {message}'**
  String commonError(String message);

  /// No description provided for @errorFolderRequiresOpenAsRoot.
  ///
  /// In en, this message translates to:
  /// **'To open this folder, use “Open as root”.'**
  String get errorFolderRequiresOpenAsRoot;

  /// No description provided for @sidebarAddNetworkTitle.
  ///
  /// In en, this message translates to:
  /// **'Add network location'**
  String get sidebarAddNetworkTitle;

  /// No description provided for @sidebarNetworkPathLabel.
  ///
  /// In en, this message translates to:
  /// **'Network path'**
  String get sidebarNetworkPathLabel;

  /// No description provided for @sidebarNetworkHint.
  ///
  /// In en, this message translates to:
  /// **'smb://server/share or //server/share'**
  String get sidebarNetworkHint;

  /// No description provided for @sidebarNetworkHelp.
  ///
  /// In en, this message translates to:
  /// **'Examples:\n• smb://192.168.1.100/shared\n• //server/share\n• /mnt/network'**
  String get sidebarNetworkHelp;

  /// No description provided for @sidebarBrowseTooltip.
  ///
  /// In en, this message translates to:
  /// **'Browse'**
  String get sidebarBrowseTooltip;

  /// No description provided for @sidebarRenameShareTitle.
  ///
  /// In en, this message translates to:
  /// **'Rename network share'**
  String get sidebarRenameShareTitle;

  /// No description provided for @sidebarRemoveShareTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove network share'**
  String get sidebarRemoveShareTitle;

  /// No description provided for @sidebarRemoveShareConfirm.
  ///
  /// In en, this message translates to:
  /// **'Remove \"{name}\" from the list?'**
  String sidebarRemoveShareConfirm(String name);

  /// No description provided for @sidebarUnmountTitle.
  ///
  /// In en, this message translates to:
  /// **'Unmount disk'**
  String get sidebarUnmountTitle;

  /// No description provided for @sidebarUnmountConfirm.
  ///
  /// In en, this message translates to:
  /// **'Unmount \"{name}\"?'**
  String sidebarUnmountConfirm(String name);

  /// No description provided for @sidebarUnmount.
  ///
  /// In en, this message translates to:
  /// **'Unmount'**
  String get sidebarUnmount;

  /// No description provided for @sidebarUnmountOk.
  ///
  /// In en, this message translates to:
  /// **'\"{name}\" unmounted'**
  String sidebarUnmountOk(String name);

  /// No description provided for @sidebarUnmountFail.
  ///
  /// In en, this message translates to:
  /// **'Failed to unmount \"{name}\"'**
  String sidebarUnmountFail(String name);

  /// No description provided for @sidebarEmptyTrash.
  ///
  /// In en, this message translates to:
  /// **'Empty trash'**
  String get sidebarEmptyTrash;

  /// No description provided for @sidebarRemoveFromList.
  ///
  /// In en, this message translates to:
  /// **'Remove from list'**
  String get sidebarRemoveFromList;

  /// No description provided for @sidebarMenuChangeColor.
  ///
  /// In en, this message translates to:
  /// **'Change color'**
  String get sidebarMenuChangeColor;

  /// No description provided for @sidebarChangeColorDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Change color: {name}'**
  String sidebarChangeColorDialogTitle(String name);

  /// No description provided for @sidebarProperties.
  ///
  /// In en, this message translates to:
  /// **'Properties'**
  String get sidebarProperties;

  /// No description provided for @sidebarPropertiesFolderTitle.
  ///
  /// In en, this message translates to:
  /// **'Properties: {name}'**
  String sidebarPropertiesFolderTitle(String name);

  /// No description provided for @sidebarChangeFolderColor.
  ///
  /// In en, this message translates to:
  /// **'Change folder color:'**
  String get sidebarChangeFolderColor;

  /// No description provided for @sidebarRemoveCustomColor.
  ///
  /// In en, this message translates to:
  /// **'Remove custom color'**
  String get sidebarRemoveCustomColor;

  /// No description provided for @sidebarChangeAllFoldersColor.
  ///
  /// In en, this message translates to:
  /// **'Change all folder colors'**
  String get sidebarChangeAllFoldersColor;

  /// No description provided for @sidebarPickDefaultColor.
  ///
  /// In en, this message translates to:
  /// **'Pick a default color for all folders:'**
  String get sidebarPickDefaultColor;

  /// No description provided for @sidebarEmptyTrashTitle.
  ///
  /// In en, this message translates to:
  /// **'Empty trash'**
  String get sidebarEmptyTrashTitle;

  /// No description provided for @sidebarEmptyTrashBody.
  ///
  /// In en, this message translates to:
  /// **'Permanently empty the trash? This cannot be undone.'**
  String get sidebarEmptyTrashBody;

  /// No description provided for @sidebarEmptyTrashConfirm.
  ///
  /// In en, this message translates to:
  /// **'Empty'**
  String get sidebarEmptyTrashConfirm;

  /// No description provided for @sidebarTrashEmptied.
  ///
  /// In en, this message translates to:
  /// **'Trash emptied'**
  String get sidebarTrashEmptied;

  /// No description provided for @sidebarCredentialsTitle.
  ///
  /// In en, this message translates to:
  /// **'Credentials for {server}'**
  String sidebarCredentialsTitle(String server);

  /// No description provided for @sidebarGuestAccess.
  ///
  /// In en, this message translates to:
  /// **'Guest (anonymous) access'**
  String get sidebarGuestAccess;

  /// No description provided for @sidebarConnect.
  ///
  /// In en, this message translates to:
  /// **'Connect'**
  String get sidebarConnect;

  /// No description provided for @sidebarConnecting.
  ///
  /// In en, this message translates to:
  /// **'Connecting to {name}...'**
  String sidebarConnecting(String name);

  /// No description provided for @sidebarConnectionError.
  ///
  /// In en, this message translates to:
  /// **'Error connecting to {name}'**
  String sidebarConnectionError(String name);

  /// No description provided for @sidebarRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get sidebarRetry;

  /// No description provided for @copyCancelled.
  ///
  /// In en, this message translates to:
  /// **'Copy cancelled'**
  String get copyCancelled;

  /// No description provided for @fileCopiedSuccess.
  ///
  /// In en, this message translates to:
  /// **'File copied'**
  String get fileCopiedSuccess;

  /// No description provided for @folderCopiedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Folder copied'**
  String get folderCopiedSuccess;

  /// No description provided for @extractionComplete.
  ///
  /// In en, this message translates to:
  /// **'Extraction complete'**
  String get extractionComplete;

  /// No description provided for @snackInitError.
  ///
  /// In en, this message translates to:
  /// **'Initialization error: {error}'**
  String snackInitError(String error);

  /// No description provided for @snackPathRemoved.
  ///
  /// In en, this message translates to:
  /// **'Removed from list: {name}'**
  String snackPathRemoved(String name);

  /// No description provided for @labelChoosePath.
  ///
  /// In en, this message translates to:
  /// **'Choose path'**
  String get labelChoosePath;

  /// No description provided for @ctxOpenTerminal.
  ///
  /// In en, this message translates to:
  /// **'Open terminal'**
  String get ctxOpenTerminal;

  /// No description provided for @ctxNewFolder.
  ///
  /// In en, this message translates to:
  /// **'New folder'**
  String get ctxNewFolder;

  /// No description provided for @ctxOpenAsRoot.
  ///
  /// In en, this message translates to:
  /// **'Open as root'**
  String get ctxOpenAsRoot;

  /// No description provided for @ctxOpenWith.
  ///
  /// In en, this message translates to:
  /// **'Open with…'**
  String get ctxOpenWith;

  /// No description provided for @ctxCopyTo.
  ///
  /// In en, this message translates to:
  /// **'Copy to…'**
  String get ctxCopyTo;

  /// No description provided for @ctxMoveTo.
  ///
  /// In en, this message translates to:
  /// **'Move to…'**
  String get ctxMoveTo;

  /// No description provided for @ctxCopy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get ctxCopy;

  /// No description provided for @ctxCut.
  ///
  /// In en, this message translates to:
  /// **'Cut'**
  String get ctxCut;

  /// No description provided for @ctxPaste.
  ///
  /// In en, this message translates to:
  /// **'Paste'**
  String get ctxPaste;

  /// No description provided for @ctxCreateNew.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get ctxCreateNew;

  /// No description provided for @ctxNewTextDocumentShort.
  ///
  /// In en, this message translates to:
  /// **'Text document (.txt)'**
  String get ctxNewTextDocumentShort;

  /// No description provided for @ctxNewWordDocument.
  ///
  /// In en, this message translates to:
  /// **'Word document (.docx)'**
  String get ctxNewWordDocument;

  /// No description provided for @ctxNewExcelSpreadsheet.
  ///
  /// In en, this message translates to:
  /// **'Excel workbook (.xlsx)'**
  String get ctxNewExcelSpreadsheet;

  /// No description provided for @ctxExtract.
  ///
  /// In en, this message translates to:
  /// **'Extract'**
  String get ctxExtract;

  /// No description provided for @ctxExtractTo.
  ///
  /// In en, this message translates to:
  /// **'Extract archive to…'**
  String get ctxExtractTo;

  /// No description provided for @ctxCompressToZip.
  ///
  /// In en, this message translates to:
  /// **'Compress to .zip file'**
  String get ctxCompressToZip;

  /// No description provided for @snackZipCreated.
  ///
  /// In en, this message translates to:
  /// **'Created archive \"{name}\".'**
  String snackZipCreated(Object name);

  /// No description provided for @snackZipFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not create ZIP: {message}'**
  String snackZipFailed(Object message);

  /// No description provided for @ctxChangeColor.
  ///
  /// In en, this message translates to:
  /// **'Change color'**
  String get ctxChangeColor;

  /// No description provided for @ctxMoveToTrash.
  ///
  /// In en, this message translates to:
  /// **'Move to trash'**
  String get ctxMoveToTrash;

  /// No description provided for @ctxRestoreFromTrash.
  ///
  /// In en, this message translates to:
  /// **'Restore to original folder'**
  String get ctxRestoreFromTrash;

  /// No description provided for @menuRestoreFromTrash.
  ///
  /// In en, this message translates to:
  /// **'Restore from trash'**
  String get menuRestoreFromTrash;

  /// No description provided for @trashRestorePickFolderTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose folder to restore into'**
  String get trashRestorePickFolderTitle;

  /// No description provided for @trashRestoreTargetExists.
  ///
  /// In en, this message translates to:
  /// **'Cannot restore: \"{name}\" already exists at the destination.'**
  String trashRestoreTargetExists(String name);

  /// No description provided for @trashRestoredCount.
  ///
  /// In en, this message translates to:
  /// **'{count} items restored'**
  String trashRestoredCount(int count);

  /// No description provided for @trashRestoreFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not restore the selected items.'**
  String get trashRestoreFailed;

  /// No description provided for @dialogOpenWithTitle.
  ///
  /// In en, this message translates to:
  /// **'Open \"{name}\" with…'**
  String dialogOpenWithTitle(String name);

  /// No description provided for @hintSearchApp.
  ///
  /// In en, this message translates to:
  /// **'Search application…'**
  String get hintSearchApp;

  /// No description provided for @openWithDefaultApp.
  ///
  /// In en, this message translates to:
  /// **'Default application'**
  String get openWithDefaultApp;

  /// No description provided for @browseEllipsis.
  ///
  /// In en, this message translates to:
  /// **'Browse…'**
  String get browseEllipsis;

  /// No description provided for @tooltipSetAsDefaultApp.
  ///
  /// In en, this message translates to:
  /// **'Set as default application'**
  String get tooltipSetAsDefaultApp;

  /// No description provided for @openWithOpenAndSetDefault.
  ///
  /// In en, this message translates to:
  /// **'Open and set as default'**
  String get openWithOpenAndSetDefault;

  /// No description provided for @openWithFooterHint.
  ///
  /// In en, this message translates to:
  /// **'Use the star or the ⋮ menu to change the default application for this file type anytime.'**
  String get openWithFooterHint;

  /// No description provided for @snackDefaultAppSet.
  ///
  /// In en, this message translates to:
  /// **'{appName} set as default for {mimeType}'**
  String snackDefaultAppSet(String appName, String mimeType);

  /// No description provided for @snackSetDefaultAppError.
  ///
  /// In en, this message translates to:
  /// **'Could not set default: {error}'**
  String snackSetDefaultAppError(String error);

  /// No description provided for @snackOpenFileError.
  ///
  /// In en, this message translates to:
  /// **'Could not open: {error}'**
  String snackOpenFileError(String error);

  /// No description provided for @dialogTitleCreateFolder.
  ///
  /// In en, this message translates to:
  /// **'Create new folder'**
  String get dialogTitleCreateFolder;

  /// No description provided for @dialogTitleNewFolder.
  ///
  /// In en, this message translates to:
  /// **'New folder'**
  String get dialogTitleNewFolder;

  /// No description provided for @labelFolderName.
  ///
  /// In en, this message translates to:
  /// **'Folder name'**
  String get labelFolderName;

  /// No description provided for @hintFolderName.
  ///
  /// In en, this message translates to:
  /// **'Enter folder name'**
  String get hintFolderName;

  /// No description provided for @labelFileName.
  ///
  /// In en, this message translates to:
  /// **'File name'**
  String get labelFileName;

  /// No description provided for @hintTextDocument.
  ///
  /// In en, this message translates to:
  /// **'document.txt'**
  String get hintTextDocument;

  /// No description provided for @buttonCreate.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get buttonCreate;

  /// No description provided for @snackMoveError.
  ///
  /// In en, this message translates to:
  /// **'Error while moving: {error}'**
  String snackMoveError(String error);

  /// No description provided for @dialogChangeColorFor.
  ///
  /// In en, this message translates to:
  /// **'Change color: {name}'**
  String dialogChangeColorFor(String name);

  /// No description provided for @dialogPickFolderColor.
  ///
  /// In en, this message translates to:
  /// **'Pick a color for the folder:'**
  String get dialogPickFolderColor;

  /// No description provided for @shortcutTitle.
  ///
  /// In en, this message translates to:
  /// **'Keyboard shortcuts'**
  String get shortcutTitle;

  /// No description provided for @shortcutCopy.
  ///
  /// In en, this message translates to:
  /// **'Copy selected files/folders'**
  String get shortcutCopy;

  /// No description provided for @shortcutPaste.
  ///
  /// In en, this message translates to:
  /// **'Paste files/folders'**
  String get shortcutPaste;

  /// No description provided for @shortcutCut.
  ///
  /// In en, this message translates to:
  /// **'Cut selected files/folders'**
  String get shortcutCut;

  /// No description provided for @shortcutUndo.
  ///
  /// In en, this message translates to:
  /// **'Undo last operation'**
  String get shortcutUndo;

  /// No description provided for @shortcutRedo.
  ///
  /// In en, this message translates to:
  /// **'Redo last operation'**
  String get shortcutRedo;

  /// No description provided for @shortcutNewTab.
  ///
  /// In en, this message translates to:
  /// **'Open new tab'**
  String get shortcutNewTab;

  /// No description provided for @shortcutSplitView.
  ///
  /// In en, this message translates to:
  /// **'Split screen in two'**
  String get shortcutSplitView;

  /// No description provided for @shortcutRefresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh current folder'**
  String get shortcutRefresh;

  /// No description provided for @shortcutRightPanel.
  ///
  /// In en, this message translates to:
  /// **'Show/hide right sidebar'**
  String get shortcutRightPanel;

  /// No description provided for @shortcutDeselect.
  ///
  /// In en, this message translates to:
  /// **'Deselect all files'**
  String get shortcutDeselect;

  /// No description provided for @shortcutBackNav.
  ///
  /// In en, this message translates to:
  /// **'Go back in navigation'**
  String get shortcutBackNav;

  /// No description provided for @shortcutFindFiles.
  ///
  /// In en, this message translates to:
  /// **'Find files and folders'**
  String get shortcutFindFiles;

  /// No description provided for @aboutTitle.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get aboutTitle;

  /// No description provided for @aboutAppName.
  ///
  /// In en, this message translates to:
  /// **'File Manager'**
  String get aboutAppName;

  /// No description provided for @aboutTagline.
  ///
  /// In en, this message translates to:
  /// **'Advanced file manager'**
  String get aboutTagline;

  /// No description provided for @aboutVersionLabel.
  ///
  /// In en, this message translates to:
  /// **'Version: {version}'**
  String aboutVersionLabel(String version);

  /// No description provided for @aboutAuthor.
  ///
  /// In en, this message translates to:
  /// **'Author: Marco Di Giangiacomo'**
  String get aboutAuthor;

  /// No description provided for @aboutYear.
  ///
  /// In en, this message translates to:
  /// **'© 2026'**
  String get aboutYear;

  /// No description provided for @aboutDescriptionHeading.
  ///
  /// In en, this message translates to:
  /// **'Description:'**
  String get aboutDescriptionHeading;

  /// No description provided for @aboutDescription.
  ///
  /// In en, this message translates to:
  /// **'SAGE File Manager is a modern, full-featured file manager for Linux with multi-view, previews, themes, search, optimized copy/paste, split view, SMB/LAN support, and more.'**
  String get aboutDescription;

  /// No description provided for @aboutFeaturesHeading.
  ///
  /// In en, this message translates to:
  /// **'Main features:'**
  String get aboutFeaturesHeading;

  /// No description provided for @aboutFeaturesList.
  ///
  /// In en, this message translates to:
  /// **'• Full file and folder management\n• Multiple views (list, grid, details)\n• File preview (images, PDF, documents, text)\n• Theme management (presets and customization)\n• Advanced search\n• Optimized copy/paste\n• Split view\n• Favorites and custom paths\n• Executable and script support\n• Modern UI'**
  String get aboutFeaturesList;

  /// No description provided for @snackDocumentCreated.
  ///
  /// In en, this message translates to:
  /// **'Document \"{name}\" created'**
  String snackDocumentCreated(String name);

  /// No description provided for @dialogInsufficientPermissions.
  ///
  /// In en, this message translates to:
  /// **'Insufficient permissions'**
  String get dialogInsufficientPermissions;

  /// No description provided for @snackFolderCreated.
  ///
  /// In en, this message translates to:
  /// **'Folder created'**
  String get snackFolderCreated;

  /// No description provided for @snackTerminalUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Terminal not available'**
  String get snackTerminalUnavailable;

  /// No description provided for @snackTerminalRootError.
  ///
  /// In en, this message translates to:
  /// **'Could not open terminal as root'**
  String get snackTerminalRootError;

  /// No description provided for @snackRootHelperMissing.
  ///
  /// In en, this message translates to:
  /// **'Could not open as root. Install pkexec or sudo.'**
  String get snackRootHelperMissing;

  /// No description provided for @snackOpenAsRootNoFolder.
  ///
  /// In en, this message translates to:
  /// **'Open a folder first, then choose Open as root.'**
  String get snackOpenAsRootNoFolder;

  /// No description provided for @snackOpenAsRootBadFolder.
  ///
  /// In en, this message translates to:
  /// **'That folder cannot be opened.'**
  String get snackOpenAsRootBadFolder;

  /// No description provided for @snackPasteItemError.
  ///
  /// In en, this message translates to:
  /// **'Error pasting {name}: {error}'**
  String snackPasteItemError(String name, String error);

  /// No description provided for @snackFileMoved.
  ///
  /// In en, this message translates to:
  /// **'File moved'**
  String get snackFileMoved;

  /// No description provided for @dialogRenameFileTitle.
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get dialogRenameFileTitle;

  /// No description provided for @dialogRenameManySubtitle.
  ///
  /// In en, this message translates to:
  /// **'{count} items selected. Enter a new name for each row.'**
  String dialogRenameManySubtitle(int count);

  /// No description provided for @labelNewName.
  ///
  /// In en, this message translates to:
  /// **'New name'**
  String get labelNewName;

  /// No description provided for @snackFileRenamed.
  ///
  /// In en, this message translates to:
  /// **'File renamed'**
  String get snackFileRenamed;

  /// No description provided for @snackRenameError.
  ///
  /// In en, this message translates to:
  /// **'Rename error: {error}'**
  String snackRenameError(String error);

  /// No description provided for @snackRenameSameFolder.
  ///
  /// In en, this message translates to:
  /// **'All selected items must be in the same folder.'**
  String get snackRenameSameFolder;

  /// No description provided for @snackRenameEmptyName.
  ///
  /// In en, this message translates to:
  /// **'Each item needs a non-empty new name.'**
  String get snackRenameEmptyName;

  /// No description provided for @snackRenameDuplicateNames.
  ///
  /// In en, this message translates to:
  /// **'New names must be different from each other.'**
  String get snackRenameDuplicateNames;

  /// No description provided for @snackRenameTargetExists.
  ///
  /// In en, this message translates to:
  /// **'A file or folder with this name already exists.'**
  String get snackRenameTargetExists;

  /// No description provided for @snackSelectPathFirst.
  ///
  /// In en, this message translates to:
  /// **'Select a path first'**
  String get snackSelectPathFirst;

  /// No description provided for @snackAlreadyFavorite.
  ///
  /// In en, this message translates to:
  /// **'Already in favorites'**
  String get snackAlreadyFavorite;

  /// No description provided for @snackAddedFavorite.
  ///
  /// In en, this message translates to:
  /// **'Added to favorites: {name}'**
  String snackAddedFavorite(String name);

  /// No description provided for @favoritesEmptyList.
  ///
  /// In en, this message translates to:
  /// **'No favorites yet'**
  String get favoritesEmptyList;

  /// No description provided for @snackNewTabOpened.
  ///
  /// In en, this message translates to:
  /// **'New tab opened: {name}'**
  String snackNewTabOpened(String name);

  /// No description provided for @snackSelectForSymlink.
  ///
  /// In en, this message translates to:
  /// **'Select a file or folder to create a shortcut'**
  String get snackSelectForSymlink;

  /// No description provided for @dialogCreateSymlinkTitle.
  ///
  /// In en, this message translates to:
  /// **'Create shortcut'**
  String get dialogCreateSymlinkTitle;

  /// No description provided for @labelSymlinkName.
  ///
  /// In en, this message translates to:
  /// **'Shortcut name'**
  String get labelSymlinkName;

  /// No description provided for @snackSymlinkCreated.
  ///
  /// In en, this message translates to:
  /// **'Shortcut created'**
  String get snackSymlinkCreated;

  /// No description provided for @snackConnectingNetwork.
  ///
  /// In en, this message translates to:
  /// **'Connecting to network…'**
  String get snackConnectingNetwork;

  /// No description provided for @snackNewInstanceStarted.
  ///
  /// In en, this message translates to:
  /// **'New app instance started'**
  String get snackNewInstanceStarted;

  /// No description provided for @snackNewInstanceError.
  ///
  /// In en, this message translates to:
  /// **'Could not start new instance: {error}'**
  String snackNewInstanceError(String error);

  /// No description provided for @snackSelectFilesRename.
  ///
  /// In en, this message translates to:
  /// **'Select at least one file to rename'**
  String get snackSelectFilesRename;

  /// No description provided for @bulkRenameTitle.
  ///
  /// In en, this message translates to:
  /// **'Bulk rename'**
  String get bulkRenameTitle;

  /// No description provided for @bulkRenameSelectedCount.
  ///
  /// In en, this message translates to:
  /// **'{count} files selected'**
  String bulkRenameSelectedCount(int count);

  /// No description provided for @bulkRenamePatternLabel.
  ///
  /// In en, this message translates to:
  /// **'Rename pattern'**
  String get bulkRenamePatternLabel;

  /// No description provided for @bulkRenamePatternHelper.
  ///
  /// In en, this message translates to:
  /// **'Use the tokens name and num each wrapped in curly braces (see example below).'**
  String get bulkRenamePatternHelper;

  /// No description provided for @bulkRenameAutoNumber.
  ///
  /// In en, this message translates to:
  /// **'Use automatic numbering'**
  String get bulkRenameAutoNumber;

  /// No description provided for @bulkRenameStartNumber.
  ///
  /// In en, this message translates to:
  /// **'Starting number'**
  String get bulkRenameStartNumber;

  /// No description provided for @bulkRenameKeepExt.
  ///
  /// In en, this message translates to:
  /// **'Keep original extension'**
  String get bulkRenameKeepExt;

  /// No description provided for @trashEmptyError.
  ///
  /// In en, this message translates to:
  /// **'Error emptying trash: {error}'**
  String trashEmptyError(String error);

  /// No description provided for @labelNItems.
  ///
  /// In en, this message translates to:
  /// **'{count} items'**
  String labelNItems(int count);

  /// No description provided for @dialogTitleDeletePermanent.
  ///
  /// In en, this message translates to:
  /// **'Delete permanently?'**
  String get dialogTitleDeletePermanent;

  /// No description provided for @dialogTitleMoveToTrashConfirm.
  ///
  /// In en, this message translates to:
  /// **'Move to trash?'**
  String get dialogTitleMoveToTrashConfirm;

  /// No description provided for @dialogBodyPermanentDeleteOne.
  ///
  /// In en, this message translates to:
  /// **'Permanently delete one item?'**
  String get dialogBodyPermanentDeleteOne;

  /// No description provided for @dialogBodyPermanentDeleteMany.
  ///
  /// In en, this message translates to:
  /// **'Permanently delete {count} items?'**
  String dialogBodyPermanentDeleteMany(int count);

  /// No description provided for @dialogBodyTrashOne.
  ///
  /// In en, this message translates to:
  /// **'Move one item to trash?'**
  String get dialogBodyTrashOne;

  /// No description provided for @dialogBodyTrashMany.
  ///
  /// In en, this message translates to:
  /// **'Move {count} items to trash?'**
  String dialogBodyTrashMany(int count);

  /// No description provided for @snackDeletedPermanentOne.
  ///
  /// In en, this message translates to:
  /// **'One item permanently deleted'**
  String get snackDeletedPermanentOne;

  /// No description provided for @snackDeletedPermanentMany.
  ///
  /// In en, this message translates to:
  /// **'{count} items permanently deleted'**
  String snackDeletedPermanentMany(int count);

  /// No description provided for @snackMovedToTrashOne.
  ///
  /// In en, this message translates to:
  /// **'One item moved to trash'**
  String get snackMovedToTrashOne;

  /// No description provided for @snackMovedToTrashMany.
  ///
  /// In en, this message translates to:
  /// **'{count} items moved to trash'**
  String snackMovedToTrashMany(int count);

  /// No description provided for @snackDeleteErrorsSuffix.
  ///
  /// In en, this message translates to:
  /// **', {errors} errors'**
  String snackDeleteErrorsSuffix(int errors);

  /// No description provided for @dialogOpenAsRootBody.
  ///
  /// In en, this message translates to:
  /// **'You do not have permission to create files or folders in this directory. Open the file manager as root?'**
  String get dialogOpenAsRootBody;

  /// No description provided for @dialogOpenAsRootAuthTitle.
  ///
  /// In en, this message translates to:
  /// **'Open as administrator'**
  String get dialogOpenAsRootAuthTitle;

  /// No description provided for @dialogOpenAsRootAuthBody.
  ///
  /// In en, this message translates to:
  /// **'When you tap Continue, the system will ask for the administrator password. Only after you authenticate successfully will a new file manager window open in this folder.'**
  String get dialogOpenAsRootAuthBody;

  /// No description provided for @dialogOpenAsRootContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get dialogOpenAsRootContinue;

  /// No description provided for @paneSelectPathHint.
  ///
  /// In en, this message translates to:
  /// **'Select a path'**
  String get paneSelectPathHint;

  /// No description provided for @emptyFolderLabel.
  ///
  /// In en, this message translates to:
  /// **'Empty folder'**
  String get emptyFolderLabel;

  /// No description provided for @sidebarMountPointOptional.
  ///
  /// In en, this message translates to:
  /// **'Mount point (optional)'**
  String get sidebarMountPointOptional;

  /// No description provided for @snackBulkRenameManyDone.
  ///
  /// In en, this message translates to:
  /// **'{count} files renamed'**
  String snackBulkRenameManyDone(int count);

  /// No description provided for @commonOk.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get commonOk;

  /// No description provided for @prefsPageTitle.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get prefsPageTitle;

  /// No description provided for @snackPrefsSaved.
  ///
  /// In en, this message translates to:
  /// **'Preferences saved'**
  String get snackPrefsSaved;

  /// No description provided for @prefsNavView.
  ///
  /// In en, this message translates to:
  /// **'Display'**
  String get prefsNavView;

  /// No description provided for @prefsNavPreview.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get prefsNavPreview;

  /// No description provided for @prefsNavFileOps.
  ///
  /// In en, this message translates to:
  /// **'File operations'**
  String get prefsNavFileOps;

  /// No description provided for @prefsNavTrash.
  ///
  /// In en, this message translates to:
  /// **'Trash'**
  String get prefsNavTrash;

  /// No description provided for @prefsNavMedia.
  ///
  /// In en, this message translates to:
  /// **'Removable media'**
  String get prefsNavMedia;

  /// No description provided for @prefsNavCache.
  ///
  /// In en, this message translates to:
  /// **'Cache'**
  String get prefsNavCache;

  /// No description provided for @prefsDefaultFmSuccess.
  ///
  /// In en, this message translates to:
  /// **'File manager set as default successfully.'**
  String get prefsDefaultFmSuccess;

  /// No description provided for @prefsShowHiddenTitle.
  ///
  /// In en, this message translates to:
  /// **'Show hidden files'**
  String get prefsShowHiddenTitle;

  /// No description provided for @prefsShowHiddenSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Show files and folders whose names start with a dot'**
  String get prefsShowHiddenSubtitle;

  /// No description provided for @prefsShowPreviewPanelTitle.
  ///
  /// In en, this message translates to:
  /// **'Show preview panel'**
  String get prefsShowPreviewPanelTitle;

  /// No description provided for @prefsShowPreviewPanelSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Show the preview panel on the right'**
  String get prefsShowPreviewPanelSubtitle;

  /// No description provided for @prefsAlwaysDoublePaneTitle.
  ///
  /// In en, this message translates to:
  /// **'Always start with split view'**
  String get prefsAlwaysDoublePaneTitle;

  /// No description provided for @prefsAlwaysDoublePaneSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Always open split view on startup'**
  String get prefsAlwaysDoublePaneSubtitle;

  /// No description provided for @prefsIgnoreViewPerFolderTitle.
  ///
  /// In en, this message translates to:
  /// **'Ignore per-folder view preferences'**
  String get prefsIgnoreViewPerFolderTitle;

  /// No description provided for @prefsIgnoreViewPerFolderSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Do not save view preferences for each folder'**
  String get prefsIgnoreViewPerFolderSubtitle;

  /// No description provided for @prefsDefaultViewModeTitle.
  ///
  /// In en, this message translates to:
  /// **'Default view mode'**
  String get prefsDefaultViewModeTitle;

  /// No description provided for @prefsViewModeList.
  ///
  /// In en, this message translates to:
  /// **'List'**
  String get prefsViewModeList;

  /// No description provided for @prefsViewModeGrid.
  ///
  /// In en, this message translates to:
  /// **'Grid'**
  String get prefsViewModeGrid;

  /// No description provided for @prefsViewModeDetails.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get prefsViewModeDetails;

  /// No description provided for @prefsGridZoomTitle.
  ///
  /// In en, this message translates to:
  /// **'Default grid zoom level'**
  String get prefsGridZoomTitle;

  /// No description provided for @prefsGridZoomLevel.
  ///
  /// In en, this message translates to:
  /// **'Level: {current}/10'**
  String prefsGridZoomLevel(int current);

  /// No description provided for @prefsFontSection.
  ///
  /// In en, this message translates to:
  /// **'Font'**
  String get prefsFontSection;

  /// No description provided for @prefsFontFamilyLabel.
  ///
  /// In en, this message translates to:
  /// **'Font family'**
  String get prefsFontFamilyLabel;

  /// No description provided for @labelSelectFont.
  ///
  /// In en, this message translates to:
  /// **'Select font'**
  String get labelSelectFont;

  /// No description provided for @fontFamilyDefaultSystem.
  ///
  /// In en, this message translates to:
  /// **'Default (system)'**
  String get fontFamilyDefaultSystem;

  /// No description provided for @prefsFontSizeTitle.
  ///
  /// In en, this message translates to:
  /// **'Font size'**
  String get prefsFontSizeTitle;

  /// No description provided for @prefsFontSizeValue.
  ///
  /// In en, this message translates to:
  /// **'Size: {size}'**
  String prefsFontSizeValue(String size);

  /// No description provided for @prefsFontWeightTitle.
  ///
  /// In en, this message translates to:
  /// **'Font weight'**
  String get prefsFontWeightTitle;

  /// No description provided for @prefsFontWeightNormal.
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get prefsFontWeightNormal;

  /// No description provided for @prefsFontWeightBold.
  ///
  /// In en, this message translates to:
  /// **'Bold'**
  String get prefsFontWeightBold;

  /// No description provided for @prefsFontWeightSemiBold.
  ///
  /// In en, this message translates to:
  /// **'Semi-bold'**
  String get prefsFontWeightSemiBold;

  /// No description provided for @prefsFontWeightMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get prefsFontWeightMedium;

  /// No description provided for @prefsTextShadowSection.
  ///
  /// In en, this message translates to:
  /// **'Text shadow'**
  String get prefsTextShadowSection;

  /// No description provided for @prefsTextShadowEnableTitle.
  ///
  /// In en, this message translates to:
  /// **'Enable text shadow'**
  String get prefsTextShadowEnableTitle;

  /// No description provided for @prefsTextShadowEnableSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add a shadow to text for readability'**
  String get prefsTextShadowEnableSubtitle;

  /// No description provided for @prefsShadowIntensityTitle.
  ///
  /// In en, this message translates to:
  /// **'Shadow blur'**
  String get prefsShadowIntensityTitle;

  /// No description provided for @prefsShadowOffsetXTitle.
  ///
  /// In en, this message translates to:
  /// **'Shadow offset X'**
  String get prefsShadowOffsetXTitle;

  /// No description provided for @prefsShadowOffsetYTitle.
  ///
  /// In en, this message translates to:
  /// **'Shadow offset Y'**
  String get prefsShadowOffsetYTitle;

  /// No description provided for @prefsShadowColorTitle.
  ///
  /// In en, this message translates to:
  /// **'Shadow color'**
  String get prefsShadowColorTitle;

  /// No description provided for @prefsShadowColorValue.
  ///
  /// In en, this message translates to:
  /// **'Color: {value}'**
  String prefsShadowColorValue(String value);

  /// No description provided for @prefsShadowColorBlack.
  ///
  /// In en, this message translates to:
  /// **'Black'**
  String get prefsShadowColorBlack;

  /// No description provided for @dialogPickShadowColor.
  ///
  /// In en, this message translates to:
  /// **'Pick shadow color'**
  String get dialogPickShadowColor;

  /// No description provided for @prefsPickColor.
  ///
  /// In en, this message translates to:
  /// **'Choose color'**
  String get prefsPickColor;

  /// No description provided for @prefsTextPreviewLabel.
  ///
  /// In en, this message translates to:
  /// **'Text preview'**
  String get prefsTextPreviewLabel;

  /// No description provided for @prefsDisableFileQueueTitle.
  ///
  /// In en, this message translates to:
  /// **'Disable file operation queue'**
  String get prefsDisableFileQueueTitle;

  /// No description provided for @prefsDisableFileQueueSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Run file operations sequentially without a queue'**
  String get prefsDisableFileQueueSubtitle;

  /// No description provided for @prefsAskTrashTitle.
  ///
  /// In en, this message translates to:
  /// **'Ask before moving to trash'**
  String get prefsAskTrashTitle;

  /// No description provided for @prefsAskTrashSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Require confirmation before moving files to trash'**
  String get prefsAskTrashSubtitle;

  /// No description provided for @prefsAskEmptyTrashTitle.
  ///
  /// In en, this message translates to:
  /// **'Ask before emptying trash'**
  String get prefsAskEmptyTrashTitle;

  /// No description provided for @prefsAskEmptyTrashSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Require confirmation before permanently deleting trash'**
  String get prefsAskEmptyTrashSubtitle;

  /// No description provided for @prefsIncludeDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Include Delete command'**
  String get prefsIncludeDeleteTitle;

  /// No description provided for @prefsIncludeDeleteSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Show option to delete files without trash'**
  String get prefsIncludeDeleteSubtitle;

  /// No description provided for @prefsSkipTrashDelKeyTitle.
  ///
  /// In en, this message translates to:
  /// **'Skip trash with Delete key'**
  String get prefsSkipTrashDelKeyTitle;

  /// No description provided for @prefsSkipTrashDelKeySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Delete files directly when pressing Delete'**
  String get prefsSkipTrashDelKeySubtitle;

  /// No description provided for @prefsAutoMountTitle.
  ///
  /// In en, this message translates to:
  /// **'Auto-mount removable devices'**
  String get prefsAutoMountTitle;

  /// No description provided for @prefsAutoMountSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Mount USB and other devices when connected'**
  String get prefsAutoMountSubtitle;

  /// No description provided for @prefsOpenWindowMountedTitle.
  ///
  /// In en, this message translates to:
  /// **'Open window for mounted devices'**
  String get prefsOpenWindowMountedTitle;

  /// No description provided for @prefsOpenWindowMountedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Automatically open a window for mounted devices'**
  String get prefsOpenWindowMountedSubtitle;

  /// No description provided for @prefsWarnRemovableTitle.
  ///
  /// In en, this message translates to:
  /// **'Warn when device is connected'**
  String get prefsWarnRemovableTitle;

  /// No description provided for @prefsWarnRemovableSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Show notification when a removable device is connected'**
  String get prefsWarnRemovableSubtitle;

  /// No description provided for @prefsPreviewExtensionsIntro.
  ///
  /// In en, this message translates to:
  /// **'Choose file extensions to enable preview for:'**
  String get prefsPreviewExtensionsIntro;

  /// No description provided for @prefsPreviewRightPanelNote.
  ///
  /// In en, this message translates to:
  /// **'Full previews for PDF, Office, text and other types appear in the right sidebar when it is visible. If the sidebar is hidden, only image thumbnails are shown in the file list.'**
  String get prefsPreviewRightPanelNote;

  /// No description provided for @prefsAdminPasswordSection.
  ///
  /// In en, this message translates to:
  /// **'Administrator password'**
  String get prefsAdminPasswordSection;

  /// No description provided for @prefsSaveAdminPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Save administrator password'**
  String get prefsSaveAdminPasswordTitle;

  /// No description provided for @prefsSaveAdminPasswordSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Save password for updates (not recommended)'**
  String get prefsSaveAdminPasswordSubtitle;

  /// No description provided for @labelAdminPassword.
  ///
  /// In en, this message translates to:
  /// **'Administrator password'**
  String get labelAdminPassword;

  /// No description provided for @hintAdminPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter password'**
  String get hintAdminPassword;

  /// No description provided for @prefsCacheSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Cache and previews'**
  String get prefsCacheSectionTitle;

  /// No description provided for @prefsCacheSizeTitle.
  ///
  /// In en, this message translates to:
  /// **'Cache size'**
  String get prefsCacheSizeTitle;

  /// No description provided for @prefsCacheSizeCurrent.
  ///
  /// In en, this message translates to:
  /// **'Current size: {size}'**
  String prefsCacheSizeCurrent(String size);

  /// No description provided for @labelNetworkShareName.
  ///
  /// In en, this message translates to:
  /// **'Custom name'**
  String get labelNetworkShareName;

  /// No description provided for @hintNetworkShareName.
  ///
  /// In en, this message translates to:
  /// **'Enter a name for this share'**
  String get hintNetworkShareName;

  /// No description provided for @sidebarTooltipRemoveNetwork.
  ///
  /// In en, this message translates to:
  /// **'Remove network path'**
  String get sidebarTooltipRemoveNetwork;

  /// No description provided for @sidebarTooltipUnmount.
  ///
  /// In en, this message translates to:
  /// **'Unmount disk'**
  String get sidebarTooltipUnmount;

  /// No description provided for @sidebarUnmountSuccess.
  ///
  /// In en, this message translates to:
  /// **'\"{name}\" unmounted successfully'**
  String sidebarUnmountSuccess(String name);

  /// No description provided for @sidebarUnmountError.
  ///
  /// In en, this message translates to:
  /// **'Error unmounting \"{name}\"'**
  String sidebarUnmountError(String name);

  /// No description provided for @previewSelectFile.
  ///
  /// In en, this message translates to:
  /// **'Select a file for preview'**
  String get previewSelectFile;

  /// No description provided for @previewPanelTitle.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get previewPanelTitle;

  /// No description provided for @previewPanelSizeLine.
  ///
  /// In en, this message translates to:
  /// **'Size: {value}'**
  String previewPanelSizeLine(String value);

  /// No description provided for @previewPanelModifiedLine.
  ///
  /// In en, this message translates to:
  /// **'Modified: {value}'**
  String previewPanelModifiedLine(String value);

  /// No description provided for @dialogErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get dialogErrorTitle;

  /// No description provided for @propsLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load file properties'**
  String get propsLoadError;

  /// No description provided for @snackPermissionsUpdated.
  ///
  /// In en, this message translates to:
  /// **'Permissions updated'**
  String get snackPermissionsUpdated;

  /// No description provided for @dialogEditFieldTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit {label}'**
  String dialogEditFieldTitle(String label);

  /// No description provided for @snackFieldUpdated.
  ///
  /// In en, this message translates to:
  /// **'{label} updated successfully'**
  String snackFieldUpdated(String label);

  /// No description provided for @propsEditPermissionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit permissions'**
  String get propsEditPermissionsTitle;

  /// No description provided for @permOwner.
  ///
  /// In en, this message translates to:
  /// **'Owner:'**
  String get permOwner;

  /// No description provided for @permGroup.
  ///
  /// In en, this message translates to:
  /// **'Group:'**
  String get permGroup;

  /// No description provided for @permOthers.
  ///
  /// In en, this message translates to:
  /// **'Others:'**
  String get permOthers;

  /// No description provided for @permRead.
  ///
  /// In en, this message translates to:
  /// **'Read'**
  String get permRead;

  /// No description provided for @permWrite.
  ///
  /// In en, this message translates to:
  /// **'Write'**
  String get permWrite;

  /// No description provided for @permExecute.
  ///
  /// In en, this message translates to:
  /// **'Execute'**
  String get permExecute;

  /// No description provided for @previewNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Preview not available'**
  String get previewNotAvailable;

  /// No description provided for @previewImageError.
  ///
  /// In en, this message translates to:
  /// **'Error loading image'**
  String get previewImageError;

  /// No description provided for @previewDocLoadError.
  ///
  /// In en, this message translates to:
  /// **'Error loading document'**
  String get previewDocLoadError;

  /// No description provided for @previewOpenExternally.
  ///
  /// In en, this message translates to:
  /// **'Open with external viewer'**
  String get previewOpenExternally;

  /// No description provided for @previewDocumentTitle.
  ///
  /// In en, this message translates to:
  /// **'Document preview'**
  String get previewDocumentTitle;

  /// No description provided for @previewDocLegacyFormat.
  ///
  /// In en, this message translates to:
  /// **'.doc is not supported. Use .docx or open with an external viewer.'**
  String get previewDocLegacyFormat;

  /// No description provided for @previewSheetLoadError.
  ///
  /// In en, this message translates to:
  /// **'Error loading spreadsheet'**
  String get previewSheetLoadError;

  /// No description provided for @previewSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Spreadsheet preview'**
  String get previewSheetTitle;

  /// No description provided for @previewXlsLegacyFormat.
  ///
  /// In en, this message translates to:
  /// **'.xls is not supported. Use .xlsx or open with an external viewer.'**
  String get previewXlsLegacyFormat;

  /// No description provided for @previewPresentationLoadError.
  ///
  /// In en, this message translates to:
  /// **'Error loading presentation'**
  String get previewPresentationLoadError;

  /// No description provided for @previewOpenOfficeTitle.
  ///
  /// In en, this message translates to:
  /// **'OpenOffice preview'**
  String get previewOpenOfficeTitle;

  /// No description provided for @previewOpenOfficeBody.
  ///
  /// In en, this message translates to:
  /// **'OpenOffice files require an external viewer.'**
  String get previewOpenOfficeBody;

  /// No description provided for @themeApplied.
  ///
  /// In en, this message translates to:
  /// **'Theme \"{name}\" applied'**
  String themeApplied(String name);

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark theme'**
  String get themeDark;

  /// No description provided for @themeFontSizeTitle.
  ///
  /// In en, this message translates to:
  /// **'Font size: {size}'**
  String themeFontSizeTitle(String size);

  /// No description provided for @themeFontWeightSection.
  ///
  /// In en, this message translates to:
  /// **'Font weight'**
  String get themeFontWeightSection;

  /// No description provided for @themeBoldLabel.
  ///
  /// In en, this message translates to:
  /// **'Bold'**
  String get themeBoldLabel;

  /// No description provided for @themeTextShadowSection.
  ///
  /// In en, this message translates to:
  /// **'Text shadow'**
  String get themeTextShadowSection;

  /// No description provided for @themeShadowIntensity.
  ///
  /// In en, this message translates to:
  /// **'Shadow intensity: {percent}%'**
  String themeShadowIntensity(String percent);

  /// No description provided for @themeColorPicked.
  ///
  /// In en, this message translates to:
  /// **'Color selected'**
  String get themeColorPicked;

  /// No description provided for @themeSelectToCustomize.
  ///
  /// In en, this message translates to:
  /// **'Select a theme to customize'**
  String get themeSelectToCustomize;

  /// No description provided for @themeFontFamilySection.
  ///
  /// In en, this message translates to:
  /// **'Font family'**
  String get themeFontFamilySection;

  /// No description provided for @searchNeedCriterion.
  ///
  /// In en, this message translates to:
  /// **'Enter at least one search criterion'**
  String get searchNeedCriterion;

  /// No description provided for @searchCurrentPath.
  ///
  /// In en, this message translates to:
  /// **'Current path'**
  String get searchCurrentPath;

  /// No description provided for @searchButton.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get searchButton;

  /// No description provided for @pkgConfirmUninstallTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm uninstall'**
  String get pkgConfirmUninstallTitle;

  /// No description provided for @pkgConfirmUninstallBody.
  ///
  /// In en, this message translates to:
  /// **'Uninstall {name}?'**
  String pkgConfirmUninstallBody(String name);

  /// No description provided for @pkgDependenciesTitle.
  ///
  /// In en, this message translates to:
  /// **'Dependencies found'**
  String get pkgDependenciesTitle;

  /// No description provided for @pkgUninstallError.
  ///
  /// In en, this message translates to:
  /// **'Error during uninstall'**
  String get pkgUninstallError;

  /// No description provided for @pkgManagerTitle.
  ///
  /// In en, this message translates to:
  /// **'Application manager'**
  String get pkgManagerTitle;

  /// No description provided for @pkgInstallTitle.
  ///
  /// In en, this message translates to:
  /// **'Install package'**
  String get pkgInstallTitle;

  /// No description provided for @pkgInstallBody.
  ///
  /// In en, this message translates to:
  /// **'Install \"{name}\"?'**
  String pkgInstallBody(String name);

  /// No description provided for @pkgMadeExecutable.
  ///
  /// In en, this message translates to:
  /// **'{name} made executable'**
  String pkgMadeExecutable(String name);

  /// No description provided for @pkgUnsupportedFormat.
  ///
  /// In en, this message translates to:
  /// **'Unsupported package format'**
  String get pkgUnsupportedFormat;

  /// No description provided for @pkgInstallErrorOutput.
  ///
  /// In en, this message translates to:
  /// **'Install error: {output}'**
  String pkgInstallErrorOutput(String output);

  /// No description provided for @updateItemSuccess.
  ///
  /// In en, this message translates to:
  /// **'{name} updated successfully'**
  String updateItemSuccess(String name);

  /// No description provided for @updateItemError.
  ///
  /// In en, this message translates to:
  /// **'Error updating {name}'**
  String updateItemError(String name);

  /// No description provided for @updateAllError.
  ///
  /// In en, this message translates to:
  /// **'Error installing updates'**
  String get updateAllError;

  /// No description provided for @updateInstallAllButton.
  ///
  /// In en, this message translates to:
  /// **'Install all'**
  String get updateInstallAllButton;

  /// No description provided for @previewCatImages.
  ///
  /// In en, this message translates to:
  /// **'Images'**
  String get previewCatImages;

  /// No description provided for @previewCatDocuments.
  ///
  /// In en, this message translates to:
  /// **'Documents'**
  String get previewCatDocuments;

  /// No description provided for @previewCatText.
  ///
  /// In en, this message translates to:
  /// **'Text'**
  String get previewCatText;

  /// No description provided for @previewCatWeb.
  ///
  /// In en, this message translates to:
  /// **'Web'**
  String get previewCatWeb;

  /// No description provided for @previewCatOffice.
  ///
  /// In en, this message translates to:
  /// **'Office'**
  String get previewCatOffice;

  /// No description provided for @previewExtTitle.
  ///
  /// In en, this message translates to:
  /// **'.{ext} — {name}'**
  String previewExtTitle(String ext, String name);

  /// No description provided for @bulkRenamePatternExample.
  ///
  /// In en, this message translates to:
  /// **'{a}, {a}_{b}, Document_{b}'**
  String bulkRenamePatternExample(String a, String b);

  /// No description provided for @tableColumnName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get tableColumnName;

  /// No description provided for @tableColumnPath.
  ///
  /// In en, this message translates to:
  /// **'Path'**
  String get tableColumnPath;

  /// No description provided for @tableColumnSize.
  ///
  /// In en, this message translates to:
  /// **'Size'**
  String get tableColumnSize;

  /// No description provided for @tableColumnModified.
  ///
  /// In en, this message translates to:
  /// **'Modified'**
  String get tableColumnModified;

  /// No description provided for @tableColumnType.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get tableColumnType;

  /// No description provided for @networkBrowserTitle.
  ///
  /// In en, this message translates to:
  /// **'Browse network'**
  String get networkBrowserTitle;

  /// No description provided for @networkSearchingServers.
  ///
  /// In en, this message translates to:
  /// **'Searching for network servers…'**
  String get networkSearchingServers;

  /// No description provided for @networkNoServersFound.
  ///
  /// In en, this message translates to:
  /// **'No network servers found'**
  String get networkNoServersFound;

  /// No description provided for @networkServersSharesHeader.
  ///
  /// In en, this message translates to:
  /// **'Servers and shares'**
  String get networkServersSharesHeader;

  /// No description provided for @labelUsername.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get labelUsername;

  /// No description provided for @labelPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get labelPassword;

  /// No description provided for @networkRefreshTooltip.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get networkRefreshTooltip;

  /// No description provided for @networkNoSharesAvailable.
  ///
  /// In en, this message translates to:
  /// **'No shares available'**
  String get networkNoSharesAvailable;

  /// No description provided for @networkInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'Information'**
  String get networkInfoTitle;

  /// No description provided for @networkServersFoundCount.
  ///
  /// In en, this message translates to:
  /// **'Servers found: {count}'**
  String networkServersFoundCount(int count);

  /// No description provided for @networkConnectShareInstructions.
  ///
  /// In en, this message translates to:
  /// **'To connect to a share, expand a server and tap the share you want.'**
  String get networkConnectShareInstructions;

  /// No description provided for @networkSelectedServerLabel.
  ///
  /// In en, this message translates to:
  /// **'Selected server:'**
  String get networkSelectedServerLabel;

  /// No description provided for @networkSharesCount.
  ///
  /// In en, this message translates to:
  /// **'Shares: {count}'**
  String networkSharesCount(int count);

  /// No description provided for @sidebarTooltipBrowseNetworkPaths.
  ///
  /// In en, this message translates to:
  /// **'Browse network paths'**
  String get sidebarTooltipBrowseNetworkPaths;

  /// No description provided for @sidebarTooltipAddNetworkPath.
  ///
  /// In en, this message translates to:
  /// **'Add network path'**
  String get sidebarTooltipAddNetworkPath;

  /// No description provided for @sidebarSectionNetwork.
  ///
  /// In en, this message translates to:
  /// **'Network'**
  String get sidebarSectionNetwork;

  /// No description provided for @sidebarSectionDisks.
  ///
  /// In en, this message translates to:
  /// **'Disks'**
  String get sidebarSectionDisks;

  /// No description provided for @sidebarAddPath.
  ///
  /// In en, this message translates to:
  /// **'Add path'**
  String get sidebarAddPath;

  /// No description provided for @sidebarUserFolderHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get sidebarUserFolderHome;

  /// No description provided for @sidebarUserFolderDesktop.
  ///
  /// In en, this message translates to:
  /// **'Desktop'**
  String get sidebarUserFolderDesktop;

  /// No description provided for @sidebarUserFolderDocuments.
  ///
  /// In en, this message translates to:
  /// **'Documents'**
  String get sidebarUserFolderDocuments;

  /// No description provided for @sidebarUserFolderPictures.
  ///
  /// In en, this message translates to:
  /// **'Pictures'**
  String get sidebarUserFolderPictures;

  /// No description provided for @sidebarUserFolderMusic.
  ///
  /// In en, this message translates to:
  /// **'Music'**
  String get sidebarUserFolderMusic;

  /// No description provided for @sidebarUserFolderVideos.
  ///
  /// In en, this message translates to:
  /// **'Videos'**
  String get sidebarUserFolderVideos;

  /// No description provided for @sidebarUserFolderDownloads.
  ///
  /// In en, this message translates to:
  /// **'Downloads'**
  String get sidebarUserFolderDownloads;

  /// No description provided for @sidebarSectionFavorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get sidebarSectionFavorites;

  /// No description provided for @commonUnknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get commonUnknown;

  /// No description provided for @prefsClearCacheButton.
  ///
  /// In en, this message translates to:
  /// **'Clear cache'**
  String get prefsClearCacheButton;

  /// No description provided for @prefsClearCacheTitle.
  ///
  /// In en, this message translates to:
  /// **'Clear cache'**
  String get prefsClearCacheTitle;

  /// No description provided for @prefsClearCacheBody.
  ///
  /// In en, this message translates to:
  /// **'Clear all thumbnail preview cache?'**
  String get prefsClearCacheBody;

  /// No description provided for @prefsClearCacheConfirm.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get prefsClearCacheConfirm;

  /// No description provided for @snackPrefsCacheCleared.
  ///
  /// In en, this message translates to:
  /// **'Cache cleared'**
  String get snackPrefsCacheCleared;

  /// No description provided for @previewFmtJpeg.
  ///
  /// In en, this message translates to:
  /// **'JPEG image'**
  String get previewFmtJpeg;

  /// No description provided for @previewFmtPng.
  ///
  /// In en, this message translates to:
  /// **'PNG image'**
  String get previewFmtPng;

  /// No description provided for @previewFmtGif.
  ///
  /// In en, this message translates to:
  /// **'GIF image'**
  String get previewFmtGif;

  /// No description provided for @previewFmtBmp.
  ///
  /// In en, this message translates to:
  /// **'BMP image'**
  String get previewFmtBmp;

  /// No description provided for @previewFmtWebp.
  ///
  /// In en, this message translates to:
  /// **'WebP image'**
  String get previewFmtWebp;

  /// No description provided for @previewFmtPdf.
  ///
  /// In en, this message translates to:
  /// **'PDF document'**
  String get previewFmtPdf;

  /// No description provided for @previewFmtPlainText.
  ///
  /// In en, this message translates to:
  /// **'Text file'**
  String get previewFmtPlainText;

  /// No description provided for @previewFmtMarkdown.
  ///
  /// In en, this message translates to:
  /// **'Markdown'**
  String get previewFmtMarkdown;

  /// No description provided for @previewFmtNfo.
  ///
  /// In en, this message translates to:
  /// **'Info file'**
  String get previewFmtNfo;

  /// No description provided for @previewFmtShell.
  ///
  /// In en, this message translates to:
  /// **'Shell script'**
  String get previewFmtShell;

  /// No description provided for @previewFmtHtml.
  ///
  /// In en, this message translates to:
  /// **'HTML document'**
  String get previewFmtHtml;

  /// No description provided for @previewFmtDocx.
  ///
  /// In en, this message translates to:
  /// **'Word document'**
  String get previewFmtDocx;

  /// No description provided for @previewFmtXlsx.
  ///
  /// In en, this message translates to:
  /// **'Excel spreadsheet'**
  String get previewFmtXlsx;

  /// No description provided for @previewFmtPptx.
  ///
  /// In en, this message translates to:
  /// **'PowerPoint presentation'**
  String get previewFmtPptx;

  /// No description provided for @themeAppliedSnackbar.
  ///
  /// In en, this message translates to:
  /// **'Theme \"{name}\" applied'**
  String themeAppliedSnackbar(String name);

  /// No description provided for @themeEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit theme'**
  String get themeEditTitle;

  /// No description provided for @themeNewTitle.
  ///
  /// In en, this message translates to:
  /// **'New theme'**
  String get themeNewTitle;

  /// No description provided for @themeFieldName.
  ///
  /// In en, this message translates to:
  /// **'Theme name'**
  String get themeFieldName;

  /// No description provided for @themeDarkThemeSwitch.
  ///
  /// In en, this message translates to:
  /// **'Dark theme'**
  String get themeDarkThemeSwitch;

  /// No description provided for @themeColorPrimary.
  ///
  /// In en, this message translates to:
  /// **'Primary color'**
  String get themeColorPrimary;

  /// No description provided for @themeColorSecondary.
  ///
  /// In en, this message translates to:
  /// **'Secondary color'**
  String get themeColorSecondary;

  /// No description provided for @themeColorFile.
  ///
  /// In en, this message translates to:
  /// **'File color'**
  String get themeColorFile;

  /// No description provided for @themeColorLocation.
  ///
  /// In en, this message translates to:
  /// **'Location bar color'**
  String get themeColorLocation;

  /// No description provided for @themeColorBackground.
  ///
  /// In en, this message translates to:
  /// **'Background color'**
  String get themeColorBackground;

  /// No description provided for @themeColorFolder.
  ///
  /// In en, this message translates to:
  /// **'Folder color'**
  String get themeColorFolder;

  /// No description provided for @themeFolderIconsHint.
  ///
  /// In en, this message translates to:
  /// **'Icons are applied automatically based on folder type.'**
  String get themeFolderIconsHint;

  /// No description provided for @themeFolderIconPickColor.
  ///
  /// In en, this message translates to:
  /// **'Pick a color for folder icons'**
  String get themeFolderIconPickColor;

  /// No description provided for @themeColorPickedSnack.
  ///
  /// In en, this message translates to:
  /// **'Color selected'**
  String get themeColorPickedSnack;

  /// No description provided for @themeManagerTitle.
  ///
  /// In en, this message translates to:
  /// **'Theme management'**
  String get themeManagerTitle;

  /// No description provided for @themeBuiltinHeader.
  ///
  /// In en, this message translates to:
  /// **'Built-in themes'**
  String get themeBuiltinHeader;

  /// No description provided for @themeCustomHeader.
  ///
  /// In en, this message translates to:
  /// **'Custom themes'**
  String get themeCustomHeader;

  /// No description provided for @themeCustomizationHeader.
  ///
  /// In en, this message translates to:
  /// **'Customization'**
  String get themeCustomizationHeader;

  /// No description provided for @themeSelectPrompt.
  ///
  /// In en, this message translates to:
  /// **'Select a theme to customize'**
  String get themeSelectPrompt;

  /// No description provided for @themeVariantLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeVariantLight;

  /// No description provided for @themeVariantDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeVariantDark;

  /// No description provided for @themeColorsHeader.
  ///
  /// In en, this message translates to:
  /// **'Colors'**
  String get themeColorsHeader;

  /// No description provided for @themeFontHeader.
  ///
  /// In en, this message translates to:
  /// **'Font'**
  String get themeFontHeader;

  /// No description provided for @themeFontFamilyRow.
  ///
  /// In en, this message translates to:
  /// **'Font family'**
  String get themeFontFamilyRow;

  /// No description provided for @themeFontSizeRow.
  ///
  /// In en, this message translates to:
  /// **'Font size: {size}'**
  String themeFontSizeRow(String size);

  /// No description provided for @themeFontWeightHeader.
  ///
  /// In en, this message translates to:
  /// **'Font weight'**
  String get themeFontWeightHeader;

  /// No description provided for @themeTextShadow.
  ///
  /// In en, this message translates to:
  /// **'Text shadow'**
  String get themeTextShadow;

  /// No description provided for @themeIconShadowTitle.
  ///
  /// In en, this message translates to:
  /// **'Icon shadow (grid)'**
  String get themeIconShadowTitle;

  /// No description provided for @themeIconShadowSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Drop shadow under file and folder icons in grid view'**
  String get themeIconShadowSubtitle;

  /// No description provided for @themeIconShadowIntensity.
  ///
  /// In en, this message translates to:
  /// **'Icon shadow intensity: {percent}%'**
  String themeIconShadowIntensity(String percent);

  /// No description provided for @themeShadowIntensityRow.
  ///
  /// In en, this message translates to:
  /// **'Shadow intensity: {percent}%'**
  String themeShadowIntensityRow(String percent);

  /// No description provided for @themeFolderIconFolder.
  ///
  /// In en, this message translates to:
  /// **'Folder'**
  String get themeFolderIconFolder;

  /// No description provided for @themeFolderIconFolderOpen.
  ///
  /// In en, this message translates to:
  /// **'Folder open'**
  String get themeFolderIconFolderOpen;

  /// No description provided for @themeFolderIconFolderSpecial.
  ///
  /// In en, this message translates to:
  /// **'Folder special'**
  String get themeFolderIconFolderSpecial;

  /// No description provided for @themeFolderIconFolderShared.
  ///
  /// In en, this message translates to:
  /// **'Folder shared'**
  String get themeFolderIconFolderShared;

  /// No description provided for @themeFolderIconFolderCopy.
  ///
  /// In en, this message translates to:
  /// **'Folder copy'**
  String get themeFolderIconFolderCopy;

  /// No description provided for @themeFolderIconFolderDelete.
  ///
  /// In en, this message translates to:
  /// **'Folder delete'**
  String get themeFolderIconFolderDelete;

  /// No description provided for @themeFolderIconFolderZip.
  ///
  /// In en, this message translates to:
  /// **'Folder zip'**
  String get themeFolderIconFolderZip;

  /// No description provided for @themeFolderIconFolderOff.
  ///
  /// In en, this message translates to:
  /// **'Folder off'**
  String get themeFolderIconFolderOff;

  /// No description provided for @themeFolderIconFolderPlus.
  ///
  /// In en, this message translates to:
  /// **'New folder'**
  String get themeFolderIconFolderPlus;

  /// No description provided for @themeFolderIconFolderHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get themeFolderIconFolderHome;

  /// No description provided for @themeFolderIconFolderDrive.
  ///
  /// In en, this message translates to:
  /// **'Drive'**
  String get themeFolderIconFolderDrive;

  /// No description provided for @themeFolderIconFolderCloud.
  ///
  /// In en, this message translates to:
  /// **'Cloud'**
  String get themeFolderIconFolderCloud;

  /// No description provided for @propsTitle.
  ///
  /// In en, this message translates to:
  /// **'Properties'**
  String get propsTitle;

  /// No description provided for @propsTimeoutLoading.
  ///
  /// In en, this message translates to:
  /// **'Timed out loading properties'**
  String get propsTimeoutLoading;

  /// No description provided for @propsLoadErrorDetail.
  ///
  /// In en, this message translates to:
  /// **'Error loading properties: {detail}'**
  String propsLoadErrorDetail(String detail);

  /// No description provided for @propsFieldName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get propsFieldName;

  /// No description provided for @propsFieldPath.
  ///
  /// In en, this message translates to:
  /// **'Path'**
  String get propsFieldPath;

  /// No description provided for @propsFieldType.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get propsFieldType;

  /// No description provided for @propsFieldSize.
  ///
  /// In en, this message translates to:
  /// **'Size'**
  String get propsFieldSize;

  /// No description provided for @propsFieldSizeOnDisk.
  ///
  /// In en, this message translates to:
  /// **'Size on disk'**
  String get propsFieldSizeOnDisk;

  /// No description provided for @propsFieldModified.
  ///
  /// In en, this message translates to:
  /// **'Modified'**
  String get propsFieldModified;

  /// No description provided for @propsFieldAccessed.
  ///
  /// In en, this message translates to:
  /// **'Accessed'**
  String get propsFieldAccessed;

  /// No description provided for @propsFieldCreated.
  ///
  /// In en, this message translates to:
  /// **'Created'**
  String get propsFieldCreated;

  /// No description provided for @propsFieldOwner.
  ///
  /// In en, this message translates to:
  /// **'Owner'**
  String get propsFieldOwner;

  /// No description provided for @propsFieldGroup.
  ///
  /// In en, this message translates to:
  /// **'Group'**
  String get propsFieldGroup;

  /// No description provided for @propsFieldPermissions.
  ///
  /// In en, this message translates to:
  /// **'Permissions'**
  String get propsFieldPermissions;

  /// No description provided for @propsFieldInode.
  ///
  /// In en, this message translates to:
  /// **'Inode'**
  String get propsFieldInode;

  /// No description provided for @propsFieldLinks.
  ///
  /// In en, this message translates to:
  /// **'Links'**
  String get propsFieldLinks;

  /// No description provided for @propsFieldFilesInside.
  ///
  /// In en, this message translates to:
  /// **'Files inside'**
  String get propsFieldFilesInside;

  /// No description provided for @propsFieldDirsInside.
  ///
  /// In en, this message translates to:
  /// **'Folders inside'**
  String get propsFieldDirsInside;

  /// No description provided for @propsTypeFolder.
  ///
  /// In en, this message translates to:
  /// **'Folder'**
  String get propsTypeFolder;

  /// No description provided for @propsTypeFile.
  ///
  /// In en, this message translates to:
  /// **'File'**
  String get propsTypeFile;

  /// No description provided for @propsMultiSelectionTitle.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{1 item selected} other{{count} items selected}}'**
  String propsMultiSelectionTitle(int count);

  /// No description provided for @propsMultiTypeMixed.
  ///
  /// In en, this message translates to:
  /// **'Mixed (files and folders)'**
  String get propsMultiTypeMixed;

  /// No description provided for @propsMultiCombinedSize.
  ///
  /// In en, this message translates to:
  /// **'Total size on disk'**
  String get propsMultiCombinedSize;

  /// No description provided for @propsMultiLoadingSizes.
  ///
  /// In en, this message translates to:
  /// **'Calculating sizes…'**
  String get propsMultiLoadingSizes;

  /// No description provided for @propsMultiPerItemTitle.
  ///
  /// In en, this message translates to:
  /// **'Each item'**
  String get propsMultiPerItemTitle;

  /// No description provided for @propsMultiCountSummary.
  ///
  /// In en, this message translates to:
  /// **'{folderCount} folders, {fileCount} files'**
  String propsMultiCountSummary(int folderCount, int fileCount);

  /// No description provided for @propsEditTooltip.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get propsEditTooltip;

  /// No description provided for @propsHintNewValue.
  ///
  /// In en, this message translates to:
  /// **'Enter new value'**
  String get propsHintNewValue;

  /// No description provided for @propsPermissionsDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit permissions'**
  String get propsPermissionsDialogTitle;

  /// No description provided for @propsPermOwnerSection.
  ///
  /// In en, this message translates to:
  /// **'Owner:'**
  String get propsPermOwnerSection;

  /// No description provided for @propsPermGroupSection.
  ///
  /// In en, this message translates to:
  /// **'Group:'**
  String get propsPermGroupSection;

  /// No description provided for @propsPermOtherSection.
  ///
  /// In en, this message translates to:
  /// **'Others:'**
  String get propsPermOtherSection;

  /// No description provided for @propsInvalidPermissionsFormat.
  ///
  /// In en, this message translates to:
  /// **'Invalid permissions format'**
  String get propsInvalidPermissionsFormat;

  /// No description provided for @propsChmodFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not change permissions: {detail}'**
  String propsChmodFailed(String detail);

  /// No description provided for @pkgPageTitle.
  ///
  /// In en, this message translates to:
  /// **'Applications'**
  String get pkgPageTitle;

  /// No description provided for @pkgInstallFromFileTooltip.
  ///
  /// In en, this message translates to:
  /// **'Install package from file'**
  String get pkgInstallFromFileTooltip;

  /// No description provided for @pkgFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get pkgFilterAll;

  /// No description provided for @pkgSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search applications…'**
  String get pkgSearchHint;

  /// No description provided for @pkgUninstallTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm uninstall'**
  String get pkgUninstallTitle;

  /// No description provided for @pkgUninstallConfirm.
  ///
  /// In en, this message translates to:
  /// **'Uninstall {name}?'**
  String pkgUninstallConfirm(String name);

  /// No description provided for @pkgUninstallButton.
  ///
  /// In en, this message translates to:
  /// **'Uninstall'**
  String get pkgUninstallButton;

  /// No description provided for @pkgDepsTitle.
  ///
  /// In en, this message translates to:
  /// **'Dependencies found'**
  String get pkgDepsTitle;

  /// No description provided for @pkgDepsUsedByBody.
  ///
  /// In en, this message translates to:
  /// **'This package is used by:\n{list}'**
  String pkgDepsUsedByBody(String list);

  /// No description provided for @pkgProceedAnyway.
  ///
  /// In en, this message translates to:
  /// **'Proceed anyway'**
  String get pkgProceedAnyway;

  /// No description provided for @pkgUninstalled.
  ///
  /// In en, this message translates to:
  /// **'{name} uninstalled'**
  String pkgUninstalled(Object name);

  /// No description provided for @pkgUninstallFailed.
  ///
  /// In en, this message translates to:
  /// **'Error during uninstall'**
  String get pkgUninstallFailed;

  /// No description provided for @pkgInstallDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Install package'**
  String get pkgInstallDialogTitle;

  /// No description provided for @pkgInstallConfirm.
  ///
  /// In en, this message translates to:
  /// **'Install \"{name}\"?'**
  String pkgInstallConfirm(String name);

  /// No description provided for @pkgInstallButton.
  ///
  /// In en, this message translates to:
  /// **'Install'**
  String get pkgInstallButton;

  /// No description provided for @pkgInstallProgressTitle.
  ///
  /// In en, this message translates to:
  /// **'Installing package'**
  String get pkgInstallProgressTitle;

  /// No description provided for @pkgInstallRunningStatus.
  ///
  /// In en, this message translates to:
  /// **'Starting installer…'**
  String get pkgInstallRunningStatus;

  /// No description provided for @zipProgressPanelTitle.
  ///
  /// In en, this message translates to:
  /// **'Compressing to ZIP'**
  String get zipProgressPanelTitle;

  /// No description provided for @zipProgressSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Adding files to archive'**
  String get zipProgressSubtitle;

  /// No description provided for @zipProgressEncoding.
  ///
  /// In en, this message translates to:
  /// **'Writing archive…'**
  String get zipProgressEncoding;

  /// No description provided for @pkgExecutableMade.
  ///
  /// In en, this message translates to:
  /// **'{name} is now executable'**
  String pkgExecutableMade(String name);

  /// No description provided for @pkgUnsupportedPackage.
  ///
  /// In en, this message translates to:
  /// **'Unsupported package format'**
  String get pkgUnsupportedPackage;

  /// No description provided for @pkgInstalledSuccess.
  ///
  /// In en, this message translates to:
  /// **'{name} installed successfully'**
  String pkgInstalledSuccess(String name);

  /// No description provided for @pkgInstallFailedWithError.
  ///
  /// In en, this message translates to:
  /// **'Install error: {detail}'**
  String pkgInstallFailedWithError(String detail);

  /// No description provided for @updateTitle.
  ///
  /// In en, this message translates to:
  /// **'Updates'**
  String get updateTitle;

  /// No description provided for @updateTitleWithCount.
  ///
  /// In en, this message translates to:
  /// **'Updates ({count})'**
  String updateTitleWithCount(int count);

  /// No description provided for @updateInstallAll.
  ///
  /// In en, this message translates to:
  /// **'Install all'**
  String get updateInstallAll;

  /// No description provided for @updateNoneAvailable.
  ///
  /// In en, this message translates to:
  /// **'No updates available'**
  String get updateNoneAvailable;

  /// No description provided for @updateTypeLine.
  ///
  /// In en, this message translates to:
  /// **'Type: {type}'**
  String updateTypeLine(String type);

  /// No description provided for @updateCurrentVersionLine.
  ///
  /// In en, this message translates to:
  /// **'Current version: {v}'**
  String updateCurrentVersionLine(String v);

  /// No description provided for @updateAvailableVersionLine.
  ///
  /// In en, this message translates to:
  /// **'Available version: {v}'**
  String updateAvailableVersionLine(String v);

  /// No description provided for @updateInstallTooltip.
  ///
  /// In en, this message translates to:
  /// **'Install update'**
  String get updateInstallTooltip;

  /// No description provided for @updateUpdatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'{name} updated successfully'**
  String updateUpdatedSuccess(String name);

  /// No description provided for @updateOneFailed.
  ///
  /// In en, this message translates to:
  /// **'Error updating {name}'**
  String updateOneFailed(String name);

  /// No description provided for @updateInstallAllTitle.
  ///
  /// In en, this message translates to:
  /// **'Install all updates'**
  String get updateInstallAllTitle;

  /// No description provided for @updateInstallAllBody.
  ///
  /// In en, this message translates to:
  /// **'Install {count} updates?'**
  String updateInstallAllBody(int count);

  /// No description provided for @updateAllSuccess.
  ///
  /// In en, this message translates to:
  /// **'All updates installed successfully'**
  String get updateAllSuccess;

  /// No description provided for @updateAllFailed.
  ///
  /// In en, this message translates to:
  /// **'Error installing updates'**
  String get updateAllFailed;

  /// No description provided for @searchDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Find files'**
  String get searchDialogTitle;

  /// No description provided for @searchPathLabel.
  ///
  /// In en, this message translates to:
  /// **'Path: {path}'**
  String searchPathLabel(String path);

  /// No description provided for @searchSelectDiskTooltip.
  ///
  /// In en, this message translates to:
  /// **'Select drive'**
  String get searchSelectDiskTooltip;

  /// No description provided for @searchAllMountsLabel.
  ///
  /// In en, this message translates to:
  /// **'Search all mounted volumes'**
  String get searchAllMountsLabel;

  /// No description provided for @searchAllMountsHint.
  ///
  /// In en, this message translates to:
  /// **'USB drives, extra partitions, GVFS/network (where accessible). Slower than a single folder.'**
  String get searchAllMountsHint;

  /// No description provided for @searchAllMountsActive.
  ///
  /// In en, this message translates to:
  /// **'Searching {count} locations (all mounts)'**
  String searchAllMountsActive(int count);

  /// No description provided for @searchPathCurrentMenu.
  ///
  /// In en, this message translates to:
  /// **'Current path'**
  String get searchPathCurrentMenu;

  /// No description provided for @searchPathRootMenu.
  ///
  /// In en, this message translates to:
  /// **'Filesystem root'**
  String get searchPathRootMenu;

  /// No description provided for @searchLabelQuery.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get searchLabelQuery;

  /// No description provided for @searchHintQuery.
  ///
  /// In en, this message translates to:
  /// **'File name, *.mp4, *.txt…'**
  String get searchHintQuery;

  /// No description provided for @searchHelperPatterns.
  ///
  /// In en, this message translates to:
  /// **'Patterns: *.mp4, *.txt, document*.pdf'**
  String get searchHelperPatterns;

  /// No description provided for @searchLabelNameFilter.
  ///
  /// In en, this message translates to:
  /// **'Name filter'**
  String get searchLabelNameFilter;

  /// No description provided for @searchHintNameFilter.
  ///
  /// In en, this message translates to:
  /// **'e.g. document'**
  String get searchHintNameFilter;

  /// No description provided for @searchLabelExtension.
  ///
  /// In en, this message translates to:
  /// **'Extension'**
  String get searchLabelExtension;

  /// No description provided for @searchHintExtension.
  ///
  /// In en, this message translates to:
  /// **'e.g. pdf'**
  String get searchHintExtension;

  /// No description provided for @searchLabelSizeMin.
  ///
  /// In en, this message translates to:
  /// **'Min size (bytes)'**
  String get searchLabelSizeMin;

  /// No description provided for @searchLabelSizeMax.
  ///
  /// In en, this message translates to:
  /// **'Max size (bytes)'**
  String get searchLabelSizeMax;

  /// No description provided for @searchLabelFileType.
  ///
  /// In en, this message translates to:
  /// **'File type'**
  String get searchLabelFileType;

  /// No description provided for @searchLabelDateFilter.
  ///
  /// In en, this message translates to:
  /// **'Date filter'**
  String get searchLabelDateFilter;

  /// No description provided for @searchIncludeSystemFiles.
  ///
  /// In en, this message translates to:
  /// **'Include system files'**
  String get searchIncludeSystemFiles;

  /// No description provided for @searchChoosePath.
  ///
  /// In en, this message translates to:
  /// **'Choose path'**
  String get searchChoosePath;

  /// No description provided for @searchStop.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get searchStop;

  /// No description provided for @searchSearchButton.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get searchSearchButton;

  /// No description provided for @searchNoCriteriaSnack.
  ///
  /// In en, this message translates to:
  /// **'Enter at least one search criterion'**
  String get searchNoCriteriaSnack;

  /// No description provided for @searchError.
  ///
  /// In en, this message translates to:
  /// **'Search error: {error}'**
  String searchError(String error);

  /// No description provided for @searchNoResults.
  ///
  /// In en, this message translates to:
  /// **'No results'**
  String get searchNoResults;

  /// No description provided for @searchResultsOne.
  ///
  /// In en, this message translates to:
  /// **'1 result found'**
  String get searchResultsOne;

  /// No description provided for @searchResultsMany.
  ///
  /// In en, this message translates to:
  /// **'{count} results found'**
  String searchResultsMany(int count);

  /// No description provided for @searchTooltipViewList.
  ///
  /// In en, this message translates to:
  /// **'List'**
  String get searchTooltipViewList;

  /// No description provided for @searchTooltipViewGrid.
  ///
  /// In en, this message translates to:
  /// **'Grid'**
  String get searchTooltipViewGrid;

  /// No description provided for @searchTooltipViewDetails.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get searchTooltipViewDetails;

  /// No description provided for @searchZoomOut.
  ///
  /// In en, this message translates to:
  /// **'Zoom out'**
  String get searchZoomOut;

  /// No description provided for @searchZoomIn.
  ///
  /// In en, this message translates to:
  /// **'Zoom in'**
  String get searchZoomIn;

  /// No description provided for @searchTypeAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get searchTypeAll;

  /// No description provided for @searchTypeImages.
  ///
  /// In en, this message translates to:
  /// **'Images'**
  String get searchTypeImages;

  /// No description provided for @searchTypeVideo.
  ///
  /// In en, this message translates to:
  /// **'Video'**
  String get searchTypeVideo;

  /// No description provided for @searchTypeAudio.
  ///
  /// In en, this message translates to:
  /// **'Audio'**
  String get searchTypeAudio;

  /// No description provided for @searchTypeDocuments.
  ///
  /// In en, this message translates to:
  /// **'Documents'**
  String get searchTypeDocuments;

  /// No description provided for @searchTypeArchives.
  ///
  /// In en, this message translates to:
  /// **'Archives'**
  String get searchTypeArchives;

  /// No description provided for @searchTypeExecutables.
  ///
  /// In en, this message translates to:
  /// **'Executables'**
  String get searchTypeExecutables;

  /// No description provided for @searchDateAll.
  ///
  /// In en, this message translates to:
  /// **'Any time'**
  String get searchDateAll;

  /// No description provided for @searchDateToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get searchDateToday;

  /// No description provided for @searchDateWeek.
  ///
  /// In en, this message translates to:
  /// **'Last week'**
  String get searchDateWeek;

  /// No description provided for @searchDateMonth.
  ///
  /// In en, this message translates to:
  /// **'Last month'**
  String get searchDateMonth;

  /// No description provided for @searchDateYear.
  ///
  /// In en, this message translates to:
  /// **'Last year'**
  String get searchDateYear;

  /// No description provided for @statusDiskPercent.
  ///
  /// In en, this message translates to:
  /// **'{value}%'**
  String statusDiskPercent(String value);

  /// No description provided for @depsDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'System components'**
  String get depsDialogTitle;

  /// No description provided for @depsDialogIntro.
  ///
  /// In en, this message translates to:
  /// **'The following components are missing. The app works best when they are installed. You can install them now using your administrator password (PolicyKit).'**
  String get depsDialogIntro;

  /// No description provided for @depsInstallButton.
  ///
  /// In en, this message translates to:
  /// **'Install now (admin password)'**
  String get depsInstallButton;

  /// No description provided for @depsContinueButton.
  ///
  /// In en, this message translates to:
  /// **'Continue without installing'**
  String get depsContinueButton;

  /// No description provided for @depsInstalling.
  ///
  /// In en, this message translates to:
  /// **'Installing packages…'**
  String get depsInstalling;

  /// No description provided for @depsInstallSuccess.
  ///
  /// In en, this message translates to:
  /// **'Installation completed successfully.'**
  String get depsInstallSuccess;

  /// No description provided for @depsInstallFailed.
  ///
  /// In en, this message translates to:
  /// **'Installation failed: {message}'**
  String depsInstallFailed(String message);

  /// No description provided for @depsUnknownDistro.
  ///
  /// In en, this message translates to:
  /// **'Automatic installation is not available for this Linux distribution. Install the packages manually in a terminal.'**
  String get depsUnknownDistro;

  /// No description provided for @depsManualCommandLabel.
  ///
  /// In en, this message translates to:
  /// **'Suggested command'**
  String get depsManualCommandLabel;

  /// No description provided for @depsPkexecNotFound.
  ///
  /// In en, this message translates to:
  /// **'pkexec was not found. Run this in a terminal:'**
  String get depsPkexecNotFound;

  /// No description provided for @depsRustUnavailable.
  ///
  /// In en, this message translates to:
  /// **'The native library (Rust) was not loaded. Copying large files may be slower. Reinstall the application if this continues.'**
  String get depsRustUnavailable;

  /// No description provided for @depLabelXdgOpen.
  ///
  /// In en, this message translates to:
  /// **'xdg-open — open files with default applications'**
  String get depLabelXdgOpen;

  /// No description provided for @depLabelMountCifs.
  ///
  /// In en, this message translates to:
  /// **'mount.cifs — mount SMB shares (cifs-utils)'**
  String get depLabelMountCifs;

  /// No description provided for @depsCifsInstallTitle.
  ///
  /// In en, this message translates to:
  /// **'Install cifs-utils?'**
  String get depsCifsInstallTitle;

  /// No description provided for @depsCifsInstallBody.
  ///
  /// In en, this message translates to:
  /// **'Mounting SMB shares needs mount.cifs from the cifs-utils package. Install it now with the system package manager (administrator password required)?'**
  String get depsCifsInstallBody;

  /// No description provided for @depLabelSmbclient.
  ///
  /// In en, this message translates to:
  /// **'smbclient — browse SMB/CIFS shares'**
  String get depLabelSmbclient;

  /// No description provided for @depLabelNmblookup.
  ///
  /// In en, this message translates to:
  /// **'nmblookup — find computers on the LAN (NetBIOS)'**
  String get depLabelNmblookup;

  /// No description provided for @depLabelAvahiBrowse.
  ///
  /// In en, this message translates to:
  /// **'avahi-browse — find computers via network discovery (mDNS)'**
  String get depLabelAvahiBrowse;

  /// No description provided for @depLabelAvahiResolve.
  ///
  /// In en, this message translates to:
  /// **'avahi-resolve-address — resolve host names on the LAN (mDNS)'**
  String get depLabelAvahiResolve;

  /// No description provided for @depsNetworkBannerHint.
  ///
  /// In en, this message translates to:
  /// **'Some optional tools for finding PCs on the network and mounting shares are missing. You can install them automatically (administrator password required).'**
  String get depsNetworkBannerHint;

  /// No description provided for @depsNetworkBannerLater.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get depsNetworkBannerLater;

  /// No description provided for @depsSomeStillMissing.
  ///
  /// In en, this message translates to:
  /// **'Some tools are still missing. Try the suggested terminal command below.'**
  String get depsSomeStillMissing;

  /// No description provided for @depsPolkitAuthFailed.
  ///
  /// In en, this message translates to:
  /// **'Administrator authentication was cancelled, denied, or pkexec could not run the installer.'**
  String get depsPolkitAuthFailed;

  /// No description provided for @depsInstallOutputIntro.
  ///
  /// In en, this message translates to:
  /// **'Package manager output:'**
  String get depsInstallOutputIntro;

  /// No description provided for @depsInstallUnexpected.
  ///
  /// In en, this message translates to:
  /// **'unexpected error'**
  String get depsInstallUnexpected;

  /// No description provided for @depsDialogIntroRustOnly.
  ///
  /// In en, this message translates to:
  /// **'Native acceleration for some file operations is not available (Rust library).'**
  String get depsDialogIntroRustOnly;

  /// No description provided for @depsDialogIntroToolsOk.
  ///
  /// In en, this message translates to:
  /// **'Required command-line tools are installed.'**
  String get depsDialogIntroToolsOk;

  /// No description provided for @depsCloseButton.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get depsCloseButton;

  /// No description provided for @computerTitle.
  ///
  /// In en, this message translates to:
  /// **'Computer'**
  String get computerTitle;

  /// No description provided for @computerOnDevice.
  ///
  /// In en, this message translates to:
  /// **'On this device'**
  String get computerOnDevice;

  /// No description provided for @computerNetworks.
  ///
  /// In en, this message translates to:
  /// **'Network'**
  String get computerNetworks;

  /// No description provided for @computerNoVolumes.
  ///
  /// In en, this message translates to:
  /// **'No volumes found'**
  String get computerNoVolumes;

  /// No description provided for @computerNoServers.
  ///
  /// In en, this message translates to:
  /// **'No servers found'**
  String get computerNoServers;

  /// No description provided for @computerTools.
  ///
  /// In en, this message translates to:
  /// **'Tools'**
  String get computerTools;

  /// No description provided for @computerToolFindFiles.
  ///
  /// In en, this message translates to:
  /// **'Find files and folders'**
  String get computerToolFindFiles;

  /// No description provided for @computerToolPackages.
  ///
  /// In en, this message translates to:
  /// **'Uninstall/Install apps'**
  String get computerToolPackages;

  /// No description provided for @computerToolSystemUpdates.
  ///
  /// In en, this message translates to:
  /// **'Check system updates'**
  String get computerToolSystemUpdates;

  /// No description provided for @computerRefresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get computerRefresh;

  /// No description provided for @computerFreeShort.
  ///
  /// In en, this message translates to:
  /// **'{size} free'**
  String computerFreeShort(String size);

  /// No description provided for @computerNetworkHint.
  ///
  /// In en, this message translates to:
  /// **'Use the sidebar → Network to connect to {name}'**
  String computerNetworkHint(String name);

  /// No description provided for @computerVolumeOpen.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get computerVolumeOpen;

  /// No description provided for @computerFormatVolume.
  ///
  /// In en, this message translates to:
  /// **'Format…'**
  String get computerFormatVolume;

  /// No description provided for @computerFormatTitle.
  ///
  /// In en, this message translates to:
  /// **'Format volume'**
  String get computerFormatTitle;

  /// No description provided for @computerFormatWarning.
  ///
  /// In en, this message translates to:
  /// **'All data on this volume will be erased. This cannot be undone.'**
  String get computerFormatWarning;

  /// No description provided for @computerFormatFilesystem.
  ///
  /// In en, this message translates to:
  /// **'Filesystem'**
  String get computerFormatFilesystem;

  /// No description provided for @computerFormatConfirm.
  ///
  /// In en, this message translates to:
  /// **'Format'**
  String get computerFormatConfirm;

  /// No description provided for @computerFormatNotSupported.
  ///
  /// In en, this message translates to:
  /// **'Formatting from this screen is only supported on Linux with udisks2.'**
  String get computerFormatNotSupported;

  /// No description provided for @computerFormatNoDevice.
  ///
  /// In en, this message translates to:
  /// **'Could not determine the block device for this volume.'**
  String get computerFormatNoDevice;

  /// No description provided for @computerFormatSystemBlockedTitle.
  ///
  /// In en, this message translates to:
  /// **'Cannot format'**
  String get computerFormatSystemBlockedTitle;

  /// No description provided for @computerFormatSystemBlockedBody.
  ///
  /// In en, this message translates to:
  /// **'This is a system volume (root, boot, or same device as the system disk). Formatting it here is not allowed.'**
  String get computerFormatSystemBlockedBody;

  /// No description provided for @computerFormatRunning.
  ///
  /// In en, this message translates to:
  /// **'Formatting…'**
  String get computerFormatRunning;

  /// No description provided for @computerFormatDone.
  ///
  /// In en, this message translates to:
  /// **'Format completed.'**
  String get computerFormatDone;

  /// No description provided for @computerFormatFailed.
  ///
  /// In en, this message translates to:
  /// **'Format failed: {error}'**
  String computerFormatFailed(String error);

  /// No description provided for @computerMounting.
  ///
  /// In en, this message translates to:
  /// **'Connecting…'**
  String get computerMounting;

  /// No description provided for @computerMountNoShares.
  ///
  /// In en, this message translates to:
  /// **'No shares found. Check credentials, firewall, or SMB on the server.'**
  String get computerMountNoShares;

  /// No description provided for @computerMountFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not mount the share. Try different credentials, install cifs-utils, or check mount permissions.'**
  String get computerMountFailed;

  /// No description provided for @computerMountMissingGio.
  ///
  /// In en, this message translates to:
  /// **'mount.cifs was not found. Install the cifs-utils package. You may need root privileges or /etc/fstab entries to allow mounting.'**
  String get computerMountMissingGio;

  /// No description provided for @computerMountNeedPassword.
  ///
  /// In en, this message translates to:
  /// **'This share requires a username and password. Connect again and enter your credentials.'**
  String get computerMountNeedPassword;

  /// No description provided for @networkRememberPassword.
  ///
  /// In en, this message translates to:
  /// **'Remember credentials for this computer (secure storage)'**
  String get networkRememberPassword;

  /// No description provided for @dialogRootPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Administrator password'**
  String get dialogRootPasswordTitle;

  /// No description provided for @dialogRootPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password for sudo'**
  String get dialogRootPasswordLabel;

  /// No description provided for @computerSelectShare.
  ///
  /// In en, this message translates to:
  /// **'Select share'**
  String get computerSelectShare;

  /// No description provided for @computerConnect.
  ///
  /// In en, this message translates to:
  /// **'Connect'**
  String get computerConnect;

  /// No description provided for @computerCredentialsTitle.
  ///
  /// In en, this message translates to:
  /// **'Network login'**
  String get computerCredentialsTitle;

  /// No description provided for @computerUsername.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get computerUsername;

  /// No description provided for @computerPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get computerPassword;

  /// No description provided for @computerDiskProperties.
  ///
  /// In en, this message translates to:
  /// **'Properties'**
  String get computerDiskProperties;

  /// No description provided for @diskPropsOpenInDisks.
  ///
  /// In en, this message translates to:
  /// **'Open in Disks'**
  String get diskPropsOpenInDisks;

  /// No description provided for @diskPropsFsUnknown.
  ///
  /// In en, this message translates to:
  /// **'File system unknown'**
  String get diskPropsFsUnknown;

  /// No description provided for @diskPropsFsLine.
  ///
  /// In en, this message translates to:
  /// **'File system {type}'**
  String diskPropsFsLine(String type);

  /// No description provided for @diskPropsTotalLine.
  ///
  /// In en, this message translates to:
  /// **'Total: {size}'**
  String diskPropsTotalLine(String size);

  /// No description provided for @diskPropsUsedLine.
  ///
  /// In en, this message translates to:
  /// **'Used: {size}'**
  String diskPropsUsedLine(String size);

  /// No description provided for @diskPropsFreeLine.
  ///
  /// In en, this message translates to:
  /// **'Free: {size}'**
  String diskPropsFreeLine(String size);

  /// No description provided for @diskPropsFileAccessRow.
  ///
  /// In en, this message translates to:
  /// **'File access'**
  String get diskPropsFileAccessRow;

  /// No description provided for @snackExternalDropDone.
  ///
  /// In en, this message translates to:
  /// **'Finished with dropped items.'**
  String get snackExternalDropDone;

  /// No description provided for @snackDropUnreadable.
  ///
  /// In en, this message translates to:
  /// **'Could not read the dropped files.'**
  String get snackDropUnreadable;

  /// No description provided for @snackOpenAsRootLaunched.
  ///
  /// In en, this message translates to:
  /// **'Administrator window started (separate from this window).'**
  String get snackOpenAsRootLaunched;

  /// No description provided for @computerNetworkIpLine.
  ///
  /// In en, this message translates to:
  /// **'IP: {ip}'**
  String computerNetworkIpLine(String ip);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'de',
    'en',
    'es',
    'fr',
    'it',
    'pt',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'it':
      return AppLocalizationsIt();
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
