class Website {
  final String id;
  final String name;
  final List<String> description;
  final List<String> tags;
  final String link;
  final List<String> keyFeatures;
  final String? image;
  final int? view;
  final int? heart;
  final double? evaluation;

  Website({
    required this.id,
    required this.name,
    required this.description,
    required this.tags,
    required this.link,
    required this.keyFeatures,
    this.image,
    this.view,
    this.heart,
    this.evaluation,
  });

  factory Website.fromJson(Map<String, dynamic> json) {
    return Website(
      id: json['_id'] ?? json['id'],
      name: json['name'],
      description: List<String>.from(json['description']),
      tags: List<String>.from(json['tags']),
      link: json['link'],
      keyFeatures: List<String>.from(json['keyFeatures']),
      image: json['image'],
      view: json['view'],
      heart: json['heart'],
      evaluation: json['evaluation']?.toDouble(),
    );
  }
}
