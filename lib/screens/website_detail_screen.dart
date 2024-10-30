import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/website.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class WebsiteDetailScreen extends StatefulWidget {
  final Website website;

  const WebsiteDetailScreen({super.key, required this.website});

  @override
  State<WebsiteDetailScreen> createState() => _WebsiteDetailScreenState();
}

class _WebsiteDetailScreenState extends State<WebsiteDetailScreen> {
  bool isHearted = false;
  bool isLoading = false;
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  int heartCount = 0;

  @override
  void initState() {
    super.initState();
    heartCount = widget.website.heart ?? 0;
    _checkHeartStatus();
  }

  Future<void> _checkHeartStatus() async {
    final user = _auth.currentUser;
    if (user != null) {
      try {
        final doc = await _firestore.collection('users').doc(user.uid).get();
        if (doc.exists) {
          final heartedWebsites =
              List<String>.from(doc.data()?['heartedWebsites'] ?? []);
          setState(() {
            isHearted = heartedWebsites.contains(widget.website.id);
          });
        }
      } catch (e) {
        print('Error checking heart status: $e');
      }
    }
  }

  Future<void> _handleHeartClick() async {
    final user = _auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Vui lòng đăng nhập để thực hiện chức năng này')),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final userDoc = _firestore.collection('users').doc(user.uid);

      final newHeartStatus = !isHearted;
      setState(() {
        isHearted = newHeartStatus;
        heartCount += newHeartStatus ? 1 : -1;
      });

      await _firestore.runTransaction((transaction) async {
        final userSnapshot = await transaction.get(userDoc);

        if (!userSnapshot.exists) {
          throw Exception('User document not found');
        }

        List<String> heartedWebsites =
            List<String>.from(userSnapshot.data()?['heartedWebsites'] ?? []);

        if (newHeartStatus) {
          if (!heartedWebsites.contains(widget.website.id)) {
            heartedWebsites.add(widget.website.id);
          }
        } else {
          heartedWebsites.remove(widget.website.id);
        }

        transaction.update(userDoc, {
          'heartedWebsites': heartedWebsites,
        });
      });

      _updateHeartCount(newHeartStatus).catchError((error) {
        print('Error updating API: $error');
      });
    } catch (e) {
      setState(() {
        isHearted = !isHearted;
        heartCount += isHearted ? 1 : -1;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Có lỗi xảy ra: ${e.toString()}')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _updateHeartCount(bool increment) async {
    try {
      await http.post(
        Uri.parse('https://showai.io.vn/api/updateHeart'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'id': widget.website.id,
          'increment': increment,
        }),
      );
    } catch (e) {
      print('Error updating heart count API: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: Colors.transparent,
            flexibleSpace: FlexibleSpaceBar(
              background: widget.website.image != null
                  ? Stack(
                      fit: StackFit.expand,
                      children: [
                        Hero(
                          tag: widget.website.id,
                          child: Image.network(
                            widget.website.image!,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withOpacity(0.3),
                                Colors.black.withOpacity(0.8),
                              ],
                            ),
                          ),
                        ),
                      ],
                    )
                  : null,
              title: Text(
                widget.website.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatItem(
                          Icons.remove_red_eye,
                          '${widget.website.view ?? 0}',
                          Colors.blue,
                          'Lượt xem',
                        ),
                        _buildStatItem(
                          Icons.favorite,
                          '$heartCount',
                          isHearted ? Colors.red : Colors.grey,
                          'Yêu thích',
                          onTap: _handleHeartClick,
                          isLoading: isLoading,
                        ),
                        _buildStatItem(
                          Icons.star,
                          widget.website.evaluation?.toStringAsFixed(1) ??
                              '0.0',
                          Colors.amber,
                          'Đánh giá',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final url = Uri.parse(widget.website.link);
                        try {
                          if (await canLaunchUrl(url)) {
                            await launchUrl(
                              url,
                              mode: LaunchMode.externalApplication,
                            );
                          } else {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Không thể mở link này')),
                              );
                            }
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Có lỗi xảy ra khi mở link')),
                            );
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.launch),
                      label: const Text(
                        'Truy cập website',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: widget.website.tags.map((tag) {
                      return Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.blue.shade400,
                              Colors.blue.shade600
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blue.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Chip(
                          label: Text(
                            tag,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                              fontSize: 13,
                            ),
                          ),
                          backgroundColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 2),
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 30),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.grey[900]!,
                          Colors.grey[850]!,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.grey[800]!,
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.description_outlined,
                              color: Colors.blue[300],
                              size: 24,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'Mô tả',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue[300],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 15),
                        Text(
                          widget.website.description.first,
                          style:
                              Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    height: 1.6,
                                    color: Colors.grey[300],
                                    fontSize: 15,
                                  ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  if (widget.website.keyFeatures.isNotEmpty) ...[
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[850],
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.grey[800]!,
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.stars_outlined,
                                color: Colors.blue[300],
                                size: 24,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                'Tính năng chính',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue[300],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 15),
                          ...widget.website.keyFeatures.map((feature) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '•',
                                    style: TextStyle(
                                      color: Colors.blue[400],
                                      fontSize: 24,
                                      height: 1,
                                    ),
                                  ),
                                  const SizedBox(width: 15),
                                  Expanded(
                                    child: Text(
                                      feature,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyLarge
                                          ?.copyWith(
                                            height: 1.5,
                                            color: Colors.grey[300],
                                            fontSize: 15,
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    IconData icon,
    String value,
    Color color,
    String label, {
    VoidCallback? onTap,
    bool isLoading = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          isLoading
              ? const SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                )
              : Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
