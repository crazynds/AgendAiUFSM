import 'package:flutter/cupertino.dart';

class AppController extends ChangeNotifier {
  static AppController instance = AppController();

  bool isDarkTheme = false;
  bool isLoading = false;
  changeTheme() {
    isDarkTheme = !isDarkTheme;
    notifyListeners();
  }

  setLoading(bool isLoading) {
    this.isLoading = isLoading;
    notifyListeners();
  }
}
