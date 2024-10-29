class Website {
  final String id;
  final String name;
  final List<String> description;
  final List<String> tags;
  final String link;
  final List<String> keyFeatures;
  final String? image;
  final String? displayName;
  final DateTime? createdAt;
  final int? heart;
  final int? star;
  final int? view;
  final double? evaluation;

  Website({
    required this.id,
    required this.name,
    required this.description,
    required this.tags,
    required this.link,
    required this.keyFeatures,
    this.image,
    this.displayName,
    this.createdAt,
    this.heart,
    this.star,
    this.view,
    this.evaluation,
  });

  factory Website.fromJson(Map<String, dynamic> json) {
    return Website(
      id: json['id'],
      name: json['name'],
      description: List<String>.from(json['description']),
      tags: List<String>.from(json['tags']),
      link: json['link'],
      keyFeatures: List<String>.from(json['keyFeatures']),
      image: json['image'],
      displayName: json['displayName'],
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      heart: json['heart'],
      star: json['star'],
      view: json['view'],
      evaluation: json['evaluation']?.toDouble(),
    );
  }
}
