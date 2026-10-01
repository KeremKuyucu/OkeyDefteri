import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/localization_service.dart';
import '../theme/app_theme.dart';

class CloudBackupSheet extends StatelessWidget {
  final VoidCallback onRestore;
  final VoidCallback onSyncAll;
  final VoidCallback onSignOut;
  final VoidCallback onSignInWithGoogle;

  const CloudBackupSheet({
    super.key,
    required this.onRestore,
    required this.onSyncAll,
    required this.onSignOut,
    required this.onSignInWithGoogle,
  });

  static void show(
    BuildContext context, {
    required VoidCallback onRestore,
    required VoidCallback onSyncAll,
    required VoidCallback onSignOut,
    required VoidCallback onSignInWithGoogle,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surfaceDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => CloudBackupSheet(
        onRestore: onRestore,
        onSyncAll: onSyncAll,
        onSignOut: onSignOut,
        onSignInWithGoogle: onSignInWithGoogle,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isSignedIn = AuthService.isSignedIn;
    final name = AuthService.displayName;
    final avatarUrl = AuthService.avatarUrl;

    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 20,
        bottom: MediaQuery.of(context).padding.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppTheme.textMuted,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          if (isSignedIn) ...[
            // Profil bilgisi
            Row(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: AppTheme.accentGold.withValues(alpha: 0.2),
                  backgroundImage:
                      avatarUrl != null ? NetworkImage(avatarUrl) : null,
                  child: avatarUrl == null
                      ? Text(
                          name.isNotEmpty ? name[0].toUpperCase() : 'U',
                          style: const TextStyle(
                            color: AppTheme.accentGold,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        Localization.t('cloud.active'),
                        style: const TextStyle(
                          color: AppTheme.lightGreen,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Divider(color: AppTheme.surfaceCardLight),
            const SizedBox(height: 12),
            // Geri yukle
            ListTile(
              leading: const Icon(
                Icons.cloud_download_rounded,
                color: AppTheme.lightGreen,
              ),
              title: Text(
                Localization.t('cloud.restore'),
                style: const TextStyle(color: AppTheme.textPrimary),
              ),
              subtitle: Text(
                Localization.t('cloud.restore_subtitle'),
                style: const TextStyle(color: AppTheme.textMuted, fontSize: 11),
              ),
              onTap: () {
                Navigator.pop(context);
                onRestore();
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.cloud_upload_rounded,
                color: AppTheme.accentAmber,
              ),
              title: Text(
                Localization.t('cloud.push_all'),
                style: const TextStyle(color: AppTheme.textPrimary),
              ),
              subtitle: Text(
                Localization.t('cloud.push_all_subtitle'),
                style: const TextStyle(color: AppTheme.textMuted, fontSize: 11),
              ),
              onTap: () {
                Navigator.pop(context);
                onSyncAll();
              },
            ),
            const SizedBox(height: 8),
            // Cikis
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  onSignOut();
                },
                icon: const Icon(Icons.logout,
                    color: AppTheme.dangerRed, size: 18),
                label: Text(
                  Localization.t('cloud.sign_out'),
                  style: const TextStyle(color: AppTheme.dangerRed),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                    color: AppTheme.dangerRed.withValues(alpha: 0.4),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ] else ...[
            // Giris ekrani
            const Icon(
              Icons.cloud_off_rounded,
              color: AppTheme.textMuted,
              size: 48,
            ),
            const SizedBox(height: 12),
            Text(
              Localization.t('cloud.title'),
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              Localization.t('cloud.desc'),
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppTheme.textMuted, fontSize: 13),
            ),
            const SizedBox(height: 24),
            // Google ile giris
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  onSignInWithGoogle();
                },
                icon: const Text('👀', style: TextStyle(fontSize: 18)),
                label: Text(
                  Localization.t('cloud.sign_in_google'),
                  style: const TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
