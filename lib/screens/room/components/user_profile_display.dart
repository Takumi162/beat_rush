import 'package:flutter/material.dart';

/// ユーザーのプロフィール画像とニックネームをまとめて表示するコンポーネント
///
/// - AppBar内でも使えるコンパクト表示モード（isCompact）対応
/// - 他のユーザーを横並びで表示する用途にも再利用可能
class UserProfileDisplay extends StatelessWidget {
  final String iconPath; // 画像アセットのパス
  final String nickname; // ニックネーム
  final bool isCompact; // コンパクト表示モードかどうか（AppBar用など）

  const UserProfileDisplay({
    super.key,
    required this.iconPath,
    required this.nickname,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    // 👇 表示サイズをモードによって調整
    final double imageSize = isCompact ? 32 : 56;
    final double fontSize = isCompact ? 10 : 14;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 🔹 アイコン画像
        CircleAvatar(
          radius: imageSize / 2,
          backgroundImage: AssetImage(iconPath),
        ),

        const SizedBox(height: 4),

        // 🔹 ニックネームテキスト
        Text(
          nickname,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
          overflow: TextOverflow.ellipsis, // 長い名前は「…」で省略
        ),
      ],
    );
  }
}
