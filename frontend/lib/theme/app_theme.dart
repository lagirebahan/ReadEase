import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum BgMode {light, dark, amoled}

class AppTheme extends ChangeNotifier {
  double _fontSize = 14.0;
  String _fontFamily = 'Default';
  Color _accentColor = Colors.deepPurple;
  BgMode _bgMode = BgMode.light;
  bool _useAccentForText = false;
  double _letterSpacing = 0.0;

  double get fontSize => _fontSize;
  String get fontFamily => _fontFamily;
  Color get accentColor => _accentColor;
  BgMode get bgMode => _bgMode;
  bool get useAccentForText => _useAccentForText;
  double get letterSpacing => _letterSpacing;

  Color get baseBg => _bgMode == BgMode.light
    ? const Color(0xFFF0F0F5)
    : _bgMode == BgMode.amoled
      ? Colors.black
      : const Color(0xFF0D0D1A);

  Color get surfaceBg => _bgMode == BgMode.light
    ? const Color(0xFFFFFFFF)
    : _bgMode == BgMode.amoled
      ? const Color(0xFF0A0A0A)
      : const Color(0xFF1A1A2E);

  Color get borderColor => _bgMode == BgMode.light
    ? const Color(0xFFDDDDE8)
    : _bgMode == BgMode.amoled
      ? const Color(0xFF1A1A1A)
      : const Color(0xFF2A2A4A);

  Color get primaryTextColor =>
      _bgMode == BgMode.light ? const Color(0xFF0D0D1A) : Colors.white;

  TextStyle baseTextStyle(Color color) => TextStyle(
        fontSize: _fontSize,
        fontFamily: _fontFamily == 'Default' ? null : _fontFamily,
        color: color,
        letterSpacing: _letterSpacing,
      );

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _fontSize = prefs.getDouble('theme_fontSize') ?? 14.0;
    _fontFamily = prefs.getString('theme_fontFamily') ?? 'Default';
    _accentColor = Color(prefs.getInt('theme_accentColor') ?? Colors.deepPurple.value);
    final modeIndex = prefs.getInt('theme_bgMode') ?? 0;
    _bgMode = BgMode.values[modeIndex];
    _useAccentForText = prefs.getBool('theme_useAccentForText') ?? false;
    _letterSpacing = prefs.getDouble('theme_letterSpacing') ?? 0.0;
    notifyListeners();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('theme_fontSize', _fontSize);
    await prefs.setString('theme_fontFamily', _fontFamily);
    await prefs.setInt('theme_accentColor', _accentColor.value);
    await prefs.setInt('theme_bgMode', _bgMode.index);
    await prefs.setBool('theme_useAccentForText', _useAccentForText);
    await prefs.setDouble('theme_letterSpacing', _letterSpacing);
  }

  void setBgMode(BgMode mode) {
    _bgMode = mode;
    notifyListeners();
    _save();
  }

  void setFontSize(double v) {
    _fontSize = v;
    notifyListeners();
    _save();
  }

  void setFontFamily(String v) {
    _fontFamily = v;
    notifyListeners();
    _save();
  }

  void setAccentColor(Color v) {
    _accentColor = v;
    notifyListeners();
    _save();
  }

  void setUseAccentForText(bool v) {
    _useAccentForText = v;
    notifyListeners();
    _save();
  }

  void setLetterSpacing(double v) {
    _letterSpacing = v;
    notifyListeners();
    _save();
  }

  Future<void> reset() async {
    _fontSize = 14.0;
    _fontFamily = 'Default';
    _accentColor = Colors.deepPurple;
    _bgMode = BgMode.light;
    _useAccentForText = false;
    _letterSpacing = 0.0;
    notifyListeners();
    _save();
  }
}