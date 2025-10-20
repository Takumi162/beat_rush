import 'package:firebase_database/firebase_database.dart';

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
}
