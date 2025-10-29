// 📍 lib/services/spotify_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SpotifyArtist {
  final String name;
  final String? imageUrl;

  SpotifyArtist({required this.name, this.imageUrl});
}

class SpotifyService {
  late final String clientId;
  late final String clientSecret;
  String? _accessToken;

  SpotifyService() {
    // 🔹 .envから環境変数を取得
    clientId = dotenv.env['SPOTIFY_CLIENT_ID'] ?? '';
    clientSecret = dotenv.env['SPOTIFY_CLIENT_SECRET'] ?? '';
  }

  /// 🔹 アクセストークン取得
  Future<void> _fetchAccessToken() async {
    if (clientId.isEmpty || clientSecret.isEmpty) {
      throw Exception('SpotifyのClient IDまたはSecretが設定されていません');
    }

    final credentials = base64Encode(utf8.encode('$clientId:$clientSecret'));

    final response = await http.post(
      Uri.parse('https://accounts.spotify.com/api/token'),
      headers: {
        'Authorization': 'Basic $credentials',
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {'grant_type': 'client_credentials'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      _accessToken = data['access_token'];
    } else {
      throw Exception('Spotifyトークン取得失敗: ${response.statusCode}');
    }
  }

  /// 🔍 アーティスト検索
  Future<List<SpotifyArtist>> searchArtists(String query) async {
    if (query.isEmpty) return [];
    if (_accessToken == null) await _fetchAccessToken();

    final response = await http.get(
      Uri.parse(
        'https://api.spotify.com/v1/search?q=$query&type=artist&limit=21',
      ),
      headers: {'Authorization': 'Bearer $_accessToken'},
    );

    if (response.statusCode != 200) {
      throw Exception('Spotify検索失敗: ${response.statusCode}');
    }

    final data = jsonDecode(response.body);
    final artists = data['artists']['items'] as List;

    return artists.map((artist) {
      final images = artist['images'] as List?;
      final imageUrl = (images != null && images.isNotEmpty)
          ? images.first['url']
          : null;
      return SpotifyArtist(name: artist['name'], imageUrl: imageUrl);
    }).toList();
  }
}
