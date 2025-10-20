import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ホーム'), centerTitle: true),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 部屋をつくるボタン
            ElevatedButton(
              onPressed: () => context.go('/room/create'),
              child: const Text('部屋をつくる'),
            ),
            const SizedBox(height: 16),
            // 部屋に入るボタン
            ElevatedButton(
              onPressed: () => context.go('/room/join'),
              child: const Text('部屋に入る'),
            ),
          ],
        ),
      ),
    );
  }
}
