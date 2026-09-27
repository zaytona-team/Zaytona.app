import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection_container.dart';
import '../cubit/groups/list_groups_cubit.dart';

// Wires the shared ListGroupsCubit singleton; load() is a no-op once
// already loaded, so this is safe to use from multiple entry points.
class ListGroupsProvider extends StatelessWidget {
  final Widget child;

  const ListGroupsProvider({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    // .value, not create: — ListGroupsCubit is a shared singleton;
    // create: would auto-close it every time this widget unmounts.
    return BlocProvider.value(
      value: sl<ListGroupsCubit>()..load(),
      child: child,
    );
  }
}
