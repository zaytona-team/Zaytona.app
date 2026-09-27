// text_field.dart — ZaytonaTextField
//
// Source spec: design_source/.../components/forms/Input.jsx
//
// Brand border changes by state:
//   default → 2px navy
//   focused → 2px indigo + 4px indigo-tint outer ring
//   error   → 2px red (ring removed)
//
// The focus ring is a spread-only BoxShadow (blurRadius:0, spreadRadius:4),
// exactly matching the CSS `box-shadow: 0 0 0 4px var(--indigo-tint)`.
//
// Uses a raw TextField inside a custom DecoratedBox — Flutter's built-in
// OutlineInputBorder cannot produce an outer glow ring, so we own the border.

import 'package:flutter/material.dart';
import '../tokens/zaytona_theme.dart';

class ZaytonaTextField extends StatefulWidget {
  const ZaytonaTextField({
    super.key,
    this.controller,
    this.placeholder,
    this.icon,
    this.error,
    this.keyboardType,
    this.obscureText = false,
    this.textDirection,
    this.onChanged,
    this.onSubmitted,
    this.focusNode,
    this.autofocus = false,
  });

  final TextEditingController? controller;
  final String? placeholder;

  /// Optional leading icon. Rendered in ink-300 color.
  final Widget? icon;

  /// Non-null = error state; string is the message shown below.
  final String? error;

  final TextInputType? keyboardType;
  final bool obscureText;

  /// Pass `TextDirection.rtl` for Arabic fields.
  final TextDirection? textDirection;

  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;

  /// External FocusNode. If null, the widget manages its own.
  final FocusNode? focusNode;

  final bool autofocus;

  @override
  State<ZaytonaTextField> createState() => _ZaytonaTextFieldState();
}

class _ZaytonaTextFieldState extends State<ZaytonaTextField> {
  late final FocusNode _focusNode;
  bool _ownsNode = false;

  @override
  void initState() {
    super.initState();
    if (widget.focusNode != null) {
      _focusNode = widget.focusNode!;
    } else {
      _focusNode = FocusNode();
      _ownsNode = true;
    }
    _focusNode.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    if (_ownsNode) _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final focused = _focusNode.hasFocus;
    final hasError = widget.error != null;

    final borderColor = hasError
        ? ZaytonaColors.red
        : (focused ? ZaytonaColors.indigo : ZaytonaColors.navy);

    final List<BoxShadow> shadows = (focused && !hasError)
        ? const [
            BoxShadow(
              color: ZaytonaColors.indigoTint,
              blurRadius: 0,
              spreadRadius: 4,
            ),
          ]
        : const [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          height: 54,
          decoration: BoxDecoration(
            color: ZaytonaColors.surfaceCard,
            borderRadius: ZaytonaRadius.brMd,
            border: Border.all(color: borderColor, width: 2),
            boxShadow: shadows,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                if (widget.icon != null) ...[
                  IconTheme(
                    data: const IconThemeData(
                      color: ZaytonaColors.ink300,
                      size: ZaytonaSpacing.iconMd,
                    ),
                    child: widget.icon!,
                  ),
                  const SizedBox(width: 10),
                ],
                Expanded(
                  child: TextField(
                    controller: widget.controller,
                    focusNode: _focusNode,
                    autofocus: widget.autofocus,
                    keyboardType: widget.keyboardType,
                    obscureText: widget.obscureText,
                    textDirection: widget.textDirection,
                    onChanged: widget.onChanged,
                    onSubmitted: widget.onSubmitted,
                    style: const TextStyle(
                      fontSize: ZaytonaType.fsBody,
                      fontWeight: ZaytonaType.fwMedium,
                      color: ZaytonaColors.textBody,
                      height: 1.0,
                    ),
                    decoration: InputDecoration(
                      hintText: widget.placeholder,
                      hintStyle: const TextStyle(
                        fontSize: ZaytonaType.fsBody,
                        fontWeight: ZaytonaType.fwRegular,
                        color: ZaytonaColors.textHint,
                      ),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsetsDirectional.only(start: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Icon(
                  Icons.warning_rounded,
                  size: 14,
                  color: ZaytonaColors.redPress,
                ),
                const SizedBox(width: 5),
                Text(
                  widget.error!,
                  style: const TextStyle(
                    fontFamily: ZaytonaType.fontBody,
                    fontSize: 12.5,
                    fontWeight: ZaytonaType.fwMedium,
                    color: ZaytonaColors.redPress,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
