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

  // 🔹 ValueNotifierで最小限のUI更新を管理
  final ValueNotifier<String> trackTitle = ValueNotifier<String>('---');
  final ValueNotifier<String> artistName = ValueNotifier<String>('---');
  final ValueNotifier<String> albumArtUrl = ValueNotifier<String>('');
  final ValueNotifier<String> appleMusicUrl = ValueNotifier<String>(
    '',
  ); // ← 追加！

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
    trackTitle.dispose();
    artistName.dispose();
    albumArtUrl.dispose();
    appleMusicUrl.dispose(); // ← 追加！
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

  /// 🎵 曲を取得して自動再生
  Future<void> _fetchAndPlayTrack() async {
    if (_isFetching) return;
    _isFetching = true;
    isLoadingTrack = true;
    setState(() {});

    try {
      final newTrack = await _itunesService.fetchRandomTrack();

      // 🔹 曲情報をValueNotifier経由で更新（UI部分更新のみ）
      trackTitle.value = newTrack.trackName;
      artistName.value = newTrack.artistName;
      albumArtUrl.value = newTrack.artworkUrl;
      appleMusicUrl.value = newTrack.trackViewUrl ?? ''; // ← 追加！

      // 🎧 自動再生
      await _audioPlayer.play(UrlSource(newTrack.previewUrl));

      // 🔁 再生終了時 → 次の曲を自動再生
      _audioPlayer.onPlayerComplete.listen((_) => _fetchAndPlayTrack());
    } catch (e) {
      debugPrint('iTunes曲取得エラー: $e');
    } finally {
      _isFetching = false;
      isLoadingTrack = false;
      if (mounted) setState(() {});
    }
  }

  bool _isLeaving = false;

  Future<void> _leaveRoom() async {
    if (isOwner) await _roomService.deleteRoom(widget.roomCode);
    if (!mounted) return;

    if (_isLeaving) return; // 🚫 二重呼び出し防止
    _isLeaving = true;

    try {
      if (isOwner) {
        await _roomService.deleteRoom(widget.roomCode);
      }
      if (!mounted) return;

      // 🔹 Navigatorロックを避ける
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.go('/room/create');
      });
    } catch (e) {
      debugPrint('部屋退出中エラー: $e');
    } finally {
      _isLeaving = false;
    }
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

            // 🔹 曲情報カード
            if (isLoadingTrack && albumArtUrl.value.isEmpty)
              const Center(child: CircularProgressIndicator())
            else
              ItunesAlbumCard(
                albumArtUrlNotifier: albumArtUrl,
                trackTitleNotifier: trackTitle,
                artistNameNotifier: artistName,
                appleMusicUrl: appleMusicUrl.value.isNotEmpty
                    ? appleMusicUrl.value
                    : null, // ← ValueNotifierからURLを受け渡し
                onSkip: _fetchAndPlayTrack,
              ),

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
