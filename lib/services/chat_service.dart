import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'supabase_service.dart';

class Message {
  final String id;
  final String role; // 'user' or 'assistant'
  final String content;
  final DateTime timestamp;

  Message({
    required this.id,
    required this.role,
    required this.content,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'role': role,
    'content': content,
    'timestamp': timestamp.toIso8601String(),
  };

  factory Message.fromJson(Map<String, dynamic> json) => Message(
    id: json['id'] as String,
    role: json['role'] as String,
    content: json['content'] as String,
    timestamp: DateTime.parse(json['timestamp'] as String),
  );
}

class ChatService {
  static const String _baseUrl = 'https://japanese-learning-app-bay.vercel.app';
  final _storage = const FlutterSecureStorage();
  final _supabase = SupabaseService().client;
  late final Dio _dio;

  ChatService() {
    _dio = Dio(BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 30),
      headers: {'Content-Type': 'application/json'},
    ));
  }

  Future<String?> _getToken() async {
    return await _storage.read(key: 'auth_token');
  }

  Future<Map<String, dynamic>> sendMessage({
    required String userMessage,
    required String scene,
    List<Message> conversationHistory = const [],
  }) async {
    try {
      // Rate limit チェック
      final canExchange = await _checkRateLimit();
      if (!canExchange) {
        throw Exception('Rate limit exceeded. Please try again tomorrow.');
      }

      final token = await _getToken();
      if (token == null) {
        throw Exception('Not authenticated');
      }

      // API コール
      final response = await _dio.post(
        '/api/chat',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
        data: {
          'message': userMessage,
          'scene': scene,
          'conversationHistory': conversationHistory
              .map((m) => {'role': m.role, 'content': m.content})
              .toList(),
        },
      );

      if (response.statusCode != 200) {
        throw Exception('API error: ${response.statusCode}');
      }

      final data = response.data as Map<String, dynamic>;
      return {
        'success': true,
        'content': data['content'] as String,
        'audioUrl': data['audioUrl'] as String?,
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  Future<bool> _checkRateLimit() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return false;

      final result = await _supabase.rpc('check_and_increment_rate_limit', params: {
        'user_id': userId,
        'tz': 'Asia/Tokyo',
      }) as Map<String, dynamic>;

      return (result['remaining'] as int) > 0;
    } catch (e) {
      print('Rate limit check error: $e');
      return false;
    }
  }

  Future<int> getRemainingExchanges() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return 0;

      final result = await _supabase
          .from('rate_limits')
          .select('count')
          .eq('user_id', userId)
          .eq('date', DateTime.now().toIso8601String().split('T')[0])
          .single() as Map<String, dynamic>?;

      if (result == null) return 5; // Default free limit
      return 5 - (result['count'] as int);
    } catch (e) {
      print('Get remaining exchanges error: $e');
      return 5;
    }
  }

  List<String> get learningScenes => [
    'Meeting Japanese friends',
    'Ordering at a restaurant',
    'Shopping & asking for help',
    'Using trains & asking directions',
    'At a clinic / pharmacy',
    'Introducing yourself',
    'Casual café conversation',
  ];
}
