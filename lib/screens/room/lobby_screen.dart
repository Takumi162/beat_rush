import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/room_service.dart';
import '../../services/itunes_service.dart'; // ← 追加！
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
  final ItunesService _itunesService = ItunesService(); // ← 追加！

  bool isOwner = false;
  String? ownerUid;

  // 🔹 iTunesトラック情報
  ItunesTrack? track;
  bool isLoadingTrack = true;

  @override
  void initState() {
    super.initState();
    _checkOwner();
    _fetchRandomTrack(); // ← 追加！
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

  // 🔹 iTunesからランダム曲を取得
  Future<void> _fetchRandomTrack() async {
    try {
      final fetchedTrack = await _itunesService.fetchRandomTrack();
      setState(() {
        track = fetchedTrack;
        isLoadingTrack = false;
      });
    } catch (e) {
      debugPrint('iTunes取得エラー: $e');
      setState(() => isLoadingTrack = false);
    }
  }

  Future<void> _leaveRoom() async {
    if (isOwner) {
      await _roomService.deleteRoom(widget.roomCode);
    }
    if (!mounted) return;
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
        child: SingleChildScrollView(
          child: Column(
            children: [
              RoomCodeDisplay(roomCode: widget.roomCode),
              const SizedBox(height: 16),
              WaitingPlayersList(roomCode: widget.roomCode),
              const SizedBox(height: 16),

              // 🔹 iTunes情報部分
              if (isLoadingTrack)
                const CircularProgressIndicator()
              else if (track != null)
                ItunesAlbumCard(
                  albumTitle: track!.trackName,
                  artistName: track!.artistName,
                  albumArtUrl: track!.artworkUrl,
                  itunesUrl: track!.previewUrl, // 仮でpreviewURLを渡しておく
                  trackName: track!.trackName,
                )
              else
                const Text('曲情報の取得に失敗しました'),

              const SizedBox(height: 16),

              if (isOwner)
                ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('ゲーム開始は次フェーズで実装します')),
                    );
                  },
                  child: const Text('ゲーム開始（オーナーのみ）'),
                ),
              if (!isOwner)
                ElevatedButton(
                  onPressed: () => context.go('/room/join'),
                  child: const Text('参加画面に戻る（参加者のみ）'),
                ),
              const SizedBox(height: 8),
              TextButton(onPressed: _leaveRoom, child: const Text('部屋作成画面に戻る')),
            ],
          ),
        ),
      ),
    );
  }
}
