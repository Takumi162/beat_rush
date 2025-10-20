import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'services/auth_service.dart'; // ← あなたのAuthServiceを使用

import 'package:go_router/go_router.dart';
import './screens/login/login_screen.dart';
import './screens/home/home_screen.dart';

/// 🔹 AuthServiceのインスタンス（アプリ全体で使う）
final AuthService _authService = AuthService();

/// 🔹 GoRouter設定
final _router = GoRouter(
  initialLocation: '/login',
  // FirebaseAuthの状態変化をトリガーに再ビルドしたいので、
  // AuthServiceをChangeNotifier化しなくても「定期チェック方式」で十分（簡潔版）
  routes: [
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
  ],

  /// 🔸 ログイン状態によって遷移を出し分け
  redirect: (context, state) async {
    final uid = _authService.getCurrentUid();
    final loggingIn = state.matchedLocation == '/login';

    if (uid == null) {
      // 未ログイン → /login へ
      return loggingIn ? null : '/login';
    }

    // ログイン済みで /login にいるなら /home へ
    if (loggingIn) return '/home';

    // その他は現状維持
    return null;
  },
);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  debugPrint("Firebase 初期化成功");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'BeatRush',
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
    );
  }
}
