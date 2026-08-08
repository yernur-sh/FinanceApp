import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/transaction_model.dart';
import 'profile_screen.dart';
import 'goals_screen.dart';
import 'analytics_screen.dart';
import 'budget_screen.dart';
import '../models/goal_model.dart';
import '../models/budget_model.dart';

// ───────────────────────── Design tokens ─────────────────────────
const kInk = Color(0xFF11182B);
const kBg = Color(0xFFF4F5F8);
const kSurface = Colors.white;
const kBorder = Color(0xFFE7E9EE);
const kAmber = Color(0xFFD68A3C);
const kAmberDeep = Color(0xFFB86F2C);
const kAmberBg = Color(0xFFF7EAD9);
const kGreen = Color(0xFF1F6F54);
const kGreenLight = Color(0xFF8FD6B4);
const kGreenBg = Color(0xFFE7F2EC);
const kClay = Color(0xFFB54A3E);
const kClayLight = Color(0xFFE9A79A);
const kClayBg = Color(0xFFF8EAE8);
const kTextPrimary = Color(0xFF11182B);
const kTextSecondary = Color(0xFF5B6472);
const kTextMuted = Color(0xFF9AA1AC);

InputDecoration _fieldDecoration(String label, {String? hint}) {
  return InputDecoration(
    labelText: label,
    hintText: hint,
    filled: true,
    fillColor: kBg,
    labelStyle: GoogleFonts.inter(color: kTextSecondary, fontSize: 13.5),
    hintStyle: GoogleFonts.inter(color: kTextMuted, fontSize: 13),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: kBorder),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: kBorder),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: kInk, width: 1.4),
    ),
  );
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

  String? get _userId => FirebaseAuth.instance.currentUser?.uid;

  @override
  void initState() {
    super.initState();
    _transactionsStream = _buildTransactionsStream();
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

  void _addTransaction({TransactionType initialType = TransactionType.expense}) {
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
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
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
                          color: kBorder,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    Text(
                      'Жаңа транзакция',
                      style: GoogleFonts.golosText(
                        fontSize: 19,
                        fontWeight: FontWeight.w700,
                        color: kTextPrimary,
                      ),
                    ),
                    const SizedBox(height: 18),
                    SegmentedButton<TransactionType>(
                      style: SegmentedButton.styleFrom(
                        backgroundColor: kBg,
                        foregroundColor: kTextSecondary,
                        selectedBackgroundColor: kInk,
                        selectedForegroundColor: Colors.white,
                        side: const BorderSide(color: kBorder),
                        textStyle: GoogleFonts.inter(
                            fontWeight: FontWeight.w600, fontSize: 13.5),
                      ),
                      segments: const [
                        ButtonSegment(
                          value: TransactionType.income,
                          label: Text('Табыс'),
                          icon: Icon(Icons.arrow_upward_rounded, size: 16),
                        ),
                        ButtonSegment(
                          value: TransactionType.expense,
                          label: Text('Шығын'),
                          icon: Icon(Icons.arrow_downward_rounded, size: 16),
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
                        style: GoogleFonts.inter(fontSize: 14.5),
                        decoration: _fieldDecoration(
                            'Табыс атауы (мыс. Жалақы, Премия)'),
                      ),
                      const SizedBox(height: 12),
                    ],

                    TextField(
                      controller: amountController,
                      keyboardType: TextInputType.number,
                      style: GoogleFonts.inter(fontSize: 14.5),
                      decoration: _fieldDecoration('Сомасы (₸)'),
                    ),

                    const SizedBox(height: 12),
                    TextField(
                      controller: noteController,
                      maxLines: 2,
                      style: GoogleFonts.inter(fontSize: 14.5),
                      decoration:
                      _fieldDecoration('Комментарий', hint: 'Себеп-салдары'),
                    ),

                    if (selectedType == TransactionType.expense) ...[
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Бюджет санатынан таңдаңыз',
                            style: GoogleFonts.inter(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w600,
                                color: kTextPrimary),
                          ),
                          if (selectedGoalId != null)
                            Text('Мақсат таңдалды',
                                style: GoogleFonts.inter(
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
                                  'Әзірге бюджет санаттары жоқ. Алдымен "Бюджет" бетінде санат құрыңыз',
                                  style: GoogleFonts.inter(
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
                                    backgroundColor: kBg,
                                    selectedColor: kInk,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      side: BorderSide(
                                          color: selected ? kInk : kBorder),
                                    ),
                                    labelStyle: GoogleFonts.inter(
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
                            'Мақсатқа қосу керек пе?',
                            style: GoogleFonts.inter(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w600,
                                color: kTextPrimary),
                          ),
                          if (selectedBudgetCategory != null)
                            Text('Санат таңдалды',
                                style: GoogleFonts.inter(
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
                                  'Әзірге мақсаттарыңыз жоқ',
                                  style: GoogleFonts.inter(
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
                                    backgroundColor: kBg,
                                    selectedColor: kAmberDeep,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      side: BorderSide(
                                          color: selected
                                              ? kAmberDeep
                                              : kBorder),
                                    ),
                                    labelStyle: GoogleFonts.inter(
                                      color: selected
                                          ? Colors.white
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
                    FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: kInk,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                        textStyle: GoogleFonts.inter(
                            fontWeight: FontWeight.w700, fontSize: 15),
                      ),
                      onPressed: () async {
                        final amount =
                        double.tryParse(amountController.text.trim());
                        if (amount == null || amount <= 0) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Соманы дұрыс енгізіңіз')),
                          );
                          return;
                        }
                        if (_userId == null) return;

                        final isExpense = selectedType == TransactionType.expense;
                        final enteredTitle = titleController.text.trim();
                        final enteredNote = noteController.text.trim();

                        String finalTitle = 'Шығын';
                        String finalCategory = '-';

                        if (!isExpense) {
                          finalTitle = enteredTitle.isNotEmpty ? enteredTitle : 'Табыс';
                          finalCategory = 'Табыс';
                        } else {
                          if (selectedGoalId != null) {
                            final goalDoc = await _firestore
                                .collection('goals')
                                .doc(selectedGoalId)
                                .get();
                            if (goalDoc.exists) {
                              finalTitle = goalDoc.get('title') ?? 'Мақсат';
                              finalCategory = goalDoc.get('title') ?? 'Мақсат';
                            }
                          } else if (selectedBudgetCategory != null) {
                            finalTitle = selectedBudgetCategory!;
                            finalCategory = selectedBudgetCategory!;
                          } else {
                            finalTitle = 'Шығын';
                            finalCategory = 'Шығын';
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
                          final goalRef =
                          _firestore.collection('goals').doc(selectedGoalId);
                          batch.update(goalRef, {
                            'currentAmount': FieldValue.increment(amount),
                          });
                        }

                        await batch.commit();
                      },
                      child: const Text('Қосу'),
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
      const ProfileScreen(),
    ];

    return Scaffold(
      backgroundColor: kBg,
      body: SafeArea(child: pages[_selectedIndex]),
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          backgroundColor: kSurface,
          indicatorColor: kAmberBg,
          height: 66,
          labelTextStyle: MaterialStateProperty.resolveWith((states) {
            final selected = states.contains(MaterialState.selected);
            return GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: selected ? kAmberDeep : kTextMuted,
            );
          }),
          iconTheme: MaterialStateProperty.resolveWith((states) {
            final selected = states.contains(MaterialState.selected);
            return IconThemeData(
                color: selected ? kAmberDeep : kTextMuted, size: 23);
          }),
        ),
        child: NavigationBar(
          elevation: 0,
          selectedIndex: _selectedIndex,
          onDestinationSelected: (index) {
            setState(() => _selectedIndex = index);
          },
          destinations: const [
            NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Басты бет'),
            NavigationDestination(icon: Icon(Icons.pie_chart_outline), label: 'Аналитика'),
            NavigationDestination(icon: Icon(Icons.flag_outlined), label: 'Мақсаттар'),
            NavigationDestination(icon: Icon(Icons.account_balance_wallet_outlined), label: 'Бюджет'),
            NavigationDestination(icon: Icon(Icons.person_outline), label: 'Профиль'),
          ],
        ),
      ),
    );
  }

  Widget _buildHomeContent() {
    return StreamBuilder<List<TransactionModel>>(
      stream: _transactionsStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: kAmber));
        }
        if (snapshot.hasError) {
          return Center(
              child: Text('Қате: ${snapshot.error}',
                  style: GoogleFonts.inter(color: kTextSecondary)));
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
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 32),
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('ҚАРЖЫ ШОЛУ',
                          style: GoogleFonts.inter(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: kTextMuted,
                            letterSpacing: 1.2,
                          )),
                      const SizedBox(height: 4),
                      Text('Жеке Қаржылар',
                          style: GoogleFonts.golosText(
                            fontSize: 25,
                            fontWeight: FontWeight.w700,
                            color: kTextPrimary,
                          )),
                    ],
                  ),
                ),
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: kSurface,
                    shape: BoxShape.circle,
                    border: Border.all(color: kBorder),
                  ),
                  child: const Icon(Icons.notifications_none_rounded,
                      color: kTextSecondary, size: 21),
                ),
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
                    title: 'Толықтыру',
                    icon: Icons.add_rounded,
                    accentColor: kGreen,
                    accentBg: kGreenBg,
                    onTap: () => _addTransaction(initialType: TransactionType.income),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ActionButtonCard(
                    title: 'Жұмсау',
                    icon: Icons.remove_rounded,
                    accentColor: kClay,
                    accentBg: kClayBg,
                    onTap: () => _addTransaction(initialType: TransactionType.expense),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Соңғы транзакциялар',
                    style: GoogleFonts.golosText(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: kTextPrimary)),
                if (transactions.isNotEmpty)
                  Text('${transactions.length}',
                      style: GoogleFonts.inter(
                          fontSize: 13, fontWeight: FontWeight.w600, color: kTextMuted)),
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

// ───────────────────────── Balance card + mountain signature ─────────────────────────
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
        color: kInk,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
              color: kInk.withOpacity(0.28),
              blurRadius: 28,
              offset: const Offset(0, 14)),
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
                Text('ЖАЛПЫ БАЛАНС',
                    style: GoogleFonts.inter(
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
                style: GoogleFonts.golosText(
                  fontSize: 38,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  height: 1,
                ),
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
                    label: 'Түсім',
                    amount: '+${formatMoney(income)} ₸',
                    color: kGreenLight,
                  ),
                ),
                Container(
                    width: 1,
                    height: 34,
                    color: Colors.white.withOpacity(0.08)),
                Expanded(
                  child: _MiniStat(
                    icon: Icons.arrow_downward_rounded,
                    label: 'Шығын',
                    amount: '-${formatMoney(expense)} ₸',
                    color: kClayLight,
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
      padding: EdgeInsets.only(left: alignEnd ? 16 : 0, right: alignEnd ? 0 : 16),
      child: Column(
        crossAxisAlignment: alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!alignEnd) ...[
                Icon(icon, size: 13, color: color),
                const SizedBox(width: 5),
              ],
              Text(label,
                  style: GoogleFonts.inter(
                      fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white60)),
              if (alignEnd) ...[
                const SizedBox(width: 5),
                Icon(icon, size: 13, color: color),
              ],
            ],
          ),
          const SizedBox(height: 5),
          Text(
            amount,
            style: GoogleFonts.inter(
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
      color: kSurface,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: kBorder),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 30,
                height: 30,
                decoration:
                BoxDecoration(color: accentBg, borderRadius: BorderRadius.circular(9)),
                child: Icon(icon, color: accentColor, size: 18),
              ),
              const SizedBox(width: 10),
              Text(title,
                  style: GoogleFonts.inter(
                      fontWeight: FontWeight.w700, fontSize: 14.5, color: kTextPrimary)),
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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 44),
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: kBorder),
      ),
      child: Column(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: const BoxDecoration(color: kAmberBg, shape: BoxShape.circle),
            child: const Icon(Icons.receipt_long_rounded, color: kAmberDeep, size: 24),
          ),
          const SizedBox(height: 14),
          Text('Транзакциялар жоқ',
              style: GoogleFonts.inter(
                  fontWeight: FontWeight.w700, fontSize: 14.5, color: kTextPrimary)),
          const SizedBox(height: 4),
          Text(
            'Жаңа жазба қосу үшін жоғарыдағы\nбатырманы басыңыз',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(fontSize: 12.5, color: kTextMuted, height: 1.4),
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
    if (transaction.type == TransactionType.income) return Icons.trending_up_rounded;
    if (transaction.goalId != null) return Icons.flag_rounded;
    final c = transaction.category.toLowerCase();
    if (c.contains('тама') || c.contains('eda') || c.contains('food')) {
      return Icons.restaurant_rounded;
    }
    if (c.contains('көлік') || c.contains('авто') || c.contains('car')) {
      return Icons.directions_car_filled_rounded;
    }
    if (c.contains('сая') || c.contains('travel')) return Icons.flight_takeoff_rounded;
    if (c.contains('денсаул') || c.contains('health')) return Icons.favorite_rounded;
    if (c.contains('білім') || c.contains('оқу') || c.contains('edu')) {
      return Icons.school_rounded;
    }
    return Icons.shopping_bag_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.type == TransactionType.income;
    final isGoal = !isIncome && transaction.goalId != null;
    final color = isIncome ? kGreen : (isGoal ? kAmberDeep : kClay);
    final bg = isIncome ? kGreenBg : (isGoal ? kAmberBg : kClayBg);
    final sign = isIncome ? '+' : '-';
    final hasNote = transaction.note != null && transaction.note!.isNotEmpty;
    final hasSubtitle = transaction.title != transaction.category;

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
        child: const Icon(Icons.delete_outline_rounded, color: Colors.white, size: 22),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: kSurface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: kBorder),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(13)),
              child: Icon(_icon, color: color, size: 19),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(transaction.title,
                      style: GoogleFonts.inter(
                          fontWeight: FontWeight.w700, fontSize: 14.5, color: kTextPrimary)),
                  if (hasSubtitle) ...[
                    const SizedBox(height: 2),
                    Text(transaction.category,
                        style: GoogleFonts.inter(
                            fontSize: 12.5, color: kTextMuted, fontWeight: FontWeight.w500)),
                  ],
                  if (hasNote) ...[
                    const SizedBox(height: 4),
                    Text(transaction.note!,
                        style:
                        GoogleFonts.inter(fontSize: 12, color: kTextSecondary, height: 1.3)),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '$sign${formatMoney(transaction.amount)} ₸',
              style: GoogleFonts.inter(
                  fontWeight: FontWeight.w700, fontSize: 14.5, color: color),
            ),
          ],
        ),
      ),
    );
  }
}