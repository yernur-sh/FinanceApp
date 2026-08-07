import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // ✅ Түзу
import 'package:firebase_auth/firebase_auth.dart';
import '../models/goal_model.dart';

class GoalsScreen extends StatefulWidget {
  const GoalsScreen({super.key});

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  final _firestore = FirebaseFirestore.instance;
  late final Stream<List<GoalModel>> _goalsStream;

  String? get _userId => FirebaseAuth.instance.currentUser?.uid;

  @override
  void initState() {
    super.initState();
    _goalsStream = _buildGoalsStream();
  }

  Stream<List<GoalModel>> _buildGoalsStream() {
    if (_userId == null) return const Stream.empty();
    return _firestore
        .collection('goals')
        .where('userId', isEqualTo: _userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) =>
        snap.docs.map((doc) => GoalModel.fromDoc(doc)).toList());
  }

  String _formatMoney(double value) {
    final formatter = NumberFormat('#,##0', 'ru');
    return formatter.format(value).replaceAll(',', ' ');
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
  }

  /// 🎯 ӨЗГЕРІС: Ішкі Index талап етпейтіндей жөнделді
  Future<void> _deleteGoal(String goalId) async {
    if (_userId == null) return;

    final batch = _firestore.batch();

    // 1. Мақсатты өшіру
    final goalRef = _firestore.collection('goals').doc(goalId);
    batch.delete(goalRef);

    // 2. Осы мақсатқа қатысты барлық транзакцияларды табу (Тек goalId арқылы)
    final relatedTransactions = await _firestore
        .collection('transactions')
        .where('goalId', isEqualTo: goalId)
        .get();

    for (var doc in relatedTransactions.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();
  }

  void _addGoal() {
    final titleController = TextEditingController();
    final targetController = TextEditingController();
    GoalCategory selectedCategory = GoalCategory.savings;
    DateTime? selectedDeadline;

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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Жаңа мақсат',
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 16),
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: 'Мақсат атауы',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: targetController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Мақсатты сома (₸)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text('Санат', style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: GoalCategory.values.map((cat) {
                      final info = goalCategoryData[cat]!;
                      final selected = selectedCategory == cat;
                      return ChoiceChip(
                        label: Text(info.label),
                        avatar: Icon(info.icon,
                            size: 18,
                            color: selected ? Colors.white : info.color),
                        selected: selected,
                        selectedColor: info.color,
                        labelStyle: TextStyle(
                            color: selected ? Colors.white : Colors.black87),
                        onSelected: (_) {
                          setModalState(() => selectedCategory = cat);
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.calendar_today, size: 18),
                    label: Text(selectedDeadline == null
                        ? 'Мерзімін таңдау (міндетті емес)'
                        : _formatDate(selectedDeadline!)),
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now().add(const Duration(days: 30)),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        setModalState(() => selectedDeadline = picked);
                      }
                    },
                  ),
                  const SizedBox(height: 20),
                  FilledButton(
                    style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16)),
                    onPressed: () async {
                      final target = double.tryParse(targetController.text.trim());
                      if (titleController.text.trim().isEmpty ||
                          target == null ||
                          target <= 0) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Барлық өрісті дұрыс толтырыңыз')),
                        );
                        return;
                      }

                      final newGoal = GoalModel(
                        id: '',
                        title: titleController.text.trim(),
                        targetAmount: target,
                        currentAmount: 0,
                        deadline: selectedDeadline,
                        category: selectedCategory,
                        createdAt: DateTime.now(),
                      );

                      Navigator.pop(context);
                      if (_userId != null) {
                        await _firestore
                            .collection('goals')
                            .add(newGoal.toMap(_userId!));
                      }
                    },
                    child: const Text('Мақсат құру'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<GoalModel>>(
      stream: _goalsStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Қате: ${snapshot.error}'));
        }

        final goals = snapshot.data ?? [];

        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Қаржылық мақсаттар',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                InkWell(
                  onTap: _addGoal,
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
              'Белсенді мақсаттар',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 15),
            ),
            const SizedBox(height: 20),
            if (goals.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 48),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.flag_outlined,
                          size: 48, color: Colors.grey.shade300),
                      const SizedBox(height: 12),
                      Text(
                        'Әзірге мақсаттар жоқ',
                        style: TextStyle(color: Colors.grey.shade500),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Жаңа мақсат қосу үшін + батырмасын басыңыз',
                        style: TextStyle(
                            color: Colors.grey.shade400, fontSize: 13),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              )
            else
              ...goals.map((g) => _GoalCard(
                goal: g,
                formatMoney: _formatMoney,
                formatDate: _formatDate,
                onDelete: () => _deleteGoal(g.id),
              )),
          ],
        );
      },
    );
  }
}

class _GoalCard extends StatelessWidget {
  final GoalModel goal;
  final String Function(double) formatMoney;
  final String Function(DateTime) formatDate;
  final VoidCallback onDelete;

  const _GoalCard({
    required this.goal,
    required this.formatMoney,
    required this.formatDate,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final info = goalCategoryData[goal.category]!;
    final isDone = goal.progress >= 1;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: info.color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(info.icon, color: info.color, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        goal.title,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Мақсат: ${formatMoney(goal.targetAmount)} ₸',
                        style: TextStyle(
                            color: Colors.grey.shade500, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${goal.progressPercent}%',
                  style: TextStyle(
                    color: isDone ? const Color(0xFF34C471) : info.color,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.delete_outline,
                      color: Colors.grey.shade400, size: 20),
                  onPressed: onDelete,
                ),
              ],
            ),
            const SizedBox(height: 14),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: goal.progress,
                minHeight: 8,
                backgroundColor: info.color.withOpacity(0.12),
                valueColor: AlwaysStoppedAnimation<Color>(
                    isDone ? const Color(0xFF34C471) : info.color),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${formatMoney(goal.currentAmount)} ₸ жиналды',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
                if (goal.deadline != null)
                  Text(
                    formatDate(goal.deadline!),
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}