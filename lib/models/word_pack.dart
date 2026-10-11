import 'word_pair.dart';

class WordPack {
  final String id;
  final String name;
  final String description;
  final String icon;
  final List<WordPair> pairs;
  bool isEnabled;
  final bool isCustom;

  WordPack({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.pairs,
    this.isEnabled = true,
    this.isCustom = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'icon': icon,
        'pairs': pairs.map((p) => p.toJson()).toList(),
        'isEnabled': isEnabled,
        'isCustom': isCustom,
      };

  factory WordPack.fromJson(Map<String, dynamic> json) => WordPack(
        id: json['id'],
        name: json['name'],
        description: json['description'],
        icon: json['icon'],
        pairs: (json['pairs'] as List).map((p) => WordPair.fromJson(p)).toList(),
        isEnabled: json['isEnabled'] ?? true,
        isCustom: json['isCustom'] ?? false,
      );
}
