import 'package:flutter/material.dart';

class JoinRoomScreen extends StatelessWidget {
  const JoinRoomScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('部屋に入る')),
      body: const Center(
        child: Text('これは仮の部屋参加画面です', style: TextStyle(fontSize: 18)),
      ),
    );
  }
}
