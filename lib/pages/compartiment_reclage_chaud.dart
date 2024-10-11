import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fresh_front/constant/colors.dart';
import 'package:fresh_front/constant/variable_globales.dart';
import 'package:fresh_front/services/notifications_service.dart';
import 'package:fresh_front/services/service_mqtt_aws_iot_core.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:intl/intl.dart';

class PageCompartimentReclageChaud extends StatefulWidget {
  @override
  _PageCompartimentReclageChaudState createState() =>
      _PageCompartimentReclageChaudState();
}

class _PageCompartimentReclageChaudState
    extends State<PageCompartimentReclageChaud> {
  
 
  late bool isSliderEtatCircuit = false;
  MqttService myService = MqttService();
    Future<SharedPreferences> _prefs =  SharedPreferences.getInstance();
    int notificationId = DateTime.now().millisecondsSinceEpoch % 100000;

  
  @override
  void initState() {
    super.initState();
    
    _connectMqtt();
    loadSwitchState();
  }

  Future<void> loadSwitchState() async {
    final prefs = await _prefs;
    isSliderEtatCircuit = prefs.getBool('relayStateChaud') ?? false;
  }

  void onChangeEtatCircuit(bool value) async {
    final  prefs = await _prefs;
    setState(() {
      isSliderEtatCircuit = value;
    });

    if (myService.isConnected) {
      myService.sendMessage('manda_smart/command_chaud', {
        "command_chaud" : value ? "ON_CHAUD" : "OFF_CHAUD"
      });
      prefs.setBool('relayStateChaud', value);
    } else {
      print('Cannot send command, MQTT client is not connected.');
    }

  }

   Future<void> onAppliqueTemperature(int minTemp, int maxTemp) async {
    if (myService.isConnected) {
        myService.sendMessage('manda_smart/command_chaud', {
          "temperatureMin_chaud": minTemp,
          "temperatureMax_chaud": maxTemp
        });

        NotificationService().showNotification(
          id: notificationId,
          title: "Avertissement de Plage de Température dans le compartiment chaud",
          body: "La plage de température définie manuellement (${minTemp}°C - ${maxTemp}°C) ",
          payload: "go_to_notifications",
        );

        FirebaseFirestore firestore = FirebaseFirestore.instance;
        String formattedDate =
            DateFormat('yyyy-MM-dd – kk:mm').format(DateTime.now());
        
        firestore.collection('Notifications').doc(notificationId.toString()).set({
          'id': notificationId.toString(),
          'title': "Avertissement de Plage de Température dans le compartiment chaud",
          'body': "La plage de température définie manuellement (${minTemp}°C - ${maxTemp}°C)  ",
          'date': formattedDate,
          'read': false,
        });
        myService.readConfirmationMessage("compartiment chaud est reglé à une temperature de $minTemp à $maxTemp");

      } else {
        print('Cannot send command, MQTT client is not connected.');
      }
  }



  Future<void> _connectMqtt() async {
    try {
      await myService.connect();
      updateTemperatures();

      // Écoute des messages MQTT
      myService.client?.updates?.listen((List<MqttReceivedMessage<MqttMessage>> c) {
        final MqttPublishMessage recMess = c[0].payload as MqttPublishMessage;
        final String payload = MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
        
        final topic = c[0].topic;
        if (topic == myService.topicData) {
          setState(() {
            updateTemperatures();
          });
        }
      });
    } catch (error) {
      print('Échec de la connexion MQTT : $error');
      // Affichez une alerte à l'utilisateur ou un type de notification
     
    }
  }

  void updateTemperatures() {
    // Récupérez et mettez à jour les températures ici
    // Assurez-vous que les données sont non nulles avant de les utiliser
    setState(() {
      // Exemple d'initialisation
      temperatureChaud = myService.getTemperatureChaud();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: greenColor,
        foregroundColor: whiteColor,
        title: Text(
          "Compartiment Sechage",
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
                              "${temperatureChaud} °C",
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
              SizedBox(height: 20),
              Text(
                "Réglage de température",
                style: TextStyle(
                  fontSize: 20,
                  color: blackColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              
              ElevatedButton(
                onPressed: () async{
                  await onAppliqueTemperature(40, 50);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: whiteColor,
                  side: BorderSide(
                    color: greenColor
                  )
                ),
                 child:  Text(
                  '40 °C - 50 °C',
                  style: TextStyle(
                    color: greenColor,
                    fontSize: 15,
                    fontWeight: FontWeight.bold
                  ),
                ),
                
              ),
              const SizedBox(width: 20),
              ElevatedButton(
                onPressed: () async{
                  await onAppliqueTemperature(50, 60);
                },
                 child:  Text(
                  '50 °C - 60 °C',
                  style: TextStyle(
                    color: greenColor,
                    fontSize: 15,
                    fontWeight: FontWeight.bold
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: whiteColor,
                  side: BorderSide(
                    color: greenColor
                  )
                ),
              ),
            ],
          ),
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
