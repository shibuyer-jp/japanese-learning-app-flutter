import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/chat_service.dart';

class SceneSelectionScreen extends StatelessWidget {
  final _chatService = ChatService();

  SceneSelectionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('学習シーン選択')),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: _chatService.learningScenes.length,
        itemBuilder: (context, index) {
          final scene = _chatService.learningScenes[index];
          final icons = [
            Icons.people,
            Icons.restaurant,
            Icons.shopping_bag,
            Icons.train,
            Icons.local_hospital,
            Icons.person,
            Icons.coffee,
          ];

          return GestureDetector(
            onTap: () => context.push('/chat', extra: scene),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.blue[100 + (index * 50)],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icons[index],
                    size: 48,
                    color: Colors.blue[900],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    scene,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[900],
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
