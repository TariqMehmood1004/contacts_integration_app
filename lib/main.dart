import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'screens/home_page.dart';
import 'utils/colors.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Contacts',
      themeMode: ThemeMode.light,
      theme: ThemeData(
        scaffoldBackgroundColor: colorWhite,
        primaryColor: colorPrimary,
        colorScheme: ColorScheme.fromSwatch().copyWith(
          secondary: colorSecondry,
          primary: colorPrimary,
          onPrimary: colorWhite,
          onSecondary: colorWhite,
          onBackground: colorBlack,
          background: colorWhite,
          onSurface: colorBlack,
          surface: colorWhite,
          error: colorOrange,
          onError: colorWhite,
        ),
        fontFamily: 'Poppins',
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: colorBlack, fontSize: 20),
          bodyMedium: TextStyle(color: colorBlack, fontSize: 16),
          bodySmall: TextStyle(color: colorBlack, fontSize: 14),
        ),
        iconTheme: const IconThemeData(color: colorBlack),
        useMaterial3: true,
      ),
      home: const HomePageScreen(title: 'Contacts'),
    );
  }
}
