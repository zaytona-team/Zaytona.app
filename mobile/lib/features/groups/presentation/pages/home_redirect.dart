import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:zaytona_design_system/zaytona_design_system.dart';
import '../../../../core/network/token_storage.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/group.dart';
import '../cubit/groups/list_groups_cubit.dart';
import '../widgets/list_groups_provider.dart';

/// Post-auth landing (prototype app.jsx: reset('groupDetail', lastGroup)).
/// Loads the user's groups and forwards to the personal/default group's
/// detail screen — the app has no separate "home" page.
/// A direct "get my default group" endpoint would avoid the extra list
/// round-trip; logged in Documentation/backend-needs.md.
class HomeRedirect extends StatelessWidget {
  const HomeRedirect({super.key});

  @override
  Widget build(BuildContext context) {
    return const ListGroupsProvider(child: _HomeRedirectView());
  }
}

class _HomeRedirectView extends StatelessWidget {
  const _HomeRedirectView();

  void _goToDefaultGroup(BuildContext context, List<Group> groups) {
    final home = groups.firstWhere(
      (g) => g.isPrivate,
      orElse: () => groups.first,
    );
    context.go('/groups/${home.groupId}');
  }

  // A signed-in account should always have at least its auto-created
  // private group. An empty list here means the session outlived its
  // account (e.g. the backend DB was reset) — treat it as logged out
  // rather than crashing on `groups.first`.
  Future<void> _handleOrphanedSession(BuildContext context) async {
    await TokenStorage.clearToken();
    if (context.mounted) context.go('/welcome');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ZaytonaColors.bgApp,
      body: BlocBuilder<ListGroupsCubit, ListGroupsState>(
        builder: (context, state) {
          if (state is ListGroupsLoaded) {
            // Cubit may already be loaded by the time this mounts, so
            // redirect off current state, not just future transitions.
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!context.mounted) return;
              if (state.groups.isEmpty) {
                _handleOrphanedSession(context);
              } else {
                _goToDefaultGroup(context, state.groups);
              }
            });
          }
          return switch (state) {
            ListGroupsError(:final message) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(message, style: ZaytonaType.bodySm),
                    const SizedBox(height: ZaytonaSpacing.space3),
                    TextButton(
                      onPressed: () => context.read<ListGroupsCubit>().load(),
                      child: Text(AppLocalizations.of(context)!.retryAction),
                    ),
                  ],
                ),
              ),
            _ => const Center(child: ZaytonaSpinningLogo()),
          };
        },
      ),
    );
  }
}