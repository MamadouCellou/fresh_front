import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class ModifProduitChaud extends StatefulWidget {
  const ModifProduitChaud({super.key});

  @override
  State<ModifProduitChaud> createState() => _ModifProduitChaudState();
}

final _formKey = GlobalKey<FormBuilderState>();

class _ModifProduitChaudState extends State<ModifProduitChaud> {
  List<Map<String, dynamic>> aliments = [];
  String selectedAliment = '';
  String? selectedAlimentId;

  Map<String, dynamic>? produitDetails;

  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  String? categorieProduitActuel;
  String? produitId;

  // Pick image from gallery
  Future<void> _pickImage() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    final args = Get.arguments as Map<String, dynamic>;
    produitId = args['id'];
    print("Id produit : $produitId");
    fetchProduitData().then((_) {
      // On récupère d'abord les détails du produit avant de récupérer les aliments
      if (categorieProduitActuel != null) {
        _fetchAlimentsFromFirestore();
      }
    });
  }

  Future<void> fetchProduitData() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('ProduitsChauds')
          .where('id', isEqualTo: produitId)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        setState(() {
          produitDetails = snapshot.docs.first.data() as Map<String, dynamic>;
          categorieProduitActuel = produitDetails!['specifique_chaud'];
        });
        print("Categorie avant 2 : $categorieProduitActuel");
      } else {
        print("Aucun produit trouvé avec cet ID.");
      }
    } catch (e) {
      print("Erreur lors de la récupération des détails du produit: $e");
    }
  }

  Future<void> _fetchAlimentsFromFirestore() async {
    try {
      CollectionReference alimentsRef =
          FirebaseFirestore.instance.collection('SpecifiqueProduitChaud');
      QuerySnapshot querySnapshot = await alimentsRef.get();

      setState(() {
        aliments = querySnapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return {
            'id': data['id'].toString(), // Assurez-vous que l'ID est une chaîne
            'nom': data['nom'],
            'image': data['image'],
          };
        }).toList();

        // Définir l'aliment sélectionné basé sur la catégorie du produit
        if (categorieProduitActuel != null) {
          final alimentActuel = aliments.firstWhere(
            (aliment) => aliment['id'] == categorieProduitActuel,
            orElse: () => aliments.isNotEmpty
                ? aliments.first
                : {'nom': 'Sélectionner un aliment'},
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

  Future<void> updateProduit() async {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      final values = _formKey.currentState?.value;
      String imageUrl = produitDetails?['image'] ?? '';

      // Vérifier s'il y a une nouvelle image à télécharger
      if (_imageFile != null) {
        imageUrl = await _uploadImage(_imageFile!);
      }

      Get.dialog(
        Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      if (selectedAliment.isNotEmpty) {
        final selectedAlimentData = aliments.firstWhere(
          (aliment) => aliment['nom'] == selectedAliment,
        );

        try {
          final produitRef = FirebaseFirestore.instance
              .collection('ProduitsChauds')
              .where('id', isEqualTo: produitId)
              .limit(1);

          final querySnapshot = await produitRef.get();

          if (querySnapshot.docs.isNotEmpty) {
            final docId = querySnapshot.docs.first.id;

            await FirebaseFirestore.instance
                .collection('ProduitsChauds')
                .doc(docId)
                .update({
              'description': values?['description'] ?? '',
              'dispositif': 'MANDA1',
              'image': imageUrl,
              'id': produitId,
              'specifique_chaud': selectedAlimentId,
              'modifie_a': formatTimestamp(Timestamp.now()),
              'cree_a': produitDetails!['cree_a'].toString(),
            });

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Produit modifié avec succès')),
            );

            Get.back();
          } else {
            Get.back();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Produit non trouvé')),
            );
          }
        } catch (e) {
          Get.back();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Erreur lors de la modification du produit')),
          );
          print("Erreur lors de la modification du produit: $e");
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Veuillez sélectionner un aliment')),
        );
      }
    }
  }

  // Fonction pour formater un Timestamp en une chaîne de caractères lisible
  String formatTimestamp(Timestamp timestamp) {
    DateTime dateTime =
        timestamp.toDate(); // Convertir le Timestamp en DateTime
    return DateFormat('dd/MM/yyyy HH:mm:ss')
        .format(dateTime); // Formater la date
  }

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
      return Center(child: CircularProgressIndicator());
    }

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "Modifier produit chaud",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                image: (_imageFile != null)
                                    ? FileImage(
                                        _imageFile!) // Affiche l'image locale si elle est sélectionnée
                                    : (produitDetails != null &&
                                            produitDetails!['image'] != null &&
                                            produitDetails!['image'].isNotEmpty)
                                        ? NetworkImage(produitDetails![
                                            'image']) // Affiche l'image à partir de l'URL si l'image locale n'est pas disponible
                                        : AssetImage(
                                                "assets/images/pomme_noir.png")
                                            as ImageProvider,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 2),
                            child: GestureDetector(
                              onTap: () {
                                _pickImage();
                              },
                              child: Icon(Icons.edit),
                            ),
                          ),
                        ],
                      ),
                      
                      // Dropdown for selecting aliment
                      FormBuilderDropdown<String>(
                        name: 'aliment',
                        initialValue:
                            selectedAliment.isNotEmpty ? selectedAliment : null,
                        decoration: InputDecoration(
                          labelText: 'Aliment',
                          border: OutlineInputBorder(),
                        ),
                        items: aliments.map((aliment) {
                          return DropdownMenuItem<String>(
                            value: aliment['nom'],
                            child: Text(aliment['nom']),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedAliment = value ?? '';
                            selectedAlimentId = aliments.firstWhere(
                              (aliment) => aliment['nom'] == selectedAliment,
                              orElse: () => {'id': '', 'nom': ''},
                            )['id'];
                          });
                        },
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(),
                        ]),
                      ),
                      SizedBox(height: 10),
                      FormBuilderTextField(
                        name: 'description',
                        initialValue: produitDetails?['description'] ?? '',
                        decoration: InputDecoration(
                          labelText: 'Description',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: 10),
                      
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
}
