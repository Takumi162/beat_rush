import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/room_service.dart';
import 'components/itunes_album_card.dart';
import 'components/room_code_display.dart';
import 'components/waiting_players_list.dart';

import 'package:go_router/go_router.dart';

class LobbyScreen extends StatefulWidget {
  final String roomCode;
  const LobbyScreen({super.key, required this.roomCode});

  @override
  State<LobbyScreen> createState() => _LobbyScreenState();
}

class _LobbyScreenState extends State<LobbyScreen> {
  final RoomService _roomService = RoomService();
  bool isOwner = false;
  String? ownerUid;

  @override
  void initState() {
    super.initState();
    _checkOwner();
  }

  Future<void> _checkOwner() async {
    final data = await _roomService.getRoomData(widget.roomCode);
    final currentUid = FirebaseAuth.instance.currentUser?.uid;
    if (data != null && currentUid != null) {
      setState(() {
        ownerUid = data['ownerUid'] as String?;
        isOwner = ownerUid == currentUid;
      });
    }
  }

  Future<void> _leaveRoom() async {
    // オーナーが離脱＝部屋を消してから戻る
    if (isOwner) {
      await _roomService.deleteRoom(widget.roomCode);
    }
    if (!mounted) return;
    // ホームではなく「部屋作成画面」に戻る
    context.go('/room/create');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ロビー'),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            RoomCodeDisplay(roomCode: widget.roomCode),
            const SizedBox(height: 16),

            Expanded(child: WaitingPlayersList(roomCode: widget.roomCode)),
            const SizedBox(height: 16),

            // iTunes 情報（Phase 1 はダミー）
            Flexible(
              child: const ItunesAlbumCard(
                albumTitle: "Random Access Memories",
                artistName: "Daft Punk",
                albumArtUrl:
                    "https://www.google.com/imgres?q=%E3%81%82%E3%81%84%E3%81%BF%E3%82%87%E3%82%93&imgurl=https%3A%2F%2Faeradot.ismcdn.jp%2Fmwimgs%2F7%2F5%2F414m%2Fimg_753c8407ab9cfe3a061ab6ba8d80619475218.jpg&imgrefurl=https%3A%2F%2Fdot.asahi.com%2Faerakids%2Farticles%2F-%2F127755&docid=ISxWWyxaPCVmCM&tbnid=UuPDpir3PxmFqM&vet=12ahUKEwj-y_7g2rmQAxVPsVYBHT7qKrQQM3oECBgQAA..i&w=414&h=621&hcb=2&ved=2ahUKEwj-y_7g2rmQAxVPsVYBHT7qKrQQM3oECBgQAA",
                itunesUrl:
                    "https://music.apple.com/jp/album/random-access-memories/617154241",
                trackName: 'あいみょん',
              ),
            ),

            const SizedBox(height: 16),

            if (isOwner)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // 次フェーズ：対戦画面への同期遷移（status更新→全員遷移）
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('ゲーム開始は次フェーズで実装します')),
                    );
                  },
                  child: const Text('ゲーム開始（オーナーのみ）'),
                ),
              ),

            if (!isOwner)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    context.go('/room/join');
                  },
                  child: const Text('参加画面に戻る（参加者のみ）'),
                ),
              ),

            const SizedBox(height: 8),

            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: _leaveRoom,
                child: const Text('部屋作成画面に戻る'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
