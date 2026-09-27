import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/group.dart';
import '../../../domain/entities/group_member.dart';
import '../../../domain/usecases/get_group_members_usecase.dart';
import '../../../domain/usecases/get_group_usecase.dart';

part 'get_group_state.dart';

class GetGroupCubit extends Cubit<GetGroupState> {
  GetGroupCubit(this._getGroupUseCase, this._getMembersUseCase)
      : super(GetGroupInitial());
  final GetGroupUseCase _getGroupUseCase;
  final GetGroupMembersUseCase _getMembersUseCase;

  Future<void> load(String groupId) async {
    emit(GetGroupLoading());
    final result = await _getGroupUseCase(GetGroupParams(groupId));
    await result.fold(
      (failure) async => emit(GetGroupError(failure.message)),
      (group) async {
        if (group.isPrivate) {
          emit(GetGroupLoaded(group));
          return;
        }
        final membersResult =
            await _getMembersUseCase(GetGroupMembersParams(groupId));
        membersResult.fold(
          (failure) => emit(GetGroupError(failure.message)),
          (members) => emit(GetGroupLoaded(group, members: members)),
        );
      },
    );
  }
}
