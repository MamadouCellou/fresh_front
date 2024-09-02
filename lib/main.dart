import 'package:fresh_front/constant/colors.dart';
import 'package:fresh_front/pages/onboarding.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'App MandaFresh',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // bottomSheetTheme: BottomSheetThemeData(backgroundColor: Colors.transparent),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          selectedItemColor:
              greenColor, // Couleur des icônes et labels sélectionnés
          unselectedItemColor:
              greyColor, // Couleur des icônes et labels non sélectionnés
          selectedLabelStyle: TextStyle(color: greenColor),
          unselectedLabelStyle: TextStyle(color: greyColor),
        ),
      ),
      home: WelcomeScreen(),
    );
  }
}
