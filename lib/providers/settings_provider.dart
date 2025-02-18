import 'package:flutter/material.dart';

class SettingsProvider with ChangeNotifier {
  bool _darkMode = false;
  String _language = 'hr';
  String _currency = 'EUR';

  bool get darkMode => _darkMode;
  String get language => _language;
  String get currency => _currency;

  void setDarkMode(bool value) {
    _darkMode = value;
    notifyListeners();
  }

  void setLanguage(String value) {
    _language = value;
    notifyListeners();
  }

  void setCurrency(String value) {
    _currency = value;
    notifyListeners();
  }
}