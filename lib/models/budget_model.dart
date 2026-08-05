import 'package:cloud_firestore/cloud_firestore.dart';

class BudgetModel {
  final String id;
  final String category;
  final double limit;
  final int month;
  final int year;

  BudgetModel({
    required this.id,
    required this.category,
    required this.limit,
    required this.month,
    required this.year,
  });

  Map<String, dynamic> toMap(String userId) {
    return {
      'userId': userId,
      'category': category,
      'limit': limit,
      'month': month,
      'year': year,
    };
  }

  factory BudgetModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return BudgetModel(
      id: doc.id,
      category: data['category'] ?? '',
      limit: (data['limit'] as num).toDouble(),
      month: data['month'] ?? 0,
      year: data['year'] ?? 0,
    );
  }
}