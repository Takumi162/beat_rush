import 'package:flutter/material.dart';
import '../../../services/room_service.dart';
import '../../../constants/icon_paths.dart';
import 'user_profile_display.dart';

/// 🔹 待機中プレイヤー一覧をリアルタイム表示するウィジェット
class WaitingPlayersList extends StatelessWidget {
  final String roomCode;
  final RoomService _roomService = RoomService();

  WaitingPlayersList({super.key, required this.roomCode});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _roomService.watchPlayers(roomCode),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {}

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Text(
            'まだ誰も参加していません',
            style: TextStyle(color: Colors.grey),
          );
        }

        final players = snapshot.data!;

        return Wrap(
          alignment: WrapAlignment.center,
          spacing: 12,
          runSpacing: 8,
          children: players.map((player) {
            final nickname = player['nickname'] as String? ?? '？？？';
            final iconKey = player['icon'] as String? ?? 'finn';
            final iconPath = IconPaths.resolve(iconKey);

            return UserProfileDisplay(
              iconPath: iconPath,
              nickname: nickname,
              isCompact: true,
            );
          }).toList(),
        );
      },
    );
  }
}
