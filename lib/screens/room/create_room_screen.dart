import 'package:go_router/go_router.dart';

import '../../services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/room_service.dart';
import 'components/room_code_display.dart';

import '../room/components/waiting_players_list.dart';
import '../../services/spotify_service.dart'; // ← Spotifyサービスを使うならこれを追加

class CreateRoomScreen extends StatefulWidget {
  const CreateRoomScreen({super.key});

  @override
  State<CreateRoomScreen> createState() => _CreateRoomScreenState();
}

class _CreateRoomScreenState extends State<CreateRoomScreen> {
  final RoomService _roomService = RoomService();
  final UserService _userService = UserService();
  String roomCode = '------';
  String themeName = '未選択';
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _createRoom(); // 画面起動時に自動で部屋作成
  }

  Future<void> _createRoom() async {
    setState(() => isLoading = true);

    // 🔹 FirebaseAuth から現在のユーザーを取得
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      debugPrint('未ログインユーザー');
      setState(() => isLoading = false);
      return;
    }

    final userData = await _userService.getUserProfile(uid);
    if (userData == null) {
      debugPrint('ユーザデータが見つかりません');
      setState(() => isLoading = false);
      return;
    }

    final nickname = userData['nickname'] as String? ?? '名無し';
    final iconKey = userData['icon'] as String? ?? 'finn';

    // 🔹 6桁コードを生成
    final code = _roomService.generateCode();

    // 🔹 Firebaseにルーム作成（ニックネーム・アイコンは仮）
    await _roomService.createRoom(
      code: code,
      ownerUid: uid,
      nickname: nickname, // 後でUserServiceから取得するよう変更
      iconKey: iconKey,
    );

    // 🔹 画面に反映
    setState(() {
      roomCode = code;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('部屋をつくる'),
        actions: [
          if (isLoading)
            const Padding(
              padding: EdgeInsets.only(right: 16),
              child: Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            RoomCodeDisplay(roomCode: roomCode),

            const SizedBox(height: 16),

            Expanded(child: WaitingPlayersList(roomCode: roomCode)),

            const SizedBox(height: 16),
            Row(
              children: [
                const Text('テーマ：', style: TextStyle(fontSize: 16)),
                Text(
                  themeName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final selectedArtist = await context.push<SpotifyArtist?>(
                    '/theme/select',
                  );
                  if (selectedArtist != null) {
                    setState(() {
                      themeName = selectedArtist.name;
                    });
                  }
                },

                child: const Text('テーマを選ぶ'),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  if (themeName == '未選択') {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('テーマを選択してください')),
                    );
                    return;
                  }

                  try {
                    // 🔹 テーマを保存
                    await _roomService.updateTheme(roomCode, themeName);

                    // 🔹 ステータスを「ready」に更新
                    await _roomService.updateStatus(roomCode, 'ready');

                    // 🔹 ロビーへ遷移
                    if (!mounted) return;
                    context.go('/room/lobby/$roomCode');
                  } catch (e) {
                    debugPrint('準備完了処理エラー: $e');
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('通信エラーが発生しました')),
                    );
                  }
                },
                child: const Text('準備完了'),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => context.go('/home'),
                child: const Text('ホームに戻る'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
