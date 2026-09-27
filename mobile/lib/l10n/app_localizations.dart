import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

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
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Zaytona'**
  String get appTitle;

  /// No description provided for @joinGroupTitle.
  ///
  /// In en, this message translates to:
  /// **'Join a group'**
  String get joinGroupTitle;

  /// No description provided for @inviteCodeLabel.
  ///
  /// In en, this message translates to:
  /// **'Invite code'**
  String get inviteCodeLabel;

  /// No description provided for @inviteCodeHint.
  ///
  /// In en, this message translates to:
  /// **'Invite code'**
  String get inviteCodeHint;

  /// No description provided for @inviteCodeRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter the invite code first'**
  String get inviteCodeRequired;

  /// No description provided for @joinAction.
  ///
  /// In en, this message translates to:
  /// **'Join'**
  String get joinAction;

  /// No description provided for @copyAction.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get copyAction;

  /// No description provided for @inviteCodeCopied.
  ///
  /// In en, this message translates to:
  /// **'Invite code copied'**
  String get inviteCodeCopied;

  /// No description provided for @inviteLinkCopied.
  ///
  /// In en, this message translates to:
  /// **'Invite link copied'**
  String get inviteLinkCopied;

  /// No description provided for @newListTitle.
  ///
  /// In en, this message translates to:
  /// **'New list'**
  String get newListTitle;

  /// No description provided for @listNameLabel.
  ///
  /// In en, this message translates to:
  /// **'List name'**
  String get listNameLabel;

  /// No description provided for @listColorLabel.
  ///
  /// In en, this message translates to:
  /// **'List color'**
  String get listColorLabel;

  /// No description provided for @listNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Weekend run'**
  String get listNameHint;

  /// No description provided for @createListAction.
  ///
  /// In en, this message translates to:
  /// **'Create list'**
  String get createListAction;

  /// No description provided for @listsTab.
  ///
  /// In en, this message translates to:
  /// **'Lists'**
  String get listsTab;

  /// No description provided for @noListsYet.
  ///
  /// In en, this message translates to:
  /// **'No lists yet'**
  String get noListsYet;

  /// No description provided for @noListsYetBody.
  ///
  /// In en, this message translates to:
  /// **'Lists you create for this group will show up here.'**
  String get noListsYetBody;

  /// No description provided for @listCompletedBadge.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get listCompletedBadge;

  /// No description provided for @listItemCount.
  ///
  /// In en, this message translates to:
  /// **'{count} items'**
  String listItemCount(int count);

  /// No description provided for @retryAction.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get retryAction;

  /// No description provided for @signupTitle.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get signupTitle;

  /// No description provided for @signupSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Join your family on Zaytona'**
  String get signupSubtitle;

  /// No description provided for @firstNameLabel.
  ///
  /// In en, this message translates to:
  /// **'First name'**
  String get firstNameLabel;

  /// No description provided for @lastNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Last name'**
  String get lastNameLabel;

  /// No description provided for @phoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get phoneLabel;

  /// No description provided for @phoneHint.
  ///
  /// In en, this message translates to:
  /// **'05X XXX XXXX'**
  String get phoneHint;

  /// No description provided for @emailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email (optional)'**
  String get emailLabel;

  /// No description provided for @signupAction.
  ///
  /// In en, this message translates to:
  /// **'Sign up'**
  String get signupAction;

  /// No description provided for @alreadyHaveAccountPrompt.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHaveAccountPrompt;

  /// No description provided for @loginAction.
  ///
  /// In en, this message translates to:
  /// **'Log in'**
  String get loginAction;

  /// No description provided for @fieldRequired.
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get fieldRequired;

  /// No description provided for @nameTooShort.
  ///
  /// In en, this message translates to:
  /// **'At least 2 characters'**
  String get nameTooShort;

  /// No description provided for @phoneInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid phone number'**
  String get phoneInvalid;

  /// No description provided for @emailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address'**
  String get emailInvalid;

  /// No description provided for @appTagline.
  ///
  /// In en, this message translates to:
  /// **'The family\'s shared list'**
  String get appTagline;

  /// No description provided for @welcomeTagline.
  ///
  /// In en, this message translates to:
  /// **'Zaytona brings you together'**
  String get welcomeTagline;

  /// No description provided for @noAccountPrompt.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get noAccountPrompt;

  /// No description provided for @welcomeSignupCta.
  ///
  /// In en, this message translates to:
  /// **'Sign up'**
  String get welcomeSignupCta;

  /// No description provided for @otpTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter the code'**
  String get otpTitle;

  /// No description provided for @otpSubtitle.
  ///
  /// In en, this message translates to:
  /// **'We sent a 4-digit code to {phone}'**
  String otpSubtitle(String phone);

  /// No description provided for @otpSubtitleWhatsapp.
  ///
  /// In en, this message translates to:
  /// **'We sent a 4-digit code to {phone} via WhatsApp'**
  String otpSubtitleWhatsapp(String phone);

  /// No description provided for @otpResendCountdown.
  ///
  /// In en, this message translates to:
  /// **'Resend in {seconds} seconds'**
  String otpResendCountdown(int seconds);

  /// No description provided for @otpResendAction.
  ///
  /// In en, this message translates to:
  /// **'Resend code'**
  String get otpResendAction;

  /// No description provided for @otpResending.
  ///
  /// In en, this message translates to:
  /// **'Sending...'**
  String get otpResending;

  /// No description provided for @otpResent.
  ///
  /// In en, this message translates to:
  /// **'A new code was sent'**
  String get otpResent;

  /// No description provided for @otpConfirmAction.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get otpConfirmAction;

  /// No description provided for @otpResendVia.
  ///
  /// In en, this message translates to:
  /// **'Didn\'t get the code? Resend via:'**
  String get otpResendVia;

  /// No description provided for @otpChannelWhatsapp.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp'**
  String get otpChannelWhatsapp;

  /// No description provided for @otpChannelSms.
  ///
  /// In en, this message translates to:
  /// **'SMS'**
  String get otpChannelSms;

  /// No description provided for @otpChannelEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get otpChannelEmail;

  /// No description provided for @otpResendLimitReached.
  ///
  /// In en, this message translates to:
  /// **'Resend attempts used up — try again later'**
  String get otpResendLimitReached;

  /// No description provided for @editPhoneNumberAction.
  ///
  /// In en, this message translates to:
  /// **'Edit number'**
  String get editPhoneNumberAction;

  /// No description provided for @otpEmailFallback.
  ///
  /// In en, this message translates to:
  /// **'Send via email ({email}) — coming soon'**
  String otpEmailFallback(String email);

  /// No description provided for @otpNoEmailFallback.
  ///
  /// In en, this message translates to:
  /// **'No email registered for fallback sending'**
  String get otpNoEmailFallback;

  /// No description provided for @drawerJoinGroup.
  ///
  /// In en, this message translates to:
  /// **'Join a group'**
  String get drawerJoinGroup;

  /// No description provided for @drawerCreateGroup.
  ///
  /// In en, this message translates to:
  /// **'Create a group'**
  String get drawerCreateGroup;

  /// No description provided for @drawerMyGroups.
  ///
  /// In en, this message translates to:
  /// **'My groups'**
  String get drawerMyGroups;

  /// No description provided for @drawerSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings & account'**
  String get drawerSettings;

  /// No description provided for @memberCount.
  ///
  /// In en, this message translates to:
  /// **'{count} members'**
  String memberCount(int count);

  /// No description provided for @urgentCount.
  ///
  /// In en, this message translates to:
  /// **'{count} urgent'**
  String urgentCount(int count);

  /// No description provided for @allCategories.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get allCategories;

  /// No description provided for @noItemsTitle.
  ///
  /// In en, this message translates to:
  /// **'No items yet'**
  String get noItemsTitle;

  /// No description provided for @noItemsBody.
  ///
  /// In en, this message translates to:
  /// **'Add the first item to start building this list with the group.'**
  String get noItemsBody;

  /// No description provided for @nothingInCategory.
  ///
  /// In en, this message translates to:
  /// **'Nothing in this category.'**
  String get nothingInCategory;

  /// No description provided for @noResultsTitle.
  ///
  /// In en, this message translates to:
  /// **'No results'**
  String get noResultsTitle;

  /// No description provided for @clearFilterAction.
  ///
  /// In en, this message translates to:
  /// **'Clear filter'**
  String get clearFilterAction;

  /// No description provided for @startTrip.
  ///
  /// In en, this message translates to:
  /// **'Start trip'**
  String get startTrip;

  /// No description provided for @addItemAction.
  ///
  /// In en, this message translates to:
  /// **'Add item'**
  String get addItemAction;

  /// No description provided for @manualEntryTitle.
  ///
  /// In en, this message translates to:
  /// **'Manual entry'**
  String get manualEntryTitle;

  /// No description provided for @editItemTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit item'**
  String get editItemTitle;

  /// No description provided for @howToAddHead.
  ///
  /// In en, this message translates to:
  /// **'How to add'**
  String get howToAddHead;

  /// No description provided for @methodManual.
  ///
  /// In en, this message translates to:
  /// **'Manual'**
  String get methodManual;

  /// No description provided for @methodBarcode.
  ///
  /// In en, this message translates to:
  /// **'Scan barcode'**
  String get methodBarcode;

  /// No description provided for @methodPhoto.
  ///
  /// In en, this message translates to:
  /// **'Photo scan'**
  String get methodPhoto;

  /// No description provided for @soonBadge.
  ///
  /// In en, this message translates to:
  /// **'soon'**
  String get soonBadge;

  /// No description provided for @itemNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get itemNameLabel;

  /// No description provided for @itemNameHint.
  ///
  /// In en, this message translates to:
  /// **'What do we need?'**
  String get itemNameHint;

  /// No description provided for @itemBrandLabel.
  ///
  /// In en, this message translates to:
  /// **'Brand (optional)'**
  String get itemBrandLabel;

  /// No description provided for @itemBrandHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Almarai'**
  String get itemBrandHint;

  /// No description provided for @itemNoteLabel.
  ///
  /// In en, this message translates to:
  /// **'Note (optional)'**
  String get itemNoteLabel;

  /// No description provided for @itemNoteHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Full fat'**
  String get itemNoteHint;

  /// No description provided for @categoryLabel.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get categoryLabel;

  /// No description provided for @categorySearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search a category…'**
  String get categorySearchHint;

  /// No description provided for @quantityLabel.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get quantityLabel;

  /// No description provided for @extraDetailsLabel.
  ///
  /// In en, this message translates to:
  /// **'Extra details?'**
  String get extraDetailsLabel;

  /// No description provided for @markUrgent.
  ///
  /// In en, this message translates to:
  /// **'Mark as urgent'**
  String get markUrgent;

  /// No description provided for @addToListAction.
  ///
  /// In en, this message translates to:
  /// **'Add to list'**
  String get addToListAction;

  /// No description provided for @saveChangesAction.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get saveChangesAction;

  /// No description provided for @newGroupTitle.
  ///
  /// In en, this message translates to:
  /// **'New group'**
  String get newGroupTitle;

  /// No description provided for @editGroupTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit group'**
  String get editGroupTitle;

  /// No description provided for @groupNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Group name is required'**
  String get groupNameRequired;

  /// No description provided for @groupUpdateError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t update the group. Try again.'**
  String get groupUpdateError;

  /// No description provided for @groupNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Group name'**
  String get groupNameLabel;

  /// No description provided for @groupNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. The Otaibis'**
  String get groupNameHint;

  /// Placeholder in the group name field, personalized with the signed-in user's own last name
  ///
  /// In en, this message translates to:
  /// **'e.g. The {lastName} Family'**
  String groupNameHintPersonalized(String lastName);

  /// No description provided for @groupIconLabel.
  ///
  /// In en, this message translates to:
  /// **'Icon'**
  String get groupIconLabel;

  /// No description provided for @createGroupAction.
  ///
  /// In en, this message translates to:
  /// **'Create group'**
  String get createGroupAction;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Account settings'**
  String get settingsTitle;

  /// No description provided for @languageLabel.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageLabel;

  /// No description provided for @arabicLanguage.
  ///
  /// In en, this message translates to:
  /// **'العربية'**
  String get arabicLanguage;

  /// No description provided for @englishLanguage.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get englishLanguage;

  /// No description provided for @logoutAction.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get logoutAction;

  /// No description provided for @buyingModeLabel.
  ///
  /// In en, this message translates to:
  /// **'Buying mode'**
  String get buyingModeLabel;

  /// No description provided for @showAllFilter.
  ///
  /// In en, this message translates to:
  /// **'Show all'**
  String get showAllFilter;

  /// No description provided for @urgentFilter.
  ///
  /// In en, this message translates to:
  /// **'Urgent'**
  String get urgentFilter;

  /// No description provided for @urgentBadge.
  ///
  /// In en, this message translates to:
  /// **'Urgent'**
  String get urgentBadge;

  /// No description provided for @finishTrip.
  ///
  /// In en, this message translates to:
  /// **'Finish shopping'**
  String get finishTrip;

  /// No description provided for @completeTripTitle.
  ///
  /// In en, this message translates to:
  /// **'Finish this trip?'**
  String get completeTripTitle;

  /// No description provided for @completeTripBody.
  ///
  /// In en, this message translates to:
  /// **'Bought items move to trip history. Anything left unchecked stays on the list for next time.'**
  String get completeTripBody;

  /// No description provided for @tripSummaryCounts.
  ///
  /// In en, this message translates to:
  /// **'{bought} bought · {remaining} left for next time'**
  String tripSummaryCounts(int bought, int remaining);

  /// No description provided for @tripInProgressByOther.
  ///
  /// In en, this message translates to:
  /// **'Someone\'s shopping right now'**
  String get tripInProgressByOther;

  /// No description provided for @noActiveTripError.
  ///
  /// In en, this message translates to:
  /// **'This trip couldn\'t be found. It may have already ended.'**
  String get noActiveTripError;

  /// No description provided for @backToGroupAction.
  ///
  /// In en, this message translates to:
  /// **'Back to group'**
  String get backToGroupAction;

  /// No description provided for @confirmAction.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirmAction;

  /// No description provided for @cancelAction.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelAction;

  /// No description provided for @privateBadge.
  ///
  /// In en, this message translates to:
  /// **'Private'**
  String get privateBadge;

  /// No description provided for @adminBadge.
  ///
  /// In en, this message translates to:
  /// **'Admin'**
  String get adminBadge;

  /// No description provided for @memberBadge.
  ///
  /// In en, this message translates to:
  /// **'Member'**
  String get memberBadge;

  /// No description provided for @privateSpaceLine.
  ///
  /// In en, this message translates to:
  /// **'Your private space · just you'**
  String get privateSpaceLine;

  /// No description provided for @groupMembersCount.
  ///
  /// In en, this message translates to:
  /// **'{count} members'**
  String groupMembersCount(int count);

  /// No description provided for @boughtOfTotal.
  ///
  /// In en, this message translates to:
  /// **'{bought} of {total} bought'**
  String boughtOfTotal(int bought, int total);

  /// No description provided for @completedListsSection.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completedListsSection;

  /// No description provided for @possibleDuplicateTitle.
  ///
  /// In en, this message translates to:
  /// **'Possible duplicate'**
  String get possibleDuplicateTitle;

  /// No description provided for @possibleDuplicateBody.
  ///
  /// In en, this message translates to:
  /// **'\"{name}\" is already on this list.'**
  String possibleDuplicateBody(String name);

  /// No description provided for @notifyAction.
  ///
  /// In en, this message translates to:
  /// **'Notify'**
  String get notifyAction;

  /// No description provided for @historyAction.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get historyAction;

  /// No description provided for @historyActivityEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No activity yet'**
  String get historyActivityEmptyTitle;

  /// No description provided for @historyActivityEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Actions taken on this list\'s items will show up here.'**
  String get historyActivityEmptyBody;

  /// No description provided for @historyNoTripsTitle.
  ///
  /// In en, this message translates to:
  /// **'Previous rounds'**
  String get historyNoTripsTitle;

  /// No description provided for @historyNoTripsBody.
  ///
  /// In en, this message translates to:
  /// **'This list\'s shopping rounds will show up here after the first trip is finished.'**
  String get historyNoTripsBody;

  /// No description provided for @historyTabActivity.
  ///
  /// In en, this message translates to:
  /// **'Activity log'**
  String get historyTabActivity;

  /// No description provided for @historyTabTrips.
  ///
  /// In en, this message translates to:
  /// **'Trips'**
  String get historyTabTrips;

  /// No description provided for @undoAction.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undoAction;

  /// No description provided for @historyTimeJustNow.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get historyTimeJustNow;

  /// No description provided for @historyTimeMinutesAgo.
  ///
  /// In en, this message translates to:
  /// **'{minutes, plural, =1{A minute ago} =2{Two minutes ago} other{{minutes} minutes ago}}'**
  String historyTimeMinutesAgo(int minutes);

  /// No description provided for @historyTimeHoursAgo.
  ///
  /// In en, this message translates to:
  /// **'{hours, plural, =1{An hour ago} =2{Two hours ago} other{{hours} hours ago}}'**
  String historyTimeHoursAgo(int hours);

  /// No description provided for @historyTimeYesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get historyTimeYesterday;

  /// No description provided for @historyTimeDaysAgo.
  ///
  /// In en, this message translates to:
  /// **'{days, plural, =2{Two days ago} other{{days} days ago}}'**
  String historyTimeDaysAgo(int days);

  /// No description provided for @deleteItemConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove this item?'**
  String get deleteItemConfirmTitle;

  /// No description provided for @deleteItemConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'\"{name}\" will be removed from the list.'**
  String deleteItemConfirmBody(String name);

  /// No description provided for @deleteListConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete this list?'**
  String get deleteListConfirmTitle;

  /// No description provided for @deleteListConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'\"{name}\" will be permanently deleted.'**
  String deleteListConfirmBody(String name);

  /// No description provided for @listSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'List settings'**
  String get listSettingsTitle;

  /// No description provided for @listMenuAction.
  ///
  /// In en, this message translates to:
  /// **'List menu'**
  String get listMenuAction;

  /// No description provided for @deleteAllItemsAction.
  ///
  /// In en, this message translates to:
  /// **'Delete all items'**
  String get deleteAllItemsAction;

  /// No description provided for @deleteAllAction.
  ///
  /// In en, this message translates to:
  /// **'Delete all'**
  String get deleteAllAction;

  /// No description provided for @deleteAllItemsConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete all items?'**
  String get deleteAllItemsConfirmTitle;

  /// No description provided for @deleteAllItemsConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'{count} items will be removed from the list.'**
  String deleteAllItemsConfirmBody(int count);

  /// No description provided for @listDeletedMessage.
  ///
  /// In en, this message translates to:
  /// **'\"{name}\" was deleted'**
  String listDeletedMessage(String name);

  /// No description provided for @listDeleteFailedMessage.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t delete the list'**
  String get listDeleteFailedMessage;

  /// No description provided for @catalogTitle.
  ///
  /// In en, this message translates to:
  /// **'Add item'**
  String get catalogTitle;

  /// No description provided for @catalogSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search for an item'**
  String get catalogSearchHint;

  /// No description provided for @attachPhotoLabel.
  ///
  /// In en, this message translates to:
  /// **'Attach photo'**
  String get attachPhotoLabel;

  /// No description provided for @cameraSourceLabel.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get cameraSourceLabel;

  /// No description provided for @gallerySourceLabel.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get gallerySourceLabel;

  /// No description provided for @removePhotoLabel.
  ///
  /// In en, this message translates to:
  /// **'Remove photo'**
  String get removePhotoLabel;

  /// No description provided for @myItemsHead.
  ///
  /// In en, this message translates to:
  /// **'My items'**
  String get myItemsHead;

  /// No description provided for @addManuallyAction.
  ///
  /// In en, this message translates to:
  /// **'Add manually'**
  String get addManuallyAction;

  /// No description provided for @itemAddedMessage.
  ///
  /// In en, this message translates to:
  /// **'\"{name}\" added'**
  String itemAddedMessage(String name);

  /// No description provided for @itemQuantityIncreasedMessage.
  ///
  /// In en, this message translates to:
  /// **'\"{name}\" quantity increased to {qty}'**
  String itemQuantityIncreasedMessage(String name, int qty);

  /// No description provided for @quickAddLabel.
  ///
  /// In en, this message translates to:
  /// **'Quick add'**
  String get quickAddLabel;

  /// No description provided for @addAction.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get addAction;

  /// No description provided for @addedLabel.
  ///
  /// In en, this message translates to:
  /// **'Added'**
  String get addedLabel;

  /// No description provided for @catalogEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Your catalog is empty'**
  String get catalogEmptyTitle;

  /// No description provided for @catalogEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Add your first item to start building your personal catalog.'**
  String get catalogEmptyBody;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get loginTitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get loginSubtitle;

  /// No description provided for @loginIdentifierHint.
  ///
  /// In en, this message translates to:
  /// **'Phone or email'**
  String get loginIdentifierHint;

  /// No description provided for @loginChecking.
  ///
  /// In en, this message translates to:
  /// **'Checking…'**
  String get loginChecking;

  /// No description provided for @sendCodeAction.
  ///
  /// In en, this message translates to:
  /// **'Send code'**
  String get sendCodeAction;

  /// No description provided for @createAccountAction.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get createAccountAction;

  /// No description provided for @inviteMembersTitle.
  ///
  /// In en, this message translates to:
  /// **'Invite members'**
  String get inviteMembersTitle;

  /// No description provided for @backAction.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get backAction;

  /// No description provided for @shareInviteLink.
  ///
  /// In en, this message translates to:
  /// **'Share invite link'**
  String get shareInviteLink;

  /// No description provided for @joinedMembersSection.
  ///
  /// In en, this message translates to:
  /// **'Members ({count})'**
  String joinedMembersSection(int count);

  /// No description provided for @nobodyJoinedYet.
  ///
  /// In en, this message translates to:
  /// **'No one joined yet — share the code or link'**
  String get nobodyJoinedYet;

  /// No description provided for @nobodyJoinedYetBody.
  ///
  /// In en, this message translates to:
  /// **'Invited members haven\'t opened the link yet.'**
  String get nobodyJoinedYetBody;

  /// No description provided for @doneAction.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get doneAction;

  /// No description provided for @groupSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Group settings'**
  String get groupSettingsTitle;

  /// No description provided for @groupIdentitySection.
  ///
  /// In en, this message translates to:
  /// **'Group identity'**
  String get groupIdentitySection;

  /// No description provided for @membersSection.
  ///
  /// In en, this message translates to:
  /// **'Members'**
  String get membersSection;

  /// No description provided for @dangerZoneSection.
  ///
  /// In en, this message translates to:
  /// **'Danger zone'**
  String get dangerZoneSection;

  /// No description provided for @youSuffix.
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get youSuffix;

  /// No description provided for @saveAction.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get saveAction;

  /// No description provided for @changesSaved.
  ///
  /// In en, this message translates to:
  /// **'Changes saved'**
  String get changesSaved;

  /// No description provided for @makeAdminAction.
  ///
  /// In en, this message translates to:
  /// **'Make admin'**
  String get makeAdminAction;

  /// No description provided for @removeMemberAction.
  ///
  /// In en, this message translates to:
  /// **'Remove from group'**
  String get removeMemberAction;

  /// No description provided for @memberActionsLabel.
  ///
  /// In en, this message translates to:
  /// **'Member actions'**
  String get memberActionsLabel;

  /// No description provided for @transferAdminConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Transfer admin role?'**
  String get transferAdminConfirmTitle;

  /// No description provided for @transferAdminConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'{name} becomes the group\'s only admin and you lose admin privileges.'**
  String transferAdminConfirmBody(String name);

  /// No description provided for @removeMemberConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove {name}?'**
  String removeMemberConfirmTitle(String name);

  /// No description provided for @removeMemberConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'They lose access to this group\'s lists.'**
  String get removeMemberConfirmBody;

  /// No description provided for @deleteGroupTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete group'**
  String get deleteGroupTitle;

  /// No description provided for @deleteGroupBody.
  ///
  /// In en, this message translates to:
  /// **'Permanently removes all lists for everyone.'**
  String get deleteGroupBody;

  /// No description provided for @deleteGroupConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete this group?'**
  String get deleteGroupConfirmTitle;

  /// No description provided for @deleteGroupConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'This can\'t be undone.'**
  String get deleteGroupConfirmBody;

  /// No description provided for @deleteAction.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteAction;

  /// No description provided for @leaveGroupTitle.
  ///
  /// In en, this message translates to:
  /// **'Leave group'**
  String get leaveGroupTitle;

  /// No description provided for @leaveGroupBody.
  ///
  /// In en, this message translates to:
  /// **'You\'ll lose access to this group\'s lists.'**
  String get leaveGroupBody;

  /// No description provided for @leaveGroupConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Leave this group?'**
  String get leaveGroupConfirmTitle;

  /// No description provided for @leaveGroupConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'You can re-join later with the invite code.'**
  String get leaveGroupConfirmBody;

  /// No description provided for @leaveAction.
  ///
  /// In en, this message translates to:
  /// **'Leave'**
  String get leaveAction;

  /// No description provided for @privateGroupBannerTitle.
  ///
  /// In en, this message translates to:
  /// **'Your private group'**
  String get privateGroupBannerTitle;

  /// No description provided for @privateGroupBannerBody.
  ///
  /// In en, this message translates to:
  /// **'Only you can see it. No members to invite, and it can\'t be deleted.'**
  String get privateGroupBannerBody;

  /// No description provided for @chooseAvatarTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose your avatar'**
  String get chooseAvatarTitle;

  /// No description provided for @chooseAvatarBody.
  ///
  /// In en, this message translates to:
  /// **'It shows next to the items you add for the group.'**
  String get chooseAvatarBody;

  /// No description provided for @continueAction.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueAction;

  /// No description provided for @firstGroupTitle.
  ///
  /// In en, this message translates to:
  /// **'Start with a group'**
  String get firstGroupTitle;

  /// No description provided for @firstGroupBody.
  ///
  /// In en, this message translates to:
  /// **'Create one for your family, or join with an invite code. You already have your own private group.'**
  String get firstGroupBody;

  /// No description provided for @createFamilyGroupAction.
  ///
  /// In en, this message translates to:
  /// **'Create a family group'**
  String get createFamilyGroupAction;

  /// No description provided for @joinWithCodeAction.
  ///
  /// In en, this message translates to:
  /// **'Join with a code'**
  String get joinWithCodeAction;

  /// No description provided for @skipForNowAction.
  ///
  /// In en, this message translates to:
  /// **'Skip for now'**
  String get skipForNowAction;

  /// No description provided for @avatarsLoadError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load avatars'**
  String get avatarsLoadError;

  /// No description provided for @avatarSelectError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t save your avatar'**
  String get avatarSelectError;

  /// No description provided for @tipsTitle.
  ///
  /// In en, this message translates to:
  /// **'4 things before you dive in'**
  String get tipsTitle;

  /// No description provided for @tipDrawerTitle.
  ///
  /// In en, this message translates to:
  /// **'The drawer'**
  String get tipDrawerTitle;

  /// No description provided for @tipDrawerBody.
  ///
  /// In en, this message translates to:
  /// **'All your groups live in there — swipe or tap the logo and peek in'**
  String get tipDrawerBody;

  /// No description provided for @tipPersonalGroupTitle.
  ///
  /// In en, this message translates to:
  /// **'Your personal group'**
  String get tipPersonalGroupTitle;

  /// No description provided for @tipPersonalGroupBody.
  ///
  /// In en, this message translates to:
  /// **'This one\'s just for you — nobody\'s crashing this party, no matter how hard they try'**
  String get tipPersonalGroupBody;

  /// No description provided for @tipCreateListTitle.
  ///
  /// In en, this message translates to:
  /// **'The \"create list\" button'**
  String get tipCreateListTitle;

  /// No description provided for @tipCreateListBody.
  ///
  /// In en, this message translates to:
  /// **'Tap it and start a fresh list before someone \"forgets\" what they need'**
  String get tipCreateListBody;

  /// No description provided for @tipGroupSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Group settings'**
  String get tipGroupSettingsTitle;

  /// No description provided for @tipGroupSettingsBody.
  ///
  /// In en, this message translates to:
  /// **'Rename it, re-icon it, or see who\'s actually in the group with you'**
  String get tipGroupSettingsBody;

  /// No description provided for @letsGoAction.
  ///
  /// In en, this message translates to:
  /// **'Let\'s go'**
  String get letsGoAction;

  /// No description provided for @tripAlertsTitle.
  ///
  /// In en, this message translates to:
  /// **'Trip alerts'**
  String get tripAlertsTitle;

  /// No description provided for @headingToStoreTitle.
  ///
  /// In en, this message translates to:
  /// **'I\'m heading to the store'**
  String get headingToStoreTitle;

  /// No description provided for @headingToStoreBody.
  ///
  /// In en, this message translates to:
  /// **'Nudge everyone to add their last items'**
  String get headingToStoreBody;

  /// No description provided for @notifyGroupAction.
  ///
  /// In en, this message translates to:
  /// **'Notify group'**
  String get notifyGroupAction;

  /// No description provided for @assignBuyerTitle.
  ///
  /// In en, this message translates to:
  /// **'Assign a buyer'**
  String get assignBuyerTitle;

  /// No description provided for @assignBuyerBody.
  ///
  /// In en, this message translates to:
  /// **'Pick who shops this trip'**
  String get assignBuyerBody;

  /// No description provided for @chooseMemberAction.
  ///
  /// In en, this message translates to:
  /// **'Choose member'**
  String get chooseMemberAction;

  /// No description provided for @changeMemberAction.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get changeMemberAction;

  /// No description provided for @remindMemberTitle.
  ///
  /// In en, this message translates to:
  /// **'Remind someone'**
  String get remindMemberTitle;

  /// No description provided for @remindMemberBody.
  ///
  /// In en, this message translates to:
  /// **'Remind a member to add their items'**
  String get remindMemberBody;

  /// No description provided for @remindMemberSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Remind member'**
  String get remindMemberSheetTitle;

  /// No description provided for @noMembersToNotifyTitle.
  ///
  /// In en, this message translates to:
  /// **'No members yet'**
  String get noMembersToNotifyTitle;

  /// No description provided for @noMembersToNotifyBody.
  ///
  /// In en, this message translates to:
  /// **'Invite someone to the group before you can notify them.'**
  String get noMembersToNotifyBody;

  /// No description provided for @notifyAllConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Notify all members?'**
  String get notifyAllConfirmTitle;

  /// No description provided for @notifyAllConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'Everyone gets a push to add their last items.'**
  String get notifyAllConfirmBody;

  /// No description provided for @alertSent.
  ///
  /// In en, this message translates to:
  /// **'Sent ✓'**
  String get alertSent;

  /// No description provided for @headingToStoreSent.
  ///
  /// In en, this message translates to:
  /// **'Alert sent ✓ You\'re heading to the store now — happy shopping!'**
  String get headingToStoreSent;

  /// No description provided for @notificationsLabel.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsLabel;

  /// No description provided for @enableAction.
  ///
  /// In en, this message translates to:
  /// **'Enable'**
  String get enableAction;

  /// No description provided for @disableAction.
  ///
  /// In en, this message translates to:
  /// **'Disable'**
  String get disableAction;

  /// No description provided for @aboutTitle.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get aboutTitle;

  /// No description provided for @builtWithLoveInRiyadh.
  ///
  /// In en, this message translates to:
  /// **'Built with love in Riyadh'**
  String get builtWithLoveInRiyadh;

  /// No description provided for @appVersion.
  ///
  /// In en, this message translates to:
  /// **'v1.0.0'**
  String get appVersion;

  /// No description provided for @aboutNameStoryTitle.
  ///
  /// In en, this message translates to:
  /// **'How we got the name'**
  String get aboutNameStoryTitle;

  /// No description provided for @aboutNameStoryQuote.
  ///
  /// In en, this message translates to:
  /// **'“Call it Zaytona — like my doll.”'**
  String get aboutNameStoryQuote;

  /// No description provided for @aboutNameStoryBody.
  ///
  /// In en, this message translates to:
  /// **'The app was called “Zaytona”, and the name never quite fit. Aljawharah had been turning options over for days, her little sister Alhanouf quietly listening on the call.\n\nThen Alhanouf looked up at the small doll on her shelf and said, with a child’s certainty: “Call it Zaytona.” Aljawharah laughed — then stopped. The name wouldn’t leave her.\n\nThe next day she pitched it to the team, holding her breath. They loved it instantly. From one little doll on an ordinary call, Zaytona was born — and became a family.'**
  String get aboutNameStoryBody;

  /// No description provided for @aboutTeamHeading.
  ///
  /// In en, this message translates to:
  /// **'The Zaytona team'**
  String get aboutTeamHeading;

  /// No description provided for @aboutTeamMember1Name.
  ///
  /// In en, this message translates to:
  /// **'Reem Alyamani'**
  String get aboutTeamMember1Name;

  /// No description provided for @aboutTeamMember2Name.
  ///
  /// In en, this message translates to:
  /// **'Abdullah Almouraibd'**
  String get aboutTeamMember2Name;

  /// No description provided for @aboutTeamMember3Name.
  ///
  /// In en, this message translates to:
  /// **'Randa Baeshen'**
  String get aboutTeamMember3Name;

  /// No description provided for @aboutTeamMember4Name.
  ///
  /// In en, this message translates to:
  /// **'Mousa Alqarni'**
  String get aboutTeamMember4Name;

  /// No description provided for @aboutTeamMember5Name.
  ///
  /// In en, this message translates to:
  /// **'Alhanouf Aljandal'**
  String get aboutTeamMember5Name;

  /// No description provided for @aboutTeamMember6Name.
  ///
  /// In en, this message translates to:
  /// **'Aljawharah Alammar'**
  String get aboutTeamMember6Name;

  /// No description provided for @editAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit account'**
  String get editAccountTitle;

  /// No description provided for @chooseAvatarLabel.
  ///
  /// In en, this message translates to:
  /// **'Choose your avatar'**
  String get chooseAvatarLabel;

  /// No description provided for @avatarsUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load avatars'**
  String get avatarsUnavailable;

  /// No description provided for @saveChangesError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t save changes'**
  String get saveChangesError;

  /// No description provided for @completeNameFields.
  ///
  /// In en, this message translates to:
  /// **'Complete your first and last name'**
  String get completeNameFields;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar': return AppLocalizationsAr();
    case 'en': return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
