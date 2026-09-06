import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../env.dart';
import 'localization_service.dart';

class AuthService {
  static final SupabaseClient _supabase = Supabase.instance.client;

  /// Web: localhost (debug/dev) veya okey.keremkk.com.tr (production)
  /// Mobile: okey-defteri deep link scheme
  static String get redirectUrl {
    if (kIsWeb) {
      if (kDebugMode || Uri.base.host.contains('localhost')) {
        return 'http://localhost:3000/';
      }
      return 'https://okey.keremkk.com.tr/';
    }
    return 'io.supabase.okeydefteri://login-callback/';
  }

  /// Mevcut kullanici
  static User? get currentUser => _supabase.auth.currentUser;
  static bool get isSignedIn => currentUser != null;
  static Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  /// Google ile giris
  static Future<String?> signInWithGoogle() async {
    try {
      // Web ve desktop: doğrudan OAuth browser akisi
      if (kIsWeb ||
          (defaultTargetPlatform != TargetPlatform.android &&
              defaultTargetPlatform != TargetPlatform.iOS)) {
        return await _signInWithOAuthFallback();
      }

      // Android / iOS: native google_sign_in -> idToken
      final GoogleSignIn googleSignIn = GoogleSignIn(
        serverClientId: Env.googleWebClientId.isNotEmpty ? Env.googleWebClientId : null,
        clientId: Env.googleIosClientId.isNotEmpty ? Env.googleIosClientId : null,
        scopes: const ['email', 'profile'],
      );

      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) return Localization.t('cloud.cancelled');

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final String? idToken = googleAuth.idToken;
      final String? accessToken = googleAuth.accessToken;

      if (idToken == null) {
        debugPrint('ID Token null, OAuth fallback deneniyor');
        return await _signInWithOAuthFallback();
      }

      final AuthResponse res = await _supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );

      if (res.user == null) return Localization.t('cloud.failed');
      return null; // basarili
    } on AuthException catch (e) {
      debugPrint('AuthException: ${e.message}');
      return e.message;
    } catch (e) {
      debugPrint('Google Sign-In hatasi: $e');
      return await _signInWithOAuthFallback();
    }
  }

  /// OAuth browser akisi (web + fallback)
  static Future<String?> _signInWithOAuthFallback() async {
    try {
      final bool success = await _supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: redirectUrl,
      );
      if (!success) return Localization.t('cloud.failed');
      return null;
    } on AuthException catch (e) {
      return e.message;
    } catch (e) {
      return Localization.t('cloud.sign_in_error', args: [e.toString()]);
    }
  }

  /// Magic link ile e-posta girisi
  static Future<void> signInWithEmail(String email) async {
    await _supabase.auth.signInWithOtp(
      email: email,
      emailRedirectTo: redirectUrl,
    );
  }

  /// Cikis
  static Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
    } catch (e) {
      debugPrint('Supabase signOut error: $e');
    }
    try {
      final GoogleSignIn g = GoogleSignIn();
      await g.signOut();
    } catch (_) {}
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
