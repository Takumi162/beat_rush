import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/room_service.dart';
import 'components/room_code_display.dart';

class CreateRoomScreen extends StatefulWidget {
  const CreateRoomScreen({super.key});

  @override
  State<CreateRoomScreen> createState() => _CreateRoomScreenState();
}

class _CreateRoomScreenState extends State<CreateRoomScreen> {
  final RoomService _roomService = RoomService();
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

    // 🔹 6桁コードを生成
    final code = _roomService.generateCode();

    // 🔹 Firebaseにルーム作成（ニックネーム・アイコンは仮）
    await _roomService.createRoom(
      code: code,
      ownerUid: uid,
      nickname: 'たくみ', // 後でUserServiceから取得するよう変更
      iconKey: 'finn',
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
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('ルール：5本先取', style: TextStyle(fontSize: 16)),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                child: const Text('テーマを選ぶ'),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                child: const Text('ゲーム開始'),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.of(context).maybePop(),
                child: const Text('ホームに戻る'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
