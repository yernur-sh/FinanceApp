// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Personal Finances';

  @override
  String get income => 'Income';

  @override
  String get expense => 'Expense';

  @override
  String get category => 'Category';

  @override
  String get loginRequired => 'Login required';

  @override
  String errorWithMessage(String message) {
    return 'Error: $message';
  }

  @override
  String get fillAllFieldsCorrectly => 'Please fill in all fields correctly';

  @override
  String get otherCategory => 'Other';

  @override
  String get userNotFound => 'No such user found';

  @override
  String get wrongPassword => 'Incorrect password';

  @override
  String get invalidEmail => 'Email entered incorrectly';

  @override
  String get invalidCredential => 'Email or password is incorrect';

  @override
  String get loginTitle => 'Log In';

  @override
  String get loginSubtitle => 'Continue tracking your finances';

  @override
  String get emailLabel => 'Email';

  @override
  String get emailRequired => 'Enter your email';

  @override
  String get emailInvalid => 'Enter a valid email';

  @override
  String get passwordLabel => 'Password';

  @override
  String get passwordTooShort => 'Must be at least 6 characters';

  @override
  String get noAccountRegister => 'Don\'t have an account? Sign up';

  @override
  String get logoutTitle => 'Log Out';

  @override
  String get logoutConfirm =>
      'Are you sure you want to log out of your account?';

  @override
  String get cancel => 'Cancel';

  @override
  String get logoutAction => 'Log Out';

  @override
  String get logoutButton => 'Log out of account';

  @override
  String get userFallback => 'User';

  @override
  String get profileTitle => 'Profile';

  @override
  String get personalSettings => 'Personal Settings';

  @override
  String get editData => 'Edit Data';

  @override
  String get editDataSubtitle => 'Name, profile photo';

  @override
  String get notifications => 'Notifications';

  @override
  String get notificationsSubtitle => 'Alerts';

  @override
  String get noNotificationsYet => 'No notifications yet';

  @override
  String get security => 'Security';

  @override
  String get securitySubtitle => 'Change password';

  @override
  String get appSection => 'App';

  @override
  String get helpSupport => 'Help & Support';

  @override
  String get helpAndSupport => 'Help and support';

  @override
  String get aboutApp => 'About the app';

  @override
  String appVersion(String version) {
    return 'Version v$version';
  }

  @override
  String get passwordChangedSuccess => 'Password changed successfully';

  @override
  String get wrongCurrentPassword => 'Current password is incorrect';

  @override
  String get currentPasswordWrong => 'Current password is incorrect';

  @override
  String get newPasswordTooWeak => 'New password is too weak';

  @override
  String get newPasswordWeak => 'New password is too weak';

  @override
  String get requiresRecentLogin =>
      'For security, please log in again. Sign out and sign back in';

  @override
  String get tooManyRequests => 'Too many attempts. Please try again later';

  @override
  String get nonEmailAccountNotice =>
      'Your account was registered via another provider, not email/password. You can\'t change the password here.';

  @override
  String get otherProviderAccountNotice =>
      'Your account was registered through another provider, not email/password. You can\'t change the password from here.';

  @override
  String get changePassword => 'Change password';

  @override
  String get currentPassword => 'Current password';

  @override
  String get currentPasswordLabel => 'Current password';

  @override
  String get enterCurrentPassword => 'Enter your current password';

  @override
  String get newPassword => 'New password';

  @override
  String get newPasswordLabel => 'New password';

  @override
  String get minSixCharacters => 'Must be at least 6 characters';

  @override
  String get newPasswordMustDiffer =>
      'New password must differ from the old one';

  @override
  String get confirmNewPassword => 'Confirm new password';

  @override
  String get confirmNewPasswordLabel => 'Repeat new password';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match';

  @override
  String get savePassword => 'Save password';

  @override
  String get savePasswordButton => 'Save password';

  @override
  String get emailAlreadyInUse => 'This email is already registered';

  @override
  String get passwordTooWeak => 'Password is too weak';

  @override
  String get passwordWeak => 'Password is too weak';

  @override
  String get register => 'Register';

  @override
  String get registerTitle => 'Sign Up';

  @override
  String get createNewAccountSubtitle => 'Create a new account to get started';

  @override
  String get registerSubtitle => 'Create a new account to get started';

  @override
  String get fullName => 'Full name';

  @override
  String get fullNameLabel => 'Full name';

  @override
  String get enterYourName => 'Enter your name';

  @override
  String get email => 'Email';

  @override
  String get enterValidEmail => 'Enter a valid email';

  @override
  String get password => 'Password';

  @override
  String get confirmPassword => 'Confirm password';

  @override
  String get confirmPasswordLabel => 'Repeat password';

  @override
  String get newGoal => 'New Goal';

  @override
  String get goalNameLabel => 'Goal name';

  @override
  String get goalTargetAmountLabel => 'Target amount (₸)';

  @override
  String get selectDeadlineOptional => 'Choose deadline (optional)';

  @override
  String get createGoal => 'Create Goal';

  @override
  String get goalsTitle => 'Goals';

  @override
  String get activeGoals => 'Active goals';

  @override
  String get noGoalsYet => 'No goals yet';

  @override
  String get noGoalsYetShort => 'You don\'t have any goals yet';

  @override
  String get addGoalHint => 'Tap + to add a new goal';

  @override
  String get categorySavings => 'Savings';

  @override
  String get categoryTravel => 'Travel';

  @override
  String get categoryProperty => 'Property';

  @override
  String get categoryOther => 'Other';

  @override
  String goalTargetPrefix(String amount) {
    return 'Target: $amount ₸';
  }

  @override
  String goalCollected(String amount) {
    return '$amount ₸ collected';
  }

  @override
  String get newBudget => 'New Budget';

  @override
  String get budgetCategoryHint => 'Category (e.g. Transport, Food)';

  @override
  String get budgetLimitLabel => 'Limit (₸)';

  @override
  String get createBudget => 'Create Budget';

  @override
  String get budgetTitle => 'Budget';

  @override
  String get currentMonth => 'Current month';

  @override
  String get noBudgetsYet => 'No budgets yet';

  @override
  String get addBudgetHint => 'Tap + to add a new budget';

  @override
  String budgetLimitPrefix(String amount) {
    return 'Limit: $amount ₸';
  }

  @override
  String get budgetExceeded => 'Exceeded';

  @override
  String budgetRemaining(String amount) {
    return '$amount ₸ remaining';
  }

  @override
  String budgetSpent(String amount) {
    return '$amount ₸ spent';
  }

  @override
  String get incomeTitleFieldHint => 'Income name (e.g. Salary, Bonus)';

  @override
  String get amountFieldLabel => 'Amount (₸)';

  @override
  String get commentFieldLabel => 'Comment';

  @override
  String get commentFieldHint => 'Reason';

  @override
  String get chooseBudgetCategory => 'Choose a budget category';

  @override
  String get goalSelected => 'Goal selected';

  @override
  String get noBudgetCategoriesYet =>
      'No budget categories yet. First create a category on the \"Budget\" page';

  @override
  String get addToGoalQuestion => 'Add to a goal?';

  @override
  String get categorySelected => 'Category selected';

  @override
  String get addButton => 'Add';

  @override
  String get enterValidAmount => 'Enter a valid amount';

  @override
  String get recentTransactions => 'Recent transactions';

  @override
  String get noTransactions => 'No transactions';

  @override
  String get addTransactionHint => 'Tap the button above\nto add a new entry';

  @override
  String get totalBalance => 'TOTAL BALANCE';

  @override
  String get incomeMini => 'Income';

  @override
  String get topUp => 'Top Up';

  @override
  String get spend => 'Spend';

  @override
  String get navHome => 'Home';

  @override
  String get newTransaction => 'New Transaction';

  @override
  String get analyticsTitle => 'Analytics';

  @override
  String get filterWeek => 'Week';

  @override
  String get filterMonth => 'Month';

  @override
  String get filterYear => 'Year';

  @override
  String get balanceDynamics => 'Balance dynamics';

  @override
  String get balanceDynamicsSubtitle => 'Change after each transaction';

  @override
  String get expensesByCategory => 'Expenses by category';

  @override
  String get noExpensesInPeriod => 'No data for the selected period';

  @override
  String get noExpensesRegisteredInPeriod =>
      'No expenses recorded for this period';

  @override
  String get frequentlyAskedQuestions => 'Frequently asked questions';

  @override
  String get faqSectionTitle => 'Frequently Asked Questions';

  @override
  String get faqQ1 => 'How do I add a transaction?';

  @override
  String get faqA1 =>
      'Tap the \"Top Up\" or \"Spend\" button on the home screen, enter the amount, category (if needed), and a comment, then tap \"Add\".';

  @override
  String get faqQ2 => 'What\'s the difference between a goal and a budget?';

  @override
  String get faqA2 =>
      'A budget helps you set a monthly spending limit for a specific category (e.g. Food). A goal is for saving up a specific amount (e.g. saving for a trip).';

  @override
  String get faqQ3 =>
      'If I delete a transaction, will the budget/goal amount change?';

  @override
  String get faqA3 =>
      'Yes. When you delete a transaction linked to a goal, the amount is automatically subtracted from the goal\'s collected total.';

  @override
  String get faqQ4 => 'Is my data secure?';

  @override
  String get faqA4 =>
      'All data is stored on Google Firebase servers and is linked only to your account. You can change your password anytime in the \"Security\" section of the profile page.';

  @override
  String get faqQ5 => 'What does the balance chart on the analytics page show?';

  @override
  String get faqA5 =>
      'It shows the accumulated balance after each transaction within the selected period — each point corresponds to one transaction.';

  @override
  String get editProfile => 'Edit profile';

  @override
  String get photoChangeComingSoon =>
      'Changing profile photo will be available soon';

  @override
  String get tapToChangePhoto => 'Tap to change photo';

  @override
  String get contactSupportToChangeEmail =>
      'Contact support to change your email';

  @override
  String get save => 'Save';

  @override
  String get saveButton => 'Save';

  @override
  String get couldNotOpenLink => 'Could not open the link';

  @override
  String get appName => 'Financial Literacy';

  @override
  String get financialLiteracy => 'Financial Literacy';

  @override
  String get aboutAppDescription =>
      'This app helps you track your daily income and expenses, set budgets, and reach your financial goals. All your data is stored securely and is accessible only to you.';

  @override
  String get termsOfUse => 'Terms of Use';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get rateApp => 'Rate the App';

  @override
  String copyrightNotice(int year) {
    return '© $year Kipy. All rights reserved.';
  }

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String get noNotifications => 'No notifications';

  @override
  String get goalReachedTitle => 'Goal Reached! 🎉';

  @override
  String goalReachedMessage(String goalTitle) {
    return 'Funds have been fully collected for the goal «$goalTitle».';
  }

  @override
  String get budgetExceededTitle => 'Budget Limit Exceeded';

  @override
  String budgetExceededMessage(String category) {
    return 'Spending limit exceeded for category «$category».';
  }
}
