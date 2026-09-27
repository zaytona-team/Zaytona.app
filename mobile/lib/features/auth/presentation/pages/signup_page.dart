import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:zaytona_design_system/zaytona_design_system.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../router.dart';
import '../../domain/validators/login_validator.dart';
import '../../domain/validators/signup_validator.dart';
import '../bloc/signup_cubit.dart';
import '../widgets/already_have_account_link.dart';
import '../widgets/auth_page_template.dart';
import '../widgets/labeled_text_field.dart';

class SignupPage extends StatelessWidget {
  const SignupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(create: (_) => SignupCubit(), child: const _SignupView());
  }
}

class _SignupView extends StatefulWidget {
  const _SignupView();

  @override
  State<_SignupView> createState() => _SignupViewState();
}

class _SignupViewState extends State<_SignupView> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();

  String? _firstNameError;
  String? _lastNameError;
  String? _phoneError;
  String? _emailError;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _submitSignup(AppLocalizations l10n) {
    final firstNameError = SignupValidator.validateName(_firstNameController.text, l10n);
    final lastNameError = SignupValidator.validateName(_lastNameController.text, l10n);
    final phoneError = SignupValidator.validatePhone(_phoneController.text, l10n);
    final emailError = SignupValidator.validateOptionalEmail(_emailController.text, l10n);
    setState(() {
      _firstNameError = firstNameError;
      _lastNameError = lastNameError;
      _phoneError = phoneError;
      _emailError = emailError;
    });
    if (firstNameError != null || lastNameError != null || phoneError != null || emailError != null) {
      return;
    }
    final email = _emailController.text.trim();
    context.read<SignupCubit>().submit(
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      phone: LoginValidator.normalizePhone(_phoneController.text),
      email: email.isEmpty ? null : email,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocConsumer<SignupCubit, SignupState>(
      listener: (context, state) {
        if (state is SignupSuccess) {
          context.push(
            '/otp',
            extra: OtpArgs(phone: state.phone, email: state.email, purpose: OtpPurpose.registration),
          );
        } else if (state is SignupError) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      builder: (context, state) {
        final isLoading = state is SignupLoading;

        return AuthPageTemplate(
          title: l10n.signupTitle,
          subtitle: l10n.signupSubtitle,
          buttonLabel: l10n.signupAction,
          isLoading: isLoading,
          onButtonPressed: () => _submitSignup(l10n),
          footer: AlreadyHaveAccountLink(onTap: () => context.go('/welcome')),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: LabeledTextField(
                      label: l10n.firstNameLabel,
                      controller: _firstNameController,
                      error: _firstNameError,
                      onChanged: (_) => setState(() => _firstNameError = null),
                    ),
                  ),
                  SizedBox(width: ZaytonaSpacing.space3),
                  Expanded(
                    child: LabeledTextField(
                      label: l10n.lastNameLabel,
                      controller: _lastNameController,
                      error: _lastNameError,
                      onChanged: (_) => setState(() => _lastNameError = null),
                    ),
                  ),
                ],
              ),
              SizedBox(height: ZaytonaSpacing.space4),
              LabeledTextField(
                label: l10n.phoneLabel,
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                placeholder: l10n.phoneHint,
                icon: const Icon(Icons.phone_outlined, size: 18),
                error: _phoneError,
                textDirection: TextDirection.ltr,
                onChanged: (_) => setState(() => _phoneError = null),
              ),
              SizedBox(height: ZaytonaSpacing.space4),
              LabeledTextField(
                label: l10n.emailLabel,
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                error: _emailError,
                textDirection: TextDirection.ltr,
                onChanged: (_) => setState(() => _emailError = null),
              ),
            ],
          ),
        );
      },
    );
  }
}
