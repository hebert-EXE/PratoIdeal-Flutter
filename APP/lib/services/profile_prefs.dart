import 'package:shared_preferences/shared_preferences.dart';

/// Preferências locais do perfil (bio, data de nascimento, fundo escolhido),
/// como o `localStorage` do web. Não vão para o backend.
class ProfilePrefs {
  static const _bioKey = 'profile_bio';
  static const _dobKey = 'profile_dob';
  static const _bgKey = 'profile_bg';

  Future<String?> getBio() async =>
      (await SharedPreferences.getInstance()).getString(_bioKey);
  Future<void> setBio(String value) async =>
      (await SharedPreferences.getInstance()).setString(_bioKey, value);

  Future<String?> getDob() async =>
      (await SharedPreferences.getInstance()).getString(_dobKey);
  Future<void> setDob(String value) async =>
      (await SharedPreferences.getInstance()).setString(_dobKey, value);

  Future<String?> getBackground() async =>
      (await SharedPreferences.getInstance()).getString(_bgKey);
  Future<void> setBackground(String value) async =>
      (await SharedPreferences.getInstance()).setString(_bgKey, value);
}
