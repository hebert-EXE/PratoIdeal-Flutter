// Modelos da camada Google Places, espelhando os tipos do
// `src/services/restaurantService.ts` do web (`RestaurantCard`,
// `RestaurantDetails`, `ReviewItem`).

/// Card de restaurante para listagens/carrosséis.
class RestaurantCard {
  final String id; // place_id do Google
  final String name;
  final String city;
  final String state;
  final double rating;
  final String distance;
  final String image;
  final String openUntil;
  final List<String> openingHours;
  final String? category;
  final String? discountPratoIdeal;

  const RestaurantCard({
    required this.id,
    required this.name,
    required this.city,
    required this.state,
    required this.rating,
    required this.distance,
    required this.image,
    this.openUntil = '23:00',
    this.openingHours = const [],
    this.category,
    this.discountPratoIdeal,
  });
}

/// Detalhes completos de um restaurante (tela de detalhe).
class RestaurantDetails {
  final String id;
  final String name;
  final String city;
  final String state;
  final double rating;
  final String distance;
  final String image;
  final String openUntil;
  final List<String> openingHours;
  final String address;
  final String phone;
  final double lat;
  final double lng;
  final List<String> photos;
  final List<ReviewItem> reviews;
  final String description;

  const RestaurantDetails({
    required this.id,
    required this.name,
    required this.city,
    required this.state,
    required this.rating,
    required this.distance,
    required this.image,
    required this.openUntil,
    required this.openingHours,
    required this.address,
    required this.phone,
    required this.lat,
    required this.lng,
    required this.photos,
    required this.reviews,
    required this.description,
  });
}

/// Item de avaliação exibido na UI (origem: API .NET ou local).
class ReviewItem {
  final String id;
  final String userName;
  final int rating;
  final String comment;
  final String date;
  final String? userImage;
  final String? restaurantId;
  final String? restaurantName;
  final List<String> photos;

  const ReviewItem({
    required this.id,
    required this.userName,
    required this.rating,
    required this.comment,
    required this.date,
    this.userImage,
    this.restaurantId,
    this.restaurantName,
    this.photos = const [],
  });
}
