import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/group.dart';
import '../../../domain/usecases/join_group_usecase.dart';
import 'list_groups_cubit.dart';

part 'join_group_state.dart';

class JoinGroupCubit extends Cubit<JoinGroupState> {
  JoinGroupCubit(this._joinGroupUseCase, this._listGroupsCubit)
      : super(JoinGroupInitial());
  final JoinGroupUseCase _joinGroupUseCase;
  final ListGroupsCubit _listGroupsCubit;

  Future<void> submit(String inviteCode) async {
    emit(JoinGroupLoading());
    final result = await _joinGroupUseCase(JoinGroupParams(inviteCode));
    result.fold(
      (failure) => emit(JoinGroupError(failure.message)),
      (group) {
        _listGroupsCubit.refresh();
        emit(JoinGroupSuccess(group));
      },
    );
  }
}
