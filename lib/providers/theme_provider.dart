import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode mode = ThemeMode.light;
  ThemeProvider(){ _load(); }
  Future<void> _load() async { final p=await SharedPreferences.getInstance(); final v=p.getString('theme_mode'); if(v=='dark') mode=ThemeMode.dark; notifyListeners(); }
  Future<void> toggle(bool isDark) async { mode=isDark?ThemeMode.dark:ThemeMode.light; notifyListeners(); final p=await SharedPreferences.getInstance(); await p.setString('theme_mode', isDark?'dark':'light'); }
}
