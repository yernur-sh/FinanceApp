import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum GoalCategory { savings, travel, emergency, other }

class GoalCategoryInfo {
  final IconData icon;
  final Color color;
  final String label;
  const GoalCategoryInfo(this.icon, this.color, this.label);
}

const Map<GoalCategory, GoalCategoryInfo> goalCategoryData = {
  GoalCategory.savings: GoalCategoryInfo(
      Icons.savings_outlined, Color(0xFF34C471), 'Жинақ'),
  GoalCategory.travel: GoalCategoryInfo(
      Icons.flight_takeoff, Color(0xFF4A90E2), 'Саяхат'),
  GoalCategory.emergency: GoalCategoryInfo(
      Icons.work_outline, Color(0xFFE0A83E), 'Жинақ қоры'),
  GoalCategory.other: GoalCategoryInfo(
      Icons.flag_outlined, Color(0xFF6C63FF), 'Басқа'),
};

class GoalModel {
  final String id;
  final String title;
  final double targetAmount;
  final double currentAmount;
  final DateTime? deadline;
  final GoalCategory category;
  final DateTime createdAt;

  GoalModel({
    required this.id,
    required this.title,
    required this.targetAmount,
    required this.currentAmount,
    required this.deadline,
    required this.category,
    required this.createdAt,
  });

  double get progress =>
      targetAmount <= 0 ? 0 : (currentAmount / targetAmount).clamp(0, 1);

  int get progressPercent => (progress * 100).round();

  Map<String, dynamic> toMap(String userId) {
    return {
      'userId': userId,
      'title': title,
      'targetAmount': targetAmount,
      'currentAmount': currentAmount,
      'deadline': deadline != null ? Timestamp.fromDate(deadline!) : null,
      'category': category.name,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory GoalModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return GoalModel(
      id: doc.id,
      title: data['title'] ?? '',
      targetAmount: (data['targetAmount'] as num).toDouble(),
      currentAmount: (data['currentAmount'] as num).toDouble(),
      deadline: data['deadline'] != null
          ? (data['deadline'] as Timestamp).toDate()
          : null,
      category: GoalCategory.values.firstWhere(
            (c) => c.name == data['category'],
        orElse: () => GoalCategory.other,
      ),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }
}