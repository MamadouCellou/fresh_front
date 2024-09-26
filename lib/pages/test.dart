import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fresh_front/constant/colors.dart';
import 'package:fresh_front/services/notifications_service.dart';
import 'package:fresh_front/services/service_mqtt.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:intl/intl.dart';


class PageCompartimentReclageFroid extends StatefulWidget {
  @override
  _PageCompartimentReclageFroidState createState() =>
      _PageCompartimentReclageFroidState();
}

class _PageCompartimentReclageFroidState
    extends State<PageCompartimentReclageFroid> {
  late bool isSliderPlageManuelle = false;
  late bool isSliderPlageAuto = false;
  late bool isSliderEtatCircuit = false;

  late bool islodoading = false;

  final TextEditingController minController = TextEditingController();
  final TextEditingController maxController = TextEditingController();
  final TextEditingController minControllerManuel = TextEditingController();
  final TextEditingController maxControllerManuel = TextEditingController();

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
      setState(() {
        islodoading = true;
      });
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

  MqttService myService = MqttService();

 void onAppliqueTemperatureManuelle() {
  int temperatureMinManuelle = int.parse(minControllerManuel.text);
  int temperatureMaxManuelle = int.parse(maxControllerManuel.text);

  int temperatureMinOptimale = int.parse(minController.text);
  int temperatureMaxOptimale = int.parse(maxController.text);

  // Comparer la plage manuelle avec la plage optimale
  if (temperatureMinManuelle != temperatureMinOptimale ||
      temperatureMaxManuelle != temperatureMaxOptimale) {
    // Générer un identifiant unique et suffisamment petit pour la notification
    int notificationId = DateTime.now().millisecondsSinceEpoch % 100000;

    // Envoyer une notification locale avec cet ID
    NotificationService().showNotification(
        id: notificationId, // ID unique pour la notification
        title: "Avertissement de Plage de Température",
        body:
            "La plage de température définie manuellement (${temperatureMinManuelle}°C - ${temperatureMaxManuelle}°C) est différente de la plage optimale (${temperatureMinOptimale}°C - ${temperatureMaxOptimale}°C).",
        payload: "go_to_notifications");

    // Enregistrer la notification dans Firestore avec le même ID unique
    enregistrerNotificationFirestore(
      id: notificationId.toString(), // Convertir l'ID en chaîne de caractères pour Firestore
      title: "Avertissement de Plage de Température",
      body:
          "La plage de température définie manuellement (${temperatureMinManuelle}°C - ${temperatureMaxManuelle}°C) est différente de la plage optimale (${temperatureMinOptimale}°C - ${temperatureMaxOptimale}°C).",
    );
  }

  // Envoyer le message via MQTT comme avant
  // myService.sendMessage(temperatureMin: temperatureMinManuelle, temperatureMax: temperatureMaxManuelle);
}



// Fonction pour enregistrer la notification dans Firestore avec un ID unique
  void enregistrerNotificationFirestore(
      {required String id, required String title, required String body}) {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    // Obtenir l'heure actuelle formatée
    String formattedDate =
        DateFormat('yyyy-MM-dd – kk:mm').format(DateTime.now());

    // Créer une nouvelle notification avec un champ 'id' unique
    firestore.collection('Notifications').doc(id).set({
      'id': id, // ID unique de la notification
      'title': title,
      'body': body,
      'timestamp':
          formattedDate, // Enregistre l'heure d'envoi de la notification
      'read': false, // Statut de lecture, par défaut non lue
    }).then((value) {
      print("Notification enregistrée avec succès avec l'ID : $id");
    }).catchError((error) {
      print("Erreur lors de l'enregistrement de la notification : $error");
    });
  }

  void toggleRelay(bool value) {
    setState(() {
      isSliderEtatCircuit = value;
      myService.sendMessage(command: isSliderEtatCircuit ? "ON" : "OFF");
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
    myService.connect();
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

Determine the ideal temperature range (in °C) that would be suitable for storing all these items simultaneously. The range should be the smallest possible range that includes all the provided ranges, ensuring that every item is stored within its specified temperature limits. Provide the result in the format 'min°C @ max°C'.
""";

      print("Prompt envoyé à l'IA: $prompt");

      final response = await model.generateContent([Content.text(prompt)]);

      final responseText =
          response.text ?? "Aucune température optimale trouvée.";
      print("Réponse de l'IA: $responseText");

      // Expression régulière mise à jour pour capturer le format '2°C @ 15°C'
      final regex = RegExp(r'(\d+)°C\s*@\s*(\d+)°C');
      final match = regex.firstMatch(responseText);

      if (match != null) {
        final minTemperature = match.group(1);
        final maxTemperature = match.group(2);

        if (minTemperature != null && maxTemperature != null) {
          setState(() {
            minController.text = minTemperature;
            maxController.text = maxTemperature;
          });
        }
      } else {
        print("Aucune plage de température optimale trouvée dans la réponse.");
      }
    } catch (e) {
      print("Erreur lors de l'appel à l'API : $e");
      print("Erreur de calcul de température optimale.");
    }
    setState(() {
      islodoading = false;
    });
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
                              "${myService.getTemperature()} °C",
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
                                  controller: minControllerManuel,
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
                                  controller: maxControllerManuel,
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
                          onPressed: onAppliqueTemperatureManuelle,
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
              islodoading
                  ? Center(
                      child: CircularProgressIndicator(
                      color: greenColor,
                    ))
                  : SwitchListTile(
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
                onChanged: toggleRelay,
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

/* import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'dart:io';

class TemperatureAdaptiveScreen extends StatefulWidget {
  @override
  _TemperatureAdaptiveScreenState createState() => _TemperatureAdaptiveScreenState();
}

class _TemperatureAdaptiveScreenState extends State<TemperatureAdaptiveScreen> {
  final apiKey = "AIzaSyDGVpXSZMwSQk7eF8h9mEWqnxgR1TX0144";
  late GenerativeModel model;
  
  @override
  void initState() {
    super.initState();
    model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: apiKey,
    );
  }

  Future<String> getOptimalTemperature() async {
  // Exemple de données de produits avec leurs plages de température
  final products = [
    {"name": "Orange", "temp_min": 0, "temp_max": 10},
    {"name": "Mangue", "temp_min": 5, "temp_max": 15},
    {"name": "Banane", "temp_min": 7, "temp_max": 12}
  ];

  // Crée une requête textuelle pour l'API Gemini
  final prompt = "Given these food items with their temperature ranges: "
                 "${products.map((p) => '${p["name"]}: ${p["temp_min"]} to ${p["temp_max"]}').join(', ')}, "
                 "provide the ideal temperature range to store them all in the format 'min - max'.";

  try {
    // Envoie la requête à l'API
    final response = await model.generateContent([Content.text(prompt)]);

    // Extraire les deux valeurs avec une expression régulière
    final responseText = response.text ?? "No optimal temperature found.";
    print(responseText);
    final regex = RegExp(r'(\d+)\s*-\s*(\d+)');
    final match = regex.firstMatch(responseText);

    if (match != null) {
      final minTemperature = match.group(1);
      final maxTemperature = match.group(2);
      
      // Stocke les valeurs dans des variables ou les utilise selon besoin
      print('Min Temperature: $minTemperature');
      print('Max Temperature: $maxTemperature');

      return '$minTemperature - $maxTemperature';
    } else {
      return "No optimal temperature range found in the response.";
    }
  } catch (e) {
    print("Erreur lors de l'appel à l'API : $e");
    return "Erreur de calcul de température optimale.";
  }
}



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Temperature Adaptive Control'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            final result = await getOptimalTemperature();
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                content: Text(result),
              ),
            );
          },
          child: Text('Get Optimal Temperature'),
        ),
      ),
    );
  }
}
 */