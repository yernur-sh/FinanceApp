import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/budget_model.dart';

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  final _firestore = FirebaseFirestore.instance;

  String? get _userId => FirebaseAuth.instance.currentUser?.uid;

  String _formatMoney(double value) {
    final formatter = NumberFormat('#,##0', 'ru');
    return formatter.format(value).replaceAll(',', ' ');
  }

  /// 🔹 БҮДЖЕТТІ ЖӘНЕ ОҒАН ҚАТЫСТЫ БАРЛЫҚ ТРАНЗАКЦИЯЛАРДЫ БІРГЕ ӨШІРУ
  Future<void> _deleteBudgetCascade(String budgetId, String categoryName) async {
    if (_userId == null) return;

    final batch = _firestore.batch();

    // 1. Бюджет құжатын өшіруге дайындаймыз
    final budgetRef = _firestore.collection('budgets').doc(budgetId);
    batch.delete(budgetRef);

    // 2. Осы санатқа жататын пайдаланушының транзакцияларын табамыз
    final transactionsQuery = await _firestore
        .collection('transactions')
        .where('userId', isEqualTo: _userId)
        .where('category', isEqualTo: categoryName)
        .get();

    // 3. Табылған транзакциялардың барлығын өшіруге қосамыз
    for (var doc in transactionsQuery.docs) {
      batch.delete(doc.reference);
    }

    // 4. Барлық транзакция мен бюджетті бірге өшіреміз (Atomic operation)
    await batch.commit();
  }

  Future<void> _addBudget() async {
    final categoryController = TextEditingController();
    final limitController = TextEditingController();

    if (!mounted) return;

    await showModalBottomSheet(
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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Жаңа бюджет',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: categoryController,
                    decoration: const InputDecoration(
                      labelText: 'Санат (мыс. Көлік, Тамақ)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: limitController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Лимит (₸)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  FilledButton(
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: () async {
                      final limit = double.tryParse(
                        limitController.text.trim(),
                      );
                      final category = categoryController.text.trim();

                      if (category.isEmpty || limit == null || limit <= 0) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Барлық өрісті дұрыс толтырыңыз'),
                          ),
                        );
                        return;
                      }

                      if (_userId == null) return;

                      final now = DateTime.now();

                      final newBudget = BudgetModel(
                        id: '',
                        category: category,
                        limit: limit,
                        month: now.month,
                        year: now.year,
                      );

                      Navigator.pop(context);

                      await _firestore
                          .collection('budgets')
                          .add(newBudget.toMap(_userId!));
                    },
                    child: const Text('Бюджет құру'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  /// 🔹 Санат бойынша ағымдағы айдың шығындарын есептеу
  Future<double> _getSpentForCategory(
      String category,
      int month,
      int year,
      ) async {
    if (_userId == null) return 0.0;

    final start = DateTime(year, month, 1);
    final end = DateTime(year, month + 1, 1);

    // Сұраныста қате болмауы үшін транзакцияларды сүзіп алып, датасын ішінде тексереміз
    final snapshot = await _firestore
        .collection('transactions')
        .where('userId', isEqualTo: _userId)
        .where('category', isEqualTo: category)
        .get();

    double total = 0.0;

    for (final doc in snapshot.docs) {
      final data = doc.data();
      // 'type' тек 'expense' (шығын) болса және осы айда жасалса ғана есептейміз
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

  @override
  Widget build(BuildContext context) {
    if (_userId == null) {
      return const Center(child: Text('Кіру қажет'));
    }

    final now = DateTime.now();
    final currentMonth = now.month;
    final currentYear = now.year;

    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('budgets')
          .where('userId', isEqualTo: _userId)
          .where('month', isEqualTo: currentMonth)
          .where('year', isEqualTo: currentYear)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Қате: ${snapshot.error}'));
        }

        final budgets =
            snapshot.data?.docs
                .map((doc) => BudgetModel.fromDoc(doc))
                .toList() ??
                [];

        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Бюджет',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                InkWell(
                  onTap: _addBudget,
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFF6C63FF),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.add, color: Colors.white),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Ағымдағы ай',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 15),
            ),
            const SizedBox(height: 20),
            if (budgets.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 48),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.account_balance_wallet_outlined,
                        size: 48,
                        color: Colors.grey.shade300,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Әзірге бюджеттер жоқ',
                        style: TextStyle(color: Colors.grey.shade500),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Жаңа бюджет қосу үшін + батырмасын басыңыз',
                        style: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 13,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              )
            else
              ...budgets.map(
                    (budget) => _BudgetCard(
                  budget: budget,
                  formatMoney: _formatMoney,
                  getSpent: () => _getSpentForCategory(
                    budget.category,
                    budget.month,
                    budget.year,
                  ),
                  onDelete: () => _deleteBudgetCascade(budget.id, budget.category),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _BudgetCard extends StatelessWidget {
  final BudgetModel budget;
  final String Function(double) formatMoney;
  final Future<double> Function() getSpent;
  final VoidCallback onDelete;

  const _BudgetCard({
    required this.budget,
    required this.formatMoney,
    required this.getSpent,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<double>(
      future: getSpent(),
      builder: (context, snapshot) {
        final spent = snapshot.data ?? 0.0;
        final remaining = budget.limit - spent;
        final progress = budget.limit <= 0
            ? 0.0
            : (spent / budget.limit).clamp(0.0, 1.0);
        final percent = (progress * 100).toInt();
        final isOver = remaining < 0;

        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          budget.category,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Лимит: ${formatMoney(budget.limit)} ₸',
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '$percent%',
                        style: TextStyle(
                          color: isOver
                              ? const Color(0xFFE05B49)
                              : const Color(0xFF34C471),
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(width: 12),
                      IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: Icon(
                          Icons.delete_outline,
                          color: Colors.grey.shade400,
                          size: 20,
                        ),
                        onPressed: onDelete,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 14),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 8,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isOver ? const Color(0xFFE05B49) : const Color(0xFF34C471),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${formatMoney(spent)} ₸ жұмсалды',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    isOver
                        ? 'Асып кетті'
                        : '${formatMoney(remaining)} ₸ қалды',
                    style: TextStyle(
                      color: isOver
                          ? const Color(0xFFE05B49)
                          : Colors.grey.shade600,
                      fontSize: 12,
                      fontWeight: isOver ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}