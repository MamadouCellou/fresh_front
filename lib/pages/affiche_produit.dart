import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'package:fresh_front/local/shared.dart';
import 'package:fresh_front/pages/login.dart';
import 'package:fresh_front/pages/modife_produit.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class AfficueProduitFrais extends StatefulWidget {
  const AfficueProduitFrais({super.key});

  @override
  State<AfficueProduitFrais> createState() => _AfficueProduitFraisState();
}

class _AfficueProduitFraisState extends State<AfficueProduitFrais> {
  File? _imageFile;
  Stream<QuerySnapshot>?
      produitStream; // Stream pour les détails du produit basé sur le champ 'id'
  bool isLoading = true; // Indicateur de chargement

  TextStyle styleTitre = TextStyle(fontSize: 20, fontWeight: FontWeight.bold);
  TextStyle styleSousTitre = TextStyle(fontSize: 18);

  final args = Get.arguments;

  String? idProduit;

  @override
  void initState() {
    super.initState();

    idProduit = (args['id'] + 1).toString();

    print("Id produit : $idProduit");

    produitStream = FirebaseFirestore.instance
        .collection('ProduitsFrais')
        .where('id', isEqualTo: idProduit) // Requête basée sur le champ 'id'
        .snapshots(); // Écoute en temps réel

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text("Détail du produit frais",
              style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: produitStream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Erreur: ${snapshot.error}'));
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(child: Text('Aucun produit trouvé'));
            }

            // Supposons qu'il y a un seul document correspondant
            Map<String, dynamic> produitDetails =
                snapshot.data!.docs.first.data() as Map<String, dynamic>;

            return SingleChildScrollView(
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
                        image: produitDetails['image'] != null &&
                                produitDetails['image'].isNotEmpty
                            ? NetworkImage(produitDetails['image'])
                            : AssetImage("assets/images/pomme_noir.png")
                                as ImageProvider,
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
                          produitDetails['id'] ?? 'ID',
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
                    sousTitre:
                        produitDetails['description'] ?? 'Non disponible',
                  ),
                  Divider(),
                  propieteProduit(
                    titre: "Prix du produit",
                    sousTitre: "${produitDetails['prix'] ?? 'N/A'} GNF",
                  ),
                  Divider(),
                  propieteProduit(
                    titre: "Type d'aliment",
                    sousTitre:
                        produitDetails['specifique_frais'] ?? 'Non disponible',
                  ),
                  Divider(),
                  propieteProduit(
                    titre: "Date d'ajout",
                    sousTitre: produitDetails['cree_a'],
                  ),
                  Divider(),
                  propieteProduit(
                    titre: "Date modification",
                    sousTitre: produitDetails['modifie_a'],
                  ),
                ],
              ),
            );
          },
        ),
        bottomSheet: _buildBottomSheet(),
      ),
    );
  }

  Widget _buildBottomSheet() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ElevatedButton(
            onPressed: () {
              Get.to(arguments: {'id': args['id']}, ModifProduitFrais());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
                side: BorderSide(color: Colors.greenAccent, width: 2),
              ),
              shadowColor: Colors.greenAccent.withOpacity(0.5),
              elevation: 10,
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
            icon: Icon(Icons.more_vert),
            offset: Offset(60, -75),
            onSelected: (String value) {
              if (value == 'Supprimer') {
                print("Supprimer l'élément");
                // Ajoute ici la fonction de suppression
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              PopupMenuItem<String>(
                value: 'Supprimer',
                onTap: () {
                  showDeleteConfirmationDialog(idProduit!);
                },
                child: Text(
                  'Supprimer le produit',
                  style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 18),
                ),
              ),
            ],
          ),
        ],
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
          Text(
            inversedOrdre ? sousTitre : titre,
            style: inversedStyle ? styleTitre : styleSousTitre,
          ),
          Text(
            inversedOrdre ? titre : sousTitre,
            style: inversedStyle ? styleSousTitre : styleTitre,
          ),
        ],
      ),
    );
  }

  String formatDate(dynamic date) {
    if (date == null || date == "") return 'Non modifié';

    if (date is Timestamp) {
      final DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm');
      return formatter.format(date.toDate());
    } else if (date is String) {
      return date;
    } else {
      return 'Date invalide';
    }
  }

  Future<void> deleteProduct(String productId) async {
    try {
      // Supprimer le document où le champ 'id' correspond à 'productId'
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('ProduitsFrais')
          .where('id', isEqualTo: productId)
          .get();

      if (snapshot.docs.isNotEmpty) {
        // Supposons qu'il y a un seul document correspondant
        DocumentReference docRef = snapshot.docs.first.reference;
        await docRef.delete();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Produit $productId supprimé avec succès')),
        );
        Get.back();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Aucun produit trouvé pour cet ID')),
        );
      }
    } catch (e) {
      print("Erreur lors de la suppression du produit: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la suppression du produit')),
      );
    }
  }

  void showDeleteConfirmationDialog(String productId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmer la suppression'),
          content: Text('Êtes-vous sûr de vouloir supprimer ce produit ?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Fermer la boîte de dialogue
              },
              child: Text('Annuler'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Fermer la boîte de dialogue
                deleteProduct(productId); // Appel de la méthode de suppression
              },
              child: Text('Supprimer'),
            ),
          ],
        );
      },
    );
  }
}
