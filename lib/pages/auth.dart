import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fresh_front/pages/home.dart';
import 'package:fresh_front/pages/login.dart';

class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(), // Ecoute les changements d'état d'authentification
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator()); // Affiche un loader pendant la vérification
        } else if (snapshot.hasData) {
          return HomePage(); // Redirige vers la page d'accueil si l'utilisateur est connecté
        } else {
          return Login(); // Redirige vers la page de connexion si aucun utilisateur n'est connecté
        }
      },
    );
  }


}
