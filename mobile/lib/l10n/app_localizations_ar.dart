// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'زيتونة';

  @override
  String get joinGroupTitle => 'الانضمام لمجموعة';

  @override
  String get inviteCodeLabel => 'كود الدعوة';

  @override
  String get inviteCodeHint => 'رمز الدعوة';

  @override
  String get inviteCodeRequired => 'أدخل كود الدعوة أولاً';

  @override
  String get joinAction => 'انضمام';

  @override
  String get copyAction => 'نسخ';

  @override
  String get inviteCodeCopied => 'تم نسخ كود الدعوة';

  @override
  String get inviteLinkCopied => 'تم نسخ رابط الدعوة';

  @override
  String get newListTitle => 'قائمة جديدة';

  @override
  String get listNameLabel => 'اسم القائمة';

  @override
  String get listColorLabel => 'لون القائمة';

  @override
  String get listNameHint => 'مثال: تسوق نهاية الأسبوع';

  @override
  String get createListAction => 'إنشاء القائمة';

  @override
  String get listsTab => 'القوائم';

  @override
  String get noListsYet => 'لا توجد قوائم بعد';

  @override
  String get noListsYetBody => 'القوائم التي تنشئها لهذه المجموعة ستظهر هنا.';

  @override
  String get listCompletedBadge => 'مكتملة';

  @override
  String listItemCount(int count) {
    return '$count عنصر';
  }

  @override
  String get retryAction => 'إعادة المحاولة';

  @override
  String get signupTitle => 'إنشاء حساب';

  @override
  String get signupSubtitle => 'انضم لعائلتك في زيتونة';

  @override
  String get firstNameLabel => 'الاسم الأول';

  @override
  String get lastNameLabel => 'اسم العائلة';

  @override
  String get phoneLabel => 'رقم الجوال';

  @override
  String get phoneHint => '05X XXX XXXX';

  @override
  String get emailLabel => 'البريد الإلكتروني (اختياري)';

  @override
  String get signupAction => 'إنشاء الحساب';

  @override
  String get alreadyHaveAccountPrompt => 'لديك حساب؟';

  @override
  String get loginAction => 'تسجيل الدخول';

  @override
  String get fieldRequired => 'هذا الحقل مطلوب';

  @override
  String get nameTooShort => 'حرفان على الأقل';

  @override
  String get phoneInvalid => 'أدخل رقم جوال صحيح';

  @override
  String get emailInvalid => 'أدخل بريدًا إلكترونيًا صحيحًا';

  @override
  String get appTagline => 'قائمة العائلة المشتركة';

  @override
  String get welcomeTagline => 'زيتونة تلمكم، وتكمل بعضكم';

  @override
  String get noAccountPrompt => 'ليس لديك حساب؟';

  @override
  String get welcomeSignupCta => 'سجل الان';

  @override
  String get otpTitle => 'أدخل الرمز';

  @override
  String otpSubtitle(String phone) {
    return 'أرسلنا رمزًا مكونًا من ٤ أرقام إلى $phone';
  }

  @override
  String otpSubtitleWhatsapp(String phone) {
    return 'أرسلنا رمزًا مكونًا من ٤ أرقام إلى $phone عبر واتساب';
  }

  @override
  String otpResendCountdown(int seconds) {
    return 'إعادة الإرسال خلال $seconds ثانية';
  }

  @override
  String get otpResendAction => 'إعادة إرسال الرمز';

  @override
  String get otpResending => 'جارٍ الإرسال...';

  @override
  String get otpResent => 'تم إرسال رمز جديد';

  @override
  String get otpConfirmAction => 'تأكيد';

  @override
  String get otpResendVia => 'لم يصلك الرمز؟ أعد الإرسال عبر:';

  @override
  String get otpChannelWhatsapp => 'واتساب';

  @override
  String get otpChannelSms => 'رسالة نصية';

  @override
  String get otpChannelEmail => 'البريد الإلكتروني';

  @override
  String get otpResendLimitReached => 'استنفدت محاولات إعادة الإرسال، جرّب لاحقًا';

  @override
  String get editPhoneNumberAction => 'تعديل الرقم';

  @override
  String otpEmailFallback(String email) {
    return 'إرسال عبر البريد ($email) — قريبًا';
  }

  @override
  String get otpNoEmailFallback => 'لا يوجد بريد إلكتروني مسجل للإرسال البديل';

  @override
  String get drawerJoinGroup => 'الانضمام لمجموعة';

  @override
  String get drawerCreateGroup => 'إنشاء مجموعة';

  @override
  String get drawerMyGroups => 'مجموعاتي';

  @override
  String get drawerSettings => 'الإعدادات والحساب';

  @override
  String memberCount(int count) {
    return '$count أفراد';
  }

  @override
  String urgentCount(int count) {
    return '$count عاجل';
  }

  @override
  String get allCategories => 'الكل';

  @override
  String get noItemsTitle => 'لا عناصر بعد';

  @override
  String get noItemsBody => 'أضف أول عنصر لتبدأ ببناء القائمة مع المجموعة.';

  @override
  String get nothingInCategory => 'لا عناصر في هذه الفئة.';

  @override
  String get noResultsTitle => 'لا نتائج';

  @override
  String get clearFilterAction => 'مسح الفلتر';

  @override
  String get startTrip => 'ابدأ الرحلة';

  @override
  String get addItemAction => 'إضافة عنصر';

  @override
  String get manualEntryTitle => 'إضافة يدوية';

  @override
  String get editItemTitle => 'تعديل عنصر';

  @override
  String get howToAddHead => 'طريقة الإضافة';

  @override
  String get methodManual => 'إدخال يدوي';

  @override
  String get methodBarcode => 'مسح باركود';

  @override
  String get methodPhoto => 'تصوير المنتج';

  @override
  String get soonBadge => 'قريباً';

  @override
  String get itemNameLabel => 'الاسم';

  @override
  String get itemNameHint => 'ماذا نحتاج؟';

  @override
  String get itemBrandLabel => 'الماركة (اختياري)';

  @override
  String get itemBrandHint => 'مثال: المراعي';

  @override
  String get itemNoteLabel => 'ملاحظة (اختياري)';

  @override
  String get itemNoteHint => 'مثال: كامل الدسم';

  @override
  String get categoryLabel => 'الفئة';

  @override
  String get categorySearchHint => 'ابحث عن فئة…';

  @override
  String get quantityLabel => 'الكمية';

  @override
  String get extraDetailsLabel => 'تفاصيل إضافية؟';

  @override
  String get markUrgent => 'تحديد كعاجل';

  @override
  String get addToListAction => 'أضف للقائمة';

  @override
  String get saveChangesAction => 'حفظ التغييرات';

  @override
  String get newGroupTitle => 'مجموعة جديدة';

  @override
  String get editGroupTitle => 'تعديل المجموعة';

  @override
  String get groupNameRequired => 'اسم المجموعة مطلوب';

  @override
  String get groupUpdateError => 'تعذر تعديل المجموعة. حاول مرة أخرى.';

  @override
  String get groupNameLabel => 'اسم المجموعة';

  @override
  String get groupNameHint => 'مثال: آل العتيبي';

  @override
  String groupNameHintPersonalized(String lastName) {
    return 'مثال: آل $lastName';
  }

  @override
  String get groupIconLabel => 'الأيقونة';

  @override
  String get createGroupAction => 'إنشاء المجموعة';

  @override
  String get settingsTitle => 'إعدادات الحساب';

  @override
  String get languageLabel => 'اللغة';

  @override
  String get arabicLanguage => 'العربية';

  @override
  String get englishLanguage => 'English';

  @override
  String get logoutAction => 'تسجيل الخروج';

  @override
  String get buyingModeLabel => 'وضع التسوّق';

  @override
  String get showAllFilter => 'عرض الكل';

  @override
  String get urgentFilter => 'العاجل';

  @override
  String get urgentBadge => 'عاجل';

  @override
  String get finishTrip => 'إنهاء التسوق';

  @override
  String get completeTripTitle => 'إنهاء رحلة التسوّق؟';

  @override
  String get completeTripBody => 'العناصر المشتراة تُحفظ في سجل الرحلات، والعناصر غير المشتراة تبقى في القائمة للمرة القادمة.';

  @override
  String tripSummaryCounts(int bought, int remaining) {
    return 'تم شراء $bought · تبقّى $remaining للمرة القادمة';
  }

  @override
  String get tripInProgressByOther => 'أحد يتسوق الآن ...';

  @override
  String get noActiveTripError => 'تعذر العثور على هذه الرحلة، ربما انتهت بالفعل.';

  @override
  String get backToGroupAction => 'الرجوع إلى المجموعة';

  @override
  String get confirmAction => 'تأكيد';

  @override
  String get cancelAction => 'إلغاء';

  @override
  String get privateBadge => 'خاصة';

  @override
  String get adminBadge => 'مشرف';

  @override
  String get memberBadge => 'عضو';

  @override
  String get privateSpaceLine => 'مساحتك الخاصة · أنت فقط';

  @override
  String groupMembersCount(int count) {
    return '$count أعضاء';
  }

  @override
  String boughtOfTotal(int bought, int total) {
    return '$bought من $total تم';
  }

  @override
  String get completedListsSection => 'المكتملة';

  @override
  String get possibleDuplicateTitle => 'عنصر مكرّر محتمل';

  @override
  String possibleDuplicateBody(String name) {
    return '«$name» موجود في القائمة بالفعل.';
  }

  @override
  String get notifyAction => 'تنبيه';

  @override
  String get historyAction => 'السجل';

  @override
  String get historyActivityEmptyTitle => 'لا يوجد نشاط بعد';

  @override
  String get historyActivityEmptyBody => 'ستظهر هنا العمليات التي تتم على عناصر هذه القائمة.';

  @override
  String get historyNoTripsTitle => 'جولات سابقة';

  @override
  String get historyNoTripsBody => 'ستظهر هنا جولات التسوق لهذه القائمة بعد إنهاء أول رحلة.';

  @override
  String get historyTabActivity => 'سجل النشاط';

  @override
  String get historyTabTrips => 'الرحلات';

  @override
  String get undoAction => 'تراجع';

  @override
  String get historyTimeJustNow => 'الآن';

  @override
  String historyTimeMinutesAgo(int minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      minutes,
      locale: localeName,
      other: 'قبل $minutes دقيقة',
      two: 'قبل دقيقتين',
      one: 'قبل دقيقة',
    );
    return '$_temp0';
  }

  @override
  String historyTimeHoursAgo(int hours) {
    String _temp0 = intl.Intl.pluralLogic(
      hours,
      locale: localeName,
      other: 'قبل $hours ساعات',
      two: 'قبل ساعتين',
      one: 'قبل ساعة',
    );
    return '$_temp0';
  }

  @override
  String get historyTimeYesterday => 'أمس';

  @override
  String historyTimeDaysAgo(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'قبل $days أيام',
      two: 'قبل يومين',
    );
    return '$_temp0';
  }

  @override
  String get deleteItemConfirmTitle => 'إزالة هذا العنصر؟';

  @override
  String deleteItemConfirmBody(String name) {
    return 'سيتم حذف «$name» من القائمة.';
  }

  @override
  String get deleteListConfirmTitle => 'حذف هذه القائمة؟';

  @override
  String deleteListConfirmBody(String name) {
    return 'سيتم حذف «$name» نهائيًا.';
  }

  @override
  String get listSettingsTitle => 'إعدادات القائمة';

  @override
  String get listMenuAction => 'قائمة الخيارات';

  @override
  String get deleteAllItemsAction => 'حذف كل العناصر';

  @override
  String get deleteAllAction => 'حذف الكل';

  @override
  String get deleteAllItemsConfirmTitle => 'حذف كل العناصر؟';

  @override
  String deleteAllItemsConfirmBody(int count) {
    return 'سيتم حذف $count عنصر من القائمة.';
  }

  @override
  String listDeletedMessage(String name) {
    return 'تم حذف «$name»';
  }

  @override
  String get listDeleteFailedMessage => 'تعذر حذف القائمة';

  @override
  String get catalogTitle => 'إضافة عنصر';

  @override
  String get catalogSearchHint => 'ابحث عن عنصر';

  @override
  String get attachPhotoLabel => 'إرفاق صورة';

  @override
  String get cameraSourceLabel => 'الكاميرا';

  @override
  String get gallerySourceLabel => 'معرض الصور';

  @override
  String get removePhotoLabel => 'إزالة الصورة';

  @override
  String get myItemsHead => 'عناصري';

  @override
  String get addManuallyAction => 'إضافة يدوية';

  @override
  String itemAddedMessage(String name) {
    return 'تمت إضافة «$name»';
  }

  @override
  String itemQuantityIncreasedMessage(String name, int qty) {
    return 'تمت زيادة كمية «$name» إلى $qty';
  }

  @override
  String get quickAddLabel => 'إضافة سريعة';

  @override
  String get addAction => 'إضافة';

  @override
  String get addedLabel => 'أُضيف';

  @override
  String get catalogEmptyTitle => 'لا عناصر في كتالوجك بعد';

  @override
  String get catalogEmptyBody => 'أضف أول عنصر لتبدأ ببناء كتالوجك الشخصي.';

  @override
  String get loginTitle => 'تسجيل الدخول';

  @override
  String get loginSubtitle => 'مرحباً بعودتك';

  @override
  String get loginIdentifierHint => 'الجوال أو البريد';

  @override
  String get loginChecking => 'جارٍ التحقق…';

  @override
  String get sendCodeAction => 'إرسال الرمز';

  @override
  String get createAccountAction => 'إنشاء حساب';

  @override
  String get inviteMembersTitle => 'دعوة أعضاء';

  @override
  String get backAction => 'رجوع';

  @override
  String get shareInviteLink => 'مشاركة رابط الدعوة';

  @override
  String joinedMembersSection(int count) {
    return 'الأعضاء ($count)';
  }

  @override
  String get nobodyJoinedYet => 'لم ينضم أحد بعد، شارك الكود أو الرابط';

  @override
  String get nobodyJoinedYetBody => 'لم يفتح الأعضاء المدعوون الرابط بعد.';

  @override
  String get doneAction => 'تم';

  @override
  String get groupSettingsTitle => 'إعدادات المجموعة';

  @override
  String get groupIdentitySection => 'هوية المجموعة';

  @override
  String get membersSection => 'الأعضاء';

  @override
  String get dangerZoneSection => 'منطقة الخطر';

  @override
  String get youSuffix => 'أنت';

  @override
  String get saveAction => 'حفظ';

  @override
  String get changesSaved => 'تم حفظ التغييرات';

  @override
  String get makeAdminAction => 'تعيين كمشرف';

  @override
  String get removeMemberAction => 'إزالة من المجموعة';

  @override
  String get memberActionsLabel => 'إجراءات العضو';

  @override
  String get transferAdminConfirmTitle => 'نقل الإشراف؟';

  @override
  String transferAdminConfirmBody(String name) {
    return 'سيصبح $name المشرف الوحيد للمجموعة وستفقد صلاحيات الإشراف.';
  }

  @override
  String removeMemberConfirmTitle(String name) {
    return 'إزالة $name؟';
  }

  @override
  String get removeMemberConfirmBody => 'سيفقد الوصول لقوائم هذه المجموعة.';

  @override
  String get deleteGroupTitle => 'حذف المجموعة';

  @override
  String get deleteGroupBody => 'يحذف كل القوائم نهائياً لجميع الأعضاء.';

  @override
  String get deleteGroupConfirmTitle => 'حذف هذه المجموعة؟';

  @override
  String get deleteGroupConfirmBody => 'لا يمكن التراجع عن هذا الإجراء.';

  @override
  String get deleteAction => 'حذف';

  @override
  String get leaveGroupTitle => 'مغادرة المجموعة';

  @override
  String get leaveGroupBody => 'ستفقد الوصول لقوائم هذه المجموعة.';

  @override
  String get leaveGroupConfirmTitle => 'مغادرة المجموعة؟';

  @override
  String get leaveGroupConfirmBody => 'يمكنك الانضمام مجدداً لاحقاً بكود الدعوة.';

  @override
  String get leaveAction => 'مغادرة';

  @override
  String get privateGroupBannerTitle => 'مجموعتك الخاصة';

  @override
  String get privateGroupBannerBody => 'لا يراها أحد غيرك. لا يمكن دعوة أعضاء أو حذفها.';

  @override
  String get chooseAvatarTitle => 'اختر صورتك';

  @override
  String get chooseAvatarBody => 'تظهر بجانب العناصر التي تضيفها للمجموعة.';

  @override
  String get continueAction => 'متابعة';

  @override
  String get firstGroupTitle => 'لنبدأ بمجموعة';

  @override
  String get firstGroupBody => 'أنشئ مجموعة لعائلتك، أو انضم بكود دعوة. لديك أصلاً مجموعتك الشخصية الخاصة.';

  @override
  String get createFamilyGroupAction => 'إنشاء مجموعة العائلة';

  @override
  String get joinWithCodeAction => 'الانضمام بكود';

  @override
  String get skipForNowAction => 'تخطّي الآن';

  @override
  String get avatarsLoadError => 'تعذر تحميل الصور';

  @override
  String get avatarSelectError => 'تعذر حفظ الصورة';

  @override
  String get tipsTitle => '٤ أشياء قبل ما تنطلق';

  @override
  String get tipDrawerTitle => 'القائمة الجانبية';

  @override
  String get tipDrawerBody => 'كل مجموعاتك ساكنة هناك — اسحب أو اضغط الشعار وطلّع راسك';

  @override
  String get tipPersonalGroupTitle => 'مجموعتك الخاصة';

  @override
  String get tipPersonalGroupBody => 'هذي خاصة فيك بس، محد يقدر ينضم لها حتى لو حاول!';

  @override
  String get tipCreateListTitle => 'زر \"إنشاء قائمة\"';

  @override
  String get tipCreateListBody => 'اضغطيه وابدئي قائمة جديدة قبل ما ينسى أحد شي في البيت';

  @override
  String get tipGroupSettingsTitle => 'إعدادات المجموعة';

  @override
  String get tipGroupSettingsBody => 'من فيه تغيّرين الاسم، الأيقونة، أو تشوفين مين معك في المجموعة';

  @override
  String get letsGoAction => 'لننطلق!';

  @override
  String get tripAlertsTitle => 'تنبيهات الرحلة';

  @override
  String get headingToStoreTitle => 'أنا متجهة للمتجر';

  @override
  String get headingToStoreBody => 'نبّه الجميع لإضافة آخر طلباتهم';

  @override
  String get notifyGroupAction => 'تنبيه المجموعة';

  @override
  String get assignBuyerTitle => 'تعيين مشترٍ';

  @override
  String get assignBuyerBody => 'اختر من سيقوم بالتسوّق';

  @override
  String get chooseMemberAction => 'اختيار عضو';

  @override
  String get changeMemberAction => 'تغيير';

  @override
  String get remindMemberTitle => 'ذكّر أحدهم';

  @override
  String get remindMemberBody => 'ذكّر عضواً بإضافة طلباته';

  @override
  String get remindMemberSheetTitle => 'تذكير عضو';

  @override
  String get noMembersToNotifyTitle => 'لا يوجد أعضاء بعد';

  @override
  String get noMembersToNotifyBody => 'ادعُ أحدًا إلى المجموعة قبل أن تتمكن من إشعاره.';

  @override
  String get notifyAllConfirmTitle => 'تنبيه كل الأعضاء؟';

  @override
  String get notifyAllConfirmBody => 'سيصل تنبيه للجميع لإضافة آخر طلباتهم.';

  @override
  String get alertSent => 'تم الإرسال ✓';

  @override
  String get headingToStoreSent => 'تم التنبيه ✓ أنت متجهة للمتجر الآن، بالتوفيق في التسوّق!';

  @override
  String get notificationsLabel => 'الإشعارات';

  @override
  String get enableAction => 'تفعيل';

  @override
  String get disableAction => 'إيقاف';

  @override
  String get aboutTitle => 'عن التطبيق';

  @override
  String get builtWithLoveInRiyadh => 'صُنع بحب في الرياض';

  @override
  String get appVersion => 'الإصدار 1.0.0';

  @override
  String get aboutNameStoryTitle => 'قصة الاسم';

  @override
  String get aboutNameStoryQuote => '«سمّوه زيتونة… مثل دميتي»';

  @override
  String get aboutNameStoryBody => 'كان التطبيق اسمه «ثلاجة»، والاسم لا يشبهه. الجوهرة تقلّب الأسماء منذ أيام، وأختها الصغيرة الهنوف معها على المكالمة تسمع بصمت.\n\nثم رفعت الهنوف رأسها نحو دميتها الصغيرة على الرف، وقالت ببساطة الأطفال: «سمّوها زيتونة». ضحكت الجوهرة… ثم توقفت. الاسم لم يفارقها.\n\nفي اليوم التالي عرضته على الفريق وهي تحبس أنفاسها — فأحبّوه من أول لحظة. ومن دمية صغيرة في مكالمة عابرة، وُلدت زيتونة وصارت عائلة.';

  @override
  String get aboutTeamHeading => 'فريق زيتونة';

  @override
  String get aboutTeamMember1Name => 'ريم اليماني';

  @override
  String get aboutTeamMember2Name => 'عبدالله المريبض';

  @override
  String get aboutTeamMember3Name => 'رندا باعشن';

  @override
  String get aboutTeamMember4Name => 'موسى القرني';

  @override
  String get aboutTeamMember5Name => 'الهنوف الجندل';

  @override
  String get aboutTeamMember6Name => 'الجوهرة العمار';

  @override
  String get editAccountTitle => 'تعديل الحساب';

  @override
  String get chooseAvatarLabel => 'اختر صورتك';

  @override
  String get avatarsUnavailable => 'تعذر تحميل الصور';

  @override
  String get saveChangesError => 'تعذر حفظ التغييرات';

  @override
  String get completeNameFields => 'أكملي الاسم الأول واسم العائلة';
}
