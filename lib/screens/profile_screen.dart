import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../models/profile.dart';
import '../providers/profile_provider.dart';
import '../theme/app_theme.dart';

const double _maxContentWidth = 600;

/// Màn hình quản lý hồ sơ người dùng: chuyển, thêm và xóa hồ sơ.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return Consumer<ProfileProvider>(
      builder: (context, profileProvider, _) {
        final profiles = profileProvider.profiles;
        final activeId = profileProvider.activeProfile?.id;
        final canDelete = profiles.length > 1;

        return Scaffold(
          appBar: AppBar(title: Text(t.profilesTitle)),
          body: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: _maxContentWidth),
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(
                  AppTheme.spacingM,
                  AppTheme.spacingM,
                  AppTheme.spacingM,
                  AppTheme.spacingL * 4,
                ),
                itemCount: profiles.length,
                itemBuilder: (context, index) {
                  final profile = profiles[index];
                  final isActive = profile.id == activeId;

                  return Padding(
                    padding: const EdgeInsets.only(
                      bottom: AppTheme.spacingS + 4,
                    ),
                    child: _ProfileCard(
                      profile: profile,
                      isActive: isActive,
                      canDelete: canDelete,
                      onTap: isActive
                          ? null
                          : () => context.read<ProfileProvider>().switchProfile(
                              profile.id,
                            ),
                      onDelete: () => _onDeleteProfile(context, profile),
                    ),
                  );
                },
              ),
            ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _onAddProfile(context),
            icon: const Icon(Icons.add),
            label: Text(t.addProfile),
          ),
        );
      },
    );
  }

  Future<void> _onAddProfile(BuildContext context) async {
    final name = await showDialog<String>(
      context: context,
      builder: (dialogContext) => const _ProfileNameDialog(),
    );
    if (name == null || !context.mounted) return;

    await context.read<ProfileProvider>().addProfile(name);
  }

  Future<void> _onDeleteProfile(BuildContext context, Profile profile) async {
    final t = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(t.deleteProfileTitle),
          content: Text(t.deleteProfileMessage(profile.name)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(t.cancel),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: TextButton.styleFrom(foregroundColor: AppTheme.danger),
              child: Text(t.delete),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !context.mounted) return;

    await context.read<ProfileProvider>().deleteProfile(profile.id);
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({
    required this.profile,
    required this.isActive,
    required this.canDelete,
    required this.onTap,
    required this.onDelete,
  });

  final Profile profile;
  final bool isActive;
  final bool canDelete;
  final VoidCallback? onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final color = AppTheme.deckColorAt(profile.colorIndex);

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radiusM),
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingM),
          child: Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: color.withValues(alpha: 0.12),
                child: Text(
                  profile.name.isEmpty ? '?' : profile.name[0].toUpperCase(),
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: AppTheme.spacingM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profile.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (isActive) ...[
                      const SizedBox(height: AppTheme.spacingS),
                      _ActiveChip(label: t.activeProfileLabel, color: color),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: AppTheme.spacingS),
              Tooltip(
                message: canDelete ? t.delete : t.cannotDeleteLastProfile,
                child: IconButton(
                  icon: const Icon(Icons.delete_outline),
                  color: AppTheme.danger,
                  onPressed: canDelete ? onDelete : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActiveChip extends StatelessWidget {
  const _ActiveChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _ProfileNameDialog extends StatefulWidget {
  const _ProfileNameDialog();

  @override
  State<_ProfileNameDialog> createState() => _ProfileNameDialogState();
}

class _ProfileNameDialogState extends State<_ProfileNameDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pop(_controller.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return AlertDialog(
      title: Text(t.addProfile),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _controller,
          autofocus: true,
          textInputAction: TextInputAction.done,
          decoration: InputDecoration(labelText: t.profileName),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return t.profileNameEmpty;
            }
            return null;
          },
          onFieldSubmitted: (_) => _submit(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(t.cancel),
        ),
        FilledButton(onPressed: _submit, child: Text(t.save)),
      ],
    );
  }
}
