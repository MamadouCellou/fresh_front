import 'package:fresh_front/constant/colors.dart';
import 'package:fresh_front/pages/produits.dart';
import 'package:fresh_front/widget/card_cellule_widget.dart';
import 'package:fresh_front/widget/card_widget.dart';
import 'package:fresh_front/widget/text_field_search.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';


class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  static const TextStyle optionStyle =
      TextStyle(fontSize: 16, fontWeight: FontWeight.bold);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: TextFielSearch(),
        leadingWidth: double.infinity,
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              height: 20,
            ),
            const SizedBox(height: 20),
            // Add an image at the top of the column
            Image.asset(
              'assets/images/agriculteur.png', // Path to your image asset
              height: 150, // Adjust height as needed
              width: double.infinity, // Makes the image take full width
              fit: BoxFit.cover, // Adjusts the image to cover the area
            ),
            const Text(
              "Vu d'ensemble des compartiments",
              style: optionStyle,
            ),
            const SizedBox(
              height: 20,
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Status des produits",
                  style: optionStyle,
                ),
                IconButton(
                  onPressed: () {
                    Get.to(PageProduits());
                  },
                  icon: Icon(
                    Icons.arrow_right,
                    color: greenColor,
                    size: 30,
                  ),
                ),
              ],
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
