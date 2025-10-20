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

  // 開発用にサインアウト関数を用意
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// 現在のユーザーがFirebaseサーバー上でまだ有効かをチェック
  ///
  /// - 有効な場合 → true
  /// - 削除済み / トークン失効時 → false
  Future<bool> isUserValid() async {
    final user = _auth.currentUser;
    if (user == null) return false; // そもそも未ログイン

    try {
      // サーバーにトークン再発行を要求 → 削除済みなら例外が発生
      await user.getIdToken(true);
      return true;
    } on FirebaseAuthException catch (e) {
      // ユーザー削除・トークン無効化など
      if (e.code == 'user-disabled' ||
          e.code == 'user-token-expired' ||
          e.code == 'user-not-found') {
        return false;
      }
      rethrow; // 他の例外は上位で扱う
    } catch (_) {
      // 予期せぬ例外でも安全側に倒す
      return false;
    }
  }
}
