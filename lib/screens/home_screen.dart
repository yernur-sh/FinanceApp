import 'package:flutter/material.dart';
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

    // Егер транзакция мақсатпен байланысты болса, мақсаттың жиналған
    // сомасынан сол мөлшерді кері азайтамыз
    if (transaction.goalId != null) {
      final goalRef = _firestore.collection('goals').doc(transaction.goalId);
      batch.update(goalRef, {
        'currentAmount': FieldValue.increment(-transaction.amount),
      });
    }

    await batch.commit();
  }

  void _addTransaction({TransactionType initialType = TransactionType.expense}) {
    final titleController = TextEditingController(); // Табыс атауы үшін
    final amountController = TextEditingController();
    TransactionType selectedType = initialType;
    String? selectedGoalId;
    String? selectedBudgetCategory;

    final now = DateTime.now();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Жаңа транзакция',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    SegmentedButton<TransactionType>(
                      segments: const [
                        ButtonSegment(
                          value: TransactionType.income,
                          label: Text('Табыс'),
                          icon: Icon(Icons.arrow_upward),
                        ),
                        ButtonSegment(
                          value: TransactionType.expense,
                          label: Text('Шығын'),
                          icon: Icon(Icons.arrow_downward),
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
                    const SizedBox(height: 16),

                    // --- ТАБЫС ТАҢДАЛҒАНДА ШЫҒАТЫН АТАУ ӨРІСІ ---
                    if (selectedType == TransactionType.income) ...[
                      TextField(
                        controller: titleController,
                        decoration: const InputDecoration(
                          labelText: 'Табыс атауы (мыс. Жалақы, Премия)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // --- СОМА ӨРІСІ ---
                    TextField(
                      controller: amountController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Сомасы (₸)',
                        border: OutlineInputBorder(),
                      ),
                    ),

                    // --- ШЫҒЫН ТАҢДАЛҒАНДА БЮДЖЕТ САНАТТАРЫ ---
                    if (selectedType == TransactionType.expense) ...[
                      const SizedBox(height: 16),
                      Text(
                        'Бюджет санатынан таңдаңыз',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 8),
                      StreamBuilder<QuerySnapshot>(
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
                                  child: CircularProgressIndicator(strokeWidth: 2),
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
                              style: TextStyle(
                                  color: Colors.grey.shade500, fontSize: 13),
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
                                selectedColor: const Color(0xFF6C63FF),
                                labelStyle: TextStyle(
                                  color: selected ? Colors.white : Colors.black87,
                                  fontSize: 13,
                                ),
                                onSelected: (isSelected) {
                                  setModalState(() {
                                    selectedBudgetCategory =
                                    isSelected ? b.category : null;
                                  });
                                },
                              );
                            }).toList(),
                          );
                        },
                      ),
                      const SizedBox(height: 6),
                    ],

                    // --- ШЫҒЫН ТАҢДАЛҒАНДА МАҚСАТТАР ТІЗІМІ ---
                    if (selectedType == TransactionType.expense) ...[
                      const SizedBox(height: 16),
                      Text(
                        'Мақсатқа қосу керек пе?',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 8),
                      StreamBuilder<QuerySnapshot>(
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
                                  child: CircularProgressIndicator(strokeWidth: 2),
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
                              style: TextStyle(
                                  color: Colors.grey.shade500, fontSize: 13),
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
                                selectedColor: const Color(0xFF6C63FF),
                                labelStyle: TextStyle(
                                  color: selected ? Colors.white : Colors.black87,
                                  fontSize: 13,
                                ),
                                onSelected: (isSelected) {
                                  setModalState(() {
                                    selectedGoalId = isSelected ? g.id : null;
                                  });
                                },
                              );
                            }).toList(),
                          );
                        },
                      ),
                    ],

                    const SizedBox(height: 20),
                    FilledButton(
                      style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16)),
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

                        String finalTitle = 'Шығын';
                        String finalCategory = '-';

                        if (!isExpense) {
                          // Табыс болса
                          finalTitle = enteredTitle.isNotEmpty ? enteredTitle : 'Табыс';
                          finalCategory = 'Табыс';
                        } else {
                          // Шығын болса
                          if (selectedGoalId != null) {
                            // Мақсат таңдалса — Firestore-дан сол мақсаттың атын тартып аламыз
                            final goalDoc = await _firestore
                                .collection('goals')
                                .doc(selectedGoalId)
                                .get();
                            if (goalDoc.exists) {
                              finalTitle = goalDoc.get('title') ?? 'Мақсат';
                              finalCategory = goalDoc.get('title') ?? 'Мақсат';
                            }
                          } else if (selectedBudgetCategory != null) {
                            // Бюджет санаты таңдалса
                            finalTitle = selectedBudgetCategory!;
                            finalCategory = selectedBudgetCategory!;
                          } else {
                            // Ештеңе таңдалмаса
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
      backgroundColor: const Color(0xFFF8F9FE),
      body: SafeArea(child: pages[_selectedIndex]),
      bottomNavigationBar: NavigationBar(
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
    );
  }

  Widget _buildHomeContent() {
    return StreamBuilder<List<TransactionModel>>(
      stream: _transactionsStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Қате: ${snapshot.error}'));
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
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              'Жеке Қаржылар',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),

            // Баланс карточкасы
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Жалпы баланс',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${_formatMoney(balance)} ₸',
                    style: const TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Жеке-жеке батырмалар карточкалары
            Row(
              children: [
                // Толықтыру карточкасы
                Expanded(
                  child: _ActionButtonCard(
                    title: 'Толықтыру',
                    icon: Icons.arrow_upward_rounded,
                    accentColor: const Color(0xFF34C471),
                    onTap: () => _addTransaction(initialType: TransactionType.income),
                  ),
                ),
                const SizedBox(width: 14),
                // Жұмсау карточкасы
                Expanded(
                  child: _ActionButtonCard(
                    title: 'Жұмсау',
                    icon: Icons.arrow_downward_rounded,
                    accentColor: const Color(0xFFE05B49),
                    onTap: () => _addTransaction(initialType: TransactionType.expense),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 28),

            // Соңғы транзакциялар тақырыбы
            Text(
              'Соңғы транзакциялар',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            if (transactions.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 32),
                child: Center(
                  child: Text(
                    'Транзакциялар жоқ',
                    style: TextStyle(color: Colors.grey.shade500),
                  ),
                ),
              )
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

// Жеке батырма карточкасына арналған компонент
class _ActionButtonCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color accentColor;
  final VoidCallback onTap;

  const _ActionButtonCard({
    required this.title,
    required this.icon,
    required this.accentColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: accentColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: Color(0xFF1E293B),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  final TransactionModel transaction;
  final String Function(double) formatMoney;
  final VoidCallback onDelete;

  const _TransactionTile({
    required this.transaction,
    required this.formatMoney,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.type == TransactionType.income;
    final color = isIncome ? const Color(0xFF34C471) : const Color(0xFFE05B49);
    final sign = isIncome ? '+' : '-';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.title,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  transaction.category,
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                ),
              ],
            ),
          ),
          Text(
            '$sign${formatMoney(transaction.amount)} ₸',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          IconButton(
            icon: Icon(Icons.delete_outline, color: Colors.grey.shade400),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}