import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fresh_front/pages/modife_produit.dart';
import 'package:get/get.dart';

class AfficueProduitChaud extends StatefulWidget {
  const AfficueProduitChaud({super.key});

  @override
  State<AfficueProduitChaud> createState() => _AfficueProduitChaudState();
}

class _AfficueProduitChaudState extends State<AfficueProduitChaud> {
  File? _imageFile;
  String produitId = '';
  String typeAliment = 'Chargement...';
  String dateSechage = 'Chargement...';

  TextStyle styleTitre = TextStyle(fontSize: 20, fontWeight: FontWeight.bold);
  TextStyle styleSousTitre = TextStyle(fontSize: 18);

  @override
  void initState() {
    super.initState();
    produitId = Get.arguments['id'] ?? '';
  }

  Stream<DocumentSnapshot> _getProductStream(String id) {
    return FirebaseFirestore.instance
        .collection('ProduitsChauds')
        .doc(id)
        .snapshots();
  }

  Stream<QuerySnapshot> _getSpecificDetailsStream(String specificId) {
    return FirebaseFirestore.instance
        .collection('SpecifiqueProduitChaud')
        .where('id', isEqualTo: specificId)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text("Détail du produit chaud",
              style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        body: StreamBuilder<DocumentSnapshot>(
          stream: _getProductStream(produitId),
          builder: (context, produitSnapshot) {
            if (produitSnapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            if (!produitSnapshot.hasData || produitSnapshot.data == null) {
              return Center(child: Text("Produit non disponible"));
            }

            var produit = produitSnapshot.data!.data() as Map<String, dynamic>?;
            var specificId = produit?['specifique_chaud'] ?? '';

            return StreamBuilder<QuerySnapshot>(
              stream: _getSpecificDetailsStream(specificId),
              builder: (context, specificSnapshot) {
                if (specificSnapshot.connectionState ==
                    ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (!specificSnapshot.hasData ||
                    specificSnapshot.data!.docs.isEmpty) {
                  return Center(
                      child: Text("Détails spécifiques non disponibles"));
                }

                // On récupère le premier document correspondant à l'ID
                var specificDetails = specificSnapshot.data!.docs.first.data()
                    as Map<String, dynamic>;

                String typeAliment = specificDetails['nom'] ?? 'Non disponible';
                String dateSechage =
                    specificDetails['dure'] ?? 'Non disponible';

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
                            image: produit?['image'] != null
                                ? NetworkImage(produit!['image'])
                                : AssetImage('assets/images/default_image.png') as ImageProvider,
                          ),
                        ),
                      ),
                      propieteProduit(
                        titre: "Description",
                        sousTitre: produit?['description'] ?? 'Non disponible',
                        paddingTop: 10,
                        paddingBottom: 0,
                      ),
                      // ... Les widgets pour afficher les détails du produit
                      propieteProduit(
                          titre: "Type d'aliment", sousTitre: typeAliment),
                      Divider(),
                      propieteProduit(
                          titre: "Date de séchage dans",
                          sousTitre: "$dateSechage heures"),
                          Divider(),
                      propieteProduit(
                        titre: "Date d'ajout",
                        sousTitre: produit?['cree_a'],
                      ),
                      Divider(),
                      propieteProduit(
                        titre: "Date modification",
                        sousTitre: produit?['modifie_a'],
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
        bottomSheet: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {
                  Get.to(ModifProduitFrais(), arguments: {'id': produitId});
                },
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all<Color>(Colors.green),
                  padding: MaterialStateProperty.all<EdgeInsets>(
                      EdgeInsets.symmetric(horizontal: 30, vertical: 15)),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                      side: BorderSide(color: Colors.greenAccent, width: 2),
                    ),
                  ),
                  shadowColor: MaterialStateProperty.all<Color>(
                      Colors.greenAccent.withOpacity(0.5)),
                  elevation: MaterialStateProperty.all<double>(10),
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
                    _deleteProduct();
                  }
                },
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                  PopupMenuItem<String>(
                    value: 'Supprimer',
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
        ),
      ),
    );
  }

  String _formatDate(Timestamp? timestamp) {
    if (timestamp == null) return 'Non disponible';
    DateTime date = timestamp.toDate();
    return '${date.day}-${date.month}-${date.year} à ${date.hour}:${date.minute}';
  }

  void _deleteProduct() async {
    try {
      await FirebaseFirestore.instance
          .collection('ProduitsChauds')
          .doc(produitId)
          .delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Produit supprimé avec succès')),
      );
      Get.back(); // Retourner à la page précédente après la suppression
    } catch (e) {
      print("Erreur lors de la suppression du produit: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la suppression du produit')),
      );
    }
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
            style: inversedOrdre ? styleSousTitre : styleTitre,
          ),
        ],
      ),
    );
  }
}
