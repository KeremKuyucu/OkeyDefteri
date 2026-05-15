import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_theme.dart';

class DeveloperInfo {
  static Future<void> show(BuildContext context) async {
    // Platform desteklemeyen durumlarda (test vb.) varsayılan değer
    String localVersion = '1.0.0';
    try {
      final PackageInfo packageInfo = await PackageInfo.fromPlatform();
      localVersion = packageInfo.version;
    } catch (e) {
      debugPrint('Sürüm bilgisi alınamadı: $e');
    }

    if (!context.mounted) return;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppTheme.surfaceDark,
          title: const Row(
            children: [
              Icon(Icons.info_outline, color: AppTheme.accentGold),
              SizedBox(width: 10),
              Text(
                'Hakkında',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                // Uygulama Adı
                const Center(
                  child: Text(
                    'Okey 101 Defteri',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.accentGold,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    'Versiyon: $localVersion',
                    style: const TextStyle(color: AppTheme.textSecondary),
                  ),
                ),
                const Divider(height: 24, color: AppTheme.textMuted),
                // Bilgi Satırları
                _buildInfoTile(
                  icon: Icons.person_outline,
                  title: 'Geliştirici',
                  subtitle: 'Kerem Kuyucu',
                  url: 'https://github.com/keremkuyucu',
                ),
                _buildInfoTile(
                  icon: Icons.code,
                  title: 'Kaynak Kod',
                  subtitle: 'github.com/keremkuyucu/okey_defteri',
                  url: 'https://github.com/KeremKuyucu/okey-defteri-flutter',
                ),
                _buildInfoTile(
                  icon: Icons.email_outlined,
                  title: 'İletişim',
                  subtitle: 'contact@keremkk.com.tr',
                  url: 'mailto:contact@keremkk.com.tr',
                ),
                const Divider(height: 24, color: AppTheme.textMuted),
                // Uygulama Açıklaması
                const Text(
                  'Okey 101 deneyiminizi bir üst seviyeye taşıyın! Kalem ve kağıt derdine son veren bu akıllı asistan ile puanları anında hesaplayın, maç geçmişinizi detaylı istatistiklerle takip edin ve oyun performansınıza göre kazandığınız eğlenceli lakapların tadını çıkarın.\n\nSiz sadece oyununuza odaklanın, gerisini deftere bırakın.',
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.5,
                    color: AppTheme.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                // "Made with" kısmı
                const Center(
                  child: Text(
                    'Made with ❤️ in Türkiye',
                    style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            // Lisansları Görüntüle Butonu
            TextButton(
              child: const Text(
                'Lisanslar',
                style: TextStyle(color: AppTheme.accentGold),
              ),
              onPressed: () {
                showLicensePage(
                  context: context,
                  applicationName: 'Okey 101 Defteri',
                  applicationVersion: localVersion,
                  applicationLegalese: '© 2026 Kerem Kuyucu',
                );
              },
            ),
            // Kapat Butonu
            TextButton(
              child: const Text(
                'Kapat',
                style: TextStyle(color: AppTheme.textSecondary),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  /// Dialog içindeki tıklanabilir bilgi satırlarını oluşturan yardımcı (private) metot.
  static Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String subtitle,
    String? url,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.accentGold.withValues(alpha: 0.8)),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: AppTheme.textPrimary,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(color: AppTheme.textSecondary),
      ),
      onTap: url != null ? () => _launchURL(url) : null,
      trailing: url != null
          ? const Icon(
              Icons.open_in_new,
              size: 18,
              color: AppTheme.textSecondary,
            )
          : null,
      contentPadding: EdgeInsets.zero, // Daha kompakt bir görünüm için
    );
  }

  /// Verilen URL'i cihazın varsayılan uygulamasında açan yardımcı (private) metot.
  static Future<void> _launchURL(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      debugPrint('Could not launch $urlString');
    }
  }
}
