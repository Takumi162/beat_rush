import 'package:firebase_database/firebase_database.dart';

/// ルーム作成や管理を行うサービス
class RoomService {
  final _db = FirebaseDatabase.instance.ref();

  /// 6桁のランダムなルームコードを生成
  String generateCode() {
    final now = DateTime.now().millisecondsSinceEpoch;
    final code = (now % 900000 + 100000).toString();
    return code; // 例: "428195"
  }

  /// ルームを新規作成
  Future<void> createRoom({
    required String code,
    required String ownerUid,
    required String nickname,
    required String iconKey,
  }) async {
    final roomRef = _db.child('rooms/$code');

    await roomRef.set({
      'ownerUid': ownerUid,
      'status': 'lobby',
      'settings': {
        'themeId': null,
        'mode': 'first_to_5', // 固定ルール
      },
      'players': {
        ownerUid: {
          'nickname': nickname,
          'icon': iconKey,
          'joinedAt': DateTime.now().toIso8601String(),
        },
      },
      'createdAt': DateTime.now().toIso8601String(),
    });
  }

  /// 🔹 プレイヤー一覧をリアルタイム監視する
  Stream<List<Map<String, dynamic>>> watchPlayers(String code) {
    final playersRef = _db.child('rooms/$code/players');

    return playersRef.onValue.map((event) {
      if (!event.snapshot.exists) return <Map<String, dynamic>>[];

      // Firebaseから取得したデータをMapに変換
      final raw = Map<String, dynamic>.from(event.snapshot.value as Map);
      final players = raw.entries.map((entry) {
        final playerData = Map<String, dynamic>.from(entry.value as Map);
        return {
          'uid': entry.key,
          'nickname': playerData['nickname'],
          'icon': playerData['icon'],
        };
      }).toList();

      return players;
    });
  }

  /// 🔹 ルームに参加する
  Future<bool> joinRoom({
    required String code,
    required String uid,
    required String nickname,
    required String iconKey,
  }) async {
    final roomRef = _db.child('rooms/$code');

    // ルームが存在するか確認
    final roomSnapshot = await roomRef.get();
    if (!roomSnapshot.exists) {
      return false; // ❌ ルームが存在しない
    }

    // 🔹 すでに同じUIDで登録済みでなければ追加
    final playerRef = roomRef.child('players/$uid');
    await playerRef.set({
      'nickname': nickname,
      'icon': iconKey,
      'joinedAt': DateTime.now().toIso8601String(),
    });

    return true; // ✅ 成功
  }

  // 部屋の情報を取得し、Map型で返す。
  Future<Map<String, dynamic>?> getRoomData(String code) async {
    final snap = await _db.child('rooms/$code').get();
    if (!snap.exists) return null;
    return Map<String, dynamic>.from(snap.value as Map);
  }

  /// 🔹 ルームを削除する（オーナーのみ呼び出し想定）
  Future<void> deleteRoom(String code) async {
    final roomRef = _db.child('rooms/$code');
    await roomRef.remove();
  }
}
