class User {
  final String id;
  final String name;
  final String email;
  final String profileImageUrl;
  final List<String> favorites; // List of Restaurant IDs

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.profileImageUrl,
    required this.favorites,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    // Trata lista de favoritos de forma segura, independente do tipo dinâmico retornado pela API
    List<String> parseFavorites(dynamic value) {
      if (value is List) {
        return value.map((e) => e.toString()).toList();
      }
      return <String>[];
    }

    return User(
      id: json['Id'] ?? json['id'] ?? '',
      name: json['Nome'] ?? json['nome'] ?? '',
      email: json['Email'] ?? json['email'] ?? '',
      profileImageUrl: json['Foto'] ?? json['foto'] ?? '',
      favorites: parseFavorites(json['Favoritos'] ?? json['favoritos']),
    );
  }
}
