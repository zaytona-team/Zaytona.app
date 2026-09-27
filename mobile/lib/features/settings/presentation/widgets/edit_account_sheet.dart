import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:zaytona_design_system/zaytona_design_system.dart';

import '../../../../l10n/app_localizations.dart';
import '../../data/profile_remote_data_source.dart';
import 'edit_account_avatar_picker.dart';

/// Edit-account bottom sheet: avatar picker, first/last name, phone
/// (read-only), optional email, and a save button.
class EditAccountSheet extends StatefulWidget {
  const EditAccountSheet({
    super.key,
    required this.firstName,
    required this.lastName,
    required this.phone,
  });

  final String firstName;
  final String lastName;
  final String phone;

  @override
  State<EditAccountSheet> createState() => _EditAccountSheetState();
}

class _EditAccountSheetState extends State<EditAccountSheet> {
  final _api = ProfileRemoteDataSource();

  late final TextEditingController _firstName;
  late final TextEditingController _lastName;

  List<Map<String, dynamic>> _avatars = [];
  Map<String, dynamic>? _selectedAvatar;

  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();

    _firstName = TextEditingController(text: widget.firstName)
      ..addListener(() => setState(() {}));
    _lastName = TextEditingController(text: widget.lastName)
      ..addListener(() => setState(() {}));

    _loadAvatars();
  }

  Future<void> _loadAvatars() async {
    try {
      _avatars = await _api.getAvatars();
    } catch (_) {
      if (mounted) {
        _showMessage(AppLocalizations.of(context)!.avatarsUnavailable);
      }
    }

    if (mounted) {
      setState(() => _loading = false);
    }
  }

  Future<void> _save() async {
    final firstName = _firstName.text.trim();
    final lastName = _lastName.text.trim();
    final l10n = AppLocalizations.of(context)!;

    setState(() => _saving = true);

    try {
      await _api.updateProfile(firstName: firstName, lastName: lastName);

      if (_selectedAvatar != null) {
        await _api.selectAvatar(_selectedAvatar!['id']);
      }

      if (!mounted) return;

      context.pop({
        'firstName': firstName,
        'lastName': lastName,
        'avatarUrl': _avatarUrl(_selectedAvatar),
      });
    } catch (_) {
      _showMessage(l10n.saveChangesError);
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  String? _avatarUrl(Map<String, dynamic>? avatar) {
    return avatar?['url']?.toString() ??
        avatar?['avatar_url']?.toString() ??
        avatar?['image_url']?.toString();
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    super.dispose();
  }

  bool get _canSave =>
      _firstName.text.trim().isNotEmpty && _lastName.text.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return ZaytonaSheet(
      onClose: () => Navigator.of(context).maybePop(),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          4,
          20,
          MediaQuery.viewInsetsOf(context).bottom + 24,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ZaytonaSheetHeader(
                title: l10n.editAccountTitle,
                onClose: () => Navigator.of(context).maybePop(),
              ),
              const SizedBox(height: 20),
              EditAccountAvatarPicker(
                loading: _loading,
                avatars: _avatars,
                selectedId: _selectedAvatar?['id'],
                label: l10n.chooseAvatarLabel,
                urlOf: _avatarUrl,
                onSelect: (avatar) => setState(() => _selectedAvatar = avatar),
              ),
              const SizedBox(height: 20),
              Row(children: [
                Expanded(child: ZaytonaTextField(controller: _firstName, placeholder: l10n.firstNameLabel)),
                const SizedBox(width: 12),
                Expanded(child: ZaytonaTextField(controller: _lastName, placeholder: l10n.lastNameLabel)),
              ]),
              const SizedBox(height: 16),
              ZaytonaTextField(
                controller: TextEditingController(text: widget.phone),
                textDirection: TextDirection.ltr,
                icon: const Icon(Icons.phone_outlined),
                placeholder: l10n.phoneLabel,
              ),
              const SizedBox(height: 16),
              ZaytonaTextField(
                textDirection: TextDirection.ltr,
                icon: const Icon(Icons.mail_outline),
                placeholder: l10n.emailLabel,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 24),
              ZaytonaButton(
                label: l10n.saveChangesAction,
                variant: ZaytonaButtonVariant.primary,
                size: ZaytonaButtonSize.lg,
                block: true,
                disabled: !_canSave || _saving,
                onTap: _saving || !_canSave ? null : _save,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
