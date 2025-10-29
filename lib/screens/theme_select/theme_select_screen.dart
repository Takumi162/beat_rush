// 📍 lib/screens/theme_select/theme_select_screen.dart

import 'package:flutter/material.dart';
import '../../services/spotify_service.dart';

class ThemeSelectScreen extends StatefulWidget {
  const ThemeSelectScreen({super.key});

  @override
  State<ThemeSelectScreen> createState() => _ThemeSelectScreenState();
}

class _ThemeSelectScreenState extends State<ThemeSelectScreen> {
  final TextEditingController _controller = TextEditingController();
  final SpotifyService _spotifyService = SpotifyService();

  List<SpotifyArtist> artists = [];
  bool isLoading = false;
  String? errorMessage;

  Future<void> _searchArtists() async {
    final query = _controller.text.trim();
    if (query.isEmpty) return;

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final results = await _spotifyService.searchArtists(query);
      setState(() => artists = results);
    } catch (e) {
      setState(() => errorMessage = '検索に失敗しました');
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _selectArtist(SpotifyArtist artist) {
    Navigator.pop(context, artist);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('テーマを選ぶ')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Spotifyでアーティストを検索',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _searchArtists,
                ),
              ),
              onSubmitted: (_) => _searchArtists(),
            ),
            const SizedBox(height: 16),

            if (isLoading) const CircularProgressIndicator(),

            if (errorMessage != null)
              Text(errorMessage!, style: const TextStyle(color: Colors.red)),

            const SizedBox(height: 8),

            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: artists.length,
                itemBuilder: (context, index) {
                  final artist = artists[index];
                  return GestureDetector(
                    onTap: () => _selectArtist(artist),
                    child: Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            artist.imageUrl ??
                                'https://cdn-icons-png.flaticon.com/512/149/149071.png',
                            height: 80,
                            width: 80,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          artist.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
