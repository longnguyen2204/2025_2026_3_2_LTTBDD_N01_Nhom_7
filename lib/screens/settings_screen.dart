import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../providers/locale_provider.dart';
import '../providers/theme_provider.dart';
import '../theme/app_theme.dart';
import 'about_screen.dart';
import 'profile_screen.dart';

const double _maxContentWidth = 600;

/// Màn hình cài đặt: đổi ngôn ngữ giao diện và bật/tắt chế độ tối
/// (FR12, FR21).
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(t.settingsTitle)),
      body: Consumer2<LocaleProvider, ThemeProvider>(
        builder: (context, localeProvider, themeProvider, _) {
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: _maxContentWidth),
              child: ListView(
                padding: const EdgeInsets.all(AppTheme.spacingM),
                children: [
                  _SectionTitle(title: t.interfaceLanguage),
                  const SizedBox(height: AppTheme.spacingS),
                  Card(
                    child: RadioGroup<Locale>(
                      groupValue: localeProvider.currentLocale,
                      onChanged: (locale) {
                        if (locale != null) {
                          localeProvider.changeLocale(locale);
                        }
                      },
                      child: Column(
                        children: [
                          RadioListTile<Locale>(
                            value: const Locale('vi'),
                            title: _LanguageTitle(
                              flag: '🇻🇳',
                              label: t.vietnamese,
                            ),
                          ),
                          RadioListTile<Locale>(
                            value: const Locale('en'),
                            title: _LanguageTitle(
                              flag: '🇺🇸',
                              label: t.english,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingL),
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.people_outline_rounded),
                      title: Text(t.profilesTitle),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const ProfileScreen(),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingL),
                  _SectionTitle(title: t.appearance),
                  const SizedBox(height: AppTheme.spacingS),
                  Card(
                    child: SwitchListTile(
                      value: themeProvider.isDarkMode,
                      onChanged: (_) => themeProvider.toggleTheme(),
                      title: Text(t.darkMode),
                      secondary: Icon(
                        themeProvider.isDarkMode
                            ? Icons.dark_mode_rounded
                            : Icons.light_mode_rounded,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingL),
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.info_outline_rounded),
                      title: Text(t.about),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const AboutScreen(),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _LanguageTitle extends StatelessWidget {
  const _LanguageTitle({required this.flag, required this.label});

  final String flag;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(flag, style: const TextStyle(fontSize: 28)),
        const SizedBox(width: AppTheme.spacingM),
        Expanded(child: Text(label)),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingS),
      child: Text(
        title,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
