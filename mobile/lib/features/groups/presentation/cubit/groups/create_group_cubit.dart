import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/group.dart';
import '../../../domain/usecases/create_group_usecase.dart';
import 'list_groups_cubit.dart';

part 'create_group_state.dart';

class CreateGroupCubit extends Cubit<CreateGroupState> {
  CreateGroupCubit(this._createGroupUseCase, this._listGroupsCubit)
      : super(CreateGroupInitial());
  final CreateGroupUseCase _createGroupUseCase;
  final ListGroupsCubit _listGroupsCubit;

  Future<void> submit({required String name, String? icon, String type = 'household'}) async {
    emit(CreateGroupLoading());
    final result = await _createGroupUseCase(
      CreateGroupParams(name: name, icon: icon, type: type),
    );
    result.fold(
      (failure) => emit(CreateGroupError(failure.message)),
      (group) {
        _listGroupsCubit.upsertGroup(group);
        emit(CreateGroupSuccess(group));
      },
    );
  }
}