import 'package:flutter/material.dart';
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
