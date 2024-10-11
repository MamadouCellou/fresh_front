import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'package:fresh_front/constant/colors.dart';
import 'package:fresh_front/constant/variable_globales.dart';
import 'package:fresh_front/pages/affiche_produit_chaud.dart';
import 'package:fresh_front/pages/ajout_produit_chaud.dart';
import 'package:fresh_front/pages/modifie_produit_chaud.dart';
import 'package:fresh_front/services/service_mqtt_aws_iot_core.dart';
import 'package:fresh_front/widget/card_widget.dart';
import 'package:get/get.dart';
import 'package:mqtt_client/mqtt_client.dart';

class PageChaudProduct extends StatefulWidget {
  @override
  _PageChaudProductState createState() => _PageChaudProductState();
}

class _PageChaudProductState extends State<PageChaudProduct> {
  bool _isExpandedChaudProduits = true;

  Stream<List<Map<String, dynamic>>> _getProduitsAndCategoriesStream() {
    // Récupérer les produits en temps réel
    return FirebaseFirestore.instance
        .collection('ProduitsChauds')
        .snapshots()
        .asyncMap((produitsSnapshot) async {
      List<Map<String, dynamic>> produits = produitsSnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();

      // Récupérer les catégories associées aux produits
      List<String> categoriesIds = produits
          .map((produit) => produit['specifique_chaud'] as String)
          .toSet() // Pour éviter les doublons
          .toList();

      QuerySnapshot categoriesSnapshot = await FirebaseFirestore.instance
          .collection('SpecifiqueProduitChaud')
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
          'categorie': categoriesMap[produit['specifique_chaud']] ?? {}
        };
      }).toList();
    });
  }

  MqttService myService = MqttService();
  
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _connectMqtt();
  }

  Future<void> _connectMqtt() async {
    try {
      await myService.connect();
      updateTemperatures();

      // Écoute des messages MQTT
      myService.client?.updates?.listen((List<MqttReceivedMessage<MqttMessage>> c) {
        final MqttPublishMessage recMess = c[0].payload as MqttPublishMessage;
        final String payload = MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
        
        final topic = c[0].topic;
        if (topic == myService.topicData) {
          setState(() {
            updateTemperatures();
          });
        }
      });
    } catch (error) {
      print('Échec de la connexion MQTT : $error');
      // Affichez une alerte à l'utilisateur ou un type de notification
     
    }
  }

  void updateTemperatures() {
    // Récupérez et mettez à jour les températures ici
    // Assurez-vous que les données sont non nulles avant de les utiliser
    setState(() {
      // Exemple d'initialisation
      temperatureChaud = myService.getTemperatureChaud();
    });
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
                      "Compartiment Chaud",
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
                  temperature: "$temperatureChaud",
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
                      return Center(child: Text('Aucun produit chaud trouvé.'));
                    } else {
                      List<Map<String, dynamic>> produitsAvecCategories =
                          snapshot.data!;
                      return _buildAnimatedContainer(
                        _isExpandedChaudProduits,
                        Column(
                          children: produitsAvecCategories.map((produit) {
                            var categorie =
                                produit['categorie'] as Map<String, dynamic>;
                            return produitChaud(
                              id: produit['id'],
                              titre: produit['description'],
                              sousTitre: categorie['nom'] ?? '',
                              image: produit[
                                  'image'], // Utiliser directement l'URL de l'image
                              dateHeureFin: categorie['dure'].toString(),
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
      floatingActionButton: SizedBox(
        width: 100.0,
        child: FloatingActionButton.extended(
          onPressed: () {
            Get.to(AjoutProduitChaud());
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

  Widget produitChaud(
      {required String titre,
      required String sousTitre,
      required String image, // URL de l'image
      required String dateHeureFin,
      required String id}) {
    return GestureDetector(
      onTap: () {
        Get.to(AfficueProduitChaud(), arguments: {'id': id});
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
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                  fit: BoxFit.cover,
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
                   Get.to(ModifProduitChaud(), arguments: {'id': id});
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
          .collection('ProduitsChauds')
          .where('id', isEqualTo: productId)
          .get();

      if (snapshot.docs.isNotEmpty) {
        // Supposons qu'il y a un seul document correspondant
        DocumentReference docRef = snapshot.docs.first.reference;
        await docRef.delete();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Produit supprimé avec succès')),
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
