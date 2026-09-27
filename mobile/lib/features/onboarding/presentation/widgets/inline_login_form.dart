import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:zaytona_design_system/zaytona_design_system.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../router.dart';
import '../../../auth/domain/validators/login_validator.dart';
import '../../../auth/presentation/bloc/login_cubit.dart';

/// Phone-login form folded into WelcomePage — login_page.dart's fields,
/// validator, and cubit wiring, unchanged, just restyled with the DS.
class InlineLoginForm extends StatefulWidget {
  const InlineLoginForm({super.key});

  @override
  State<InlineLoginForm> createState() => _InlineLoginFormState();
}

class _InlineLoginFormState extends State<InlineLoginForm> {
  final _phoneController = TextEditingController();
  String? _phoneError;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _submitLogin(BuildContext context) {
    final phone = _phoneController.text.trim();
    final error = LoginValidator.validatePhone(phone, AppLocalizations.of(context)!);
    if (error != null) {
      setState(() => _phoneError = error);
      return;
    }
    setState(() => _phoneError = null);
    context.read<LoginCubit>().submit(LoginValidator.normalizePhone(phone));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocConsumer<LoginCubit, LoginState>(
      listener: (context, state) {
        if (state is LoginOtpRequired) {
          context.push(
            '/otp',
            extra: OtpArgs(phone: state.phone, purpose: OtpPurpose.login),
          );
        } else if (state is LoginError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is LoginLoading;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: Text(l10n.phoneLabel, style: ZaytonaType.fieldLabel),
            ),
            SizedBox(height: ZaytonaSpacing.space2),
            ZaytonaTextField(
              controller: _phoneController,
              placeholder: l10n.phoneHint,
              keyboardType: TextInputType.phone,
              icon: Icon(Icons.phone_outlined, size: ZaytonaSpacing.iconSm),
              error: _phoneError,
              onChanged: (_) {
                if (_phoneError != null) setState(() => _phoneError = null);
              },
              onSubmitted: (_) => _submitLogin(context),
            ),
            SizedBox(height: ZaytonaSpacing.space4),
            ZaytonaButton(
              label: l10n.loginAction,
              variant: ZaytonaButtonVariant.primary,
              size: ZaytonaButtonSize.lg,
              block: true,
              disabled: isLoading,
              onTap: () => _submitLogin(context),
            ),
          ],
        );
      },
    );
  }
}
