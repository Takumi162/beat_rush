import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ホーム画面')),
      body: const Center(
        child: Text('ここがホーム画面です！', style: TextStyle(fontSize: 20)),
      ),
    );
  }
}
