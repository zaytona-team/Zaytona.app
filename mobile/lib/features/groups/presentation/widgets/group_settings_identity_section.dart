import 'package:flutter/material.dart';
import 'package:zaytona_design_system/zaytona_design_system.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/group.dart';
import '../../domain/entities/group_icon.dart';
import 'group_tone.dart';

class GroupIdentitySection extends StatefulWidget {
  final Group group;
  final bool isAdmin;
  final bool actionInFlight;
  final ValueChanged<String> onSave;
  final ValueChanged<String> onIconSelected;

  const GroupIdentitySection({
    super.key,
    required this.group,
    required this.isAdmin,
    required this.actionInFlight,
    required this.onSave,
    required this.onIconSelected,
  });

  @override
  State<GroupIdentitySection> createState() => _GroupIdentitySectionState();
}

class _GroupIdentitySectionState extends State<GroupIdentitySection> {
  final _nameController = TextEditingController();
  bool _showIconPicker = false;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.group.name;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final group = widget.group;
    final isAdmin = widget.isAdmin;
    final nameChanged = _nameController.text.trim() != group.name &&
        _nameController.text.trim().isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            GestureDetector(
              onTap: isAdmin
                  ? () => setState(() => _showIconPicker = !_showIconPicker)
                  : null,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  ZaytonaStar(
                    size: 56,
                    tone: group.tone,
                    rotate: -6,
                    child: Icon(
                      GroupIconX.fromApiValue(group.icon).iconData,
                      size: 26,
                    ),
                  ),
                  if (isAdmin)
                    PositionedDirectional(
                      end: -2,
                      bottom: -2,
                      child: Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          color: ZaytonaColors.navy,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: ZaytonaColors.bgApp,
                            width: 2,
                          ),
                        ),
                        child: const Icon(Icons.edit,
                            size: 11, color: ZaytonaColors.cream),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: ZaytonaSpacing.space4),
            Expanded(
              child: isAdmin
                  ? ZaytonaTextField(
                      controller: _nameController,
                      onChanged: (_) => setState(() {}),
                    )
                  : Text(group.name, style: ZaytonaType.cardTitle),
            ),
          ],
        ),
        if (isAdmin && _showIconPicker) ...[
          const SizedBox(height: ZaytonaSpacing.space3),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final icon in GroupIcon.values)
                GestureDetector(
                  onTap: widget.actionInFlight
                      ? null
                      : () {
                          setState(() => _showIconPicker = false);
                          widget.onIconSelected(icon.apiValue);
                        },
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: ZaytonaColors.surfaceSunken,
                      borderRadius: BorderRadius.circular(ZaytonaRadius.md),
                      border: icon.apiValue == group.icon
                          ? Border.all(
                              color: ZaytonaColors.borderBold,
                              width: ZaytonaShadows.strokeBold,
                            )
                          : null,
                    ),
                    child: Icon(icon.iconData,
                        color: ZaytonaColors.textStrong, size: 21),
                  ),
                ),
            ],
          ),
        ],
        if (isAdmin && nameChanged) ...[
          const SizedBox(height: ZaytonaSpacing.space3),
          ZaytonaButton(
            label: l10n.saveAction,
            variant: ZaytonaButtonVariant.secondary,
            size: ZaytonaButtonSize.sm,
            disabled: widget.actionInFlight,
            onTap: () => widget.onSave(_nameController.text.trim()),
          ),
        ],
      ],
    );
  }
}
