import 'package:flutter/material.dart';

/// Global controller for the app's current locale.
///
/// `main.dart` listens to [locale] (via ValueListenableBuilder) and rebuilds
/// the `MaterialApp` whenever it changes. Any widget (e.g. the language
/// switcher on the profile screen) can call [setLocale] to change it.
class LocaleController {
  LocaleController._();

  static final ValueNotifier<Locale> locale = ValueNotifier<Locale>(const Locale('kk'));

  static const List<Locale> supportedLocales = [
    Locale('kk'), // Қазақша
    Locale('ru'), // Орысша
    Locale('en'), // Ағылшынша
  ];

  static void setLocale(Locale newLocale) {
    if (!supportedLocales.contains(newLocale)) return;
    locale.value = newLocale;
  }
}