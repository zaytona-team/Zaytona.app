import 'package:flutter/material.dart';

import '../tokens/zaytona_theme.dart';

/// Shared popover shell for anchored action menus (list menu, group-member
/// actions menu, ...) — surfaceCard fill, navy border, pop shadow, pill of
/// rows. Callers supply the rows (typically [ListMenuRow]s).
class ZaytonaMenuCard extends StatelessWidget {
  const ZaytonaMenuCard({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: ZaytonaColors.surfaceCard,
          border: Border.all(
            color: ZaytonaColors.navy,
            width: ZaytonaShadows.strokeBold,
          ),
          borderRadius: ZaytonaRadius.brLg,
          boxShadow: ZaytonaShadows.shadowPop,
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(mainAxisSize: MainAxisSize.min, children: children),
      ),
    );
  }
}

/// Passes a menu's [close] callback down to its rows via an
/// [InheritedWidget], so row callbacks can dismiss the popover before
/// running their own action.
class ZaytonaMenuCloseScope extends InheritedWidget {
  const ZaytonaMenuCloseScope({
    super.key,
    required this.close,
    required super.child,
  });

  final VoidCallback close;

  static VoidCallback of(BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<ZaytonaMenuCloseScope>()!
      .close;

  @override
  bool updateShouldNotify(ZaytonaMenuCloseScope oldWidget) =>
      close != oldWidget.close;
}

/// Anchors [card] under [anchorKey]'s render box in an [OverlayEntry] —
/// RTL-aware, dismissed by tapping outside. [card] is built under a
/// [ZaytonaMenuCloseScope] so its rows can call
/// `ZaytonaMenuCloseScope.of(context)()`.
void showZaytonaAnchoredMenu(
  BuildContext context, {
  required GlobalKey anchorKey,
  required double width,
  required WidgetBuilder cardBuilder,
}) {
  final box = anchorKey.currentContext!.findRenderObject() as RenderBox;
  final overlay = Overlay.of(context);
  final position = box.localToGlobal(
    Offset.zero,
    ancestor: overlay.context.findRenderObject(),
  );
  late final OverlayEntry entry;

  void close() => entry.remove();

  entry = OverlayEntry(
    builder: (overlayContext) => Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: close,
          ),
        ),
        Positioned(
          top: position.dy + box.size.height + 6,
          left: Directionality.of(overlayContext) == TextDirection.rtl
              ? position.dx
              : null,
          right: Directionality.of(overlayContext) == TextDirection.rtl
              ? null
              : MediaQuery.of(overlayContext).size.width -
                    position.dx -
                    box.size.width,
          width: width,
          child: ZaytonaMenuCloseScope(
            close: close,
            child: Builder(builder: cardBuilder),
          ),
        ),
      ],
    ),
  );
  overlay.insert(entry);
}
