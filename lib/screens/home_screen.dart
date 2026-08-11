import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/transaction_model.dart';
import '../theme/app_theme.dart';
import 'profile_screen.dart';
import 'goals_screen.dart';
import 'analytics_screen.dart';
import 'budget_screen.dart';
import 'notifications_screen.dart';
import '../models/goal_model.dart';
import '../models/budget_model.dart';
import '../services/notification_service.dart';
import '../l10n/app_localizations.dart';

/// Базадағы хардкод немесе кілттік сөздерді тілге сай аударуға арналған extension
extension TransactionCategoryLocalizer on String {
  String getLocalizedCategory(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final val = toLowerCase().trim();

    if (val == 'табыс' || val == 'доход' || val == 'income') {
      return l10n.income;
    }
    if (val == 'шығын' || val == 'расход' || val == 'expense') {
      return l10n.expense;
    }
    return this; // Басқа арнайы категория болса өзін қайтарады
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final _firestore = FirebaseFirestore.instance;
  late final Stream<List<TransactionModel>> _transactionsStream;

  StreamSubscription<QuerySnapshot>? _goalsWatchSub;
  StreamSubscription<QuerySnapshot>? _transWatchSub;
  StreamSubscription<QuerySnapshot>? _budgetsWatchSub;

  String? get _userId => FirebaseAuth.instance.currentUser?.uid;

  @override
  void initState() {
    super.initState();
    _transactionsStream = _buildTransactionsStream();
    _startBackgroundWatchers();
  }

  @override
  void dispose() {
    _goalsWatchSub?.cancel();
    _transWatchSub?.cancel();
    _budgetsWatchSub?.cancel();
    super.dispose();
  }

  Stream<List<TransactionModel>> _buildTransactionsStream() {
    if (_userId == null) return const Stream.empty();
    return _firestore
        .collection('transactions')
        .where('userId', isEqualTo: _userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) =>
        snap.docs.map((doc) => TransactionModel.fromDoc(doc)).toList());
  }

  void _startBackgroundWatchers() {
    if (_userId == null) return;

    _goalsWatchSub = _firestore
        .collection('goals')
        .where('userId', isEqualTo: _userId)
        .snapshots()
        .listen((snap) {
      for (final doc in snap.docs) {
        final goal = GoalModel.fromDoc(doc);
        if (goal.progress >= 1) {
          NotificationService.notifyGoalCompleted(
            userId: _userId!,
            goalId: goal.id,
            goalTitle: goal.title,
          );
        }
      }
    });

    _transWatchSub = _firestore
        .collection('transactions')
        .where('userId', isEqualTo: _userId)
        .snapshots()
        .listen((_) => _checkBudgets());

    final now = DateTime.now();
    _budgetsWatchSub = _firestore
        .collection('budgets')
        .where('userId', isEqualTo: _userId)
        .where('month', isEqualTo: now.month)
        .where('year', isEqualTo: now.year)
        .snapshots()
        .listen((_) => _checkBudgets());
  }

  Future<void> _checkBudgets() async {
    if (_userId == null) return;

    final now = DateTime.now();
    final budgetsSnap = await _firestore
        .collection('budgets')
        .where('userId', isEqualTo: _userId)
        .where('month', isEqualTo: now.month)
        .where('year', isEqualTo: now.year)
        .get();

    for (final doc in budgetsSnap.docs) {
      final budget = BudgetModel.fromDoc(doc);
      final spent = await _getSpentForCategory(
        budget.category,
        budget.month,
        budget.year,
      );
      if (spent > budget.limit) {
        NotificationService.notifyBudgetExceeded(
          userId: _userId!,
          budgetId: budget.id,
          category: budget.category,
          month: budget.month,
          year: budget.year,
        );
      }
    }
  }

  Future<double> _getSpentForCategory(
      String category,
      int month,
      int year,
      ) async {
    if (_userId == null) return 0.0;

    final start = DateTime(year, month, 1);
    final end = DateTime(year, month + 1, 1);

    final snapshot = await _firestore
        .collection('transactions')
        .where('userId', isEqualTo: _userId)
        .where('category', isEqualTo: category)
        .get();

    double total = 0.0;
    for (final doc in snapshot.docs) {
      final data = doc.data();
      final type = data['type']?.toString();
      final createdAtTimestamp = data['createdAt'] as Timestamp?;

      if (type == 'expense' || type == 'TransactionType.expense') {
        if (createdAtTimestamp != null) {
          final date = createdAtTimestamp.toDate();
          if (date.isAfter(start.subtract(const Duration(seconds: 1))) &&
              date.isBefore(end)) {
            total += (data['amount'] as num).toDouble();
          }
        } else {
          total += (data['amount'] as num).toDouble();
        }
      }
    }
    return total;
  }

  Future<void> _deleteTransaction(TransactionModel transaction) async {
    final batch = _firestore.batch();
    final transRef =
    _firestore.collection('transactions').doc(transaction.id);
    batch.delete(transRef);

    if (transaction.goalId != null) {
      final goalRef = _firestore.collection('goals').doc(transaction.goalId);
      batch.update(goalRef, {
        'currentAmount': FieldValue.increment(-transaction.amount),
      });
    }

    await batch.commit();
  }

  void _addTransaction(
      {TransactionType initialType = TransactionType.expense}) {
    final titleController = TextEditingController();
    final amountController = TextEditingController();
    final noteController = TextEditingController();

    TransactionType selectedType = initialType;
    String? selectedGoalId;
    String? selectedBudgetCategory;

    final now = DateTime.now();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: kSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final l10n = AppLocalizations.of(context)!;

            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 14,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        width: 38,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 18),
                        decoration: BoxDecoration(
                          color: kBorderStrong,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    Text(
                      l10n.newTransaction,
                      style: appDisplay(
                          fontSize: 19, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 18),
                    SegmentedButton<TransactionType>(
                      style: SegmentedButton.styleFrom(
                        backgroundColor: Colors.white.withOpacity(0.05),
                        foregroundColor: kTextSecondary,
                        selectedBackgroundColor: kAccent,
                        selectedForegroundColor: Colors.white,
                        side: const BorderSide(color: kBorder),
                        textStyle: GoogleFonts.inter(
                            fontWeight: FontWeight.w600, fontSize: 13.5),
                      ),
                      segments: [
                        ButtonSegment(
                          value: TransactionType.income,
                          label: Text(l10n.income),
                          icon: const Icon(Icons.arrow_upward_rounded,
                              size: 16),
                        ),
                        ButtonSegment(
                          value: TransactionType.expense,
                          label: Text(l10n.expense),
                          icon: const Icon(Icons.arrow_downward_rounded,
                              size: 16),
                        ),
                      ],
                      selected: {selectedType},
                      onSelectionChanged: (value) {
                        setModalState(() {
                          selectedType = value.first;
                          if (selectedType == TransactionType.income) {
                            selectedGoalId = null;
                            selectedBudgetCategory = null;
                          }
                        });
                      },
                    ),
                    const SizedBox(height: 18),
                    if (selectedType == TransactionType.income) ...[
                      TextField(
                        controller: titleController,
                        style: appBody(fontSize: 14.5),
                        decoration: appFieldDecoration(
                            l10n.incomeTitleFieldHint),
                      ),
                      const SizedBox(height: 12),
                    ],
                    TextField(
                      controller: amountController,
                      keyboardType: TextInputType.number,
                      style: appBody(fontSize: 14.5),
                      decoration:
                      appFieldDecoration(l10n.amountFieldLabel),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: noteController,
                      maxLines: 2,
                      style: appBody(fontSize: 14.5),
                      decoration: appFieldDecoration(l10n.commentFieldLabel,
                          hint: l10n.commentFieldHint),
                    ),
                    if (selectedType == TransactionType.expense) ...[
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            l10n.chooseBudgetCategory,
                            style: appBody(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w600,
                                color: kTextPrimary),
                          ),
                          if (selectedGoalId != null)
                            Text(l10n.goalSelected,
                                style: appBody(
                                    color: kTextMuted, fontSize: 11.5)),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Opacity(
                        opacity: selectedGoalId != null ? 0.4 : 1,
                        child: IgnorePointer(
                          ignoring: selectedGoalId != null,
                          child: StreamBuilder<QuerySnapshot>(
                            stream: _userId == null
                                ? null
                                : _firestore
                                .collection('budgets')
                                .where('userId', isEqualTo: _userId)
                                .where('month', isEqualTo: now.month)
                                .where('year', isEqualTo: now.year)
                                .snapshots(),
                            builder: (context, budgetSnapshot) {
                              if (!budgetSnapshot.hasData) {
                                return const SizedBox(
                                  height: 32,
                                  child: Center(
                                    child: SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2, color: kAmber),
                                    ),
                                  ),
                                );
                              }

                              final budgets = budgetSnapshot.data!.docs
                                  .map((d) => BudgetModel.fromDoc(d))
                                  .toList();

                              if (budgets.isEmpty) {
                                return Text(
                                  l10n.noBudgetCategoriesYet,
                                  style: appBody(
                                      color: kTextMuted, fontSize: 12.5),
                                );
                              }

                              return Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: budgets.map((b) {
                                  final selected =
                                      selectedBudgetCategory == b.category;
                                  return ChoiceChip(
                                    label: Text(b.category),
                                    selected: selected,
                                    backgroundColor:
                                    Colors.white.withOpacity(0.05),
                                    selectedColor: kAccent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      side: BorderSide(
                                          color: selected ? kAccent : kBorder),
                                    ),
                                    labelStyle: appBody(
                                      color: selected
                                          ? Colors.white
                                          : kTextSecondary,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    onSelected: (isSelected) {
                                      setModalState(() {
                                        selectedBudgetCategory =
                                        isSelected ? b.category : null;
                                        if (isSelected) selectedGoalId = null;
                                      });
                                    },
                                  );
                                }).toList(),
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            l10n.addToGoalQuestion,
                            style: appBody(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w600,
                                color: kTextPrimary),
                          ),
                          if (selectedBudgetCategory != null)
                            Text(l10n.categorySelected,
                                style: appBody(
                                    color: kTextMuted, fontSize: 11.5)),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Opacity(
                        opacity: selectedBudgetCategory != null ? 0.4 : 1,
                        child: IgnorePointer(
                          ignoring: selectedBudgetCategory != null,
                          child: StreamBuilder<QuerySnapshot>(
                            stream: _userId == null
                                ? null
                                : _firestore
                                .collection('goals')
                                .where('userId', isEqualTo: _userId)
                                .snapshots(),
                            builder: (context, goalSnapshot) {
                              if (!goalSnapshot.hasData) {
                                return const SizedBox(
                                  height: 32,
                                  child: Center(
                                    child: SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2, color: kAmber),
                                    ),
                                  ),
                                );
                              }

                              final goals = goalSnapshot.data!.docs
                                  .map((d) => GoalModel.fromDoc(d))
                                  .toList();

                              if (goals.isEmpty) {
                                return Text(
                                  l10n.noGoalsYetShort,
                                  style: appBody(
                                      color: kTextMuted, fontSize: 12.5),
                                );
                              }

                              return Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: goals.map((g) {
                                  final selected = selectedGoalId == g.id;
                                  return ChoiceChip(
                                    label: Text(g.title),
                                    selected: selected,
                                    backgroundColor:
                                    Colors.white.withOpacity(0.05),
                                    selectedColor: kAmber,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      side: BorderSide(
                                          color: selected ? kAmber : kBorder),
                                    ),
                                    labelStyle: appBody(
                                      color: selected
                                          ? Colors.black87
                                          : kTextSecondary,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    onSelected: (isSelected) {
                                      setModalState(() {
                                        selectedGoalId =
                                        isSelected ? g.id : null;
                                        if (isSelected) {
                                          selectedBudgetCategory = null;
                                        }
                                      });
                                    },
                                  );
                                }).toList(),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 22),
                    GradientButton(
                      label: l10n.addButton,
                      onPressed: () async {
                        final amount =
                        double.tryParse(amountController.text.trim());
                        if (amount == null || amount <= 0) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text(l10n.enterValidAmount)),
                          );
                          return;
                        }

                        if (_userId == null) return;

                        final isExpense =
                            selectedType == TransactionType.expense;
                        final enteredTitle = titleController.text.trim();
                        final enteredNote = noteController.text.trim();

                        // 🌐 Хардкод сөздердің орнына кілт сөз сақталады
                        String finalTitle = isExpense ? 'Expense' : 'Income';
                        String finalCategory = isExpense ? 'Expense' : 'Income';

                        if (!isExpense) {
                          if (enteredTitle.isNotEmpty) {
                            finalTitle = enteredTitle;
                          }
                        } else {
                          if (selectedGoalId != null) {
                            final goalDoc = await _firestore
                                .collection('goals')
                                .doc(selectedGoalId)
                                .get();
                            if (goalDoc.exists) {
                              finalTitle = goalDoc.get('title') ?? 'Goal';
                              finalCategory = goalDoc.get('title') ?? 'Goal';
                            }
                          } else if (selectedBudgetCategory != null) {
                            finalTitle = selectedBudgetCategory!;
                            finalCategory = selectedBudgetCategory!;
                          }
                        }

                        final newTransaction = TransactionModel(
                          id: '',
                          title: finalTitle,
                          category: finalCategory,
                          amount: amount,
                          type: selectedType,
                          date: DateTime.now(),
                          goalId: selectedGoalId,
                          note: enteredNote.isEmpty ? null : enteredNote,
                        );

                        if (context.mounted) Navigator.pop(context);

                        final batch = _firestore.batch();
                        final transRef =
                        _firestore.collection('transactions').doc();
                        batch.set(transRef, newTransaction.toMap(_userId!));

                        if (selectedGoalId != null) {
                          final goalRef = _firestore
                              .collection('goals')
                              .doc(selectedGoalId);
                          batch.update(goalRef, {
                            'currentAmount': FieldValue.increment(amount),
                          });
                        }

                        await batch.commit();
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  String _formatMoney(double value) {
    final formatter = NumberFormat('#,##0', 'ru');
    return formatter.format(value).replaceAll(',', ' ');
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _buildHomeContent(),
      const AnalyticsScreen(),
      const GoalsScreen(),
      const BudgetScreen(),
      const ProfileScreen(embedded: true),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF03050A),
      extendBody: true,
      body: Stack(
        children: [
          const Positioned.fill(
            child: AppBackground(safeArea: false, child: SizedBox.expand()),
          ),
          SafeArea(
            bottom: false,
            child: pages[_selectedIndex],
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              top: false,
              child: _GlassBottomBar(
                selectedIndex: _selectedIndex,
                onSelect: (index) => setState(() => _selectedIndex = index),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHomeContent() {
    return StreamBuilder<List<TransactionModel>>(
      stream: _transactionsStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: kAccent));
        }
        if (snapshot.hasError) {
          return Center(
              child: Text(
                  AppLocalizations.of(context)!
                      .errorWithMessage('${snapshot.error}'),
                  style: appBody(color: kTextSecondary)));
        }

        final transactions = snapshot.data ?? [];

        final income = transactions
            .where((t) => t.type == TransactionType.income)
            .fold(0.0, (sum, t) => sum + t.amount);

        final expense = transactions
            .where((t) => t.type == TransactionType.expense)
            .fold(0.0, (sum, t) => sum + t.amount);

        final balance = income - expense;

        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 120),
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(AppLocalizations.of(context)!.appTitle,
                          style: appDisplay(
                              fontSize: 25, fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
                _NotificationBell(userId: _userId, firestore: _firestore),
              ],
            ),
            const SizedBox(height: 20),
            _BalanceCard(
              balance: balance,
              income: income,
              expense: expense,
              formatMoney: _formatMoney,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _ActionButtonCard(
                    title: AppLocalizations.of(context)!.topUp,
                    icon: Icons.add_rounded,
                    accentColor: kGreen,
                    accentBg: kGreenBg,
                    onTap: () =>
                        _addTransaction(initialType: TransactionType.income),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ActionButtonCard(
                    title: AppLocalizations.of(context)!.spend,
                    icon: Icons.remove_rounded,
                    accentColor: kClay,
                    accentBg: kClayBg,
                    onTap: () =>
                        _addTransaction(initialType: TransactionType.expense),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(AppLocalizations.of(context)!.recentTransactions,
                    style: appDisplay(
                        fontSize: 18, fontWeight: FontWeight.w700)),
                if (transactions.isNotEmpty)
                  Text('${transactions.length}',
                      style: appBody(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: kTextMuted)),
              ],
            ),
            const SizedBox(height: 14),
            if (transactions.isEmpty)
              const _EmptyState()
            else
              ...transactions.map((t) => _TransactionTile(
                transaction: t,
                formatMoney: _formatMoney,
                onDelete: () => _deleteTransaction(t),
              )),
          ],
        );
      },
    );
  }
}

// ───────────────────────── Notification bell ─────────────────────────
class _NotificationBell extends StatelessWidget {
  final String? userId;
  final FirebaseFirestore firestore;

  const _NotificationBell({required this.userId, required this.firestore});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: userId == null
          ? null
          : firestore
          .collection('notifications')
          .where('userId', isEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .snapshots(),
      builder: (context, notifSnapshot) {
        final hasUnread = (notifSnapshot.data?.docs.length ?? 0) > 0;
        return GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const NotificationsScreen(),
            ),
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  shape: BoxShape.circle,
                  border: Border.all(color: kBorder),
                ),
                child: const Icon(Icons.notifications_none_rounded,
                    color: kTextSecondary, size: 21),
              ),
              if (hasUnread)
                Positioned(
                  top: 2,
                  right: 2,
                  child: Container(
                    width: 11,
                    height: 11,
                    decoration: BoxDecoration(
                      color: kClay,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFF03050A),
                        width: 2,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

// ───────────────────────── Glass bottom bar ─────────────────────────
class _GlassBottomBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onSelect;

  const _GlassBottomBar(
      {required this.selectedIndex, required this.onSelect});

  List<({IconData icon, IconData outline, String label})> _items(
      BuildContext context) =>
      [
        (
        icon: Icons.home_rounded,
        outline: Icons.home_outlined,
        label: AppLocalizations.of(context)!.navHome
        ),
        (
        icon: Icons.pie_chart_rounded,
        outline: Icons.pie_chart_outline,
        label: AppLocalizations.of(context)!.analyticsTitle
        ),
        (
        icon: Icons.flag_rounded,
        outline: Icons.flag_outlined,
        label: AppLocalizations.of(context)!.goalsTitle
        ),
        (
        icon: Icons.account_balance_wallet_rounded,
        outline: Icons.account_balance_wallet_outlined,
        label: AppLocalizations.of(context)!.budgetTitle
        ),
        (
        icon: Icons.person_rounded,
        outline: Icons.person_outline,
        label: AppLocalizations.of(context)!.profileTitle
        ),
      ];

  @override
  Widget build(BuildContext context) {
    final items = _items(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 6),
      child: Container(
        height: 78,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF19234A),
          borderRadius: BorderRadius.circular(26),
          border:
          Border.all(color: Colors.white.withOpacity(0.14), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.55),
              blurRadius: 28,
              offset: const Offset(0, 14),
            ),
            BoxShadow(
              color: kAccent.withOpacity(0.12),
              blurRadius: 30,
              offset: const Offset(0, 0),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(items.length, (i) {
            final item = items[i];
            final selected = i == selectedIndex;
            return Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => onSelect(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOut,
                  margin:
                  const EdgeInsets.symmetric(vertical: 9, horizontal: 3),
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  decoration: BoxDecoration(
                    gradient: selected ? kAccentGradient : null,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: selected
                        ? [
                      BoxShadow(
                        color: kAccent.withOpacity(0.45),
                        blurRadius: 14,
                        offset: const Offset(0, 6),
                      ),
                    ]
                        : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        selected ? item.icon : item.outline,
                        size: 21,
                        color: selected ? Colors.white : kTextMuted,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        item.label,
                        style: appBody(
                          fontSize: 10,
                          fontWeight: selected
                              ? FontWeight.w700
                              : FontWeight.w600,
                          color: selected ? Colors.white : kTextMuted,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

// ───────────────────────── Balance card ─────────────────────────
class _BalanceCard extends StatelessWidget {
  final double balance;
  final double income;
  final double expense;
  final String Function(double) formatMoney;

  const _BalanceCard({
    required this.balance,
    required this.income,
    required this.expense,
    required this.formatMoney,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1B2C63), Color(0xFF0A1230)],
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: kBorderStrong),
        boxShadow: [
          BoxShadow(
              color: kAccent.withOpacity(0.25),
              blurRadius: 30,
              offset: const Offset(0, 16)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 26, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                      color: kAmber, shape: BoxShape.circle),
                ),
                const SizedBox(width: 8),
                Text(AppLocalizations.of(context)!.totalBalance,
                    style: appBody(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: Colors.white70,
                      letterSpacing: 1.3,
                    )),
              ],
            ),
            const SizedBox(height: 12),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                '${formatMoney(balance)} ₸',
                style: appDisplay(
                    fontSize: 38, fontWeight: FontWeight.w700, height: 1),
              ),
            ),
            const SizedBox(height: 22),
            Container(height: 1, color: Colors.white.withOpacity(0.08)),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: _MiniStat(
                    icon: Icons.arrow_upward_rounded,
                    label: AppLocalizations.of(context)!.incomeMini,
                    amount: '+${formatMoney(income)} ₸',
                    color: kGreen,
                  ),
                ),
                Container(
                    width: 1,
                    height: 34,
                    color: Colors.white.withOpacity(0.08)),
                Expanded(
                  child: _MiniStat(
                    icon: Icons.arrow_downward_rounded,
                    label: AppLocalizations.of(context)!.expense,
                    amount: '-${formatMoney(expense)} ₸',
                    color: kClay,
                    alignEnd: true,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final String amount;
  final Color color;
  final bool alignEnd;

  const _MiniStat({
    required this.icon,
    required this.label,
    required this.amount,
    required this.color,
    this.alignEnd = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
      EdgeInsets.only(left: alignEnd ? 16 : 0, right: alignEnd ? 0 : 16),
      child: Column(
        crossAxisAlignment:
        alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!alignEnd) ...[
                Icon(icon, size: 13, color: color),
                const SizedBox(width: 5),
              ],
              Text(label,
                  style: appBody(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white60)),
              if (alignEnd) ...[
                const SizedBox(width: 5),
                Icon(icon, size: 13, color: color),
              ],
            ],
          ),
          const SizedBox(height: 5),
          Text(
            amount,
            style: appBody(
                fontSize: 14.5, fontWeight: FontWeight.w700, color: color),
          ),
        ],
      ),
    );
  }
}

// ───────────────────────── Action button ─────────────────────────
class _ActionButtonCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color accentColor;
  final Color accentBg;
  final VoidCallback onTap;

  const _ActionButtonCard({
    required this.title,
    required this.icon,
    required this.accentColor,
    required this.accentBg,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          decoration: BoxDecoration(
            gradient: kSurfaceGradient,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: kBorder),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                    color: accentBg, borderRadius: BorderRadius.circular(9)),
                child: Icon(icon, color: accentColor, size: 18),
              ),
              const SizedBox(width: 10),
              Text(title,
                  style: appBody(
                      fontWeight: FontWeight.w700,
                      fontSize: 14.5,
                      color: kTextPrimary)),
            ],
          ),
        ),
      ),
    );
  }
}

// ───────────────────────── Empty state ─────────────────────────
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(vertical: 44),
      radius: 20,
      child: Column(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration:
            const BoxDecoration(color: kAmberBg, shape: BoxShape.circle),
            child:
            const Icon(Icons.receipt_long_rounded, color: kAmber, size: 24),
          ),
          const SizedBox(height: 14),
          Text(AppLocalizations.of(context)!.noTransactions,
              style: appBody(
                  fontWeight: FontWeight.w700,
                  fontSize: 14.5,
                  color: kTextPrimary)),
          const SizedBox(height: 4),
          Text(
            AppLocalizations.of(context)!.addTransactionHint,
            textAlign: TextAlign.center,
            style: appBody(fontSize: 12.5, color: kTextMuted, height: 1.4),
          ),
        ],
      ),
    );
  }
}

// ───────────────────────── Transaction tile ─────────────────────────
class _TransactionTile extends StatelessWidget {
  final TransactionModel transaction;
  final String Function(double) formatMoney;
  final VoidCallback onDelete;

  const _TransactionTile({
    required this.transaction,
    required this.formatMoney,
    required this.onDelete,
  });

  IconData get _icon {
    if (transaction.type == TransactionType.income) {
      return Icons.trending_up_rounded;
    }
    if (transaction.goalId != null) return Icons.flag_rounded;
    final c = transaction.category.toLowerCase();
    if (c.contains('тама') || c.contains('eda') || c.contains('food')) {
      return Icons.restaurant_rounded;
    }
    if (c.contains('көлік') || c.contains('авто') || c.contains('car')) {
      return Icons.directions_car_filled_rounded;
    }
    if (c.contains('сая') || c.contains('travel')) {
      return Icons.flight_takeoff_rounded;
    }
    if (c.contains('денсаул') || c.contains('health')) {
      return Icons.favorite_rounded;
    }
    if (c.contains('білім') || c.contains('оқу') || c.contains('edu')) {
      return Icons.school_rounded;
    }
    return Icons.shopping_bag_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.type == TransactionType.income;
    final isGoal = !isIncome && transaction.goalId != null;

    final color = isIncome ? kGreen : (isGoal ? kAmber : kClay);
    final bg = isIncome ? kGreenBg : (isGoal ? kAmberBg : kClayBg);
    final sign = isIncome ? '+' : '-';

    final hasNote =
        transaction.note != null && transaction.note!.isNotEmpty;

    // 🌐 Тақырып pen Категорияны локализация бойынша аламыз:
    final localizedTitle = transaction.title.getLocalizedCategory(context);
    final localizedCategory = transaction.category.getLocalizedCategory(context);

    final hasSubtitle = localizedTitle != localizedCategory;

    return Dismissible(
      key: ValueKey(transaction.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete(),
      background: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        alignment: Alignment.centerRight,
        decoration: BoxDecoration(
          color: kClay,
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Icon(Icons.delete_outline_rounded,
            color: Colors.white, size: 22),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: kSurfaceGradient,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: kBorder),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration:
              BoxDecoration(color: bg, borderRadius: BorderRadius.circular(13)),
              child: Icon(_icon, color: color, size: 19),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    localizedTitle, // 👈 Аудару функциясы қолданылды
                    style: appBody(
                        fontWeight: FontWeight.w700,
                        fontSize: 14.5,
                        color: kTextPrimary),
                  ),
                  if (hasSubtitle) ...[
                    const SizedBox(height: 2),
                    Text(
                      localizedCategory, // 👈 Аудару функциясы қолданылды
                      style: appBody(
                          fontSize: 12.5,
                          color: kTextMuted,
                          fontWeight: FontWeight.w500),
                    ),
                  ],
                  if (hasNote) ...[
                    const SizedBox(height: 4),
                    Text(
                      transaction.note!,
                      style: appBody(
                          fontSize: 12, color: kTextSecondary, height: 1.3),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '$sign${formatMoney(transaction.amount)} ₸',
              style: appBody(
                  fontWeight: FontWeight.w700, fontSize: 14.5, color: color),
            ),
          ],
        ),
      ),
    );
  }
}