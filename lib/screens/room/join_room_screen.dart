import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/room_service.dart';
import '../../services/user_service.dart';

import 'package:go_router/go_router.dart';

class JoinRoomScreen extends StatefulWidget {
  const JoinRoomScreen({super.key});

  @override
  State<JoinRoomScreen> createState() => _JoinRoomScreenState();
}

class _JoinRoomScreenState extends State<JoinRoomScreen> {
  final RoomService _roomService = RoomService();
  final UserService _userService = UserService();

  final List<TextEditingController> _controllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  bool isLoading = false;
  bool isValid = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();

    // 🔹 各コントローラにリスナーを追加
    for (int i = 0; i < 6; i++) {
      _controllers[i].addListener(_onCodeChanged);
    }

    // 🔸 初期フォーカスを1文字目に設定（小さな遅延で確実に反映）
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNodes.first.requestFocus();
    });
  }

  @override
  void dispose() {
    // 🔹 フォーカスとコントローラを全て破棄
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  // 🔹 コード入力が変わるたびに呼ばれる
  void _onCodeChanged() {
    final code = _controllers.map((c) => c.text).join();
    setState(() {
      isValid = code.length == 6 && RegExp(r'^\d{6}$').hasMatch(code);
    });
  }

  // 🔹 数字入力または削除時のフォーカス制御
  void _handleInput(String value, int index) {
    if (value.isNotEmpty && index < 5) {
      // 入力があれば次の欄へ移動
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      // 削除時は前の欄に戻る
      _focusNodes[index - 1].requestFocus();
    }
  }

  // 🔹 キーボード閉じる
  void _closeKeyboard() {
    FocusScope.of(context).unfocus();
  }

  // 🔹 ルーム参加処理
  Future<void> _joinRoom() async {
    _closeKeyboard();
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      setState(() {
        errorMessage = 'ログイン情報が見つかりません';
        isLoading = false;
      });
      return;
    }

    final userData = await _userService.getUserProfile(uid);
    if (userData == null) {
      setState(() {
        errorMessage = 'プロフィール情報が見つかりません';
        isLoading = false;
      });
      return;
    }

    final nickname = userData['nickname'] as String? ?? '名無し';
    final iconKey = userData['icon'] as String? ?? 'finn';
    final code = _controllers.map((c) => c.text).join();

    final success = await _roomService.joinRoom(
      code: code,
      uid: uid,
      nickname: nickname,
      iconKey: iconKey,
    );

    setState(() => isLoading = false);

    if (!mounted) return;

    if (success) {
      context.go('/room/lobby/$code'); // 後でLobbyに変更
    } else {
      setState(() {
        errorMessage = '指定されたルームコードが存在しません';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _closeKeyboard, // 画面外タップでキーボード閉じる
      child: Scaffold(
        appBar: AppBar(title: const Text('部屋に入る')),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const SizedBox(height: 16),
              const Text('6桁のルームコードを入力してください', style: TextStyle(fontSize: 16)),
              const SizedBox(height: 24),

              // 🔹 6つの入力フィールドを横並びに配置
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(6, (index) {
                  return Container(
                    width: 45,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    child: TextField(
                      controller: _controllers[index],
                      focusNode: _focusNodes[index],
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      maxLength: 1,
                      decoration: const InputDecoration(
                        counterText: '',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) => _handleInput(value, index),
                    ),
                  );
                }),
              ),

              const SizedBox(height: 24),

              if (errorMessage != null)
                Text(errorMessage!, style: const TextStyle(color: Colors.red)),

              const Spacer(),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isValid && !isLoading ? _joinRoom : null,
                  child: isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('部屋に参加する'),
                ),
              ),

              const SizedBox(height: 8),

              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () {
                    _closeKeyboard();
                    context.go('/home');
                  },
                  child: const Text('ホームに戻る'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
