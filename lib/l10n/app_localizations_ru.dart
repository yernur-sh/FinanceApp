// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'Личные финансы';

  @override
  String get income => 'Доход';

  @override
  String get expense => 'Расход';

  @override
  String get category => 'Категория';

  @override
  String get loginRequired => 'Необходимо войти';

  @override
  String errorWithMessage(String message) {
    return 'Ошибка: $message';
  }

  @override
  String get fillAllFieldsCorrectly => 'Заполните все поля правильно';

  @override
  String get otherCategory => 'Другое';

  @override
  String get userNotFound => 'Такой пользователь не найден';

  @override
  String get wrongPassword => 'Неверный пароль';

  @override
  String get invalidEmail => 'Email введён неверно';

  @override
  String get invalidCredential => 'Email или пароль неверны';

  @override
  String get loginTitle => 'Войти';

  @override
  String get loginSubtitle => 'Продолжайте контролировать свои финансы';

  @override
  String get emailLabel => 'Email';

  @override
  String get emailRequired => 'Введите email';

  @override
  String get emailInvalid => 'Введите корректный email';

  @override
  String get passwordLabel => 'Пароль';

  @override
  String get passwordTooShort => 'Должно быть не менее 6 символов';

  @override
  String get noAccountRegister => 'Нет аккаунта? Зарегистрироваться';

  @override
  String get logoutTitle => 'Выход из системы';

  @override
  String get logoutConfirm => 'Вы действительно хотите выйти из аккаунта?';

  @override
  String get cancel => 'Отмена';

  @override
  String get logoutAction => 'Выйти';

  @override
  String get logoutButton => 'Выйти из аккаунта';

  @override
  String get userFallback => 'Пользователь';

  @override
  String get profileTitle => 'Профиль';

  @override
  String get personalSettings => 'Личные настройки';

  @override
  String get editData => 'Редактировать данные';

  @override
  String get editDataSubtitle => 'Имя, фото профиля';

  @override
  String get notifications => 'Уведомления';

  @override
  String get notificationsSubtitle => 'Оповещения';

  @override
  String get noNotificationsYet => 'Пока нет уведомлений';

  @override
  String get security => 'Безопасность';

  @override
  String get securitySubtitle => 'Изменить пароль';

  @override
  String get appSection => 'Приложение';

  @override
  String get helpSupport => 'Помощь и поддержка';

  @override
  String get helpAndSupport => 'Помощь и поддержка';

  @override
  String get aboutApp => 'О приложении';

  @override
  String appVersion(String version) {
    return 'Версия v$version';
  }

  @override
  String get passwordChangedSuccess => 'Пароль успешно изменён';

  @override
  String get wrongCurrentPassword => 'Текущий пароль неверен';

  @override
  String get currentPasswordWrong => 'Текущий пароль неверен';

  @override
  String get newPasswordTooWeak => 'Новый пароль слишком слабый';

  @override
  String get newPasswordWeak => 'Новый пароль слишком слабый';

  @override
  String get requiresRecentLogin =>
      'Для безопасности требуется повторный вход. Выйдите и войдите снова';

  @override
  String get tooManyRequests => 'Слишком много попыток. Повторите чуть позже';

  @override
  String get nonEmailAccountNotice =>
      'Ваш аккаунт зарегистрирован не через email/пароль, а через другого провайдера. Изменить пароль здесь невозможно.';

  @override
  String get otherProviderAccountNotice =>
      'Ваш аккаунт зарегистрирован через другого провайдера, а не через email/пароль. Изменить пароль отсюда невозможно.';

  @override
  String get changePassword => 'Изменить пароль';

  @override
  String get currentPassword => 'Текущий пароль';

  @override
  String get currentPasswordLabel => 'Текущий пароль';

  @override
  String get enterCurrentPassword => 'Введите текущий пароль';

  @override
  String get newPassword => 'Новый пароль';

  @override
  String get newPasswordLabel => 'Новый пароль';

  @override
  String get minSixCharacters => 'Должно быть не менее 6 символов';

  @override
  String get newPasswordMustDiffer =>
      'Новый пароль должен отличаться от старого';

  @override
  String get confirmNewPassword => 'Повторите новый пароль';

  @override
  String get confirmNewPasswordLabel => 'Повторите новый пароль';

  @override
  String get passwordsDoNotMatch => 'Пароли не совпадают';

  @override
  String get savePassword => 'Сохранить пароль';

  @override
  String get savePasswordButton => 'Сохранить пароль';

  @override
  String get emailAlreadyInUse => 'Этот email уже зарегистрирован';

  @override
  String get passwordTooWeak => 'Пароль слишком слабый';

  @override
  String get passwordWeak => 'Пароль слишком слабый';

  @override
  String get register => 'Регистрация';

  @override
  String get registerTitle => 'Регистрация';

  @override
  String get createNewAccountSubtitle => 'Создайте новый аккаунт и начните';

  @override
  String get registerSubtitle => 'Создайте новый аккаунт и начните';

  @override
  String get fullName => 'Имя и фамилия';

  @override
  String get fullNameLabel => 'Имя';

  @override
  String get enterYourName => 'Введите ваше имя';

  @override
  String get email => 'Email';

  @override
  String get enterValidEmail => 'Введите корректный email';

  @override
  String get password => 'Пароль';

  @override
  String get confirmPassword => 'Повторите пароль';

  @override
  String get confirmPasswordLabel => 'Повторите пароль';

  @override
  String get newGoal => 'Новая цель';

  @override
  String get goalNameLabel => 'Название цели';

  @override
  String get goalTargetAmountLabel => 'Целевая сумма (₸)';

  @override
  String get selectDeadlineOptional => 'Выбрать срок (необязательно)';

  @override
  String get createGoal => 'Создать цель';

  @override
  String get goalsTitle => 'Цели';

  @override
  String get activeGoals => 'Активные цели';

  @override
  String get noGoalsYet => 'Пока целей нет';

  @override
  String get noGoalsYetShort => 'У вас пока нет целей';

  @override
  String get addGoalHint => 'Нажмите +, чтобы добавить новую цель';

  @override
  String get categorySavings => 'Сбережения';

  @override
  String get categoryTravel => 'Путешествия';

  @override
  String get categoryProperty => 'Недвижимость';

  @override
  String get categoryOther => 'Другое';

  @override
  String goalTargetPrefix(String amount) {
    return 'Цель: $amount ₸';
  }

  @override
  String goalCollected(String amount) {
    return 'Накоплено $amount ₸';
  }

  @override
  String get newBudget => 'Новый бюджет';

  @override
  String get budgetCategoryHint => 'Категория (напр. Транспорт, Еда)';

  @override
  String get budgetLimitLabel => 'Лимит (₸)';

  @override
  String get createBudget => 'Создать бюджет';

  @override
  String get budgetTitle => 'Бюджет';

  @override
  String get currentMonth => 'Текущий месяц';

  @override
  String get noBudgetsYet => 'Пока бюджетов нет';

  @override
  String get addBudgetHint => 'Нажмите +, чтобы добавить новый бюджет';

  @override
  String budgetLimitPrefix(String amount) {
    return 'Лимит: $amount ₸';
  }

  @override
  String get budgetExceeded => 'Превышен';

  @override
  String budgetRemaining(String amount) {
    return 'Осталось $amount ₸';
  }

  @override
  String budgetSpent(String amount) {
    return 'Потрачено $amount ₸';
  }

  @override
  String get incomeTitleFieldHint => 'Название дохода (напр. Зарплата, Премия)';

  @override
  String get amountFieldLabel => 'Сумма (₸)';

  @override
  String get commentFieldLabel => 'Комментарий';

  @override
  String get commentFieldHint => 'Причина';

  @override
  String get chooseBudgetCategory => 'Выберите категорию бюджета';

  @override
  String get goalSelected => 'Цель выбрана';

  @override
  String get noBudgetCategoriesYet =>
      'Пока категорий бюджета нет. Сначала создайте категорию на странице \"Бюджет\"';

  @override
  String get addToGoalQuestion => 'Добавить к цели?';

  @override
  String get categorySelected => 'Категория выбрана';

  @override
  String get addButton => 'Добавить';

  @override
  String get enterValidAmount => 'Введите корректную сумму';

  @override
  String get recentTransactions => 'Последние транзакции';

  @override
  String get noTransactions => 'Транзакций нет';

  @override
  String get addTransactionHint =>
      'Нажмите кнопку выше,\nчтобы добавить новую запись';

  @override
  String get totalBalance => 'ОБЩИЙ БАЛАНС';

  @override
  String get incomeMini => 'Поступление';

  @override
  String get topUp => 'Пополнить';

  @override
  String get spend => 'Потратить';

  @override
  String get navHome => 'Главная';

  @override
  String get newTransaction => 'Новая транзакция';

  @override
  String get analyticsTitle => 'Аналитика';

  @override
  String get filterWeek => 'Неделя';

  @override
  String get filterMonth => 'Месяц';

  @override
  String get filterYear => 'Год';

  @override
  String get balanceDynamics => 'Динамика баланса';

  @override
  String get balanceDynamicsSubtitle => 'Изменение после каждой транзакции';

  @override
  String get expensesByCategory => 'Расходы по категориям';

  @override
  String get noExpensesInPeriod => 'За выбранный период данных нет';

  @override
  String get noExpensesRegisteredInPeriod =>
      'За этот период расходы не зафиксированы';

  @override
  String get frequentlyAskedQuestions => 'Часто задаваемые вопросы';

  @override
  String get faqSectionTitle => 'Часто задаваемые вопросы';

  @override
  String get faqQ1 => 'Как добавить транзакцию?';

  @override
  String get faqA1 =>
      'Нажмите кнопку «Пополнить» или «Потратить» на главном экране, введите сумму, категорию (при необходимости) и комментарий, затем нажмите «Добавить».';

  @override
  String get faqQ2 => 'В чём разница между целью и бюджетом?';

  @override
  String get faqA2 =>
      'Бюджет помогает установить месячный лимит расходов по определённой категории (например, «Еда»). Цель предназначена для накопления конкретной суммы (например, на поездку).';

  @override
  String get faqQ3 =>
      'Изменится ли сумма бюджета/цели, если удалить транзакцию?';

  @override
  String get faqA3 =>
      'Да. При удалении транзакции, если она была связана с целью, сумма автоматически вычитается из накопленной суммы цели.';

  @override
  String get faqQ4 => 'Безопасны ли мои данные?';

  @override
  String get faqA4 =>
      'Все данные хранятся на серверах Google Firebase и связаны только с вашим аккаунтом. В разделе «Безопасность» на странице профиля вы можете в любой момент изменить пароль.';

  @override
  String get faqQ5 => 'Что показывает график баланса на странице аналитики?';

  @override
  String get faqA5 =>
      'Он показывает накопленный баланс после каждой транзакции за выбранный период — каждая точка соответствует одной транзакции.';

  @override
  String get editProfile => 'Редактировать данные';

  @override
  String get photoChangeComingSoon =>
      'Изменение фото профиля скоро будет доступно';

  @override
  String get tapToChangePhoto => 'Нажмите, чтобы изменить фото';

  @override
  String get contactSupportToChangeEmail =>
      'Чтобы изменить email, обратитесь в службу поддержки';

  @override
  String get save => 'Сохранить';

  @override
  String get saveButton => 'Сохранить';

  @override
  String get couldNotOpenLink => 'Не удалось открыть ссылку';

  @override
  String get appName => 'Финансовая грамотность';

  @override
  String get financialLiteracy => 'Финансовая грамотность';

  @override
  String get aboutAppDescription =>
      'Это приложение помогает отслеживать ваши ежедневные доходы и расходы, устанавливать бюджет и достигать финансовых целей. Все ваши данные надёжно хранятся и доступны только вам.';

  @override
  String get termsOfUse => 'Условия использования';

  @override
  String get privacyPolicy => 'Политика конфиденциальности';

  @override
  String get rateApp => 'Оценить приложение';

  @override
  String copyrightNotice(int year) {
    return '© $year Kipy. Все права защищены.';
  }

  @override
  String get notificationsTitle => 'Уведомления';

  @override
  String get noNotifications => 'Нет уведомлений';

  @override
  String get goalReachedTitle => 'Цель достигнута! 🎉';

  @override
  String goalReachedMessage(String goalTitle) {
    return 'Средства для цели «$goalTitle» успешно собраны.';
  }

  @override
  String get budgetExceededTitle => 'Лимит бюджета превышен';

  @override
  String budgetExceededMessage(String category) {
    return 'Превышен лимит расходов по категории «$category».';
  }
}
