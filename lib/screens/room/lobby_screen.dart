import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../services/room_service.dart';
import '../../services/itunes_service.dart';
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
  final ItunesService _itunesService = ItunesService();
  final AudioPlayer _audioPlayer = AudioPlayer();

  bool isOwner = false;
  String? ownerUid;

  ItunesTrack? track;
  bool isLoadingTrack = false;
  bool _isFetching = false; // 🚫 二重リクエスト防止

  @override
  void initState() {
    super.initState();
    _checkOwner();
    _fetchAndPlayTrack(); // 🎧 初期曲を取得して自動再生
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
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

  /// 🔹 曲を取得して自動再生
  Future<void> _fetchAndPlayTrack() async {
    if (_isFetching) return;
    setState(() {
      isLoadingTrack = true;
      _isFetching = true;
    });

    try {
      final newTrack = await _itunesService.fetchRandomTrack();
      setState(() {
        track = newTrack;
      });

      // 🎧 自動再生開始
      await _audioPlayer.play(UrlSource(newTrack.previewUrl));

      // 再生が自然終了したら次の曲を自動再生
      _audioPlayer.onPlayerComplete.listen((_) {
        _fetchAndPlayTrack();
      });
    } catch (e) {
      debugPrint('iTunes曲取得エラー: $e');
    } finally {
      if (mounted) {
        setState(() {
          isLoadingTrack = false;
          _isFetching = false;
        });
      }
    }
  }

  Future<void> _leaveRoom() async {
    if (isOwner) await _roomService.deleteRoom(widget.roomCode);
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
        child: Column(
          children: [
            RoomCodeDisplay(roomCode: widget.roomCode),
            const SizedBox(height: 16),
            Expanded(child: WaitingPlayersList(roomCode: widget.roomCode)),
            const SizedBox(height: 16),

            // 🔹 曲情報表示
            if (isLoadingTrack)
              const Center(child: CircularProgressIndicator())
            else if (track != null)
              ItunesAlbumCard(
                albumTitle: track!.trackName,
                artistName: track!.artistName,
                albumArtUrl: track!.artworkUrl,
                trackName: track!.trackName,
                onSkip: _fetchAndPlayTrack, // 🎵 スキップで自動再生
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
              )
            else
              ElevatedButton(
                onPressed: () => context.go('/room/join'),
                child: const Text('参加画面に戻る（参加者のみ）'),
              ),
            const SizedBox(height: 8),
            TextButton(onPressed: _leaveRoom, child: const Text('部屋作成画面に戻る')),
          ],
        ),
      ),
    );
  }
}
