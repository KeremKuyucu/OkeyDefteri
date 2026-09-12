import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'localization_service.dart';

class AuthService {
  static final SupabaseClient _supabase = Supabase.instance.client;

  /// Web: localhost (debug/dev) veya okey.keremkk.com.tr (production)
  /// Mobile: com.keremkuyucu.okeydefteri deep link scheme
  static String get redirectUrl {
    if (kIsWeb) {
      if (kDebugMode || Uri.base.host.contains('localhost')) {
        return 'http://localhost:3000/';
      }
      return 'https://okey.keremkk.com.tr/';
    }
    return 'com.keremkuyucu.okeydefteri://login-callback/';
  }

  /// Mevcut kullanici
  static User? get currentUser => _supabase.auth.currentUser;
  static String? get currentUserId => currentUser?.id;
  static bool get isSignedIn => currentUser != null;
  static Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  /// Google ile giris (Supabase OAuth akisi)
  static Future<String?> signInWithGoogle() async {
    try {
      final bool success = await _supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: redirectUrl,
        queryParams: {
          'prompt': 'select_account',
        },
      );
      if (!success) return Localization.t('cloud.failed');
      return null;
    } on AuthException catch (e) {
      debugPrint('AuthException: ${e.message}');
      return e.message;
    } catch (e) {
      debugPrint('Google Sign-In hatasi: $e');
      return Localization.t('cloud.sign_in_error', args: [e.toString()]);
    }
  }

  /// Cikis (Yerel oturumu kesinlikle temizler)
  static Future<void> signOut() async {
    try {
      await _supabase.auth.signOut(scope: SignOutScope.global);
    } catch (e) {
      debugPrint('Supabase global signOut error: $e');
    } finally {
      try {
        await _supabase.auth.signOut(scope: SignOutScope.local);
      } catch (e) {
        debugPrint('Supabase local signOut error: $e');
      }
    }
  }

  /// Kullanici adi
  static String get displayName {
    final user = currentUser;
    if (user == null) return '';
    return user.userMetadata?['full_name'] as String? ??
        user.userMetadata?['name'] as String? ??
        user.email?.split('@').first ??
        '';
  }

  /// Avatar URL
  static String? get avatarUrl =>
      currentUser?.userMetadata?['avatar_url'] as String?;

  /// Auth state listener - main.dart'ta cagir
  static void initAuthStateListener() {
    _supabase.auth.onAuthStateChange.listen((data) {
      debugPrint('Auth state: ${data.event}');
    });
  }
}
