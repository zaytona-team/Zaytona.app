// Regression test for the RenderFlex "BOTTOM OVERFLOWED" bug reported on
// the catalog/add-item grid.
//
// Root cause: a GridView's fixed `childAspectRatio` gives each cell a
// height that shrinks proportionally with cell width — but the card's
// content height is mostly fixed pixels (image block, button/stepper
// heights, font sizes), not proportional to width at all. So no aspect
// ratio value can hold across every device width: a narrower device gets
// a *shorter* budget for the exact same *fixed-height* content. The fix
// was switching both grids from `childAspectRatio` to a fixed
// `mainAxisExtent` (constant row height regardless of cell width) — see
// catalog_page.dart and about_team_grid.dart.
//
// This test pumps the cards at that same fixed height, across a range of
// widths (since width no longer determines height at all), and asserts no
// exception — Flutter reports a RenderFlex overflow as a FlutterError
// during layout, which `tester.takeException()` surfaces.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zaytona/features/settings/presentation/widgets/about_team_grid.dart';
import 'package:zaytona_design_system/zaytona_design_system.dart';

Widget _wrap(Widget child, {required double width, required double height}) {
  return MaterialApp(
    theme: ZaytonaTheme.light,
    home: Scaffold(
      body: SizedBox(
        width: width,
        height: height,
        child: child,
      ),
    ),
  );
}

Widget _catalogCard({required String name, String? subtitleText}) {
  return ZaytonaCatalogCard(
    name: name,
    subtitleText: subtitleText,
    seal: const Icon(Icons.shopping_bag, size: 32),
    quantity: ZaytonaQtyStepper(
      value: 1,
      min: 1,
      size: ZaytonaQtyStepperSize.sm,
      onChanged: (_) {},
    ),
    action: ZaytonaButton(
      label: 'إضافة +',
      variant: ZaytonaButtonVariant.mint,
      size: ZaytonaButtonSize.sm,
      block: true,
      // Matches real usage in catalog_grid_card.dart — the icon eats
      // into the same width budget the label needs, so a test without
      // it understates the risk.
      iconLeft: const Icon(Icons.add, size: 16),
      onTap: () {},
    ),
  );
}

void main() {
  group('ZaytonaCatalogCard (catalog_page.dart grid: mainAxisExtent 235)', () {
    for (final width in [147.0, 176.0, 220.0]) {
      testWidgets(
          'with a subtitle (longest content path) at width=$width does not overflow',
          (tester) async {
        await tester.pumpWidget(_wrap(
          _catalogCard(
            name: 'Smoke test item long enough to wrap',
            subtitleText: 'Some Brand Name',
          ),
          width: width,
          height: 235,
        ));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('without a subtitle does not overflow', (tester) async {
      await tester.pumpWidget(_wrap(
        _catalogCard(name: 'Water'),
        width: 176,
        height: 235,
      ));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  });

  group('AboutTeamGrid cell (about_team_grid.dart grid: mainAxisExtent 130)',
      () {
    testWidgets('with a two-line name does not overflow', (tester) async {
      const cellWidth = 106.0;
      await tester.pumpWidget(_wrap(
        const AboutTeamGrid(
          members: [
            AboutTeamMember(name: 'Mohammed Al-Qahtani Al-Otaibi'),
          ],
        ),
        // AboutTeamGrid lays out its own GridView (shrinkWrap), so give it
        // the full 3-column row width, not a single cell's width.
        width: cellWidth * 3 + 20,
        height: 130,
      ));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  });
}
