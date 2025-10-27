import 'package:flutter/material.dart';
import '../../services/itunes_service.dart';
import 'package:go_router/go_router.dart';

class ThemeSelectScreen extends StatefulWidget {
  const ThemeSelectScreen({super.key});

  @override
  State<ThemeSelectScreen> createState() => _ThemeSelectScreenState();
}

class _ThemeSelectScreenState extends State<ThemeSelectScreen> {
  final ItunesService _itunesService = ItunesService();
  final TextEditingController _controller = TextEditingController();

  List<ItunesArtist> _results = [];
  bool _isLoading = false;
  String? _error;

  Future<void> _search() async {
    final query = _controller.text.trim();
    if (query.isEmpty) return;

    setState(() {
      _isLoading = true;
      _error = null;
      _results = [];
    });

    try {
      final artists = await _itunesService.searchArtists(query);
      setState(() => _results = artists);
    } catch (e) {
      setState(() => _error = '検索に失敗しました: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _selectArtist(ItunesArtist artist) {
    context.pop(artist); // 🔙 選択結果を戻す
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('テーマ（アーティスト）を選ぶ')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => _search(),
              decoration: InputDecoration(
                hintText: 'アーティスト名を入力（例: 米津玄師）',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _search,
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (_isLoading)
              const CircularProgressIndicator()
            else if (_error != null)
              Text(_error!, style: const TextStyle(color: Colors.red))
            else if (_results.isEmpty)
              const Text('検索結果はありません')
            else
              Expanded(
                child: ListView.builder(
                  itemCount: _results.length,
                  itemBuilder: (context, index) {
                    final artist = _results[index];
                    return ListTile(
                      title: Text(artist.artistName),
                      onTap: () => _selectArtist(artist),
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
