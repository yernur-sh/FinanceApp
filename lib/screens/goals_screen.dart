import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/goal_model.dart';
import '../theme/app_theme.dart';
import '../services/notification_service.dart';
import '../l10n/app_localizations.dart';

/// GoalCategory enum-іне арналған локализация көмекшісі
/// GoalCategory enum-іне арналған локализация көмекшісі
extension GoalCategoryX on GoalCategory {
  String getLocalizedLabel(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    switch (this) {
      case GoalCategory.savings:
        return l10n.categorySavings;
      case GoalCategory.travel:
        return l10n.categoryTravel;
      case GoalCategory.emergency: // 👈 property орнына emergency қолданылады
        return l10n.categoryProperty;
      case GoalCategory.other:
        return l10n.categoryOther;
    }
  }
}
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
        .map((snap) {
      final goals = snap.docs.map((doc) => GoalModel.fromDoc(doc)).toList();
      for (final goal in goals) {
        if (goal.progress >= 1) {
          NotificationService.notifyGoalCompleted(
            userId: _userId!,
            goalId: goal.id,
            goalTitle: goal.title,
          );
        }
      }
      return goals;
    });
  }

  String _formatMoney(double value) {
    final formatter = NumberFormat('#,##0', 'ru');
    return formatter.format(value).replaceAll(',', ' ');
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
  }

  Future<void> _deleteGoal(String goalId) async {
    if (_userId == null) return;

    final batch = _firestore.batch();

    final goalRef = _firestore.collection('goals').doc(goalId);
    batch.delete(goalRef);

    final relatedTransactions = await _firestore
        .collection('transactions')
        .where('userId', isEqualTo: _userId)
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
                  Text(AppLocalizations.of(context)!.newGoal,
                      style: appDisplay(fontSize: 19, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 16),
                  TextField(
                    controller: titleController,
                    style: appBody(fontSize: 14.5),
                    decoration: appFieldDecoration(AppLocalizations.of(context)!.goalNameLabel),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: targetController,
                    keyboardType: TextInputType.number,
                    style: appBody(fontSize: 14.5),
                    decoration: appFieldDecoration(AppLocalizations.of(context)!.goalTargetAmountLabel),
                  ),
                  const SizedBox(height: 16),
                  Text(AppLocalizations.of(context)!.category, style: appBody(color: kTextSecondary, fontSize: 13.5)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: GoalCategory.values.map((cat) {
                      final info = goalCategoryData[cat]!;
                      final selected = selectedCategory == cat;
                      return ChoiceChip(
                        // 🌐 Осы жерде динамикалық аударма шақырылады:
                        label: Text(cat.getLocalizedLabel(context)),
                        avatar: Icon(info.icon,
                            size: 18,
                            color: selected ? Colors.white : info.color),
                        selected: selected,
                        backgroundColor: Colors.white.withOpacity(0.05),
                        selectedColor: info.color,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: BorderSide(color: selected ? info.color : kBorder),
                        ),
                        labelStyle: appBody(
                            color: selected ? Colors.white : kTextSecondary,
                            fontWeight: FontWeight.w600),
                        onSelected: (_) {
                          setModalState(() => selectedCategory = cat);
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.calendar_today, size: 18, color: kAccentLight),
                    label: Text(
                      selectedDeadline == null
                          ? AppLocalizations.of(context)!.selectDeadlineOptional
                          : _formatDate(selectedDeadline!),
                      style: appBody(color: kTextSecondary),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: kBorder),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
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
                  GradientButton(
                    label: AppLocalizations.of(context)!.createGoal,
                    onPressed: () async {
                      final target = double.tryParse(targetController.text.trim());
                      if (titleController.text.trim().isEmpty ||
                          target == null ||
                          target <= 0) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text(AppLocalizations.of(context)!.fillAllFieldsCorrectly)),
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
          return const Center(child: CircularProgressIndicator(color: kAccent));
        }
        if (snapshot.hasError) {
          return Center(
              child: Text(AppLocalizations.of(context)!.errorWithMessage('${snapshot.error}'),
                  style: appBody(color: kTextSecondary)));
        }

        final goals = snapshot.data ?? [];

        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 120),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(AppLocalizations.of(context)!.goalsTitle, style: appDisplay(fontSize: 24, fontWeight: FontWeight.w700)),
                InkWell(
                  onTap: _addGoal,
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
            Text(AppLocalizations.of(context)!.activeGoals, style: appBody(color: kTextMuted, fontSize: 15)),
            const SizedBox(height: 20),
            if (goals.isEmpty)
              GlassCard(
                padding: const EdgeInsets.symmetric(vertical: 48),
                radius: 24,
                child: Column(
                  children: [
                    const Icon(Icons.flag_outlined, size: 48, color: kTextMuted),
                    const SizedBox(height: 12),
                    Text(AppLocalizations.of(context)!.noGoalsYet, style: appBody(color: kTextMuted)),
                    const SizedBox(height: 4),
                    Text(
                      AppLocalizations.of(context)!.addGoalHint,
                      style: appBody(color: kTextMuted, fontSize: 13),
                      textAlign: TextAlign.center,
                    ),
                  ],
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
        gradient: kSurfaceGradient,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: kBorder),
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
                    color: info.color.withOpacity(0.16),
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
                        style: appBody(
                            fontWeight: FontWeight.w700, fontSize: 16, color: kTextPrimary),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        AppLocalizations.of(context)!.goalTargetPrefix(formatMoney(goal.targetAmount)),
                        style: appBody(color: kTextMuted, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${goal.progressPercent}%',
                  style: appBody(
                    color: isDone ? kGreen : info.color,
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: kTextMuted, size: 20),
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
                backgroundColor: info.color.withOpacity(0.16),
                valueColor: AlwaysStoppedAnimation<Color>(
                    isDone ? kGreen : info.color),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppLocalizations.of(context)!.goalCollected(formatMoney(goal.currentAmount)),
                  style: appBody(color: kTextSecondary, fontSize: 12),
                ),
                if (goal.deadline != null)
                  Text(
                    formatDate(goal.deadline!),
                    style: appBody(color: kTextMuted, fontSize: 12),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}