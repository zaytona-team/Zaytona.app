// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Zaytona';

  @override
  String get joinGroupTitle => 'Join a group';

  @override
  String get inviteCodeLabel => 'Invite code';

  @override
  String get inviteCodeHint => 'Invite code';

  @override
  String get inviteCodeRequired => 'Enter the invite code first';

  @override
  String get joinAction => 'Join';

  @override
  String get copyAction => 'Copy';

  @override
  String get inviteCodeCopied => 'Invite code copied';

  @override
  String get inviteLinkCopied => 'Invite link copied';

  @override
  String get newListTitle => 'New list';

  @override
  String get listNameLabel => 'List name';

  @override
  String get listColorLabel => 'List color';

  @override
  String get listNameHint => 'e.g. Weekend run';

  @override
  String get createListAction => 'Create list';

  @override
  String get listsTab => 'Lists';

  @override
  String get noListsYet => 'No lists yet';

  @override
  String get noListsYetBody => 'Lists you create for this group will show up here.';

  @override
  String get listCompletedBadge => 'Done';

  @override
  String listItemCount(int count) {
    return '$count items';
  }

  @override
  String get retryAction => 'Try again';

  @override
  String get signupTitle => 'Create account';

  @override
  String get signupSubtitle => 'Join your family on Zaytona';

  @override
  String get firstNameLabel => 'First name';

  @override
  String get lastNameLabel => 'Last name';

  @override
  String get phoneLabel => 'Phone number';

  @override
  String get phoneHint => '05X XXX XXXX';

  @override
  String get emailLabel => 'Email (optional)';

  @override
  String get signupAction => 'Sign up';

  @override
  String get alreadyHaveAccountPrompt => 'Already have an account?';

  @override
  String get loginAction => 'Log in';

  @override
  String get fieldRequired => 'This field is required';

  @override
  String get nameTooShort => 'At least 2 characters';

  @override
  String get phoneInvalid => 'Enter a valid phone number';

  @override
  String get emailInvalid => 'Enter a valid email address';

  @override
  String get appTagline => 'The family\'s shared list';

  @override
  String get welcomeTagline => 'Zaytona brings you together';

  @override
  String get noAccountPrompt => 'Don\'t have an account?';

  @override
  String get welcomeSignupCta => 'Sign up';

  @override
  String get otpTitle => 'Enter the code';

  @override
  String otpSubtitle(String phone) {
    return 'We sent a 4-digit code to $phone';
  }

  @override
  String otpSubtitleWhatsapp(String phone) {
    return 'We sent a 4-digit code to $phone via WhatsApp';
  }

  @override
  String otpResendCountdown(int seconds) {
    return 'Resend in $seconds seconds';
  }

  @override
  String get otpResendAction => 'Resend code';

  @override
  String get otpResending => 'Sending...';

  @override
  String get otpResent => 'A new code was sent';

  @override
  String get otpConfirmAction => 'Confirm';

  @override
  String get otpResendVia => 'Didn\'t get the code? Resend via:';

  @override
  String get otpChannelWhatsapp => 'WhatsApp';

  @override
  String get otpChannelSms => 'SMS';

  @override
  String get otpChannelEmail => 'Email';

  @override
  String get otpResendLimitReached => 'Resend attempts used up — try again later';

  @override
  String get editPhoneNumberAction => 'Edit number';

  @override
  String otpEmailFallback(String email) {
    return 'Send via email ($email) — coming soon';
  }

  @override
  String get otpNoEmailFallback => 'No email registered for fallback sending';

  @override
  String get drawerJoinGroup => 'Join a group';

  @override
  String get drawerCreateGroup => 'Create a group';

  @override
  String get drawerMyGroups => 'My groups';

  @override
  String get drawerSettings => 'Settings & account';

  @override
  String memberCount(int count) {
    return '$count members';
  }

  @override
  String urgentCount(int count) {
    return '$count urgent';
  }

  @override
  String get allCategories => 'All';

  @override
  String get noItemsTitle => 'No items yet';

  @override
  String get noItemsBody => 'Add the first item to start building this list with the group.';

  @override
  String get nothingInCategory => 'Nothing in this category.';

  @override
  String get noResultsTitle => 'No results';

  @override
  String get clearFilterAction => 'Clear filter';

  @override
  String get startTrip => 'Start trip';

  @override
  String get addItemAction => 'Add item';

  @override
  String get manualEntryTitle => 'Manual entry';

  @override
  String get editItemTitle => 'Edit item';

  @override
  String get howToAddHead => 'How to add';

  @override
  String get methodManual => 'Manual';

  @override
  String get methodBarcode => 'Scan barcode';

  @override
  String get methodPhoto => 'Photo scan';

  @override
  String get soonBadge => 'soon';

  @override
  String get itemNameLabel => 'Name';

  @override
  String get itemNameHint => 'What do we need?';

  @override
  String get itemBrandLabel => 'Brand (optional)';

  @override
  String get itemBrandHint => 'e.g. Almarai';

  @override
  String get itemNoteLabel => 'Note (optional)';

  @override
  String get itemNoteHint => 'e.g. Full fat';

  @override
  String get categoryLabel => 'Category';

  @override
  String get categorySearchHint => 'Search a category…';

  @override
  String get quantityLabel => 'Quantity';

  @override
  String get extraDetailsLabel => 'Extra details?';

  @override
  String get markUrgent => 'Mark as urgent';

  @override
  String get addToListAction => 'Add to list';

  @override
  String get saveChangesAction => 'Save changes';

  @override
  String get newGroupTitle => 'New group';

  @override
  String get editGroupTitle => 'Edit group';

  @override
  String get groupNameRequired => 'Group name is required';

  @override
  String get groupUpdateError => 'Couldn\'t update the group. Try again.';

  @override
  String get groupNameLabel => 'Group name';

  @override
  String get groupNameHint => 'e.g. The Otaibis';

  @override
  String groupNameHintPersonalized(String lastName) {
    return 'e.g. The $lastName Family';
  }

  @override
  String get groupIconLabel => 'Icon';

  @override
  String get createGroupAction => 'Create group';

  @override
  String get settingsTitle => 'Account settings';

  @override
  String get languageLabel => 'Language';

  @override
  String get arabicLanguage => 'العربية';

  @override
  String get englishLanguage => 'English';

  @override
  String get logoutAction => 'Log out';

  @override
  String get buyingModeLabel => 'Buying mode';

  @override
  String get showAllFilter => 'Show all';

  @override
  String get urgentFilter => 'Urgent';

  @override
  String get urgentBadge => 'Urgent';

  @override
  String get finishTrip => 'Finish shopping';

  @override
  String get completeTripTitle => 'Finish this trip?';

  @override
  String get completeTripBody => 'Bought items move to trip history. Anything left unchecked stays on the list for next time.';

  @override
  String tripSummaryCounts(int bought, int remaining) {
    return '$bought bought · $remaining left for next time';
  }

  @override
  String get tripInProgressByOther => 'Someone\'s shopping right now';

  @override
  String get noActiveTripError => 'This trip couldn\'t be found. It may have already ended.';

  @override
  String get backToGroupAction => 'Back to group';

  @override
  String get confirmAction => 'Confirm';

  @override
  String get cancelAction => 'Cancel';

  @override
  String get privateBadge => 'Private';

  @override
  String get adminBadge => 'Admin';

  @override
  String get memberBadge => 'Member';

  @override
  String get privateSpaceLine => 'Your private space · just you';

  @override
  String groupMembersCount(int count) {
    return '$count members';
  }

  @override
  String boughtOfTotal(int bought, int total) {
    return '$bought of $total bought';
  }

  @override
  String get completedListsSection => 'Completed';

  @override
  String get possibleDuplicateTitle => 'Possible duplicate';

  @override
  String possibleDuplicateBody(String name) {
    return '\"$name\" is already on this list.';
  }

  @override
  String get notifyAction => 'Notify';

  @override
  String get historyAction => 'History';

  @override
  String get historyActivityEmptyTitle => 'No activity yet';

  @override
  String get historyActivityEmptyBody => 'Actions taken on this list\'s items will show up here.';

  @override
  String get historyNoTripsTitle => 'Previous rounds';

  @override
  String get historyNoTripsBody => 'This list\'s shopping rounds will show up here after the first trip is finished.';

  @override
  String get historyTabActivity => 'Activity log';

  @override
  String get historyTabTrips => 'Trips';

  @override
  String get undoAction => 'Undo';

  @override
  String get historyTimeJustNow => 'Just now';

  @override
  String historyTimeMinutesAgo(int minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      minutes,
      locale: localeName,
      other: '$minutes minutes ago',
      two: 'Two minutes ago',
      one: 'A minute ago',
    );
    return '$_temp0';
  }

  @override
  String historyTimeHoursAgo(int hours) {
    String _temp0 = intl.Intl.pluralLogic(
      hours,
      locale: localeName,
      other: '$hours hours ago',
      two: 'Two hours ago',
      one: 'An hour ago',
    );
    return '$_temp0';
  }

  @override
  String get historyTimeYesterday => 'Yesterday';

  @override
  String historyTimeDaysAgo(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days days ago',
      two: 'Two days ago',
    );
    return '$_temp0';
  }

  @override
  String get deleteItemConfirmTitle => 'Remove this item?';

  @override
  String deleteItemConfirmBody(String name) {
    return '\"$name\" will be removed from the list.';
  }

  @override
  String get deleteListConfirmTitle => 'Delete this list?';

  @override
  String deleteListConfirmBody(String name) {
    return '\"$name\" will be permanently deleted.';
  }

  @override
  String get listSettingsTitle => 'List settings';

  @override
  String get listMenuAction => 'List menu';

  @override
  String get deleteAllItemsAction => 'Delete all items';

  @override
  String get deleteAllAction => 'Delete all';

  @override
  String get deleteAllItemsConfirmTitle => 'Delete all items?';

  @override
  String deleteAllItemsConfirmBody(int count) {
    return '$count items will be removed from the list.';
  }

  @override
  String listDeletedMessage(String name) {
    return '\"$name\" was deleted';
  }

  @override
  String get listDeleteFailedMessage => 'Couldn\'t delete the list';

  @override
  String get catalogTitle => 'Add item';

  @override
  String get catalogSearchHint => 'Search for an item';

  @override
  String get attachPhotoLabel => 'Attach photo';

  @override
  String get cameraSourceLabel => 'Camera';

  @override
  String get gallerySourceLabel => 'Gallery';

  @override
  String get removePhotoLabel => 'Remove photo';

  @override
  String get myItemsHead => 'My items';

  @override
  String get addManuallyAction => 'Add manually';

  @override
  String itemAddedMessage(String name) {
    return '\"$name\" added';
  }

  @override
  String itemQuantityIncreasedMessage(String name, int qty) {
    return '\"$name\" quantity increased to $qty';
  }

  @override
  String get quickAddLabel => 'Quick add';

  @override
  String get addAction => 'Add';

  @override
  String get addedLabel => 'Added';

  @override
  String get catalogEmptyTitle => 'Your catalog is empty';

  @override
  String get catalogEmptyBody => 'Add your first item to start building your personal catalog.';

  @override
  String get loginTitle => 'Sign in';

  @override
  String get loginSubtitle => 'Welcome back';

  @override
  String get loginIdentifierHint => 'Phone or email';

  @override
  String get loginChecking => 'Checking…';

  @override
  String get sendCodeAction => 'Send code';

  @override
  String get createAccountAction => 'Create account';

  @override
  String get inviteMembersTitle => 'Invite members';

  @override
  String get backAction => 'Back';

  @override
  String get shareInviteLink => 'Share invite link';

  @override
  String joinedMembersSection(int count) {
    return 'Members ($count)';
  }

  @override
  String get nobodyJoinedYet => 'No one joined yet — share the code or link';

  @override
  String get nobodyJoinedYetBody => 'Invited members haven\'t opened the link yet.';

  @override
  String get doneAction => 'Done';

  @override
  String get groupSettingsTitle => 'Group settings';

  @override
  String get groupIdentitySection => 'Group identity';

  @override
  String get membersSection => 'Members';

  @override
  String get dangerZoneSection => 'Danger zone';

  @override
  String get youSuffix => 'You';

  @override
  String get saveAction => 'Save';

  @override
  String get changesSaved => 'Changes saved';

  @override
  String get makeAdminAction => 'Make admin';

  @override
  String get removeMemberAction => 'Remove from group';

  @override
  String get memberActionsLabel => 'Member actions';

  @override
  String get transferAdminConfirmTitle => 'Transfer admin role?';

  @override
  String transferAdminConfirmBody(String name) {
    return '$name becomes the group\'s only admin and you lose admin privileges.';
  }

  @override
  String removeMemberConfirmTitle(String name) {
    return 'Remove $name?';
  }

  @override
  String get removeMemberConfirmBody => 'They lose access to this group\'s lists.';

  @override
  String get deleteGroupTitle => 'Delete group';

  @override
  String get deleteGroupBody => 'Permanently removes all lists for everyone.';

  @override
  String get deleteGroupConfirmTitle => 'Delete this group?';

  @override
  String get deleteGroupConfirmBody => 'This can\'t be undone.';

  @override
  String get deleteAction => 'Delete';

  @override
  String get leaveGroupTitle => 'Leave group';

  @override
  String get leaveGroupBody => 'You\'ll lose access to this group\'s lists.';

  @override
  String get leaveGroupConfirmTitle => 'Leave this group?';

  @override
  String get leaveGroupConfirmBody => 'You can re-join later with the invite code.';

  @override
  String get leaveAction => 'Leave';

  @override
  String get privateGroupBannerTitle => 'Your private group';

  @override
  String get privateGroupBannerBody => 'Only you can see it. No members to invite, and it can\'t be deleted.';

  @override
  String get chooseAvatarTitle => 'Choose your avatar';

  @override
  String get chooseAvatarBody => 'It shows next to the items you add for the group.';

  @override
  String get continueAction => 'Continue';

  @override
  String get firstGroupTitle => 'Start with a group';

  @override
  String get firstGroupBody => 'Create one for your family, or join with an invite code. You already have your own private group.';

  @override
  String get createFamilyGroupAction => 'Create a family group';

  @override
  String get joinWithCodeAction => 'Join with a code';

  @override
  String get skipForNowAction => 'Skip for now';

  @override
  String get avatarsLoadError => 'Couldn\'t load avatars';

  @override
  String get avatarSelectError => 'Couldn\'t save your avatar';

  @override
  String get tipsTitle => '4 things before you dive in';

  @override
  String get tipDrawerTitle => 'The drawer';

  @override
  String get tipDrawerBody => 'All your groups live in there — swipe or tap the logo and peek in';

  @override
  String get tipPersonalGroupTitle => 'Your personal group';

  @override
  String get tipPersonalGroupBody => 'This one\'s just for you — nobody\'s crashing this party, no matter how hard they try';

  @override
  String get tipCreateListTitle => 'The \"create list\" button';

  @override
  String get tipCreateListBody => 'Tap it and start a fresh list before someone \"forgets\" what they need';

  @override
  String get tipGroupSettingsTitle => 'Group settings';

  @override
  String get tipGroupSettingsBody => 'Rename it, re-icon it, or see who\'s actually in the group with you';

  @override
  String get letsGoAction => 'Let\'s go';

  @override
  String get tripAlertsTitle => 'Trip alerts';

  @override
  String get headingToStoreTitle => 'I\'m heading to the store';

  @override
  String get headingToStoreBody => 'Nudge everyone to add their last items';

  @override
  String get notifyGroupAction => 'Notify group';

  @override
  String get assignBuyerTitle => 'Assign a buyer';

  @override
  String get assignBuyerBody => 'Pick who shops this trip';

  @override
  String get chooseMemberAction => 'Choose member';

  @override
  String get changeMemberAction => 'Change';

  @override
  String get remindMemberTitle => 'Remind someone';

  @override
  String get remindMemberBody => 'Remind a member to add their items';

  @override
  String get remindMemberSheetTitle => 'Remind member';

  @override
  String get noMembersToNotifyTitle => 'No members yet';

  @override
  String get noMembersToNotifyBody => 'Invite someone to the group before you can notify them.';

  @override
  String get notifyAllConfirmTitle => 'Notify all members?';

  @override
  String get notifyAllConfirmBody => 'Everyone gets a push to add their last items.';

  @override
  String get alertSent => 'Sent ✓';

  @override
  String get headingToStoreSent => 'Alert sent ✓ You\'re heading to the store now — happy shopping!';

  @override
  String get notificationsLabel => 'Notifications';

  @override
  String get enableAction => 'Enable';

  @override
  String get disableAction => 'Disable';

  @override
  String get aboutTitle => 'About';

  @override
  String get builtWithLoveInRiyadh => 'Built with love in Riyadh';

  @override
  String get appVersion => 'v1.0.0';

  @override
  String get aboutNameStoryTitle => 'How we got the name';

  @override
  String get aboutNameStoryQuote => '“Call it Zaytona — like my doll.”';

  @override
  String get aboutNameStoryBody => 'The app was called “Zaytona”, and the name never quite fit. Aljawharah had been turning options over for days, her little sister Alhanouf quietly listening on the call.\n\nThen Alhanouf looked up at the small doll on her shelf and said, with a child’s certainty: “Call it Zaytona.” Aljawharah laughed — then stopped. The name wouldn’t leave her.\n\nThe next day she pitched it to the team, holding her breath. They loved it instantly. From one little doll on an ordinary call, Zaytona was born — and became a family.';

  @override
  String get aboutTeamHeading => 'The Zaytona team';

  @override
  String get aboutTeamMember1Name => 'Reem Alyamani';

  @override
  String get aboutTeamMember2Name => 'Abdullah Almouraibd';

  @override
  String get aboutTeamMember3Name => 'Randa Baeshen';

  @override
  String get aboutTeamMember4Name => 'Mousa Alqarni';

  @override
  String get aboutTeamMember5Name => 'Alhanouf Aljandal';

  @override
  String get aboutTeamMember6Name => 'Aljawharah Alammar';

  @override
  String get editAccountTitle => 'Edit account';

  @override
  String get chooseAvatarLabel => 'Choose your avatar';

  @override
  String get avatarsUnavailable => 'Couldn\'t load avatars';

  @override
  String get saveChangesError => 'Couldn\'t save changes';

  @override
  String get completeNameFields => 'Complete your first and last name';
}
