class Recipe {
  final String id;
  final String title;
  final String? imageUrl;
  final String category;
  int likes;
  bool isLiked;
  bool isSaved;
  final String? description;        // Tambahan
  final List<String> ingredients;
  final List<String> steps;
  final String? authorName;
  final String? authorAvatar;
  final DateTime? createdAt;
  final String? userId;

  Recipe({
    required this.id,
    required this.title,
    this.imageUrl,
    required this.category,
    this.likes = 0,
    this.isLiked = false,
    this.isSaved = false,
    this.description,               // Tambahan
    required this.ingredients,
    required this.steps,
    this.authorName,
    this.authorAvatar,
    this.createdAt,
    this.userId,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      id: json['id'],
      title: json['title'],
      imageUrl: json['image_url'],
      category: json['category'],
      likes: json['likes'] ?? 0,
      isLiked: json['is_liked'] ?? false,
      isSaved: json['is_saved'] ?? false,
      description: json['description'],   // Tambahan
      ingredients: List<String>.from(json['ingredients'] ?? []),
      steps: List<String>.from(json['steps'] ?? []),
      authorName: json['author_name'],
      authorAvatar: json['author_avatar'],
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      userId: json['user_id'],
    );
  }

  Map<String, dynamic> toJson() {
    final json = {
      'title': title,
      'image_url': imageUrl,
      'category': category,
      'likes': likes,
      'is_liked': isLiked,
      'is_saved': isSaved,
      'description': description,    // Tambahan
      'ingredients': ingredients,
      'steps': steps,
      'author_name': authorName,
      'author_avatar': authorAvatar,
      'created_at': createdAt?.toIso8601String(),
      'user_id': userId,
    };
    if (id.isNotEmpty) {
      json['id'] = id;
    }
    return json;
  }

  Recipe copyWith({
    bool? isLiked,
    int? likes,
    bool? isSaved,
    String? imageUrl,
    String? description,            // Tambahan
  }) {
    return Recipe(
      id: id,
      title: title,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category,
      likes: likes ?? this.likes,
      isLiked: isLiked ?? this.isLiked,
      isSaved: isSaved ?? this.isSaved,
      description: description ?? this.description,
      ingredients: ingredients,
      steps: steps,
      authorName: authorName,
      authorAvatar: authorAvatar,
      createdAt: createdAt,
      userId: userId,
    );
  }
}