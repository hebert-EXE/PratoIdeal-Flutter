import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Preferências de acessibilidade, portadas do `useAccessibility` do web:
/// alto contraste, tamanho de fonte, texto em negrito, espaçamento (dislexia)
/// e redução de movimento. Persistidas em shared_preferences.
class AccessibilityProvider extends ChangeNotifier {
  static const _kContrast = 'a11y_contrast';
  static const _kFontScale = 'a11y_font_scale';
  static const _kBold = 'a11y_bold';
  static const _kDyslexia = 'a11y_dyslexia';
  static const _kReduceMotion = 'a11y_reduce_motion';

  bool _highContrast = false;
  double _fontScale = 1.0;
  bool _boldText = false;
  bool _dyslexiaFriendly = false;
  bool _reduceMotion = false;

  bool get highContrast => _highContrast;
  double get fontScale => _fontScale;
  bool get boldText => _boldText;
  bool get dyslexiaFriendly => _dyslexiaFriendly;
  bool get reduceMotion => _reduceMotion;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _highContrast = prefs.getBool(_kContrast) ?? false;
    _fontScale = prefs.getDouble(_kFontScale) ?? 1.0;
    _boldText = prefs.getBool(_kBold) ?? false;
    _dyslexiaFriendly = prefs.getBool(_kDyslexia) ?? false;
    _reduceMotion = prefs.getBool(_kReduceMotion) ?? false;
    notifyListeners();
  }

  Future<void> setHighContrast(bool v) => _setBool(_kContrast, v, () => _highContrast = v);
  Future<void> setBoldText(bool v) => _setBool(_kBold, v, () => _boldText = v);
  Future<void> setDyslexiaFriendly(bool v) =>
      _setBool(_kDyslexia, v, () => _dyslexiaFriendly = v);
  Future<void> setReduceMotion(bool v) =>
      _setBool(_kReduceMotion, v, () => _reduceMotion = v);

  Future<void> setFontScale(double v) async {
    _fontScale = v.clamp(0.8, 1.6);
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_kFontScale, _fontScale);
  }

  Future<void> _setBool(String key, bool v, VoidCallback apply) async {
    apply();
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, v);
  }
}
