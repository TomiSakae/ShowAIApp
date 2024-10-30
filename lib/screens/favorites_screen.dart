import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/website.dart';
import '../widgets/website_card.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  List<Website> _favoriteWebsites = [];
  bool _isLoading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _loadFavoriteWebsites();
  }

  Future<void> _loadFavoriteWebsites() async {
    try {
      setState(() => _isLoading = true);

      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          final List<dynamic> heartedIds =
              userDoc.data()?['heartedWebsites'] ?? [];

          if (heartedIds.isEmpty) {
            setState(() {
              _favoriteWebsites = [];
              _isLoading = false;
            });
            return;
          }

          final idsString = heartedIds.join(',');

          final response = await http.get(
            Uri.parse('https://showai.io.vn/api/showai?list=$idsString'),
          );

          if (response.statusCode == 200) {
            final data = json.decode(utf8.decode(response.bodyBytes));

            if (data['data'] != null) {
              final List<Website> websites = (data['data'] as List)
                  .map((item) => Website.fromJson(item))
                  .toList();

              setState(() {
                _favoriteWebsites = websites;
                _isLoading = false;
              });
            }
          } else {
            throw Exception('Failed to load favorites');
          }
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'Không thể tải danh sách yêu thích';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Yêu thích'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error.isNotEmpty
              ? Center(child: Text(_error))
              : _favoriteWebsites.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.favorite_border,
                              size: 48, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                            'Chưa có mục yêu thích nào',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.65,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemCount: _favoriteWebsites.length,
                      itemBuilder: (context, index) {
                        return WebsiteCard(
                          website: _favoriteWebsites[index],
                        );
                      },
                    ),
    );
  }
}
