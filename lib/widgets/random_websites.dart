import 'package:flutter/material.dart';
import '../models/website.dart';
import 'website_card.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RandomWebsites extends StatefulWidget {
  const RandomWebsites({super.key});

  @override
  State<RandomWebsites> createState() => _RandomWebsitesState();
}

class _RandomWebsitesState extends State<RandomWebsites> {
  List<Website> randomWebsites = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchRandomWebsites();
  }

  Future<void> _fetchRandomWebsites() async {
    try {
      final response =
          await http.get(Uri.parse('https://showai.io.vn/api/showai?random=8'));
      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        setState(() {
          randomWebsites = (data['data'] as List)
              .map((item) => Website.fromJson(item))
              .toList();
          isLoading = false;
        });
      }
    } catch (e) {
      print('Lỗi khi tải website ngẫu nhiên: $e');
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
                    Icons.shuffle,
                    color: Colors.blue[300],
                    size: 24,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Đề xuất ngẫu nhiên',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[300],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              isLoading
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  : LayoutBuilder(
                      builder: (context, constraints) {
                        final crossAxisCount =
                            constraints.maxWidth > 700 ? 4 : 2;

                        final childAspectRatio =
                            crossAxisCount == 4 ? 0.55 : 0.58;

                        return GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossAxisCount,
                            childAspectRatio: childAspectRatio,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                          ),
                          itemCount: randomWebsites.length,
                          itemBuilder: (context, index) {
                            return WebsiteCard(website: randomWebsites[index]);
                          },
                        );
                      },
                    ),
            ],
          ),
        ),
      ],
    );
  }
}
