import 'package:flutter/material.dart';
import '../models/website.dart';
import '../screens/website_detail_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class WebsiteCard extends StatefulWidget {
  final Website website;
  final Function(String)? onTagClick;
  final bool showDescription;

  const WebsiteCard({
    super.key,
    required this.website,
    this.onTagClick,
    this.showDescription = false,
  });

  @override
  State<WebsiteCard> createState() => _WebsiteCardState();
}

class _WebsiteCardState extends State<WebsiteCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () async {
          // Tăng lượt xem ngay lập tức
          setState(() {
            widget.website.view = (widget.website.view ?? 0) + 1;
          });

          // Gọi API để cập nhật lượt xem ở backend
          try {
            await http.post(
              Uri.parse('https://showai.io.vn/api/incrementView'),
              headers: {'Content-Type': 'application/json'},
              body: json.encode({'id': widget.website.id}),
            );
          } catch (e) {
            print('Lỗi khi tăng lượt xem: $e');
          }

          // Chuyển hướng đến trang chi tiết
          if (!context.mounted) return;
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  WebsiteDetailScreen(website: widget.website),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.website.image != null)
              AspectRatio(
                aspectRatio: 16 / 9,
                child: Image.network(
                  widget.website.image!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      const ColoredBox(color: Colors.grey),
                ),
              ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.website.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.blue[300],
                            fontWeight: FontWeight.bold,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    if (widget.showDescription)
                      Expanded(
                        child: Container(
                          constraints: const BoxConstraints(minHeight: 80),
                          child: Text(
                            widget.website.description.isNotEmpty
                                ? widget.website.description.first
                                : '',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(height: 1.3),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 36,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: widget.website.tags.map((tag) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: Chip(
                              label: Text(
                                tag,
                                style: const TextStyle(fontSize: 12),
                              ),
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                              visualDensity: VisualDensity.compact,
                              onDeleted: widget.onTagClick != null
                                  ? () => widget.onTagClick!(tag)
                                  : null,
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (widget.website.view != null)
                          Row(
                            children: [
                              const Icon(Icons.remove_red_eye,
                                  size: 14, color: Colors.grey),
                              const SizedBox(width: 2),
                              Text(
                                '${widget.website.view}',
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        if (widget.website.heart != null)
                          Row(
                            children: [
                              const Icon(Icons.favorite,
                                  size: 14, color: Colors.red),
                              const SizedBox(width: 2),
                              Text(
                                '${widget.website.heart}',
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        if (widget.website.evaluation != null)
                          Row(
                            children: [
                              const Icon(Icons.star,
                                  size: 14, color: Colors.amber),
                              const SizedBox(width: 2),
                              Text(
                                widget.website.evaluation!.toStringAsFixed(1),
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
