import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/widgets.dart';

class UserService {
  final DatabaseReference _db = FirebaseDatabase.instance.ref();

  Future<void> saveUserProfile({
    required String uid,
    required String nickname,
    required String iconKey,
  }) async {
    // 🔹 書き込み先のノードを指定
    final userRef = _db.child('users/$uid');

    // 🔹 保存するデータを定義
    await userRef.set({
      'nickname': nickname,
      'icon': iconKey,
      'createdAt': DateTime.now().toIso8601String(),
    });
  }

  /// 成功時は `{'nickname': ..., 'icon': ...}` のようなMapを返す。
  /// 該当データが存在しない場合は `null` を返す。
  Future<Map<String, dynamic>?> getUserProfile(String uid) async {
    try {
      final snapshot = await _db.child('users/$uid').get();

      if (snapshot.exists) {
        final data = Map<String, dynamic>.from(snapshot.value as Map);
        return data;
      } else {
        return null;
      }
    } catch (e) {
      debugPrint('❌ ユーザーデータ取得中にエラー: $e');
      return null;
    }
  }
}
