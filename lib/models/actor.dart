class Actor {
  final String id;
  final String name;
  final String? imageUrl;
  final String? knownFor;

  Actor({
    required this.id,
    required this.name,
    this.imageUrl,
    this.knownFor,
  });

  factory Actor.fromJson(Map<String, dynamic> json) {
    return Actor(
      id: json['id'],
      name: json['l'],
      imageUrl: json['i']?['imageUrl'],
      knownFor: json['s'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'l': name,
      'i': {'imageUrl': imageUrl},
      's': knownFor,
    };
  }
}