// otp_field.dart — ZaytonaOtpField
//
// Single-digit OTP box sharing ZaytonaTextField's brand states: 2px navy
// border by default, 2px indigo + spread ring when focused, 2px red on
// error — same 54px height and surfaceCard fill as ZaytonaTextField so OTP
// entry reads as the same form language as every other field.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../tokens/zaytona_theme.dart';

class ZaytonaOtpField extends StatefulWidget {
  const ZaytonaOtpField({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    this.error = false,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;

  /// True renders the error border, matching ZaytonaTextField's error state.
  final bool error;

  @override
  State<ZaytonaOtpField> createState() => _ZaytonaOtpFieldState();
}

class _ZaytonaOtpFieldState extends State<ZaytonaOtpField> {
  @override
  void initState() {
    super.initState();
    widget.focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    widget.focusNode.removeListener(_onFocusChange);
    super.dispose();
  }

  void _onFocusChange() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final focused = widget.focusNode.hasFocus;

    final borderColor = widget.error
        ? ZaytonaColors.red
        : (focused ? ZaytonaColors.indigo : ZaytonaColors.navy);

    final List<BoxShadow> shadows = (focused && !widget.error)
        ? const [
            BoxShadow(
              color: ZaytonaColors.indigoTint,
              blurRadius: 0,
              spreadRadius: 4,
            ),
          ]
        : const [];

    return AnimatedContainer(
      duration: const Duration(milliseconds: 120),
      width: 54,
      height: 54,
      decoration: BoxDecoration(
        color: ZaytonaColors.surfaceCard,
        borderRadius: ZaytonaRadius.brMd,
        border: Border.all(color: borderColor, width: 2),
        boxShadow: shadows,
      ),
      child: TextField(
        controller: widget.controller,
        focusNode: widget.focusNode,
        onChanged: widget.onChanged,
        textAlign: TextAlign.center,
        textAlignVertical: TextAlignVertical.center,
        maxLength: 1,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        style: const TextStyle(
          fontSize: ZaytonaType.fsTitle,
          fontWeight: ZaytonaType.fwBold,
          color: ZaytonaColors.textBody,
        ),
        decoration: const InputDecoration(
          border: InputBorder.none,
          counterText: '',
          isDense: true,
          contentPadding: EdgeInsets.zero,
        ),
      ),
    );
  }
}
