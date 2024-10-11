import 'package:flutter/material.dart';
import 'package:fresh_front/services/service_mqtt_aws_iot_core.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fresh_front/services/notifications_service.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CompartimentFroidController extends GetxController {

  RxBool isSliderPlageManuelle = false.obs;
  RxBool isSliderPlageAuto = false.obs;
  RxBool isSliderEtatCircuitFroid = false.obs;
  var isLoadingTemperature = false.obs;
  var products = <Map<String, dynamic>>[].obs;


  TextEditingController minControllerManuel = TextEditingController();
  TextEditingController maxControllerManuel = TextEditingController();

  TextEditingController minControllerOptimal = TextEditingController();
  TextEditingController maxControllerOptimal = TextEditingController();

  final apiKey = "AIzaSyDGVpXSZMwSQk7eF8h9mEWqnxgR1TX0144";
  late GenerativeModel model;
  MqttService myService = MqttService();
  Future<SharedPreferences> _prefs =  SharedPreferences.getInstance();


  @override
  void onInit() {
    super.onInit();
    getProductsData();
    loadSwitchState();
    _initializeGenerativeModel();
  }



  void _initializeGenerativeModel() async {
    try {
      model = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: apiKey,
      );
      myService.connect();
    } catch (e) {
      print("Erreur lors de l'initialisation du modèle : $e");
    }
  }

  // Charger l'état du switch
  Future<void> loadSwitchState() async {
    final prefs = await _prefs;
    isSliderPlageManuelle.value = prefs.getBool('plageManuelle') ?? false;
    isSliderPlageAuto.value = prefs.getBool('plageAuto') ?? false;
  }

  Future<void> getProductsData() async {
    try {
      final firestore = FirebaseFirestore.instance;

      final produitsQuery = await firestore.collection('ProduitsFrais').get();

      List<Map<String, dynamic>> fetchedProducts = [];
      for (var doc in produitsQuery.docs) {
        final productData = doc.data();
        final specifiqueId = productData['specifique_frais'];

        final specifiqueQuery = await firestore
            .collection('SpecifiqueProduitFroid')
            .where('id', isEqualTo: specifiqueId)
            .get();

        if (specifiqueQuery.docs.isNotEmpty) {
          final specifiqueData = specifiqueQuery.docs.first.data();
          fetchedProducts.add({
            "name": specifiqueData['nom'],
            "temp_min": specifiqueData['temp_min'],
            "temp_max": specifiqueData['temp_max'],
          });
        }
      }

      products.assignAll(fetchedProducts);
    } catch (e) {
      print("Erreur lors de la récupération des données : $e");
    }
  }

  Future<void> togglePlageManuelle(bool value) async {

    final prefs = await _prefs;
    prefs.setBool('plageManuelle', value);
    isSliderPlageManuelle.value = value;

  }

   Future<void> togglePlageAuto(bool value) async {
    
    final prefs = await _prefs;
    prefs.setBool('plageAuto', value);
    isSliderPlageAuto.value = value;
    if (value) {
      isLoadingTemperature.value = true;

      await getOptimalTemperature();
    }
  }

  Future<void> getOptimalTemperature() async {
    try {
      if (model == null) {
        print("Le modèle n'a pas été initialisé.");
        return;
      }

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

      final regex = RegExp(r'(\d+)°C\s*@\s*(\d+)°C');
      final match = regex.firstMatch(responseText);

      if (match != null) {
        var minTemp = match.group(1);
        var maxTemp = match.group(2);

        minControllerOptimal.text = minTemp!;
        maxControllerOptimal.text = maxTemp!;

        myService.readConfirmationMessage("compartiment froid est reglé à une temperature de $minTemp à $maxTemp");

        isLoadingTemperature.value = false;
      } else {
        print("Aucune plage de température optimale trouvée dans la réponse.");
      }
    } catch (e) {
      print("Erreur lors de l'appel à l'API : $e");
      print("Erreur de calcul de température optimale.");
    }
  }

   Future<void> toggleRelayFroid(bool value) async{
    isSliderEtatCircuitFroid.value = value;
    final prefs = await _prefs;
    
    if (myService.isConnected) {
      myService.sendMessage('manda_smart/command_froid', {
        "command_froid" : value ? "ON_FROID" : "OFF_FROID"
      });
      prefs.setBool('relayState', value);
    } else {
      print('Cannot send command, MQTT client is not connected.');
    }
  }

  void onAppliqueTemperatureManuelle() {
    int temperatureMinManuelle = int.parse(minControllerManuel.text);
    int temperatureMaxManuelle = int.parse(maxControllerManuel.text);

    int temperatureMinOptimale = int.parse(minControllerOptimal.text);
    int temperatureMaxOptimale = int.parse(maxControllerOptimal.text);

    if (temperatureMinManuelle != temperatureMinOptimale ||
        temperatureMaxManuelle != temperatureMaxOptimale) {
          
      int notificationId = DateTime.now().millisecondsSinceEpoch % 100000;

      if (myService.isConnected) {
      myService.sendMessage('manda_smart/command_froid', {
        "temperatureMin_froid" : temperatureMinManuelle,
        "temperatureMax_froid" : temperatureMaxManuelle
      });
      minControllerManuel.text="";
      maxControllerManuel.text="";
      } else {
        print('Cannot send command, MQTT client is not connected.');
      }
      NotificationService().showNotification(
        id: notificationId,
        title: "Avertissement de Plage de Température",
        body:
            "La plage de température définie manuellement (${temperatureMinManuelle}°C - ${temperatureMaxManuelle}°C) est différente de la plage optimale (${temperatureMinOptimale}°C - ${temperatureMaxOptimale}°C).",
        payload: "go_to_notifications",
      );

      enregistrerNotificationFirestore(
        id: notificationId.toString(),
        title: "Avertissement de Plage de Température",
        body:
            "La plage de température définie manuellement (${temperatureMinManuelle}°C - ${temperatureMaxManuelle}°C) est différente de la plage optimale (${temperatureMinOptimale}°C - ${temperatureMaxOptimale}°C).",
      );
    }
  }

  void enregistrerNotificationFirestore(
      {required String id, required String title, required String body}) {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    String formattedDate =
        DateFormat('yyyy-MM-dd – kk:mm').format(DateTime.now());

    firestore.collection('Notifications').doc(id).set({
      'id': id,
      'title': title,
      'body': body,
      'date': formattedDate,
      'read': false,
    });
  }
}
