import 'package:fresh_front/pages/home.dart';
import 'package:fresh_front/pages/login.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<bool> isUserLoggedIn() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  // Vérifiez si la clé 'isLoggedIn' existe et est true
  return prefs.getBool('isLoggedIn') ?? false;
}

Future<void> loginUser() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setBool('isLoggedIn', true);

  // Redirigez vers la page d'accueil après la connexion réussie
  Get.to(HomePage());
}

Future<void> logoutUser() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setBool('isLoggedIn', false);

  // Redirigez vers la page de connexion après la déconnexion
  Get.to(Login());
}