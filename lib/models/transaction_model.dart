import 'package:cloud_firestore/cloud_firestore.dart';

enum TransactionType { income, expense }

class TransactionModel {
  final String id;
  final String title;
  final String category;
  final double amount;
  final TransactionType type;
  final DateTime date;

  TransactionModel({
    required this.id,
    required this.title,
    required this.category,
    required this.amount,
    required this.type,
    required this.date,
  });

  Map<String, dynamic> toMap(String userId) {
    return {
      'userId': userId,
      'title': title,
      'category': category,
      'amount': amount,
      'type': type == TransactionType.income ? 'income' : 'expense',
      'createdAt': Timestamp.fromDate(date),
    };
  }

  factory TransactionModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TransactionModel(
      id: doc.id,
      title: data['title'] ?? '',
      category: data['category'] ?? '',
      amount: (data['amount'] as num).toDouble(),
      type: data['type'] == 'income'
          ? TransactionType.income
          : TransactionType.expense,
      date: (data['createdAt'] as Timestamp).toDate(),
    );
  }
}