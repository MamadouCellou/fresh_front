import 'package:flutter/material.dart';
import 'package:fresh_front/constant/colors.dart';
import 'package:fresh_front/pages/compartiment_reclage_chaud.dart';
import 'package:fresh_front/pages/compartiment_reclage_froid.dart';
// Importer le package Lottie si vous utilisez des animations Lottie
import 'package:lottie/lottie.dart';

class ReclageSelectCompartiment extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:null,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Ajouter une image d'animation
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                    "Selectionnez un compartiment à regler",
                       style: TextStyle(
                        fontSize: 15,
                        color: greenColor,
                        fontWeight: FontWeight.bold
                       ),
                  ),
            ],
          ),
          Lottie.asset(
            'assets/animations/lottie_animation_2.json', // Chemin de l'animation Lottie
            width: 400, // Vous pouvez ajuster la taille selon vos besoins
            height: 350,
          ),
          const SizedBox(height: 10),
           Text(
            'Bienvenue au reglage de votre MANDAFRESH, avec nous vos aliments seront conservés à temps réel',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: blackColor,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Choisissez le compartiment à régler.',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: blackColor,
            ),
          ),
          const SizedBox(height: 10),
          // Ajouter le Row pour les boutons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PageCompartimentReclageFroid(),
                    ),
                  );
                },
                child: Text(
                  'Compartiment Froid',
                  style: TextStyle(
                    color: whiteColor,
                    fontSize: 15,
                    fontWeight: FontWeight.bold
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  foregroundColor: blackColor, // Couleur de fond
                  backgroundColor: greenColor, // Couleur du texte
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  textStyle: TextStyle(fontSize: 18),
                  side: BorderSide(color: greenColor), 
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PageCompartimentReclageChaud(),
                    ),
                  );
                },
                child:  Text(
                  'Compartiment Chaud',
                  style: TextStyle(
                    color: greenColor,
                    fontSize: 15,
                    fontWeight: FontWeight.bold
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.black, // Couleur de fond
                  backgroundColor: whiteColor, // Couleur du texte
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  textStyle: TextStyle(fontSize: 18),
                  side: BorderSide(color: greenColor), // Bordure verte
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20), // Espacement
          
        ],
      ),
    );
  }
}
