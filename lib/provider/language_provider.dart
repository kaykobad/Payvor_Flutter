
import 'package:flutter/material.dart';
import 'package:payvor/utils/memory_management.dart';





class LanguageProvider extends ChangeNotifier {
  // shared pref object

  Locale _appLocale = Locale('en');



  Locale get appLocale {
    var localeValue= MemoryManagement.appLocale;
    if (localeValue != null) {
    _appLocale = Locale(localeValue);
    }
    return _appLocale;
  }

  void updateLanguage(String languageCode) {
    if (languageCode == "zh") {
      _appLocale = Locale("zh");
    } else {
      _appLocale = Locale("en");
    }

    MemoryManagement.changeLanguage(languageCode);
    notifyListeners();
  }
}
