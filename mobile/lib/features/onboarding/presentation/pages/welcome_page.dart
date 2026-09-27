import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:zaytona_design_system/zaytona_design_system.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/l10n/locale_controller.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/presentation/bloc/login_cubit.dart';
import '../widgets/inline_login_form.dart';
import '../widgets/lang_toggle.dart';

/// Prototype: Welcome, screens-auth.jsx. Carries the phone-login form
/// inline (login_page.dart folded in) so returning users don't need a
/// separate step — "start now" still leads to signup; entering a phone
/// number and submitting logs in directly from here.
class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final localeController = sl<LocaleController>();
    return Scaffold(
      backgroundColor: ZaytonaColors.bgApp,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              right: -40,
              top: -8,
              child: Transform.rotate(
                angle: -12 * 3.14159265 / 180,
                child: Image.asset(
                  'assets/images/zaytona_doll_cut.png',
                  width: 128,
                  height: 130,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                ZaytonaSpacing.space6,
                ZaytonaSpacing.space4,
                ZaytonaSpacing.space6,
                ZaytonaSpacing.space6,
              ),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: ValueListenableBuilder<Locale>(
                      valueListenable: localeController,
                      builder: (context, locale, _) => LangToggle(
                        isArabic: locale.languageCode == 'ar',
                        onTap: () => localeController.switchTo(
                          Locale(locale.languageCode == 'ar' ? 'en' : 'ar'),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: ZaytonaSpacing.space3),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset('assets/images/logo.png', width: 400),
                        SizedBox(height: ZaytonaSpacing.space1),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            l10n.welcomeTagline,
                            maxLines: 1,
                            style: ZaytonaType.title.copyWith(
                              color: ZaytonaColors.navy,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  BlocProvider(
                    create: (_) => LoginCubit(),
                    child: const InlineLoginForm(),
                  ),
                  SizedBox(height: ZaytonaSpacing.space5),
                  GestureDetector(
                    onTap: () => context.push('/signup'),
                    child: Text.rich(
                      TextSpan(
                        style: ZaytonaType.caption,
                        children: [
                          TextSpan(text: l10n.noAccountPrompt),
                          TextSpan(
                            text: l10n.welcomeSignupCta,
                            style: const TextStyle(
                              color: ZaytonaColors.red,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
