import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../services/chat_service.dart';

class ChatScreen extends StatefulWidget {
  final String initialScene;

  const ChatScreen({Key? key, required this.initialScene}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _chatService = ChatService();
  final _tts = FlutterTts();
  final _messageController = TextEditingController();
  final _messages = <Message>[];
  
  bool _isLoading = false;
  String _selectedScene = '';
  int _remainingExchanges = 5;

  @override
  void initState() {
    super.initState();
    _selectedScene = widget.initialScene;
    _initializeTTS();
    _loadRemainingExchanges();
  }

  void _initializeTTS() {
    _tts.setLanguage('ja-JP');
    _tts.setSpeechRate(0.5);
  }

  Future<void> _loadRemainingExchanges() async {
    final remaining = await _chatService.getRemainingExchanges();
    setState(() => _remainingExchanges = remaining);
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.isEmpty) return;

    final userMessage = _messageController.text;
    _messageController.clear();

    setState(() {
      _messages.add(Message(
        id: DateTime.now().toString(),
        role: 'user',
        content: userMessage,
        timestamp: DateTime.now(),
      ));
      _isLoading = true;
    });

    final result = await _chatService.sendMessage(
      userMessage: userMessage,
      scene: _selectedScene,
      conversationHistory: _messages,
    );

    if (!mounted) return;

    if (result['success'] == true) {
      final responseContent = result['content'] as String;
      
      setState(() {
        _messages.add(Message(
          id: DateTime.now().toString(),
          role: 'assistant',
          content: responseContent,
          timestamp: DateTime.now(),
        ));
        _isLoading = false;
      });

      // 音声再生
      await _tts.speak(responseContent);
      
      // Remaining exchanges 更新
      await _loadRemainingExchanges();
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('エラー: ${result['error']}')),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_selectedScene),
        actions: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Text(
                '残り: $_remainingExchanges/日',
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _messages.isEmpty
                ? const Center(
                    child: Text('メッセージを送信して学習を開始してください'),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    reverse: true,
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[_messages.length - 1 - index];
                      final isUser = message.role == 'user';

                      return Align(
                        alignment: isUser
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isUser ? Colors.blue : Colors.grey[300],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            message.content,
                            style: TextStyle(
                              color: isUser ? Colors.white : Colors.black,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'メッセージを入力',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    maxLines: null,
                  ),
                ),
                const SizedBox(width: 8),
                FloatingActionButton(
                  onPressed: _isLoading ? null : _sendMessage,
                  child: const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
