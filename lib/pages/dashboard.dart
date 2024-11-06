import 'package:fresh_front/constant/variable_globales.dart';
import 'package:fresh_front/services/service_mqtt_aws_iot_core.dart';
import 'package:fresh_front/widget/card_widget.dart';

import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  static const TextStyle optionStyle =
      TextStyle(fontSize: 25, fontWeight: FontWeight.bold);

  final List<String> imgList = [
    'assets/images/orange.png', // Remplace avec le chemin de ta deuxième image
    'assets/images/mangue_1.png', // Remplace avec le chemin de ta troisième image
    'assets/images/pomme.png', // Remplace avec le chemin de ta troisième image
    'assets/images/fraise.png', // Remplace avec le chemin de ta troisième image
  ];

  int _currentIndex = 0;
  //final CarouselController _carouselController = CarouselController();

  MqttService myService= MqttService();
  
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    myService.connect();
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
                    width: 400,
                    height: 400,
                    decoration: BoxDecoration(
                        image: DecorationImage(
                            image: AssetImage(imgList[index]),
                            fit: BoxFit.contain)),
                  );
                },
                options: CarouselOptions(
                  initialPage: 0,
                  autoPlay: true,
                  enlargeCenterPage: true,
                  height: 300,
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
              padding: const EdgeInsets.only(top:20,bottom: 20),
              child: Text(
                "Status des compartiments",
                style: optionStyle,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CardWidget(
                  temperature: "${temperatureFroid}",
                  title: "Refroidissement",
                ),
                const SizedBox(
                  width: 10,
                ),
                 CardWidget(
                  temperature: "${temperatureChaud}",
                  title: "Séchage",
                ),
              ],
            ),
            const SizedBox(
              height: 20,
            ),
    
          ],
        ),
      ),
    );
  }
}