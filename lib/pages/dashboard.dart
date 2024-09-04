import 'package:fresh_front/constant/colors.dart';
import 'package:fresh_front/pages/gps.dart';
import 'package:fresh_front/widget/card_cellule_widget.dart';
import 'package:fresh_front/widget/card_widget.dart';

import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:get/get.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  static const TextStyle optionStyle =
      TextStyle(fontSize: 16, fontWeight: FontWeight.bold);

  final List<String> imgList = [
    'assets/images/agriculteur.png',
    'assets/images/orange.png', // Remplace avec le chemin de ta deuxième image
    'assets/images/mangue_1.png', // Remplace avec le chemin de ta troisième image
  ];

  int _currentIndex = 0;
  //final CarouselController _carouselController = CarouselController();

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
                  temperature: "15",
                  title: "Refroidissement",
                ),
                const SizedBox(
                  width: 10,
                ),
                const CardWidget(
                  temperature: '50',
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
