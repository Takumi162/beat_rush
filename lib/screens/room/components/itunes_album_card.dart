import 'package:flutter/material.dart';

class ItunesAlbumCard extends StatelessWidget {
  final ValueNotifier<String> albumArtUrlNotifier;
  final ValueNotifier<String> trackTitleNotifier;
  final ValueNotifier<String> artistNameNotifier;
  final Future<void> Function()? onSkip;

  const ItunesAlbumCard({
    super.key,
    required this.albumArtUrlNotifier,
    required this.trackTitleNotifier,
    required this.artistNameNotifier,
    this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // 🔹 画像はAnimatedSwitcherで自然に切り替え
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
            const SizedBox(width: 16),
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
