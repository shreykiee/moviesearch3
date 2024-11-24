class Movie {
  final String id;
  final String title;
  final String? imageUrl;
  final String? year;
  final String? type;
  final String? description;

  Movie({
    required this.id,
    required this.title,
    this.imageUrl,
    this.year,
    this.type,
    this.description,
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['id'],
      title: json['l'],
      imageUrl: json['i']?['imageUrl'],
      year: json['y']?.toString(),
      type: json['qid'],
      description: json['s'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'l': title,
      'i': {'imageUrl': imageUrl},
      'y': year,
      'qid': type,
      's': description,
    };
  }
}