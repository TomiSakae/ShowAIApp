import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:flutter/services.dart';
import '../models/website.dart';
import '../widgets/website_card.dart';
import 'change_password_screen.dart';
import 'delete_account_screen.dart';
import 'change_display_name_screen.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  String _activeTab = 'info';
  String? _displayName;
  String _error = '';
  bool _isLoading = true;
  List<Website> _favoriteWebsites = [];
  bool _isLoadingFavorites = true;
  bool _isGoogleUser = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadFavoriteWebsites();
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

  Future<void> _loadFavoriteWebsites() async {
    try {
      setState(() => _isLoadingFavorites = true);

      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          final List<dynamic> heartedIds =
              userDoc.data()?['heartedWebsites'] ?? [];
          print('Danh sách ID yêu thích: $heartedIds'); // Debug log

          if (heartedIds.isEmpty) {
            setState(() {
              _favoriteWebsites = [];
              _isLoadingFavorites = false;
            });
            return;
          }

          final idsString = heartedIds.join(',');
          print('Chuỗi ID gửi API: $idsString'); // Debug log

          final response = await http.get(
            Uri.parse('https://showai.io.vn/api/showai?list=$idsString'),
          );

          if (response.statusCode == 200) {
            final data = json.decode(utf8.decode(response.bodyBytes));
            print('Dữ liệu API trả về: ${data['data']}'); // Debug log

            if (data['data'] != null) {
              final List<Website> websites = (data['data'] as List)
                  .map((item) => Website.fromJson(item))
                  .toList();

              setState(() {
                _favoriteWebsites = websites;
                _isLoadingFavorites = false;
              });
            }
          } else {
            print('API trả về status code: ${response.statusCode}');
            throw Exception('Failed to load favorites');
          }
        }
      }
    } catch (e) {
      print('Lỗi khi tải danh sách yêu thích: $e');
      setState(() {
        _isLoadingFavorites = false;
        _error = 'Không thể tải danh sách yêu thích';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Tab buttons
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 40,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: _activeTab == 'info'
                                ? Theme.of(context).primaryColor
                                : Colors.grey.withOpacity(0.2),
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(8),
                              onTap: () => setState(() => _activeTab = 'info'),
                              child: Center(
                                child: Text(
                                  'Thông tin',
                                  style: TextStyle(
                                    color: _activeTab == 'info'
                                        ? Colors.white
                                        : Colors.grey[700],
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          height: 40,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: _activeTab == 'favorites'
                                ? Theme.of(context).primaryColor
                                : Colors.grey.withOpacity(0.2),
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(8),
                              onTap: () =>
                                  setState(() => _activeTab = 'favorites'),
                              child: Center(
                                child: Text(
                                  'Yêu thích',
                                  style: TextStyle(
                                    color: _activeTab == 'favorites'
                                        ? Colors.white
                                        : Colors.grey[700],
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Tab content
                Expanded(
                  child: _activeTab == 'info'
                      ? _buildInfoTab()
                      : _buildFavoritesTab(),
                ),

                if (_error.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      _error,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
              ],
            ),
    );
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

        // Thêm tùy chọn đổi tên hiển thị
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

        // Danh sách các tùy chọn
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

  Widget _buildFavoritesTab() {
    if (_isLoadingFavorites) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_favoriteWebsites.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.favorite_border, size: 48, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Chưa có mục yêu thích nào',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.65,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: _favoriteWebsites.length,
      itemBuilder: (context, index) {
        return WebsiteCard(website: _favoriteWebsites[index]);
      },
    );
  }
}
