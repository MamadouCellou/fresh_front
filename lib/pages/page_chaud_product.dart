import 'package:flutter/material.dart';
import 'package:fresh_front/constant/colors.dart';
import 'package:fresh_front/widget/card_widget.dart';

class PageChaudProduct extends StatefulWidget {
  @override
  _PageChaudProductState createState() => _PageChaudProductState();
}

class _PageChaudProductState extends State<PageChaudProduct> {
  bool _isExpandedChaudProduits = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "Compartiment Chaud",
                      style: TextStyle(
                          fontSize: 20,
                          color: greenColor,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                const CardWidget(
                  height: 100,
                  width: 200,
                  temperature: "50",
                  title: "Temperature actuelle",
                ),
                const SizedBox(
                  height: 15,
                ),
                Row(
                  children: [
                    Text(
                      "La liste des produits",
                      style: TextStyle(
                          fontSize: 15,
                          color: blackColor,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 15,
                ),
                _buildAnimatedContainer(
                  _isExpandedChaudProduits,
                  Column(
                    children: [
                      produitChaud(
                        titre: "Ma mangue à sécher",
                        sousTitre: "Mangue",
                        image: "assets/images/mangue_1.png",
                        dateHeureFin: "15:30",
                      ),
                      SizedBox(height: 10),
                      produitChaud(
                        titre: "Ma banane à sécher",
                        sousTitre: "Banane",
                        image: "assets/images/banane.png",
                        dateHeureFin: "10:30",
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
        ],
      ),
      floatingActionButton: SizedBox(
              width: 100.0, // Largeur du bouton flottant
              child: FloatingActionButton.extended(
                onPressed: () {
                  // Action à réaliser lorsque le bouton flottant est pressé
                },
                backgroundColor: greenColor,
                label: Text('Ajouter', style: TextStyle(color: whiteColor),),
                icon: Icon(Icons.add, color: whiteColor,), // Icône sur le bouton flottant
              ),
            ),
    );
  }

  Widget _buildTemperatureRow(String label, String temperature) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        ),
        Row(
          children: [
            Icon(Icons.thermostat),
            Text(
              temperature,
              style: TextStyle(fontSize: 15),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAnimatedContainer(bool isExpanded, Widget content) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      height: isExpanded ? null : 0,
      child: SingleChildScrollView(
        child: content,
      ),
    );
  }

  Widget produitChaud(
      {required String titre,
      required String sousTitre,
      required String image,
      required String dateHeureFin}) {
    return GestureDetector(
      onTap: () {
        // Gérer l'affichage du produit
      },
      child: Container(
        decoration: BoxDecoration(
            border: Border.all(color: Colors.green),
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(15)),
        child: ListTile(
          title: Text(
            titre,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          subtitle: Text(sousTitre),
          leading: Container(
            height: 70,
            width: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(
                fit: BoxFit.cover,
                image: AssetImage(image),
              ),
            ),
          ),
          trailing: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Color.fromRGBO(3, 75, 5, 1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                dateHeureFin,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
