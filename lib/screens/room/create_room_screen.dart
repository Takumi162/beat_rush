import 'package:flutter/material.dart';

class CreateRoomScreen extends StatelessWidget {
  const CreateRoomScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('部屋をつくる')),
      body: const Center(
        child: Text('これは仮の部屋作成画面です', style: TextStyle(fontSize: 18)),
      ),
    );
  }
}
