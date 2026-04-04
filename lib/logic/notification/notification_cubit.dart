import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/notification_model.dart';
import '../../data/repositories/notification_repository.dart';

// ── State ─────────────────────────────────────────────────────────────────────

class NotificationState extends Equatable {
  final List<NotificationModel> notifications;
  final int unreadCount;
  final bool isLoading;

  const NotificationState({
    this.notifications = const [],
    this.unreadCount = 0,
    this.isLoading = false,
  });

  NotificationState copyWith({
    List<NotificationModel>? notifications,
    int? unreadCount,
    bool? isLoading,
  }) =>
      NotificationState(
        notifications: notifications ?? this.notifications,
        unreadCount: unreadCount ?? this.unreadCount,
        isLoading: isLoading ?? this.isLoading,
      );

  @override
  List<Object?> get props => [notifications, unreadCount, isLoading];
}

// ── Cubit ─────────────────────────────────────────────────────────────────────

class NotificationCubit extends Cubit<NotificationState> {
  final NotificationRepository _repo;

  NotificationCubit(this._repo) : super(const NotificationState());

  Future<void> load() async {
    emit(state.copyWith(isLoading: true));
    try {
      final notifications = await _repo.getAll();
      final unreadCount = await _repo.getUnreadCount();
      emit(state.copyWith(
        notifications: notifications,
        unreadCount: unreadCount,
        isLoading: false,
      ));
    } catch (_) {
      emit(state.copyWith(isLoading: false));
    }
  }

  Future<void> markAllRead() async {
    await _repo.markAllRead();
    emit(state.copyWith(
      notifications: state.notifications
          .map((n) => n.copyWith(isRead: true))
          .toList(),
      unreadCount: 0,
    ));
  }

  Future<void> markRead(String id) async {
    await _repo.markRead(id);
    final updated = state.notifications
        .map((n) => n.id == id ? n.copyWith(isRead: true) : n)
        .toList();
    final unread = updated.where((n) => !n.isRead).length;
    emit(state.copyWith(notifications: updated, unreadCount: unread));
  }

  Future<void> clearAll() async {
    await _repo.deleteAll();
    emit(state.copyWith(notifications: [], unreadCount: 0));
  }
}