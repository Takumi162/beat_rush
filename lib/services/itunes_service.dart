import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;

/// iTunesの楽曲情報モデル
class ItunesTrack {
  final String trackName; // 曲名
  final String artistName; // アーティスト名
  final String artworkUrl; // ジャケット画像URL
  final String previewUrl; // 30秒プレビュー音源URL
  final String? trackViewUrl; // Apple MusicページURL（将来的に使う）

  ItunesTrack({
    required this.trackName,
    required this.artistName,
    required this.artworkUrl,
    required this.previewUrl,
    this.trackViewUrl,
  });

  /// JSON → ItunesTrackオブジェクト変換
  factory ItunesTrack.fromJson(Map<String, dynamic> json) {
    return ItunesTrack(
      trackName: json['trackName'] ?? '不明な曲名',
      artistName: json['artistName'] ?? '不明なアーティスト',
      artworkUrl: json['artworkUrl100'] ?? '',
      previewUrl: json['previewUrl'] ?? '',
      trackViewUrl: json['trackViewUrl'], // Apple MusicのページURL
    );
  }
}

/// iTunes Search APIからランダムに1曲を取得するサービス
class ItunesService {
  static const _baseUrl = 'https://itunes.apple.com/search';

  /// 🎵 ランダムジャンルから1曲を取得
  Future<ItunesTrack> fetchRandomTrack() async {
    // ジャンル候補（バリエーションを増やすとより多様に）
    final genres = [
      'pop',
      'rock',
      'anime',
      'jazz',
      'hiphop',
      'idol',
      'classical',
    ];
    final randomGenre = genres[Random().nextInt(genres.length)];

    final uri = Uri.parse(
      '$_baseUrl?term=$randomGenre&entity=song&country=JP&limit=50',
    );

    try {
      final response = await http.get(uri);
      if (response.statusCode != 200) {
        throw Exception('iTunes APIエラー: ${response.statusCode}');
      }

      final data = json.decode(response.body);
      final results = data['results'] as List?;

      if (results == null || results.isEmpty) {
        throw Exception('検索結果が空です (genre: $randomGenre)');
      }

      // 再生可能なプレビューURLが存在する曲のみ抽出
      final playableTracks = results
          .where(
            (r) =>
                r['previewUrl'] != null &&
                (r['previewUrl'] as String).isNotEmpty,
          )
          .toList();

      if (playableTracks.isEmpty) {
        throw Exception('プレビュー音源付きの曲が見つかりません');
      }

      final randomResult =
          playableTracks[Random().nextInt(playableTracks.length)];
      return ItunesTrack.fromJson(randomResult);
    } catch (e) {
      // ここで詳細を出力してデバッグしやすく
      print('⚠️ iTunes通信エラー: $e');
      rethrow;
    }
  }
}
