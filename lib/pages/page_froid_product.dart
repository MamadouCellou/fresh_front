import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fresh_front/constant/colors.dart';
import 'package:fresh_front/pages/affiche_produit.dart';
import 'package:fresh_front/pages/affiche_produit_chaud.dart';
import 'package:fresh_front/pages/ajout_produit_frais.dart';
import 'package:fresh_front/pages/modife_produit.dart';
import 'package:fresh_front/widget/card_widget.dart';
import 'package:fresh_front/widget/numero_produit.dart';
import 'package:get/get.dart';

class PageFroidProduct extends StatefulWidget {
  @override
  _PageFroidProductState createState() => _PageFroidProductState();
}

class _PageFroidProductState extends State<PageFroidProduct> {
  bool _isExpandedFroidProduits = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance.collection('ProduitsFrais').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
                child: Text('Erreur lors de la récupération des produits'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('Aucun produit trouvé'));
          }

          // Convertir les données en une liste de produits
          List<Map<String, dynamic>> produits = List.generate(
            12,
            (index) => {
              'id': (index + 1).toString(),
              'image': '',
              'description': 'Non présent',
            },
          );

          for (var doc in snapshot.data!.docs) {
            final data = doc.data() as Map<String, dynamic>;
            int id = int.parse(data['id']);

            if (id > 0 && id <= 12) {
              produits[id - 1] = {
                'id': data['id'],
                'image': data[
                    'image'], // Assurez-vous que l'image est bien référencée
                'description': data['description'],
              };
            }
          }

          return SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "Compartiment Froid",
                      style: TextStyle(
                        fontSize: 20,
                        color: greenColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                const CardWidget(
                  height: 100,
                  width: 200,
                  temperature: "30",
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
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 15,
                ),
                _buildAnimatedContainer(
                  _isExpandedFroidProduits,
                  _buildProduitGrid(produits),
                ),
              ],
            ),
          );
        },
      ),
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

  Widget _buildProduitGrid(List<Map<String, dynamic>> produits) {
    return GridView.builder(
      itemCount: produits.length,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisSpacing: 5,
        mainAxisSpacing: 5,
        crossAxisCount: 3,
        childAspectRatio: 1.0,
      ),
      itemBuilder: (context, index) {
        final produit = produits[index];
        String image = produit['image'] ?? ''; // Récupérer le chemin de l'image

        final isPresent = produit['description'] != "Non présent";

        // Vérification du chemin de l'image. Utilisez une image par défaut si vide ou non trouvée.
        if (image.isEmpty) {
          image =
              'assets/images/pomme_noir.png'; // Chemin de l'image par défaut
        }

        return GestureDetector(
          onTap: () {
            // Gérer l'affichage du produit
            isPresent
                ? Get.to(arguments: {'id': index}, (AfficueProduitFrais()))
                : ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(
                            "Cette cellule ne contient aucun produit, veillez-en ajouter")),
                  );
          },
          onLongPress: () {
            // Passer la liste des produits à la fonction
            _showProductOptionsDialog(context, index, produits);
          },
          child: CelluleProduitsWidget(
            index: index + 1,
            imagePath: image,
            description: produit['description'] ?? 'Non présent',
          ),
        );
      },
    );
  }

  void _showProductOptionsDialog(
      BuildContext context, int index, List<Map<String, dynamic>> produits) {
    final produit = produits[index]; // Récupérer le produit à l'index spécifié
    final isPresent = produit['description'] != "Non présent";

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Produit ${index + 1}"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Fermer la boîte de dialogue

                  isPresent
                      ? Get.to(arguments: {'id': index}, ModifProduitFrais())
                      : Get.to(arguments: {'id': index}, AjoutProduitFrais());
                },
                child: Text(isPresent ? 'Modifier' : 'Ajouter'),
              ),
              isPresent
                  ? TextButton(
                      onPressed: () {
                        Navigator.of(context)
                            .pop(); // Fermer la boîte de dialogue
                        showDeleteConfirmationDialog((index + 1).toString());
                      },
                      child: Text('Supprimer'),
                    )
                  : SizedBox()
            ],
          ),
        );
      },
    );
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
        // Optionnel: Retourner à la page précédente ou rafraîchir la vue
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
