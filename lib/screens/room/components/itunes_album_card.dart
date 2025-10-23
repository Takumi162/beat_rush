import 'package:flutter/material.dart';

class ItunesAlbumCard extends StatelessWidget {
  final String albumTitle;
  final String artistName;
  final String albumArtUrl;
  final String trackName;
  final Future<void> Function()? onSkip;

  const ItunesAlbumCard({
    super.key,
    required this.albumTitle,
    required this.artistName,
    required this.albumArtUrl,
    required this.trackName,
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
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                albumArtUrl,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    const Icon(Icons.music_note, size: 80),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    albumTitle,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    artistName,
                    style: const TextStyle(color: Colors.grey, fontSize: 14),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
