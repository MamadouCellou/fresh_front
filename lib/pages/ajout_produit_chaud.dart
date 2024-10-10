import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AjoutProduitChaud extends StatefulWidget {
  const AjoutProduitChaud({super.key});

  @override
  State<AjoutProduitChaud> createState() => _AjoutProduitChaudState();
}

final _formKey = GlobalKey<FormBuilderState>();

class _AjoutProduitChaudState extends State<AjoutProduitChaud> {
  List<Map<String, dynamic>> aliments =
      []; // Liste des aliments chauds à partir de Firestore
  String selectedAliment = '';
  String selectedImage = 'assets/images/pomme_noir.png'; // Image par défaut

  final String message = Get.arguments ?? '-1';

  @override
  void initState() {
    super.initState();
    _fetchAlimentsChaud(
        message); // Récupérer la liste des aliments chauds depuis Firestore
  }

  // Fonction pour récupérer la liste des aliments chauds depuis Firestore
  Future<void> _fetchAlimentsChaud(String dureFiltre) async {
    // Si le filtre est différent de -1, ajouter une condition à la requête
    QuerySnapshot snapshot;

    if (dureFiltre != "") {
      snapshot = await FirebaseFirestore.instance
          .collection('SpecifiqueProduitChaud')
          .where('dure', isEqualTo: dureFiltre) // Filtrer par le champ 'dure'
          .get();
    } else {
      snapshot = await FirebaseFirestore.instance
          .collection('SpecifiqueProduitChaud')
          .get();
    }

    setState(() {
      aliments = snapshot.docs
          .map((doc) => {
                'id': doc['id'],
                'nom': doc['nom'],
                'image': doc['image'],
                'dure': doc['dure'],
              })
          .toList();

      if (aliments.isNotEmpty) {
        selectedAliment =
            aliments[0]['id'].toString(); // Initialiser avec le premier aliment
        selectedImage = aliments[0]['image']; // Mettre à jour l'image initiale
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Ajouter produit chaud",
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
                              image: NetworkImage(
                                  selectedImage), // Utiliser l'image sélectionnée
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
                    SizedBox(height: 5),
                    Text(
                        "Les aliments dans la liste sont ceux seulement qui sont sechageable avec celui initialement ajouté."),
                    SizedBox(height: 15),
                    // Dropdown pour sélectionner l'aliment chaud
                    FormBuilderDropdown<String>(
                      name: 'aliment',
                      initialValue: selectedAliment,
                      decoration: InputDecoration(
                        labelText: 'Aliment',
                        border: OutlineInputBorder(),
                      ),
                      items: aliments.map((aliment) {
                        return DropdownMenuItem<String>(
                          value: aliment['id'].toString(),
                          child: Text(aliment['nom']),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedAliment = newValue!;
                          // Mettre à jour l'image en fonction de l'aliment sélectionné
                          selectedImage = aliments.firstWhere((element) =>
                              element['id'].toString() == newValue)['image'];
                        });
                      },
                    ),
                    SizedBox(height: 20),
                    // Champs modifiables
                    buildEditableField(
                        'Description', 'description', TextInputType.text),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: 20), // Espace entre le contenu et les boutons
          // Ligne contenant les boutons 'Ajouter' et 'Annuler'
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.saveAndValidate()) {
                    final values = _formKey.currentState!.value;
    
                    // Vérifie si la liste des aliments est vide
                    if (aliments.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text('La liste des aliments est vide.')));
                      return; // Arrête l'exécution
                    }
    
                    // Imprime le contenu de la liste des aliments
                    aliments.forEach((element) {
                      print("Nom de l'aliment : ${element['nom']}");
                    });
    
                    print(
                        "Aliment sélectionné : '${selectedAliment}'"); // Vérifie les espaces
    
                    Map<String, dynamic>? alimentTrouve = aliments.firstWhere(
                      (element) =>
                          element['id'].toLowerCase() ==
                          selectedAliment.toLowerCase(),
                      // orElse: () => null,
                    );
                    print(
                        "Aliment trouvé : '${alimentTrouve}'"); // Vérifie les espaces
    
                    // Vérifie si l'aliment a été trouvé
                    int duree = int.parse(alimentTrouve[
                        'dure']); // Assure-toi que 'duree' existe
                    DateTime expirationDate =
                        DateTime.now().add(Duration(minutes: duree));
    
                    // Générer un ID unique pour le produit chaud
                    String uniqueId = FirebaseFirestore.instance
                        .collection('ProduitsChauds')
                        .doc()
                        .id;
    
                    // Ajouter le produit chaud dans Firestore
                    await FirebaseFirestore.instance
                        .collection('ProduitsChauds')
                        .doc(uniqueId)
                        .set({
                      'id': uniqueId,
                      'description': values['description'],
                      'specifique_chaud': selectedAliment,
                      'expirationDate': expirationDate.toString(),
                      'image': selectedImage,
                      'dispositif': "MANDA1",
                      'cree_a': formatTimestamp(Timestamp.now()),
                      'modifie_a': "Non modifié",
                    });
    
                    print("Ajout sauvegardées avec valeurs: $values");
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Produit ajouté')));
                    Get.back();
                  }
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
          SizedBox(height: 20), // Espace en bas de l'écran
        ],
      ),
    );
  }

  // Fonction pour formater un Timestamp en une chaîne de caractères lisible
  String formatTimestamp(Timestamp timestamp) {
    DateTime dateTime =
        timestamp.toDate(); // Convertir le Timestamp en DateTime
    return DateFormat('dd/MM/yyyy HH:mm:ss')
        .format(dateTime); // Formater la date
  }

  // Fonction pour créer un champ éditable avec FormBuilder
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
