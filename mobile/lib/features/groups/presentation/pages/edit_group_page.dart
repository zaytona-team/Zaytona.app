import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:zaytona_design_system/zaytona_design_system.dart';
import 'package:zaytona/core/network/network_client.dart';
import 'package:zaytona/features/groups/data/datasources/remote/group_remote_datasource.dart';
import 'package:zaytona/features/groups/domain/entities/group_icon.dart';
import 'package:zaytona/l10n/app_localizations.dart';

class EditGroupPage extends StatefulWidget {
  final String groupId;
  final String currentName;
  final String? currentIcon;

  const EditGroupPage({
    super.key,
    required this.groupId,
    required this.currentName,
    this.currentIcon,
  });

  @override
  State<EditGroupPage> createState() => _EditGroupPageState();
}

class _EditGroupPageState extends State<EditGroupPage> {
  final _formKey = GlobalKey<FormState>();
  final _groupDataSource = GroupRemoteDataSource(NetworkClient.instance);

  late final TextEditingController _nameController;
  late GroupIcon _selectedIcon;

  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(
      text: widget.currentName,
    );

    _selectedIcon = _findCurrentIcon(widget.currentIcon);
  }

  GroupIcon _findCurrentIcon(String? value) {
    for (final icon in GroupIcon.values) {
      if (icon.apiValue == value) {
        return icon;
      }
    }

    return GroupIcon.home;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: EdgeInsets.only(
        left: ZaytonaSpacing.space5,
        right: ZaytonaSpacing.space5,
        top: ZaytonaSpacing.space3,
        bottom: MediaQuery.of(context).viewInsets.bottom + ZaytonaSpacing.space7,
      ),
      decoration: const BoxDecoration(
        color: ZaytonaColors.surfaceCard,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _dragHandle(),
            const SizedBox(height: ZaytonaSpacing.space4),
            _header(context, l10n),
            const SizedBox(height: ZaytonaSpacing.space5),
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: Text(
                l10n.groupNameLabel,
                style: const TextStyle(
                  color: ZaytonaColors.textMuted,
                  fontSize: 13,
                ),
              ),
            ),
            const SizedBox(height: ZaytonaSpacing.space2),
            _nameField(l10n),
            const SizedBox(height: ZaytonaSpacing.space5),
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: Text(
                l10n.groupIconLabel,
                style: const TextStyle(
                  color: ZaytonaColors.textMuted,
                  fontSize: 13,
                ),
              ),
            ),
            const SizedBox(height: ZaytonaSpacing.space3),
            _iconGrid(),
            if (_error != null) ...[
              const SizedBox(height: ZaytonaSpacing.space3),
              Text(
                _error!,
                style: const TextStyle(
                  color: ZaytonaColors.red,
                ),
              ),
            ],
            const SizedBox(height: ZaytonaSpacing.space7),
            _saveButton(context, l10n),
          ],
        ),
      ),
    );
  }

  Widget _dragHandle() {
    return Center(
      child: Container(
        width: 36,
        height: 4,
        decoration: BoxDecoration(
          color: ZaytonaColors.borderSoft,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _header(BuildContext context, AppLocalizations l10n) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          l10n.editGroupTitle,
          style: const TextStyle(
            color: ZaytonaColors.textStrong,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Container(
            width: 34,
            height: 34,
            decoration: const BoxDecoration(
              color: ZaytonaColors.surfaceSunken,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.close,
              size: 18,
              color: ZaytonaColors.textMuted,
            ),
          ),
        ),
      ],
    );
  }

  Widget _nameField(AppLocalizations l10n) {
    return TextFormField(
      controller: _nameController,
      textAlign: TextAlign.right,
      textDirection: TextDirection.rtl,
      decoration: InputDecoration(
        hintText: l10n.groupNameLabel,
        hintStyle: const TextStyle(
          color: ZaytonaColors.textHint,
          fontSize: 14,
        ),
        hintTextDirection: TextDirection.rtl,
        filled: true,
        fillColor: ZaytonaColors.surfaceCard,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: ZaytonaSpacing.space4,
          vertical: ZaytonaSpacing.space3,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: ZaytonaColors.borderSoft,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: ZaytonaColors.indigo,
            width: 1.8,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: ZaytonaColors.red,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: ZaytonaColors.red,
            width: 1.8,
          ),
        ),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return l10n.groupNameRequired;
        }

        return null;
      },
    );
  }

  Widget _iconGrid() {
    return Wrap(
      spacing: ZaytonaSpacing.space2,
      runSpacing: ZaytonaSpacing.space2,
      children: GroupIcon.values.map(_iconTile).toList(),
    );
  }

  Widget _iconTile(GroupIcon type) {
    final isSelected = _selectedIcon == type;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIcon = type;
        });
      },
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: ZaytonaColors.surfaceSunken,
          borderRadius: BorderRadius.circular(14),
          border: isSelected
              ? Border.all(
                  color: ZaytonaColors.textStrong,
                  width: 2,
                )
              : null,
        ),
        child: Icon(
          type.iconData,
          color: ZaytonaColors.textStrong,
          size: 22,
        ),
      ),
    );
  }

  Widget _saveButton(BuildContext context, AppLocalizations l10n) {
    return ElevatedButton(
      onPressed: _isLoading
          ? null
          : () => _onSavePressed(context, l10n),
      style: ElevatedButton.styleFrom(
        backgroundColor: ZaytonaColors.red,
        foregroundColor: ZaytonaColors.textOnColor,
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),
        elevation: 0,
      ),
      child: _isLoading
          ? SizedBox(
              height: 22,
              width: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: ZaytonaColors.textOnColor,
              ),
            )
          : Text(
              l10n.saveChangesAction,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
    );
  }

  Future<void> _onSavePressed(BuildContext context, AppLocalizations l10n) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await _groupDataSource.updateGroup(
        groupId: widget.groupId,
        name: _nameController.text.trim(),
        icon: _selectedIcon.apiValue,
      );

      if (!context.mounted) {
        return;
      }

      Navigator.of(context).pop({
  'name': _nameController.text.trim(),
  'icon': _selectedIcon.apiValue,
});
   } on DioException catch (e) {
  final data = e.response?.data;

  setState(() {
    _error = data is Map && data['message'] is String
        ? data['message'] as String
        : l10n.groupUpdateError;
  });
  
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}