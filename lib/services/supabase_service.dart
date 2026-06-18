import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();

  factory SupabaseService() => _instance;

  SupabaseService._internal();

  late final SupabaseClient _client;

  SupabaseClient get client => _client;

  Future<void> initialize(String url, String anonKey) async {
    await Supabase.initialize(
      url: url,
      anonKey: anonKey,
      authFlowType: AuthFlowType.pkce,
      redirectUrl: 'jp.shibuyer.japanese-learning-app://auth',
    );
    _client = Supabase.instance.client;
  }
}
