import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:get/get.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class AjoutProduitFrais extends StatefulWidget {
  const AjoutProduitFrais({super.key});

  @override
  State<AjoutProduitFrais> createState() => _AjoutProduitFraisState();
}

final _formKey = GlobalKey<FormBuilderState>();

class _AjoutProduitFraisState extends State<AjoutProduitFrais> {
  List<Map<String, dynamic>> aliments = [];
  String selectedAliment = '';
  String selectedImageUrl = ''; // Stocke l'URL de l'image sélectionnée

  String specifique_frais = '';
  File? _imageFile; // Image sélectionnée par l'utilisateur
  final ImagePicker _picker = ImagePicker();

  String? produitId;

  @override
  void initState() {
    super.initState();
    final args = Get.arguments as Map<String, dynamic>;
    produitId = args['id'];
    print("Id produit : $produitId");
    _fetchAlimentsFromFirestore();
  }

  // Fetch aliments from Firestore
  Future<void> _fetchAlimentsFromFirestore() async {
    try {
      CollectionReference alimentsRef =
          FirebaseFirestore.instance.collection('SpecifiqueProduitFroid');
      QuerySnapshot querySnapshot = await alimentsRef.get();

      List<Map<String, dynamic>> fetchedAliments = [];
      for (var doc in querySnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        fetchedAliments.add({
          'id': data['id'].toString(),
          'nom': data['nom'],
          'categorie_produit': data['categorie_produit'],
          'image': data['image'], // Ajouter le champ image ici
        });
      }
      setState(() {
        aliments = fetchedAliments;
        if (aliments.isNotEmpty) {
          // Sélectionner le premier aliment et mettre à jour l'image
          selectedAliment = aliments.first['nom'];
          selectedImageUrl =
              aliments.first['image']; // Charger l'image du premier aliment
              specifique_frais = aliments.first['id'];
        }
      });
    } catch (e) {
      print("Erreur lors de la récupération des aliments: $e");
    }
  }

  // Mettre à jour l'image lorsque l'aliment sélectionné change
  void _onAlimentChanged(String? newValue) {
    setState(() {
      selectedAliment = newValue!;
      final selectedAlimentData =
          aliments.firstWhere((aliment) => aliment['nom'] == selectedAliment);
      selectedImageUrl =
          selectedAlimentData['image']; // Mettre à jour l'image correspondante
          specifique_frais = selectedAlimentData['id'];
          print("Le specifique_frais : "+specifique_frais);
    });
  }

  // Fonction pour enregistrer le produit dans Firebase
  Future<void> _saveProduct() async {
  final form = _formKey.currentState;
  if (form != null && form.validate()) {
    form.save();

    try {
      String imageUrl;
      if (_imageFile != null) {
        imageUrl = await _uploadImageToFirebase(_imageFile!);
      } else {
        imageUrl = selectedImageUrl ?? ''; // Utiliser une valeur par défaut si selectedImageUrl est null
      }

      final prix = form.fields['prix']?.value ?? ''; // Valeur par défaut pour prix
      final description = form.fields['description']?.value ?? ''; // Valeur par défaut pour description

      await FirebaseFirestore.instance.collection('ProduitsFrais').add({
        'id': produitId ?? '', 
        'prix': prix,
        'description': description,
        'image': imageUrl, 
        'specifique_frais': specifique_frais, 
        'cree_a': formatTimestamp(Timestamp.now()), 
        'modifie_a': "Non modifié", 
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Produit ajouté avec succès')),
      );

      Get.back();
    } catch (e) {
      print("Erreur lors de l'ajout du produit: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de l\'ajout du produit')),
      );
    }
  } else {
    print("Formulaire est null ou non valide");
  }
}

  String formatTimestamp(Timestamp timestamp) {
    DateTime dateTime =
        timestamp.toDate(); // Convertir le Timestamp en DateTime
    return DateFormat('dd/MM/yyyy HH:mm:ss')
        .format(dateTime); // Formater la date
  }


  Future<String> _uploadImageToFirebase(File imageFile) async {
    try {
      String fileName = 'images/${DateTime.now().millisecondsSinceEpoch}.jpg';
      Reference firebaseStorageRef =
          FirebaseStorage.instance.ref().child(fileName);
      UploadTask uploadTask = firebaseStorageRef.putFile(imageFile);
      TaskSnapshot taskSnapshot = await uploadTask;

      return await taskSnapshot.ref.getDownloadURL();
    } catch (e) {
      throw Exception('Erreur lors du téléchargement de l\'image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "Ajouter produit frais",
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
                          GestureDetector(
                            onTap:
                                _pickImage, // L'utilisateur peut toujours choisir une autre image
                            child: Container(
                              height: 250,
                              width: 230,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(),
                                image: DecorationImage(
                                  fit: BoxFit.cover,
                                  image: _imageFile != null
                                      ? FileImage(_imageFile!)
                                      : (selectedImageUrl.isNotEmpty
                                              ? NetworkImage(selectedImageUrl)
                                              : AssetImage(
                                                  "assets/images/pomme_noir.png"))
                                          as ImageProvider,
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 2),
                            child: GestureDetector(
                              onTap: _pickImage,
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
                      // Dropdown pour sélectionner l'aliment
                      FormBuilderDropdown<String>(
                        name: 'aliment',
                        initialValue: selectedAliment,
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
                        onChanged:
                            _onAlimentChanged, // Appeler la fonction lorsque la sélection change
                      ),
                      SizedBox(height: 20),

                      buildEditableField(
                          'Description', 'description', TextInputType.text),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _saveProduct,
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
                      Icon(Icons.check, color: Colors.white),
                      SizedBox(width: 10),
                      Text(
                        "Ajouter",
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
                      SnackBar(content: Text('Ajout annulée')),
                    );
                    Get.back();
                  },
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all<Color>(Colors.red),
                    padding: MaterialStateProperty.all<EdgeInsets>(
                        EdgeInsets.symmetric(horizontal: 30, vertical: 15)),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                        side: BorderSide(color: Colors.redAccent, width: 2),
                      ),
                    ),
                    shadowColor: MaterialStateProperty.all<Color>(
                        Colors.redAccent.withOpacity(0.5)),
                    elevation: MaterialStateProperty.all<double>(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.close, color: Colors.white),
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
          ],
        ),
      ),
    );
  }

  // Fonction pour sélectionner une image depuis la galerie
  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Widget buildEditableField(
      String label, String name, TextInputType inputType) {
    return FormBuilderTextField(
      name: name,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
      ),
      keyboardType: inputType,
      validator: FormBuilderValidators.required(),
    );
  }
}
