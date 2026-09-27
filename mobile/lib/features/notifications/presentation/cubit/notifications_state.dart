part of 'notifications_cubit.dart';

sealed class NotificationsState extends Equatable {
  const NotificationsState();

  @override
  List<Object?> get props => [];
}

class NotificationsLoading extends NotificationsState {
  const NotificationsLoading();
}

/// Members failed to load — the pickers need them, so the page can't work.
class NotificationsLoadError extends NotificationsState {
  const NotificationsLoadError(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}

/// Members loaded; [sending] disables actions while a push is in flight.
class NotificationsReady extends NotificationsState {
  const NotificationsReady(this.members, {this.sending = false});
  final List<GroupMember> members;
  final bool sending;

  @override
  List<Object?> get props => [members, sending];
}

/// Which trip-alert action produced a [NotificationsSent], so the page can
/// show an action-specific confirmation (the buyer who taps heading-out
/// gets told they're heading to the store, not just a generic "sent").
enum NotificationAction { headingToStore, assignBuyer, remindMember }

/// One-shot: a push was accepted — page shows the "sent" snackbar.
class NotificationsSent extends NotificationsReady {
  const NotificationsSent(super.members, this.action);
  final NotificationAction action;

  @override
  List<Object?> get props => [members, action];
}

/// One-shot: a push failed — page shows [message] in a snackbar.
class NotificationsSendError extends NotificationsReady {
  const NotificationsSendError(super.members, this.message);
  final String message;

  @override
  List<Object?> get props => [members, message];
}
