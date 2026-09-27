// gallery_sections_extra.dart — gallery sections for widgets added/audited in
// the DS reconciliation pass (fab, group_card, list_summary_card (new API),
// empty_state, switch, trip_card, buying_header, alert_tile, drawer, sheet,
// dialog, toast, error_state). Split out of gallery_page.dart to respect the
// 180-line file cap.

import 'package:flutter/material.dart';
import 'package:zaytona_design_system/zaytona_design_system.dart';
import 'gallery_section.dart';

List<Widget> buildExtraGallerySections(BuildContext context) {
  return [
    GallerySection('Group card', children: [
      ZaytonaGroupCard(
        name: 'عائلة الجوهرة',
        badge: const ZaytonaBadge(label: 'مسؤول', tone: ZaytonaBadgeTone.mint),
        members: const ZaytonaAvatarGroup(names: ['أحمد', 'فاطمة', 'خالد']),
        tone: ZaytonaGroupCardTone.lilac,
      ),
    ]),

    GallerySection('List summary card', children: [
      ZaytonaListSummaryCard(
        name: 'قائمة السوبرماركت',
        total: 12,
        urgent: 3,
        updated: 'قبل ساعتين',
        accent: ZaytonaListAccent.indigo,
      ),
    ]),

    GallerySection('Empty state', children: [
      SizedBox(
        height: 260,
        child: ZaytonaEmptyState(
          icon: const Icon(Icons.shopping_basket_outlined, size: 40),
          title: 'لا توجد قوائم بعد',
          body: 'أنشئ أول قائمة تسوق لعائلتك',
          ctaLabel: 'إنشاء قائمة',
          onCta: () {},
        ),
      ),
    ]),

    GallerySection('Switch', children: [
      const _SwitchDemo(),
    ]),

    GallerySection('Trip card', children: [
      ZaytonaTripCard(
        buyer: const ZaytonaAvatar(name: 'خالد', size: 44),
        buyerName: 'خالد',
        date: '24 يونيو',
        count: 5,
        countLabel: 'عناصر',
        items: const ['حليب', 'خبز', 'تفاح', 'جبن', 'بيض'],
      ),
    ]),

    GallerySection('Alert tile', children: [
      ZaytonaAlertTile(
        title: 'تعيين مشترٍ',
        body: 'اختر من سيقوم بالشراء هذه المرة',
        tone: ZaytonaAlertTone.indigo,
        action: ZaytonaButton(
          label: 'اختيار',
          size: ZaytonaButtonSize.sm,
          onTap: () {},
        ),
      ),
    ]),

    GallerySection('Buying header', children: [
      ClipRRect(
        borderRadius: ZaytonaRadius.brMd,
        child: ZaytonaBuyingHeader(
          name: 'قائمة السوبرماركت',
          done: 3,
          total: 12,
          chips: [
            ZaytonaBuyingFilterChip(label: 'الكل', selected: true, onTap: () {}),
            ZaytonaBuyingFilterChip(
              label: 'عاجل',
              selected: false,
              tone: ZaytonaBuyingFilterTone.red,
              onTap: () {},
            ),
          ],
        ),
      ),
    ]),

    GallerySection('Overlays', children: [
      Wrap(spacing: 10, runSpacing: 10, children: [
        ZaytonaButton(
          label: 'Sheet',
          variant: ZaytonaButtonVariant.outline,
          onTap: () => ZaytonaSheet.show(
            context,
            child: const Padding(
              padding: EdgeInsets.all(20),
              child: Text('محتوى الورقة السفلية'),
            ),
          ),
        ),
        ZaytonaButton(
          label: 'Dialog',
          variant: ZaytonaButtonVariant.outline,
          onTap: () => ZaytonaDialog.show(
            context,
            title: 'حذف القائمة؟',
            body: 'لا يمكن التراجع عن هذا الإجراء.',
            cancelLabel: 'إلغاء',
            confirmLabel: 'حذف',
            danger: true,
            onConfirm: () {},
          ),
        ),
        ZaytonaButton(
          label: 'Toast',
          variant: ZaytonaButtonVariant.outline,
          onTap: () => ZaytonaToast.show(context, message: 'تم الحفظ'),
        ),
      ]),
    ]),

    GallerySection('Drawer', children: [
      SizedBox(
        height: 360,
        child: ZaytonaDrawer(
          header: const Padding(
            padding: EdgeInsets.all(16),
            child: Text('زيتونة', style: TextStyle(fontFamily: ZaytonaType.fontDisplay, fontWeight: ZaytonaType.fwBlack, fontSize: 20, color: ZaytonaColors.navy)),
          ),
          children: [
            ZaytonaDrawerLink(icon: const Icon(Icons.group_outlined), label: 'المجموعات', onTap: () {}),
            ZaytonaDrawerLink(icon: const Icon(Icons.settings_outlined), label: 'الإعدادات', tone: ZaytonaDrawerLinkTone.indigo, onTap: () {}),
          ],
        ),
      ),
    ]),

    GallerySection('Error state', children: [
      SizedBox(
        height: 320,
        child: ZaytonaErrorState(
          icon: const Icon(Icons.wifi_off, size: 40),
          title: 'لا يوجد اتصال',
          body: 'تحقق من اتصالك بالإنترنت وحاول مرة أخرى',
          detail: 'ERR_OFFLINE_204',
          actionLabel: 'إعادة المحاولة',
          onAction: () {},
        ),
      ),
    ]),
  ];
}

class _SwitchDemo extends StatefulWidget {
  const _SwitchDemo();

  @override
  State<_SwitchDemo> createState() => _SwitchDemoState();
}

class _SwitchDemoState extends State<_SwitchDemo> {
  bool _value = true;

  @override
  Widget build(BuildContext context) {
    return ZaytonaSwitch(
      value: _value,
      onChanged: (v) => setState(() => _value = v),
    );
  }
}
