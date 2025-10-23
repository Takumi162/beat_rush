import 'package:flutter/material.dart';

/// 🔹 iTunesの楽曲情報を表示するカードウィジェット（Phase 1：ダミー表示版）
class ItunesAlbumCard extends StatelessWidget {
  final String albumTitle;
  final String artistName;
  final String trackName; // 🎵 曲名を追加
  final String albumArtUrl;
  final String itunesUrl;

  const ItunesAlbumCard({
    super.key,
    required this.albumTitle,
    required this.artistName,
    required this.trackName, // ← 必須パラメータとして追加
    required this.albumArtUrl,
    required this.itunesUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // 🎨 アルバムアート
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                albumArtUrl,
                width: 60,
                height: 60,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 12),

            // 🎵 曲情報テキスト
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 曲名（最も目立つ）
                  Text(
                    trackName,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),

                  // アーティスト名
                  Text(
                    artistName,
                    style: const TextStyle(color: Colors.grey, fontSize: 14),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),

                  // アルバムタイトル
                  Text(
                    albumTitle,
                    style: const TextStyle(fontSize: 13, color: Colors.black54),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 8),

                  // iTunesリンク（まだ未実装）
                  GestureDetector(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('iTunesリンクは次フェーズで実装します')),
                      );
                    },
                    child: const Text(
                      '🔗 iTunesで開く',
                      style: TextStyle(
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
