import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fresh_front/local/shared.dart';
import 'package:fresh_front/pages/login.dart';
import 'package:fresh_front/pages/modife_produit.dart';
import 'package:get/get.dart';

class AfficueProduit extends StatefulWidget {
  const AfficueProduit({super.key});

  @override
  State<AfficueProduit> createState() => _AfficueProduitState();
}

class _AfficueProduitState extends State<AfficueProduit> {
  File? _imageFile;

  TextStyle styleTitre = TextStyle(fontSize: 20, fontWeight: FontWeight.bold);
  TextStyle styleSousTitre = TextStyle(fontSize: 18);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text("Detail du produit frais", style: TextStyle(fontWeight: FontWeight.bold),),
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.only(left: 20, bottom: 20, right: 20),
          child: Column(
            children: [
              Container(
                height: 250,
                width: 230,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(),
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: AssetImage("assets/images/orange.png"),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: 10),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Color.fromRGBO(3, 75, 5, 1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '1',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              propieteProduit(
                titre: "Description",
                sousTitre: "Mon orange",
                paddingTop: 0,
                paddingBottom: 10,
              ),
              Divider(),
              propieteProduit(titre: "Prix du produit", sousTitre: "5 000 GNF"),
              Divider(),
              propieteProduit(titre: "Type d'aliment", sousTitre: "Orange"),
              Divider(),
              propieteProduit(
                  titre: "Durée de conservation", sousTitre: "22 Jours"),
              Divider(),
              propieteProduit(
                  titre: "Date d'ajout", sousTitre: "27-07-2002 à 12:25"),
              Divider(),
              propieteProduit(
                  titre: "Dernière modification", sousTitre: "Non modifié"),
            ],
          ),
        ),
        bottomSheet: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {
                  Get.to(ModifProduit());
                },
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all<Color>(Colors.green),
                  padding: WidgetStateProperty.all<EdgeInsets>(
                      EdgeInsets.symmetric(horizontal: 30, vertical: 15)),
                  shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                      side: BorderSide(color: Colors.greenAccent, width: 2),
                    ),
                  ),
                  shadowColor: WidgetStateProperty.all<Color>(
                      Colors.greenAccent.withOpacity(0.5)),
                  elevation: WidgetStateProperty.all<double>(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.edit, color: Colors.white),
                    SizedBox(width: 10),
                    Text(
                      "Modifier",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                icon: Icon(Icons.more_vert), // Icône 'more_vert'
                offset: Offset(60, -75),
                onSelected: (String value) {
                  if (value == 'Supprimer') {
                    // Logique pour supprimer l'élément
                    print("Supprimer l'élément");
                    // Ajoute ici la fonction de suppression
                  }
                },
                // position: PopupMenuPosition.over,
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                  PopupMenuItem<String>(
                    value: 'Supprimer',
                    onTap: () {
                      print("Produit supprimé");
                      
                       ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Produit modifié')));
                    
                    Get.back();
                    },
                    child: Text('Supprimer le produit', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 18),),
                  ),
                  // Ajoute d'autres options si nécessaire
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget propieteProduit({
    required String titre,
    required String sousTitre,
    double paddingTop = 2,
    double paddingBottom = 2,
    bool inversedStyle = false,
    bool inversedOrdre = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(top: paddingTop, bottom: paddingBottom),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(inversedOrdre ? sousTitre:
            titre,
            style: inversedStyle ? styleTitre : styleSousTitre,
          ),
          Text(inversedOrdre ? titre:
            sousTitre,
            style: inversedStyle ? styleSousTitre : styleTitre,
          ),
        ],
      ),
    );
  }
}
