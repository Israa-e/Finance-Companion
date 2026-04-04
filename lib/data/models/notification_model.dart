import 'package:equatable/equatable.dart';

enum NotificationType {
  spendingAlert,
  goalDeadline,
  goalCompleted,
  streakMilestone,
  monthlyBudgetWarning,
}

class NotificationModel extends Equatable {
  final String id;
  final String title;
  final String body;
  final NotificationType type;
  final DateTime createdAt;
  final bool isRead;

  const NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.createdAt,
    this.isRead = false,
  });

  NotificationModel copyWith({
    String? id,
    String? title,
    String? body,
    NotificationType? type,
    DateTime? createdAt,
    bool? isRead,
  }) =>
      NotificationModel(
        id: id ?? this.id,
        title: title ?? this.title,
        body: body ?? this.body,
        type: type ?? this.type,
        createdAt: createdAt ?? this.createdAt,
        isRead: isRead ?? this.isRead,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'body': body,
        'type': type.name,
        'createdAt': createdAt.toIso8601String(),
        'isRead': isRead ? 1 : 0,
      };

  factory NotificationModel.fromMap(Map<String, dynamic> map) =>
      NotificationModel(
        id: map['id'] as String,
        title: map['title'] as String,
        body: map['body'] as String,
        type: NotificationType.values.byName(map['type'] as String),
        createdAt: DateTime.parse(map['createdAt'] as String),
        isRead: (map['isRead'] as int) == 1,
      );

  @override
  List<Object?> get props => [id, title, body, type, createdAt, isRead];
}