import '../../features/groups/presentation/cubit/groups/list_groups_cubit.dart';
import 'injection_container.dart';
import '../realtime/socket_service.dart';


void clearSessionState() {
  sl<ListGroupsCubit>().clear();
  sl<SocketService>().disconnect();
}
