import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/api_service.dart';

class UserProvider extends ChangeNotifier {
  User? _currentUser;
  final ApiService _apiService = ApiService();
  bool _isLoading = false;
  String? _token;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get token => _token;

  Future<void> login(String userId, String token) async {
    _isLoading = true;
    _token = token;
    notifyListeners();

    try {
      _currentUser = await _apiService.getUser(userId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  void logout() {
    _currentUser = null;
    _token = null;
    notifyListeners();
  }
}
