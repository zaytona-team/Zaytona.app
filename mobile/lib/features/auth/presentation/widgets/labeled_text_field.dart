import 'package:flutter/material.dart';
import 'package:zaytona_design_system/zaytona_design_system.dart';

/// A [ZaytonaTextField] with its field label stacked above it, matching the
/// label + field rhythm used in InlineLoginForm.
class LabeledTextField extends StatelessWidget {
  const LabeledTextField({
    super.key,
    required this.label,
    required this.controller,
    this.error,
    this.placeholder,
    this.icon,
    this.keyboardType,
    this.onChanged,
    this.textDirection,
  });

  final String label;
  final TextEditingController controller;
  final String? error;
  final String? placeholder;
  final Widget? icon;
  final TextInputType? keyboardType;
  final void Function(String)? onChanged;
  final TextDirection? textDirection;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: Text(label, style: ZaytonaType.fieldLabel),
        ),
        SizedBox(height: ZaytonaSpacing.space2),
        ZaytonaTextField(
          controller: controller,
          placeholder: placeholder,
          icon: icon,
          error: error,
          keyboardType: keyboardType,
          onChanged: onChanged,
          textDirection: textDirection,
        ),
      ],
    );
  }
}
