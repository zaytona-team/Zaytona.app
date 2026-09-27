import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:zaytona_design_system/zaytona_design_system.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/network/token_storage.dart';
import '../cubit/groups/group_settings_cubit.dart';
import '../widgets/group_settings_body.dart';

// Group settings (prototype: AdminSettings, screens-more.jsx 298+).
class GroupSettingsPage extends StatelessWidget {
  final String groupId;

  const GroupSettingsPage({super.key, required this.groupId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<GroupSettingsCubit>()..load(groupId),
      child: const _GroupSettingsView(),
    );
  }
}

class _GroupSettingsView extends StatefulWidget {
  const _GroupSettingsView();

  @override
  State<_GroupSettingsView> createState() => _GroupSettingsViewState();
}

class _GroupSettingsViewState extends State<_GroupSettingsView> {
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    TokenStorage.readUserId().then((id) {
      if (mounted) setState(() => _currentUserId = id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<GroupSettingsCubit, GroupSettingsState>(
      listener: (context, state) {
        if (state is GroupSettingsClosed) {
          context.go('/home');
        } else if (state is GroupSettingsLoaded && state.actionError != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.actionError!)),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: ZaytonaColors.bgApp,
          body: SafeArea(
            child: switch (state) {
              GroupSettingsInitial() ||
              GroupSettingsLoading() ||
              GroupSettingsClosed() =>
                const Center(child: ZaytonaSpinningLogo()),
              GroupSettingsError(:final message) => Center(
                  child: Text(message, style: ZaytonaType.bodySm),
                ),
              GroupSettingsLoaded() => GroupSettingsBody(
                  state: state,
                  currentUserId: _currentUserId,
                ),
            },
          ),
        );
      },
    );
  }
}
