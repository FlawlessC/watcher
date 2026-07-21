// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Watcher';

  @override
  String get language => 'Language';

  @override
  String get languageDescription => 'Application interface language';

  @override
  String get languageSystem => 'System default';

  @override
  String get languageRussian => 'Русский';

  @override
  String get languageEnglish => 'English';

  @override
  String get settings => 'Settings';

  @override
  String get account => 'Account';

  @override
  String get notifications => 'Notifications';

  @override
  String get updates => 'Updates';

  @override
  String get logs => 'Logs';

  @override
  String get feedback => 'Feedback';

  @override
  String get all => 'All';

  @override
  String get future => 'Future';

  @override
  String get present => 'Present';

  @override
  String get again => 'Again';

  @override
  String get past => 'Past';

  @override
  String get later => 'Later';

  @override
  String get search => 'Search...';

  @override
  String get filters => 'Filters';

  @override
  String get cancel => 'Cancel';

  @override
  String get close => 'Close';

  @override
  String get save => 'Save';

  @override
  String get delete => 'Delete';

  @override
  String get logout => 'Log out';

  @override
  String get whatsNew => 'What\'s new';

  @override
  String get nothingFound => 'Nothing found';

  @override
  String selectedCount(int count) {
    return 'Selected: $count';
  }

  @override
  String versionLabel(String version) {
    return 'Version $version';
  }

  @override
  String get updateApp => 'Update app';

  @override
  String get randomChoice => 'Random choice';

  @override
  String get random => 'Random';

  @override
  String get changeTheme => 'Change theme';

  @override
  String get showPast => 'Show past';

  @override
  String get showLater => 'Show later';

  @override
  String get deleteSelected => 'Delete';

  @override
  String selectedItems(int count) {
    return 'Selected: $count';
  }

  @override
  String get filtersDescription =>
      'You can select multiple categories at the same time.';

  @override
  String get showPastDescription =>
      'Include items from Past in the main lists and global search.';

  @override
  String get showLaterDescription =>
      'Include postponed items in the main lists and global search.';

  @override
  String get reset => 'Reset';

  @override
  String get apply => 'Apply';

  @override
  String get myLists => 'My lists';

  @override
  String get categories => 'Categories';

  @override
  String get noCategories => 'No categories yet';

  @override
  String get newList => 'New list';

  @override
  String get listNameHint => 'Name (for example, Books)';

  @override
  String get create => 'Create';

  @override
  String get deleteListTitle => 'Delete list?';

  @override
  String get deleteListDescription =>
      'The category will be deleted. Its items will remain, but this category will be removed from their tags.';

  @override
  String get categoryDeleted => 'Category deleted';

  @override
  String get categoryDeleteError => 'Failed to delete category';

  @override
  String get editList => 'Edit list';

  @override
  String get newName => 'New name';

  @override
  String errorWithDetails(String error) {
    return 'Error: $error';
  }

  @override
  String get editItem => 'Edit item';

  @override
  String get addItem => 'Add new item';

  @override
  String get title => 'Title';

  @override
  String get description => 'Description';

  @override
  String get currentProgress => 'Current';

  @override
  String get totalProgress => 'Total';

  @override
  String get progressOf => 'of';

  @override
  String get addToList => 'Add to list';

  @override
  String get mainList => 'Main list:';

  @override
  String get hideIn => 'Hide in:';

  @override
  String get noCategoriesHint =>
      'There are no categories yet. You can create them in the side menu.';

  @override
  String itemProgress(String current, String total, String unit) {
    return 'Progress: $current/$total $unit';
  }

  @override
  String get logoutTitle => 'Log out?';

  @override
  String get logoutDescription => 'Are you sure you want to log out?';

  @override
  String get installPermissionTitle => 'Permission required';

  @override
  String get installPermissionDescription =>
      'Allow installing APKs from Watcher to update the application.';

  @override
  String get openSettings => 'Open settings';

  @override
  String get updateAvailable => 'Update available';

  @override
  String get downloadingApk => 'Downloading APK...';

  @override
  String whatsNewInVersion(Object version) {
    return 'What\'s new in version $version';
  }

  @override
  String get releaseInfoUnavailable => 'Release information is unavailable.';

  @override
  String get releaseInfoLoadError => 'Failed to load release information';

  @override
  String get maintenanceUnavailable =>
      'Maintenance is in progress. Changes are temporarily unavailable.';

  @override
  String get apkUpdatesAndroidOnly =>
      'APK updates are available only on Android';

  @override
  String get latestVersionInstalled => 'The latest version is installed';

  @override
  String apkInstallerOpenError(String error) {
    return 'Failed to open the APK installer: $error';
  }

  @override
  String updateError(String error) {
    return 'Update error: $error';
  }

  @override
  String updateAvailableVersion(String version) {
    return 'Update $version is available';
  }

  @override
  String get update => 'Update';

  @override
  String bulkTagRemoved(String tag) {
    return 'The “$tag” tag was removed';
  }

  @override
  String bulkItemsMoved(String tag) {
    return 'Selected items were moved to “$tag”';
  }

  @override
  String get bulkChangeError => 'Failed to update the selected items';

  @override
  String get deleteSelectedItemsTitle => 'Delete selected items?';

  @override
  String deleteSelectedItemsDescription(int count) {
    return '$count items will be deleted. This action cannot be undone.';
  }

  @override
  String deletedItemsCount(int count) {
    return 'Items deleted: $count';
  }

  @override
  String get bulkDeleteError => 'Failed to delete the selected items';

  @override
  String get randomListEmpty =>
      'There are no matching items in the currently filtered list';

  @override
  String get howAboutThis => 'How about this?';

  @override
  String get untitled => 'Untitled';

  @override
  String get another => 'Another';

  @override
  String get maintenanceDefaultMessage => 'Maintenance is in progress';

  @override
  String get progressUnitEpisode => 'episode';

  @override
  String get progressUnitPage => 'pages';

  @override
  String get progressUnitChapter => 'chapters';

  @override
  String get progressUnitBook => 'book';

  @override
  String get progressUnitSeason => 'season';

  @override
  String get progressUnitHours => 'hours';

  @override
  String get progressUnitAchievements => 'achievements';

  @override
  String get progressUnitNone => 'no unit';

  @override
  String get settingsAccount => 'Account';

  @override
  String get settingsNotifications => 'Notifications';

  @override
  String get settingsLogs => 'Logs';

  @override
  String get settingsFeedback => 'Feedback';

  @override
  String get settingsUpdates => 'Updates';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get backToWatcher => 'Back to Watcher';

  @override
  String get openMenu => 'Open menu';

  @override
  String get back => 'Back';

  @override
  String get authWait => 'Please wait...';

  @override
  String get authEmail => 'Email';

  @override
  String get authPassword => 'Password';

  @override
  String get authRepeatPassword => 'Repeat password';

  @override
  String get authSignIn => 'Sign in';

  @override
  String get authSignInWithGoogle => 'Sign in with Google';

  @override
  String get authSignInWithEmail => 'Sign in with email';

  @override
  String get authContinueAsGuest => 'Continue as guest';

  @override
  String get authCreateAccount => 'Create account';

  @override
  String get authAlreadyHaveAccount => 'Already have an account';

  @override
  String get authForgotPassword => 'Forgot password?';

  @override
  String get authRecoveryEmail => 'Recovery email';

  @override
  String get authSending => 'Sending...';

  @override
  String get authSendEmail => 'Send email';

  @override
  String get authBackToSignIn => 'Back to sign in';

  @override
  String get authEnterEmailAndPassword => 'Enter your email and password';

  @override
  String get authEnterEmail => 'Enter your email';

  @override
  String get authPasswordsDoNotMatch => 'Passwords do not match';

  @override
  String get authPasswordResetEmailSent => 'Password reset email sent';

  @override
  String get authGoogleSignInFailed => 'Failed to sign in with Google';

  @override
  String get authGuestSignInFailed => 'Failed to continue as guest';

  @override
  String get authEmailSendFailed => 'Failed to send the email';

  @override
  String get authSignInFailed => 'Failed to sign in';

  @override
  String get authEmailAlreadyInUse => 'This email is already registered';

  @override
  String get authInvalidEmail => 'Invalid email address';

  @override
  String get authWeakPassword => 'The password is too weak';

  @override
  String get authUserNotFound => 'User not found';

  @override
  String get authWrongEmailOrPassword => 'Incorrect email or password';

  @override
  String get accountGuest => 'Guest';

  @override
  String get accountUnknownProvider => 'Unknown';

  @override
  String get accountUnnamed => 'Unnamed';

  @override
  String get accountUserNotFound => 'User not found';

  @override
  String accountLoadFailed(String error) {
    return 'Failed to load account: $error';
  }

  @override
  String get accountSignOutQuestion => 'Sign out?';

  @override
  String get accountSignOutConfirmation =>
      'Are you sure you want to sign out of your account?';

  @override
  String get accountSignOut => 'Sign out';

  @override
  String get accountDeleteQuestion => 'Delete account?';

  @override
  String get accountDeleteExplanation =>
      'The account will be disabled immediately, but permanently deleted only after 14 days.\n\nUntil then, it can be restored.';

  @override
  String get accountDelete => 'Delete';

  @override
  String get accountDeleteAccount => 'Delete account';

  @override
  String get accountMainInformation => 'Main information';

  @override
  String get accountPersonalData => 'Personal data';

  @override
  String get accountSecurity => 'Security';

  @override
  String get accountAuthorization => 'Authorization';

  @override
  String get accountWatcherId => 'Watcher ID';

  @override
  String get accountWatcherIdCopied => 'Watcher ID copied';

  @override
  String get accountLogin => 'Username';

  @override
  String get accountLoginCopied => 'Username copied';

  @override
  String get accountNickname => 'Nickname';

  @override
  String get accountChangeNicknameQuestion => 'Change nickname?';

  @override
  String get accountChangeNicknameExplanation =>
      'The new nickname will be displayed in the app.';

  @override
  String get accountChangeEmailQuestion => 'Change email?';

  @override
  String get accountChangeEmailExplanation =>
      'The email will be changed in the profile. Updating Firebase Auth will be added separately.';

  @override
  String get accountPassword => 'Password';

  @override
  String get accountChangePassword => 'Change password';

  @override
  String get accountPasswordEmailOnly => 'Available for email accounts';

  @override
  String get accountPasswordComingSoon =>
      'Password changes will be added later';

  @override
  String get accountActiveDevices => 'Active devices';

  @override
  String get accountActiveDevicesComingSoon =>
      'Active devices will be added later';

  @override
  String get accountTwoFactorProtection => 'Two-factor authentication';

  @override
  String get accountTwoFactorComingSoon =>
      'Two-factor authentication will be added later';

  @override
  String get accountComingSoon => 'Coming later';

  @override
  String get accountSignInType => 'Sign-in method';

  @override
  String get accountLinkGoogle => 'Link Google';

  @override
  String get accountLinkGoogleComingSoon =>
      'Linking Google will be added later';

  @override
  String get accountLinkEmail => 'Link Email';

  @override
  String get accountLinkEmailComingSoon => 'Linking Email will be added later';

  @override
  String get feedbackTitle => 'Feedback';

  @override
  String get feedbackSubtitle =>
      'Report a bug or suggest an improvement for Watcher.';

  @override
  String get feedbackType => 'Feedback type';

  @override
  String get feedbackBug => 'Bug';

  @override
  String get feedbackImprovement => 'Suggestion';

  @override
  String get feedbackOther => 'Other';

  @override
  String get feedbackDescription => 'Description';

  @override
  String get feedbackDescriptionHint =>
      'What happened, what did you expect, and how can it be reproduced?';

  @override
  String get feedbackSend => 'Send';

  @override
  String get feedbackSending => 'Sending...';

  @override
  String get feedbackTechnicalInformation => 'Technical information';

  @override
  String get feedbackCopy => 'Copy';

  @override
  String get feedbackCopied => 'Copied';

  @override
  String get feedbackLoading => 'Loading...';

  @override
  String get feedbackLoadFailed => 'Failed to retrieve information';

  @override
  String get feedbackApplication => 'Application';

  @override
  String get feedbackVersion => 'Version';

  @override
  String get feedbackPlatform => 'Platform';

  @override
  String get feedbackMessageTooShort =>
      'Please describe the issue or suggestion using at least 10 characters.';

  @override
  String get feedbackLoginRequired => 'You must be signed in to send feedback.';

  @override
  String get feedbackSent => 'Message sent. Thank you!';

  @override
  String get feedbackSendFailed => 'Failed to send the message';

  @override
  String get feedbackPermissionDenied =>
      'Permission denied. Please report the issue by email.';

  @override
  String get logsDescription =>
      'Logs help identify the cause of errors in the application.';

  @override
  String get logsCollect => 'Collect logs';

  @override
  String get logsCollectDescription =>
      'Logs are collected only while the application is running.';

  @override
  String get logsCollected => 'Collected logs';

  @override
  String get logsEmpty => 'No logs yet';

  @override
  String get logsCopied => 'Logs copied';

  @override
  String get logsCleared => 'Logs cleared';

  @override
  String get logsShare => 'Share';

  @override
  String get logsClear => 'Clear';

  @override
  String get logsClearQuestion => 'Clear logs?';

  @override
  String get logsClearExplanation =>
      'All logs collected during the current session will be deleted.';

  @override
  String get logsShareSubject => 'Watcher — application logs';

  @override
  String get logsShareHeader => 'Watcher — application logs';

  @override
  String get settingCopy => 'Copy';

  @override
  String get settingCopied => 'Copied';

  @override
  String get settingEdit => 'Edit';

  @override
  String get settingValueTooShort =>
      'The value must contain at least 2 characters';

  @override
  String get settingChangesSaved => 'Changes saved';

  @override
  String settingSaveFailed(String error) {
    return 'Failed to save: $error';
  }

  @override
  String get updatesDescription =>
      'Check for and install new versions of Watcher.';

  @override
  String get updatesCurrentVersion => 'Current version';

  @override
  String get updatesAvailable => 'Update available';

  @override
  String get updatesNewVersion => 'New version';

  @override
  String get updatesShowIndicator => 'Show update indicator';

  @override
  String get updatesIndicatorDescription =>
      'A red dot will appear on the profile icon when a new version is available.';

  @override
  String get updatesCheck => 'Check for updates';

  @override
  String get updatesWhatsNew => 'What\'s new';

  @override
  String get notificationsShowUpdate => 'Show update notification';

  @override
  String get notificationsShowUpdateDescription =>
      'When disabled, the red dot will not appear on the profile icon.';

  @override
  String logInstallPermissionCheckError(String error) {
    return 'Failed to check APK installation permission: $error';
  }

  @override
  String logInstallSettingsOpenError(String error) {
    return 'Failed to open APK installation settings: $error';
  }

  @override
  String logMaintenanceCheckError(String error) {
    return 'Failed to check maintenance mode: $error';
  }

  @override
  String get logApkDownloadStarted => 'APK download started';

  @override
  String get logApkDownloaded => 'APK downloaded';

  @override
  String logApkUpdateError(String error) {
    return 'Update failed: $error';
  }
}
