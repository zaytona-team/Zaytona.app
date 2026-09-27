import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/shopping_list.dart';
import '../../../domain/usecases/create_list_usecase.dart';

part 'create_list_state.dart';

class CreateListCubit extends Cubit<CreateListState> {
  CreateListCubit(this._createListUseCase) : super(CreateListInitial());
  final CreateListUseCase _createListUseCase;

  Future<void> submit({required String groupId, required String name}) async {
    emit(CreateListLoading());
    final result = await _createListUseCase(
      CreateListParams(groupId: groupId, name: name),
    );
    result.fold(
      (failure) => emit(CreateListError(failure.message)),
      (list) => emit(CreateListSuccess(list)),
    );
  }
}
