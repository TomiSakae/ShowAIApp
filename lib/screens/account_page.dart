import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'change_password_screen.dart';
import 'delete_account_screen.dart';
import 'favorites_screen.dart';
import 'change_display_name_screen.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  String? _displayName;
  String _error = '';
  bool _isLoading = true;
  bool _isGoogleUser = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _checkAuthProvider();
  }

  void _checkAuthProvider() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        _isGoogleUser =
            user.providerData.any((info) => info.providerId == 'google.com');
      });
    }
  }

  Future<void> _loadUserData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          setState(() {
            _displayName = userDoc.data()?['displayName'];
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      setState(() {
        _error = 'Lỗi khi tải thông tin người dùng';
        _isLoading = false;
      });
    }
  }

  Future<void> _handleSignOut() async {
    try {
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      setState(() {
        _error = 'Lỗi khi đăng xuất';
      });
    }
  }

  Widget _buildInfoTab() {
    return ListView(
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.person),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        _displayName ?? 'Người dùng',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        softWrap: true,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        ListTile(
          title: const Text('Đổi tên hiển thị'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () async {
            final newName = await Navigator.push<String>(
              context,
              MaterialPageRoute(
                builder: (context) => ChangeDisplayNameScreen(
                  currentDisplayName: _displayName,
                ),
              ),
            );
            if (newName != null) {
              setState(() => _displayName = newName);
            }
          },
        ),
        const Divider(height: 1),
        ListTile(
          title: const Text('Yêu thích'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const FavoritesScreen()),
          ),
        ),
        const Divider(height: 1),
        if (!_isGoogleUser)
          ListTile(
            title: const Text('Đổi mật khẩu'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const ChangePasswordScreen()),
            ),
          ),
        const Divider(height: 1),
        ListTile(
          title: const Text('Xóa tài khoản'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const DeleteAccountScreen()),
          ),
        ),
        const Divider(height: 1),
        ListTile(
          title: const Text('Đăng xuất'),
          trailing: const Icon(Icons.chevron_right),
          onTap: _handleSignOut,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildInfoTab(),
    );
  }
}
