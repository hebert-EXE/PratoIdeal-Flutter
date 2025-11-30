import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/restaurant.dart';
import '../models/user.dart';
import '../models/review.dart';

class ApiService {
  static const String baseUrl = 'https://apirestaurantes.onrender.com/api';

  // Auth
  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/Usuario/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'Email': email, 'Senha': password}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Falha no login: ${response.body}');
    }
  }

  Future<void> register(String name, String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/Usuario/cadastro'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'Nome': name, 'Email': email, 'Senha': password}),
    );

    if (response.statusCode != 200) {
      throw Exception('Falha no cadastro: ${response.body}');
    }
  }

  // Restaurants
  Future<List<Restaurant>> getRestaurants() async {
    final response = await http.get(Uri.parse('$baseUrl/Restaurante'));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Restaurant.fromJson(json)).toList();
    } else {
      throw Exception('Falha ao carregar restaurantes');
    }
  }

  Future<List<String>> getRestaurantCategories() async {
    final response = await http.get(Uri.parse('$baseUrl/Restaurante'));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      final categories = <String>{};
      for (final item in data) {
        final category =
            (item as Map<String, dynamic>)['Categoria'] ??
            (item as Map<String, dynamic>)['categoria'];
        if (category is String && category.isNotEmpty) {
          categories.add(category);
        }
      }
      return categories.toList();
    } else {
      throw Exception('Falha ao carregar categorias de restaurantes');
    }
  }

  Future<List<Restaurant>> getRestaurantsByCategory(String category) async {
    final response = await http.get(
      Uri.parse('$baseUrl/Restaurante/categoria/$category'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Restaurant.fromJson(json)).toList();
    } else {
      throw Exception('Falha ao carregar restaurantes por categoria');
    }
  }

  Future<Restaurant> getRestaurant(String id) async {
    final response = await http.get(Uri.parse('$baseUrl/Restaurante/$id'));

    if (response.statusCode == 200) {
      return Restaurant.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Falha ao carregar restaurante');
    }
  }

  // Reviews
  Future<List<Review>> getReviews(String restaurantId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/Review/restaurante/$restaurantId'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Review.fromJson(json)).toList();
    } else {
      throw Exception('Falha ao carregar avaliações');
    }
  }

  Future<void> createReview(
    String restaurantId,
    String userId,
    int rating,
    String comment,
    String token,
  ) async {
    // Converte IDs para número quando possível e garante data em UTC ISO 8601 com 'Z'
    final parsedRestaurantId = int.tryParse(restaurantId);
    final parsedUserId = int.tryParse(userId);
    final clampedRating = rating.clamp(0, 5);

    final response = await http.post(
      Uri.parse('$baseUrl/Review'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'IdRestaurante': parsedRestaurantId ?? restaurantId,
        'IdUsuario': parsedUserId ?? userId,
        'Nota': clampedRating,
        'Comentario': comment,
        'Data': DateTime.now().toUtc().toIso8601String(),
      }),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Falha ao criar avaliação: ${response.body}');
    }
  }

  // Users
  Future<User> getUser(String id) async {
    final response = await http.get(Uri.parse('$baseUrl/Usuario/$id'));

    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Falha ao carregar usuário');
    }
  }
}
