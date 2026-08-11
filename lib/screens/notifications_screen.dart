import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:finance_app/l10n/app_localizations.dart';
import '../models/notification_model.dart';
import '../theme/app_theme.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final _firestore = FirebaseFirestore.instance;
  late final Stream<List<NotificationModel>> _notificationsStream;

  String? get _userId => FirebaseAuth.instance.currentUser?.uid;

  @override
  void initState() {
    super.initState();
    _notificationsStream = _buildStream();
  }

  Stream<List<NotificationModel>> _buildStream() {
    if (_userId == null) return const Stream.empty();
    return _firestore
        .collection('notifications')
        .where('userId', isEqualTo: _userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => NotificationModel.fromDoc(d)).toList());
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd.MM.yyyy, HH:mm').format(date);
  }

  Future<void> _markAsRead(NotificationModel n) async {
    if (n.isRead) return;
    await _firestore.collection('notifications').doc(n.id).update({'isRead': true});
  }

  Future<void> _delete(String id) async {
    await _firestore.collection('notifications').doc(id).delete();
  }

  IconData _iconFor(NotificationType type) {
    switch (type) {
      case NotificationType.goalCompleted:
        return Icons.flag_rounded;
      case NotificationType.budgetExceeded:
        return Icons.warning_amber_rounded;
    }
  }

  Color _colorFor(NotificationType type) {
    switch (type) {
      case NotificationType.goalCompleted:
        return kGreen;
      case NotificationType.budgetExceeded:
        return kClay;
    }
  }

  /// Хабарлама ішіндегі тырнақшадағы атауды (мақсат аты немесе категория) бөліп алу
  String _extractName(String message) {
    final regExp = RegExp(r'[«""](.*?)[»""]');
    final match = regExp.firstMatch(message);
    if (match != null && match.groupCount >= 1) {
      return match.group(1) ?? '';
    }
    return '';
  }

  /// Ағымдағы тілге сәйкес Тақырыпты қайтару
  String _getLocalizedTitle(NotificationModel n, AppLocalizations l10n) {
    switch (n.type) {
      case NotificationType.goalCompleted:
        return l10n.goalReachedTitle;
      case NotificationType.budgetExceeded:
        return l10n.budgetExceededTitle;
    }
  }

  /// Ағымдағы тілге сәйкес Хабарламаны қайтару
  String _getLocalizedMessage(NotificationModel n, AppLocalizations l10n) {
    final extractedName = _extractName(n.message);

    switch (n.type) {
      case NotificationType.goalCompleted:
        return l10n.goalReachedMessage(extractedName);
      case NotificationType.budgetExceeded:
        return l10n.budgetExceededMessage(extractedName);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(l10n.notifications, style: appBody(fontWeight: FontWeight.w700, fontSize: 20)),
        centerTitle: true,
      ),
      body: AppBackground(
        safeArea: false,
        child: SafeArea(
          child: StreamBuilder<List<NotificationModel>>(
            stream: _notificationsStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: kAccent));
              }
              if (snapshot.hasError) {
                return Center(
                    child: Text(l10n.errorWithMessage(snapshot.error.toString()),
                        style: appBody(color: kTextSecondary)));
              }

              final notifications = snapshot.data ?? [];

              if (notifications.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.notifications_none_rounded, size: 48, color: kTextMuted),
                        const SizedBox(height: 12),
                        Text(l10n.noNotificationsYet, style: appBody(color: kTextMuted)),
                      ],
                    ),
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
                itemCount: notifications.length,
                itemBuilder: (context, index) {
                  final n = notifications[index];

                  // Ағымдағы таңдаулы тілдегі мәтіндерді аламыз:
                  final localizedTitle = _getLocalizedTitle(n, l10n);
                  final localizedMessage = _getLocalizedMessage(n, l10n);

                  return Dismissible(
                    key: ValueKey(n.id),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: kClay.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Icon(Icons.delete_outline, color: kClay),
                    ),
                    onDismissed: (_) => _delete(n.id),
                    child: GestureDetector(
                      onTap: () => _markAsRead(n),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: kSurfaceGradient,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: n.isRead ? kBorder : _colorFor(n.type).withOpacity(0.5),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: _colorFor(n.type).withOpacity(0.16),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(_iconFor(n.type), color: _colorFor(n.type), size: 20),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(localizedTitle,
                                      style: appBody(
                                          fontWeight: FontWeight.w700, fontSize: 14.5, color: kTextPrimary)),
                                  const SizedBox(height: 4),
                                  Text(localizedMessage, style: appBody(color: kTextSecondary, fontSize: 13)),
                                  const SizedBox(height: 6),
                                  Text(_formatDate(n.createdAt),
                                      style: appBody(color: kTextMuted, fontSize: 11)),
                                ],
                              ),
                            ),
                            if (!n.isRead)
                              Container(
                                width: 8,
                                height: 8,
                                margin: const EdgeInsets.only(top: 4),
                                decoration: BoxDecoration(color: _colorFor(n.type), shape: BoxShape.circle),
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}