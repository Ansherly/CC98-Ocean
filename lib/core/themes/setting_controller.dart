
import 'package:cc98_ocean/core/constants/color_tokens.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

///全局设置管理
class AppState extends ChangeNotifier{
  static const String _kTheme = 'theme';
  static const String _kThemeColor = 'theme_color';
  static const String _kUseTail="tail";
  static const String _kUserId="user_id";
  int _themeMode = 0; // 0: system, 1: light, 2: dark
  Color _primaryColor = ColorTokens.softPurple;
  bool _useTail=false;

  /// 当前登录用户 ID。用于比对某主页是否为自己的空间（0 表示未缓存）。
  int _userId = 0;

  AppState() {
    _loadFromPrefs();
  }

  int get themeMode => _themeMode;
  Color get primaryColor => _primaryColor;
  bool get useTail=>_useTail;
  int get userId => _userId;

  ThemeMode get themeModeEnum {
    return _themeMode == 1
        ? ThemeMode.light
        : (_themeMode == 2 ? ThemeMode.dark : ThemeMode.system);
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    _themeMode = prefs.getInt(_kTheme) ?? 0;
    final int? colorVal = prefs.getInt(_kThemeColor);
    if (colorVal != null) {
      _primaryColor = Color(colorVal);
    }
    final bool? useTail=prefs.getBool(_kUseTail);
    if(useTail!=null){
      _useTail=useTail;
    }
    _userId = prefs.getInt(_kUserId) ?? 0;
    notifyListeners();
  }

  /// 记录当前登录用户 ID（用于比对"是否他人空间"）。
  Future<void> setUserId(int id) async {
    if (id <= 0 || id == _userId) return;
    _userId = id;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kUserId, id);
    notifyListeners();
  }

  Future<void> setThemeMode(int mode) async {
    _themeMode = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kTheme, mode);
    notifyListeners();
  }

  Future<void> setPrimaryColor(Color color) async {
    _primaryColor = color;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kThemeColor, color.value);
    notifyListeners();
  }

  Future<void> setTailMode(bool newValue)async{
    _useTail=newValue;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kUseTail, newValue);
    notifyListeners();
  }
}