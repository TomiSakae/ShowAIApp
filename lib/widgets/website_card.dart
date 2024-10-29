import 'package:flutter/material.dart';
import '../models/website.dart';
import '../screens/website_detail_screen.dart';

class WebsiteCard extends StatelessWidget {
  final Website website;
  final Function(String)? onTagClick;

  const WebsiteCard({
    super.key,
    required this.website,
    this.onTagClick,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => WebsiteDetailScreen(website: website),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (website.image != null)
              AspectRatio(
                aspectRatio: 16 / 9,
                child: Image.network(
                  website.image!,
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
                      website.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.blue[300],
                            fontWeight: FontWeight.bold,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: Container(
                        constraints: const BoxConstraints(minHeight: 80),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final textSpan = TextSpan(
                              text: website.description.first,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(height: 1.3),
                            );
                            final textPainter = TextPainter(
                              text: textSpan,
                              textDirection: TextDirection.ltr,
                              maxLines: 4,
                            );
                            textPainter.layout(maxWidth: constraints.maxWidth);

                            final isTextOverflowed =
                                textPainter.didExceedMaxLines;

                            return Text(
                              website.description.first +
                                  (isTextOverflowed ? '...' : ''),
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(height: 1.3),
                              maxLines: 4,
                              overflow: TextOverflow.ellipsis,
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 36,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: website.tags.map((tag) {
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
                              onDeleted: onTagClick != null
                                  ? () => onTagClick!(tag)
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
                        if (website.view != null)
                          Row(
                            children: [
                              const Icon(Icons.remove_red_eye,
                                  size: 16, color: Colors.grey),
                              const SizedBox(width: 4),
                              Text(
                                '${website.view}',
                                style: const TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        if (website.heart != null)
                          Row(
                            children: [
                              const Icon(Icons.favorite,
                                  size: 16, color: Colors.red),
                              const SizedBox(width: 4),
                              Text(
                                '${website.heart}',
                                style: const TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        if (website.evaluation != null)
                          Row(
                            children: [
                              const Icon(Icons.star,
                                  size: 16, color: Colors.amber),
                              const SizedBox(width: 4),
                              Text(
                                website.evaluation!.toStringAsFixed(1),
                                style: const TextStyle(color: Colors.grey),
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
