import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'supabase_service.dart';

class AuthService {
  static const String _tokenKey = 'auth_token';
  static const String _emailKey = 'user_email';
  final _storage = const FlutterSecureStorage();
  late final SupabaseService _supabaseService;

  AuthService() {
    _supabaseService = SupabaseService();
  }

  SupabaseClient get _supabase => _supabaseService.client;

  Future<void> sendMagicLink(String email) async {
    try {
      await _supabase.auth.signInWithOtp(
        email: email,
        emailRedirectTo: 'jp.shibuyer.japanese-learning-app://auth',
      );
    } catch (e) {
      throw Exception('Magic Link 送信失敗: $e');
    }
  }

  Future<void> handleAuthRedirect(String? token) async {
    if (token == null) return;
    try {
      final session = await _supabase.auth.recoverSession();
      if (session != null) {
        await _saveToken(session.accessToken, session.user.email ?? '');
      }
    } catch (e) {
      throw Exception('セッション復元失敗: $e');
    }
  }

  Future<void> _saveToken(String token, String email) async {
    await _storage.write(key: _tokenKey, value: token);
    await _storage.write(key: _emailKey, value: email);
  }

  Future<String?> getToken() async => await _storage.read(key: _tokenKey);

  Future<void> logout() async {
    await _supabase.auth.signOut();
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _emailKey);
  }

  Future<bool> isLoggedIn() async => await getToken() != null;
}
