import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../models/restaurant.dart';
import '../models/user.dart';
import '../models/review.dart';
import '../models/place_models.dart';

class ApiService {
  static const String baseUrl = AppConfig.apiBaseUrl;

  /// Extrai o token JWT de respostas que podem vir como string crua ou
  /// como objeto `{ token | Token }`.
  static String? _extractToken(dynamic body) {
    if (body is String) {
      final trimmed = body.trim();
      // String JSON simples ("token") ou token cru.
      if (trimmed.startsWith('{')) {
        return _extractToken(jsonDecode(trimmed));
      }
      return trimmed.isEmpty ? null : trimmed;
    }
    if (body is Map<String, dynamic>) {
      final t = body['token'] ?? body['Token'] ?? body['accessToken'];
      return t?.toString();
    }
    return null;
  }

  // Auth
  /// Login por email/senha. Retorna o token JWT.
  Future<String> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/Usuario/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'Email': email, 'Senha': password}),
    );

    if (response.statusCode == 200) {
      final token = _extractToken(response.body);
      if (token == null) {
        throw Exception('Login: token não retornado pela API.');
      }
      return token;
    } else {
      throw Exception('Falha no login: ${response.body}');
    }
  }

  /// Login via Google: troca o `idToken` do Google por um JWT do backend.
  Future<String> loginWithGoogle(String idToken) async {
    final response = await http.post(
      Uri.parse('$baseUrl/Usuario/login/google'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'IdToken': idToken}),
    );

    if (response.statusCode == 200) {
      final token = _extractToken(response.body);
      if (token == null) {
        throw Exception('Login Google: token não retornado pela API.');
      }
      return token;
    } else {
      throw Exception('Falha no login com Google: ${response.body}');
    }
  }

  Future<void> register(String name, String email, String password) async {
    // O endpoint de cadastro espera chaves minúsculas (igual ao web).
    final response = await http.post(
      Uri.parse('$baseUrl/Usuario/cadastro'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'nome': name, 'email': email, 'senha': password}),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
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
        final map = item as Map<String, dynamic>;
        final category = map['Categoria'] ?? map['categoria'];
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

  /// Avaliações de um restaurante mapeadas para [ReviewItem] (UI).
  /// O GET da API não retorna o nome do usuário (igual ao web).
  Future<List<ReviewItem>> getReviewItems(String restaurantId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/Review/restaurante/$restaurantId'),
    );
    if (response.statusCode != 200) {
      throw Exception('Falha ao carregar avaliações');
    }
    final data = jsonDecode(response.body) as List<dynamic>;
    return data.map((raw) {
      final r = raw as Map<String, dynamic>;
      final rawDate = (r['Data'] ?? r['data'])?.toString();
      String date = '';
      if (rawDate != null) {
        final parsed = DateTime.tryParse(rawDate);
        if (parsed != null) {
          date =
              '${parsed.day.toString().padLeft(2, '0')}/${parsed.month.toString().padLeft(2, '0')}/${parsed.year}';
        }
      }
      final fotos = (r['Fotos'] ?? r['fotos']);
      return ReviewItem(
        id: (r['Id'] ?? r['id'] ?? '').toString(),
        userName: 'Membro da Comunidade',
        rating: (r['Nota'] ?? r['nota'] ?? 0) is num
            ? (r['Nota'] ?? r['nota'] ?? 0).toInt()
            : 0,
        comment: (r['Comentario'] ?? r['comentario'] ?? '').toString(),
        date: date,
        restaurantId: (r['IdRestaurante'] ?? r['idRestaurante'])?.toString(),
        photos: fotos is List ? fotos.map((e) => e.toString()).toList() : const [],
      );
    }).toList();
  }

  /// Cria avaliação com fotos (multipart), espelhando o POST `/Review` do web.
  Future<void> createReviewWithPhotos({
    required String restaurantId,
    required String restaurantName,
    required int rating,
    required String comment,
    required String token,
    List<String> photoPaths = const [],
  }) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/Review'),
    )
      ..headers['Authorization'] = 'Bearer $token'
      ..fields['IdRestaurante'] = restaurantId
      ..fields['NomeRestaurante'] = restaurantName
      ..fields['Nota'] = rating.clamp(0, 5).toString()
      ..fields['Comentario'] = comment
      ..fields['Data'] = DateTime.now().toUtc().toIso8601String();

    for (final path in photoPaths) {
      request.files.add(await http.MultipartFile.fromPath('Fotos', path));
    }

    final streamed = await request.send();
    final status = streamed.statusCode;
    // 400 é tolerado pelo web (fallback local); demais erros (exceto 2xx) lançam.
    if (status != 200 && status != 201 && status != 400) {
      final body = await streamed.stream.bytesToString();
      throw Exception('Falha ao criar avaliação: $body');
    }
  }

  // Favoritos
  Future<void> addFavorite(String placeId, String token) async {
    final response = await http.post(
      Uri.parse('$baseUrl/Usuario/favoritos/$placeId'),
      headers: {'Authorization': 'Bearer $token'},
    );
    // 409 = já existe → considera sucesso (como o web).
    if (response.statusCode == 409) return;
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Falha ao favoritar: ${response.body}');
    }
  }

  Future<void> removeFavorite(String placeId, String token) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/Usuario/favoritos/$placeId'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Falha ao remover favorito: ${response.body}');
    }
  }

  /// Avaliações do usuário autenticado (`GET /Review/usuario`).
  Future<List<ReviewItem>> getUserReviews(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/Review/usuario'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode != 200) {
      throw Exception('Falha ao carregar avaliações do usuário');
    }
    final data = jsonDecode(response.body) as List<dynamic>;
    return data.map((raw) {
      final r = raw as Map<String, dynamic>;
      return ReviewItem(
        id: (r['Id'] ?? r['id'] ?? '').toString(),
        userName: 'Você',
        rating: (r['Nota'] ?? r['nota'] ?? 0) is num
            ? (r['Nota'] ?? r['nota'] ?? 0).toInt()
            : 0,
        comment: (r['Comentario'] ?? r['comentario'] ?? '').toString(),
        date: '',
        restaurantId: (r['IdRestaurante'] ?? r['idRestaurante'])?.toString(),
        restaurantName:
            (r['NomeRestaurante'] ?? r['nomeRestaurante'])?.toString() ??
                'Restaurante avaliado',
      );
    }).toList();
  }

  /// Atualiza a foto de perfil (`PUT /Usuario/foto`, multipart `foto`).
  Future<void> updateUserPhoto(String photoPath, String token) async {
    final request = http.MultipartRequest(
      'PUT',
      Uri.parse('$baseUrl/Usuario/foto'),
    )
      ..headers['Authorization'] = 'Bearer $token'
      ..files.add(await http.MultipartFile.fromPath('foto', photoPath));

    final streamed = await request.send();
    if (streamed.statusCode != 200 && streamed.statusCode != 201) {
      final body = await streamed.stream.bytesToString();
      throw Exception('Falha ao atualizar foto: $body');
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
