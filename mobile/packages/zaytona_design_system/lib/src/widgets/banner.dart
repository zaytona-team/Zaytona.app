// banner.dart — ZaytonaBanner
//
// Source spec: prototype Banner (tinted rounded box, tone border, leading
// icon, title + optional body/action). Used for inline warnings such as the
// non-blocking "possible duplicate" hint and form-level errors.

import 'package:flutter/material.dart';
import '../tokens/zaytona_theme.dart';

enum ZaytonaBannerTone { red, indigo, mint }

class ZaytonaBanner extends StatelessWidget {
  const ZaytonaBanner({
    super.key,
    required this.title,
    this.body,
    this.icon,
    this.tone = ZaytonaBannerTone.red,
    this.action,
  });

  final String title;
  final String? body;
  final Widget? icon;
  final ZaytonaBannerTone tone;

  /// Optional trailing action (e.g. an Undo button).
  final Widget? action;

  Color get _border => switch (tone) {
        ZaytonaBannerTone.red => ZaytonaColors.red,
        ZaytonaBannerTone.indigo => ZaytonaColors.indigo,
        ZaytonaBannerTone.mint => ZaytonaColors.mint,
      };

  Color get _fill => switch (tone) {
        ZaytonaBannerTone.red => ZaytonaColors.redTint,
        ZaytonaBannerTone.indigo => ZaytonaColors.indigoTint,
        ZaytonaBannerTone.mint => ZaytonaColors.mintTint,
      };

  Color get _ink => switch (tone) {
        ZaytonaBannerTone.red => ZaytonaColors.redPress,
        ZaytonaBannerTone.indigo => ZaytonaColors.indigoPress,
        ZaytonaBannerTone.mint => ZaytonaColors.successInk,
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: _fill,
        border: Border.all(color: _border, width: 1.5),
        borderRadius: BorderRadius.circular(ZaytonaRadius.md),
      ),
      child: Row(
        children: [
          if (icon != null) ...[
            IconTheme(
              data: IconThemeData(size: 18, color: _ink),
              child: icon!,
            ),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: ZaytonaType.fontBody,
                    fontWeight: ZaytonaType.fwBold,
                    fontSize: ZaytonaType.fsBodySm,
                    color: _ink,
                  ),
                ),
                if (body != null) Text(body!, style: ZaytonaType.caption),
              ],
            ),
          ),
          if (action != null) ...[const SizedBox(width: 8), action!],
        ],
      ),
    );
  }
}
