import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/budget_model.dart';
import '../theme/app_theme.dart';

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

  Future<void> _deleteBudgetCascade(String budgetId, String categoryName) async {
    if (_userId == null) return;

    final batch = _firestore.batch();

    final budgetRef = _firestore.collection('budgets').doc(budgetId);
    batch.delete(budgetRef);

    final transactionsQuery = await _firestore
        .collection('transactions')
        .where('userId', isEqualTo: _userId)
        .where('category', isEqualTo: categoryName)
        .get();

    for (var doc in transactionsQuery.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();
  }

  Future<void> _addBudget() async {
    final categoryController = TextEditingController();
    final limitController = TextEditingController();

    if (!mounted) return;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: kSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
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
                  Text('Жаңа бюджет',
                      style: appDisplay(fontSize: 19, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 16),
                  TextField(
                    controller: categoryController,
                    style: appBody(fontSize: 14.5),
                    decoration: appFieldDecoration('Санат (мыс. Көлік, Тамақ)'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: limitController,
                    keyboardType: TextInputType.number,
                    style: appBody(fontSize: 14.5),
                    decoration: appFieldDecoration('Лимит (₸)'),
                  ),
                  const SizedBox(height: 20),
                  GradientButton(
                    label: 'Бюджет құру',
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
                  ),
                ],
              ),
            );
          },
        );
      },
    );
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

  @override
  Widget build(BuildContext context) {
    if (_userId == null) {
      return Center(
          child: Text('Кіру қажет', style: appBody(color: kTextSecondary)));
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
          return const Center(child: CircularProgressIndicator(color: kAccent));
        }

        if (snapshot.hasError) {
          return Center(
              child: Text('Қате: ${snapshot.error}',
                  style: appBody(color: kTextSecondary)));
        }

        final budgets = snapshot.data?.docs
                .map((doc) => BudgetModel.fromDoc(doc))
                .toList() ??
            [];

        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 120),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Бюджет', style: appDisplay(fontSize: 24, fontWeight: FontWeight.w700)),
                InkWell(
                  onTap: _addBudget,
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: kAccentGradient,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: kAccent.withOpacity(0.4),
                          blurRadius: 14,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.add, color: Colors.white),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('Ағымдағы ай', style: appBody(color: kTextMuted, fontSize: 15)),
            const SizedBox(height: 20),
            if (budgets.isEmpty)
              GlassCard(
                padding: const EdgeInsets.symmetric(vertical: 48),
                radius: 24,
                child: Column(
                  children: [
                    const Icon(
                      Icons.account_balance_wallet_outlined,
                      size: 48,
                      color: kTextMuted,
                    ),
                    const SizedBox(height: 12),
                    Text('Әзірге бюджеттер жоқ', style: appBody(color: kTextMuted)),
                    const SizedBox(height: 4),
                    Text(
                      'Жаңа бюджет қосу үшін + батырмасын басыңыз',
                      style: appBody(color: kTextMuted, fontSize: 13),
                      textAlign: TextAlign.center,
                    ),
                  ],
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
            gradient: kSurfaceGradient,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: kBorder),
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
                          style: appBody(
                              fontWeight: FontWeight.w700, fontSize: 16, color: kTextPrimary),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Лимит: ${formatMoney(budget.limit)} ₸',
                          style: appBody(color: kTextMuted, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '$percent%',
                        style: appBody(
                          color: isOver ? kClay : kGreen,
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(width: 12),
                      IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: const Icon(
                          Icons.delete_outline,
                          color: kTextMuted,
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
                  backgroundColor: Colors.white.withOpacity(0.06),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isOver ? kClay : kGreen,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${formatMoney(spent)} ₸ жұмсалды',
                    style: appBody(color: kTextSecondary, fontSize: 12),
                  ),
                  Text(
                    isOver ? 'Асып кетті' : '${formatMoney(remaining)} ₸ қалды',
                    style: appBody(
                      color: isOver ? kClay : kTextSecondary,
                      fontSize: 12,
                      fontWeight: isOver ? FontWeight.w700 : FontWeight.normal,
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
