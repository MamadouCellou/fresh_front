import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fresh_front/services/notifications_service.dart';
import 'package:fresh_front/services/service_mqtt.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:intl/intl.dart';

class CompartimentFroidController extends GetxController {

  var isSliderPlageManuelle = false.obs;
  var isSliderPlageAuto = false.obs;
  var isSliderEtatCircuitFroid = false.obs;
  var isLoadingTemperature = false.obs;
  var products = <Map<String, dynamic>>[].obs;

  MqttService myService = MqttService();

  TextEditingController minControllerManuel = TextEditingController();
  TextEditingController maxControllerManuel = TextEditingController();

  TextEditingController minControllerOptimal = TextEditingController();
  TextEditingController maxControllerOptimal = TextEditingController();

  final apiKey = "AIzaSyDGVpXSZMwSQk7eF8h9mEWqnxgR1TX0144";
  late GenerativeModel model;

  @override
  void onInit() {
    super.onInit();
    getProductsData();
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

  void togglePlageManuelle(bool value) {
    print("Avant ${isSliderPlageManuelle.value}");

    isSliderPlageManuelle.value = value;
    print("Apres $value");
  }

  void togglePlageAuto(bool value) async {
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

        isLoadingTemperature.value = false;
      } else {
        print("Aucune plage de température optimale trouvée dans la réponse.");
      }
    } catch (e) {
      print("Erreur lors de l'appel à l'API : $e");
      print("Erreur de calcul de température optimale.");
    }
  }

  void toggleRelayFroid(bool value) {
    isSliderEtatCircuitFroid.value = value;
    // Vous pouvez ajouter ici la logique pour gérer le relais via MQTT
  }

  void onAppliqueTemperatureManuelle() {
    int temperatureMinManuelle = int.parse(minControllerManuel.text);
    int temperatureMaxManuelle = int.parse(maxControllerManuel.text);

    int temperatureMinOptimale = int.parse(minControllerOptimal.text);
    int temperatureMaxOptimale = int.parse(maxControllerOptimal.text);

    if (temperatureMinManuelle != temperatureMinOptimale ||
        temperatureMaxManuelle != temperatureMaxOptimale) {

          minControllerManuel.text="";
          maxControllerManuel.text="";
      int notificationId = DateTime.now().millisecondsSinceEpoch % 100000;

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
