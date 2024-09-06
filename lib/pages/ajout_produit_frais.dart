import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:get/get.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';

class AjoutProduitFrais extends StatefulWidget {
  const AjoutProduitFrais({super.key});

  @override
  State<AjoutProduitFrais> createState() => _AjoutProduitFraisState();
}

final _formKey = GlobalKey<FormBuilderState>();

class _AjoutProduitFraisState extends State<AjoutProduitFrais> {
  List<Map<String, dynamic>> aliments = [];
  String selectedAliment = '';

  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  String? produitId;

  @override
  void initState() {
    super.initState();
    final args = Get.arguments as Map<String, dynamic>;
    produitId = (args['id'] + 1).toString();
    print("Id produit : $produitId");
    _fetchAlimentsFromFirestore();
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
        });
      }
      setState(() {
        aliments = fetchedAliments;
        if (aliments.isNotEmpty) {
          selectedAliment = aliments.first['nom'];
        }
      });
    } catch (e) {
      print("Erreur lors de la récupération des aliments: $e");
    }
  }

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

  // Save product to Firestore
  Future<void> _saveProduct() async {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      final values = _formKey.currentState?.value;
      String imageUrl = '';

      if (_imageFile != null) {
        imageUrl = await _uploadImage(_imageFile!);
      }

      Get.dialog(
        Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      if (selectedAliment.isNotEmpty) {
        final selectedAlimentData =
            aliments.firstWhere((aliment) => aliment['nom'] == selectedAliment);

        try {
          await FirebaseFirestore.instance.collection('ProduitsFrais').add({
            'description': values?['description'] ?? '',
            'dispositif': 'MANDA1', // Example, you can adjust as needed
            'id': produitId,
            'image': imageUrl,
            'prix': values?['prix'] ?? '',
            'categorie_produit': selectedAlimentData['categorie_produit'],
            'cree_a': Timestamp.now(),
            'modifie_a': Null,
          });

          Get.back();

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Produit ajouté avec succès')),
          );
          Get.back();
        } catch (e) {
          print("Erreur lors de l'ajout du produit: $e");
        }
      }
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
                            onTap: _pickImage,
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
                                      : AssetImage(
                                              "assets/images/pomme_noir.png")
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
                              produitId!, // Example, replace with dynamic value if needed
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
                          return DropdownMenuItem<String>(
                            value: aliment['nom'],
                            child: Text(aliment['nom']),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedAliment = newValue!;
                          });
                        },
                      ),
                      SizedBox(height: 20),
                      // Editable fields
                      buildEditableField(
                          'Prix du produit', 'prix', TextInputType.number),
                      SizedBox(height: 10),
                      buildEditableField(
                          'Description', 'description', TextInputType.text),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            // Row containing buttons 'Ajouter' and 'Annuler'
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
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // Function to build an editable field using FormBuilder
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
