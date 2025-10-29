import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;

/// iTunesの楽曲情報モデル
class ItunesTrack {
  final String trackName; // 曲名
  final String artistName; // アーティスト名
  final String artworkUrl; // ジャケット画像URL
  final String previewUrl; // 30秒プレビュー音源URL
  final String? trackViewUrl; // Apple MusicページURL

  ItunesTrack({
    required this.trackName,
    required this.artistName,
    required this.artworkUrl,
    required this.previewUrl,
    this.trackViewUrl,
  });

  factory ItunesTrack.fromJson(Map<String, dynamic> json) {
    return ItunesTrack(
      trackName: json['trackName'] ?? '不明な曲名',
      artistName: json['artistName'] ?? '不明なアーティスト',
      artworkUrl: json['artworkUrl100'] ?? '',
      previewUrl: json['previewUrl'] ?? '',
      trackViewUrl: json['trackViewUrl'],
    );
  }
}

/// iTunes アーティスト情報モデル
class ItunesArtist {
  final String artistName;
  final String? artworkUrl;

  ItunesArtist({required this.artistName, this.artworkUrl});
}

/// iTunes Search APIサービス
class ItunesService {
  static const _baseUrl = 'https://itunes.apple.com/search';

  /// 🎵 ランダムジャンルから1曲を取得
  Future<ItunesTrack> fetchRandomTrack() async {
    final genres = ['pop'];
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
      print('⚠️ iTunes通信エラー: $e');
      rethrow;
    }
  }

  /// 🔍 高精度アーティスト検索（日本語・英語名を統合）
  Future<List<ItunesArtist>> searchArtists(String query) async {
    if (query.isEmpty) return [];

    final uri = Uri.parse(
      '$_baseUrl'
      '?term=$query'
      '&entity=musicArtist'
      '&attribute=artistTerm'
      '&country=JP'
      '&limit=25',
    );

    try {
      final response = await http.get(uri);
      if (response.statusCode != 200) {
        throw Exception('アーティスト検索失敗: ${response.statusCode}');
      }

      final data = json.decode(response.body);
      final results = data['results'] as List;
      if (results.isEmpty) return [];

      final Map<String, ItunesArtist> normalizedMap = {};

      for (final artist in results) {
        final name = (artist['artistName'] ?? '').trim();
        if (name.isEmpty) continue;

        // ✅ 正規化処理：全て小文字化・空白/記号削除
        final normalized = name
            .toLowerCase()
            .replaceAll(RegExp(r'\s+'), '')
            .replaceAll(RegExp(r'[.\-]'), '');

        final normalizedQuery = query
            .toLowerCase()
            .replaceAll(RegExp(r'\s+'), '')
            .replaceAll(RegExp(r'[.\-]'), '');

        // ✅ 完全一致または強い部分一致のみ許可
        final isRelated =
            normalized == normalizedQuery ||
            normalized.contains(normalizedQuery) ||
            normalizedQuery.contains(normalized);

        if (isRelated) {
          // 🔸 米津玄師 / Yonezu Kenshi → 同一とみなして統合
          normalizedMap.putIfAbsent(
            normalized,
            () => ItunesArtist(artistName: name, artworkUrl: null),
          );
        }
      }

      return normalizedMap.values.toList();
    } catch (e) {
      throw Exception('アーティスト検索エラー: $e');
    }
  }
}
