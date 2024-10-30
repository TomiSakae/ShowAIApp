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
                    Icons.recommend_outlined,
                    color: Colors.blue[300],
                    size: 24,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Có thể bạn quan tâm',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[300],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              isLoading
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  : ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: randomWebsites.length,
                      separatorBuilder: (context, index) => const Divider(
                        color: Colors.grey,
                        height: 32,
                      ),
                      itemBuilder: (context, index) {
                        return Container(
                          height: 360,
                          decoration: BoxDecoration(
                            color: Colors.grey[850],
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                              color: Colors.grey[800]!,
                              width: 1,
                            ),
                          ),
                          child: WebsiteCard(
                            website: randomWebsites[index],
                            showDescription: true,
                          ),
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
