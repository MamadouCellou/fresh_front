import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fresh_front/constant/colors.dart';
import 'package:fresh_front/constant/variable_globales.dart';
import 'package:fresh_front/getX/getx.dart';
import 'package:fresh_front/services/notifications_service.dart';
import 'package:fresh_front/services/service_mqtt_aws_iot_core.dart';
import 'package:get/get.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:intl/intl.dart';

class PageCompartimentReclageFroid extends StatefulWidget {
  @override
  _PageCompartimentReclageFroidState createState() =>
      _PageCompartimentReclageFroidState();
}

class _PageCompartimentReclageFroidState
    extends State<PageCompartimentReclageFroid> {
  final controleur = Get.put(CompartimentFroidController());
  final TextEditingController minControllerManuel = TextEditingController();
  final TextEditingController maxControllerManuel = TextEditingController();
  
  bool isSliderEtatCircuit = false;

  MqttService myService = MqttService();
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  int notificationId = DateTime.now().millisecondsSinceEpoch % 100000;

  @override
  void initState() {
    super.initState();
    controleur.loadSwitchState();
    loadSwitchFroid();
    _connectMqtt();
  }

  void updateTemperatures() {
    setState(() {
      temperatureFroid = myService.getTemperatureFroid();
    });
  }

  Future<void> _connectMqtt() async {
    try {
      await myService.connect();
      updateTemperatures();
      
      myService.client?.updates?.listen((List<MqttReceivedMessage<MqttMessage>> c) {
        final MqttPublishMessage recMess = c[0].payload as MqttPublishMessage;
        final String payload = MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
        
        final topic = c[0].topic;
        if (topic == myService.topicData) {
          updateTemperatures();
        }
      });
    } catch (error) {
      print('Échec de la connexion MQTT : $error');
    }
  }

  Future<void> onChangeEtatCircuit(bool value) async {
    final prefs = await _prefs;
    setState(() {
      isSliderEtatCircuit = value;
    });

    if (myService.isConnected) {
      myService.sendMessage('manda_smart/command_froid', {
        "command_froid": value ? "ON_FROID" : "OFF_FROID"
      });
      prefs.setBool('relayState', value);
    } else {
      print('Cannot send command, MQTT client is not connected.');
    }
  }

  Future<void> loadSwitchFroid() async {
    final prefs = await _prefs;
    isSliderEtatCircuit = prefs.getBool('relayState') ?? false;
  }

  Future<void> onAppliqueManuelTemperature() async {
    if (minControllerManuel.text.isNotEmpty && maxControllerManuel.text.isNotEmpty) {
      int minControllerManValue = int.parse(minControllerManuel.text);
      int maxControllerManValue = int.parse(maxControllerManuel.text);

      if (myService.isConnected) {
        myService.sendMessage('manda_smart/command_froid', {
          "temperatureMin_froid": minControllerManValue,
          "temperatureMax_froid": maxControllerManValue
        });

        NotificationService().showNotification(
          id: notificationId,
          title: "Avertissement de Plage de Température dans le compartiment froid",
          body: "La plage de température définie manuellement (${minControllerManValue}°C - ${maxControllerManValue}°C) ",
          payload: "go_to_notifications",
        );

        FirebaseFirestore firestore = FirebaseFirestore.instance;
        String formattedDate =
            DateFormat('yyyy-MM-dd – kk:mm').format(DateTime.now());
        
        firestore.collection('Notifications').doc(notificationId.toString()).set({
          'id': notificationId.toString(),
          'title': "Avertissement de Plage de Température dans le compartiment froid",
          'body': "La plage de température définie manuellement (${minControllerManValue}°C - ${maxControllerManValue}°C)  ",
          'date': formattedDate,
          'read': false,
        });

        myService.readConfirmationMessage("compartiment froid est reglé à une temperature de $minControllerManValue à $maxControllerManValue");

        setState(() {
          minControllerManuel.clear();
          maxControllerManuel.clear();
        });
      } else {
        print('Cannot send command, MQTT client is not connected.');
      }
    }
  }


  void enregistrerNotificationFirestore(
      {required String id, required String title, required String body}) {
    
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: greenColor,
        foregroundColor: whiteColor,
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
              SizedBox(height: 10),
              _buildTemperatureDisplay(),
              SizedBox(height: 20),
              _buildTemperatureSettings(),
              SizedBox(height: 10),
              _buildCircuitSwitch(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTemperatureDisplay() {
    return Center(
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
                    "$temperatureFroid °C",
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
    );
  }

  Widget _buildTemperatureSettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Réglage de température",
          style: TextStyle(
            fontSize: 20,
            color: blackColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        Obx(() => SwitchListTile(
          value: controleur.isSliderPlageManuelle.value,
          onChanged: (value) {
            controleur.togglePlageManuelle(value);
            controleur.togglePlageAuto(false);
            if (value) {
              
            }
          },
          activeColor: greenColor,
          title: Text(
            "Régler de façon manuelle",
            style: TextStyle(
              fontSize: 18,
              color: blackColor,
            ),
          ),
        )),
        Obx(() => controleur.isSliderPlageManuelle.value ? _buildManualTemperatureInputs() : Container()),
        Obx(() => controleur.isSliderPlageManuelle.value ? _buildApplyButton() : Container()),
        Obx(() => SwitchListTile(
          value: controleur.isSliderPlageAuto.value,
          onChanged: (value) {
            controleur.togglePlageManuelle(false);
            controleur.togglePlageAuto(value);
          },
          activeColor: greenColor,
          title: Text(
            "Régler de façon adaptive",
            style: TextStyle(
              fontSize: 18,
              color: blackColor,
            ),
          ),
        )),
        Obx(() => controleur.isSliderPlageAuto.value ? _buildOptimalTemperatureDisplay() : Container()),
      ],
    );
  }

  Widget _buildManualTemperatureInputs() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 80),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: TextField(
                  controller: minControllerManuel,
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
    );
  }

  Widget _buildApplyButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: () async {
            await onAppliqueManuelTemperature();
          },
          child: Text(
            "Appliquer",
            style: TextStyle(
              fontSize: 15,
              color: greenColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOptimalTemperatureDisplay() {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 80),
    child: Column(
      children: [
        controleur.isSliderPlageAuto.value
            ? controleur.isLoadingTemperature.value
                ? Center(
                    child: CircularProgressIndicator(
                    color: Colors.green,
                  ))
                : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Flexible(
                              child: TextField(
                                controller: controleur.minControllerOptimal,
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
                                controller: controleur.maxControllerOptimal,
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
      ],
    ),
  );
}

  Widget _buildCircuitSwitch() {
    return 
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
    );
  }
}
