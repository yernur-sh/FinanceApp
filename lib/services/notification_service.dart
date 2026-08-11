import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/notification_model.dart';

class NotificationService {
  static final _firestore = FirebaseFirestore.instance;

  static Future<void> _createIfNotExists({
    required String userId,
    required String title,
    required String message,
    required NotificationType type,
    required String relatedId,
  }) async {
    final existing = await _firestore
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .where('relatedId', isEqualTo: relatedId)
        .where('type', isEqualTo: type.name)
        .limit(1)
        .get();

    if (existing.docs.isNotEmpty) return;

    await _firestore.collection('notifications').add(
      NotificationModel(
        id: '',
        userId: userId,
        title: title,
        message: message,
        type: type,
        relatedId: relatedId,
        createdAt: DateTime.now(),
      ).toMap(),
    );
  }

  static Future<void> notifyGoalCompleted({
    required String userId,
    required String goalId,
    required String goalTitle,
  }) {
    return _createIfNotExists(
      userId: userId,
      title: 'Мақсатқа жеттіңіз! 🎉',
      message: '«$goalTitle» мақсаты үшін қаражат толық жиналды.',
      type: NotificationType.goalCompleted,
      relatedId: goalId,
    );
  }

  static Future<void> notifyBudgetExceeded({
    required String userId,
    required String budgetId,
    required String category,
    required int month,
    required int year,
  }) {
    final relatedId = '$budgetId-$month-$year';
    return _createIfNotExists(
      userId: userId,
      title: 'Бюджет лимиті асып кетті',
      message: '«$category» санаты бойынша шығын лимиттен асты.',
      type: NotificationType.budgetExceeded,
      relatedId: relatedId,
    );
  }
}