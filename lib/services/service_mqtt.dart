import 'dart:io';

import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class MQTTService {
  final String broker = 'http://y0e990c1.ala.dedicated.aws.emqxcloud.com/';  // L'URL de ton serveur EMQX
  final int port = 1883;                   // Le port par défaut pour MQTT
  final String clientId = 'manda_temperatureId';
  
  final String temperatureTopic = 'manda/temperature';  // Le topic pour les données de température

  final String username = 'traore-manda-fresh';
  final String password = 'Manda2024';

  String message = 'No message yet';
  List<String> receivedMessages = [];
  List<String> sendedMessages = [];
  bool isConnected = false;

  MqttServerClient client;

  MQTTService()
      : client = MqttServerClient.withPort('c133a990.ala.dedicated.aws.emqxcloud.com', 'manda_fresh_app', 1883) {
    client.keepAlivePeriod = 60;
    client.logging(on: true);
    client.onDisconnected = onDisconnected;
    client.onConnected = onConnected;
    client.autoReconnect = true;
    client.onAutoReconnect = onAutoReconnect;
    client.onAutoReconnected = onAutoReconnected;
  }

  Future<void> connect() async {
    print("START CONNECTION NOW");

    final connMessage = MqttConnectMessage()
        .withClientIdentifier(clientId)
        .authenticateAs(username, password) // Authentification utilisateur/mot de passe
        .withWillTopic('Will topic')
        .withWillMessage('Will message')
        .startClean() // Commence une nouvelle session
        .withWillQos(MqttQos.atLeastOnce);
    client.connectionMessage = connMessage;

    try {
      print("Connecting...");
      await client.connect();

      if (client.connectionStatus!.state == MqttConnectionState.connected) {
        print('Connected');
        isConnected = true;
        // Souscription au topic de température
        subscribeToTemperatureTopic();
      } else {
        print('Connection failed - status is ${client.connectionStatus}');
        disconnect();
        exit(-1);
      }
    } catch (e) {
      print('Exception during connection: $e');
      disconnect();
    }
  }

  // Publication de message sur le topic des commandes
  void sendCommand(String command, String commandTopic) async {
    if (isConnected) {
      print("Connection exists");

      final builder = MqttClientPayloadBuilder();
      builder.addString(command);
      client.publishMessage(commandTopic, MqttQos.atLeastOnce, builder.payload!);
      sendedMessages.add(command);
    } else {
      print("Connection state: ${client.connectionStatus!.state}");
      print("No connection");
    }
  }

  // Souscription au topic de température pour recevoir les messages
  void subscribeToTemperatureTopic() {
    client.subscribe(temperatureTopic, MqttQos.atLeastOnce);
    client.updates!.listen((List<MqttReceivedMessage<MqttMessage?>>? c) {
      if (c != null && c.isNotEmpty) {
        final MqttPublishMessage recMess = c[0].payload as MqttPublishMessage;
        final String receivedMessage = MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
        message = receivedMessage;
        receivedMessages.add(receivedMessage);
        print('Received temperature message: $message from topic: ${c[0].topic}');
      }
    });
  }

  void disconnect() {
    print('Disconnecting from the broker.');
    client.disconnect();
    isConnected = false;
  }

  void onConnected() {
    print('Connected to the broker.');
  }

  void onDisconnected() {
    print('Disconnected from the broker.');
  }

  void onAutoReconnect() {
    print('Client auto reconnection sequence will start.');
  }

  void onAutoReconnected() {
    print('Client auto reconnection sequence has completed.');
  }
}