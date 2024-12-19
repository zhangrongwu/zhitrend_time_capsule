import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ThemeProvider with ChangeNotifier {
  static const String _themeKey = 'app_theme_mode';
  static const String _primaryColorKey = 'app_primary_color';
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  ThemeMode _currentThemeMode = ThemeMode.system;
  Color _primaryColor = const Color(0xFF6A5ACD);

  ThemeMode get currentThemeMode => _currentThemeMode;
  Color get primaryColor => _primaryColor;

  ThemeProvider() {
    _loadThemeFromStorage();
  }

  Future<void> _loadThemeFromStorage() async {
    final storedTheme = await _secureStorage.read(key: _themeKey);
    final storedPrimaryColor = await _secureStorage.read(key: _primaryColorKey);

    if (storedTheme != null) {
      switch (storedTheme) {
        case 'light':
          _currentThemeMode = ThemeMode.light;
          break;
        case 'dark':
          _currentThemeMode = ThemeMode.dark;
          break;
        default:
          _currentThemeMode = ThemeMode.system;
      }
    }

    if (storedPrimaryColor != null) {
      _primaryColor = Color(int.parse(storedPrimaryColor));
    }

    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode themeMode) async {
    _currentThemeMode = themeMode;
    
    String themeString;
    switch (themeMode) {
      case ThemeMode.light:
        themeString = 'light';
        break;
      case ThemeMode.dark:
        themeString = 'dark';
        break;
      default:
        themeString = 'system';
    }
    
    await _secureStorage.write(key: _themeKey, value: themeString);
    notifyListeners();
  }

  Future<void> setPrimaryColor(Color color) async {
    _primaryColor = color;
    await _secureStorage.write(
      key: _primaryColorKey, 
      value: color.value.toString()
    );
    notifyListeners();
  }

  // 预定义的颜色调色板
  static final List<Color> colorPalette = [
    const Color(0xFF6A5ACD),   // 原始紫色
    const Color(0xFFFF6B6B),   // 珊瑚红
    const Color(0xFF8A4FFF),   // 亮紫色
    Colors.blue,               // 蓝色
    Colors.green,              // 绿色
    Colors.purple,             // 紫色
    Colors.teal,               // 蓝绿色
    Colors.orange,             // 橙色
  ];

  // 自定义文本样式
  TextStyle get headingStyle => TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: _primaryColor,
  );

  TextStyle get subtitleStyle => TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: _primaryColor.withOpacity(0.7),
  );
}
