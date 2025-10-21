import 'package:beat_rush/constants/icon_paths.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/user_service.dart';
import '../room/components/user_profile_display.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final UserService _userService = UserService();
  String? nickname;
  String? iconPath;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final data = await _userService.getUserProfile(uid);
    if (data != null) {
      setState(() {
        nickname = data['nickname'] as String?;
        final iconKey = data['icon'] as String?;
        iconPath = IconPaths.resolve(iconKey ?? '');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: nickname != null && iconPath != null
            ? UserProfileDisplay(
                iconPath: iconPath!,
                nickname: nickname!,
                isCompact: true,
              )
            : const Text('読み込み中...'),
      ),
      body: const Center(child: Text('ホーム画面')),
    );
  }
}
