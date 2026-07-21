import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';

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
    Locale('en'),
    Locale('ru'),
  ];

  /// No description provided for @appName.
  ///
  /// In ru, this message translates to:
  /// **'Watcher'**
  String get appName;

  /// No description provided for @language.
  ///
  /// In ru, this message translates to:
  /// **'Язык'**
  String get language;

  /// No description provided for @languageDescription.
  ///
  /// In ru, this message translates to:
  /// **'Язык интерфейса приложения'**
  String get languageDescription;

  /// No description provided for @languageSystem.
  ///
  /// In ru, this message translates to:
  /// **'Как в системе'**
  String get languageSystem;

  /// No description provided for @languageRussian.
  ///
  /// In ru, this message translates to:
  /// **'Русский'**
  String get languageRussian;

  /// No description provided for @languageEnglish.
  ///
  /// In ru, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @settings.
  ///
  /// In ru, this message translates to:
  /// **'Настройки'**
  String get settings;

  /// No description provided for @account.
  ///
  /// In ru, this message translates to:
  /// **'Аккаунт'**
  String get account;

  /// No description provided for @notifications.
  ///
  /// In ru, this message translates to:
  /// **'Уведомления'**
  String get notifications;

  /// No description provided for @updates.
  ///
  /// In ru, this message translates to:
  /// **'Обновления'**
  String get updates;

  /// No description provided for @logs.
  ///
  /// In ru, this message translates to:
  /// **'Логи'**
  String get logs;

  /// No description provided for @feedback.
  ///
  /// In ru, this message translates to:
  /// **'Обратная связь'**
  String get feedback;

  /// No description provided for @all.
  ///
  /// In ru, this message translates to:
  /// **'Все'**
  String get all;

  /// No description provided for @future.
  ///
  /// In ru, this message translates to:
  /// **'Будущее'**
  String get future;

  /// No description provided for @present.
  ///
  /// In ru, this message translates to:
  /// **'Настоящее'**
  String get present;

  /// No description provided for @again.
  ///
  /// In ru, this message translates to:
  /// **'Ещё раз'**
  String get again;

  /// No description provided for @past.
  ///
  /// In ru, this message translates to:
  /// **'Прошлое'**
  String get past;

  /// No description provided for @later.
  ///
  /// In ru, this message translates to:
  /// **'Позже'**
  String get later;

  /// No description provided for @search.
  ///
  /// In ru, this message translates to:
  /// **'Поиск...'**
  String get search;

  /// No description provided for @filters.
  ///
  /// In ru, this message translates to:
  /// **'Фильтры'**
  String get filters;

  /// No description provided for @cancel.
  ///
  /// In ru, this message translates to:
  /// **'Отмена'**
  String get cancel;

  /// No description provided for @close.
  ///
  /// In ru, this message translates to:
  /// **'Закрыть'**
  String get close;

  /// No description provided for @save.
  ///
  /// In ru, this message translates to:
  /// **'Сохранить'**
  String get save;

  /// No description provided for @delete.
  ///
  /// In ru, this message translates to:
  /// **'Удалить'**
  String get delete;

  /// No description provided for @logout.
  ///
  /// In ru, this message translates to:
  /// **'Выйти'**
  String get logout;

  /// No description provided for @whatsNew.
  ///
  /// In ru, this message translates to:
  /// **'Что нового'**
  String get whatsNew;

  /// No description provided for @nothingFound.
  ///
  /// In ru, this message translates to:
  /// **'Ничего не найдено'**
  String get nothingFound;

  /// No description provided for @selectedCount.
  ///
  /// In ru, this message translates to:
  /// **'Выбрано: {count}'**
  String selectedCount(int count);

  /// No description provided for @versionLabel.
  ///
  /// In ru, this message translates to:
  /// **'Версия {version}'**
  String versionLabel(String version);

  /// No description provided for @updateApp.
  ///
  /// In ru, this message translates to:
  /// **'Обновить приложение'**
  String get updateApp;

  /// No description provided for @randomChoice.
  ///
  /// In ru, this message translates to:
  /// **'Случайный выбор'**
  String get randomChoice;

  /// No description provided for @random.
  ///
  /// In ru, this message translates to:
  /// **'Рандом'**
  String get random;

  /// No description provided for @changeTheme.
  ///
  /// In ru, this message translates to:
  /// **'Сменить тему'**
  String get changeTheme;

  /// No description provided for @showPast.
  ///
  /// In ru, this message translates to:
  /// **'Показывать прошлое'**
  String get showPast;

  /// No description provided for @showLater.
  ///
  /// In ru, this message translates to:
  /// **'Показывать потом'**
  String get showLater;

  /// No description provided for @deleteSelected.
  ///
  /// In ru, this message translates to:
  /// **'Удалить'**
  String get deleteSelected;

  /// No description provided for @selectedItems.
  ///
  /// In ru, this message translates to:
  /// **'Выбрано: {count}'**
  String selectedItems(int count);

  /// No description provided for @filtersDescription.
  ///
  /// In ru, this message translates to:
  /// **'Можно выбрать несколько категорий одновременно.'**
  String get filtersDescription;

  /// No description provided for @showPastDescription.
  ///
  /// In ru, this message translates to:
  /// **'Добавлять пункты из «Прошлого» в основные списки и общий поиск.'**
  String get showPastDescription;

  /// No description provided for @showLaterDescription.
  ///
  /// In ru, this message translates to:
  /// **'Добавлять отложенные пункты в основные списки и общий поиск.'**
  String get showLaterDescription;

  /// No description provided for @reset.
  ///
  /// In ru, this message translates to:
  /// **'Сбросить'**
  String get reset;

  /// No description provided for @apply.
  ///
  /// In ru, this message translates to:
  /// **'Применить'**
  String get apply;

  /// No description provided for @myLists.
  ///
  /// In ru, this message translates to:
  /// **'Мои списки'**
  String get myLists;

  /// No description provided for @categories.
  ///
  /// In ru, this message translates to:
  /// **'Категории'**
  String get categories;

  /// No description provided for @noCategories.
  ///
  /// In ru, this message translates to:
  /// **'Категорий пока нет'**
  String get noCategories;

  /// No description provided for @newList.
  ///
  /// In ru, this message translates to:
  /// **'Новый список'**
  String get newList;

  /// No description provided for @listNameHint.
  ///
  /// In ru, this message translates to:
  /// **'Название (например, Книги)'**
  String get listNameHint;

  /// No description provided for @create.
  ///
  /// In ru, this message translates to:
  /// **'Создать'**
  String get create;

  /// No description provided for @deleteListTitle.
  ///
  /// In ru, this message translates to:
  /// **'Удалить список?'**
  String get deleteListTitle;

  /// No description provided for @deleteListDescription.
  ///
  /// In ru, this message translates to:
  /// **'Категория будет удалена. Пункты из неё останутся, но эта категория будет убрана из их тегов.'**
  String get deleteListDescription;

  /// No description provided for @categoryDeleted.
  ///
  /// In ru, this message translates to:
  /// **'Категория удалена'**
  String get categoryDeleted;

  /// No description provided for @categoryDeleteError.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось удалить категорию'**
  String get categoryDeleteError;

  /// No description provided for @editList.
  ///
  /// In ru, this message translates to:
  /// **'Редактировать список'**
  String get editList;

  /// No description provided for @newName.
  ///
  /// In ru, this message translates to:
  /// **'Новое название'**
  String get newName;

  /// No description provided for @errorWithDetails.
  ///
  /// In ru, this message translates to:
  /// **'Ошибка: {error}'**
  String errorWithDetails(String error);

  /// No description provided for @editItem.
  ///
  /// In ru, this message translates to:
  /// **'Редактировать пункт'**
  String get editItem;

  /// No description provided for @addItem.
  ///
  /// In ru, this message translates to:
  /// **'Добавить новый пункт'**
  String get addItem;

  /// No description provided for @title.
  ///
  /// In ru, this message translates to:
  /// **'Название'**
  String get title;

  /// No description provided for @description.
  ///
  /// In ru, this message translates to:
  /// **'Описание'**
  String get description;

  /// No description provided for @currentProgress.
  ///
  /// In ru, this message translates to:
  /// **'Сейчас'**
  String get currentProgress;

  /// No description provided for @totalProgress.
  ///
  /// In ru, this message translates to:
  /// **'Всего'**
  String get totalProgress;

  /// No description provided for @progressOf.
  ///
  /// In ru, this message translates to:
  /// **'из'**
  String get progressOf;

  /// No description provided for @addToList.
  ///
  /// In ru, this message translates to:
  /// **'Добавить в список'**
  String get addToList;

  /// No description provided for @mainList.
  ///
  /// In ru, this message translates to:
  /// **'Основной список:'**
  String get mainList;

  /// No description provided for @hideIn.
  ///
  /// In ru, this message translates to:
  /// **'Скрыть в:'**
  String get hideIn;

  /// No description provided for @noCategoriesHint.
  ///
  /// In ru, this message translates to:
  /// **'Категорий пока нет. Их можно создать в боковом меню.'**
  String get noCategoriesHint;

  /// No description provided for @itemProgress.
  ///
  /// In ru, this message translates to:
  /// **'Прогресс: {current}/{total} {unit}'**
  String itemProgress(String current, String total, String unit);

  /// No description provided for @logoutTitle.
  ///
  /// In ru, this message translates to:
  /// **'Выйти?'**
  String get logoutTitle;

  /// No description provided for @logoutDescription.
  ///
  /// In ru, this message translates to:
  /// **'Вы действительно хотите выйти из аккаунта?'**
  String get logoutDescription;

  /// No description provided for @installPermissionTitle.
  ///
  /// In ru, this message translates to:
  /// **'Нужно разрешение'**
  String get installPermissionTitle;

  /// No description provided for @installPermissionDescription.
  ///
  /// In ru, this message translates to:
  /// **'Для обновления разрешите установку APK из Watcher.'**
  String get installPermissionDescription;

  /// No description provided for @openSettings.
  ///
  /// In ru, this message translates to:
  /// **'Открыть настройки'**
  String get openSettings;

  /// No description provided for @updateAvailable.
  ///
  /// In ru, this message translates to:
  /// **'Доступно обновление'**
  String get updateAvailable;

  /// No description provided for @downloadingApk.
  ///
  /// In ru, this message translates to:
  /// **'Скачиваю APK...'**
  String get downloadingApk;

  /// No description provided for @whatsNewInVersion.
  ///
  /// In ru, this message translates to:
  /// **'Что нового в версии {version}'**
  String whatsNewInVersion(Object version);

  /// No description provided for @releaseInfoUnavailable.
  ///
  /// In ru, this message translates to:
  /// **'Информация об обновлении недоступна.'**
  String get releaseInfoUnavailable;

  /// No description provided for @releaseInfoLoadError.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось загрузить информацию об обновлении'**
  String get releaseInfoLoadError;

  /// No description provided for @maintenanceUnavailable.
  ///
  /// In ru, this message translates to:
  /// **'Проводятся технические работы. Изменения временно недоступны.'**
  String get maintenanceUnavailable;

  /// No description provided for @apkUpdatesAndroidOnly.
  ///
  /// In ru, this message translates to:
  /// **'Обновления APK доступны только на Android'**
  String get apkUpdatesAndroidOnly;

  /// No description provided for @latestVersionInstalled.
  ///
  /// In ru, this message translates to:
  /// **'Установлена актуальная версия'**
  String get latestVersionInstalled;

  /// No description provided for @apkInstallerOpenError.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось открыть установщик APK: {error}'**
  String apkInstallerOpenError(String error);

  /// No description provided for @updateError.
  ///
  /// In ru, this message translates to:
  /// **'Ошибка обновления: {error}'**
  String updateError(String error);

  /// No description provided for @updateAvailableVersion.
  ///
  /// In ru, this message translates to:
  /// **'Доступно обновление {version}'**
  String updateAvailableVersion(String version);

  /// No description provided for @update.
  ///
  /// In ru, this message translates to:
  /// **'Обновить'**
  String get update;

  /// No description provided for @bulkTagRemoved.
  ///
  /// In ru, this message translates to:
  /// **'Тег «{tag}» убран'**
  String bulkTagRemoved(String tag);

  /// No description provided for @bulkItemsMoved.
  ///
  /// In ru, this message translates to:
  /// **'Выбранные пункты перемещены в «{tag}»'**
  String bulkItemsMoved(String tag);

  /// No description provided for @bulkChangeError.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось изменить выбранные пункты'**
  String get bulkChangeError;

  /// No description provided for @deleteSelectedItemsTitle.
  ///
  /// In ru, this message translates to:
  /// **'Удалить выбранные пункты?'**
  String get deleteSelectedItemsTitle;

  /// No description provided for @deleteSelectedItemsDescription.
  ///
  /// In ru, this message translates to:
  /// **'Будет удалено: {count}. Это действие нельзя отменить.'**
  String deleteSelectedItemsDescription(int count);

  /// No description provided for @deletedItemsCount.
  ///
  /// In ru, this message translates to:
  /// **'Удалено пунктов: {count}'**
  String deletedItemsCount(int count);

  /// No description provided for @bulkDeleteError.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось удалить выбранные пункты'**
  String get bulkDeleteError;

  /// No description provided for @randomListEmpty.
  ///
  /// In ru, this message translates to:
  /// **'В текущем отфильтрованном списке нет подходящих элементов'**
  String get randomListEmpty;

  /// No description provided for @howAboutThis.
  ///
  /// In ru, this message translates to:
  /// **'Как насчёт этого?'**
  String get howAboutThis;

  /// No description provided for @untitled.
  ///
  /// In ru, this message translates to:
  /// **'Без названия'**
  String get untitled;

  /// No description provided for @another.
  ///
  /// In ru, this message translates to:
  /// **'Другой'**
  String get another;

  /// No description provided for @maintenanceDefaultMessage.
  ///
  /// In ru, this message translates to:
  /// **'Проводятся технические работы'**
  String get maintenanceDefaultMessage;

  /// No description provided for @progressUnitEpisode.
  ///
  /// In ru, this message translates to:
  /// **'серия'**
  String get progressUnitEpisode;

  /// No description provided for @progressUnitPage.
  ///
  /// In ru, this message translates to:
  /// **'стр.'**
  String get progressUnitPage;

  /// No description provided for @progressUnitChapter.
  ///
  /// In ru, this message translates to:
  /// **'гл.'**
  String get progressUnitChapter;

  /// No description provided for @progressUnitBook.
  ///
  /// In ru, this message translates to:
  /// **'книга'**
  String get progressUnitBook;

  /// No description provided for @progressUnitSeason.
  ///
  /// In ru, this message translates to:
  /// **'сезон'**
  String get progressUnitSeason;

  /// No description provided for @progressUnitHours.
  ///
  /// In ru, this message translates to:
  /// **'часов'**
  String get progressUnitHours;

  /// No description provided for @progressUnitAchievements.
  ///
  /// In ru, this message translates to:
  /// **'ачивок'**
  String get progressUnitAchievements;

  /// No description provided for @progressUnitNone.
  ///
  /// In ru, this message translates to:
  /// **'без единицы'**
  String get progressUnitNone;

  /// No description provided for @settingsAccount.
  ///
  /// In ru, this message translates to:
  /// **'Аккаунт'**
  String get settingsAccount;

  /// No description provided for @settingsNotifications.
  ///
  /// In ru, this message translates to:
  /// **'Уведомления'**
  String get settingsNotifications;

  /// No description provided for @settingsLogs.
  ///
  /// In ru, this message translates to:
  /// **'Логи'**
  String get settingsLogs;

  /// No description provided for @settingsFeedback.
  ///
  /// In ru, this message translates to:
  /// **'Обратная связь'**
  String get settingsFeedback;

  /// No description provided for @settingsUpdates.
  ///
  /// In ru, this message translates to:
  /// **'Обновления'**
  String get settingsUpdates;

  /// No description provided for @settingsLanguage.
  ///
  /// In ru, this message translates to:
  /// **'Язык'**
  String get settingsLanguage;

  /// No description provided for @backToWatcher.
  ///
  /// In ru, this message translates to:
  /// **'Назад в Watcher'**
  String get backToWatcher;

  /// No description provided for @openMenu.
  ///
  /// In ru, this message translates to:
  /// **'Открыть меню'**
  String get openMenu;

  /// No description provided for @back.
  ///
  /// In ru, this message translates to:
  /// **'Назад'**
  String get back;

  /// No description provided for @authWait.
  ///
  /// In ru, this message translates to:
  /// **'Подождите...'**
  String get authWait;

  /// No description provided for @authEmail.
  ///
  /// In ru, this message translates to:
  /// **'Email'**
  String get authEmail;

  /// No description provided for @authPassword.
  ///
  /// In ru, this message translates to:
  /// **'Пароль'**
  String get authPassword;

  /// No description provided for @authRepeatPassword.
  ///
  /// In ru, this message translates to:
  /// **'Повтор пароля'**
  String get authRepeatPassword;

  /// No description provided for @authSignIn.
  ///
  /// In ru, this message translates to:
  /// **'Войти'**
  String get authSignIn;

  /// No description provided for @authSignInWithGoogle.
  ///
  /// In ru, this message translates to:
  /// **'Войти через Google'**
  String get authSignInWithGoogle;

  /// No description provided for @authSignInWithEmail.
  ///
  /// In ru, this message translates to:
  /// **'Войти по email'**
  String get authSignInWithEmail;

  /// No description provided for @authContinueAsGuest.
  ///
  /// In ru, this message translates to:
  /// **'Продолжить как гость'**
  String get authContinueAsGuest;

  /// No description provided for @authCreateAccount.
  ///
  /// In ru, this message translates to:
  /// **'Создать аккаунт'**
  String get authCreateAccount;

  /// No description provided for @authAlreadyHaveAccount.
  ///
  /// In ru, this message translates to:
  /// **'Уже есть аккаунт'**
  String get authAlreadyHaveAccount;

  /// No description provided for @authForgotPassword.
  ///
  /// In ru, this message translates to:
  /// **'Забыли пароль?'**
  String get authForgotPassword;

  /// No description provided for @authRecoveryEmail.
  ///
  /// In ru, this message translates to:
  /// **'Email для восстановления'**
  String get authRecoveryEmail;

  /// No description provided for @authSending.
  ///
  /// In ru, this message translates to:
  /// **'Отправляю...'**
  String get authSending;

  /// No description provided for @authSendEmail.
  ///
  /// In ru, this message translates to:
  /// **'Отправить письмо'**
  String get authSendEmail;

  /// No description provided for @authBackToSignIn.
  ///
  /// In ru, this message translates to:
  /// **'Назад ко входу'**
  String get authBackToSignIn;

  /// No description provided for @authEnterEmailAndPassword.
  ///
  /// In ru, this message translates to:
  /// **'Введите email и пароль'**
  String get authEnterEmailAndPassword;

  /// No description provided for @authEnterEmail.
  ///
  /// In ru, this message translates to:
  /// **'Введите email'**
  String get authEnterEmail;

  /// No description provided for @authPasswordsDoNotMatch.
  ///
  /// In ru, this message translates to:
  /// **'Пароли не совпадают'**
  String get authPasswordsDoNotMatch;

  /// No description provided for @authPasswordResetEmailSent.
  ///
  /// In ru, this message translates to:
  /// **'Письмо для сброса пароля отправлено'**
  String get authPasswordResetEmailSent;

  /// No description provided for @authGoogleSignInFailed.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось войти через Google'**
  String get authGoogleSignInFailed;

  /// No description provided for @authGuestSignInFailed.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось войти как гость'**
  String get authGuestSignInFailed;

  /// No description provided for @authEmailSendFailed.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось отправить письмо'**
  String get authEmailSendFailed;

  /// No description provided for @authSignInFailed.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось войти'**
  String get authSignInFailed;

  /// No description provided for @authEmailAlreadyInUse.
  ///
  /// In ru, this message translates to:
  /// **'Этот email уже зарегистрирован'**
  String get authEmailAlreadyInUse;

  /// No description provided for @authInvalidEmail.
  ///
  /// In ru, this message translates to:
  /// **'Некорректный email'**
  String get authInvalidEmail;

  /// No description provided for @authWeakPassword.
  ///
  /// In ru, this message translates to:
  /// **'Пароль слишком простой'**
  String get authWeakPassword;

  /// No description provided for @authUserNotFound.
  ///
  /// In ru, this message translates to:
  /// **'Пользователь не найден'**
  String get authUserNotFound;

  /// No description provided for @authWrongEmailOrPassword.
  ///
  /// In ru, this message translates to:
  /// **'Неверный email или пароль'**
  String get authWrongEmailOrPassword;

  /// No description provided for @accountGuest.
  ///
  /// In ru, this message translates to:
  /// **'Гость'**
  String get accountGuest;

  /// No description provided for @accountUnknownProvider.
  ///
  /// In ru, this message translates to:
  /// **'Неизвестно'**
  String get accountUnknownProvider;

  /// No description provided for @accountUnnamed.
  ///
  /// In ru, this message translates to:
  /// **'Без имени'**
  String get accountUnnamed;

  /// No description provided for @accountUserNotFound.
  ///
  /// In ru, this message translates to:
  /// **'Пользователь не найден'**
  String get accountUserNotFound;

  /// No description provided for @accountLoadFailed.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось загрузить аккаунт: {error}'**
  String accountLoadFailed(String error);

  /// No description provided for @accountSignOutQuestion.
  ///
  /// In ru, this message translates to:
  /// **'Выйти?'**
  String get accountSignOutQuestion;

  /// No description provided for @accountSignOutConfirmation.
  ///
  /// In ru, this message translates to:
  /// **'Вы действительно хотите выйти из аккаунта?'**
  String get accountSignOutConfirmation;

  /// No description provided for @accountSignOut.
  ///
  /// In ru, this message translates to:
  /// **'Выйти'**
  String get accountSignOut;

  /// No description provided for @accountDeleteQuestion.
  ///
  /// In ru, this message translates to:
  /// **'Удалить аккаунт?'**
  String get accountDeleteQuestion;

  /// No description provided for @accountDeleteExplanation.
  ///
  /// In ru, this message translates to:
  /// **'Аккаунт будет отключён сразу, но окончательно удалится только через 14 дней.\n\nДо этого момента его можно будет восстановить.'**
  String get accountDeleteExplanation;

  /// No description provided for @accountDelete.
  ///
  /// In ru, this message translates to:
  /// **'Удалить'**
  String get accountDelete;

  /// No description provided for @accountDeleteAccount.
  ///
  /// In ru, this message translates to:
  /// **'Удалить аккаунт'**
  String get accountDeleteAccount;

  /// No description provided for @accountMainInformation.
  ///
  /// In ru, this message translates to:
  /// **'Основная информация'**
  String get accountMainInformation;

  /// No description provided for @accountPersonalData.
  ///
  /// In ru, this message translates to:
  /// **'Личные данные'**
  String get accountPersonalData;

  /// No description provided for @accountSecurity.
  ///
  /// In ru, this message translates to:
  /// **'Безопасность'**
  String get accountSecurity;

  /// No description provided for @accountAuthorization.
  ///
  /// In ru, this message translates to:
  /// **'Авторизация'**
  String get accountAuthorization;

  /// No description provided for @accountWatcherId.
  ///
  /// In ru, this message translates to:
  /// **'Watcher ID'**
  String get accountWatcherId;

  /// No description provided for @accountWatcherIdCopied.
  ///
  /// In ru, this message translates to:
  /// **'Watcher ID скопирован'**
  String get accountWatcherIdCopied;

  /// No description provided for @accountLogin.
  ///
  /// In ru, this message translates to:
  /// **'Логин'**
  String get accountLogin;

  /// No description provided for @accountLoginCopied.
  ///
  /// In ru, this message translates to:
  /// **'Логин скопирован'**
  String get accountLoginCopied;

  /// No description provided for @accountNickname.
  ///
  /// In ru, this message translates to:
  /// **'Ник'**
  String get accountNickname;

  /// No description provided for @accountChangeNicknameQuestion.
  ///
  /// In ru, this message translates to:
  /// **'Изменить ник?'**
  String get accountChangeNicknameQuestion;

  /// No description provided for @accountChangeNicknameExplanation.
  ///
  /// In ru, this message translates to:
  /// **'Новый ник будет отображаться в приложении.'**
  String get accountChangeNicknameExplanation;

  /// No description provided for @accountChangeEmailQuestion.
  ///
  /// In ru, this message translates to:
  /// **'Изменить email?'**
  String get accountChangeEmailQuestion;

  /// No description provided for @accountChangeEmailExplanation.
  ///
  /// In ru, this message translates to:
  /// **'Почта будет изменена в профиле. Перепривязку Firebase Auth добавим отдельным шагом.'**
  String get accountChangeEmailExplanation;

  /// No description provided for @accountPassword.
  ///
  /// In ru, this message translates to:
  /// **'Пароль'**
  String get accountPassword;

  /// No description provided for @accountChangePassword.
  ///
  /// In ru, this message translates to:
  /// **'Изменить пароль'**
  String get accountChangePassword;

  /// No description provided for @accountPasswordEmailOnly.
  ///
  /// In ru, this message translates to:
  /// **'Доступно для email-аккаунтов'**
  String get accountPasswordEmailOnly;

  /// No description provided for @accountPasswordComingSoon.
  ///
  /// In ru, this message translates to:
  /// **'Смену пароля добавим позже'**
  String get accountPasswordComingSoon;

  /// No description provided for @accountActiveDevices.
  ///
  /// In ru, this message translates to:
  /// **'Активные устройства'**
  String get accountActiveDevices;

  /// No description provided for @accountActiveDevicesComingSoon.
  ///
  /// In ru, this message translates to:
  /// **'Активные устройства добавим позже'**
  String get accountActiveDevicesComingSoon;

  /// No description provided for @accountTwoFactorProtection.
  ///
  /// In ru, this message translates to:
  /// **'Двухфакторная защита'**
  String get accountTwoFactorProtection;

  /// No description provided for @accountTwoFactorComingSoon.
  ///
  /// In ru, this message translates to:
  /// **'2FA добавим позже'**
  String get accountTwoFactorComingSoon;

  /// No description provided for @accountComingSoon.
  ///
  /// In ru, this message translates to:
  /// **'Появится позже'**
  String get accountComingSoon;

  /// No description provided for @accountSignInType.
  ///
  /// In ru, this message translates to:
  /// **'Тип входа'**
  String get accountSignInType;

  /// No description provided for @accountLinkGoogle.
  ///
  /// In ru, this message translates to:
  /// **'Привязать Google'**
  String get accountLinkGoogle;

  /// No description provided for @accountLinkGoogleComingSoon.
  ///
  /// In ru, this message translates to:
  /// **'Привязку Google добавим позже'**
  String get accountLinkGoogleComingSoon;

  /// No description provided for @accountLinkEmail.
  ///
  /// In ru, this message translates to:
  /// **'Привязать Email'**
  String get accountLinkEmail;

  /// No description provided for @accountLinkEmailComingSoon.
  ///
  /// In ru, this message translates to:
  /// **'Привязку Email добавим позже'**
  String get accountLinkEmailComingSoon;

  /// No description provided for @feedbackTitle.
  ///
  /// In ru, this message translates to:
  /// **'Обратная связь'**
  String get feedbackTitle;

  /// No description provided for @feedbackSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Расскажи об ошибке или предложи улучшение для Watcher.'**
  String get feedbackSubtitle;

  /// No description provided for @feedbackType.
  ///
  /// In ru, this message translates to:
  /// **'Тип обращения'**
  String get feedbackType;

  /// No description provided for @feedbackBug.
  ///
  /// In ru, this message translates to:
  /// **'Баг'**
  String get feedbackBug;

  /// No description provided for @feedbackImprovement.
  ///
  /// In ru, this message translates to:
  /// **'Предложение'**
  String get feedbackImprovement;

  /// No description provided for @feedbackOther.
  ///
  /// In ru, this message translates to:
  /// **'Другое'**
  String get feedbackOther;

  /// No description provided for @feedbackDescription.
  ///
  /// In ru, this message translates to:
  /// **'Описание'**
  String get feedbackDescription;

  /// No description provided for @feedbackDescriptionHint.
  ///
  /// In ru, this message translates to:
  /// **'Что произошло, чего ты ожидал(а) и как это можно повторить?'**
  String get feedbackDescriptionHint;

  /// No description provided for @feedbackSend.
  ///
  /// In ru, this message translates to:
  /// **'Отправить'**
  String get feedbackSend;

  /// No description provided for @feedbackSending.
  ///
  /// In ru, this message translates to:
  /// **'Отправка...'**
  String get feedbackSending;

  /// No description provided for @feedbackTechnicalInformation.
  ///
  /// In ru, this message translates to:
  /// **'Техническая информация'**
  String get feedbackTechnicalInformation;

  /// No description provided for @feedbackCopy.
  ///
  /// In ru, this message translates to:
  /// **'Копировать'**
  String get feedbackCopy;

  /// No description provided for @feedbackCopied.
  ///
  /// In ru, this message translates to:
  /// **'Скопировано'**
  String get feedbackCopied;

  /// No description provided for @feedbackLoading.
  ///
  /// In ru, this message translates to:
  /// **'Загрузка...'**
  String get feedbackLoading;

  /// No description provided for @feedbackLoadFailed.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось получить информацию'**
  String get feedbackLoadFailed;

  /// No description provided for @feedbackApplication.
  ///
  /// In ru, this message translates to:
  /// **'Приложение'**
  String get feedbackApplication;

  /// No description provided for @feedbackVersion.
  ///
  /// In ru, this message translates to:
  /// **'Версия'**
  String get feedbackVersion;

  /// No description provided for @feedbackPlatform.
  ///
  /// In ru, this message translates to:
  /// **'Платформа'**
  String get feedbackPlatform;

  /// No description provided for @feedbackMessageTooShort.
  ///
  /// In ru, this message translates to:
  /// **'Опиши проблему или предложение хотя бы в 10 символах'**
  String get feedbackMessageTooShort;

  /// No description provided for @feedbackLoginRequired.
  ///
  /// In ru, this message translates to:
  /// **'Для отправки обращения нужно войти в аккаунт'**
  String get feedbackLoginRequired;

  /// No description provided for @feedbackSent.
  ///
  /// In ru, this message translates to:
  /// **'Сообщение отправлено. Спасибо!'**
  String get feedbackSent;

  /// No description provided for @feedbackSendFailed.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось отправить сообщение'**
  String get feedbackSendFailed;

  /// No description provided for @feedbackPermissionDenied.
  ///
  /// In ru, this message translates to:
  /// **'Нет разрешения на отправку. Сообщи по почте о проблеме.'**
  String get feedbackPermissionDenied;

  /// No description provided for @logsDescription.
  ///
  /// In ru, this message translates to:
  /// **'Логи помогают найти причину ошибки в приложении.'**
  String get logsDescription;

  /// No description provided for @logsCollect.
  ///
  /// In ru, this message translates to:
  /// **'Собирать логи'**
  String get logsCollect;

  /// No description provided for @logsCollectDescription.
  ///
  /// In ru, this message translates to:
  /// **'Сбор выполняется только во время работы приложения.'**
  String get logsCollectDescription;

  /// No description provided for @logsCollected.
  ///
  /// In ru, this message translates to:
  /// **'Собранные логи'**
  String get logsCollected;

  /// No description provided for @logsEmpty.
  ///
  /// In ru, this message translates to:
  /// **'Логов пока нет'**
  String get logsEmpty;

  /// No description provided for @logsCopied.
  ///
  /// In ru, this message translates to:
  /// **'Логи скопированы'**
  String get logsCopied;

  /// No description provided for @logsCleared.
  ///
  /// In ru, this message translates to:
  /// **'Логи очищены'**
  String get logsCleared;

  /// No description provided for @logsShare.
  ///
  /// In ru, this message translates to:
  /// **'Поделиться'**
  String get logsShare;

  /// No description provided for @logsClear.
  ///
  /// In ru, this message translates to:
  /// **'Очистить'**
  String get logsClear;

  /// No description provided for @logsClearQuestion.
  ///
  /// In ru, this message translates to:
  /// **'Очистить логи?'**
  String get logsClearQuestion;

  /// No description provided for @logsClearExplanation.
  ///
  /// In ru, this message translates to:
  /// **'Все собранные за текущий запуск логи будут удалены.'**
  String get logsClearExplanation;

  /// No description provided for @logsShareSubject.
  ///
  /// In ru, this message translates to:
  /// **'Watcher — логи приложения'**
  String get logsShareSubject;

  /// No description provided for @logsShareHeader.
  ///
  /// In ru, this message translates to:
  /// **'Watcher — логи приложения'**
  String get logsShareHeader;

  /// No description provided for @settingCopy.
  ///
  /// In ru, this message translates to:
  /// **'Копировать'**
  String get settingCopy;

  /// No description provided for @settingCopied.
  ///
  /// In ru, this message translates to:
  /// **'Скопировано'**
  String get settingCopied;

  /// No description provided for @settingEdit.
  ///
  /// In ru, this message translates to:
  /// **'Изменить'**
  String get settingEdit;

  /// No description provided for @settingValueTooShort.
  ///
  /// In ru, this message translates to:
  /// **'Значение должно быть не короче 2 символов'**
  String get settingValueTooShort;

  /// No description provided for @settingChangesSaved.
  ///
  /// In ru, this message translates to:
  /// **'Изменения сохранены'**
  String get settingChangesSaved;

  /// No description provided for @settingSaveFailed.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось сохранить: {error}'**
  String settingSaveFailed(String error);

  /// No description provided for @updatesDescription.
  ///
  /// In ru, this message translates to:
  /// **'Проверка и установка новых версий Watcher.'**
  String get updatesDescription;

  /// No description provided for @updatesCurrentVersion.
  ///
  /// In ru, this message translates to:
  /// **'Текущая версия'**
  String get updatesCurrentVersion;

  /// No description provided for @updatesAvailable.
  ///
  /// In ru, this message translates to:
  /// **'Доступно обновление'**
  String get updatesAvailable;

  /// No description provided for @updatesNewVersion.
  ///
  /// In ru, this message translates to:
  /// **'Новая версия'**
  String get updatesNewVersion;

  /// No description provided for @updatesShowIndicator.
  ///
  /// In ru, this message translates to:
  /// **'Показывать индикатор обновления'**
  String get updatesShowIndicator;

  /// No description provided for @updatesIndicatorDescription.
  ///
  /// In ru, this message translates to:
  /// **'Красная точка появится на иконке профиля, когда будет доступна новая версия.'**
  String get updatesIndicatorDescription;

  /// No description provided for @updatesCheck.
  ///
  /// In ru, this message translates to:
  /// **'Проверить обновления'**
  String get updatesCheck;

  /// No description provided for @updatesWhatsNew.
  ///
  /// In ru, this message translates to:
  /// **'Что нового'**
  String get updatesWhatsNew;

  /// No description provided for @notificationsShowUpdate.
  ///
  /// In ru, this message translates to:
  /// **'Показывать уведомление об обновлении'**
  String get notificationsShowUpdate;

  /// No description provided for @notificationsShowUpdateDescription.
  ///
  /// In ru, this message translates to:
  /// **'Если выключено, красная точка на иконке профиля не будет появляться.'**
  String get notificationsShowUpdateDescription;

  /// No description provided for @logInstallPermissionCheckError.
  ///
  /// In ru, this message translates to:
  /// **'Ошибка проверки разрешения установки APK: {error}'**
  String logInstallPermissionCheckError(String error);

  /// No description provided for @logInstallSettingsOpenError.
  ///
  /// In ru, this message translates to:
  /// **'Ошибка открытия настроек установки APK: {error}'**
  String logInstallSettingsOpenError(String error);

  /// No description provided for @logMaintenanceCheckError.
  ///
  /// In ru, this message translates to:
  /// **'Ошибка проверки технических работ: {error}'**
  String logMaintenanceCheckError(String error);

  /// No description provided for @logApkDownloadStarted.
  ///
  /// In ru, this message translates to:
  /// **'Начато скачивание APK'**
  String get logApkDownloadStarted;

  /// No description provided for @logApkDownloaded.
  ///
  /// In ru, this message translates to:
  /// **'APK скачан'**
  String get logApkDownloaded;

  /// No description provided for @logApkUpdateError.
  ///
  /// In ru, this message translates to:
  /// **'Ошибка обновления: {error}'**
  String logApkUpdateError(String error);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ru':
      return AppLocalizationsRu();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
