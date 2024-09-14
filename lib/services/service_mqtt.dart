import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'dart:convert';

class MqttService {
  MqttServerClient? client;
  String broker = '192.168.174.128'; // Adresse IP du broker local
  String topicData = 'topic/manda_smart_envoi_data'; // Topic pour recevoir les données
  String topicNotification= 'topic/manda_smart/notifications'; // Topic pour recevoir les notifications
  String commandTopic = 'topic/manda_smart/commande'; // Topic pour envoyer des commandes
  
  // Variables pour stocker les données
  String temperature = '0';
  String humidity = '0';
  String notification = '';

  Future<void> connect() async {
    client = MqttServerClient(broker, '');
    client?.port = 1883;
    client?.logging(on: true);
    client?.keepAlivePeriod = 20;
    client?.onDisconnected = onDisconnected;

    final connMessage = MqttConnectMessage()
        .withClientIdentifier('flutter_client')
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
      print('MQTT client connected');
      // S'abonner au topic
      client?.subscribe(topicData, MqttQos.atLeastOnce);
      client?.subscribe(topicNotification, MqttQos.atLeastOnce);
      client?.updates?.listen((List<MqttReceivedMessage<MqttMessage>> c) {
        final MqttPublishMessage recMess = c[0].payload as MqttPublishMessage;
        final String payload =
            MqttPublishPayload.bytesToStringAsString(recMess.payload.message);

        final topic = c[0].topic;

        if (topic == topicData) {
          processMessage(payload);
        } else if (topic == topicNotification) {
          handleNotification(payload);
        } 
      });
    } else {
      print(
          'Connection failed - status: ${client?.connectionStatus?.state}');
      client?.disconnect();
    }
  }

  void processMessage(String payload) {
    // Décoder la chaîne JSON reçue
    final data = jsonDecode(payload);
    temperature = data['temperature'].toString();
    humidity = data['humidity'].toString();
  }

  void handleNotification(String payload) {
    notification = payload;
    print('Notification received: $notification');
  }

  void onDisconnected() {
    print('MQTT client disconnected');
  }

  // Méthode pour envoyer une commande à l'ESP8266
  void sendCommand(String command) {
    final builder = MqttClientPayloadBuilder();
    builder.addString(command);
    client?.publishMessage(commandTopic, MqttQos.atLeastOnce, builder.payload!);
    print('Command sent: $command');
  }

  void sendMessage({String command = '', int temperatureMin = 0, int temperatureMax = 0}) {
    final Map<String, dynamic> message = {
      'command': command,
      'temperatureMin': temperatureMin ,
      'temperatureMax': temperatureMax,
    };
    final builder = MqttClientPayloadBuilder();
    builder.addString(jsonEncode(message));
    client?.publishMessage(commandTopic, MqttQos.exactlyOnce, builder.payload!);
  }

  // Méthode pour obtenir la température
  String getTemperature() {
    return temperature;
  }

  // Méthode pour obtenir l'humidité
  String getHumidity() {
    return humidity;
  }

  String getNotification() {
    return notification;
  }
}