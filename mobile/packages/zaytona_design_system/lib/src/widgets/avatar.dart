// avatar.dart — ZaytonaAvatar + ZaytonaAvatarGroup
//
// Source spec: design_source/.../components/core/Avatar.jsx
//
// Renders a backend photo (src), an explicit mascot (character 1-5), or a
// neutral placeholder — no name-derived mascot fallback.

import 'package:flutter/material.dart';
import '../tokens/zaytona_theme.dart';

class ZaytonaAvatar extends StatelessWidget {
  const ZaytonaAvatar({
    super.key,
    this.name = '',
    this.src,
    this.character,
    this.size = 44,
    this.ringColor = ZaytonaColors.navy,
  })  : assert(
          character == null || (character >= 1 && character <= 5),
          'character must be 1–5',
        );

  final String name;

  /// Explicit image URL/asset path. Takes priority over [character] and [name].
  final String? src;

  /// Explicit mascot index (1–5). Takes priority over [name].
  final int? character;

  final double size;
  final Color ringColor;

  @override
  Widget build(BuildContext context) {
    final hasSrc = src != null && src!.isNotEmpty;
    final image = character != null
        ? Image.asset(
            'assets/avatars/av-$character.png',
            fit: BoxFit.cover,
            width: size,
            height: size,
          )
        : hasSrc
            ? Image.network(
                src!,
                fit: BoxFit.cover,
                width: size,
                height: size,
                errorBuilder: (context, error, stackTrace) =>
                    _placeholder(size),
              )
            : _placeholder(size);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: ringColor, width: 2),
      ),
      child: ClipOval(child: image),
    );
  }

  static Widget _placeholder(double size) {
    return Container(
      width: size,
      height: size,
      color: ZaytonaColors.surfaceSunken,
      alignment: Alignment.center,
      child: Icon(
        Icons.person_outline,
        size: size * 0.55,
        color: ZaytonaColors.navy,
      ),
    );
  }
}

class ZaytonaAvatarGroup extends StatelessWidget {
  const ZaytonaAvatarGroup({
    super.key,
    required this.names,
    this.avatarUrls,
    this.max = 4,
    this.size = 36,
  });

  /// Display names for each member. Used for mascot selection when no
  /// [avatarUrls] entry is available for that index.
  final List<String> names;

  /// Optional backend avatar URLs, same length/order as [names]. A null or
  /// empty entry at an index falls back to the mascot resolved from that
  /// member's name.
  final List<String?>? avatarUrls;

  /// Maximum avatars shown before the +N chip appears.
  final int max;

  final double size;

  @override
  Widget build(BuildContext context) {
    final shown = names.take(max).toList();
    final overflow = names.length - shown.length;
    // Each avatar overlaps the previous by 32 % of its size.
    final overlap = size * 0.32;
    final step = size - overlap;
    final totalItems = shown.length + (overflow > 0 ? 1 : 0);
    final totalWidth = size + step * (totalItems - 1);

    return SizedBox(
      width: totalWidth,
      height: size,
      child: Stack(
        children: [
          for (int i = 0; i < shown.length; i++)
            Positioned.directional(
              textDirection: Directionality.of(context),
              start: i * step,
              child: ZaytonaAvatar(
                name: shown[i],
                src: avatarUrls != null && i < avatarUrls!.length
                    ? avatarUrls![i]
                    : null,
                size: size,
              ),
            ),
          if (overflow > 0)
            Positioned.directional(
              textDirection: Directionality.of(context),
              start: shown.length * step,
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  color: ZaytonaColors.navy,
                  shape: BoxShape.circle,
                  border: Border.all(color: ZaytonaColors.navy, width: 2),
                ),
                alignment: Alignment.center,
                child: Text(
                  '+$overflow',
                  style: TextStyle(
                    fontFamily: ZaytonaType.fontBody,
                    fontWeight: ZaytonaType.fwBold,
                    fontSize: size * 0.3,
                    color: ZaytonaColors.cream,
                    height: 1.0,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
