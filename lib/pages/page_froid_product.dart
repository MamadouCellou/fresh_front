import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fresh_front/constant/colors.dart';
import 'package:fresh_front/pages/affiche_produit.dart';
import 'package:fresh_front/pages/ajout_produit_frais.dart';
import 'package:fresh_front/pages/modife_produit.dart';
import 'package:fresh_front/services/service_mqtt.dart';
import 'package:fresh_front/widget/card_widget.dart';
import 'package:get/get.dart';

class PageFroidProduct extends StatefulWidget {
  @override
  _PageFroidProductState createState() => _PageFroidProductState();
}

class _PageFroidProductState extends State<PageFroidProduct> {
  bool _isExpandedFraisProduits = true;

  Stream<List<Map<String, dynamic>>> _getProduitsAndCategoriesStream() {
    // Récupérer les produits en temps réel
    return FirebaseFirestore.instance
        .collection('ProduitsFrais')
        .snapshots()
        .asyncMap((produitsSnapshot) async {
      List<Map<String, dynamic>> produits = produitsSnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();

      // Récupérer les catégories associées aux produits
      List<String> categoriesIds = produits
          .map((produit) => produit['specifique_frais'] as String)
          .toSet() // Pour éviter les doublons
          .toList();

      QuerySnapshot categoriesSnapshot = await FirebaseFirestore.instance
          .collection('SpecifiqueProduitFroid')
          .where('id', whereIn: categoriesIds)
          .get();

      Map<String, Map<String, dynamic>> categoriesMap = {
        for (var doc in categoriesSnapshot.docs)
          (doc.data() as Map<String, dynamic>)['id']:
              doc.data() as Map<String, dynamic>
      };

      // Associer chaque produit avec sa catégorie
      return produits.map((produit) {
        return {
          ...produit,
          'categorie': categoriesMap[produit['specifique_frais']] ?? {}
        };
      }).toList();
    });
  }

  void _ajouterProduitSiPossible(List<Map<String, dynamic>> produits) {
    // Extraire tous les IDs des produits existants
    List<int> idsProduits =
        produits.map((produit) => int.parse(produit['id'])).toList();

    // Trouver l'ID le plus élevé
    int maxId =
        idsProduits.isEmpty ? 0 : idsProduits.reduce((a, b) => a > b ? a : b);

    if (maxId < 24) {
      // Si l'ID le plus élevé est inférieur à 24, on lance la page d'ajout
      int nouvelId = maxId + 1;
      Get.to(AjoutProduitFrais(), arguments: {'id': nouvelId.toString()});
    } else {
      // Sinon, on affiche un Snackbar pour informer l'utilisateur que la limite est atteinte
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Limite de 24 produits atteinte, impossible d\'ajouter un nouveau produit.'),
        ),
      );
    }
  }

   MqttService myService= MqttService();
  
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    myService.connect();
  }

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
                  children: [
                    Text(
                      "Compartiment Froid",
                      style: TextStyle(
                          fontSize: 20,
                          color: greenColor,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                 CardWidget(
                  height: 100,
                  width: 200,
                  temperature: "${myService.getTemperature()}",
                  title: "Temperature actuelle",
                ),
                const SizedBox(height: 15),
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
                const SizedBox(height: 15),
                StreamBuilder<List<Map<String, dynamic>>>(
                  stream: _getProduitsAndCategoriesStream(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Erreur: ${snapshot.error}'));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(child: Text('Aucun produit frais trouvé.'));
                    } else {
                      List<Map<String, dynamic>> produitsAvecCategories =
                          snapshot.data!;
                      return _buildAnimatedContainer(
                        _isExpandedFraisProduits,
                        Column(
                          children: produitsAvecCategories.map((produit) {
                            var categorie =
                                produit['categorie'] as Map<String, dynamic>;
                            print('Le produit : $produit');
                            return produitFrais(
                              id: produit['id'],
                              titre: produit['description'],
                              sousTitre: categorie['nom'] ?? '',
                              image: produit[
                                  'image'], // Utiliser directement l'URL de l'image
                            );
                          }).toList(),
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _getProduitsAndCategoriesStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return FloatingActionButton.extended(
              onPressed: null,
              backgroundColor: Colors.grey,
              label: Text('Chargement...'),
            );
          } else if (!snapshot.hasData) {
            return FloatingActionButton.extended(
              onPressed: (){
                Get.to(AjoutProduitFrais(), arguments: {'id': "1"});
              },
              backgroundColor: Colors.grey,
              label: Text('Ajoutez un premier'),
            );
          } else {
            List<Map<String, dynamic>> produits = snapshot.data ?? [];

            return SizedBox(
              width: 100.0,
              child: FloatingActionButton.extended(
                onPressed: () {
                  _ajouterProduitSiPossible(produits);
                },
                backgroundColor: greenColor,
                label: Text(
                  'Ajouter',
                  style: TextStyle(color: whiteColor),
                ),
                icon: Icon(
                  Icons.add,
                  color: whiteColor,
                ),
              ),
            );
          }
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

  Widget produitFrais(
      {required String titre,
      required String sousTitre,
      required String image, // URL de l'image
      required String id}) {
    return GestureDetector(
      onTap: () {
        Get.to(AfficueProduitFrais(), arguments: {'id': id});
        print("L'id $id");
      },
      onLongPress: () {
        _showProductOptionsDialog(id);
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.green),
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(15),
            ),
            child: ListTile(
              title: Text(
                titre,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              subtitle: Text(sousTitre),
              leading: Container(
                width: 100,
                height:
                    100, // Assurez-vous que la hauteur est égale à la largeur pour maintenir la forme circulaire
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    fit: BoxFit
                        .contain, // Assurez-vous que l'image couvre tout le conteneur
                    image: NetworkImage(image), // Utilisation de NetworkImage
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
                    id,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            )),
      ),
    );
  }

  void _showProductOptionsDialog(
    String id,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Get.to(ModifProduitFrais(), arguments: {'id': id});
                },
                child: Text('Modifier'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Fermer la boîte de dialogue
                  showDeleteConfirmationDialog(id);
                },
                child: Text('Supprimer'),
              )
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
          SnackBar(content: Text('Produit $productId supprimé avec succès.')),
        );
        // Optionnel: Retourner à la page précédente ou rafraîchir la vue
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Aucun produit trouvé pour cet ID.')),
        );
      }
    } catch (e) {
      print("Erreur lors de la suppression du produit: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la suppression du produit.')),
      );
    }
  }

  void showDeleteConfirmationDialog(String productId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmation'),
          content: Text('Voulez-vous vraiment supprimer ce produit ?'),
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
                deleteProduct(productId); // Appeler la fonction de suppression
              },
              child: Text('Supprimer'),
            ),
          ],
        );
      },
    );
  }
}
