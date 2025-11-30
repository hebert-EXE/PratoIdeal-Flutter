class Review {
  final String id;
  final String restaurantId;
  final String userId;
  final int rating;
  final String comment;
  final DateTime date;

  Review({
    required this.id,
    required this.restaurantId,
    required this.userId,
    required this.rating,
    required this.comment,
    required this.date,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['Id'] ?? json['id'] ?? '',
      restaurantId: json['IdRestaurante'] ?? json['idRestaurante'] ?? '',
      userId: json['IdUsuario'] ?? json['idUsuario'] ?? '',
      rating: json['Nota'] ?? json['nota'] ?? 0,
      comment: json['Comentario'] ?? json['comentario'] ?? '',
      date: DateTime.parse(json['Data'] ?? json['data'] ?? DateTime.now().toIso8601String()),
    );
  }
}
