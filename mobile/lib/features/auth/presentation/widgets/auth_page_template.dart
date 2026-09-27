import 'package:flutter/material.dart';
import 'package:zaytona_design_system/zaytona_design_system.dart';
import 'auth_primary_button.dart';

/// Shared shell for auth pages (signup, OTP): logo pinned at the very top as
/// a standalone heading, title/subtitle below it, a scrollable [body], and a
/// bottom-pinned primary button with an optional [footer] under it.
class AuthPageTemplate extends StatelessWidget {
  const AuthPageTemplate({
    super.key,
    required this.title,
    this.subtitle,
    this.titleTrailing,
    required this.body,
    required this.buttonLabel,
    required this.onButtonPressed,
    this.isLoading = false,
    this.footer,
  });

  final String title;
  final String? subtitle;
  final Widget? titleTrailing;
  final Widget body;
  final String buttonLabel;
  final VoidCallback? onButtonPressed;
  final bool isLoading;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ZaytonaColors.bgApp,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(ZaytonaSpacing.gutter),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(child: Image.asset('assets/images/logo.png', height: 56)),
              SizedBox(height: ZaytonaSpacing.space5),
              Text(title, style: ZaytonaType.displaySm),
              if (subtitle != null) ...[
                SizedBox(height: ZaytonaSpacing.space1),
                Text(subtitle!, style: ZaytonaType.bodySm.copyWith(color: ZaytonaColors.textMuted)),
              ],
              ?titleTrailing,
              SizedBox(height: ZaytonaSpacing.space5),
              Expanded(child: SingleChildScrollView(child: body)),
              SizedBox(height: ZaytonaSpacing.space4),
              AuthPrimaryButton(label: buttonLabel, isLoading: isLoading, onPressed: onButtonPressed),
              if (footer != null) ...[
                SizedBox(height: ZaytonaSpacing.space4),
                footer!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}
