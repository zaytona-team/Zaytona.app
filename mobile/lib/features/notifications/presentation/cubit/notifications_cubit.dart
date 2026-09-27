import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../../../groups/domain/entities/group_member.dart';
import '../../../groups/domain/usecases/get_group_members_usecase.dart';
import '../../domain/usecases/assign_buyer_usecase.dart';
import '../../domain/usecases/heading_to_store_usecase.dart';
import '../../domain/usecases/remind_member_usecase.dart';

part 'notifications_state.dart';

/// Trip alerts (Story 7). Loads the group's members for the buyer/reminder
/// pickers, then fires the push endpoints. US-43 (remind-me) has plumbing
/// but no UI yet — no arb spec for its card.
class NotificationsCubit extends Cubit<NotificationsState> {
  NotificationsCubit(
    this._getMembers,
    this._headingToStore,
    this._assignBuyer,
    this._remindMember,
  ) : super(const NotificationsLoading());

  final GetGroupMembersUseCase _getMembers;
  final HeadingToStoreUseCase _headingToStore;
  final AssignBuyerUseCase _assignBuyer;
  final RemindMemberUseCase _remindMember;

  Future<void> load(String groupId) async {
    emit(const NotificationsLoading());
    final result = await _getMembers(GetGroupMembersParams(groupId));
    result.fold(
      (failure) => emit(NotificationsLoadError(failure.message)),
      (members) => emit(NotificationsReady(members)),
    );
  }

  Future<void> headingToStore(String listId) {
    return _send(
      NotificationAction.headingToStore,
      () => _headingToStore(HeadingToStoreParams(listId)),
    );
  }

  Future<void> assignBuyer(String listId, String memberId) {
    return _send(
      NotificationAction.assignBuyer,
      () => _assignBuyer(AssignBuyerParams(listId: listId, memberId: memberId)),
    );
  }

  Future<void> remindMember(String listId, String memberId) {
    return _send(
      NotificationAction.remindMember,
      () => _remindMember(RemindMemberParams(listId: listId, memberId: memberId)),
    );
  }

  Future<void> _send(
    NotificationAction action,
    Future<Result<Failure, void>> Function() request,
  ) async {
    final current = state;
    if (current is! NotificationsReady || current.sending) return;
    final members = current.members;
    emit(NotificationsReady(members, sending: true));
    final result = await request();
    result.fold(
      (failure) => emit(NotificationsSendError(members, failure.message)),
      (_) => emit(NotificationsSent(members, action)),
    );
  }
}
