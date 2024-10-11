import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class ControlState {
  final bool isDarkMode;
  final bool isSliderPlageManuelle;
  final bool isSliderPlageAuto;
  final bool isSliderEtatCircuitDispo;
  final bool isSliderEtatCircuitFroid;
  final bool isSliderEtatCircuitChaud;
  final bool isLoadingTemperature;
  final String? minTemperature; 
  final String? maxTemperature;

  ControlState({
    required this.isDarkMode,
    required this.isSliderPlageManuelle,
    required this.isSliderPlageAuto,
    required this.isSliderEtatCircuitDispo,
    required this.isSliderEtatCircuitFroid,
    required this.isSliderEtatCircuitChaud,
    required this.minTemperature,
    required this.maxTemperature,
    required this.isLoadingTemperature,
  });

  ControlState copyWith({
    bool? isDarkMode,
    bool? isSliderPlageAuto,
    bool? isSliderPlageManuelle,
    bool? isSliderEtatCircuitDispo,
    bool? isSliderEtatCircuitFroid,
    bool? isSliderEtatCircuitChaud,
    String? minTemperature,
    String? maxTemperature,
    bool? isLoadingTemperature,
  }) {
    return ControlState(
      isDarkMode: isDarkMode ?? this.isDarkMode,
      isSliderPlageAuto: isSliderPlageAuto ?? this.isSliderPlageAuto,
      isSliderPlageManuelle: isSliderPlageManuelle ?? this.isSliderPlageManuelle, 
      isSliderEtatCircuitDispo: isSliderEtatCircuitDispo ?? this.isSliderEtatCircuitDispo,
      isSliderEtatCircuitFroid: isSliderEtatCircuitFroid ?? this.isSliderEtatCircuitFroid,
      isSliderEtatCircuitChaud: isSliderEtatCircuitChaud ?? this.isSliderEtatCircuitChaud,
      minTemperature: minTemperature ?? this.minTemperature,  
      maxTemperature: maxTemperature ?? this.maxTemperature,  
      isLoadingTemperature: isLoadingTemperature ?? this.isLoadingTemperature,
    );
  }
}

class ControlCubit extends Cubit<ControlState> {

  final apiKey = "AIzaSyDGVpXSZMwSQk7eF8h9mEWqnxgR1TX0144";
  late GenerativeModel model;

  ControlCubit()
      : super(ControlState(
          isDarkMode: false,
          isSliderPlageManuelle: true,
          isSliderPlageAuto: false,
          isSliderEtatCircuitDispo: false,
          isSliderEtatCircuitFroid: false,
          isSliderEtatCircuitChaud: false,
          minTemperature: '-',
          maxTemperature: '-',
          isLoadingTemperature: false,
        )) {
    _initializeGenerativeModel();
  }

  void _initializeGenerativeModel() async {
    try {
      model = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: apiKey,
      );
    } catch (e) {
      print("Erreur lors de l'initialisation du modèle : $e");
    }
  }

  void toggleTheme() {
    emit(state.copyWith(isDarkMode: !state.isDarkMode));
  }

  void togglePlageAuto(bool value, List<Map<String, dynamic>> products) async {
    if (value) {
      emit(state.copyWith(isLoadingTemperature: true));
      await getOptimalTemperature(products); 
      emit(state.copyWith(isSliderPlageAuto: value, isLoadingTemperature: false));
    } else {
      emit(state.copyWith(isSliderPlageAuto: value));
    }
  }

  Future<void> getOptimalTemperature(List<Map<String, dynamic>> products) async {
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
      final responseText = response.text ?? "Aucune température optimale trouvée.";
      print("Réponse de l'IA: $responseText");

      final regex = RegExp(r'(\d+)°C\s*@\s*(\d+)°C');
      final match = regex.firstMatch(responseText);

      if (match != null) {
        var minTemperature = match.group(1);
        var maxTemperature = match.group(2);

        emit(state.copyWith(
            minTemperature: minTemperature, maxTemperature: maxTemperature));
      } else {
        print("Aucune plage de température optimale trouvée dans la réponse.");
      }
    } catch (e) {
      print("Erreur lors de l'appel à l'API : $e");
      print("Erreur de calcul de température optimale.");
    }
  }

  void toggleRelayChaud(bool value) {
    emit(state.copyWith(isSliderEtatCircuitChaud: value));
    sendMessageToRelayChaud(value);
  }

  void toggleRelayFroid(bool value) {
    emit(state.copyWith(isSliderEtatCircuitFroid: value));
    sendMessageToRelayFroid(value);
  }

  void toggleRelayDispo(bool value) {
    emit(state.copyWith(isSliderEtatCircuitDispo: value));
    sendMessageToRelayDispo(value);
  }

  void togglePlageManuelle(bool value) {
    emit(state.copyWith(isSliderPlageManuelle: value));
  }

  void sendMessageToRelayChaud(bool state) {
    String command = state ? "ON" : "OFF";
    // Logique pour envoyer la commande au relais chaud
  }

  void sendMessageToRelayFroid(bool state) {
    String command = state ? "ON" : "OFF";
    // Logique pour envoyer la commande au relais froid
  }

  void sendMessageToRelayDispo(bool state) {
    String command = state ? "ON" : "OFF";
    // Logique pour envoyer la commande au dispositif
  }
}
