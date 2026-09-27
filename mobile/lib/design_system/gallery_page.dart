// gallery_page.dart — visual check for the DS widget catalog.
// Route: /gallery — registered in debug builds only (router.dart).

import 'package:flutter/material.dart';
import 'package:zaytona_design_system/zaytona_design_system.dart';
import 'gallery_section.dart';
import 'gallery_sections_extra.dart';

class GalleryPage extends StatefulWidget {
  const GalleryPage({super.key});

  @override
  State<GalleryPage> createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPage> {
  // form state
  bool _checked1 = false;
  bool _checked2 = true;
  int _qty = 2;
  String _seg = 'all';
  int _chip = 0;
  final _textCtrl = TextEditingController();
  final _errorCtrl = TextEditingController(text: 'bad value');

  @override
  void dispose() {
    _textCtrl.dispose();
    _errorCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ZaytonaColors.cream,
      appBar: AppBar(
        backgroundColor: ZaytonaColors.cream,
        elevation: 0,
        title: Text(
          'DS Gallery',
          style: TextStyle(
            fontFamily: ZaytonaType.fontDisplay,
            fontFamilyFallback: const [ZaytonaType.fontBody],
            fontWeight: ZaytonaType.fwBlack,
            fontSize: 20,
            color: ZaytonaColors.navy,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          // ── Colors ────────────────────────────────────────────────
          GallerySection('Colors', children: [
            Wrap(spacing: 10, runSpacing: 10, children: [
              _Swatch(ZaytonaColors.red, 'red'),
              _Swatch(ZaytonaColors.cream, 'cream', border: true),
              _Swatch(ZaytonaColors.surfaceCard, 'card'),
              _Swatch(ZaytonaColors.navy, 'navy'),
              _Swatch(ZaytonaColors.mint, 'mint'),
              _Swatch(ZaytonaColors.indigo, 'indigo'),
              _Swatch(ZaytonaColors.successInk, 'success'),
              _Swatch(ZaytonaColors.surfaceSunken, 'sunken', border: true),
            ]),
          ]),

          // ── Typography ────────────────────────────────────────────
          GallerySection('Typography', children: [
            _TypeSample('Display / Black / 24', ZaytonaType.fontDisplay, FontWeight.w900, 24),
            _TypeSample('Display / Bold / 18', ZaytonaType.fontDisplay, FontWeight.w700, 18),
            _TypeSample('Body / SemiBold / 16', ZaytonaType.fontBody, FontWeight.w600, 16),
            _TypeSample('Body / Regular / 14', ZaytonaType.fontBody, FontWeight.w400, 14),
          ]),

          // ── Buttons ───────────────────────────────────────────────
          GallerySection('Buttons — variants', children: [
            Wrap(spacing: 10, runSpacing: 10, children: [
              ZaytonaButton(label: 'Primary', variant: ZaytonaButtonVariant.primary, onTap: () {}),
              ZaytonaButton(label: 'Secondary', variant: ZaytonaButtonVariant.secondary, onTap: () {}),
              ZaytonaButton(label: 'Mint', variant: ZaytonaButtonVariant.mint, onTap: () {}),
              ZaytonaButton(label: 'Outline', variant: ZaytonaButtonVariant.outline, onTap: () {}),
              ZaytonaButton(label: 'Ghost', variant: ZaytonaButtonVariant.ghost, onTap: () {}),
              ZaytonaButton(label: 'Danger', variant: ZaytonaButtonVariant.danger, onTap: () {}),
            ]),
          ]),
          GallerySection('Buttons — sizes + disabled', children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              ZaytonaButton(label: 'Large', variant: ZaytonaButtonVariant.primary, size: ZaytonaButtonSize.lg, block: true, onTap: () {}),
              const SizedBox(height: 10),
              ZaytonaButton(label: 'Medium', variant: ZaytonaButtonVariant.primary, size: ZaytonaButtonSize.md, block: true, onTap: () {}),
              const SizedBox(height: 10),
              ZaytonaButton(label: 'Small', variant: ZaytonaButtonVariant.primary, size: ZaytonaButtonSize.sm, block: true, onTap: () {}),
              const SizedBox(height: 10),
              ZaytonaButton(label: 'Disabled', variant: ZaytonaButtonVariant.primary, size: ZaytonaButtonSize.md, block: true, disabled: true, onTap: () {}),
            ]),
          ]),

          // ── Icon buttons ──────────────────────────────────────────
          GallerySection('Icon buttons', children: [
            Wrap(spacing: 10, runSpacing: 10, children: [
              ZaytonaIconButton(icon: const Icon(Icons.add), variant: ZaytonaIconButtonVariant.soft, tone: ZaytonaIconButtonTone.red, onTap: () {}),
              ZaytonaIconButton(icon: const Icon(Icons.add), variant: ZaytonaIconButtonVariant.solid, tone: ZaytonaIconButtonTone.indigo, onTap: () {}),
              ZaytonaIconButton(icon: const Icon(Icons.add), variant: ZaytonaIconButtonVariant.outline, tone: ZaytonaIconButtonTone.mint, onTap: () {}),
              ZaytonaIconButton(icon: const Icon(Icons.add), variant: ZaytonaIconButtonVariant.ghost, tone: ZaytonaIconButtonTone.navy, onTap: () {}),
              ZaytonaIconButton(icon: const Icon(Icons.add), variant: ZaytonaIconButtonVariant.soft, tone: ZaytonaIconButtonTone.red, size: ZaytonaIconButtonSize.lg, shape: ZaytonaIconButtonShape.square, onTap: () {}),
            ]),
          ]),

          // ── Badges ────────────────────────────────────────────────
          GallerySection('Badges', children: [
            Wrap(spacing: 8, runSpacing: 8, children: [
              ZaytonaBadge(label: 'Neutral', tone: ZaytonaBadgeTone.neutral),
              ZaytonaBadge(label: 'Red', tone: ZaytonaBadgeTone.red),
              ZaytonaBadge(label: 'Mint', tone: ZaytonaBadgeTone.mint),
              ZaytonaBadge(label: 'Indigo', tone: ZaytonaBadgeTone.indigo),
              ZaytonaBadge(label: 'Lilac', tone: ZaytonaBadgeTone.lilac),
              ZaytonaBadge(label: '• Dot', tone: ZaytonaBadgeTone.red, dot: true),
              ZaytonaBadge(label: 'Outline', tone: ZaytonaBadgeTone.indigo, variant: ZaytonaBadgeVariant.outline),
            ]),
          ]),

          // ── Avatars ───────────────────────────────────────────────
          GallerySection('Avatars', children: [
            Row(children: [
              ZaytonaAvatar(name: 'أحمد'),
              const SizedBox(width: 8),
              ZaytonaAvatar(name: 'فاطمة'),
              const SizedBox(width: 8),
              ZaytonaAvatar(name: 'خالد', size: 48),
              const SizedBox(width: 16),
              ZaytonaAvatarGroup(names: const ['أحمد', 'فاطمة', 'خالد', 'سارة', 'محمد']),
            ]),
          ]),

          // ── Cards ─────────────────────────────────────────────────
          GallerySection('Cards', children: [
            Column(children: [
              ZaytonaCard(
                variant: ZaytonaCardVariant.pop,
                child: const _CardContent('Pop card — navy border + shadow'),
              ),
              const SizedBox(height: 12),
              ZaytonaCard(
                variant: ZaytonaCardVariant.plain,
                child: const _CardContent('Plain card — soft border'),
              ),
              const SizedBox(height: 12),
              ZaytonaCard(
                variant: ZaytonaCardVariant.sunken,
                child: const _CardContent('Sunken card'),
              ),
              const SizedBox(height: 12),
              ZaytonaCard(
                variant: ZaytonaCardVariant.brand,
                child: const _CardContent('Brand card — red fill', light: true),
              ),
            ]),
          ]),

          // ── Text fields ───────────────────────────────────────────
          GallerySection('Text fields', children: [
            Column(children: [
              ZaytonaTextField(
                controller: _textCtrl,
                placeholder: 'رقم الجوال أو البريد',
              ),
              const SizedBox(height: 12),
              ZaytonaTextField(
                controller: _errorCtrl,
                placeholder: 'With error',
                error: 'هذا الحقل مطلوب',
              ),
            ]),
          ]),

          // ── Checkboxes ────────────────────────────────────────────
          GallerySection('Checkboxes', children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              ZaytonaCheckbox(
                checked: _checked1,
                label: 'غير محدد',
                onChanged: (v) => setState(() => _checked1 = v),
              ),
              const SizedBox(height: 10),
              ZaytonaCheckbox(
                checked: _checked2,
                label: 'محدد مع خط',
                onChanged: (v) => setState(() => _checked2 = v),
              ),
            ]),
          ]),

          // ── Qty steppers ──────────────────────────────────────────
          GallerySection('Qty steppers', children: [
            Row(children: [
              ZaytonaQtyStepper(
                value: _qty,
                onChanged: (v) => setState(() => _qty = v),
              ),
              const SizedBox(width: 20),
              ZaytonaQtyStepper(
                value: _qty,
                unit: 'كغ',
                size: ZaytonaQtyStepperSize.sm,
                onChanged: (v) => setState(() => _qty = v),
              ),
            ]),
          ]),

          // ── Segmented control ─────────────────────────────────────
          GallerySection('Segmented control', children: [
            ZaytonaSegmentedControl(
              value: _seg,
              onChanged: (v) => setState(() => _seg = v),
              options: const [
                ZaytonaSegmentOption(value: 'all', label: 'الكل', badge: 12),
                ZaytonaSegmentOption(value: 'mine', label: 'طلباتي', badge: 4),
                ZaytonaSegmentOption(value: 'done', label: 'مكتمل'),
              ],
            ),
          ]),

          // ── Stars ─────────────────────────────────────────────────
          GallerySection('Star — 14-point', children: [
            Wrap(spacing: 14, runSpacing: 14, crossAxisAlignment: WrapCrossAlignment.center, children: [
              const ZaytonaStar(size: 72, tone: ZaytonaStarTone.red, child: Icon(Icons.shopping_basket, size: 26)),
              const ZaytonaStar(size: 72, tone: ZaytonaStarTone.mint, child: Icon(Icons.check, size: 26)),
              const ZaytonaStar(size: 72, tone: ZaytonaStarTone.indigo, rotate: 12, child: Icon(Icons.star, size: 26)),
              const ZaytonaStar(size: 56, tone: ZaytonaStarTone.lilac),
              const ZaytonaStar(size: 56, tone: ZaytonaStarTone.navy, halo: null),
            ]),
          ]),

          // ── Banners ───────────────────────────────────────────────
          GallerySection('Banners', children: [
            Column(children: [
              const ZaytonaBanner(
                title: 'قد يكون مكرراً',
                body: 'أضاف خالد "حليب" قبل قليل',
                icon: Icon(Icons.warning_amber_rounded),
              ),
              const SizedBox(height: 10),
              const ZaytonaBanner(
                title: 'تم الإرسال ✓',
                tone: ZaytonaBannerTone.mint,
                icon: Icon(Icons.check_circle_outline),
              ),
              const SizedBox(height: 10),
              ZaytonaBanner(
                title: 'تم حذف 6 عناصر',
                tone: ZaytonaBannerTone.indigo,
                icon: const Icon(Icons.delete_outline),
                action: ZaytonaButton(
                  label: 'تراجع',
                  variant: ZaytonaButtonVariant.ghost,
                  size: ZaytonaButtonSize.sm,
                  onTap: () {},
                ),
              ),
            ]),
          ]),

          // ── Category chips ────────────────────────────────────────
          GallerySection('Category chips', children: [
            Wrap(spacing: 8, runSpacing: 8, children: [
              for (final (i, label) in const ['الكل', 'خضار وفواكه', 'ألبان', 'مخبوزات'].indexed)
                ZaytonaCategoryChip(
                  label: label,
                  selected: _chip == i,
                  onTap: () => setState(() => _chip = i),
                ),
            ]),
          ]),

          // ── Text swap ─────────────────────────────────────────────
          GallerySection('Text swap', children: [
            ZaytonaTextSwap(
              prompt: 'ليس لديك حساب؟',
              action: 'إنشاء حساب',
              onTap: () {},
            ),
          ]),

          ...buildExtraGallerySections(context),

          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

// ── Helper widgets ─────────────────────────────────────────────────────────────
// GallerySection lives in gallery_section.dart (shared with gallery_sections_extra.dart).

class _Swatch extends StatelessWidget {
  const _Swatch(this.color, this.name, {this.border = false});
  final Color color;
  final String name;
  final bool border;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color,
            borderRadius: ZaytonaRadius.brSm,
            border: border ? Border.all(color: ZaytonaColors.ink100) : null,
            boxShadow: ZaytonaShadows.shadowSm,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          name,
          style: TextStyle(
            fontFamily: ZaytonaType.fontBody,
            fontSize: 10,
            color: ZaytonaColors.textMuted,
          ),
        ),
      ],
    );
  }
}

class _TypeSample extends StatelessWidget {
  const _TypeSample(this.label, this.family, this.weight, this.size);
  final String label;
  final String family;
  final FontWeight weight;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        'زيتونه — Zaytona ($label)',
        style: TextStyle(
          fontFamily: family,
          fontFamilyFallback: const [ZaytonaType.fontBody],
          fontWeight: weight,
          fontSize: size,
          color: ZaytonaColors.navy,
        ),
      ),
    );
  }
}

class _CardContent extends StatelessWidget {
  const _CardContent(this.text, {this.light = false});
  final String text;
  final bool light;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontFamily: ZaytonaType.fontBody,
        fontSize: ZaytonaType.fsBodySm,
        fontWeight: ZaytonaType.fwMedium,
        color: light ? ZaytonaColors.cream : ZaytonaColors.navy,
      ),
    );
  }
}
