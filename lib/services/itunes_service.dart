import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;

/// iTunesの楽曲情報モデル
class ItunesTrack {
  final String trackName;
  final String artistName;
  final String artworkUrl;
  final String previewUrl;

  ItunesTrack({
    required this.trackName,
    required this.artistName,
    required this.artworkUrl,
    required this.previewUrl,
  });

  factory ItunesTrack.fromJson(Map<String, dynamic> json) {
    return ItunesTrack(
      trackName: json['trackName'] ?? '不明な曲名',
      artistName: json['artistName'] ?? '不明なアーティスト',
      artworkUrl: json['artworkUrl100'] ?? '',
      previewUrl: json['previewUrl'] ?? '',
    );
  }
}

/// iTunes Search APIからランダムに1曲取得するサービス
class ItunesService {
  static const _baseUrl = 'https://itunes.apple.com/search';

  /// ランダムに人気ジャンルから1曲を取得
  Future<ItunesTrack> fetchRandomTrack() async {
    // 適当にジャンル候補をいくつか用意
    final genres = ['pop', 'rock', 'anime', 'jazz', 'hiphop', 'idol'];
    final randomGenre = genres[Random().nextInt(genres.length)];

    final uri = Uri.parse(
      '$_baseUrl?term=$randomGenre&entity=song&country=JP&limit=25',
    );

    try {
      final response = await http.get(uri);
      if (response.statusCode != 200) {
        throw Exception('iTunes API失敗: ${response.statusCode}');
      }

      final data = json.decode(response.body);
      final results = data['results'] as List;
      if (results.isEmpty) {
        throw Exception('検索結果が空です');
      }

      final randomResult = results[Random().nextInt(results.length)];
      return ItunesTrack.fromJson(randomResult);
    } catch (e) {
      throw Exception('iTunes通信エラー: $e');
    }
  }
}
