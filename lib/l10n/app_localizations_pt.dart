// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'SAGE File Manager';

  @override
  String get menuTooltip => 'Menu';

  @override
  String get menuTopFile => 'Ficheiro';

  @override
  String get menuTopEdit => 'Editar';

  @override
  String get menuTopView => 'Ver';

  @override
  String get menuTopFavorites => 'Favoritos';

  @override
  String get menuTopThemes => 'Temas';

  @override
  String get menuTopTools => 'Ferramentas';

  @override
  String get menuTopHelp => 'Ajuda';

  @override
  String get menuNewTab => 'Abrir novo separador (F2)';

  @override
  String get menuNewFolder => 'Nova pasta';

  @override
  String get menuNewTextFile => 'Novo documento de texto';

  @override
  String get menuNetworkDrive => 'Ligar unidade de rede';

  @override
  String get menuBulkRename => 'Mudar o nome';

  @override
  String get menuEmptyTrash => 'Esvaziar lixo';

  @override
  String get menuExit => 'Sair';

  @override
  String get menuCut => 'Cortar (Ctrl+X)';

  @override
  String get menuCopy => 'Copiar (Ctrl+C)';

  @override
  String get menuPaste => 'Colar (Ctrl+V)';

  @override
  String get menuUndo => 'Anular (Ctrl+Z)';

  @override
  String get menuRedo => 'Refazer (Ctrl+Y)';

  @override
  String get menuRefresh => 'Atualizar (F5)';

  @override
  String get menuSelectAll => 'Selecionar tudo';

  @override
  String get menuDeselectAll => 'Desmarcar tudo';

  @override
  String get menuFind => 'Localizar (F1)';

  @override
  String get menuPreferences => 'Preferências';

  @override
  String get snackOneFileCut => '1 item cortado para a área de transferência';

  @override
  String snackManyFilesCut(int count) {
    return '$count itens cortados para a área de transferência';
  }

  @override
  String get snackOneFileCopied =>
      '1 item copiado para a área de transferência';

  @override
  String snackManyFilesCopied(int count) {
    return '$count itens copiados para a área de transferência';
  }

  @override
  String get sortArrangeIcons => 'Dispor ícones';

  @override
  String get sortManual => 'Manualmente';

  @override
  String get sortByName => 'Por nome';

  @override
  String get sortBySize => 'Por tamanho';

  @override
  String get sortByType => 'Por tipo';

  @override
  String get sortByDetailedType => 'Por tipo detalhado';

  @override
  String get sortByDate => 'Por data de modificação';

  @override
  String get sortReverse => 'Ordem inversa';

  @override
  String get viewShowHidden => 'Mostrar ficheiros ocultos';

  @override
  String get viewHideHidden => 'Ocultar ficheiros ocultos';

  @override
  String get viewSplitScreen => 'Vista dividida (F3)';

  @override
  String get viewShowPreview => 'Mostrar pré-visualização';

  @override
  String get viewHidePreview => 'Ocultar pré-visualização';

  @override
  String get viewShowRightPanel => 'Mostrar barra lateral direita';

  @override
  String get viewHideRightPanel => 'Ocultar barra lateral direita';

  @override
  String get favAdd => 'Adicionar aos favoritos';

  @override
  String get favManage => 'Gerir favoritos';

  @override
  String get themesManage => 'Gestor de temas';

  @override
  String get toolsPackages => 'Desinstalar / instalar aplicações';

  @override
  String get toolsUpdates => 'Procurar atualizações';

  @override
  String get toolsBulkRenamePattern => 'Mudar nome em massa (padrão)';

  @override
  String get toolsExtractArchive => 'Extrair arquivo';

  @override
  String get helpShortcuts => 'Atalhos de teclado';

  @override
  String get helpUserGuide => 'Guia do utilizador';

  @override
  String get helpUserGuideTitle => 'Guia da aplicação';

  @override
  String get helpUserGuideBlock1 =>
      'NAVEGAÇÃO\n• Barra lateral: pasta pessoal, pastas padrão (Ambiente de trabalho, Documentos…), caminhos adicionados, favoritos, rede e discos montados. Arraste linhas para reordenar.\n• Barra de ferramentas e caminho: pasta superior, atualizar e pesquisa global.\n• Backspace: voltar no histórico. Se ativo nas Preferências, duplo clique em espaço vazio sobe à pasta superior.\n• Duplo clique numa pasta para abrir; duplo clique num ficheiro para abrir com a aplicação predefinida.';

  @override
  String get helpUserGuideBlock2 =>
      'FICHEIROS E ÁREA DE TRANSFERÊNCIA\n• Clique para selecionar; arraste um retângulo para vários itens. Ctrl para multiseleção, Shift para intervalos. Esc desmarca tudo.\n• Ctrl+C, Ctrl+X, Ctrl+V copiam, cortam e colam. Pode arrastar a seleção para fora da janela.\n• Botão direito: menu de contexto (mudar nome, eliminar, propriedades…). Os menus Ficheiro e Editar têm as mesmas ações.';

  @override
  String get helpUserGuideBlock3 =>
      'VISTAS E PESQUISA\n• Menu Ver: lista, grelha ou detalhes; ficheiros ocultos; ecrã dividido (F3); pré-visualização e painel direito (F6).\n• F5 atualiza a pasta atual. F2 abre uma nova janela.\n• Ferramentas → Localizar (F1) abre a pesquisa de ficheiros: filtros por nome, extensão, tamanho, tipo e data; uma árvore ou todos os volumes montados se a opção estiver ativa.';

  @override
  String get helpUserGuideBlock4 =>
      'DEFINIÇÕES E MAIS\n• Favoritos e Gestão de temas no menu superior (abre o editor de temas). Preferências: cliques, idioma, menu compacto, ecrã dividido e operações com ficheiros.\n• Computador lista discos. Adicione caminhos de rede na barra lateral; para SMB a app pode sugerir dependências.\n• Ferramentas: localizar ficheiros (F1), gestor de pacotes e verificação de atualizações quando disponíveis.\n• Ajuda → Atalhos de teclado lista todas as teclas; este guia resume o essencial.';

  @override
  String get helpAbout => 'Acerca';

  @override
  String get helpGitHubProject => 'Projeto no GitHub';

  @override
  String get helpDonateNow => 'Doar agora';

  @override
  String get helpCheckAppUpdate => 'Procurar atualização da aplicação';

  @override
  String appUpdateNewVersionAvailable(Object version) {
    return 'A versão $version está disponível.';
  }

  @override
  String get appUpdateViewRelease => 'Ver lançamento';

  @override
  String get appUpdateCheckFailed =>
      'Não foi possível verificar atualizações (rede ou GitHub).';

  @override
  String get appUpdateAlreadyLatest => 'Já está a usar a versão mais recente.';

  @override
  String get navBack => 'Recuar';

  @override
  String get navForward => 'Avançar';

  @override
  String get navUp => 'Subir';

  @override
  String get prefsGeneral => 'Geral';

  @override
  String get prefsSingleClickOpen => 'Clique único para abrir';

  @override
  String get prefsSingleClickOpenSubtitle =>
      'Abrir ficheiros e pastas com um único clique';

  @override
  String get prefsDoubleClickRename => 'Duplo clique para mudar o nome';

  @override
  String get prefsDoubleClickRenameSubtitle =>
      'Mudar o nome com duplo clique no nome';

  @override
  String get prefsDoubleClickEmptyUp => 'Duplo clique na área vazia para subir';

  @override
  String get prefsDoubleClickEmptyUpSubtitle =>
      'Ir para a pasta superior com duplo clique no espaço vazio';

  @override
  String get prefsLanguage => 'Idioma';

  @override
  String get prefsLanguageLabel => 'Idioma da interface';

  @override
  String get prefsMenuCompactTitle => 'Menu compacto';

  @override
  String get prefsMenuCompactSubtitle =>
      'Agrupar itens do menu atrás do ícone de três linhas em vez da barra clássica';

  @override
  String get smbShellLimitedModeGvfsFallback =>
      'Montagem CIFS falhou: pastas só via smbclient. Instale cifs-utils e confirme que mount.cifs está disponível e tente de novo.';

  @override
  String get smbShellFileOpenUnavailable =>
      'Caminho só smbclient (sem montagem CIFS). Monte a partilha com mount.cifs ou desative a opção se a montagem CIFS funcionar.';

  @override
  String get prefsExecTextTitle => 'Ficheiros de texto executáveis';

  @override
  String get prefsExecAuto => 'Executar automaticamente';

  @override
  String get prefsExecAlwaysShow => 'Mostrar sempre';

  @override
  String get prefsExecAlwaysAsk => 'Perguntar sempre';

  @override
  String get prefsDefaultFmTitle => 'Gestor de ficheiros predefinido';

  @override
  String get prefsDefaultFmBody =>
      'Definir este gestor como aplicação predefinida para abrir pastas.';

  @override
  String get prefsDefaultFmButton => 'Definir como gestor predefinido';

  @override
  String get langItalian => 'Italiano';

  @override
  String get langEnglish => 'Inglês';

  @override
  String get langFrench => 'Francês';

  @override
  String get langSpanish => 'Espanhol';

  @override
  String get langPortuguese => 'Português';

  @override
  String get langGerman => 'Alemão';

  @override
  String get fileListTypeFolder => 'Pasta';

  @override
  String get fileListTypeFile => 'Ficheiro';

  @override
  String get fileListEmpty => 'Sem ficheiros';

  @override
  String get copyProgressTitle => 'A copiar';

  @override
  String get copyProgressCancelTooltip => 'Cancelar';

  @override
  String copySpeed(String speed) {
    return 'Velocidade: $speed';
  }

  @override
  String copyRemaining(String time) {
    return 'Tempo restante: $time';
  }

  @override
  String copyProgressDestLine(String name) {
    return '→ $name';
  }

  @override
  String statusItems(int count) {
    return 'Itens: $count';
  }

  @override
  String statusFree(String size) {
    return 'Livre: $size';
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
    return 'Cópia: $source → $dest';
  }

  @override
  String statusCurrentFile(String name) {
    return 'Ficheiro: $name';
  }

  @override
  String get dialogCloseWhileCopyTitle => 'Operação em curso';

  @override
  String get dialogCloseWhileCopyBody =>
      'Há uma cópia ou movimento em curso. Fechar pode interromper. Continuar?';

  @override
  String get dialogCancel => 'Cancelar';

  @override
  String get dialogOverwriteTitle => 'Substituir o item existente?';

  @override
  String dialogOverwriteBody(String name) {
    return '\"$name\" já existe nesta pasta. Substituir?';
  }

  @override
  String get dialogOverwriteReplace => 'Substituir';

  @override
  String get dialogOverwriteSkip => 'Ignorar';

  @override
  String get dialogCloseAnyway => 'Fechar mesmo assim';

  @override
  String get commonClose => 'Fechar';

  @override
  String get commonSave => 'Guardar';

  @override
  String get commonDelete => 'Eliminar';

  @override
  String get commonRename => 'Mudar o nome';

  @override
  String get commonAdd => 'Adicionar';

  @override
  String commonError(String message) {
    return 'Erro: $message';
  }

  @override
  String get errorFolderRequiresOpenAsRoot =>
      'Para abrir esta pasta, use «Abrir como root».';

  @override
  String get sidebarAddNetworkTitle => 'Adicionar localização de rede';

  @override
  String get sidebarNetworkPathLabel => 'Caminho de rede';

  @override
  String get sidebarNetworkHint =>
      'smb://servidor/partilha ou //servidor/partilha';

  @override
  String get sidebarNetworkHelp =>
      'Exemplos:\n• smb://192.168.1.100/partilhado\n• //servidor/partilha\n• /mnt/rede';

  @override
  String get sidebarBrowseTooltip => 'Procurar';

  @override
  String get sidebarRenameShareTitle => 'Mudar o nome da partilha de rede';

  @override
  String get sidebarRemoveShareTitle => 'Remover partilha de rede';

  @override
  String sidebarRemoveShareConfirm(String name) {
    return 'Remover \"$name\" da lista?';
  }

  @override
  String get sidebarUnmountTitle => 'Desmontar disco';

  @override
  String sidebarUnmountConfirm(String name) {
    return 'Desmontar \"$name\"?';
  }

  @override
  String get sidebarUnmount => 'Desmontar';

  @override
  String sidebarUnmountOk(String name) {
    return '\"$name\" desmontado';
  }

  @override
  String sidebarUnmountFail(String name) {
    return 'Falha ao desmontar \"$name\"';
  }

  @override
  String get sidebarEmptyTrash => 'Esvaziar lixo';

  @override
  String get sidebarRemoveFromList => 'Remover da lista';

  @override
  String get sidebarMenuChangeColor => 'Mudar cor';

  @override
  String sidebarChangeColorDialogTitle(String name) {
    return 'Mudar cor: $name';
  }

  @override
  String get sidebarProperties => 'Propriedades';

  @override
  String sidebarPropertiesFolderTitle(String name) {
    return 'Propriedades: $name';
  }

  @override
  String get sidebarChangeFolderColor => 'Cor da pasta:';

  @override
  String get sidebarRemoveCustomColor => 'Remover cor personalizada';

  @override
  String get sidebarChangeAllFoldersColor => 'Cor de todas as pastas';

  @override
  String get sidebarPickDefaultColor =>
      'Escolha uma cor predefinida para todas as pastas:';

  @override
  String get sidebarEmptyTrashTitle => 'Esvaziar lixo';

  @override
  String get sidebarEmptyTrashBody =>
      'Esvaziar o lixo de forma permanente? Não pode ser anulado.';

  @override
  String get sidebarEmptyTrashConfirm => 'Esvaziar';

  @override
  String get sidebarTrashEmptied => 'Lixo esvaziado';

  @override
  String sidebarCredentialsTitle(String server) {
    return 'Credenciais para $server';
  }

  @override
  String get sidebarGuestAccess => 'Acesso convidado (anónimo)';

  @override
  String get sidebarConnect => 'Ligar';

  @override
  String sidebarConnecting(String name) {
    return 'A ligar a $name...';
  }

  @override
  String sidebarConnectionError(String name) {
    return 'Erro ao ligar a $name';
  }

  @override
  String get sidebarRetry => 'Tentar novamente';

  @override
  String get copyCancelled => 'Cópia cancelada';

  @override
  String get fileCopiedSuccess => 'Ficheiro copiado';

  @override
  String get folderCopiedSuccess => 'Pasta copiada';

  @override
  String get extractionComplete => 'Extração concluída';

  @override
  String snackInitError(String error) {
    return 'Erro de inicialização: $error';
  }

  @override
  String snackPathRemoved(String name) {
    return 'Removido da lista: $name';
  }

  @override
  String get labelChoosePath => 'Escolher caminho';

  @override
  String get ctxOpenTerminal => 'Abrir terminal';

  @override
  String get ctxNewFolder => 'Nova pasta';

  @override
  String get ctxOpenAsRoot => 'Abrir como root';

  @override
  String get ctxOpenWith => 'Abrir com…';

  @override
  String get ctxCopyTo => 'Copiar para…';

  @override
  String get ctxMoveTo => 'Mover para…';

  @override
  String get ctxCopy => 'Copiar';

  @override
  String get ctxCut => 'Cortar';

  @override
  String get ctxPaste => 'Colar';

  @override
  String get ctxCreateNew => 'Novo';

  @override
  String get ctxNewTextDocumentShort => 'Documento de texto (.txt)';

  @override
  String get ctxNewWordDocument => 'Documento Word (.docx)';

  @override
  String get ctxNewExcelSpreadsheet => 'Folha de cálculo Excel (.xlsx)';

  @override
  String get ctxExtract => 'Extrair';

  @override
  String get ctxExtractTo => 'Extrair arquivo para…';

  @override
  String get ctxCompressToZip => 'Comprimir para ficheiro .zip';

  @override
  String snackZipCreated(Object name) {
    return 'Arquivo criado: \"$name\".';
  }

  @override
  String snackZipFailed(Object message) {
    return 'Não foi possível criar o ZIP: $message';
  }

  @override
  String get ctxChangeColor => 'Alterar cor';

  @override
  String get ctxMoveToTrash => 'Mover para o lixo';

  @override
  String get ctxRestoreFromTrash => 'Restaurar na pasta original';

  @override
  String get menuRestoreFromTrash => 'Restaurar do lixo';

  @override
  String get trashRestorePickFolderTitle => 'Escolher pasta para restaurar';

  @override
  String trashRestoreTargetExists(String name) {
    return 'Não é possível restaurar: \"$name\" já existe no destino.';
  }

  @override
  String trashRestoredCount(int count) {
    return '$count itens restaurados';
  }

  @override
  String get trashRestoreFailed =>
      'Não foi possível restaurar os itens selecionados.';

  @override
  String dialogOpenWithTitle(String name) {
    return 'Abrir \"$name\" com…';
  }

  @override
  String get hintSearchApp => 'Procurar aplicação…';

  @override
  String get openWithDefaultApp => 'Aplicação predefinida';

  @override
  String get browseEllipsis => 'Procurar…';

  @override
  String get tooltipSetAsDefaultApp => 'Definir como aplicação predefinida';

  @override
  String get openWithOpenAndSetDefault => 'Abrir e definir como predefinida';

  @override
  String get openWithFooterHint =>
      'Use a estrela ou o menu ⋮ para alterar a aplicação predefinida para este tipo de ficheiro a qualquer momento.';

  @override
  String snackDefaultAppSet(String appName, String mimeType) {
    return '$appName definida como predefinida para $mimeType';
  }

  @override
  String snackSetDefaultAppError(String error) {
    return 'Não foi possível definir o predefinido: $error';
  }

  @override
  String snackOpenFileError(String error) {
    return 'Não foi possível abrir: $error';
  }

  @override
  String get dialogTitleCreateFolder => 'Criar nova pasta';

  @override
  String get dialogTitleNewFolder => 'Nova pasta';

  @override
  String get labelFolderName => 'Nome da pasta';

  @override
  String get hintFolderName => 'Introduza o nome da pasta';

  @override
  String get labelFileName => 'Nome do ficheiro';

  @override
  String get hintTextDocument => 'documento.txt';

  @override
  String get buttonCreate => 'Criar';

  @override
  String snackMoveError(String error) {
    return 'Erro ao mover: $error';
  }

  @override
  String dialogChangeColorFor(String name) {
    return 'Alterar cor: $name';
  }

  @override
  String get dialogPickFolderColor => 'Escolha uma cor para a pasta:';

  @override
  String get shortcutTitle => 'Atalhos de teclado';

  @override
  String get shortcutCopy => 'Copiar ficheiros/pastas selecionados';

  @override
  String get shortcutPaste => 'Colar ficheiros/pastas';

  @override
  String get shortcutCut => 'Cortar ficheiros/pastas selecionados';

  @override
  String get shortcutUndo => 'Anular última operação';

  @override
  String get shortcutRedo => 'Refazer última operação';

  @override
  String get shortcutNewTab => 'Novo separador';

  @override
  String get shortcutSplitView => 'Dividir ecrã em dois';

  @override
  String get shortcutRefresh => 'Atualizar pasta atual';

  @override
  String get shortcutRightPanel => 'Mostrar/ocultar barra lateral direita';

  @override
  String get shortcutDeselect => 'Desmarcar tudo';

  @override
  String get shortcutBackNav => 'Recuar na navegação';

  @override
  String get shortcutFindFiles => 'Encontrar ficheiros e pastas';

  @override
  String get aboutTitle => 'Acerca';

  @override
  String get aboutAppName => 'Gestor de ficheiros';

  @override
  String get aboutTagline => 'Gestor de ficheiros avançado';

  @override
  String aboutVersionLabel(String version) {
    return 'Versão: $version';
  }

  @override
  String get aboutAuthor => 'Autor: Marco Di Giangiacomo';

  @override
  String get aboutYear => '© 2026';

  @override
  String get aboutDescriptionHeading => 'Descrição:';

  @override
  String get aboutDescription =>
      'SAGE File Manager: gestor moderno para Linux com várias vistas, pré-visualizações, temas, pesquisa, cópia otimizada, vista dividida, SMB/LAN e mais.';

  @override
  String get aboutFeaturesHeading => 'Principais funcionalidades:';

  @override
  String get aboutFeaturesList =>
      '• Gestão completa de ficheiros e pastas\n• Vistas múltiplas (lista, grelha, detalhes)\n• Pré-visualização (imagens, PDF, documentos, texto)\n• Gestão de temas (predefinidos e personalização)\n• Pesquisa avançada\n• Copiar/colar otimizado\n• Vista dividida\n• Favoritos e caminhos\n• Executáveis e scripts\n• Interface moderna';

  @override
  String snackDocumentCreated(String name) {
    return 'Documento \"$name\" criado';
  }

  @override
  String get dialogInsufficientPermissions => 'Permissões insuficientes';

  @override
  String get snackFolderCreated => 'Pasta criada';

  @override
  String get snackTerminalUnavailable => 'Terminal indisponível';

  @override
  String get snackTerminalRootError =>
      'Não foi possível abrir o terminal como root';

  @override
  String get snackRootHelperMissing =>
      'Não foi possível abrir como root. Instale pkexec ou sudo.';

  @override
  String get snackOpenAsRootNoFolder =>
      'Abra primeiro uma pasta e escolha Abrir como root.';

  @override
  String get snackOpenAsRootBadFolder => 'Não é possível abrir essa pasta.';

  @override
  String snackPasteItemError(String name, String error) {
    return 'Erro ao colar $name: $error';
  }

  @override
  String get snackFileMoved => 'Ficheiro movido';

  @override
  String get dialogRenameFileTitle => 'Mudar o nome';

  @override
  String dialogRenameManySubtitle(int count) {
    return '$count itens selecionados. Introduza um novo nome em cada linha.';
  }

  @override
  String get labelNewName => 'Novo nome';

  @override
  String get snackFileRenamed => 'Ficheiro renomeado';

  @override
  String snackRenameError(String error) {
    return 'Erro ao renomear: $error';
  }

  @override
  String get snackRenameSameFolder =>
      'Todos os itens selecionados devem estar na mesma pasta.';

  @override
  String get snackRenameEmptyName =>
      'Cada item precisa de um novo nome não vazio.';

  @override
  String get snackRenameDuplicateNames =>
      'Os novos nomes devem ser todos diferentes.';

  @override
  String get snackRenameTargetExists =>
      'Já existe um ficheiro ou pasta com esse nome.';

  @override
  String get snackSelectPathFirst => 'Selecione primeiro um caminho';

  @override
  String get snackAlreadyFavorite => 'Já está nos favoritos';

  @override
  String snackAddedFavorite(String name) {
    return 'Adicionado aos favoritos: $name';
  }

  @override
  String get favoritesEmptyList => 'Ainda sem favoritos';

  @override
  String snackNewTabOpened(String name) {
    return 'Novo separador: $name';
  }

  @override
  String get snackSelectForSymlink =>
      'Selecione um ficheiro ou pasta para o atalho';

  @override
  String get dialogCreateSymlinkTitle => 'Criar atalho';

  @override
  String get labelSymlinkName => 'Nome do atalho';

  @override
  String get snackSymlinkCreated => 'Atalho criado';

  @override
  String get snackConnectingNetwork => 'A ligar à rede…';

  @override
  String get snackNewInstanceStarted => 'Nova instância iniciada';

  @override
  String snackNewInstanceError(String error) {
    return 'Não foi possível iniciar nova instância: $error';
  }

  @override
  String get snackSelectFilesRename =>
      'Selecione pelo menos um ficheiro para renomear';

  @override
  String get bulkRenameTitle => 'Mudar nome em massa';

  @override
  String bulkRenameSelectedCount(int count) {
    return '$count ficheiros selecionados';
  }

  @override
  String get bulkRenamePatternLabel => 'Padrão de nome';

  @override
  String get bulkRenamePatternHelper =>
      'Use os marcadores name e num entre chavetas (veja o exemplo abaixo).';

  @override
  String get bulkRenameAutoNumber => 'Numeração automática';

  @override
  String get bulkRenameStartNumber => 'Número inicial';

  @override
  String get bulkRenameKeepExt => 'Manter extensão original';

  @override
  String trashEmptyError(String error) {
    return 'Erro ao esvaziar o lixo: $error';
  }

  @override
  String labelNItems(int count) {
    return '$count itens';
  }

  @override
  String get dialogTitleDeletePermanent => 'Eliminar permanentemente?';

  @override
  String get dialogTitleMoveToTrashConfirm => 'Mover para o lixo?';

  @override
  String get dialogBodyPermanentDeleteOne =>
      'Eliminar permanentemente um item?';

  @override
  String dialogBodyPermanentDeleteMany(int count) {
    return 'Eliminar permanentemente $count itens?';
  }

  @override
  String get dialogBodyTrashOne => 'Mover um item para o lixo?';

  @override
  String dialogBodyTrashMany(int count) {
    return 'Mover $count itens para o lixo?';
  }

  @override
  String get snackDeletedPermanentOne => 'Um item eliminado permanentemente';

  @override
  String snackDeletedPermanentMany(int count) {
    return '$count itens eliminados permanentemente';
  }

  @override
  String get snackMovedToTrashOne => 'Um item movido para o lixo';

  @override
  String snackMovedToTrashMany(int count) {
    return '$count itens movidos para o lixo';
  }

  @override
  String snackDeleteErrorsSuffix(int errors) {
    return ', $errors erros';
  }

  @override
  String get dialogOpenAsRootBody =>
      'Não tem permissão para criar ficheiros ou pastas nesta pasta. Abrir o gestor de ficheiros como root?';

  @override
  String get dialogOpenAsRootAuthTitle => 'Abrir como administrador';

  @override
  String get dialogOpenAsRootAuthBody =>
      'Depois de Continuar, o sistema pedirá a palavra-passe de administrador. Só após autenticação bem-sucedida é que uma nova janela do gestor de ficheiros abrirá nesta pasta.';

  @override
  String get dialogOpenAsRootContinue => 'Continuar';

  @override
  String get paneSelectPathHint => 'Selecione um caminho';

  @override
  String get emptyFolderLabel => 'Pasta vazia';

  @override
  String get sidebarMountPointOptional => 'Ponto de montagem (opcional)';

  @override
  String snackBulkRenameManyDone(int count) {
    return '$count ficheiros renomeados';
  }

  @override
  String get commonOk => 'OK';

  @override
  String get prefsPageTitle => 'Preferências';

  @override
  String get snackPrefsSaved => 'Preferências guardadas';

  @override
  String get prefsNavView => 'Visualização';

  @override
  String get prefsNavPreview => 'Pré-visualização';

  @override
  String get prefsNavFileOps => 'Operações de ficheiros';

  @override
  String get prefsNavTrash => 'Lixo';

  @override
  String get prefsNavMedia => 'Suportes removíveis';

  @override
  String get prefsNavCache => 'Cache';

  @override
  String get prefsDefaultFmSuccess =>
      'Gestor de ficheiros definido como predefinido.';

  @override
  String get prefsShowHiddenTitle => 'Mostrar ficheiros ocultos';

  @override
  String get prefsShowHiddenSubtitle =>
      'Mostrar ficheiros e pastas cujo nome começa por ponto';

  @override
  String get prefsShowPreviewPanelTitle => 'Mostrar painel de pré-visualização';

  @override
  String get prefsShowPreviewPanelSubtitle =>
      'Mostrar o painel de pré-visualização à direita';

  @override
  String get prefsAlwaysDoublePaneTitle => 'Iniciar sempre com vista dividida';

  @override
  String get prefsAlwaysDoublePaneSubtitle =>
      'Abrir sempre a vista dividida ao iniciar';

  @override
  String get prefsIgnoreViewPerFolderTitle =>
      'Ignorar preferências de vista por pasta';

  @override
  String get prefsIgnoreViewPerFolderSubtitle =>
      'Não guardar preferências de vista por pasta';

  @override
  String get prefsDefaultViewModeTitle => 'Modo de vista predefinido';

  @override
  String get prefsViewModeList => 'Lista';

  @override
  String get prefsViewModeGrid => 'Grelha';

  @override
  String get prefsViewModeDetails => 'Detalhes';

  @override
  String get prefsGridZoomTitle => 'Nível de zoom da grelha predefinido';

  @override
  String prefsGridZoomLevel(int current) {
    return 'Nível: $current/10';
  }

  @override
  String get prefsFontSection => 'Tipo de letra';

  @override
  String get prefsFontFamilyLabel => 'Família de letra';

  @override
  String get labelSelectFont => 'Selecionar tipo de letra';

  @override
  String get fontFamilyDefaultSystem => 'Predefinido (sistema)';

  @override
  String get prefsFontSizeTitle => 'Tamanho da letra';

  @override
  String prefsFontSizeValue(String size) {
    return 'Tamanho: $size';
  }

  @override
  String get prefsFontWeightTitle => 'Peso da letra';

  @override
  String get prefsFontWeightNormal => 'Normal';

  @override
  String get prefsFontWeightBold => 'Negrito';

  @override
  String get prefsFontWeightSemiBold => 'Seminegrito';

  @override
  String get prefsFontWeightMedium => 'Médio';

  @override
  String get prefsTextShadowSection => 'Sombra do texto';

  @override
  String get prefsTextShadowEnableTitle => 'Ativar sombra do texto';

  @override
  String get prefsTextShadowEnableSubtitle =>
      'Adiciona sombra ao texto para legibilidade';

  @override
  String get prefsShadowIntensityTitle => 'Desfoque da sombra';

  @override
  String get prefsShadowOffsetXTitle => 'Deslocamento sombra X';

  @override
  String get prefsShadowOffsetYTitle => 'Deslocamento sombra Y';

  @override
  String get prefsShadowColorTitle => 'Cor da sombra';

  @override
  String prefsShadowColorValue(String value) {
    return 'Cor: $value';
  }

  @override
  String get prefsShadowColorBlack => 'Preto';

  @override
  String get dialogPickShadowColor => 'Escolher cor da sombra';

  @override
  String get prefsPickColor => 'Escolher cor';

  @override
  String get prefsTextPreviewLabel => 'Pré-visualização de texto';

  @override
  String get prefsDisableFileQueueTitle => 'Desativar fila de operações';

  @override
  String get prefsDisableFileQueueSubtitle =>
      'Executar operações em sequência sem fila';

  @override
  String get prefsAskTrashTitle => 'Perguntar antes de mover para o lixo';

  @override
  String get prefsAskTrashSubtitle => 'Confirmar antes de mover para o lixo';

  @override
  String get prefsAskEmptyTrashTitle => 'Perguntar antes de esvaziar o lixo';

  @override
  String get prefsAskEmptyTrashSubtitle =>
      'Confirmar antes de eliminar definitivamente';

  @override
  String get prefsIncludeDeleteTitle => 'Incluir comando Eliminar';

  @override
  String get prefsIncludeDeleteSubtitle => 'Opção para eliminar sem lixo';

  @override
  String get prefsSkipTrashDelKeyTitle => 'Ignorar lixo com Eliminar';

  @override
  String get prefsSkipTrashDelKeySubtitle =>
      'Eliminar diretamente com Eliminar';

  @override
  String get prefsAutoMountTitle => 'Montar automaticamente dispositivos';

  @override
  String get prefsAutoMountSubtitle => 'Montar USB e outros ao ligar';

  @override
  String get prefsOpenWindowMountedTitle =>
      'Abrir janela para dispositivos montados';

  @override
  String get prefsOpenWindowMountedSubtitle => 'Abrir janela automaticamente';

  @override
  String get prefsWarnRemovableTitle => 'Avisar ao ligar um dispositivo';

  @override
  String get prefsWarnRemovableSubtitle =>
      'Notificação ao ligar suporte removível';

  @override
  String get prefsPreviewExtensionsIntro =>
      'Extensões para ativar pré-visualização:';

  @override
  String get prefsPreviewRightPanelNote =>
      'As pré-visualizações completas de PDF, Office, texto e outros tipos aparecem na barra lateral direita quando está visível. Se a barra estiver oculta, na lista de ficheiros só são mostradas miniaturas de imagens.';

  @override
  String get prefsAdminPasswordSection => 'Palavra-passe de administrador';

  @override
  String get prefsSaveAdminPasswordTitle =>
      'Guardar palavra-passe de administrador';

  @override
  String get prefsSaveAdminPasswordSubtitle =>
      'Guardar palavra-passe para atualizações (não recomendado)';

  @override
  String get labelAdminPassword => 'Palavra-passe de administrador';

  @override
  String get hintAdminPassword => 'Introduzir palavra-passe';

  @override
  String get prefsCacheSectionTitle => 'Cache e pré-visualizações';

  @override
  String get prefsCacheSizeTitle => 'Tamanho da cache';

  @override
  String prefsCacheSizeCurrent(String size) {
    return 'Tamanho atual: $size';
  }

  @override
  String get labelNetworkShareName => 'Nome personalizado';

  @override
  String get hintNetworkShareName => 'Nome para esta partilha';

  @override
  String get sidebarTooltipRemoveNetwork => 'Remover caminho de rede';

  @override
  String get sidebarTooltipUnmount => 'Desmontar disco';

  @override
  String sidebarUnmountSuccess(String name) {
    return '«$name» desmontado';
  }

  @override
  String sidebarUnmountError(String name) {
    return 'Erro ao desmontar «$name»';
  }

  @override
  String get previewSelectFile => 'Selecione um ficheiro para pré-visualizar';

  @override
  String get previewPanelTitle => 'Pré-visualização';

  @override
  String previewPanelSizeLine(String value) {
    return 'Tamanho: $value';
  }

  @override
  String previewPanelModifiedLine(String value) {
    return 'Modificado: $value';
  }

  @override
  String get dialogErrorTitle => 'Erro';

  @override
  String get propsLoadError => 'Não foi possível carregar propriedades';

  @override
  String get snackPermissionsUpdated => 'Permissões atualizadas';

  @override
  String dialogEditFieldTitle(String label) {
    return 'Editar $label';
  }

  @override
  String snackFieldUpdated(String label) {
    return '$label atualizado';
  }

  @override
  String get propsEditPermissionsTitle => 'Editar permissões';

  @override
  String get permOwner => 'Proprietário:';

  @override
  String get permGroup => 'Grupo:';

  @override
  String get permOthers => 'Outros:';

  @override
  String get permRead => 'Leitura';

  @override
  String get permWrite => 'Escrita';

  @override
  String get permExecute => 'Execução';

  @override
  String get previewNotAvailable => 'Pré-visualização indisponível';

  @override
  String get previewImageError => 'Erro ao carregar imagem';

  @override
  String get previewDocLoadError => 'Erro ao carregar documento';

  @override
  String get previewOpenExternally => 'Abrir com visualizador externo';

  @override
  String get previewDocumentTitle => 'Pré-visualização de documento';

  @override
  String get previewDocLegacyFormat =>
      '.doc não suportado. Use .docx ou um visualizador externo.';

  @override
  String get previewSheetLoadError => 'Erro ao carregar folha de cálculo';

  @override
  String get previewSheetTitle => 'Pré-visualização de folha de cálculo';

  @override
  String get previewXlsLegacyFormat =>
      '.xls não suportado. Use .xlsx ou um visualizador externo.';

  @override
  String get previewPresentationLoadError => 'Erro ao carregar apresentação';

  @override
  String get previewOpenOfficeTitle => 'Pré-visualização OpenOffice';

  @override
  String get previewOpenOfficeBody =>
      'Ficheiros OpenOffice precisam de visualizador externo.';

  @override
  String themeApplied(String name) {
    return 'Tema «$name» aplicado';
  }

  @override
  String get themeDark => 'Tema escuro';

  @override
  String themeFontSizeTitle(String size) {
    return 'Tamanho da letra: $size';
  }

  @override
  String get themeFontWeightSection => 'Peso da letra';

  @override
  String get themeBoldLabel => 'Negrito';

  @override
  String get themeTextShadowSection => 'Sombra do texto';

  @override
  String themeShadowIntensity(String percent) {
    return 'Intensidade da sombra: $percent%';
  }

  @override
  String get themeColorPicked => 'Cor selecionada';

  @override
  String get themeSelectToCustomize => 'Selecione um tema para personalizar';

  @override
  String get themeFontFamilySection => 'Família de letra';

  @override
  String get searchNeedCriterion => 'Introduza pelo menos um critério';

  @override
  String get searchCurrentPath => 'Caminho atual';

  @override
  String get searchButton => 'Pesquisar';

  @override
  String get pkgConfirmUninstallTitle => 'Confirmar desinstalação';

  @override
  String pkgConfirmUninstallBody(String name) {
    return 'Desinstalar $name?';
  }

  @override
  String get pkgDependenciesTitle => 'Dependências encontradas';

  @override
  String get pkgUninstallError => 'Erro na desinstalação';

  @override
  String get pkgManagerTitle => 'Gestor de aplicações';

  @override
  String get pkgInstallTitle => 'Instalar pacote';

  @override
  String pkgInstallBody(String name) {
    return 'Instalar «$name»?';
  }

  @override
  String pkgMadeExecutable(String name) {
    return '$name tornado executável';
  }

  @override
  String get pkgUnsupportedFormat => 'Formato de pacote não suportado';

  @override
  String pkgInstallErrorOutput(String output) {
    return 'Erro na instalação: $output';
  }

  @override
  String updateItemSuccess(String name) {
    return '$name atualizado com sucesso';
  }

  @override
  String updateItemError(String name) {
    return 'Erro ao atualizar $name';
  }

  @override
  String get updateAllError => 'Erro ao instalar atualizações';

  @override
  String get updateInstallAllButton => 'Instalar tudo';

  @override
  String get previewCatImages => 'Imagens';

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
  String get tableColumnName => 'Nome';

  @override
  String get tableColumnPath => 'Caminho';

  @override
  String get tableColumnSize => 'Tamanho';

  @override
  String get tableColumnModified => 'Modificado';

  @override
  String get tableColumnType => 'Tipo';

  @override
  String get networkBrowserTitle => 'Explorar rede';

  @override
  String get networkSearchingServers => 'A procurar servidores…';

  @override
  String get networkNoServersFound => 'Nenhum servidor encontrado';

  @override
  String get networkServersSharesHeader => 'Servidores e partilhas';

  @override
  String get labelUsername => 'Utilizador';

  @override
  String get labelPassword => 'Palavra-passe';

  @override
  String get networkRefreshTooltip => 'Atualizar';

  @override
  String get networkNoSharesAvailable => 'Nenhuma partilha disponível';

  @override
  String get networkInfoTitle => 'Informação';

  @override
  String networkServersFoundCount(int count) {
    return 'Servidores encontrados: $count';
  }

  @override
  String get networkConnectShareInstructions =>
      'Para se ligar a uma partilha, expanda um servidor e toque na partilha pretendida.';

  @override
  String get networkSelectedServerLabel => 'Servidor selecionado:';

  @override
  String networkSharesCount(int count) {
    return 'Partilhas: $count';
  }

  @override
  String get sidebarTooltipBrowseNetworkPaths => 'Explorar caminhos de rede';

  @override
  String get sidebarTooltipAddNetworkPath => 'Adicionar caminho de rede';

  @override
  String get sidebarSectionNetwork => 'Rede';

  @override
  String get sidebarSectionDisks => 'Discos';

  @override
  String get sidebarAddPath => 'Adicionar caminho';

  @override
  String get sidebarUserFolderHome => 'Início';

  @override
  String get sidebarUserFolderDesktop => 'Ambiente de trabalho';

  @override
  String get sidebarUserFolderDocuments => 'Documentos';

  @override
  String get sidebarUserFolderPictures => 'Imagens';

  @override
  String get sidebarUserFolderMusic => 'Música';

  @override
  String get sidebarUserFolderVideos => 'Vídeos';

  @override
  String get sidebarUserFolderDownloads => 'Transferências';

  @override
  String get sidebarSectionFavorites => 'Favoritos';

  @override
  String get commonUnknown => 'Desconhecido';

  @override
  String get prefsClearCacheButton => 'Limpar cache';

  @override
  String get prefsClearCacheTitle => 'Limpar cache';

  @override
  String get prefsClearCacheBody =>
      'Limpar toda a cache das miniaturas de pré-visualização?';

  @override
  String get prefsClearCacheConfirm => 'Limpar';

  @override
  String get snackPrefsCacheCleared => 'Cache limpa';

  @override
  String get previewFmtJpeg => 'Imagem JPEG';

  @override
  String get previewFmtPng => 'Imagem PNG';

  @override
  String get previewFmtGif => 'Imagem GIF';

  @override
  String get previewFmtBmp => 'Imagem BMP';

  @override
  String get previewFmtWebp => 'Imagem WebP';

  @override
  String get previewFmtPdf => 'Documento PDF';

  @override
  String get previewFmtPlainText => 'Ficheiro de texto';

  @override
  String get previewFmtMarkdown => 'Markdown';

  @override
  String get previewFmtNfo => 'Ficheiro de informação';

  @override
  String get previewFmtShell => 'Script shell';

  @override
  String get previewFmtHtml => 'Documento HTML';

  @override
  String get previewFmtDocx => 'Documento Word';

  @override
  String get previewFmtXlsx => 'Folha Excel';

  @override
  String get previewFmtPptx => 'Apresentação PowerPoint';

  @override
  String themeAppliedSnackbar(String name) {
    return 'Theme \"$name\" applied';
  }

  @override
  String get themeEditTitle => 'Edit theme';

  @override
  String get themeNewTitle => 'New theme';

  @override
  String get themeFieldName => 'Theme name';

  @override
  String get themeDarkThemeSwitch => 'Dark theme';

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
  String get themeManagerTitle => 'Gestão de temas';

  @override
  String get themeBuiltinHeader => 'Temas predefinidos';

  @override
  String get themeCustomHeader => 'Temas personalizados';

  @override
  String get themeCustomizationHeader => 'Customization';

  @override
  String get themeSelectPrompt => 'Select a theme to customize';

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
  String get themeIconShadowTitle => 'Sombra dos ícones (grelha)';

  @override
  String get themeIconShadowSubtitle =>
      'Sombra por baixo dos ícones de ficheiros e pastas na vista grelha';

  @override
  String themeIconShadowIntensity(String percent) {
    return 'Intensidade da sombra dos ícones: $percent%';
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
  String get propsTitle => 'Propriedades';

  @override
  String get propsTimeoutLoading => 'Timed out loading properties';

  @override
  String propsLoadErrorDetail(String detail) {
    return 'Error loading properties: $detail';
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
      other: '$count itens selecionados',
      one: '1 item selecionado',
    );
    return '$_temp0';
  }

  @override
  String get propsMultiTypeMixed => 'Seleção mista (ficheiros e pastas)';

  @override
  String get propsMultiCombinedSize => 'Tamanho total em disco';

  @override
  String get propsMultiLoadingSizes => 'A calcular tamanhos…';

  @override
  String get propsMultiPerItemTitle => 'Cada item';

  @override
  String propsMultiCountSummary(int folderCount, int fileCount) {
    return '$folderCount pastas, $fileCount ficheiros';
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
  String get pkgPageTitle => 'Aplicações';

  @override
  String get pkgInstallFromFileTooltip => 'Install package from file';

  @override
  String get pkgFilterAll => 'Todas';

  @override
  String get pkgSearchHint => 'Search applications…';

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
  String get pkgInstallProgressTitle => 'A instalar pacote';

  @override
  String get pkgInstallRunningStatus => 'A iniciar o instalador…';

  @override
  String get zipProgressPanelTitle => 'A comprimir para ZIP';

  @override
  String get zipProgressSubtitle => 'A adicionar ficheiros ao arquivo';

  @override
  String get zipProgressEncoding => 'A escrever arquivo…';

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
  String get updateTitle => 'Atualizações';

  @override
  String updateTitleWithCount(int count) {
    return 'Atualizações ($count)';
  }

  @override
  String get updateInstallAll => 'Install all';

  @override
  String get updateNoneAvailable => 'No updates available';

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
  String get searchDialogTitle => 'Encontrar ficheiros';

  @override
  String searchPathLabel(String path) {
    return 'Caminho: $path';
  }

  @override
  String get searchSelectDiskTooltip => 'Select drive';

  @override
  String get searchAllMountsLabel => 'Pesquisar em todos os volumes montados';

  @override
  String get searchAllMountsHint =>
      'USB, partições extra, GVFS/rede (se acessível). Mais lento do que uma pasta única.';

  @override
  String searchAllMountsActive(int count) {
    return 'A pesquisar em $count localizações (todos os mounts)';
  }

  @override
  String get searchPathCurrentMenu => 'Current path';

  @override
  String get searchPathRootMenu => 'Raiz do sistema de ficheiros';

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
  String get searchNoCriteriaSnack => 'Enter at least one search criterion';

  @override
  String searchError(String error) {
    return 'Search error: $error';
  }

  @override
  String get searchNoResults => 'Sem resultados';

  @override
  String get searchResultsOne => '1 result found';

  @override
  String searchResultsMany(int count) {
    return '$count results found';
  }

  @override
  String get searchTooltipViewList => 'Lista';

  @override
  String get searchTooltipViewGrid => 'Grelha';

  @override
  String get searchTooltipViewDetails => 'Detalhes';

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
  String get depsDialogTitle => 'Componentes do sistema';

  @override
  String get depsDialogIntro =>
      'Faltam os seguintes componentes. Pode instalá-los agora com a palavra-passe de administrador (PolicyKit).';

  @override
  String get depsInstallButton => 'Instalar agora (palavra-passe admin)';

  @override
  String get depsContinueButton => 'Continuar sem instalar';

  @override
  String get depsInstalling => 'A instalar pacotes…';

  @override
  String get depsInstallSuccess => 'Instalação concluída.';

  @override
  String depsInstallFailed(String message) {
    return 'Falha na instalação: $message';
  }

  @override
  String get depsUnknownDistro =>
      'Instalação automática indisponível para esta distribuição. Instale os pacotes manualmente num terminal.';

  @override
  String get depsManualCommandLabel => 'Comando sugerido';

  @override
  String get depsPkexecNotFound =>
      'pkexec não encontrado. Execute no terminal:';

  @override
  String get depsRustUnavailable =>
      'Biblioteca nativa (Rust) não carregada. A cópia pode ser mais lenta. Reinstale a aplicação se persistir.';

  @override
  String get depLabelXdgOpen =>
      'xdg-open — abrir ficheiros com aplicações predefinidas';

  @override
  String get depLabelMountCifs =>
      'mount.cifs — montar partilhas SMB (cifs-utils)';

  @override
  String get depsCifsInstallTitle => 'Instalar cifs-utils?';

  @override
  String get depsCifsInstallBody =>
      'Para montar partilhas SMB é necessário o mount.cifs do pacote cifs-utils. Instalar agora com o gestor de pacotes (palavra-passe de administrador)?';

  @override
  String get depLabelSmbclient => 'smbclient — explorar partilhas SMB/CIFS';

  @override
  String get depLabelNmblookup =>
      'nmblookup — encontrar computadores na LAN (NetBIOS)';

  @override
  String get depLabelAvahiBrowse => 'avahi-browse — descoberta de rede (mDNS)';

  @override
  String get depLabelAvahiResolve =>
      'avahi-resolve-address — resolve nomes de anfitrião na LAN (mDNS)';

  @override
  String get depsNetworkBannerHint =>
      'Faltam ferramentas opcionais para encontrar PCs na rede e montar partilhas. Pode instalá-las automaticamente (é necessária palavra-passe de administrador).';

  @override
  String get depsNetworkBannerLater => 'Agora não';

  @override
  String get depsSomeStillMissing =>
      'Ainda faltam ferramentas. Tente o comando de terminal sugerido abaixo.';

  @override
  String get depsPolkitAuthFailed =>
      'A autenticação de administrador foi cancelada ou recusada, ou o pkexec não conseguiu executar o instalador.';

  @override
  String get depsInstallOutputIntro => 'Saída do gestor de pacotes:';

  @override
  String get depsInstallUnexpected => 'erro inesperado';

  @override
  String get depsDialogIntroRustOnly =>
      'A aceleração nativa para algumas operações em ficheiros não está disponível (biblioteca Rust).';

  @override
  String get depsDialogIntroToolsOk =>
      'As ferramentas de linha de comandos necessárias estão instaladas.';

  @override
  String get depsCloseButton => 'Fechar';

  @override
  String get computerTitle => 'Computador';

  @override
  String get computerOnDevice => 'Neste dispositivo';

  @override
  String get computerNetworks => 'Rede';

  @override
  String get computerNoVolumes => 'Nenhum volume encontrado';

  @override
  String get computerNoServers => 'Nenhum servidor encontrado';

  @override
  String get computerTools => 'Ferramentas';

  @override
  String get computerToolFindFiles => 'Encontrar ficheiros e pastas';

  @override
  String get computerToolPackages => 'Desinstalar/Instalar apps';

  @override
  String get computerToolSystemUpdates => 'Procurar atualizações do sistema';

  @override
  String get computerRefresh => 'Atualizar';

  @override
  String computerFreeShort(String size) {
    return '$size livres';
  }

  @override
  String computerNetworkHint(String name) {
    return 'Ligue pela barra lateral → Rede: $name';
  }

  @override
  String get computerVolumeOpen => 'Abrir';

  @override
  String get computerFormatVolume => 'Formatar…';

  @override
  String get computerFormatTitle => 'Formatar volume';

  @override
  String get computerFormatWarning =>
      'Todos os dados neste volume serão apagados. Não pode ser anulado.';

  @override
  String get computerFormatFilesystem => 'Sistema de ficheiros';

  @override
  String get computerFormatConfirm => 'Formatar';

  @override
  String get computerFormatNotSupported =>
      'A formatação neste ecrã só é suportada no Linux com udisks2.';

  @override
  String get computerFormatNoDevice =>
      'Não foi possível determinar o dispositivo de blocos.';

  @override
  String get computerFormatSystemBlockedTitle => 'Não é possível formatar';

  @override
  String get computerFormatSystemBlockedBody =>
      'Este é um volume de sistema (raiz, arranque ou o mesmo disco do sistema). Não pode ser formatado aqui.';

  @override
  String get computerFormatRunning => 'A formatar…';

  @override
  String get computerFormatDone => 'Formatação concluída.';

  @override
  String computerFormatFailed(String error) {
    return 'Formatação falhou: $error';
  }

  @override
  String get computerMounting => 'A ligar…';

  @override
  String get computerMountNoShares =>
      'Nenhuma partilha encontrada. Verifique credenciais, firewall ou SMB.';

  @override
  String get computerMountFailed =>
      'Não foi possível montar a partilha. Tente outras credenciais, instale cifs-utils ou verifique as permissões de montagem.';

  @override
  String get computerMountMissingGio =>
      'mount.cifs não encontrado. Instale cifs-utils. Pode precisar de root ou entradas em /etc/fstab.';

  @override
  String get computerMountNeedPassword =>
      'Esta partilha precisa de utilizador e palavra-passe. Ligue-se de novo e introduza as credenciais.';

  @override
  String get networkRememberPassword =>
      'Memorizar credenciais para este computador (armazenamento seguro)';

  @override
  String get dialogRootPasswordTitle => 'Palavra-passe de administrador';

  @override
  String get dialogRootPasswordLabel => 'Palavra-passe para sudo';

  @override
  String get computerSelectShare => 'Selecionar partilha';

  @override
  String get computerConnect => 'Ligar';

  @override
  String get computerCredentialsTitle => 'Início de sessão de rede';

  @override
  String get computerUsername => 'Utilizador';

  @override
  String get computerPassword => 'Palavra-passe';

  @override
  String get computerDiskProperties => 'Propriedades';

  @override
  String get diskPropsOpenInDisks => 'Abrir em Discos';

  @override
  String get diskPropsFsUnknown => 'Sistema de ficheiros desconhecido';

  @override
  String diskPropsFsLine(String type) {
    return 'Sistema de ficheiros $type';
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
    return 'Livre: $size';
  }

  @override
  String get diskPropsFileAccessRow => 'Acesso a ficheiros';

  @override
  String get snackExternalDropDone => 'Operação nos itens largados concluída.';

  @override
  String get snackDropUnreadable =>
      'Não foi possível ler os ficheiros largados.';

  @override
  String get snackOpenAsRootLaunched =>
      'Janela de administrador iniciada (separada desta).';

  @override
  String computerNetworkIpLine(String ip) {
    return 'IP: $ip';
  }
}
