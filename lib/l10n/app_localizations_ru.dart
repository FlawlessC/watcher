// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appName => 'Watcher';

  @override
  String get language => 'Язык';

  @override
  String get languageDescription => 'Язык интерфейса приложения';

  @override
  String get languageSystem => 'Как в системе';

  @override
  String get languageRussian => 'Русский';

  @override
  String get languageEnglish => 'English';

  @override
  String get settings => 'Настройки';

  @override
  String get account => 'Аккаунт';

  @override
  String get notifications => 'Уведомления';

  @override
  String get updates => 'Обновления';

  @override
  String get logs => 'Логи';

  @override
  String get feedback => 'Обратная связь';

  @override
  String get all => 'Все';

  @override
  String get future => 'Будущее';

  @override
  String get present => 'Настоящее';

  @override
  String get again => 'Ещё раз';

  @override
  String get past => 'Прошлое';

  @override
  String get later => 'Позже';

  @override
  String get search => 'Поиск...';

  @override
  String get filters => 'Фильтры';

  @override
  String get cancel => 'Отмена';

  @override
  String get close => 'Закрыть';

  @override
  String get save => 'Сохранить';

  @override
  String get delete => 'Удалить';

  @override
  String get logout => 'Выйти';

  @override
  String get whatsNew => 'Что нового';

  @override
  String get nothingFound => 'Ничего не найдено';

  @override
  String selectedCount(int count) {
    return 'Выбрано: $count';
  }

  @override
  String versionLabel(String version) {
    return 'Версия $version';
  }

  @override
  String get updateApp => 'Обновить приложение';

  @override
  String get randomChoice => 'Случайный выбор';

  @override
  String get random => 'Рандом';

  @override
  String get changeTheme => 'Сменить тему';

  @override
  String get showPast => 'Показывать прошлое';

  @override
  String get showLater => 'Показывать потом';

  @override
  String get deleteSelected => 'Удалить';

  @override
  String selectedItems(int count) {
    return 'Выбрано: $count';
  }

  @override
  String get filtersDescription =>
      'Можно выбрать несколько категорий одновременно.';

  @override
  String get showPastDescription =>
      'Добавлять пункты из «Прошлого» в основные списки и общий поиск.';

  @override
  String get showLaterDescription =>
      'Добавлять отложенные пункты в основные списки и общий поиск.';

  @override
  String get reset => 'Сбросить';

  @override
  String get apply => 'Применить';

  @override
  String get myLists => 'Мои списки';

  @override
  String get categories => 'Категории';

  @override
  String get noCategories => 'Категорий пока нет';

  @override
  String get newList => 'Новый список';

  @override
  String get listNameHint => 'Название (например, Книги)';

  @override
  String get create => 'Создать';

  @override
  String get deleteListTitle => 'Удалить список?';

  @override
  String get deleteListDescription =>
      'Категория будет удалена. Пункты из неё останутся, но эта категория будет убрана из их тегов.';

  @override
  String get categoryDeleted => 'Категория удалена';

  @override
  String get categoryDeleteError => 'Не удалось удалить категорию';

  @override
  String get editList => 'Редактировать список';

  @override
  String get newName => 'Новое название';

  @override
  String errorWithDetails(String error) {
    return 'Ошибка: $error';
  }

  @override
  String get editItem => 'Редактировать пункт';

  @override
  String get addItem => 'Добавить новый пункт';

  @override
  String get title => 'Название';

  @override
  String get description => 'Описание';

  @override
  String get currentProgress => 'Сейчас';

  @override
  String get totalProgress => 'Всего';

  @override
  String get progressOf => 'из';

  @override
  String get addToList => 'Добавить в список';

  @override
  String get mainList => 'Основной список:';

  @override
  String get hideIn => 'Скрыть в:';

  @override
  String get noCategoriesHint =>
      'Категорий пока нет. Их можно создать в боковом меню.';

  @override
  String itemProgress(String current, String total, String unit) {
    return 'Прогресс: $current/$total $unit';
  }

  @override
  String get logoutTitle => 'Выйти?';

  @override
  String get logoutDescription => 'Вы действительно хотите выйти из аккаунта?';

  @override
  String get installPermissionTitle => 'Нужно разрешение';

  @override
  String get installPermissionDescription =>
      'Для обновления разрешите установку APK из Watcher.';

  @override
  String get openSettings => 'Открыть настройки';

  @override
  String get updateAvailable => 'Доступно обновление';

  @override
  String get downloadingApk => 'Скачиваю APK...';

  @override
  String whatsNewInVersion(Object version) {
    return 'Что нового в версии $version';
  }

  @override
  String get releaseInfoUnavailable => 'Информация об обновлении недоступна.';

  @override
  String get releaseInfoLoadError =>
      'Не удалось загрузить информацию об обновлении';

  @override
  String get maintenanceUnavailable =>
      'Проводятся технические работы. Изменения временно недоступны.';

  @override
  String get apkUpdatesAndroidOnly =>
      'Обновления APK доступны только на Android';

  @override
  String get latestVersionInstalled => 'Установлена актуальная версия';

  @override
  String apkInstallerOpenError(String error) {
    return 'Не удалось открыть установщик APK: $error';
  }

  @override
  String updateError(String error) {
    return 'Ошибка обновления: $error';
  }

  @override
  String updateAvailableVersion(String version) {
    return 'Доступно обновление $version';
  }

  @override
  String get update => 'Обновить';

  @override
  String bulkTagRemoved(String tag) {
    return 'Тег «$tag» убран';
  }

  @override
  String bulkItemsMoved(String tag) {
    return 'Выбранные пункты перемещены в «$tag»';
  }

  @override
  String get bulkChangeError => 'Не удалось изменить выбранные пункты';

  @override
  String get deleteSelectedItemsTitle => 'Удалить выбранные пункты?';

  @override
  String deleteSelectedItemsDescription(int count) {
    return 'Будет удалено: $count. Это действие нельзя отменить.';
  }

  @override
  String deletedItemsCount(int count) {
    return 'Удалено пунктов: $count';
  }

  @override
  String get bulkDeleteError => 'Не удалось удалить выбранные пункты';

  @override
  String get randomListEmpty =>
      'В текущем отфильтрованном списке нет подходящих элементов';

  @override
  String get howAboutThis => 'Как насчёт этого?';

  @override
  String get untitled => 'Без названия';

  @override
  String get another => 'Другой';

  @override
  String get maintenanceDefaultMessage => 'Проводятся технические работы';

  @override
  String get progressUnitEpisode => 'серия';

  @override
  String get progressUnitPage => 'стр.';

  @override
  String get progressUnitChapter => 'гл.';

  @override
  String get progressUnitBook => 'книга';

  @override
  String get progressUnitSeason => 'сезон';

  @override
  String get progressUnitHours => 'часов';

  @override
  String get progressUnitAchievements => 'ачивок';

  @override
  String get progressUnitNone => 'без единицы';

  @override
  String get settingsAccount => 'Аккаунт';

  @override
  String get settingsNotifications => 'Уведомления';

  @override
  String get settingsLogs => 'Логи';

  @override
  String get settingsFeedback => 'Обратная связь';

  @override
  String get settingsUpdates => 'Обновления';

  @override
  String get settingsLanguage => 'Язык';

  @override
  String get backToWatcher => 'Назад в Watcher';

  @override
  String get openMenu => 'Открыть меню';

  @override
  String get back => 'Назад';

  @override
  String get authWait => 'Подождите...';

  @override
  String get authEmail => 'Email';

  @override
  String get authPassword => 'Пароль';

  @override
  String get authRepeatPassword => 'Повтор пароля';

  @override
  String get authSignIn => 'Войти';

  @override
  String get authSignInWithGoogle => 'Войти через Google';

  @override
  String get authSignInWithEmail => 'Войти по email';

  @override
  String get authContinueAsGuest => 'Продолжить как гость';

  @override
  String get authCreateAccount => 'Создать аккаунт';

  @override
  String get authAlreadyHaveAccount => 'Уже есть аккаунт';

  @override
  String get authForgotPassword => 'Забыли пароль?';

  @override
  String get authRecoveryEmail => 'Email для восстановления';

  @override
  String get authSending => 'Отправляю...';

  @override
  String get authSendEmail => 'Отправить письмо';

  @override
  String get authBackToSignIn => 'Назад ко входу';

  @override
  String get authEnterEmailAndPassword => 'Введите email и пароль';

  @override
  String get authEnterEmail => 'Введите email';

  @override
  String get authPasswordsDoNotMatch => 'Пароли не совпадают';

  @override
  String get authPasswordResetEmailSent =>
      'Письмо для сброса пароля отправлено';

  @override
  String get authGoogleSignInFailed => 'Не удалось войти через Google';

  @override
  String get authGuestSignInFailed => 'Не удалось войти как гость';

  @override
  String get authEmailSendFailed => 'Не удалось отправить письмо';

  @override
  String get authSignInFailed => 'Не удалось войти';

  @override
  String get authEmailAlreadyInUse => 'Этот email уже зарегистрирован';

  @override
  String get authInvalidEmail => 'Некорректный email';

  @override
  String get authWeakPassword => 'Пароль слишком простой';

  @override
  String get authUserNotFound => 'Пользователь не найден';

  @override
  String get authWrongEmailOrPassword => 'Неверный email или пароль';

  @override
  String get accountGuest => 'Гость';

  @override
  String get accountUnknownProvider => 'Неизвестно';

  @override
  String get accountUnnamed => 'Без имени';

  @override
  String get accountUserNotFound => 'Пользователь не найден';

  @override
  String accountLoadFailed(String error) {
    return 'Не удалось загрузить аккаунт: $error';
  }

  @override
  String get accountSignOutQuestion => 'Выйти?';

  @override
  String get accountSignOutConfirmation =>
      'Вы действительно хотите выйти из аккаунта?';

  @override
  String get accountSignOut => 'Выйти';

  @override
  String get accountDeleteQuestion => 'Удалить аккаунт?';

  @override
  String get accountDeleteExplanation =>
      'Аккаунт будет отключён сразу, но окончательно удалится только через 14 дней.\n\nДо этого момента его можно будет восстановить.';

  @override
  String get accountDelete => 'Удалить';

  @override
  String get accountDeleteAccount => 'Удалить аккаунт';

  @override
  String get accountMainInformation => 'Основная информация';

  @override
  String get accountPersonalData => 'Личные данные';

  @override
  String get accountSecurity => 'Безопасность';

  @override
  String get accountAuthorization => 'Авторизация';

  @override
  String get accountWatcherId => 'Watcher ID';

  @override
  String get accountWatcherIdCopied => 'Watcher ID скопирован';

  @override
  String get accountLogin => 'Логин';

  @override
  String get accountLoginCopied => 'Логин скопирован';

  @override
  String get accountNickname => 'Ник';

  @override
  String get accountChangeNicknameQuestion => 'Изменить ник?';

  @override
  String get accountChangeNicknameExplanation =>
      'Новый ник будет отображаться в приложении.';

  @override
  String get accountChangeEmailQuestion => 'Изменить email?';

  @override
  String get accountChangeEmailExplanation =>
      'Почта будет изменена в профиле. Перепривязку Firebase Auth добавим отдельным шагом.';

  @override
  String get accountPassword => 'Пароль';

  @override
  String get accountChangePassword => 'Изменить пароль';

  @override
  String get accountPasswordEmailOnly => 'Доступно для email-аккаунтов';

  @override
  String get accountPasswordComingSoon => 'Смену пароля добавим позже';

  @override
  String get accountActiveDevices => 'Активные устройства';

  @override
  String get accountActiveDevicesComingSoon =>
      'Активные устройства добавим позже';

  @override
  String get accountTwoFactorProtection => 'Двухфакторная защита';

  @override
  String get accountTwoFactorComingSoon => '2FA добавим позже';

  @override
  String get accountComingSoon => 'Появится позже';

  @override
  String get accountSignInType => 'Тип входа';

  @override
  String get accountLinkGoogle => 'Привязать Google';

  @override
  String get accountLinkGoogleComingSoon => 'Привязку Google добавим позже';

  @override
  String get accountLinkEmail => 'Привязать Email';

  @override
  String get accountLinkEmailComingSoon => 'Привязку Email добавим позже';

  @override
  String get feedbackTitle => 'Обратная связь';

  @override
  String get feedbackSubtitle =>
      'Расскажи об ошибке или предложи улучшение для Watcher.';

  @override
  String get feedbackType => 'Тип обращения';

  @override
  String get feedbackBug => 'Баг';

  @override
  String get feedbackImprovement => 'Предложение';

  @override
  String get feedbackOther => 'Другое';

  @override
  String get feedbackDescription => 'Описание';

  @override
  String get feedbackDescriptionHint =>
      'Что произошло, чего ты ожидал(а) и как это можно повторить?';

  @override
  String get feedbackSend => 'Отправить';

  @override
  String get feedbackSending => 'Отправка...';

  @override
  String get feedbackTechnicalInformation => 'Техническая информация';

  @override
  String get feedbackCopy => 'Копировать';

  @override
  String get feedbackCopied => 'Скопировано';

  @override
  String get feedbackLoading => 'Загрузка...';

  @override
  String get feedbackLoadFailed => 'Не удалось получить информацию';

  @override
  String get feedbackApplication => 'Приложение';

  @override
  String get feedbackVersion => 'Версия';

  @override
  String get feedbackPlatform => 'Платформа';

  @override
  String get feedbackMessageTooShort =>
      'Опиши проблему или предложение хотя бы в 10 символах';

  @override
  String get feedbackLoginRequired =>
      'Для отправки обращения нужно войти в аккаунт';

  @override
  String get feedbackSent => 'Сообщение отправлено. Спасибо!';

  @override
  String get feedbackSendFailed => 'Не удалось отправить сообщение';

  @override
  String get feedbackPermissionDenied =>
      'Нет разрешения на отправку. Сообщи по почте о проблеме.';

  @override
  String get logsDescription =>
      'Логи помогают найти причину ошибки в приложении.';

  @override
  String get logsCollect => 'Собирать логи';

  @override
  String get logsCollectDescription =>
      'Сбор выполняется только во время работы приложения.';

  @override
  String get logsCollected => 'Собранные логи';

  @override
  String get logsEmpty => 'Логов пока нет';

  @override
  String get logsCopied => 'Логи скопированы';

  @override
  String get logsCleared => 'Логи очищены';

  @override
  String get logsShare => 'Поделиться';

  @override
  String get logsClear => 'Очистить';

  @override
  String get logsClearQuestion => 'Очистить логи?';

  @override
  String get logsClearExplanation =>
      'Все собранные за текущий запуск логи будут удалены.';

  @override
  String get logsShareSubject => 'Watcher — логи приложения';

  @override
  String get logsShareHeader => 'Watcher — логи приложения';

  @override
  String get settingCopy => 'Копировать';

  @override
  String get settingCopied => 'Скопировано';

  @override
  String get settingEdit => 'Изменить';

  @override
  String get settingValueTooShort =>
      'Значение должно быть не короче 2 символов';

  @override
  String get settingChangesSaved => 'Изменения сохранены';

  @override
  String settingSaveFailed(String error) {
    return 'Не удалось сохранить: $error';
  }

  @override
  String get updatesDescription => 'Проверка и установка новых версий Watcher.';

  @override
  String get updatesCurrentVersion => 'Текущая версия';

  @override
  String get updatesAvailable => 'Доступно обновление';

  @override
  String get updatesNewVersion => 'Новая версия';

  @override
  String get updatesShowIndicator => 'Показывать индикатор обновления';

  @override
  String get updatesIndicatorDescription =>
      'Красная точка появится на иконке профиля, когда будет доступна новая версия.';

  @override
  String get updatesCheck => 'Проверить обновления';

  @override
  String get updatesWhatsNew => 'Что нового';

  @override
  String get notificationsShowUpdate => 'Показывать уведомление об обновлении';

  @override
  String get notificationsShowUpdateDescription =>
      'Если выключено, красная точка на иконке профиля не будет появляться.';

  @override
  String logInstallPermissionCheckError(String error) {
    return 'Ошибка проверки разрешения установки APK: $error';
  }

  @override
  String logInstallSettingsOpenError(String error) {
    return 'Ошибка открытия настроек установки APK: $error';
  }

  @override
  String logMaintenanceCheckError(String error) {
    return 'Ошибка проверки технических работ: $error';
  }

  @override
  String get logApkDownloadStarted => 'Начато скачивание APK';

  @override
  String get logApkDownloaded => 'APK скачан';

  @override
  String logApkUpdateError(String error) {
    return 'Ошибка обновления: $error';
  }
}
