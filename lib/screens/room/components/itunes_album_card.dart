import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ItunesAlbumCard extends StatelessWidget {
  final ValueNotifier<String> albumArtUrlNotifier;
  final ValueNotifier<String> trackTitleNotifier;
  final ValueNotifier<String> artistNameNotifier;
  final Future<void> Function()? onSkip;

  /// 🔹 Apple Music のリンク（nullまたは空文字ならボタン非表示）
  final String? appleMusicUrl;

  const ItunesAlbumCard({
    super.key,
    required this.albumArtUrlNotifier,
    required this.trackTitleNotifier,
    required this.artistNameNotifier,
    this.onSkip,
    this.appleMusicUrl,
  });

  /// 🔗 外部ブラウザでApple Musicリンクを開く
  Future<void> _launchAppleMusicUrl(BuildContext context) async {
    if (appleMusicUrl == null || appleMusicUrl!.isEmpty) return;

    final uri = Uri.parse(appleMusicUrl!);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('リンクを開けませんでした')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // 🔹 アルバム画像（AnimatedSwitcherで自然に切替）
            Stack(
              children: [
                ValueListenableBuilder<String>(
                  valueListenable: albumArtUrlNotifier,
                  builder: (context, url, _) {
                    return AnimatedSwitcher(
                      duration: const Duration(milliseconds: 400),
                      child: ClipRRect(
                        key: ValueKey(url),
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          url,
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              const Icon(Icons.music_note, size: 80),
                        ),
                      ),
                    );
                  },
                ),

                // 🔗 Apple Musicボタン（右上に重ねる）
                if (appleMusicUrl != null && appleMusicUrl!.isNotEmpty)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: GestureDetector(
                      onTap: () => _launchAppleMusicUrl(context),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(8),
                            bottomLeft: Radius.circular(8),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 2,
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 4,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(
                              Icons.music_note,
                              size: 14,
                              color: Colors.redAccent,
                            ),
                            SizedBox(width: 2),
                            Text(
                              '開く',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.black87,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(width: 16),

            // 🔹 曲名・アーティスト名・スキップボタン
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ValueListenableBuilder<String>(
                    valueListenable: trackTitleNotifier,
                    builder: (context, title, _) => Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 4),
                  ValueListenableBuilder<String>(
                    valueListenable: artistNameNotifier,
                    builder: (context, artist, _) => Text(
                      artist,
                      style: const TextStyle(color: Colors.grey, fontSize: 14),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: onSkip,
                    icon: const Icon(Icons.skip_next),
                    label: const Text('スキップ'),
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
