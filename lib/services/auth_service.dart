import 'package:firebase_auth/firebase_auth.dart';

/// Firebase Authentication の認証処理をまとめたサービス
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// 匿名ログインを実行し、すでにログイン中なら再利用する
  Future<String> signInAnonymously() async {
    // すでにログインしているユーザーがいれば、そのUIDを返す
    final currentUser = _auth.currentUser;
    if (currentUser != null) {
      return currentUser.uid;
    }

    // まだログインしていない場合のみ、新しく匿名ログインする
    final userCredential = await _auth.signInAnonymously();
    final uid = userCredential.user!.uid;
    return uid;
  }

  // 現在ログイン中のユーザーのUIDを返す（未ログインならnull）
  String? getCurrentUid() {
    return _auth.currentUser?.uid;
  }
}
