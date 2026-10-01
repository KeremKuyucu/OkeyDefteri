import 'package:flutter/material.dart';
import '../services/settings_service.dart';
import '../services/localization_service.dart';
import '../theme/app_theme.dart';
import '../main.dart';
import 'developer_info.dart';

class SettingsSheet extends StatefulWidget {
  const SettingsSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surfaceDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => const SettingsSheet(),
    );
  }

  @override
  State<SettingsSheet> createState() => _SettingsSheetState();
}

class _SettingsSheetState extends State<SettingsSheet> {
  late bool _isVibrationEnabled;
  late bool _isSoundEnabled;
  late bool _isTelemetryEnabled;
  late bool _isToxicNicknamesEnabled;

  @override
  void initState() {
    super.initState();
    _isVibrationEnabled = SettingsService.getVibrationEnabled();
    _isSoundEnabled = SettingsService.getSoundEnabled();
    _isTelemetryEnabled = SettingsService.getTelemetryEnabled();
    _isToxicNicknamesEnabled = SettingsService.getToxicNicknamesEnabled();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(context).padding.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              Localization.t('settings.title'),
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            ListTile(
              leading: const Icon(
                Icons.language,
                color: AppTheme.accentGold,
              ),
              title: Text(
                Localization.t('settings.language'),
                style: const TextStyle(color: AppTheme.textPrimary),
              ),
              trailing: DropdownButton<String>(
                value: Localization.currentLanguage,
                dropdownColor: AppTheme.surfaceDark,
                style: const TextStyle(color: AppTheme.textPrimary),
                underline: const SizedBox(),
                icon: const Icon(
                  Icons.arrow_drop_down,
                  color: AppTheme.accentGold,
                ),
                items: Localization.supportedLanguages.map((String lang) {
                  return DropdownMenuItem<String>(
                    value: lang,
                    child: Text(Localization.getDisplayName(lang)),
                  );
                }).toList(),
                onChanged: (String? newValue) async {
                  if (newValue != null &&
                      newValue != Localization.currentLanguage) {
                    await SettingsService.setLanguage(newValue);
                    await Localization.changeLanguage(newValue);
                    if (context.mounted) {
                      Navigator.pop(context);
                      OkeyDefteriApp.restartApp(context);
                    }
                  }
                },
              ),
            ),
            ListTile(
              leading: const Icon(
                Icons.vibration,
                color: AppTheme.accentGold,
              ),
              title: Text(
                Localization.t('settings.vibration'),
                style: const TextStyle(color: AppTheme.textPrimary),
              ),
              trailing: Switch(
                value: _isVibrationEnabled,
                onChanged: (v) async {
                  await SettingsService.setVibrationEnabled(v);
                  setState(() {
                    _isVibrationEnabled = v;
                  });
                  if (v) {
                    AudioVibrationService.vibrate();
                  }
                },
                activeThumbColor: AppTheme.accentGold,
              ),
            ),
            ListTile(
              leading: const Icon(
                Icons.volume_up,
                color: AppTheme.accentGold,
              ),
              title: Text(
                Localization.t('settings.sound_effects'),
                style: const TextStyle(color: AppTheme.textPrimary),
              ),
              trailing: Switch(
                value: _isSoundEnabled,
                onChanged: (v) async {
                  await SettingsService.setSoundEnabled(v);
                  setState(() {
                    _isSoundEnabled = v;
                  });
                  if (v) {
                    AudioVibrationService.playClickSound();
                  }
                },
                activeThumbColor: AppTheme.accentGold,
              ),
            ),
            ListTile(
              leading: const Icon(
                Icons.security,
                color: AppTheme.accentGold,
              ),
              title: Text(
                Localization.t('settings.telemetry'),
                style: const TextStyle(color: AppTheme.textPrimary),
              ),
              onTap: () async {
                if (_isTelemetryEnabled) {
                  final shouldDisable = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      backgroundColor: AppTheme.surfaceDark,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      title: Text(
                        Localization.t('settings.telemetry_dialog_title'),
                        style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      content: Text(
                        Localization.t('settings.telemetry_message'),
                        style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 14,
                          height: 1.4,
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: Text(
                            Localization.t('settings.keep_enabled'),
                            style: const TextStyle(
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.warningOrange,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () => Navigator.pop(ctx, true),
                          child: Text(
                            Localization.t('settings.disable_anyway'),
                          ),
                        ),
                      ],
                    ),
                  );

                  if (shouldDisable != true) return;
                  await SettingsService.setTelemetryEnabled(false);
                  setState(() {
                    _isTelemetryEnabled = false;
                  });
                } else {
                  await SettingsService.setTelemetryEnabled(true);
                  setState(() {
                    _isTelemetryEnabled = true;
                  });
                }
              },
              trailing: Switch(
                value: _isTelemetryEnabled,
                onChanged: (v) async {
                  if (!v) {
                    final shouldDisable = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        backgroundColor: AppTheme.surfaceDark,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        title: Text(
                          Localization.t('settings.telemetry_dialog_title'),
                          style: const TextStyle(
                            color: AppTheme.textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        content: Text(
                          Localization.t('settings.telemetry_message'),
                          style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 14,
                            height: 1.4,
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: Text(
                              Localization.t('settings.keep_enabled'),
                              style: const TextStyle(
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.warningOrange,
                              foregroundColor: Colors.white,
                            ),
                            onPressed: () => Navigator.pop(ctx, true),
                            child: Text(
                              Localization.t('settings.disable_anyway'),
                            ),
                          ),
                        ],
                      ),
                    );

                    if (shouldDisable != true) return;
                  }

                  await SettingsService.setTelemetryEnabled(v);
                  setState(() {
                    _isTelemetryEnabled = v;
                  });
                },
                activeThumbColor: AppTheme.accentGold,
              ),
            ),
            ListTile(
              leading: const Icon(
                Icons.face_retouching_off,
                color: AppTheme.accentGold,
              ),
              title: Text(
                Localization.t('settings.toxic_nicknames'),
                style: const TextStyle(color: AppTheme.textPrimary),
              ),
              trailing: Switch(
                value: _isToxicNicknamesEnabled,
                onChanged: (v) async {
                  await SettingsService.setToxicNicknamesEnabled(v);
                  setState(() {
                    _isToxicNicknamesEnabled = v;
                  });
                },
                activeThumbColor: AppTheme.accentGold,
              ),
            ),
            ListTile(
              leading: const Icon(
                Icons.info_outline,
                color: AppTheme.accentGold,
              ),
              title: Text(
                Localization.t('settings.about'),
                style: const TextStyle(color: AppTheme.textPrimary),
              ),
              onTap: () {
                Navigator.pop(context);
                DeveloperInfo.show(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
