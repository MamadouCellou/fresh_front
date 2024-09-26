import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:fresh_front/constant/colors.dart';
import 'package:fresh_front/pages/auth.dart';
import 'package:fresh_front/pages/onboarding.dart';
import 'package:flutter/material.dart';
import 'package:fresh_front/services/notifications_service.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await FirebaseAppCheck.instance.activate(
    webProvider: ReCaptchaV3Provider('recaptcha-v3-site-key'),
    androidProvider: AndroidProvider.debug,
    appleProvider: AppleProvider.appAttest,
  );

  // Initialisation du service de notification
  NotificationService notificationService = NotificationService();
  await notificationService.initNotification();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool launched = true; // Initialiser à 'true' par défaut

  @override
  void initState() {
    super.initState();

    checkUse(); // Appeler une méthode asynchrone
  }

  // Vérifie si c'est le premier lancement de l'application
  void checkUse() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isFirstLaunch = prefs.getBool('launched') ?? false;
    if (!isFirstLaunch) {
      await prefs.setBool('launched', true);
    }
    setState(() {
      launched = isFirstLaunch; // Met à jour l'état après la récupération
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'App MandaSmart',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          selectedItemColor: greenColor,
          unselectedItemColor: greyColor,
          selectedLabelStyle: TextStyle(color: greenColor),
          unselectedLabelStyle: TextStyle(color: greyColor),
        ),
      ),
      home: launched
          ? AuthWrapper()
          : WelcomeScreen(), // Redirige vers la page appropriée
    );
  }
}
