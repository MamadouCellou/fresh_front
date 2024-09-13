import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fresh_front/constant/colors.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class PageCompartimentReclageChaud extends StatefulWidget {
  @override
  _PageCompartimentReclageChaudState createState() =>
      _PageCompartimentReclageChaudState();
}

class _PageCompartimentReclageChaudState
    extends State<PageCompartimentReclageChaud> {
  late bool isSliderPlageManuelle = false;
  late bool isSliderPlageAuto = false;
  late bool isSliderEtatCircuit = false;

  final TextEditingController minController = TextEditingController();
  final TextEditingController maxController = TextEditingController();

  List<Map<String, dynamic>> products = [];

  void onChangePlageManuelle(bool value) {
    if (isSliderPlageAuto) {
      // Afficher un dialogue de confirmation si le réglage adaptatif est activé
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Confirmation"),
            content: Text(
                "Attention!\nVoulez-vous désactiver le réglage adaptatif et continuer avec le réglage manuel ?"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text("Annuler"),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    isSliderPlageAuto = false;
                    isSliderPlageManuelle = value;
                  });
                  Navigator.of(context).pop();
                },
                child: Text("Continuer"),
              ),
            ],
          );
        },
      );
    } else {
      setState(() {
        isSliderPlageManuelle = value;
      });
    }
  }

  void onChangePlageAuto(bool value) async {
    // Lorsque le réglage adaptatif est activé, désactiver le réglage manuel
    if (value) {
      await getOptimalTemperature();
    }

    setState(() {
      isSliderPlageAuto = value;
      if (value) {
        isSliderPlageManuelle = false;
      }
    });
  }

  void onChangeEtatCircuit(bool v) {
    setState(() {
      isSliderEtatCircuit = v;
    });
  }

  final apiKey = "AIzaSyDGVpXSZMwSQk7eF8h9mEWqnxgR1TX0144";
  late GenerativeModel model;

  @override
  void initState() {
    super.initState();
    model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: apiKey,
    );
    getProductsData();
    // getOptimalTemperature();
  }

  Future<void> getProductsData() async {
    try {
      final firestore = FirebaseFirestore.instance;

      // Chargement des produits frais
      final produitsQuery = await firestore.collection('ProduitsFrais').get();

      List<Map<String, dynamic>> fetchedProducts = [];
      for (var doc in produitsQuery.docs) {
        final productData = doc.data();
        final specifiqueId = productData['specifique_frais'];

        print("Spécifique ID: $specifiqueId"); // Debugging line

        // Utiliser le champ 'id' de la collection 'SpecifiqueProduitFroid'
        final specifiqueQuery = await firestore
            .collection('SpecifiqueProduitFroid')
            .where('id', isEqualTo: specifiqueId)
            .get();

        if (specifiqueQuery.docs.isNotEmpty) {
          final specifiqueData = specifiqueQuery.docs.first.data();

          print(
              "Données spécifiques trouvées: $specifiqueData"); // Debugging line

          fetchedProducts.add({
            "name": specifiqueData['nom'],
            "temp_min": specifiqueData['temp_min'],
            "temp_max": specifiqueData['temp_max'],
          });
        } else {
          print("Produit non trouvé pour spécification ID: $specifiqueId");
        }
      }

      if (fetchedProducts.isEmpty) {
        print("Aucun produit avec plage de température trouvée.");
      }

      setState(() {
        products = fetchedProducts;
      });

      print(products);
    } catch (e) {
      print("Erreur lors de la récupération des données : $e");
    }
  }

  Future<void> getOptimalTemperature() async {
    try {
      if (products.isEmpty) {
        print("Aucun produit avec plage de température trouvée.");
        return;
      }

      final prompt = """
Given the following food items with their respective temperature ranges:

${products.map((p) => '${p["name"]}: ${p["temp_min"]}°C to ${p["temp_max"]}°C').join(', ')},

Determine the ideal temperature range (in °C) that would be suitable for storing all these items simultaneously. The range should be the smallest possible range that includes all the provided ranges, ensuring that every item is stored within its specified temperature limits. Provide the result in the format 'min - max'.
""";


      print("Prompt envoyé à l'IA: $prompt");

      final response = await model.generateContent([Content.text(prompt)]);

      final responseText = response.text ?? "No optimal temperature found.";
      print("Réponse de l'IA: $responseText");

      final regex = RegExp(r'(\d+)\s*-\s*(\d+)');
      final match = regex.firstMatch(responseText);

      if (match != null) {
        final minTemperature = match.group(1);
        final maxTemperature = match.group(2);

        setState(() {
          minController.text = minTemperature!;
          maxController.text = maxTemperature!;
        });
      } else {
        print("No optimal temperature range found in the response.");
      }
    } catch (e) {
      print("Erreur lors de l'appel à l'API : $e");
      print("Erreur de calcul de température optimale.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: greenColor,
        title: Text(
          "Compartiment Froid",
          style: TextStyle(
            fontSize: 20,
            color: whiteColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 10,
              ),
              Center(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: greenColor,
                      width: 1.0,
                    ),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: SizedBox(
                    width: 160,
                    height: 160,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          "Temperature actuelle",
                          style: TextStyle(
                            color: blackColor,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "20 °C",
                              style: TextStyle(
                                color: blackColor,
                                fontSize: 25,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Icon(
                              Icons.thermostat,
                              size: 30,
                              color: greenColor,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Text(
                "Reclage de temperature",
                style: TextStyle(
                  fontSize: 20,
                  color: blackColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SwitchListTile(
                value: isSliderPlageManuelle,
                onChanged: onChangePlageManuelle,
                activeColor: greenColor,
                title: Text(
                  "Regler de façon manuelle",
                  style: TextStyle(
                    fontSize: 18,
                    color: blackColor,
                  ),
                ),
              ),
              isSliderPlageManuelle
                  ? Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 80),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Flexible(
                                child: TextField(
                                  enabled: true,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    labelText: 'Min',
                                    border: InputBorder.none,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Container(
                                padding: const EdgeInsets.all(10.0),
                                decoration: BoxDecoration(
                                  color: greenColorTransparent,
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: Text(
                                  '℃',
                                  style: TextStyle(
                                    fontSize: 20,
                                    color: greenColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Flexible(
                                child: TextField(
                                  cursorColor: blackColor,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    labelText: 'Max',
                                    border: InputBorder.none,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const Divider(),
                        ],
                      ),
                    )
                  : Container(),
              isSliderPlageManuelle
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: null,
                          child: Text(
                            'Appliquer',
                            style: TextStyle(
                              fontSize: 13,
                              color: greenColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    )
                  : Container(),
              const SizedBox(
                height: 10,
              ),
              SwitchListTile(
                value: isSliderPlageAuto,
                onChanged: onChangePlageAuto,
                activeColor: greenColor,
                title: Text(
                  "Regler de façon adaptive",
                  style: TextStyle(
                    fontSize: 18,
                    color: blackColor,
                  ),
                ),
              ),
              isSliderPlageAuto
                  ? Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 80),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Flexible(
                                child: TextField(
                                  controller: minController,
                                  enabled: false,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    labelText: 'Min',
                                    border: InputBorder.none,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Container(
                                padding: const EdgeInsets.all(10.0),
                                decoration: BoxDecoration(
                                  color: greenColorTransparent,
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: Text(
                                  '℃',
                                  style: TextStyle(
                                    fontSize: 20,
                                    color: greenColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Flexible(
                                child: TextField(
                                  controller: maxController,
                                  enabled: false,
                                  cursorColor: blackColor,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    labelText: 'Max',
                                    border: InputBorder.none,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const Divider(),
                        ],
                      ),
                    )
                  : Container(),
              SwitchListTile(
                value: isSliderEtatCircuit,
                onChanged: onChangeEtatCircuit,
                activeColor: greenColor,
                title: Container(
                  padding: const EdgeInsets.all(10.0),
                  decoration: BoxDecoration(
                    color: isSliderEtatCircuit
                        ? greenColorTransparent
                        : redColorTransparent,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Center(
                    child: Text(
                      isSliderEtatCircuit ? "Allumé" : "Eteint",
                      style: TextStyle(
                        fontSize: 20,
                        color: isSliderEtatCircuit ? greenColor : redColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
