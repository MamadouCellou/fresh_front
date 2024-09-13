import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fresh_front/pages/home.dart';
import 'package:fresh_front/pages/login.dart';

class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(), // Écoute les changements d'état d'authentification
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator()); // Affiche un loader pendant la vérification
        } else if (snapshot.hasData) {
          final user = snapshot.data;
          // print("L'utilisateur : $user");
          return HomePage(); // Passe l'email à HomePage
        } else {
          return Login(); // Redirige vers la page de connexion si aucun utilisateur n'est connecté
        }
      },
    );
  }
}
