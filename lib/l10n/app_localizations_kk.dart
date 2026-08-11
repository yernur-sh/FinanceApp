// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Kazakh (`kk`).
class AppLocalizationsKk extends AppLocalizations {
  AppLocalizationsKk([String locale = 'kk']) : super(locale);

  @override
  String get appTitle => 'Жеке Қаржылар';

  @override
  String get income => 'Табыс';

  @override
  String get expense => 'Шығын';

  @override
  String get category => 'Санат';

  @override
  String get loginRequired => 'Кіру қажет';

  @override
  String errorWithMessage(String message) {
    return 'Қате: $message';
  }

  @override
  String get fillAllFieldsCorrectly => 'Барлық өрісті дұрыс толтырыңыз';

  @override
  String get otherCategory => 'Басқа';

  @override
  String get userNotFound => 'Мұндай пайдаланушы табылмады';

  @override
  String get wrongPassword => 'Құпия сөз қате';

  @override
  String get invalidEmail => 'Email қате енгізілген';

  @override
  String get invalidCredential => 'Email немесе құпия сөз қате';

  @override
  String get loginTitle => 'Кіру';

  @override
  String get loginSubtitle => 'Қаржыңызды бақылауды жалғастырыңыз';

  @override
  String get emailLabel => 'Email';

  @override
  String get emailRequired => 'Email енгізіңіз';

  @override
  String get emailInvalid => 'Дұрыс email енгізіңіз';

  @override
  String get passwordLabel => 'Құпия сөз';

  @override
  String get passwordTooShort => 'Кемінде 6 таңба болу керек';

  @override
  String get noAccountRegister => 'Аккаунтыңыз жоқ па? Тіркелу';

  @override
  String get logoutTitle => 'Жүйеден шығу';

  @override
  String get logoutConfirm => 'Шын мәнінде аккаунттан шыққыңыз келе ме?';

  @override
  String get cancel => 'Бас тарту';

  @override
  String get logoutAction => 'Шығу';

  @override
  String get logoutButton => 'Аккаунттан шығу';

  @override
  String get userFallback => 'Пайдаланушы';

  @override
  String get profileTitle => 'Профиль';

  @override
  String get personalSettings => 'Жеке баптаулар';

  @override
  String get editData => 'Деректерді өңдеу';

  @override
  String get editDataSubtitle => 'Аты-жөн, профиль суреті';

  @override
  String get notifications => 'Хабарландырулар';

  @override
  String get notificationsSubtitle => 'Ескертулер';

  @override
  String get noNotificationsYet => 'Әзірге хабарландырулар жоқ';

  @override
  String get security => 'Қауіпсіздік';

  @override
  String get securitySubtitle => 'Құпия сөзді өзгерту';

  @override
  String get appSection => 'Қолданба';

  @override
  String get helpSupport => 'Көмек және қолдау';

  @override
  String get helpAndSupport => 'Көмек және қолдау';

  @override
  String get aboutApp => 'Қолданба туралы';

  @override
  String appVersion(String version) {
    return 'Нұсқасы v$version';
  }

  @override
  String get passwordChangedSuccess => 'Құпия сөз сәтті өзгертілді';

  @override
  String get wrongCurrentPassword => 'Қазіргі құпия сөз қате';

  @override
  String get currentPasswordWrong => 'Қазіргі құпия сөз қате';

  @override
  String get newPasswordTooWeak => 'Жаңа құпия сөз тым әлсіз';

  @override
  String get newPasswordWeak => 'Жаңа құпия сөз тым әлсіз';

  @override
  String get requiresRecentLogin =>
      'Қауіпсіздік үшін қайта кіру қажет. Шығып, қайта кіріңіз';

  @override
  String get tooManyRequests => 'Тым көп әрекет жасалды. Сәл кейін қайталаңыз';

  @override
  String get nonEmailAccountNotice =>
      'Сіздің аккаунтыңыз email/құпия сөз арқылы емес, басқа провайдер арқылы тіркелген. Құпия сөзді осы жерден өзгерту мүмкін емес.';

  @override
  String get otherProviderAccountNotice =>
      'Сіздің аккаунтыңыз email/құпия сөз арқылы емес, басқа провайдер арқылы тіркелген. Құпия сөзді осы жерден өзгерту мүмкін емес.';

  @override
  String get changePassword => 'Құпия сөзді өзгерту';

  @override
  String get currentPassword => 'Қазіргі құпия сөз';

  @override
  String get currentPasswordLabel => 'Қазіргі құпия сөз';

  @override
  String get enterCurrentPassword => 'Қазіргі құпия сөзді енгізіңіз';

  @override
  String get newPassword => 'Жаңа құпия сөз';

  @override
  String get newPasswordLabel => 'Жаңа құпия сөз';

  @override
  String get minSixCharacters => 'Кемінде 6 таңба болу керек';

  @override
  String get newPasswordMustDiffer =>
      'Жаңа құпия сөз ескісінен өзгеше болуы керек';

  @override
  String get confirmNewPassword => 'Жаңа құпия сөзді қайталаңыз';

  @override
  String get confirmNewPasswordLabel => 'Жаңа құпия сөзді қайталаңыз';

  @override
  String get passwordsDoNotMatch => 'Құпия сөздер сәйкес келмейді';

  @override
  String get savePassword => 'Құпия сөзді сақтау';

  @override
  String get savePasswordButton => 'Құпия сөзді сақтау';

  @override
  String get emailAlreadyInUse => 'Бұл email тіркелген';

  @override
  String get passwordTooWeak => 'Құпия сөз тым әлсіз';

  @override
  String get passwordWeak => 'Құпия сөз тым әлсіз';

  @override
  String get register => 'Тіркелу';

  @override
  String get registerTitle => 'Тіркелу';

  @override
  String get createNewAccountSubtitle => 'Жаңа аккаунт құрып бастаңыз';

  @override
  String get registerSubtitle => 'Жаңа аккаунт құрып бастаңыз';

  @override
  String get fullName => 'Аты-жөні';

  @override
  String get fullNameLabel => 'Аты-жөні';

  @override
  String get enterYourName => 'Атыңызды енгізіңіз';

  @override
  String get email => 'Email';

  @override
  String get enterValidEmail => 'Дұрыс email енгізіңіз';

  @override
  String get password => 'Құпия сөз';

  @override
  String get confirmPassword => 'Құпия сөзді қайталаңыз';

  @override
  String get confirmPasswordLabel => 'Құпия сөзді қайталаңыз';

  @override
  String get newGoal => 'Жаңа мақсат';

  @override
  String get goalNameLabel => 'Мақсат атауы';

  @override
  String get goalTargetAmountLabel => 'Мақсатты сома (₸)';

  @override
  String get selectDeadlineOptional => 'Мерзімін таңдау (міндетті емес)';

  @override
  String get createGoal => 'Мақсат құру';

  @override
  String get goalsTitle => 'Мақсаттар';

  @override
  String get activeGoals => 'Белсенді мақсаттар';

  @override
  String get noGoalsYet => 'Әзірге мақсаттар жоқ';

  @override
  String get noGoalsYetShort => 'Әзірге мақсаттарыңыз жоқ';

  @override
  String get addGoalHint => 'Жаңа мақсат қосу үшін + батырмасын басыңыз';

  @override
  String get categorySavings => 'Жинақ';

  @override
  String get categoryTravel => 'Саяхат';

  @override
  String get categoryProperty => 'Жылжымай мүлік';

  @override
  String get categoryOther => 'Басқа';

  @override
  String goalTargetPrefix(String amount) {
    return 'Мақсат: $amount ₸';
  }

  @override
  String goalCollected(String amount) {
    return '$amount ₸ жиналды';
  }

  @override
  String get newBudget => 'Жаңа бюджет';

  @override
  String get budgetCategoryHint => 'Санат (мыс. Көлік, Тамақ)';

  @override
  String get budgetLimitLabel => 'Лимит (₸)';

  @override
  String get createBudget => 'Бюджет құру';

  @override
  String get budgetTitle => 'Бюджет';

  @override
  String get currentMonth => 'Ағымдағы ай';

  @override
  String get noBudgetsYet => 'Әзірге бюджеттер жоқ';

  @override
  String get addBudgetHint => 'Жаңа бюджет қосу үшін + батырмасын басыңыз';

  @override
  String budgetLimitPrefix(String amount) {
    return 'Лимит: $amount ₸';
  }

  @override
  String get budgetExceeded => 'Асып кетті';

  @override
  String budgetRemaining(String amount) {
    return '$amount ₸ қалды';
  }

  @override
  String budgetSpent(String amount) {
    return '$amount ₸ жұмсалды';
  }

  @override
  String get incomeTitleFieldHint => 'Табыс атауы (мыс. Жалақы, Премия)';

  @override
  String get amountFieldLabel => 'Сомасы (₸)';

  @override
  String get commentFieldLabel => 'Комментарий';

  @override
  String get commentFieldHint => 'Себеп-салдары';

  @override
  String get chooseBudgetCategory => 'Бюджет санатынан таңдаңыз';

  @override
  String get goalSelected => 'Мақсат таңдалды';

  @override
  String get noBudgetCategoriesYet =>
      'Әзірге бюджет санаттары жоқ. Алдымен \"Бюджет\" бетінде санат құрыңыз';

  @override
  String get addToGoalQuestion => 'Мақсатқа қосу керек пе?';

  @override
  String get categorySelected => 'Санат таңдалды';

  @override
  String get addButton => 'Қосу';

  @override
  String get enterValidAmount => 'Соманы дұрыс енгізіңіз';

  @override
  String get recentTransactions => 'Соңғы транзакциялар';

  @override
  String get noTransactions => 'Транзакциялар жоқ';

  @override
  String get addTransactionHint =>
      'Жаңа жазба қосу үшін жоғарыдағы\nбатырманы басыңыз';

  @override
  String get totalBalance => 'ЖАЛПЫ БАЛАНС';

  @override
  String get incomeMini => 'Түсім';

  @override
  String get topUp => 'Толықтыру';

  @override
  String get spend => 'Жұмсау';

  @override
  String get navHome => 'Басты бет';

  @override
  String get newTransaction => 'Жаңа транзакция';

  @override
  String get analyticsTitle => 'Аналитика';

  @override
  String get filterWeek => 'Апта';

  @override
  String get filterMonth => 'Ай';

  @override
  String get filterYear => 'Жыл';

  @override
  String get balanceDynamics => 'Баланс динамикасы';

  @override
  String get balanceDynamicsSubtitle => 'Әр транзакциядан кейінгі өзгеріс';

  @override
  String get expensesByCategory => 'Шығындар санаты бойынша';

  @override
  String get noExpensesInPeriod => 'Тандалған уақыт аралығында деректер жоқ';

  @override
  String get noExpensesRegisteredInPeriod =>
      'Бұл мерзімде шығындар тіркелмеген';

  @override
  String get frequentlyAskedQuestions => 'Жиі қойылатын сұрақтар';

  @override
  String get faqSectionTitle => 'Жиі қойылатын сұрақтар';

  @override
  String get faqQ1 => 'Транзакцияны қалай қосамын?';

  @override
  String get faqA1 =>
      'Басты беттегі \"Толықтыру\" немесе \"Жұмсау\" батырмасын басыңыз, соманы, санатты (қажет болса) және комментарий енгізіп, \"Қосу\" батырмасын басыңыз.';

  @override
  String get faqQ2 => 'Мақсат пен бюджеттің айырмашылығы неде?';

  @override
  String get faqA2 =>
      'Бюджет — белгілі бір санатқа (мыс. Тамақ) айлық шығын лимитін қоюға көмектеседі. Мақсат — белгілі бір соманы жинауға арналған (мыс. саяхатқа ақша жинау).';

  @override
  String get faqQ3 => 'Транзакцияны өшірсем, бюджет/мақсат саны өзгере ме?';

  @override
  String get faqA3 =>
      'Иә. Транзакцияны өшіргенде, егер ол мақсатқа байланысты болса — мақсаттың жиналған сомасынан автоматты түрде алынып тасталады.';

  @override
  String get faqQ4 => 'Деректерім қауіпсіз бе?';

  @override
  String get faqA4 =>
      'Барлық деректер Google Firebase серверлерінде сақталады және тек сіздің аккаунтыңызбен байланысты. Профиль бетіндегі \"Қауіпсіздік\" бөлімінен құпия сөзді кез келген уақытта өзгерте аласыз.';

  @override
  String get faqQ5 => 'Аналитика бетіндегі баланс графигі нені көрсетеді?';

  @override
  String get faqA5 =>
      'Ол таңдалған кезең ішіндегі әрбір транзакциядан кейінгі жинақталған балансты көрсетеді — әр нүкте бір транзакцияға сәйкес келеді.';

  @override
  String get editProfile => 'Деректерді өңдеу';

  @override
  String get photoChangeComingSoon =>
      'Профиль суретін өзгерту жақын арада қолжетімді болады';

  @override
  String get tapToChangePhoto => 'Суретті ауыстыру үшін басыңыз';

  @override
  String get contactSupportToChangeEmail =>
      'Email өзгерту үшін қолдау қызметіне хабарласыңыз';

  @override
  String get save => 'Сақтау';

  @override
  String get saveButton => 'Сақтау';

  @override
  String get couldNotOpenLink => 'Сілтемені ашу мүмкін болмады';

  @override
  String get appName => 'Қаржылай сауаттылық';

  @override
  String get financialLiteracy => 'Қаржылай сауаттылық';

  @override
  String get aboutAppDescription =>
      'Бұл қолданба сіздің күнделікті кірістеріңіз бен шығыстарыңызды бақылауға, бюджет орнатуға және қаржылай мақсаттарға жетуге көмектеседі. Барлық деректеріңіз қауіпсіз түрде сақталады және тек сізге ғана қолжетімді.';

  @override
  String get termsOfUse => 'Пайдалану шарттары';

  @override
  String get privacyPolicy => 'Құпиялылық саясаты';

  @override
  String get rateApp => 'Қолданбаны бағалау';

  @override
  String copyrightNotice(int year) {
    return '© $year Kipy. Барлық құқықтар қорғалған.';
  }

  @override
  String get notificationsTitle => 'Хабарландырулар';

  @override
  String get noNotifications => 'Хабарландырулар жоқ';

  @override
  String get goalReachedTitle => 'Мақсатқа жеттіңіз! 🎉';

  @override
  String goalReachedMessage(String goalTitle) {
    return '«$goalTitle» мақсаты үшін қаражат толық жиналды.';
  }

  @override
  String get budgetExceededTitle => 'Бюджет лимиті асып кетті';

  @override
  String budgetExceededMessage(String category) {
    return '«$category» санаты бойынша шығын лимиттен асты.';
  }
}
