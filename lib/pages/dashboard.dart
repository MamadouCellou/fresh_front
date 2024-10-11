import 'package:fresh_front/constant/variable_globales.dart';
import 'package:fresh_front/services/service_mqtt_aws_iot_core.dart';
import 'package:fresh_front/widget/card_cellule_widget.dart';
import 'package:fresh_front/widget/card_widget.dart';

import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:mqtt_client/mqtt_client.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  static const TextStyle optionStyle =
      TextStyle(fontSize: 16, fontWeight: FontWeight.bold);

  final List<String> imgList = [
    'assets/images/orange.png', // Remplace avec le chemin de ta deuxième image
    'assets/images/mangue_1.png', // Remplace avec le chemin de ta troisième image
  ];

  int _currentIndex = 0;
  //final CarouselController _carouselController = CarouselController();

  MqttService myService = MqttService();
  
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _connectMqtt();
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
      temperatureFroid = myService.getTemperatureFroid();
      temperatureChaud = myService.getTemperatureChaud();
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5.0),
              child: CarouselSlider.builder(
                itemCount: imgList.length,
                itemBuilder: (context, index, realIndex) {
                  return Container(
                    width: 230,
                    decoration: BoxDecoration(
                        image: DecorationImage(
                            image: AssetImage(imgList[index]),
                            fit: BoxFit.cover)),
                  );
                },
                options: CarouselOptions(
                  initialPage: 0,
                  autoPlay: true,
                  enlargeCenterPage: true,
                  onPageChanged: (index, reason) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: imgList.asMap().entries.map((entry) {
                return GestureDetector(
                  onTap: () => setState(() {
                    _currentIndex = entry.key;
                  }),
                  child: Container(
                    width: 8.0,
                    height: 8.0,
                    margin: const EdgeInsets.symmetric(horizontal: 4.0),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _currentIndex == entry.key
                          ? Colors.blueAccent
                          : Colors.grey,
                    ),
                  ),
                );
              }).toList(),
            ),
 
            Padding(
              padding: const EdgeInsets.only(top:10,bottom: 10),
              child: Text(
                "Status des compartiments",
                style: optionStyle,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CardWidget(
                  temperature: "$temperatureFroid",
                  title: "Refroidissement",
                ),
                const SizedBox(
                  width: 10,
                ),
                CardWidget(
                  temperature: "$temperatureChaud",
                  title: "Séchage",
                ),
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            Text(
              "Status des produits",
              style: optionStyle,
            ),
            const SizedBox(
              height: 10,
            ),
            SnapCarousel(),
          ],
        ),
      ),
    );
  }
}
