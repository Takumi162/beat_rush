import 'package:flutter/material.dart';
import '../../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _nicknameController = TextEditingController();
  final _authService = AuthService();

  String? _selectedIcon;
  final List<Map<String, String>> _icons = [
    {'key': 'jake', 'path': 'assets/icons/jake.png'},
    {'key': 'finn', 'path': 'assets/icons/finn.png'},
  ];

  // ✅ STEP 2：バリデーション条件
  bool get _isFormValid {
    final nickname = _nicknameController.text.trim();
    return nickname.isNotEmpty && _selectedIcon != null;
  }

  @override
  void initState() {
    super.initState();
    // ✅ STEP 1：リスナー登録
    _nicknameController.addListener(_onNicknameChanged);

    // すでにログイン済みならスキップ（任意）
    final uid = _authService.getCurrentUid();
    if (uid != null) {
      debugPrint("ログイン済み"); //ホーム画面へ遷移するコードを後から実装する
    }
  }

  void _onNicknameChanged() {
    setState(() {}); // 入力が変わるたびUIを更新
  }

  @override
  void dispose() {
    // ✅ リスナーを明示的に解除して安全に解放
    _nicknameController.removeListener(_onNicknameChanged);
    _nicknameController.dispose();
    super.dispose();
  }

  void _onConfirm() async {
    final nickname = _nicknameController.text.trim();
    final iconKey = _selectedIcon;

    if (!_isFormValid) return;

    try {
      // 🔹 UIDを取得（ログイン済みなら再利用）
      final uid = await _authService.signInAnonymously();

      debugPrint('ログイン完了 UID: $uid');
      debugPrint('ニックネーム: $nickname');
      debugPrint('選択アイコン: $iconKey');

      // このあとUserServiceでDatabase保存を行う予定
    } catch (e) {
      debugPrint('ログイン中にエラー: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('ログインに失敗しました。')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('プロフィール設定')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 24),

            const Text(
              'ニックネームを入力してください',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            TextField(
              controller: _nicknameController,
              decoration: const InputDecoration(hintText: 'たくみ など'),
            ),

            const SizedBox(height: 32),
            const Text(
              'アイコンを選んでください',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: _icons.map((icon) {
                final isSelected = _selectedIcon == icon['key'];
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedIcon = icon['key'];
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: isSelected ? Colors.green : Colors.transparent,
                        width: 3,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Image.asset(icon['path']!, width: 80, height: 80),
                  ),
                );
              }).toList(),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: _isFormValid ? _onConfirm : null,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
              ),
              child: const Text('確定'),
            ),

            // 開発ようにサインアウトボタン配置
            const SizedBox(height: 16),
            TextButton(
              onPressed: () async {
                final user = await _authService.getCurrentUid();
                if (user != null) {
                  await _authService.signOut();
                  debugPrint('✅ サインアウトしました。currentUserをリセットしました。');
                  if (context.mounted) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(const SnackBar(content: Text('サインアウトしました')));
                  }
                } else {
                  debugPrint('⚠️ サインインしていません。');
                }
              },
              child: const Text(
                'サインアウト（デバッグ用）',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
