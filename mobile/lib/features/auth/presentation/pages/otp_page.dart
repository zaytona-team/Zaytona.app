import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:zaytona_design_system/zaytona_design_system.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/realtime/socket_service.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../router.dart';
import '../../domain/entities/otp_channel.dart';
import '../../domain/validators/login_validator.dart';
import '../bloc/otp_cubit.dart';
import '../widgets/auth_page_template.dart';
import '../widgets/otp_channel_picker.dart';
import '../widgets/otp_header.dart';
import '../widgets/otp_resend_row.dart';

class OtpPage extends StatefulWidget {
  final OtpArgs args;

  const OtpPage({super.key, required this.args});

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  static const int _resendCooldownSeconds = 53;
  static const int _otpLength = 4;

  final _controllers = List.generate(_otpLength, (_) => TextEditingController());
  final _focusNodes = List.generate(_otpLength, (_) => FocusNode());

  int _secondsLeft = _resendCooldownSeconds;
  Timer? _timer;
  String _channel = 'whatsapp';

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _startCountdown() {
    _timer?.cancel();
    setState(() => _secondsLeft = _resendCooldownSeconds);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsLeft <= 1) {
        timer.cancel();
        setState(() => _secondsLeft = 0);
        return;
      }
      setState(() => _secondsLeft -= 1);
    });
  }

  String get _code => _controllers.map((c) => c.text).join();

  void _onDigitChanged(int index, String value) {
    if (value.isNotEmpty && index < _otpLength - 1) _focusNodes[index + 1].requestFocus();
    if (value.isEmpty && index > 0) _focusNodes[index - 1].requestFocus();
    if (_code.length == _otpLength) _verify(context);
  }

  void _verify(BuildContext context) {
    context.read<OtpCubit>().verify(phone: widget.args.phone, token: _code, email: widget.args.email);
  }

  void _onResendPressed(OtpState state) {
    if (_secondsLeft > 0 || state is OtpResending) return;
    final channel = OtpChannel.values.firstWhere(
      (c) => c.name == _channel,
      orElse: () => OtpChannel.whatsapp,
    );
    context.read<OtpCubit>().resend(widget.args.phone, channel: channel);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final hasEmail = widget.args.email != null && widget.args.email!.isNotEmpty;

    return BlocConsumer<OtpCubit, OtpState>(
      listener: (context, state) {
        if (state is OtpVerified) {
          // A fresh login/signup won't hit main.dart's cold-start connect
          // gate — this is the only place a first-ever session starts the
          // socket, so it has to happen here too.
          unawaited(sl<SocketService>().connect());
          context.go(
            widget.args.purpose == OtpPurpose.registration ? '/onboarding/avatar' : '/home',
            extra: state.firstName,
          );
        } else if (state is OtpResent) {
          _startCountdown();
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.otpResent)));
        } else if (state is OtpError) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      builder: (context, state) {
        return AuthPageTemplate(
          title: l10n.otpTitle,
          subtitle: l10n.otpSubtitleWhatsapp(LoginValidator.maskPhone(widget.args.phone)),
          titleTrailing: const OtpEditNumberLink(),
          buttonLabel: l10n.otpConfirmAction,
          isLoading: state is OtpVerifying,
          onButtonPressed: () => _verify(context),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Directionality(
                textDirection: TextDirection.ltr,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (var i = 0; i < _otpLength; i++) ...[
                      if (i > 0) SizedBox(width: ZaytonaSpacing.space3),
                      ZaytonaOtpField(
                        controller: _controllers[i],
                        focusNode: _focusNodes[i],
                        onChanged: (v) => _onDigitChanged(i, v),
                        error: state is OtpError,
                      ),
                    ],
                  ],
                ),
              ),
              SizedBox(height: ZaytonaSpacing.space7),
              OtpResendRow(
                secondsLeft: _secondsLeft,
                isResending: state is OtpResending,
                onResend: () => _onResendPressed(state),
              ),
              SizedBox(height: ZaytonaSpacing.space4),
              OtpChannelPicker(
                value: _channel,
                onChanged: (v) => setState(() => _channel = v),
                hasEmail: hasEmail,
              ),
            ],
          ),
        );
      },
    );
  }
}
