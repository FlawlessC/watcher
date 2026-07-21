import 'dart:convert';
import '../settings/settings_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:open_file/open_file.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import '../services/user_profile_service.dart';
import '../core/app_globals.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../l10n/l10n_extension.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  String get currentUserId => FirebaseAuth.instance.currentUser?.uid ?? '';
  final TextEditingController ctrl = TextEditingController();
  final TextEditingController catCtrl = TextEditingController();
  final TextEditingController descCtrl = TextEditingController();
  final TextEditingController currentProgCtrl = TextEditingController();
  final TextEditingController totalProgCtrl = TextEditingController();
  String? pendingUpdateUrl;
  String? pendingUpdateChangelog;
  String? pendingUpdateVersion;

  static const MethodChannel _installPermissionChannel = MethodChannel(
    'watcher/install_permission',
  );

  String? pendingInstallPermissionUrl;
  bool waitingInstallPermission = false;
  bool showUpdateBadge = true;
  bool isDownloadingUpdate = false;
  bool isProfileMenuOpen = false;
  bool collectLogs = false;
  bool maintenanceMode = false;
  String maintenanceMessage = '';
  final List<String> appLogs = [];
  bool _blockIfMaintenance() {
    if (!maintenanceMode) return false;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          maintenanceMessage.isEmpty
              ? context.l10n.maintenanceUnavailable
              : maintenanceMessage,
        ),
      ),
    );

    return true;
  }

  String appVersionLabel = '';
  String progressUnit = 'серия';
  String _localizedProgressUnit(String unit) {
    switch (unit) {
      case 'серия':
        return context.l10n.progressUnitEpisode;
      case 'стр':
        return context.l10n.progressUnitPage;
      case 'гл':
        return context.l10n.progressUnitChapter;
      case 'книга':
        return context.l10n.progressUnitBook;
      case 'сезон':
        return context.l10n.progressUnitSeason;
      case 'часов':
        return context.l10n.progressUnitHours;
      case 'ачивок':
        return context.l10n.progressUnitAchievements;
      case '-':
        return context.l10n.progressUnitNone;
      default:
        return unit;
    }
  }

  String _localizedTag(String tag) {
    switch (tag) {
      case 'Прошлое':
        return context.l10n.past;
      case 'Потом':
        return context.l10n.later;
      default:
        return tag;
    }
  }

  // Основной список редактируемой или создаваемой карточки.
  String selectedMainStatus = 'present';

  // Фильтры пользовательских категорий.
  List<String> selectedFilters = ['Все'];
  // Режим массового выбора карточек.
  bool selectionMode = false;

  // ID выбранных карточек.
  final Set<String> selectedItemIds = {};
  // Нужно ли временно показывать скрытые карточки
  // в «Все», «Будущее», «Настоящее» и «Ещё раз».
  bool includePastInMainResults = false;
  bool includeLaterInMainResults = false;
  String get filter =>
      selectedFilters.contains('Все') ? 'Все' : selectedFilters.join(', ');
  String searchQuery = "";
  final Set<String> selected = {};
  Future<bool> _canRequestInstallPackages() async {
    if (kIsWeb) return false;

    try {
      final result = await _installPermissionChannel.invokeMethod<bool>(
        'canRequestInstallPackages',
      );

      return result ?? false;
    } catch (e) {
      if (!mounted) return false;

      addLog(context.l10n.logInstallPermissionCheckError(e.toString()));
      return false;
    }
  }

  Future<void> _openInstallPermissionSettings() async {
    try {
      await _installPermissionChannel.invokeMethod(
        'openInstallPermissionSettings',
      );
    } catch (e) {
      if (!mounted) return;

      addLog(context.l10n.logInstallSettingsOpenError(e.toString()));
    }
  }

  void _showInstallPermissionDialog(String apkUrl) {
    pendingInstallPermissionUrl = apkUrl;
    waitingInstallPermission = true;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(context.l10n.installPermissionTitle),
        content: Text(context.l10n.installPermissionDescription),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(context.l10n.later),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              await _openInstallPermissionSettings();
            },
            child: Text(context.l10n.openSettings),
          ),
        ],
      ),
    );
  }

  void addLog(String message) {
    if (!collectLogs) return;

    final timestamp = DateTime.now().toString().substring(11, 19);

    appLogs.insert(0, "[$timestamp] $message");

    if (appLogs.length > 100) {
      appLogs.removeLast();
    }
  }

  Future<void> checkMaintenanceMode() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('config')
          .doc('app')
          .get();

      if (!doc.exists) return;

      final data = doc.data();

      if (!mounted || data == null) return;

      setState(() {
        maintenanceMode = data['maintenance'] ?? false;
        maintenanceMessage =
            data['message']?.toString() ??
            context.l10n.maintenanceDefaultMessage;
      });
    } catch (e) {
      addLog(context.l10n.logMaintenanceCheckError(e.toString()));
    }
  }

  Future<void> _showWebReleaseNotesOnce() async {
    if (!kIsWeb) return;

    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;

      final preferences = SharedPreferencesAsync();
      const preferenceKey = 'last_seen_web_release_version';

      final lastSeenVersion = await preferences.getString(preferenceKey);

      // Эту версию в данном браузере уже показывали.
      if (lastSeenVersion == currentVersion) {
        return;
      }

      final response = await Dio().get(
        'https://raw.githubusercontent.com/FlawlessC/watcher/main/version.json',
      );

      final data = response.data is String
          ? jsonDecode(response.data)
          : response.data;

      final publishedVersion = data['version']?.toString() ?? '';

      // version.json мог обновиться раньше, чем был задеплоен новый Web.
      // Показываем окно только для реально запущенной версии.
      if (publishedVersion.isEmpty || publishedVersion != currentVersion) {
        return;
      }

      await _showReleaseNotes();

      // Записываем версию только после закрытия окна.
      await preferences.setString(preferenceKey, currentVersion);
    } catch (error, stackTrace) {
      debugPrint('WEB RELEASE NOTES ERROR: $error');
      debugPrint('$stackTrace');
    }
  }

  Future<void> _showReleaseNotes() async {
    try {
      final response = await Dio().get(
        'https://raw.githubusercontent.com/FlawlessC/watcher/main/version.json',
      );

      final data = response.data is String
          ? jsonDecode(response.data)
          : response.data;

      final version = data['version']?.toString() ?? '';
      final changelog = data['changelog']?.toString() ?? '';

      if (!mounted) return;

      await showDialog<void>(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            title: Text(
              version.isEmpty
                  ? context.l10n.whatsNew
                  : context.l10n.whatsNewInVersion(version),
            ),
            content: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 650, maxHeight: 500),
              child: SizedBox(
                width: 650,
                child: Scrollbar(
                  thumbVisibility: true,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(right: 12),
                    child: SelectableText(
                      changelog.isEmpty
                          ? context.l10n.releaseInfoUnavailable
                          : changelog
                                .replaceAll('**New:**', '• ')
                                .replaceAll('**Improved:**', '• ')
                                .replaceAll('**Fixed:**', '• '),
                      style: Theme.of(dialogContext).textTheme.bodyMedium,
                    ),
                  ),
                ),
              ),
            ),
            actions: [
              FilledButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: Text(context.l10n.close),
              ),
            ],
          );
        },
      );
    } catch (error, stackTrace) {
      debugPrint('RELEASE NOTES ERROR: $error');
      debugPrint('$stackTrace');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.releaseInfoLoadError)),
      );
    }
  }

  Future<void> checkForUpdate({bool manual = false}) async {
    if (kIsWeb) {
      if (manual && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.apkUpdatesAndroidOnly)),
        );
      }
      return;
    }

    final packageInfo = await PackageInfo.fromPlatform();
    final currentBuild = int.parse(packageInfo.buildNumber);

    try {
      final response = await Dio().get(
        'https://raw.githubusercontent.com/FlawlessC/watcher/main/version.json',
      );

      final data = response.data is String
          ? jsonDecode(response.data)
          : response.data;

      debugPrint("UPDATE CHECK DATA: $data");

      final latestBuild = data['build'] as int;
      final apkUrl = data['apk_url'] as String;
      final changelog = data['changelog'] as String;
      final latestVersion = data['version'] as String;

      if (latestBuild > currentBuild) {
        setState(() {
          pendingUpdateUrl = apkUrl;
          pendingUpdateChangelog = changelog;
          pendingUpdateVersion = latestVersion;
        });

        showUpdateDialog(apkUrl, changelog);
      } else if (manual && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.latestVersionInstalled)),
        );
      }
    } catch (e) {
      debugPrint("UPDATE CHECK ERROR: $e");
    }
  }

  Future<void> _loadAppVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();

    if (!mounted) return;

    setState(() {
      appVersionLabel = '${packageInfo.version}+${packageInfo.buildNumber}';
    });
  }

  Future<void> downloadAndInstall(String url) async {
    final downloadStartedLog = context.l10n.logApkDownloadStarted;
    final downloadedLog = context.l10n.logApkDownloaded;

    try {
      debugPrint("DOWNLOAD APK START: $url");
      addLog(downloadStartedLog);

      final dir = await getApplicationDocumentsDirectory();
      final filePath = "${dir.path}/update.apk";

      await Dio().download(url, filePath);

      debugPrint("DOWNLOAD APK FINISHED: $filePath");
      addLog(downloadedLog);

      final result = await OpenFile.open(
        filePath,
        type: "application/vnd.android.package-archive",
      );

      debugPrint("OPEN APK RESULT: ${result.type}");
      debugPrint("OPEN APK MESSAGE: ${result.message}");

      if (result.type != ResultType.done) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.apkInstallerOpenError(result.message)),
          ),
        );
      }
    } catch (e, stack) {
      debugPrint("DOWNLOAD APK ERROR: $e");
      debugPrint("$stack");

      if (!mounted) return;

      addLog(context.l10n.logApkUpdateError(e.toString()));

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.updateError(e.toString()))),
      );
    }
  }

  void showUpdateDialog(String apkUrl, String changelog) {
    bool downloading = false;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            final screenHeight = MediaQuery.sizeOf(dialogContext).height;

            return AlertDialog(
              insetPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 24,
              ),
              title: Text(
                pendingUpdateVersion == null
                    ? context.l10n.updateAvailable
                    : context.l10n.updateAvailableVersion(
                        pendingUpdateVersion!,
                      ),
              ),
              content: SizedBox(
                width: double.maxFinite,
                height: screenHeight * 0.55,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Scrollbar(
                        thumbVisibility: true,
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.only(right: 12),
                          child: Text(
                            changelog,
                            style: Theme.of(dialogContext).textTheme.bodyLarge,
                          ),
                        ),
                      ),
                    ),
                    if (downloading) ...[
                      const SizedBox(height: 16),
                      const LinearProgressIndicator(),
                      const SizedBox(height: 8),
                      Text(context.l10n.downloadingApk),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: downloading
                      ? null
                      : () => Navigator.pop(dialogContext),
                  child: Text(context.l10n.later),
                ),
                FilledButton(
                  onPressed: downloading
                      ? null
                      : () async {
                          final canInstall = await _canRequestInstallPackages();

                          if (!canInstall) {
                            if (dialogContext.mounted) {
                              Navigator.pop(dialogContext);
                            }

                            if (!mounted) return;
                            _showInstallPermissionDialog(apkUrl);
                            return;
                          }

                          setDialogState(() {
                            downloading = true;
                          });

                          if (mounted) {
                            setState(() {
                              isDownloadingUpdate = true;
                            });
                          }

                          await downloadAndInstall(apkUrl);

                          if (!mounted) return;

                          setState(() {
                            isDownloadingUpdate = false;
                          });

                          if (dialogContext.mounted) {
                            setDialogState(() {
                              downloading = false;
                            });
                          }
                        },
                  child: Text(context.l10n.update),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _showLanguageDialog() async {
    final currentLanguageCode = localeController.selectedLanguageCode;

    final selectedLanguageCode = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        var temporaryLanguageCode = currentLanguageCode;

        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return AlertDialog(
              title: Text(context.l10n.language),
              content: RadioGroup<String>(
                groupValue: temporaryLanguageCode,
                onChanged: (value) {
                  if (value == null) return;

                  setDialogState(() {
                    temporaryLanguageCode = value;
                  });
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    RadioListTile<String>(
                      value: 'system',
                      title: Text(context.l10n.languageSystem),
                    ),
                    RadioListTile<String>(
                      value: 'ru',
                      title: Text(context.l10n.languageRussian),
                    ),
                    RadioListTile<String>(
                      value: 'en',
                      title: Text(context.l10n.languageEnglish),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: Text(context.l10n.cancel),
                ),
                FilledButton(
                  onPressed: () {
                    Navigator.pop(dialogContext, temporaryLanguageCode);
                  },
                  child: Text(context.l10n.save),
                ),
              ],
            );
          },
        );
      },
    );

    if (selectedLanguageCode == null) return;

    await localeController.setLanguageCode(selectedLanguageCode);
  }

  Future<void> _confirmLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(context.l10n.logoutTitle),
        content: Text(context.l10n.logoutDescription),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(context.l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(context.l10n.logout),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await FirebaseAuth.instance.signOut();
    }
  }

  void _openSettingsScreen({String initialSection = 'main'}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SettingsScreen(
          currentVersion: appVersionLabel,
          updateAvailable: pendingUpdateUrl != null,
          availableVersion: pendingUpdateVersion,
          onCheckForUpdate: () => checkForUpdate(manual: true),
          onShowReleaseNotes: _showReleaseNotes,
          initialSection: initialSection,
          collectLogs: collectLogs,
          appLogs: appLogs,
          onCollectLogsChanged: (value) {
            setState(() => collectLogs = value);
          },
          onClearLogs: () {
            setState(() => appLogs.clear());
          },
          showUpdateBadge: showUpdateBadge,
          onShowUpdateBadgeChanged: (value) {
            setState(() => showUpdateBadge = value);
          },
        ),
      ),
    );
  }

  Future<void> _handleWebRedirectResult() async {
    if (!kIsWeb) return;

    final result = await FirebaseAuth.instance.getRedirectResult();

    if (result.user != null) {
      debugPrint("Web login success: ${result.user!.email}");
    }
  }

  @override
  void initState() {
    super.initState();

    _handleWebRedirectResult();

    _loadAppVersion();

    checkMaintenanceMode();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (kIsWeb) {
        await _showWebReleaseNotesOnce();
      } else {
        await checkForUpdate();
      }
    });
  }

  void _showAddCategoryDialog() {
    if (_blockIfMaintenance()) return;
    // Локальный контроллер, не пересекается с полем класса
    final TextEditingController newCatCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.l10n.newList),
        content: TextField(
          controller: newCatCtrl,
          decoration: InputDecoration(hintText: context.l10n.listNameHint),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(context.l10n.cancel),
          ),
          FilledButton(
            onPressed: () async {
              if (newCatCtrl.text.isNotEmpty) {
                HapticFeedback.selectionClick();
                // Получаем текущее кол-во категорий для индекса
                var snap = await FirebaseFirestore.instance
                    .collection('categories')
                    .where('userId', isEqualTo: currentUserId)
                    .get();
                HapticFeedback.selectionClick();
                await FirebaseFirestore.instance.collection('categories').add({
                  'name': newCatCtrl.text.trim(),
                  'index': snap.docs.length,
                  'userId': currentUserId,
                });

                if (ctx.mounted) Navigator.pop(ctx);
              }
            },
            child: Text(context.l10n.create),
          ),
        ],
      ),
    );
  }

  // Метод для удаления категории
  Future<void> _deleteCategory(String id, String categoryName) async {
    if (_blockIfMaintenance()) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(context.l10n.deleteListTitle),
        content: Text(context.l10n.deleteListDescription),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(context.l10n.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(context.l10n.deleteSelected),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final firestore = FirebaseFirestore.instance;

      final itemsSnapshot = await firestore
          .collection('items')
          .where('userId', isEqualTo: currentUserId)
          .where('tags', arrayContains: categoryName)
          .get();

      final batch = firestore.batch();

      for (final itemDocument in itemsSnapshot.docs) {
        batch.update(itemDocument.reference, {
          'tags': FieldValue.arrayRemove([categoryName]),
        });
      }

      batch.delete(firestore.collection('categories').doc(id));

      await batch.commit();

      if (!mounted) return;

      setState(() {
        selectedFilters.remove(categoryName);

        if (selectedFilters.isEmpty) {
          selectedFilters = ['Все'];
        }
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.categoryDeleted)));
    } catch (error, stackTrace) {
      debugPrint('DELETE CATEGORY ERROR: $error');
      debugPrint('$stackTrace');

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.categoryDeleteError)));
    }
  }

  String _resolveMainStatus(Map<String, dynamic> data) {
    final savedStatus = data['status']?.toString();

    if (savedStatus == 'future' ||
        savedStatus == 'present' ||
        savedStatus == 'again') {
      return savedStatus!;
    }

    final tags = List<String>.from(data['tags'] ?? const []);

    // Совместимость со старой моделью.
    if (tags.contains('Пересмотреть')) {
      return 'again';
    }

    return 'present';
  }

  bool _hasPastTag(Map<String, dynamic> data) {
    final tags = List<String>.from(data['tags'] ?? const []);

    // done и «Архив» оставлены как поддержка старых карточек.
    return data['done'] == true ||
        tags.contains('Архив') ||
        tags.contains('Прошлое');
  }

  bool _hasLaterTag(Map<String, dynamic> data) {
    final tags = List<String>.from(data['tags'] ?? const []);

    // «Отложено» — поддержка данных предыдущей модели.
    return tags.contains('Отложено') || tags.contains('Потом');
  }

  bool _matchesStatusFilter(Map<String, dynamic> data, String requestedStatus) {
    final mainStatus = _resolveMainStatus(data);
    final isPast = _hasPastTag(data);
    final isLater = _hasLaterTag(data);
    // Вкладка «Все» всегда содержит абсолютно все пункты.
    // Фильтры «Показывать прошлое/потом» влияют только
    // на основные списки: Будущее, Настоящее и Ещё раз.
    if (requestedStatus == 'all') {
      return true;
    }
    if (requestedStatus == 'past') {
      return isPast;
    }

    if (requestedStatus == 'later') {
      return isLater;
    }

    // По умолчанию карточки «Прошлое» и «Потом»
    // скрыты из основных списков.
    final serviceTagAllowed =
        (!isPast && !isLater) ||
        (isPast && includePastInMainResults) ||
        (isLater && includeLaterInMainResults);

    if (!serviceTagAllowed) {
      return false;
    }

    switch (requestedStatus) {
      case 'future':
        return mainStatus == 'future';
      case 'present':
        return mainStatus == 'present';
      case 'again':
        return mainStatus == 'again';
      default:
        return false;
    }
  }

  void _editItem(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    // Заполняем контроллеры данными из документа
    ctrl.text = data['t'] ?? '';
    descCtrl.text = data['desc'] ?? '';
    currentProgCtrl.text = data['cur']?.toString() ?? '0';
    totalProgCtrl.text = data['total']?.toString() ?? '0';
    progressUnit = data['unit'] ?? 'серия';

    // ВАЖНО: если done == true, добавляем "Архив" в выбранные теги для отображения
    selected.clear();

    final existingTags = List<String>.from(data['tags'] ?? const []);

    selectedMainStatus = _resolveMainStatus(data);

    // Убираем служебные значения старой модели.
    existingTags.removeWhere(
      (tag) => const [
        'В работе',
        'Пересмотреть',
        'Архив',
        'Отложено',
        'Прошлое',
        'Потом',
      ].contains(tag),
    );

    // Оставляем только пользовательские категории.
    selected.addAll(existingTags);

    // Переводим старые данные в новую модель интерфейса.
    if (_hasPastTag(data)) {
      selected.add('Прошлое');
    }

    if (_hasLaterTag(data)) {
      selected.add('Потом');
    }

    showModalBottomSheet(
      context: context,

      isScrollControlled: true,
      useSafeArea: true,

      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setSheetState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  context.l10n.editItem,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: ctrl,
                  decoration: InputDecoration(
                    labelText: context.l10n.title,
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: descCtrl,
                  decoration: InputDecoration(
                    labelText: context.l10n.description,
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: currentProgCtrl,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: context.l10n.currentProgress,
                          border: const OutlineInputBorder(),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(context.l10n.progressOf),
                    ),
                    Expanded(
                      child: TextField(
                        controller: totalProgCtrl,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: context.l10n.totalProgress,
                          border: const OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    DropdownButton<String>(
                      value: progressUnit,
                      onChanged: (val) =>
                          setSheetState(() => progressUnit = val!),
                      items:
                          ['серия', 'стр', 'гл', 'книга', 'сезон', 'часов', '-']
                              .map(
                                (v) => DropdownMenuItem(
                                  value: v,
                                  child: Text(_localizedProgressUnit(v)),
                                ),
                              )
                              .toList(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildTagsSelectorForSheet(setSheetState),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () {
                      _updateItem(doc);
                      Navigator.pop(ctx);
                    },
                    child: Text(context.l10n.save),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // НОВЫЙ метод для обновления существующей записи
  void _updateItem(DocumentSnapshot doc) {
    if (_blockIfMaintenance()) return;
    if (ctrl.text.trim().isEmpty) return;

    final tagsToSave = List<String>.from(selected);

    doc.reference.update({
      't': ctrl.text.trim(),
      'desc': descCtrl.text.trim(),
      'cur': currentProgCtrl.text,
      'total': totalProgCtrl.text,
      'unit': progressUnit,
      'status': selectedMainStatus,
      'tags': tagsToSave,

      // Старое поле пока сохраняем, но больше не используем
      // как основную модель статуса.
      'done': tagsToSave.contains('Прошлое'),
    });

    ctrl.clear();
    descCtrl.clear();
    currentProgCtrl.clear();
    totalProgCtrl.clear();
    selected.clear();
    selectedMainStatus = 'present';
  }

  void _toggleSelection(String documentId) {
    setState(() {
      selectionMode = true;

      if (selectedItemIds.contains(documentId)) {
        selectedItemIds.remove(documentId);
      } else {
        selectedItemIds.add(documentId);
      }

      if (selectedItemIds.isEmpty) {
        selectionMode = false;
      }
    });
  }

  Future<void> _toggleSelectedServiceTag(String serviceTag) async {
    if (_blockIfMaintenance()) return;
    if (selectedItemIds.isEmpty) return;

    try {
      final firestore = FirebaseFirestore.instance;

      final selectedDocuments = await Future.wait(
        selectedItemIds.map(
          (documentId) => firestore.collection('items').doc(documentId).get(),
        ),
      );

      final existingDocuments = selectedDocuments
          .where((document) => document.exists && document.data() != null)
          .toList();

      if (existingDocuments.isEmpty) {
        _clearSelection();
        return;
      }

      bool hasServiceTag(Map<String, dynamic> data) {
        final tags = List<String>.from(data['tags'] ?? const []);

        if (serviceTag == 'Прошлое') {
          return data['done'] == true ||
              tags.contains('Прошлое') ||
              tags.contains('Архив');
        }

        return tags.contains('Потом') || tags.contains('Отложено');
      }

      final shouldRemove = existingDocuments.every(
        (document) => hasServiceTag(document.data()!),
      );

      final batch = firestore.batch();

      for (final document in existingDocuments) {
        final data = document.data()!;
        final tags = List<String>.from(data['tags'] ?? const []);

        // Чистим обе версии старых и новых служебных тегов.
        tags.remove('Прошлое');
        tags.remove('Потом');
        tags.remove('Архив');
        tags.remove('Отложено');

        if (!shouldRemove) {
          tags.add(serviceTag);
        }

        batch.update(document.reference, {
          'tags': tags,

          // done пока сохраняем для совместимости со старыми версиями.
          'done': !shouldRemove && serviceTag == 'Прошлое',
        });
      }

      await batch.commit();

      if (!mounted) return;

      _clearSelection();

      final actionText = shouldRemove
          ? context.l10n.bulkTagRemoved(serviceTag)
          : context.l10n.bulkItemsMoved(serviceTag);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(actionText)));
    } catch (error, stackTrace) {
      debugPrint('BULK SERVICE TAG ERROR: $error');
      debugPrint('$stackTrace');

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.bulkChangeError)));
    }
  }

  Future<void> _deleteSelectedItems() async {
    if (_blockIfMaintenance()) return;
    if (selectedItemIds.isEmpty) return;

    final count = selectedItemIds.length;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(context.l10n.deleteSelectedItemsTitle),
        content: Text(context.l10n.deleteSelectedItemsDescription(count)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(context.l10n.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(context.l10n.delete),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final firestore = FirebaseFirestore.instance;
      final batch = firestore.batch();

      for (final documentId in selectedItemIds) {
        batch.delete(firestore.collection('items').doc(documentId));
      }

      await batch.commit();

      if (!mounted) return;

      _clearSelection();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.deletedItemsCount(count))),
      );
    } catch (error, stackTrace) {
      debugPrint('BULK DELETE ERROR: $error');
      debugPrint('$stackTrace');

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.bulkDeleteError)));
    }
  }

  void _clearSelection() {
    setState(() {
      selectionMode = false;
      selectedItemIds.clear();
    });
  }

  // 1. Метод добавления в базу
  void _add() {
    if (_blockIfMaintenance()) return;
    if (ctrl.text.trim().isEmpty) return;

    final tagsToSave = List<String>.from(selected);

    FirebaseFirestore.instance.collection('items').add({
      't': ctrl.text.trim(),
      'desc': descCtrl.text.trim(),
      'cur': currentProgCtrl.text,
      'total': totalProgCtrl.text,
      'unit': progressUnit,
      'status': selectedMainStatus,
      'tags': tagsToSave,
      'done': tagsToSave.contains('Прошлое'),
      'time': DateTime.now().millisecondsSinceEpoch,
      'userId': currentUserId,
    });

    ctrl.clear();
    descCtrl.clear();
    currentProgCtrl.clear();
    totalProgCtrl.clear();
    selected.clear();
    selectedMainStatus = 'present';
  }

  // 2. Окно добавления (выезжает снизу)
  void _showAddItemSheet() {
    if (_blockIfMaintenance()) return;

    ctrl.clear();
    descCtrl.clear();
    currentProgCtrl.clear();
    totalProgCtrl.clear();
    selected.clear();
    selectedMainStatus = 'present';
    progressUnit = 'серия'; // сброс единиц на дефолт
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setSheetState) => Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,

            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                Text(
                  context.l10n.addItem,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: ctrl,
                  decoration: InputDecoration(
                    labelText: context.l10n.title,
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: descCtrl,
                  decoration: InputDecoration(
                    labelText: context.l10n.description,
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: currentProgCtrl,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: context.l10n.currentProgress,
                          border: const OutlineInputBorder(),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(context.l10n.progressOf),
                    ),
                    Expanded(
                      child: TextField(
                        controller: totalProgCtrl,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: context.l10n.totalProgress,
                          border: const OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Возвращаем выбор единиц:
                    DropdownButton<String>(
                      value: progressUnit,
                      onChanged: (val) =>
                          setSheetState(() => progressUnit = val!),
                      items:
                          [
                                'серия',
                                'стр',
                                'гл',
                                'книга',
                                'сезон',
                                'часов',
                                '-',
                                'ачивок',
                              ]
                              .map(
                                (v) => DropdownMenuItem(
                                  value: v,
                                  child: Text(_localizedProgressUnit(v)),
                                ),
                              )
                              .toList(),
                    ),
                  ],
                ),

                const SizedBox(height: 16),
                _buildTagsSelectorForSheet(
                  setSheetState,
                ), // Выбор тегов внутри окна
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () {
                      _add();
                      Navigator.pop(ctx);
                    },
                    child: Text(context.l10n.addToList),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Вспомогательный метод для выбора тегов в окне добавления
  Widget _buildTagsSelectorForSheet(StateSetter setSheetState) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('categories')
          .where('userId', isEqualTo: currentUserId)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox();
        }

        final categories = snapshot.data!.docs
            .map((document) => document['name'] as String)
            .toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.l10n.mainList,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ChoiceChip(
                  label: Text(context.l10n.future),
                  selected: selectedMainStatus == 'future',
                  onSelected: (_) {
                    setSheetState(() {
                      selectedMainStatus = 'future';
                    });
                  },
                ),
                ChoiceChip(
                  label: Text(context.l10n.present),
                  selected: selectedMainStatus == 'present',
                  onSelected: (_) {
                    setSheetState(() {
                      selectedMainStatus = 'present';
                    });
                  },
                ),
                ChoiceChip(
                  label: Text(context.l10n.again),
                  selected: selectedMainStatus == 'again',
                  onSelected: (_) {
                    setSheetState(() {
                      selectedMainStatus = 'again';
                    });
                  },
                ),
              ],
            ),

            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(),
            ),

            Text(
              context.l10n.hideIn,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilterChip(
                  label: Text(context.l10n.past),
                  selected: selected.contains('Прошлое'),
                  showCheckmark: true,
                  onSelected: (value) {
                    setSheetState(() {
                      if (value) {
                        selected.remove('Потом');
                        selected.add('Прошлое');
                      } else {
                        selected.remove('Прошлое');
                      }
                    });
                  },
                ),
                FilterChip(
                  label: Text(context.l10n.later),
                  selected: selected.contains('Потом'),
                  showCheckmark: true,
                  onSelected: (value) {
                    setSheetState(() {
                      if (value) {
                        selected.remove('Прошлое');
                        selected.add('Потом');
                      } else {
                        selected.remove('Потом');
                      }
                    });
                  },
                ),
              ],
            ),

            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(),
            ),

            Text(
              context.l10n.categories,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),

            if (categories.isEmpty)
              Text(context.l10n.noCategoriesHint)
            else
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 220),
                child: SingleChildScrollView(
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: categories
                        .map((category) => _buildChip(category, setSheetState))
                        .toList(),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  // Вспомогательный метод для красивой кнопки-тега
  Widget _buildChip(String cat, StateSetter setSheetState) {
    final isSel = selected.contains(cat);

    return FilterChip(
      label: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: Text(cat, style: const TextStyle(fontSize: 13)),
      ),

      selected: isSel,

      showCheckmark: false,

      materialTapTargetSize: MaterialTapTargetSize.padded,

      onSelected: (val) => setSheetState(() {
        if (val) {
          selected.add(cat);
        } else {
          selected.remove(cat);
        }
      }),
    );
  }

  bool _isSelected(String id) {
    return selectedItemIds.contains(id);
  }

  // 3. Основной метод списка (с 4 вкладками)
  Widget _buildItemList({required String status}) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('items')
          .where('userId', isEqualTo: currentUserId)
          .orderBy('time', descending: true)
          .snapshots(),
      builder: (context, snap) {
        if (!snap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        var docs = snap.data!.docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final String title = (data['t'] ?? '').toString().toLowerCase();
          List tags = data['tags'] ?? [];

          final matchesStatus = _matchesStatusFilter(data, status);

          bool matchesCategory =
              selectedFilters.contains('Все') ||
              tags.any((tag) => selectedFilters.contains(tag));
          bool matchesSearch = title.contains(searchQuery);

          return matchesStatus && matchesCategory && matchesSearch;
        }).toList();
        if (status == 'all') {
          docs.sort((first, second) {
            final firstData = first.data() as Map<String, dynamic>;
            final secondData = second.data() as Map<String, dynamic>;

            final firstIsPast = _hasPastTag(firstData);
            final secondIsPast = _hasPastTag(secondData);

            // Обычные карточки выше, прошлое — ниже.
            if (firstIsPast != secondIsPast) {
              return firstIsPast ? 1 : -1;
            }

            // Внутри каждой группы сохраняем порядок:
            // самые новые сверху.
            final firstTime = firstData['time'] is int
                ? firstData['time'] as int
                : 0;
            final secondTime = secondData['time'] is int
                ? secondData['time'] as int
                : 0;

            return secondTime.compareTo(firstTime);
          });
        }
        if (docs.isEmpty) {
          return Center(child: Text(context.l10n.nothingFound));
        }

        return ListView.builder(
          itemCount: docs.length,
          itemBuilder: (context, i) => _buildTaskCard(docs[i]),
        );
      },
    );
  }

  // Карточка задачи
  Widget _buildTaskCard(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    List tags = List.from(data['tags'] ?? []);

    final bool isSelected = _isSelected(doc.id);

    return Dismissible(
      key: Key(doc.id),
      direction: selectionMode
          ? DismissDirection.none
          : DismissDirection.horizontal,
      background: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.only(left: 20),
        alignment: Alignment.centerLeft,
        decoration: BoxDecoration(
          color: Colors.orange,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.archive, color: Colors.white),
      ),

      secondaryBackground: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.only(right: 20),
        alignment: Alignment.centerRight,
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),

      confirmDismiss: (direction) async {
        // Свайп справа налево = удалить
        if (_blockIfMaintenance()) return false;
        if (direction == DismissDirection.endToStart) {
          HapticFeedback.mediumImpact();

          await doc.reference.delete();

          return true;
        }
        // Свайп слева направо = архив
        else {
          List<String> updatedTags = List.from(tags);

          if (!updatedTags.contains('Архив')) {
            updatedTags.add('Архив');
          }
          await doc.reference.update({'done': true, 'tags': updatedTags});

          return false;
        }
      },

      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        color: isSelected
            ? Theme.of(context).colorScheme.primaryContainer
            : null,
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),

          leading: Checkbox(
            value: isSelected,
            onChanged: (_) {
              HapticFeedback.lightImpact();
              _toggleSelection(doc.id);
            },
          ),

          title: Text(
            data['t'] ?? '',

            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              decoration: _hasPastTag(data) ? TextDecoration.lineThrough : null,
            ),
          ),

          subtitle: Padding(
            padding: const EdgeInsets.only(top: 6),

            child: Text(
              '${context.l10n.itemProgress((data['cur'] ?? 0).toString(), (data['total'] ?? 0).toString(), _localizedProgressUnit((data['unit'] ?? '').toString()))}\n${tags.map((tag) => _localizedTag(tag.toString())).join(", ")}',
            ),
          ),

          onTap: selectionMode ? () => _toggleSelection(doc.id) : null,

          onLongPress: selectionMode
              ? () => _toggleSelection(doc.id)
              : () => _editItem(doc),

          trailing: IconButton(
            icon: const Icon(Icons.delete_outline),

            onPressed: () async {
              HapticFeedback.mediumImpact();
              if (_blockIfMaintenance()) return;
              await doc.reference.delete();
            },
          ),
        ),
      ),
    );
  }

  // Пустые заглушки для методов, которые у тебя уже были (проверь их наличие выше в коде или добавь)
  void _showRandomItem(String currentStatus) async {
    // 1. Получаем все данные из Firebase
    HapticFeedback.selectionClick();
    var snap = await FirebaseFirestore.instance
        .collection('items')
        .where('userId', isEqualTo: currentUserId)
        .get();

    if (!mounted) return;

    // 2. Фильтруем список по тем же правилам, что и основной экран
    var filteredDocs = snap.docs.where((doc) {
      final data = doc.data();
      final List tags = data['tags'] ?? [];

      // А) Проверка вкладки (статуса)
      final matchesStatus = _matchesStatusFilter(data, currentStatus);

      // Б) Проверка МНОЖЕСТВЕННЫХ фильтров (Твои книги, сериалы и т.д.)
      // Если выбрано "Все", подходит любая карточка.
      // Иначе проверяем, есть ли у карточки ХОТЯ БЫ ОДИН из выбранных тегов.
      bool matchesCategory =
          selectedFilters.contains('Все') ||
          tags.any((tag) => selectedFilters.contains(tag));

      // В) Проверка поиска (если введено что-то в строку поиска)
      final String title = (data['t'] ?? '').toString().toLowerCase();
      bool matchesSearch = title.contains(searchQuery.toLowerCase());

      return matchesStatus && matchesCategory && matchesSearch;
    }).toList();

    // 3. Если после всех фильтров список пуст
    if (filteredDocs.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.randomListEmpty)));
      return;
    }

    // 4. Выбираем рандом из того, что реально видишь на экране
    var randomDoc = (filteredDocs..shuffle()).first;

    // 5. Показываем результат (с защитой от отсутствия описания desc)
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.l10n.randomChoice),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(context.l10n.howAboutThis),
            const SizedBox(height: 10),
            Text(
              randomDoc.get('t') ?? context.l10n.untitled,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Builder(
              builder: (context) {
                final data = randomDoc.data();
                if (data.containsKey('desc') &&
                    data['desc'].toString().isNotEmpty) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      '${data['desc']}',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(context.l10n.close),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              _showRandomItem(currentStatus);
            },
            child: Text(context.l10n.another),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: StreamBuilder<QuerySnapshot>(
        // Используем простой стрим без orderBy, чтобы увидеть старые данные
        stream: FirebaseFirestore.instance
            .collection('categories')
            .where('userId', isEqualTo: currentUserId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                context.l10n.errorWithDetails(snapshot.error.toString()),
              ),
            );
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          var docs = snapshot.data!.docs;

          // Сортируем в памяти для стабильности
          docs.sort((a, b) {
            int aIdx = (a.data() as Map).containsKey('index') ? a['index'] : 0;
            int bIdx = (b.data() as Map).containsKey('index') ? b['index'] : 0;
            return aIdx.compareTo(bIdx);
          });

          return Column(
            children: [
              Container(
                width: double.infinity,
                height: 120,
                color: Colors.deepPurple,
                padding: const EdgeInsets.all(20),
                alignment: Alignment.bottomLeft,
                child: Text(
                  context.l10n.myLists,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const Divider(),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      context.l10n.categories.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.add_box_outlined,
                        color: Colors.deepPurple,
                      ),
                      onPressed: _showAddCategoryDialog,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: docs.isEmpty
                    ? Center(child: Text(context.l10n.noCategories))
                    : ReorderableListView(
                        onReorder: (oldIdx, newIdx) async {
                          if (_blockIfMaintenance()) return;

                          if (newIdx > oldIdx) newIdx -= 1;
                          final List<DocumentSnapshot> list = List.from(docs);
                          final item = list.removeAt(oldIdx);
                          list.insert(newIdx, item);
                          final batch = FirebaseFirestore.instance.batch();
                          for (int i = 0; i < list.length; i++) {
                            batch.update(list[i].reference, {'index': i});
                          }
                          await batch.commit();
                        },
                        children: [
                          for (var doc in docs)
                            ReorderableDelayedDragStartListener(
                              // Обертка для управления перетаскиванием
                              key: ValueKey(doc.id),
                              index: docs.indexOf(doc),
                              child: ListTile(
                                title: Text(doc['name'] ?? ''),
                                selected: selectedFilters.contains(doc['name']),

                                // Долгое нажатие теперь четко открывает редактирование
                                onLongPress: () => _editCategoryName(doc),

                                onTap: () {
                                  setState(
                                    () => selectedFilters = [
                                      doc['name'] as String,
                                    ],
                                  );
                                  Navigator.pop(context);
                                },

                                // Иконка перетаскивания
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete_outline,
                                        size: 18,
                                        color: Colors.redAccent,
                                      ),
                                      onPressed: () => _deleteCategory(
                                        doc.id,
                                        doc['name'] as String,
                                      ),
                                    ),
                                    // Сама "ручка" для перетаскивания
                                    const Icon(
                                      Icons.drag_handle,
                                      color: Colors.grey,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
              ),

              // Внутри _buildDrawer -> Column -> children:
            ],
          );
        },
      ),
    );
  }

  void _editCategoryName(DocumentSnapshot doc) {
    final String oldName = doc['name'];
    final TextEditingController editCtrl = TextEditingController(text: oldName);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.l10n.editList),
        content: TextField(
          controller: editCtrl,
          decoration: InputDecoration(hintText: context.l10n.newName),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(context.l10n.cancel),
          ),
          FilledButton(
            onPressed: () async {
              String newName = editCtrl.text.trim();
              if (newName.isNotEmpty && newName != oldName) {
                // 1. Обновляем саму категорию
                if (_blockIfMaintenance()) return;

                await doc.reference.update({'name': newName});
                HapticFeedback.selectionClick();
                // 2. Обновляем все задачи, у которых был этот тег
                var itemsSnap = await FirebaseFirestore.instance
                    .collection('items')
                    .where('tags', arrayContains: oldName)
                    .get();

                WriteBatch batch = FirebaseFirestore.instance.batch();
                for (var itemDoc in itemsSnap.docs) {
                  List tags = List.from(itemDoc['tags']);
                  int index = tags.indexOf(oldName);
                  if (index != -1) {
                    tags[index] = newName;
                    batch.update(itemDoc.reference, {'tags': tags});
                  }
                }
                await batch.commit();

                // 3. Обновляем текущий фильтр на экране
                if (selectedFilters.contains(oldName)) {
                  setState(() {
                    // Находим индекс старого имени в списке и заменяем на новое
                    int idx = selectedFilters.indexOf(oldName);
                    selectedFilters[idx] = newName;
                  });
                }

                // Исправляем ошибку с фигурными скобками (curly_braces)
                if (ctx.mounted) {
                  Navigator.pop(ctx);
                }
              }
            },

            child: Text(context.l10n.save),
          ),
        ],
      ),
    );
  }

  void _selectAllFilters() {
    setState(() {
      selectedFilters = ['Все'];
    });
  }

  void _toggleCategoryFilter(String category, bool selected) {
    setState(() {
      if (selected) {
        selectedFilters.remove('Все');

        if (!selectedFilters.contains(category)) {
          selectedFilters.add(category);
        }
      } else {
        selectedFilters.remove(category);

        if (selectedFilters.isEmpty) {
          selectedFilters = ['Все'];
        }
      }
    });
  }

  String _selectedFiltersLabel() {
    if (selectedFilters.contains('Все')) {
      return context.l10n.all;
    }

    if (selectedFilters.length == 1) {
      return selectedFilters.first;
    }

    return context.l10n.selectedCount(selectedFilters.length);
  }

  Future<void> _showFiltersSheet(List<String> categories) async {
    final temporaryFilters = <String>{...selectedFilters};

    var temporaryIncludePast = includePastInMainResults;
    var temporaryIncludeLater = includeLaterInMainResults;

    await showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (sheetContext, setSheetState) {
            final allSelected = temporaryFilters.contains('Все');

            void selectAll() {
              setSheetState(() {
                temporaryFilters
                  ..clear()
                  ..add('Все');
              });
            }

            void toggleCategory(String category, bool selected) {
              setSheetState(() {
                if (selected) {
                  temporaryFilters.remove('Все');
                  temporaryFilters.add(category);
                } else {
                  temporaryFilters.remove(category);

                  if (temporaryFilters.isEmpty) {
                    temporaryFilters.add('Все');
                  }
                }
              });
            }

            return Padding(
              padding: EdgeInsets.fromLTRB(
                20,
                4,
                20,
                MediaQuery.viewInsetsOf(sheetContext).bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    context.l10n.filters,
                    style: Theme.of(sheetContext).textTheme.titleLarge
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    context.l10n.filtersDescription,
                    style: Theme.of(sheetContext).textTheme.bodyMedium
                        ?.copyWith(
                          color: Theme.of(
                            sheetContext,
                          ).colorScheme.onSurfaceVariant,
                        ),
                  ),
                  const SizedBox(height: 20),
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(context.l10n.showPast),
                    subtitle: Text(context.l10n.showPastDescription),
                    value: temporaryIncludePast,
                    onChanged: (value) {
                      setSheetState(() {
                        temporaryIncludePast = value ?? false;
                      });
                    },
                  ),

                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(context.l10n.showLater),
                    subtitle: Text(context.l10n.showLaterDescription),
                    value: temporaryIncludeLater,
                    onChanged: (value) {
                      setSheetState(() {
                        temporaryIncludeLater = value ?? false;
                      });
                    },
                  ),

                  const Divider(height: 28),
                  FilterChip(
                    label: Text(context.l10n.all),
                    selected: allSelected,
                    showCheckmark: true,
                    onSelected: (_) => selectAll(),
                  ),

                  const SizedBox(height: 12),

                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.sizeOf(sheetContext).height * 0.45,
                    ),
                    child: SingleChildScrollView(
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final category in categories)
                            FilterChip(
                              label: Text(category),
                              selected: temporaryFilters.contains(category),
                              showCheckmark: true,
                              onSelected: (value) {
                                toggleCategory(category, value);
                              },
                            ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: selectAll,
                          child: Text(context.l10n.reset),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton(
                          onPressed: () {
                            setState(() {
                              selectedFilters = temporaryFilters.toList();
                              includePastInMainResults = temporaryIncludePast;
                              includeLaterInMainResults = temporaryIncludeLater;
                            });

                            Navigator.pop(sheetContext);
                          },
                          child: Text(context.l10n.apply),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isCompact = MediaQuery.of(context).size.width < 600;
    return DefaultTabController(
      length: 6,
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 100, // Увеличиваем высоту, чтобы влез поиск и фильтры
          leading: Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu, color: Colors.deepPurple),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          ),
          title: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Поле поиска
              TextField(
                decoration: InputDecoration(
                  hintText: context.l10n.search,
                  border: InputBorder.none,
                  isDense: true,
                ),
                onChanged: (v) => setState(() => searchQuery = v.toLowerCase()),
              ),
              // Секция фильтров с анимацией
              SizedBox(
                width: double.infinity,
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('categories')
                      .where('userId', isEqualTo: currentUserId)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const SizedBox(height: 40);
                    }

                    const statusTags = ['В работе', 'Пересмотреть', 'Архив'];

                    final typeTags = snapshot.data!.docs
                        .map((document) => document['name'] as String)
                        .where((name) => !statusTags.contains(name))
                        .toList();

                    final isAllSelected = selectedFilters.contains('Все');

                    if (isCompact) {
                      return Row(
                        children: [
                          Expanded(
                            child: ActionChip(
                              avatar: Icon(
                                isAllSelected
                                    ? Icons.filter_alt_off_outlined
                                    : Icons.filter_alt_outlined,
                                size: 18,
                              ),
                              label: Text(
                                _selectedFiltersLabel(),
                                overflow: TextOverflow.ellipsis,
                              ),
                              onPressed: () => _showFiltersSheet(typeTags),
                            ),
                          ),
                          const SizedBox(width: 6),
                          IconButton(
                            tooltip: context.l10n.filters,
                            icon: Badge(
                              isLabelVisible: !isAllSelected,
                              label: Text(
                                isAllSelected
                                    ? ''
                                    : selectedFilters.length.toString(),
                              ),
                              child: const Icon(Icons.tune),
                            ),
                            onPressed: () => _showFiltersSheet(typeTags),
                          ),
                        ],
                      );
                    }

                    return AnimatedSize(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      alignment: Alignment.topLeft,
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          FilterChip(
                            label: Text(
                              context.l10n.all,
                              style: const TextStyle(fontSize: 12),
                            ),
                            selected: isAllSelected,
                            onSelected: (_) => _selectAllFilters(),
                          ),
                          FilterChip(
                            label: Text(
                              context.l10n.showPast,
                              style: const TextStyle(fontSize: 12),
                            ),
                            selected: includePastInMainResults,
                            showCheckmark: true,
                            onSelected: (value) {
                              setState(() {
                                includePastInMainResults = value;
                              });
                            },
                          ),

                          FilterChip(
                            label: Text(
                              context.l10n.showLater,
                              style: const TextStyle(fontSize: 12),
                            ),
                            selected: includeLaterInMainResults,
                            showCheckmark: true,
                            onSelected: (value) {
                              setState(() {
                                includeLaterInMainResults = value;
                              });
                            },
                          ),
                          for (final category in typeTags)
                            FilterChip(
                              label: Text(
                                category,
                                style: const TextStyle(fontSize: 12),
                              ),
                              selected: selectedFilters.contains(category),
                              onSelected: (value) {
                                _toggleCategoryFilter(category, value);
                              },
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),

          bottom: TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: context.l10n.all),
              Tab(text: context.l10n.future),
              Tab(text: context.l10n.present),
              Tab(text: context.l10n.again),
              Tab(text: context.l10n.past),
              Tab(text: context.l10n.later),
            ],
          ),
          actions: [
            if (!isCompact)
              IconButton(
                tooltip: context.l10n.randomChoice,
                icon: const Icon(Icons.casino),
                onPressed: () {
                  final tabs = [
                    'all',
                    'future',
                    'present',
                    'again',
                    'past',
                    'later',
                  ];
                  final currentIdx = DefaultTabController.of(context).index;
                  _showRandomItem(tabs[currentIdx]);
                },
              ),
            // Исправленный вызов рандома (Пункт 1
            if (!isCompact)
              IconButton(
                tooltip: context.l10n.changeTheme,
                icon: Icon(
                  themeNotifier.value == ThemeMode.light
                      ? Icons.dark_mode
                      : Icons.light_mode,
                ),
                onPressed: () {
                  themeNotifier.value = themeNotifier.value == ThemeMode.light
                      ? ThemeMode.dark
                      : ThemeMode.light;
                },
              ),
            StreamBuilder<User?>(
              stream: FirebaseAuth.instance.authStateChanges(),
              builder: (context, snapshot) {
                final user = snapshot.data;
                return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                  stream: user == null
                      ? null
                      : FirebaseFirestore.instance
                            .collection('users')
                            .doc(user.uid)
                            .snapshots(),
                  builder: (context, profileSnapshot) {
                    final profile = profileSnapshot.data?.data();

                    final profileName = profile?['displayName']?.toString();
                    final profileEmail = profile?['email']?.toString();

                    final hasLegacyGuestName =
                        user?.isAnonymous == true &&
                        profileName?.trim().startsWith('Гость ') == true;

                    final shownName =
                        profileName?.trim().isNotEmpty == true &&
                            !hasLegacyGuestName
                        ? profileName!.trim()
                        : UserProfileService.instance.fallbackName(
                            user,
                            guestName: context.l10n.accountGuest,
                            unnamedName: context.l10n.accountUnnamed,
                          );

                    final shownEmail = profileEmail?.trim().isNotEmpty == true
                        ? profileEmail!.trim()
                        : user?.email ?? '';

                    return PopupMenuButton<String>(
                      icon: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          user?.photoURL != null
                              ? CircleAvatar(
                                  backgroundImage: NetworkImage(
                                    user!.photoURL!,
                                  ),
                                  radius: 14,
                                )
                              : const Icon(Icons.account_circle),

                          Positioned(
                            top: -2,
                            right: -2,
                            child: AnimatedScale(
                              scale: pendingUpdateUrl != null && showUpdateBadge
                                  ? 1
                                  : 0,
                              duration: const Duration(milliseconds: 260),
                              curve: Curves.easeOutBack,
                              child: AnimatedOpacity(
                                opacity:
                                    pendingUpdateUrl != null && showUpdateBadge
                                    ? 1
                                    : 0,
                                duration: const Duration(milliseconds: 180),
                                child: Container(
                                  width: 10,
                                  height: 10,
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.error,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.surface,
                                      width: 2,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      onSelected: (value) async {
                        if (value == 'random') {
                          final tabs = [
                            'all',
                            'future',
                            'present',
                            'again',
                            'past',
                            'later',
                          ];
                          final currentIdx = DefaultTabController.of(
                            context,
                          ).index;
                          _showRandomItem(tabs[currentIdx]);
                        } else if (value == 'theme') {
                          themeNotifier.value =
                              themeNotifier.value == ThemeMode.light
                              ? ThemeMode.dark
                              : ThemeMode.light;
                        } else if (value == 'account') {
                          _openSettingsScreen(initialSection: 'account');
                        } else if (value == 'settings') {
                          _openSettingsScreen();
                        } else if (value == 'language') {
                          await _showLanguageDialog();
                        } else if (value == 'whats_new') {
                          await _showReleaseNotes();
                        } else if (value == 'update') {
                          if (pendingUpdateUrl != null) {
                            showUpdateDialog(
                              pendingUpdateUrl!,
                              pendingUpdateChangelog ?? '',
                            );
                          }
                        } else if (value == 'logout') {
                          await _confirmLogout();
                        }
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'account',
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                shownName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (shownEmail.isNotEmpty)
                                Text(
                                  shownEmail,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              if (appVersionLabel.isNotEmpty)
                                Text(
                                  context.l10n.versionLabel(appVersionLabel),
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey,
                                  ),
                                ),
                              const Divider(),
                            ],
                          ),
                        ),

                        if (pendingUpdateUrl != null)
                          PopupMenuItem(
                            value: 'update',
                            child: Row(
                              children: [
                                const Icon(Icons.system_update, size: 18),
                                const SizedBox(width: 12),
                                Text(context.l10n.updateApp),
                              ],
                            ),
                          ),
                        if (isCompact)
                          PopupMenuItem(
                            value: 'random',
                            child: Row(
                              children: [
                                const Icon(Icons.casino, size: 18),
                                const SizedBox(width: 8),
                                Text(context.l10n.random),
                              ],
                            ),
                          ),

                        if (isCompact)
                          PopupMenuItem(
                            value: 'theme',
                            child: Row(
                              children: [
                                const Icon(Icons.dark_mode, size: 18),
                                const SizedBox(width: 8),
                                Text(context.l10n.changeTheme),
                              ],
                            ),
                          ),
                        PopupMenuItem(
                          value: 'settings',
                          child: Row(
                            children: [
                              const Icon(Icons.settings, size: 18),
                              const SizedBox(width: 8),
                              Text(context.l10n.settings),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'language',
                          child: Row(
                            children: [
                              const Icon(Icons.language, size: 18),
                              const SizedBox(width: 8),
                              Text(context.l10n.language),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'whats_new',
                          child: Row(
                            children: [
                              const Icon(Icons.new_releases_outlined, size: 18),
                              const SizedBox(width: 8),
                              Text(context.l10n.whatsNew),
                            ],
                          ),
                        ),
                        const PopupMenuDivider(),

                        PopupMenuItem(
                          value: 'logout',
                          child: Row(
                            children: [
                              const Icon(
                                Icons.logout,
                                size: 18,
                                color: Colors.redAccent,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                context.l10n.logout,
                                style: const TextStyle(color: Colors.redAccent),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
            if (!isCompact)
              IconButton(
                tooltip: context.l10n.logout,
                icon: const Icon(Icons.logout),
                onPressed: _confirmLogout,
              ),
          ],
        ),
        drawer: _buildDrawer(),
        bottomNavigationBar: selectionMode
            ? SafeArea(
                top: false,
                child: Material(
                  elevation: 12,
                  color: Theme.of(context).colorScheme.surface,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                context.l10n.selectedItems(
                                  selectedItemIds.length,
                                ),
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.w700),
                              ),
                            ),
                            IconButton(
                              tooltip: context.l10n.cancel,
                              onPressed: _clearSelection,
                              icon: const Icon(Icons.close),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              FilledButton.tonalIcon(
                                onPressed: () =>
                                    _toggleSelectedServiceTag('Потом'),
                                icon: const Icon(Icons.schedule_outlined),
                                label: Text(context.l10n.later),
                              ),
                              const SizedBox(width: 8),
                              FilledButton.tonalIcon(
                                onPressed: () =>
                                    _toggleSelectedServiceTag('Прошлое'),
                                icon: const Icon(Icons.history_outlined),
                                label: Text(context.l10n.past),
                              ),
                              const SizedBox(width: 8),
                              OutlinedButton.icon(
                                onPressed: _deleteSelectedItems,
                                icon: const Icon(
                                  Icons.delete_outline,
                                  color: Colors.redAccent,
                                ),
                                label: Text(
                                  context.l10n.deleteSelected,
                                  style: const TextStyle(
                                    color: Colors.redAccent,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              TextButton.icon(
                                onPressed: _clearSelection,
                                icon: const Icon(Icons.close),
                                label: Text(context.l10n.cancel),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            : null,
        body: Column(
          children: [
            if (maintenanceMode)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                color: Colors.orange.shade700,
                child: Row(
                  children: [
                    const Icon(Icons.build, color: Colors.white),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        maintenanceMessage,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),

            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 700),

                  child: TabBarView(
                    children: [
                      _buildItemList(status: 'all'),
                      _buildItemList(status: 'future'),
                      _buildItemList(status: 'present'),
                      _buildItemList(status: 'again'),
                      _buildItemList(status: 'past'),
                      _buildItemList(status: 'later'),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        floatingActionButton: selectionMode
            ? null
            : FloatingActionButton(
                onPressed: _showAddItemSheet,
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white,
                child: const Icon(Icons.add, size: 30),
              ),
      ),
    );
  }
}
