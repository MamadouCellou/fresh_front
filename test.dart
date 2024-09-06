import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class ModifProduitFrais extends StatefulWidget {
  const ModifProduitFrais({super.key});

  @override
  State<ModifProduitFrais> createState() => _ModifProduitFraisState();
}

final _formKey = GlobalKey<FormBuilderState>();

class _ModifProduitFraisState extends State<ModifProduitFrais> {
  List<Map<String, dynamic>> aliments = [];
  String selectedAliment = '';
  String? selectedAlimentId;

  Map<String, dynamic>? produitDetails;

  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  String? categorieProduitActuel;

  String? produitId;

 @override
void initState() {
  super.initState();
  final args = Get.arguments as Map<String, dynamic>;
  produitId = (args['id'] + 1).toString();
  print("Id produit : $produitId");
  fetchProduitData().then((_) {
    _fetchAlimentsFromFirestore(categorieProduitActuel);

    print("Categorie produit actuel : $categorieProduitActuel");
  });
}


  Future<void> fetchProduitData() async {
    try {
      // Requête Firestore pour obtenir le produit où le champ 'id' correspond à 'idProduit'
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('ProduitsFrais')
          .where('id', isEqualTo: produitId) // Vérifier la valeur du champ 'id'
          .limit(1) // Limiter à un résultat
          .get();

      if (snapshot.docs.isNotEmpty) {
        setState(() {
          produitDetails = snapshot.docs.first.data() as Map<String, dynamic>;
        print("Categorie avant 2 : $categorieProduitActuel");
          categorieProduitActuel = "1";
        print("CAtegorie 2 : $categorieProduitActuel");
        });
      } else {
        print("Aucun produit trouvé avec cet ID.");
      }
    } catch (e) {
      print("Erreur lors de la récupération des détails du produit: $e");
      setState(() {
        // isLoading = false; // Arrêter le chargement en cas d'erreur
      });
    }
  }

  Future<void> _fetchAlimentsFromFirestore(
      String? categorieProduitActuel) async {
    try {
      CollectionReference alimentsRef =
          FirebaseFirestore.instance.collection('SpecifiqueProduitFroid');
      QuerySnapshot querySnapshot = await alimentsRef.get();

      setState(() {
        aliments = querySnapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return {
            'id': data['id'], // Utiliser l'ID du document Firestore
            'nom': data['nom'],
            'image': data['image'],
          };
        }).toList();

        // Définir l'aliment sélectionné basé sur le produit actuel
        if (categorieProduitActuel != null) {
          final alimentActuel = aliments.firstWhere(
            (aliment) => aliment['id'] == categorieProduitActuel,
            orElse: () =>
                aliments.first, // Utiliser le premier aliment par défaut
          );
          selectedAliment = alimentActuel['nom'];
          selectedAlimentId = alimentActuel['id'];
        } else if (aliments.isNotEmpty) {
          // Initialiser la sélection avec le premier aliment si disponible
          selectedAliment = aliments[0]['nom'];
          selectedAlimentId = aliments[0]['id'];
        }
      });
    } catch (e) {
      print("Erreur lors de la récupération des aliments: $e");
    }
  }

  // update product to Firestore
  Future<void> updateProduit() async {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      final values = _formKey.currentState?.value;
      String imageUrl = produitDetails?['image'] ??
          ''; // Récupérer l'URL actuelle de l'image s'il n'y a pas de nouvelle image sélectionnée.

      // Vérifier s'il y a une nouvelle image à télécharger
      if (_imageFile != null) {
        imageUrl = await _uploadImage(_imageFile!);
      }

      // Afficher le dialogue de chargement pendant l'opération
      Get.dialog(
        Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      // Vérifier si un aliment est sélectionné
      if (selectedAliment.isNotEmpty) {
        final selectedAlimentData = aliments.firstWhere(
          (aliment) => aliment['nom'] == selectedAliment,
        );

        try {
          // Rechercher le document avec l'id du produit
          final produitRef = FirebaseFirestore.instance
              .collection('ProduitsFrais')
              .where('id', isEqualTo: produitId)
              .limit(1);

          final querySnapshot = await produitRef.get();

          if (querySnapshot.docs.isNotEmpty) {
            final docId = querySnapshot.docs.first.id;

            // Mise à jour du produit existant dans Firestore
            await FirebaseFirestore.instance
                .collection('ProduitsFrais')
                .doc(docId)
                .update({
              'description': values?['description'] ?? '',
              'dispositif': 'MANDA1', // Exemple, à ajuster si nécessaire
              'image': imageUrl,
              'prix': values?['prix'] ??
                  '0', // Assurez-vous que le prix est un nombre
              'id': produitId,
              'categorie_produit': selectedAlimentId,
              'modifie_a': Timestamp.now(),
              'cree_a': produitDetails!['cree_a'],
            });

            // Fermer le dialogue de chargement

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Produit modifié avec succès')),
            );

            Get.back();
          } else {
            // Fermer le dialogue de chargement
            Get.back();

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Produit non trouvé')),
            );
          }
        } catch (e) {
          // Fermer le dialogue de chargement
          Get.back();

          // Afficher un message d'erreur
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Erreur lors de la modification du produit')),
          );

          print("Erreur lors de la modification du produit: $e");
        }
      } else {
        // Fermer le dialogue de chargement si aucun aliment n'est sélectionné

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Veuillez sélectionner un aliment')),
        );
      }
    }
  }

  // Upload image to Firebase Storage
  Future<String> _uploadImage(File image) async {
    try {
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference storageReference =
          FirebaseStorage.instance.ref().child('user_images/$fileName');
      UploadTask uploadTask = storageReference.putFile(image);
      TaskSnapshot taskSnapshot = await uploadTask;
      String downloadURL = await taskSnapshot.ref.getDownloadURL();
      return downloadURL;
    } catch (e) {
      print("Erreur lors de l'upload de l'image: $e");
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (produitDetails == null) {
      // If produitDetails is null, show a loading indicator
      return Center(child: CircularProgressIndicator());
    }

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "Modifier produit frais",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        body: Column(
          mainAxisAlignment:
              MainAxisAlignment.spaceBetween, // Espace entre les widgets
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: FormBuilder(
                  key: _formKey,
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            height: 250,
                            width: 230,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(),
                              image: DecorationImage(
                                fit: BoxFit.cover,
                                image: (produitDetails != null &&
                                        produitDetails!['image'] != null &&
                                        produitDetails!['image'].isNotEmpty)
                                    ? NetworkImage(produitDetails![
                                        'image']) // Afficher l'image depuis l'URL
                                    : AssetImage(
                                        "assets/images/pomme_noir.png"),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 2),
                            child: GestureDetector(
                              onTap: () {
                                // Logique pour modifier l'image
                              },
                              child: Icon(Icons.edit),
                            ),
                          ),
                        ],
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
                              produitId!,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Dropdown for selecting aliment
                      FormBuilderDropdown<String>(
                        name: 'aliment',
                        
                        initialValue: selectedAliment,
                        decoration: InputDecoration(
                          labelText: 'Aliment',
                          border: OutlineInputBorder(),
                        ),
                        items: aliments.map((aliment) {
                          print("Selected $selectedAliment");
                          return DropdownMenuItem<String>(
                            value: aliment['nom'],
                            child: Text(aliment['nom']),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedAliment = newValue!;

                            // Mettre à jour l'ID correspondant à l'aliment sélectionné
                            selectedAlimentId = aliments
                                .firstWhere(
                                  (aliment) =>
                                      aliment['nom'] == selectedAliment,
                                  orElse: () => {
                                    'id': -1
                                  }, // Valeur par défaut pour éviter les erreurs si non trouvé
                                )['id']
                                .toString(); // Assurez-vous de convertir l'ID en String si nécessaire

                          });
                            print("Nouveau nom : $selectedAliment");
                            print("Nouveau ID : $selectedAlimentId");
                        },
                      ),
                      SizedBox(height: 20),
                      // Editable fields
                      buildEditableField('Prix du produit', 'prix',
                          TextInputType.number, produitDetails!['prix']),
                      SizedBox(height: 10),
                      buildEditableField('Description', 'description',
                          TextInputType.text, produitDetails!['description']),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 20), // Espace entre le contenu et les boutons
            // Row containing buttons 'Modifier' and 'Annuler'
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.saveAndValidate()) {
                      updateProduit();

                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Produit modifié')));
                    }
                    Get.back();
                  },
                  style: ButtonStyle(
                    backgroundColor:
                        WidgetStateProperty.all<Color>(Colors.green),
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
                ElevatedButton(
                  onPressed: () {
                    _formKey.currentState!.reset();

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Modification annulée')),
                    );

                    Get.back();
                  },
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all<Color>(Colors.red),
                    padding: WidgetStateProperty.all<EdgeInsets>(
                        EdgeInsets.symmetric(horizontal: 30, vertical: 15)),
                    shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                        side: BorderSide(color: Colors.redAccent, width: 2),
                      ),
                    ),
                    shadowColor: WidgetStateProperty.all<Color>(
                        Colors.redAccent.withOpacity(0.5)),
                    elevation: WidgetStateProperty.all<double>(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.cancel, color: Colors.white),
                      SizedBox(width: 10),
                      Text(
                        "Annuler",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 20), // Espace en bas de l'écran
          ],
        ),
      ),
    );
  }

  // Function to build an editable field using FormBuilder
  Widget buildEditableField(
      String label, String name, TextInputType inputType, String value) {
    return FormBuilderTextField(
      name: name,
      initialValue: value,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
      ),
      keyboardType: inputType,
      validator: FormBuilderValidators.required(),
    );
  }
}