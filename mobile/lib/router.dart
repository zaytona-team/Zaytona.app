import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'core/di/injection_container.dart';
import 'core/network/token_storage.dart';
import 'features/auth/presentation/bloc/otp_cubit.dart';
import 'features/auth/presentation/pages/signup_page.dart';
import 'features/auth/presentation/pages/otp_page.dart';
import 'features/onboarding/presentation/pages/splash_page.dart';
import 'features/onboarding/presentation/pages/welcome_page.dart';
import 'features/onboarding/presentation/pages/choose_avatar_page.dart';
import 'features/onboarding/presentation/pages/first_group_page.dart';
import 'features/onboarding/presentation/pages/tips_page.dart';
import 'features/groups/presentation/pages/group_settings_page.dart';
import 'features/groups/presentation/pages/group_view.dart';
import 'features/groups/presentation/pages/home_redirect.dart';
import 'features/groups/presentation/pages/invite_to_group_page.dart';
import 'features/histories/presentation/cubit/history_cubit.dart';
import 'features/histories/presentation/pages/history_page.dart';
import 'features/items/presentation/pages/buying_view_page.dart';
import 'features/items/presentation/pages/catalog_page.dart';
import 'features/items/presentation/pages/list_detail_page.dart';
import 'features/settings/presentation/pages/settings_page.dart';
import 'package:zaytona_design_system/zaytona_design_system.dart';
import 'design_system/gallery_page.dart';

/// Paths reachable without a session — everything else requires a token.
bool _isPublicPath(String path) {
  return path == '/' ||
      path == '/welcome' ||
      path == '/signup' ||
      path == '/otp' ||
      path.startsWith('/onboarding/');
}

/// Lets screens (e.g. GroupView) refresh when they become visible again,
/// regardless of whether the return trip was a Navigator pop or a
/// go_router `go()` that replaced the stack.
final routeObserver = RouteObserver<PageRoute>();

enum OtpPurpose { login, registration }

class OtpArgs {
  const OtpArgs({
    required this.phone,
    required this.purpose,
    this.email,
  });

  final String phone;
  final OtpPurpose purpose;
  final String? email;
}

final appRouter = GoRouter(
  observers: [routeObserver],
  initialLocation: '/',
  redirect: (context, state) async {
    final path = state.uri.path;
    // Splash owns the cold-start decision itself (with its own minimum
    // display duration) — don't race it with a second redirect here.
    if (path == '/') return null;

    final hasToken = await TokenStorage.readToken() != null;
    if (!hasToken && !_isPublicPath(path)) return '/welcome';
    if (hasToken &&
        (path == '/welcome' || path == '/signup' || path == '/otp')) {
      return '/home';
    }
    return null;
  },
  errorBuilder: (context, state) => Scaffold(
    body: Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('الصفحة غير موجودة'),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => context.go('/home'),
              child: const Text('العودة للرئيسية'),
            ),
          ],
        ),
      ),
    ),
  ),
  routes: [
    // Cold-start splash: token check → /home, otherwise /welcome.
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashPage(),
    ),
    // Welcome carries the phone-login form inline — there is no separate
    // /login route.
    GoRoute(
      path: '/welcome',
      builder: (context, state) => const WelcomePage(),
    ),
    GoRoute(
      path: '/signup',
      builder: (context, state) => const SignupPage(),
    ),
    GoRoute(
      path: '/otp',
      builder: (context, state) {
        final args = state.extra as OtpArgs;
        return BlocProvider(
          create: (_) => sl<OtpCubit>(),
          child: OtpPage(args: args),
        );
      },
    ),
    // Onboarding (register flow only): avatar pick → first group → home.
    GoRoute(
      path: '/onboarding/avatar',
      builder: (context, state) => const ChooseAvatarPage(),
    ),
    GoRoute(
      path: '/onboarding/first-group',
      builder: (context, state) => const FirstGroupPage(),
    ),
    GoRoute(
      path: '/onboarding/invite',
      builder: (context, state) => InviteToGroupPage(
        inviteCode: state.uri.queryParameters['code'] ?? '',
        onDone: () => context.go('/onboarding/tips'),
      ),
    ),
    GoRoute(
      path: '/onboarding/tips',
      builder: (context, state) => const TipsPage(),
    ),
    // Post-auth landing: resolves the personal/default group and forwards
    // to its detail screen (prototype has no separate home page).
    GoRoute(
      path: '/home',
      builder: (context, state) => const HomeRedirect(),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsPage(),
    ),
    GoRoute(
      path: '/groups',
      // Bare /groups has no standalone page — forward to the default group
      // like /home does. Child routes below carry the real screens.
      builder: (context, state) => const HomeRedirect(),
      routes: [
        // Literal segments must precede ':groupId' so they aren't captured.
        // 'create' and 'join' are no longer routes — CreateGroupSheet and
        // JoinGroupSheet are shown as modal bottom sheets directly from
        // their callers (drawer, onboarding).
        GoRoute(
          path: ':groupId',
          // Key forces a fresh GroupView (and cubits) when switching groups —
          // go_router reuses the page element for a same-route param change.
          builder: (context, state) {
            final groupId = state.pathParameters['groupId']!;
            return GroupView(key: ValueKey(groupId), groupId: groupId);
          },
          routes: [
            GoRoute(
              path: 'settings',
              builder: (context, state) => GroupSettingsPage(
                groupId: state.pathParameters['groupId']!,
              ),
            ),
            GoRoute(
              path: 'invite',
              builder: (context, state) => InviteToGroupPage(
                inviteCode: state.uri.queryParameters['code'] ?? '',
              ),
            ),
            GoRoute(
              path: 'lists/:listId',
              builder: (context, state) => ListDetailPage(
                groupId: state.pathParameters['groupId']!,
                listId: state.pathParameters['listId']!,
                listName: state.uri.queryParameters['name'] ?? '',
                listColor: ZaytonaListAccent.values.firstWhere(
                  (a) => a.name == state.uri.queryParameters['color'],
                  orElse: () => ZaytonaListAccent.indigo,
                ),
                isPrivateGroup: state.uri.queryParameters['private'] == 'true',
              ),
              routes: [
                // Trip alerts (Story 7) now open as a sheet directly from
                // the list detail bell (see ListDetailPage._openNotifications)
                // instead of a pushed route.
                GoRoute(
                  path: 'buying',
                  builder: (context, state) => BuyingViewPage(
                    groupId: state.pathParameters['groupId']!,
                    listId: state.pathParameters['listId']!,
                    listName: state.uri.queryParameters['name'] ?? '',
                  ),
                ),
                // "Add item" — full-screen catalog (search/browse/my-items/
                // manual entry). list_detail_page.dart already pushes here.
                GoRoute(
                  path: 'add-item',
                  builder: (context, state) => CatalogPage(
                    listId: state.pathParameters['listId']!,
                  ),
                ),
                // Activity log (Story 8) — reached from the list app bar.
                GoRoute(
                  path: 'history',
                  builder: (context, state) => BlocProvider(
                    create: (_) => sl<HistoryCubit>()..load(
                          state.pathParameters['groupId']!,
                          state.pathParameters['listId']!,
                        ),
                    child: HistoryPage(
                      listId: state.pathParameters['listId']!,
                      listName: state.uri.queryParameters['name'] ?? '',
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    ),
    // Design-system viewer — debug builds only.
    if (kDebugMode)
      GoRoute(
        path: '/gallery',
        builder: (context, state) => const GalleryPage(),
      ),
  ],
);
