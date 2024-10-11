import 'package:flutter_tts/flutter_tts.dart';
import 'package:fresh_front/constant/variable_globales.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'dart:convert';
import 'dart:io';

class MqttService {
  MqttServerClient? client;
  String broker = 'a1qavnvw56vtpy-ats.iot.eu-north-1.amazonaws.com'; // Remplacez par l'endpoint AWS IoT Core
  int port = 8883; // Port sécurisé pour AWS IoT Core

  String topicData = 'manda_smart/envoi_data'; // Topic pour recevoir les données
  String topicNotificationFroid = 'manda_smart/notifications_froid'; // Topic pour notifications froid
  String topicNotificationChaud = 'manda_smart/notifications_chaud'; // Topic pour notifications chaud


  bool isConnected = false;
  FlutterTts flutterTts = FlutterTts();

  Future<void> connect() async {
    client = MqttServerClient(broker, 'flutter_client');
    client?.port = port;
    client?.logging(on: true);
    client?.keepAlivePeriod = 20;
    client?.onDisconnected = onDisconnected;
    
    // Activer la sécurité TLS/SSL pour AWS IoT Core
    client?.secure = true;
    client?.securityContext = SecurityContext.defaultContext;

    // Ajouter les certificats directement depuis les chaînes de caractères
    client?.securityContext.setTrustedCertificatesBytes(utf8.encode(rootCA));
    client?.securityContext.useCertificateChainBytes(utf8.encode(deviceCert));
    client?.securityContext.usePrivateKeyBytes(utf8.encode(privateKey));

    final connMessage = MqttConnectMessage()
        .withClientIdentifier('flutter_client') // Identifiant unique
        .startClean()
        .withWillQos(MqttQos.atLeastOnce);
    client?.connectionMessage = connMessage;

    try {
      await client?.connect();
    } catch (e) {
      print('Exception: $e');
      client?.disconnect();
    }

    if (client?.connectionStatus?.state == MqttConnectionState.connected) {
      print('MQTT client connected to AWS IoT');
      // S'abonner aux topics
      isConnected = true;
      client?.subscribe(topicData, MqttQos.atLeastOnce);
      client?.subscribe(topicNotificationFroid, MqttQos.atLeastOnce);
      client?.subscribe(topicNotificationChaud, MqttQos.atLeastOnce);
      client?.updates?.listen((List<MqttReceivedMessage<MqttMessage>> c) {
        final MqttPublishMessage recMess = c[0].payload as MqttPublishMessage;
        final String payload =
            MqttPublishPayload.bytesToStringAsString(recMess.payload.message);

        final topic = c[0].topic;

        if (topic == topicData) {
          processMessage(payload);
        } else if (topic == topicNotificationFroid) {
          handleNotification("froid", jsonDecode(payload));
        } else if (topic == topicNotificationChaud) {
          handleNotification("chaud", jsonDecode(payload));
        }
      });
    } else {
      print(
          'Connection failed - status: ${client?.connectionStatus?.state}');
      client?.disconnect();
      isConnected = false;
    }
  }

  void processMessage(String payload) {
    final data = jsonDecode(payload);
    temperatureFroid = data['temperature_froid'].toString();
    temperatureChaud = data['temperature_chaud'].toString();
  }

  void handleNotification(String mode, var data) {
    if (mode == "froid") {
      temperatureFroidMin = data['temperatureMin_froid'].toString();
      temperatureFroidMax = data['temperatureMax_froid'].toString();
    } else if (mode == "chaud") {
      temperatureChaudMin = data['temperatureMin_chaud'].toString();
      temperatureChaudMax = data['temperatureMax_chaud'].toString();
    }
  }

  Future<void> readConfirmationMessage(String message) async {
    
    await flutterTts.setLanguage("fr-FR"); // Langue en français
    await flutterTts.setPitch(1.0); // Contrôle du ton
    await flutterTts.speak(message); // Lire le message
  }

  void onDisconnected() {
    print('MQTT client disconnected');
  }

  Future<void> sendMessage(String topic, Map<String, dynamic> message) async {
  if (client?.connectionStatus?.state == MqttConnectionState.connected) {
    try {
      final MqttClientPayloadBuilder builder = MqttClientPayloadBuilder();

      // Convertir le message en JSON
      String jsonMessage = jsonEncode(message);
      builder.addString(jsonMessage);
      
      client?.publishMessage(topic, MqttQos.atLeastOnce, builder.payload!);
      print('Message published: $jsonMessage to topic: $topic');
    } catch (e) {
      print('Error while publishing message: $e');
    }
  } else {
    print('MQTT client is not connected. Unable to send message.');
  }
}


  String getTemperatureFroid() => temperatureFroid;
  String getTemperatureChaud() => temperatureChaud;

  String getTemperatureMinFroid() => temperatureFroidMin;
  String getTemperatureMaxFroid() => temperatureFroidMax;

  String getTemperatureMinChaud() => temperatureChaudMin;
  String getTemperatureMaxChaud() => temperatureChaudMax;

}
