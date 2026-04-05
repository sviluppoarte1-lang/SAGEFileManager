// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'SAGE File Manager';

  @override
  String get menuTooltip => 'Menú';

  @override
  String get menuTopFile => 'Archivo';

  @override
  String get menuTopEdit => 'Editar';

  @override
  String get menuTopView => 'Ver';

  @override
  String get menuTopFavorites => 'Favoritos';

  @override
  String get menuTopThemes => 'Temas';

  @override
  String get menuTopTools => 'Herramientas';

  @override
  String get menuTopHelp => 'Ayuda';

  @override
  String get menuNewTab => 'Nueva pestaña (F2)';

  @override
  String get menuNewFolder => 'Nueva carpeta';

  @override
  String get menuNewTextFile => 'Nuevo documento de texto';

  @override
  String get menuNetworkDrive => 'Conectar unidad de red';

  @override
  String get menuBulkRename => 'Renombrar';

  @override
  String get menuEmptyTrash => 'Vaciar papelera';

  @override
  String get menuExit => 'Salir';

  @override
  String get menuCut => 'Cortar (Ctrl+X)';

  @override
  String get menuCopy => 'Copiar (Ctrl+C)';

  @override
  String get menuPaste => 'Pegar (Ctrl+V)';

  @override
  String get menuUndo => 'Deshacer (Ctrl+Z)';

  @override
  String get menuRedo => 'Rehacer (Ctrl+Y)';

  @override
  String get menuRefresh => 'Actualizar (F5)';

  @override
  String get menuSelectAll => 'Seleccionar todo';

  @override
  String get menuDeselectAll => 'Deseleccionar todo';

  @override
  String get menuFind => 'Buscar (F1)';

  @override
  String get menuPreferences => 'Preferencias';

  @override
  String get snackOneFileCut => '1 elemento cortado al portapapeles';

  @override
  String snackManyFilesCut(int count) {
    return '$count elementos cortados al portapapeles';
  }

  @override
  String get snackOneFileCopied => '1 elemento copiado al portapapeles';

  @override
  String snackManyFilesCopied(int count) {
    return '$count elementos copiados al portapapeles';
  }

  @override
  String get sortArrangeIcons => 'Disponer iconos';

  @override
  String get sortManual => 'Manualmente';

  @override
  String get sortByName => 'Por nombre';

  @override
  String get sortBySize => 'Por tamaño';

  @override
  String get sortByType => 'Por tipo';

  @override
  String get sortByDetailedType => 'Por tipo detallado';

  @override
  String get sortByDate => 'Por fecha de modificación';

  @override
  String get sortReverse => 'Orden inverso';

  @override
  String get viewShowHidden => 'Mostrar archivos ocultos';

  @override
  String get viewHideHidden => 'Ocultar archivos ocultos';

  @override
  String get viewSplitScreen => 'Dividir pantalla (F3)';

  @override
  String get viewShowPreview => 'Mostrar vista previa';

  @override
  String get viewHidePreview => 'Ocultar vista previa';

  @override
  String get viewShowRightPanel => 'Mostrar barra lateral derecha';

  @override
  String get viewHideRightPanel => 'Ocultar barra lateral derecha';

  @override
  String get favAdd => 'Añadir a favoritos';

  @override
  String get favManage => 'Gestionar favoritos';

  @override
  String get themesManage => 'Gestión de temas';

  @override
  String get toolsPackages => 'Desinstalar/instalar aplicaciones';

  @override
  String get toolsUpdates => 'Buscar actualizaciones';

  @override
  String get toolsBulkRenamePattern => 'Renombrar en lote (patrón)';

  @override
  String get toolsExtractArchive => 'Extraer archivo';

  @override
  String get helpShortcuts => 'Atajos de teclado';

  @override
  String get helpUserGuide => 'Guía del usuario';

  @override
  String get helpUserGuideTitle => 'Guía del usuario';

  @override
  String get helpUserGuideBlock1 =>
      'NAVEGACIÓN\n• Barra lateral: Inicio, carpetas estándar (Escritorio, Documentos…), rutas añadidas, favoritos, red y discos montados. Arrastra filas para reordenar.\n• Barra de herramientas y ruta: carpeta superior, actualizar y búsqueda global.\n• Retroceso: volver en el historial. Si está activado en Preferencias, doble clic en espacio vacío sube a la carpeta superior.\n• Doble clic en carpeta para abrirla; doble clic en archivo para abrirlo con la aplicación predeterminada.';

  @override
  String get helpUserGuideBlock2 =>
      'ARCHIVOS Y PORTAPAPELES\n• Clic para seleccionar; arrastra un rectángulo para varios elementos. Ctrl para multiselección, Mayús para rangos. Esc deselecciona todo.\n• Ctrl+C, Ctrl+X, Ctrl+V copian, cortan y pegan. Puedes arrastrar la selección fuera de la ventana.\n• Clic derecho: menú contextual (renombrar, eliminar, propiedades…). Los menús Archivo y Edición ofrecen las mismas acciones.';

  @override
  String get helpUserGuideBlock3 =>
      'VISTAS Y BÚSQUEDA\n• Menú Ver: lista, cuadrícula o detalles; archivos ocultos; pantalla dividida (F3); vista previa y panel derecho (F6).\n• F5 actualiza la carpeta actual. F2 abre una ventana nueva.\n• Herramientas → Buscar (F1) abre la búsqueda de archivos: filtros por nombre, extensión, tamaño, tipo y fecha; una ruta o todos los volúmenes montados si la opción está activa.';

  @override
  String get helpUserGuideBlock4 =>
      'AJUSTES Y MÁS\n• Favoritos y Gestión de temas en el menú superior (abre el editor de temas). Preferencias: clics, idioma, menú compacto, vista dividida y operaciones con archivos.\n• Equipo muestra discos. Añade rutas de red desde la barra lateral; para SMB la app puede indicar dependencias.\n• Herramientas: buscar archivos (F1), gestor de paquetes y buscador de actualizaciones si están disponibles.\n• Ayuda → Atajos de teclado lista todas las teclas; esta guía resume lo principal.';

  @override
  String get helpAbout => 'Acerca de';

  @override
  String get helpGitHubProject => 'Proyecto en GitHub';

  @override
  String get helpDonateNow => 'Donar ahora';

  @override
  String get helpCheckAppUpdate => 'Buscar actualización de la aplicación';

  @override
  String appUpdateNewVersionAvailable(Object version) {
    return 'Hay una nueva versión disponible: $version.';
  }

  @override
  String get appUpdateViewRelease => 'Ver publicación';

  @override
  String get appUpdateCheckFailed =>
      'No se pudo comprobar actualizaciones (red o GitHub).';

  @override
  String get appUpdateAlreadyLatest => 'Ya tienes la última versión.';

  @override
  String get navBack => 'Atrás';

  @override
  String get navForward => 'Adelante';

  @override
  String get navUp => 'Subir';

  @override
  String get prefsGeneral => 'General';

  @override
  String get prefsSingleClickOpen => 'Clic simple para abrir';

  @override
  String get prefsSingleClickOpenSubtitle =>
      'Abrir archivos y carpetas con un solo clic';

  @override
  String get prefsDoubleClickRename => 'Doble clic para renombrar';

  @override
  String get prefsDoubleClickRenameSubtitle =>
      'Renombrar con doble clic en el nombre';

  @override
  String get prefsDoubleClickEmptyUp => 'Doble clic en área vacía para subir';

  @override
  String get prefsDoubleClickEmptyUpSubtitle =>
      'Ir a la carpeta superior con doble clic en espacio vacío';

  @override
  String get prefsLanguage => 'Idioma';

  @override
  String get prefsLanguageLabel => 'Idioma de la interfaz';

  @override
  String get prefsMenuCompactTitle => 'Menú compacto';

  @override
  String get prefsMenuCompactSubtitle =>
      'Agrupar el menú tras el icono de tres líneas';

  @override
  String get smbShellLimitedModeGvfsFallback =>
      'Falló el montaje CIFS: carpetas solo vía smbclient. Instala cifs-utils y asegúrate de que mount.cifs esté disponible e inténtalo de nuevo.';

  @override
  String get smbShellFileOpenUnavailable =>
      'Ruta solo smbclient (sin montaje CIFS). Monta el recurso con mount.cifs o desactiva la opción si el montaje CIFS funciona.';

  @override
  String get prefsExecTextTitle => 'Archivos de texto ejecutables';

  @override
  String get prefsExecAuto => 'Ejecutar automáticamente';

  @override
  String get prefsExecAlwaysShow => 'Mostrar siempre';

  @override
  String get prefsExecAlwaysAsk => 'Preguntar siempre';

  @override
  String get prefsDefaultFmTitle => 'Administrador de archivos predeterminado';

  @override
  String get prefsDefaultFmBody =>
      'Establecer este administrador como aplicación predeterminada para abrir carpetas.';

  @override
  String get prefsDefaultFmButton => 'Establecer como predeterminado';

  @override
  String get langItalian => 'Italiano';

  @override
  String get langEnglish => 'Inglés';

  @override
  String get langFrench => 'Francés';

  @override
  String get langSpanish => 'Español';

  @override
  String get langPortuguese => 'Portugués';

  @override
  String get langGerman => 'Alemán';

  @override
  String get fileListTypeFolder => 'Carpeta';

  @override
  String get fileListTypeFile => 'Archivo';

  @override
  String get fileListEmpty => 'Sin archivos';

  @override
  String get copyProgressTitle => 'Copiando';

  @override
  String get copyProgressCancelTooltip => 'Cancelar';

  @override
  String copySpeed(String speed) {
    return 'Velocidad: $speed';
  }

  @override
  String copyRemaining(String time) {
    return 'Tiempo restante: $time';
  }

  @override
  String copyProgressDestLine(String name) {
    return '→ $name';
  }

  @override
  String statusItems(int count) {
    return 'Elementos: $count';
  }

  @override
  String statusFree(String size) {
    return 'Libre: $size';
  }

  @override
  String statusUsed(String size) {
    return 'Usado: $size';
  }

  @override
  String statusTotal(String size) {
    return 'Total: $size';
  }

  @override
  String statusCopyLine(String source, String dest) {
    return 'Copia: $source → $dest';
  }

  @override
  String statusCurrentFile(String name) {
    return 'Archivo: $name';
  }

  @override
  String get dialogCloseWhileCopyTitle => 'Operación en curso';

  @override
  String get dialogCloseWhileCopyBody =>
      'Hay una copia o movimiento en curso. Cerrar puede interrumpirla. ¿Continuar?';

  @override
  String get dialogCancel => 'Cancelar';

  @override
  String get dialogOverwriteTitle => '¿Reemplazar el elemento existente?';

  @override
  String dialogOverwriteBody(String name) {
    return '\"$name\" ya existe en esta carpeta. ¿Reemplazarlo?';
  }

  @override
  String get dialogOverwriteReplace => 'Reemplazar';

  @override
  String get dialogOverwriteSkip => 'Omitir';

  @override
  String get dialogCloseAnyway => 'Cerrar de todos modos';

  @override
  String get commonClose => 'Cerrar';

  @override
  String get commonSave => 'Guardar';

  @override
  String get commonDelete => 'Eliminar';

  @override
  String get commonRename => 'Renombrar';

  @override
  String get commonAdd => 'Añadir';

  @override
  String commonError(String message) {
    return 'Error: $message';
  }

  @override
  String get errorFolderRequiresOpenAsRoot =>
      'Para abrir esta carpeta, usa «Abrir como administrador» (root).';

  @override
  String get sidebarAddNetworkTitle => 'Añadir ubicación de red';

  @override
  String get sidebarNetworkPathLabel => 'Ruta de red';

  @override
  String get sidebarNetworkHint =>
      'smb://servidor/compartido o //servidor/compartido';

  @override
  String get sidebarNetworkHelp =>
      'Ejemplos:\n• smb://192.168.1.100/compartido\n• //servidor/compartido\n• /mnt/red';

  @override
  String get sidebarBrowseTooltip => 'Examinar';

  @override
  String get sidebarRenameShareTitle => 'Renombrar recurso de red';

  @override
  String get sidebarRemoveShareTitle => 'Eliminar recurso de red';

  @override
  String sidebarRemoveShareConfirm(String name) {
    return '¿Quitar «$name» de la lista?';
  }

  @override
  String get sidebarUnmountTitle => 'Desmontar disco';

  @override
  String sidebarUnmountConfirm(String name) {
    return '¿Desmontar «$name»?';
  }

  @override
  String get sidebarUnmount => 'Desmontar';

  @override
  String sidebarUnmountOk(String name) {
    return '«$name» desmontado';
  }

  @override
  String sidebarUnmountFail(String name) {
    return 'Error al desmontar «$name»';
  }

  @override
  String get sidebarEmptyTrash => 'Vaciar papelera';

  @override
  String get sidebarRemoveFromList => 'Quitar de la lista';

  @override
  String get sidebarMenuChangeColor => 'Cambiar color';

  @override
  String sidebarChangeColorDialogTitle(String name) {
    return 'Cambiar color: $name';
  }

  @override
  String get sidebarProperties => 'Propiedades';

  @override
  String sidebarPropertiesFolderTitle(String name) {
    return 'Propiedades: $name';
  }

  @override
  String get sidebarChangeFolderColor => 'Cambiar color de carpeta:';

  @override
  String get sidebarRemoveCustomColor => 'Quitar color personalizado';

  @override
  String get sidebarChangeAllFoldersColor =>
      'Cambiar color de todas las carpetas';

  @override
  String get sidebarPickDefaultColor =>
      'Elija un color predeterminado para todas las carpetas:';

  @override
  String get sidebarEmptyTrashTitle => 'Vaciar papelera';

  @override
  String get sidebarEmptyTrashBody =>
      '¿Vaciar la papelera de forma permanente? No se puede deshacer.';

  @override
  String get sidebarEmptyTrashConfirm => 'Vaciar';

  @override
  String get sidebarTrashEmptied => 'Papelera vaciada';

  @override
  String sidebarCredentialsTitle(String server) {
    return 'Credenciales para $server';
  }

  @override
  String get sidebarGuestAccess => 'Acceso de invitado (anónimo)';

  @override
  String get sidebarConnect => 'Conectar';

  @override
  String sidebarConnecting(String name) {
    return 'Conectando a $name...';
  }

  @override
  String sidebarConnectionError(String name) {
    return 'Error al conectar a $name';
  }

  @override
  String get sidebarRetry => 'Reintentar';

  @override
  String get copyCancelled => 'Copia cancelada';

  @override
  String get fileCopiedSuccess => 'Archivo copiado';

  @override
  String get folderCopiedSuccess => 'Carpeta copiada';

  @override
  String get extractionComplete => 'Extracción completada';

  @override
  String snackInitError(String error) {
    return 'Error de inicialización: $error';
  }

  @override
  String snackPathRemoved(String name) {
    return 'Quitado de la lista: $name';
  }

  @override
  String get labelChoosePath => 'Elegir ruta';

  @override
  String get ctxOpenTerminal => 'Abrir terminal';

  @override
  String get ctxNewFolder => 'Nueva carpeta';

  @override
  String get ctxOpenAsRoot => 'Abrir como root';

  @override
  String get ctxOpenWith => 'Abrir con…';

  @override
  String get ctxCopyTo => 'Copiar en…';

  @override
  String get ctxMoveTo => 'Mover a…';

  @override
  String get ctxCopy => 'Copiar';

  @override
  String get ctxCut => 'Cortar';

  @override
  String get ctxPaste => 'Pegar';

  @override
  String get ctxCreateNew => 'Crear nuevo';

  @override
  String get ctxNewTextDocumentShort => 'Documento de texto (.txt)';

  @override
  String get ctxNewWordDocument => 'Documento Word (.docx)';

  @override
  String get ctxNewExcelSpreadsheet => 'Hoja de cálculo Excel (.xlsx)';

  @override
  String get ctxExtract => 'Extraer';

  @override
  String get ctxExtractTo => 'Extraer archivo en…';

  @override
  String get ctxCompressToZip => 'Comprimir en archivo .zip';

  @override
  String snackZipCreated(Object name) {
    return 'Archivo creado: «$name».';
  }

  @override
  String snackZipFailed(Object message) {
    return 'No se pudo crear el ZIP: $message';
  }

  @override
  String get ctxChangeColor => 'Cambiar color';

  @override
  String get ctxMoveToTrash => 'Mover a la papelera';

  @override
  String get ctxRestoreFromTrash => 'Restaurar en la carpeta original';

  @override
  String get menuRestoreFromTrash => 'Restaurar desde la papelera';

  @override
  String get trashRestorePickFolderTitle => 'Elegir carpeta donde restaurar';

  @override
  String trashRestoreTargetExists(String name) {
    return 'No se puede restaurar: «$name» ya existe en el destino.';
  }

  @override
  String trashRestoredCount(int count) {
    return '$count elementos restaurados';
  }

  @override
  String get trashRestoreFailed =>
      'No se pudieron restaurar los elementos seleccionados.';

  @override
  String dialogOpenWithTitle(String name) {
    return 'Abrir «$name» con…';
  }

  @override
  String get hintSearchApp => 'Buscar aplicación…';

  @override
  String get openWithDefaultApp => 'Aplicación predeterminada';

  @override
  String get browseEllipsis => 'Examinar…';

  @override
  String get tooltipSetAsDefaultApp => 'Establecer como predeterminada';

  @override
  String get openWithOpenAndSetDefault =>
      'Abrir y establecer como predeterminada';

  @override
  String get openWithFooterHint =>
      'Use la estrella o el menú ⋮ para cambiar la aplicación predeterminada para este tipo de archivo en cualquier momento.';

  @override
  String snackDefaultAppSet(String appName, String mimeType) {
    return '$appName establecida como predeterminada para $mimeType';
  }

  @override
  String snackSetDefaultAppError(String error) {
    return 'No se pudo establecer el predeterminado: $error';
  }

  @override
  String snackOpenFileError(String error) {
    return 'No se pudo abrir: $error';
  }

  @override
  String get dialogTitleCreateFolder => 'Crear nueva carpeta';

  @override
  String get dialogTitleNewFolder => 'Nueva carpeta';

  @override
  String get labelFolderName => 'Nombre de carpeta';

  @override
  String get hintFolderName => 'Introduzca el nombre';

  @override
  String get labelFileName => 'Nombre de archivo';

  @override
  String get hintTextDocument => 'documento.txt';

  @override
  String get buttonCreate => 'Crear';

  @override
  String snackMoveError(String error) {
    return 'Error al mover: $error';
  }

  @override
  String dialogChangeColorFor(String name) {
    return 'Cambiar color: $name';
  }

  @override
  String get dialogPickFolderColor => 'Elija un color para la carpeta:';

  @override
  String get shortcutTitle => 'Atajos de teclado';

  @override
  String get shortcutCopy => 'Copiar archivos/carpetas seleccionados';

  @override
  String get shortcutPaste => 'Pegar archivos/carpetas';

  @override
  String get shortcutCut => 'Cortar archivos/carpetas seleccionados';

  @override
  String get shortcutUndo => 'Deshacer última operación';

  @override
  String get shortcutRedo => 'Rehacer última operación';

  @override
  String get shortcutNewTab => 'Nueva pestaña';

  @override
  String get shortcutSplitView => 'Dividir pantalla en dos';

  @override
  String get shortcutRefresh => 'Actualizar carpeta';

  @override
  String get shortcutRightPanel => 'Mostrar/ocultar barra derecha';

  @override
  String get shortcutDeselect => 'Desmarcar todo';

  @override
  String get shortcutBackNav => 'Volver en el historial';

  @override
  String get shortcutFindFiles => 'Buscar archivos y carpetas';

  @override
  String get aboutTitle => 'Acerca de';

  @override
  String get aboutAppName => 'Gestor de archivos';

  @override
  String get aboutTagline => 'Gestor de archivos avanzado';

  @override
  String aboutVersionLabel(String version) {
    return 'Versión: $version';
  }

  @override
  String get aboutAuthor => 'Autor: Marco Di Giangiacomo';

  @override
  String get aboutYear => '© 2026';

  @override
  String get aboutDescriptionHeading => 'Descripción:';

  @override
  String get aboutDescription =>
      'SAGE File Manager: gestor moderno para Linux con varias vistas, previsualización, temas, búsqueda, copia optimizada, vista dividida, SMB/LAN y más.';

  @override
  String get aboutFeaturesHeading => 'Funciones principales:';

  @override
  String get aboutFeaturesList =>
      '• Gestión completa de archivos\n• Varias vistas (lista, cuadrícula, detalles)\n• Vista previa (imágenes, PDF, documentos, texto)\n• Gestión de temas (predefinidos y personalización)\n• Búsqueda avanzada\n• Copiar/pegar optimizado\n• Vista dividida\n• Favoritos y rutas\n• Ejecutables y scripts\n• Interfaz moderna';

  @override
  String snackDocumentCreated(String name) {
    return 'Documento «$name» creado';
  }

  @override
  String get dialogInsufficientPermissions => 'Permisos insuficientes';

  @override
  String get snackFolderCreated => 'Carpeta creada';

  @override
  String get snackTerminalUnavailable => 'Terminal no disponible';

  @override
  String get snackTerminalRootError => 'No se pudo abrir el terminal como root';

  @override
  String get snackRootHelperMissing =>
      'No se pudo abrir como root. Instale pkexec o sudo.';

  @override
  String get snackOpenAsRootNoFolder =>
      'Abra primero una carpeta y elija Abrir como root.';

  @override
  String get snackOpenAsRootBadFolder => 'No se puede abrir esa carpeta.';

  @override
  String snackPasteItemError(String name, String error) {
    return 'Error al pegar $name: $error';
  }

  @override
  String get snackFileMoved => 'Archivo movido';

  @override
  String get dialogRenameFileTitle => 'Renombrar';

  @override
  String dialogRenameManySubtitle(int count) {
    return '$count elementos seleccionados. Escriba un nombre nuevo en cada fila.';
  }

  @override
  String get labelNewName => 'Nombre nuevo';

  @override
  String get snackFileRenamed => 'Archivo renombrado';

  @override
  String snackRenameError(String error) {
    return 'Error al renombrar: $error';
  }

  @override
  String get snackRenameSameFolder =>
      'Todos los elementos deben estar en la misma carpeta.';

  @override
  String get snackRenameEmptyName =>
      'Cada elemento necesita un nombre nuevo no vacío.';

  @override
  String get snackRenameDuplicateNames =>
      'Los nombres nuevos deben ser distintos entre sí.';

  @override
  String get snackRenameTargetExists =>
      'Ya existe un archivo o carpeta con ese nombre.';

  @override
  String get snackSelectPathFirst => 'Seleccione primero una ruta';

  @override
  String get snackAlreadyFavorite => 'Ya está en favoritos';

  @override
  String snackAddedFavorite(String name) {
    return 'Añadido a favoritos: $name';
  }

  @override
  String get favoritesEmptyList => 'Sin favoritos';

  @override
  String snackNewTabOpened(String name) {
    return 'Nueva pestaña: $name';
  }

  @override
  String get snackSelectForSymlink =>
      'Seleccione archivo o carpeta para el acceso directo';

  @override
  String get dialogCreateSymlinkTitle => 'Crear acceso directo';

  @override
  String get labelSymlinkName => 'Nombre del acceso directo';

  @override
  String get snackSymlinkCreated => 'Acceso directo creado';

  @override
  String get snackConnectingNetwork => 'Conectando a la red…';

  @override
  String get snackNewInstanceStarted => 'Nueva instancia iniciada';

  @override
  String snackNewInstanceError(String error) {
    return 'No se pudo iniciar nueva instancia: $error';
  }

  @override
  String get snackSelectFilesRename =>
      'Seleccione al menos un archivo para renombrar';

  @override
  String get bulkRenameTitle => 'Renombrado masivo';

  @override
  String bulkRenameSelectedCount(int count) {
    return '$count archivos seleccionados';
  }

  @override
  String get bulkRenamePatternLabel => 'Patrón de nombre';

  @override
  String get bulkRenamePatternHelper =>
      'Usa los marcadores name y num entre llaves (ver ejemplo abajo).';

  @override
  String get bulkRenameAutoNumber => 'Numeración automática';

  @override
  String get bulkRenameStartNumber => 'Número inicial';

  @override
  String get bulkRenameKeepExt => 'Mantener extensión original';

  @override
  String trashEmptyError(String error) {
    return 'Error al vaciar la papelera: $error';
  }

  @override
  String labelNItems(int count) {
    return '$count elementos';
  }

  @override
  String get dialogTitleDeletePermanent => '¿Eliminar permanentemente?';

  @override
  String get dialogTitleMoveToTrashConfirm => '¿Mover a la papelera?';

  @override
  String get dialogBodyPermanentDeleteOne =>
      '¿Eliminar permanentemente un elemento?';

  @override
  String dialogBodyPermanentDeleteMany(int count) {
    return '¿Eliminar permanentemente $count elementos?';
  }

  @override
  String get dialogBodyTrashOne => '¿Mover un elemento a la papelera?';

  @override
  String dialogBodyTrashMany(int count) {
    return '¿Mover $count elementos a la papelera?';
  }

  @override
  String get snackDeletedPermanentOne =>
      'Un elemento eliminado permanentemente';

  @override
  String snackDeletedPermanentMany(int count) {
    return '$count elementos eliminados permanentemente';
  }

  @override
  String get snackMovedToTrashOne => 'Un elemento movido a la papelera';

  @override
  String snackMovedToTrashMany(int count) {
    return '$count elementos movidos a la papelera';
  }

  @override
  String snackDeleteErrorsSuffix(int errors) {
    return ', $errors errores';
  }

  @override
  String get dialogOpenAsRootBody =>
      'No tienes permiso para crear archivos o carpetas en esta carpeta. ¿Abrir el gestor de archivos como root?';

  @override
  String get dialogOpenAsRootAuthTitle => 'Abrir como administrador';

  @override
  String get dialogOpenAsRootAuthBody =>
      'Al pulsar Continuar, el sistema pedirá la contraseña de administrador. Solo tras autenticarse correctamente se abrirá una nueva ventana del gestor de archivos en esta carpeta.';

  @override
  String get dialogOpenAsRootContinue => 'Continuar';

  @override
  String get paneSelectPathHint => 'Selecciona una ruta';

  @override
  String get emptyFolderLabel => 'Carpeta vacía';

  @override
  String get sidebarMountPointOptional => 'Punto de montaje (opcional)';

  @override
  String snackBulkRenameManyDone(int count) {
    return '$count archivos renombrados';
  }

  @override
  String get commonOk => 'OK';

  @override
  String get prefsPageTitle => 'Preferencias';

  @override
  String get snackPrefsSaved => 'Preferencias guardadas';

  @override
  String get prefsNavView => 'Visualización';

  @override
  String get prefsNavPreview => 'Vista previa';

  @override
  String get prefsNavFileOps => 'Operaciones de archivos';

  @override
  String get prefsNavTrash => 'Papelera';

  @override
  String get prefsNavMedia => 'Medios extraíbles';

  @override
  String get prefsNavCache => 'Caché';

  @override
  String get prefsDefaultFmSuccess =>
      'Administrador de archivos establecido como predeterminado.';

  @override
  String get prefsShowHiddenTitle => 'Mostrar archivos ocultos';

  @override
  String get prefsShowHiddenSubtitle =>
      'Mostrar archivos y carpetas cuyo nombre empieza por punto';

  @override
  String get prefsShowPreviewPanelTitle => 'Mostrar panel de vista previa';

  @override
  String get prefsShowPreviewPanelSubtitle =>
      'Mostrar el panel de vista previa a la derecha';

  @override
  String get prefsAlwaysDoublePaneTitle => 'Iniciar siempre con vista dividida';

  @override
  String get prefsAlwaysDoublePaneSubtitle =>
      'Abrir siempre la vista dividida al iniciar';

  @override
  String get prefsIgnoreViewPerFolderTitle =>
      'Ignorar preferencias de vista por carpeta';

  @override
  String get prefsIgnoreViewPerFolderSubtitle =>
      'No guardar preferencias de vista por carpeta';

  @override
  String get prefsDefaultViewModeTitle => 'Modo de vista predeterminado';

  @override
  String get prefsViewModeList => 'Lista';

  @override
  String get prefsViewModeGrid => 'Cuadrícula';

  @override
  String get prefsViewModeDetails => 'Detalles';

  @override
  String get prefsGridZoomTitle => 'Nivel de zoom de cuadrícula predeterminado';

  @override
  String prefsGridZoomLevel(int current) {
    return 'Nivel: $current/10';
  }

  @override
  String get prefsFontSection => 'Fuente';

  @override
  String get prefsFontFamilyLabel => 'Familia tipográfica';

  @override
  String get labelSelectFont => 'Seleccionar fuente';

  @override
  String get fontFamilyDefaultSystem => 'Predeterminado (sistema)';

  @override
  String get prefsFontSizeTitle => 'Tamaño de fuente';

  @override
  String prefsFontSizeValue(String size) {
    return 'Tamaño: $size';
  }

  @override
  String get prefsFontWeightTitle => 'Grosor de fuente';

  @override
  String get prefsFontWeightNormal => 'Normal';

  @override
  String get prefsFontWeightBold => 'Negrita';

  @override
  String get prefsFontWeightSemiBold => 'Seminegrita';

  @override
  String get prefsFontWeightMedium => 'Medio';

  @override
  String get prefsTextShadowSection => 'Sombra del texto';

  @override
  String get prefsTextShadowEnableTitle => 'Activar sombra de texto';

  @override
  String get prefsTextShadowEnableSubtitle =>
      'Añade sombra al texto para legibilidad';

  @override
  String get prefsShadowIntensityTitle => 'Desenfoque de sombra';

  @override
  String get prefsShadowOffsetXTitle => 'Desplazamiento sombra X';

  @override
  String get prefsShadowOffsetYTitle => 'Desplazamiento sombra Y';

  @override
  String get prefsShadowColorTitle => 'Color de sombra';

  @override
  String prefsShadowColorValue(String value) {
    return 'Color: $value';
  }

  @override
  String get prefsShadowColorBlack => 'Negro';

  @override
  String get dialogPickShadowColor => 'Elegir color de sombra';

  @override
  String get prefsPickColor => 'Elegir color';

  @override
  String get prefsTextPreviewLabel => 'Vista previa de texto';

  @override
  String get prefsDisableFileQueueTitle => 'Desactivar cola de operaciones';

  @override
  String get prefsDisableFileQueueSubtitle =>
      'Ejecutar operaciones en secuencia sin cola';

  @override
  String get prefsAskTrashTitle => 'Preguntar antes de mover a la papelera';

  @override
  String get prefsAskTrashSubtitle => 'Confirmar antes de mover a la papelera';

  @override
  String get prefsAskEmptyTrashTitle => 'Preguntar antes de vaciar la papelera';

  @override
  String get prefsAskEmptyTrashSubtitle =>
      'Confirmar antes de borrar definitivamente';

  @override
  String get prefsIncludeDeleteTitle => 'Incluir comando Eliminar';

  @override
  String get prefsIncludeDeleteSubtitle => 'Opción para eliminar sin papelera';

  @override
  String get prefsSkipTrashDelKeyTitle => 'Omitir papelera con Supr';

  @override
  String get prefsSkipTrashDelKeySubtitle => 'Eliminar directamente con Supr';

  @override
  String get prefsAutoMountTitle => 'Montar automáticamente dispositivos';

  @override
  String get prefsAutoMountSubtitle => 'Montar USB y otros al conectar';

  @override
  String get prefsOpenWindowMountedTitle =>
      'Abrir ventana para dispositivos montados';

  @override
  String get prefsOpenWindowMountedSubtitle => 'Abrir ventana automáticamente';

  @override
  String get prefsWarnRemovableTitle => 'Avisar al conectar un dispositivo';

  @override
  String get prefsWarnRemovableSubtitle =>
      'Notificación al conectar medio extraíble';

  @override
  String get prefsPreviewExtensionsIntro =>
      'Extensiones para activar vista previa:';

  @override
  String get prefsPreviewRightPanelNote =>
      'Las vistas previas completas de PDF, Office, texto y otros tipos aparecen en la barra lateral derecha cuando está visible. Si la barra está oculta, en la lista de archivos solo se muestran miniaturas de imágenes.';

  @override
  String get prefsAdminPasswordSection => 'Contraseña de administrador';

  @override
  String get prefsSaveAdminPasswordTitle =>
      'Guardar contraseña de administrador';

  @override
  String get prefsSaveAdminPasswordSubtitle =>
      'Guardar contraseña para actualizaciones (no recomendado)';

  @override
  String get labelAdminPassword => 'Contraseña de administrador';

  @override
  String get hintAdminPassword => 'Introducir contraseña';

  @override
  String get prefsCacheSectionTitle => 'Caché y vistas previas';

  @override
  String get prefsCacheSizeTitle => 'Tamaño de caché';

  @override
  String prefsCacheSizeCurrent(String size) {
    return 'Tamaño actual: $size';
  }

  @override
  String get labelNetworkShareName => 'Nombre personalizado';

  @override
  String get hintNetworkShareName => 'Nombre para este recurso';

  @override
  String get sidebarTooltipRemoveNetwork => 'Quitar ruta de red';

  @override
  String get sidebarTooltipUnmount => 'Desmontar disco';

  @override
  String sidebarUnmountSuccess(String name) {
    return '«$name» desmontado';
  }

  @override
  String sidebarUnmountError(String name) {
    return 'Error al desmontar «$name»';
  }

  @override
  String get previewSelectFile => 'Selecciona un archivo para vista previa';

  @override
  String get previewPanelTitle => 'Vista previa';

  @override
  String previewPanelSizeLine(String value) {
    return 'Tamaño: $value';
  }

  @override
  String previewPanelModifiedLine(String value) {
    return 'Modificado: $value';
  }

  @override
  String get dialogErrorTitle => 'Error';

  @override
  String get propsLoadError => 'No se pudieron cargar las propiedades';

  @override
  String get snackPermissionsUpdated => 'Permisos actualizados';

  @override
  String dialogEditFieldTitle(String label) {
    return 'Editar $label';
  }

  @override
  String snackFieldUpdated(String label) {
    return '$label actualizado';
  }

  @override
  String get propsEditPermissionsTitle => 'Editar permisos';

  @override
  String get permOwner => 'Propietario:';

  @override
  String get permGroup => 'Grupo:';

  @override
  String get permOthers => 'Otros:';

  @override
  String get permRead => 'Lectura';

  @override
  String get permWrite => 'Escritura';

  @override
  String get permExecute => 'Ejecución';

  @override
  String get previewNotAvailable => 'Vista previa no disponible';

  @override
  String get previewImageError => 'Error al cargar imagen';

  @override
  String get previewDocLoadError => 'Error al cargar documento';

  @override
  String get previewOpenExternally => 'Abrir con visor externo';

  @override
  String get previewDocumentTitle => 'Vista previa de documento';

  @override
  String get previewDocLegacyFormat =>
      '.doc no está soportado. Use .docx o un visor externo.';

  @override
  String get previewSheetLoadError => 'Error al cargar hoja de cálculo';

  @override
  String get previewSheetTitle => 'Vista previa de hoja de cálculo';

  @override
  String get previewXlsLegacyFormat =>
      '.xls no está soportado. Use .xlsx o un visor externo.';

  @override
  String get previewPresentationLoadError => 'Error al cargar presentación';

  @override
  String get previewOpenOfficeTitle => 'Vista previa OpenOffice';

  @override
  String get previewOpenOfficeBody =>
      'Los archivos OpenOffice requieren un visor externo.';

  @override
  String themeApplied(String name) {
    return 'Tema «$name» aplicado';
  }

  @override
  String get themeDark => 'Tema oscuro';

  @override
  String themeFontSizeTitle(String size) {
    return 'Tamaño de fuente: $size';
  }

  @override
  String get themeFontWeightSection => 'Grosor de fuente';

  @override
  String get themeBoldLabel => 'Negrita';

  @override
  String get themeTextShadowSection => 'Sombra del texto';

  @override
  String themeShadowIntensity(String percent) {
    return 'Intensidad de sombra: $percent %';
  }

  @override
  String get themeColorPicked => 'Color seleccionado';

  @override
  String get themeSelectToCustomize => 'Selecciona un tema para personalizar';

  @override
  String get themeFontFamilySection => 'Familia tipográfica';

  @override
  String get searchNeedCriterion => 'Introduzca al menos un criterio';

  @override
  String get searchCurrentPath => 'Ruta actual';

  @override
  String get searchButton => 'Buscar';

  @override
  String get pkgConfirmUninstallTitle => 'Confirmar desinstalación';

  @override
  String pkgConfirmUninstallBody(String name) {
    return '¿Desinstalar $name?';
  }

  @override
  String get pkgDependenciesTitle => 'Dependencias encontradas';

  @override
  String get pkgUninstallError => 'Error al desinstalar';

  @override
  String get pkgManagerTitle => 'Gestor de aplicaciones';

  @override
  String get pkgInstallTitle => 'Instalar paquete';

  @override
  String pkgInstallBody(String name) {
    return '¿Instalar «$name»?';
  }

  @override
  String pkgMadeExecutable(String name) {
    return '$name marcado como ejecutable';
  }

  @override
  String get pkgUnsupportedFormat => 'Formato de paquete no admitido';

  @override
  String pkgInstallErrorOutput(String output) {
    return 'Error de instalación: $output';
  }

  @override
  String updateItemSuccess(String name) {
    return '$name actualizado correctamente';
  }

  @override
  String updateItemError(String name) {
    return 'Error al actualizar $name';
  }

  @override
  String get updateAllError => 'Error al instalar actualizaciones';

  @override
  String get updateInstallAllButton => 'Instalar todo';

  @override
  String get previewCatImages => 'Imágenes';

  @override
  String get previewCatDocuments => 'Documentos';

  @override
  String get previewCatText => 'Texto';

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
  String get tableColumnName => 'Nombre';

  @override
  String get tableColumnPath => 'Ruta';

  @override
  String get tableColumnSize => 'Tamaño';

  @override
  String get tableColumnModified => 'Modificado';

  @override
  String get tableColumnType => 'Tipo';

  @override
  String get networkBrowserTitle => 'Explorar red';

  @override
  String get networkSearchingServers => 'Buscando servidores…';

  @override
  String get networkNoServersFound => 'No se encontraron servidores';

  @override
  String get networkServersSharesHeader => 'Servidores y recursos compartidos';

  @override
  String get labelUsername => 'Usuario';

  @override
  String get labelPassword => 'Contraseña';

  @override
  String get networkRefreshTooltip => 'Actualizar';

  @override
  String get networkNoSharesAvailable =>
      'No hay recursos compartidos disponibles';

  @override
  String get networkInfoTitle => 'Información';

  @override
  String networkServersFoundCount(int count) {
    return 'Servidores encontrados: $count';
  }

  @override
  String get networkConnectShareInstructions =>
      'Para conectarte a un recurso compartido, expande un servidor y pulsa el que quieras.';

  @override
  String get networkSelectedServerLabel => 'Servidor seleccionado:';

  @override
  String networkSharesCount(int count) {
    return 'Recursos compartidos: $count';
  }

  @override
  String get sidebarTooltipBrowseNetworkPaths => 'Explorar rutas de red';

  @override
  String get sidebarTooltipAddNetworkPath => 'Añadir ruta de red';

  @override
  String get sidebarSectionNetwork => 'Red';

  @override
  String get sidebarSectionDisks => 'Discos';

  @override
  String get sidebarAddPath => 'Añadir ruta';

  @override
  String get sidebarUserFolderHome => 'Inicio';

  @override
  String get sidebarUserFolderDesktop => 'Escritorio';

  @override
  String get sidebarUserFolderDocuments => 'Documentos';

  @override
  String get sidebarUserFolderPictures => 'Imágenes';

  @override
  String get sidebarUserFolderMusic => 'Música';

  @override
  String get sidebarUserFolderVideos => 'Vídeos';

  @override
  String get sidebarUserFolderDownloads => 'Descargas';

  @override
  String get sidebarSectionFavorites => 'Favoritos';

  @override
  String get commonUnknown => 'Desconocido';

  @override
  String get prefsClearCacheButton => 'Vaciar caché';

  @override
  String get prefsClearCacheTitle => 'Vaciar caché';

  @override
  String get prefsClearCacheBody =>
      '¿Vaciar toda la caché de miniaturas de vista previa?';

  @override
  String get prefsClearCacheConfirm => 'Vaciar';

  @override
  String get snackPrefsCacheCleared => 'Caché vaciada';

  @override
  String get previewFmtJpeg => 'Imagen JPEG';

  @override
  String get previewFmtPng => 'Imagen PNG';

  @override
  String get previewFmtGif => 'Imagen GIF';

  @override
  String get previewFmtBmp => 'Imagen BMP';

  @override
  String get previewFmtWebp => 'Imagen WebP';

  @override
  String get previewFmtPdf => 'Documento PDF';

  @override
  String get previewFmtPlainText => 'Archivo de texto';

  @override
  String get previewFmtMarkdown => 'Markdown';

  @override
  String get previewFmtNfo => 'Archivo de información';

  @override
  String get previewFmtShell => 'Script de shell';

  @override
  String get previewFmtHtml => 'Documento HTML';

  @override
  String get previewFmtDocx => 'Documento de Word';

  @override
  String get previewFmtXlsx => 'Hoja de Excel';

  @override
  String get previewFmtPptx => 'Presentación de PowerPoint';

  @override
  String themeAppliedSnackbar(String name) {
    return 'Tema «$name» aplicado';
  }

  @override
  String get themeEditTitle => 'Editar tema';

  @override
  String get themeNewTitle => 'Tema nuevo';

  @override
  String get themeFieldName => 'Nombre del tema';

  @override
  String get themeDarkThemeSwitch => 'Tema oscuro';

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
  String get themeManagerTitle => 'Gestión de temas';

  @override
  String get themeBuiltinHeader => 'Temas integrados';

  @override
  String get themeCustomHeader => 'Temas personalizados';

  @override
  String get themeCustomizationHeader => 'Personalización';

  @override
  String get themeSelectPrompt => 'Selecciona un tema para personalizarlo';

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
  String get themeIconShadowTitle => 'Sombra de iconos (cuadrícula)';

  @override
  String get themeIconShadowSubtitle =>
      'Sombra bajo iconos de archivos y carpetas en vista cuadrícula';

  @override
  String themeIconShadowIntensity(String percent) {
    return 'Intensidad sombra iconos: $percent%';
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
  String get propsTitle => 'Propiedades';

  @override
  String get propsTimeoutLoading => 'Tiempo de espera al cargar propiedades';

  @override
  String propsLoadErrorDetail(String detail) {
    return 'Error al cargar propiedades: $detail';
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
      other: '$count elementos seleccionados',
      one: '1 elemento seleccionado',
    );
    return '$_temp0';
  }

  @override
  String get propsMultiTypeMixed => 'Selección mixta (archivos y carpetas)';

  @override
  String get propsMultiCombinedSize => 'Tamaño total en disco';

  @override
  String get propsMultiLoadingSizes => 'Calculando tamaños…';

  @override
  String get propsMultiPerItemTitle => 'Cada elemento';

  @override
  String propsMultiCountSummary(int folderCount, int fileCount) {
    return '$folderCount carpetas, $fileCount archivos';
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
  String get pkgPageTitle => 'Aplicaciones';

  @override
  String get pkgInstallFromFileTooltip => 'Install package from file';

  @override
  String get pkgFilterAll => 'Todas';

  @override
  String get pkgSearchHint => 'Buscar aplicaciones…';

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
  String get pkgInstallProgressTitle => 'Instalando paquete';

  @override
  String get pkgInstallRunningStatus => 'Iniciando instalador…';

  @override
  String get zipProgressPanelTitle => 'Comprimiendo a ZIP';

  @override
  String get zipProgressSubtitle => 'Añadiendo archivos al archivo';

  @override
  String get zipProgressEncoding => 'Escribiendo archivo…';

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
  String get updateTitle => 'Actualizaciones';

  @override
  String updateTitleWithCount(int count) {
    return 'Actualizaciones ($count)';
  }

  @override
  String get updateInstallAll => 'Instalar todas';

  @override
  String get updateNoneAvailable => 'No hay actualizaciones disponibles';

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
  String get searchDialogTitle => 'Buscar archivos';

  @override
  String searchPathLabel(String path) {
    return 'Ruta: $path';
  }

  @override
  String get searchSelectDiskTooltip => 'Select drive';

  @override
  String get searchAllMountsLabel => 'Buscar en todos los volúmenes montados';

  @override
  String get searchAllMountsHint =>
      'USB, particiones extra, GVFS/red (si hay acceso). Más lento que una sola carpeta.';

  @override
  String searchAllMountsActive(int count) {
    return 'Buscando en $count ubicaciones (todos los mounts)';
  }

  @override
  String get searchPathCurrentMenu => 'Current path';

  @override
  String get searchPathRootMenu => 'Raíz del sistema de archivos';

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
  String get searchNoCriteriaSnack =>
      'Introduce al menos un criterio de búsqueda';

  @override
  String searchError(String error) {
    return 'Error de búsqueda: $error';
  }

  @override
  String get searchNoResults => 'No results';

  @override
  String get searchResultsOne => '1 resultado encontrado';

  @override
  String searchResultsMany(int count) {
    return '$count resultados encontrados';
  }

  @override
  String get searchTooltipViewList => 'Lista';

  @override
  String get searchTooltipViewGrid => 'Cuadrícula';

  @override
  String get searchTooltipViewDetails => 'Detalles';

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
  String get searchDateWeek => 'Última semana';

  @override
  String get searchDateMonth => 'Último mes';

  @override
  String get searchDateYear => 'Último año';

  @override
  String statusDiskPercent(String value) {
    return '$value%';
  }

  @override
  String get depsDialogTitle => 'Componentes del sistema';

  @override
  String get depsDialogIntro =>
      'Faltan los siguientes componentes. Puede instalarlos ahora con la contraseña de administrador (PolicyKit).';

  @override
  String get depsInstallButton => 'Instalar ahora (contraseña admin)';

  @override
  String get depsContinueButton => 'Continuar sin instalar';

  @override
  String get depsInstalling => 'Instalando paquetes…';

  @override
  String get depsInstallSuccess => 'Instalación completada.';

  @override
  String depsInstallFailed(String message) {
    return 'Error de instalación: $message';
  }

  @override
  String get depsUnknownDistro =>
      'Instalación automática no disponible para esta distribución. Instale los paquetes manualmente en una terminal.';

  @override
  String get depsManualCommandLabel => 'Comando sugerido';

  @override
  String get depsPkexecNotFound =>
      'No se encontró pkexec. Ejecute en la terminal:';

  @override
  String get depsRustUnavailable =>
      'No se cargó la biblioteca nativa (Rust). La copia puede ser más lenta. Reinstale la aplicación si persiste.';

  @override
  String get depLabelXdgOpen =>
      'xdg-open — abrir archivos con aplicaciones predeterminadas';

  @override
  String get depLabelMountCifs =>
      'mount.cifs — montar recursos SMB (cifs-utils)';

  @override
  String get depsCifsInstallTitle => '¿Instalar cifs-utils?';

  @override
  String get depsCifsInstallBody =>
      'Montar recursos SMB requiere mount.cifs del paquete cifs-utils. ¿Instalarlo ahora con el gestor de paquetes (se necesita contraseña de administrador)?';

  @override
  String get depLabelSmbclient => 'smbclient — explorar recursos SMB/CIFS';

  @override
  String get depLabelNmblookup =>
      'nmblookup — encontrar equipos en la LAN (NetBIOS)';

  @override
  String get depLabelAvahiBrowse =>
      'avahi-browse — descubrimiento de red (mDNS)';

  @override
  String get depLabelAvahiResolve =>
      'avahi-resolve-address — resuelve nombres de host en la LAN (mDNS)';

  @override
  String get depsNetworkBannerHint =>
      'Faltan herramientas opcionales para encontrar equipos en la red y montar recursos compartidos. Puede instalarlas automáticamente (se requiere contraseña de administrador).';

  @override
  String get depsNetworkBannerLater => 'Ahora no';

  @override
  String get depsSomeStillMissing =>
      'Aún faltan herramientas. Pruebe el comando de terminal sugerido abajo.';

  @override
  String get depsPolkitAuthFailed =>
      'Se canceló o denegó la autenticación de administrador, o pkexec no pudo ejecutar el instalador.';

  @override
  String get depsInstallOutputIntro => 'Salida del gestor de paquetes:';

  @override
  String get depsInstallUnexpected => 'error inesperado';

  @override
  String get depsDialogIntroRustOnly =>
      'No hay aceleración nativa para algunas operaciones con archivos (biblioteca Rust).';

  @override
  String get depsDialogIntroToolsOk =>
      'Las herramientas de línea de comandos necesarias están instaladas.';

  @override
  String get depsCloseButton => 'Cerrar';

  @override
  String get computerTitle => 'Equipo';

  @override
  String get computerOnDevice => 'En este dispositivo';

  @override
  String get computerNetworks => 'Red';

  @override
  String get computerNoVolumes => 'No se encontraron volúmenes';

  @override
  String get computerNoServers => 'No se detectaron servidores';

  @override
  String get computerTools => 'Herramientas';

  @override
  String get computerToolFindFiles => 'Buscar archivos y carpetas';

  @override
  String get computerToolPackages => 'Desinstalar/Instalar apps';

  @override
  String get computerToolSystemUpdates => 'Buscar actualizaciones del sistema';

  @override
  String get computerRefresh => 'Actualizar';

  @override
  String computerFreeShort(String size) {
    return '$size libres';
  }

  @override
  String computerNetworkHint(String name) {
    return 'Conéctate desde la barra lateral → Red: $name';
  }

  @override
  String get computerVolumeOpen => 'Abrir';

  @override
  String get computerFormatVolume => 'Formatear…';

  @override
  String get computerFormatTitle => 'Formatear volumen';

  @override
  String get computerFormatWarning =>
      'Se borrarán todos los datos de este volumen. No se puede deshacer.';

  @override
  String get computerFormatFilesystem => 'Sistema de archivos';

  @override
  String get computerFormatConfirm => 'Formatear';

  @override
  String get computerFormatNotSupported =>
      'Formatear desde esta pantalla solo está soportado en Linux con udisks2.';

  @override
  String get computerFormatNoDevice =>
      'No se pudo determinar el dispositivo de bloques.';

  @override
  String get computerFormatSystemBlockedTitle => 'No se puede formatear';

  @override
  String get computerFormatSystemBlockedBody =>
      'Es un volumen del sistema (raíz, arranque o mismo disco que el sistema). No se permite formatearlo aquí.';

  @override
  String get computerFormatRunning => 'Formateando…';

  @override
  String get computerFormatDone => 'Formateo completado.';

  @override
  String computerFormatFailed(String error) {
    return 'Error al formatear: $error';
  }

  @override
  String get computerMounting => 'Conectando…';

  @override
  String get computerMountNoShares =>
      'No se encontraron recursos compartidos. Revise credenciales, firewall o SMB.';

  @override
  String get computerMountFailed =>
      'No se pudo montar el recurso. Pruebe otras credenciales, instale cifs-utils o revise los permisos de montaje.';

  @override
  String get computerMountMissingGio =>
      'No se encontró mount.cifs. Instale cifs-utils. Puede necesitar permisos de root o entradas en /etc/fstab.';

  @override
  String get computerMountNeedPassword =>
      'Este recurso requiere usuario y contraseña. Vuelva a conectar e introduzca sus credenciales.';

  @override
  String get networkRememberPassword =>
      'Recordar credenciales para este equipo (almacenamiento seguro)';

  @override
  String get dialogRootPasswordTitle => 'Contraseña de administrador';

  @override
  String get dialogRootPasswordLabel => 'Contraseña para sudo';

  @override
  String get computerSelectShare => 'Elegir recurso compartido';

  @override
  String get computerConnect => 'Conectar';

  @override
  String get computerCredentialsTitle => 'Acceso de red';

  @override
  String get computerUsername => 'Usuario';

  @override
  String get computerPassword => 'Contraseña';

  @override
  String get computerDiskProperties => 'Propiedades';

  @override
  String get diskPropsOpenInDisks => 'Abrir en Discos';

  @override
  String get diskPropsFsUnknown => 'Sistema de archivos desconocido';

  @override
  String diskPropsFsLine(String type) {
    return 'Sistema de archivos $type';
  }

  @override
  String diskPropsTotalLine(String size) {
    return 'Total: $size';
  }

  @override
  String diskPropsUsedLine(String size) {
    return 'Usado: $size';
  }

  @override
  String diskPropsFreeLine(String size) {
    return 'Libre: $size';
  }

  @override
  String get diskPropsFileAccessRow => 'Acceso a archivos';

  @override
  String get snackExternalDropDone =>
      'Operación con elementos soltados completada.';

  @override
  String get snackDropUnreadable =>
      'No se pudieron leer los archivos soltados.';

  @override
  String get snackOpenAsRootLaunched =>
      'Ventana de administrador iniciada (separada de esta).';

  @override
  String computerNetworkIpLine(String ip) {
    return 'IP: $ip';
  }
}
