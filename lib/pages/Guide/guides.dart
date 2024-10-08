import 'package:flutter/material.dart';
import 'package:fresh_front/pages/Guide/aliment.dart';

class GuideConservation extends StatefulWidget {
  const GuideConservation({super.key});

  @override
  State<GuideConservation> createState() => _GuideConservationState();
}

class _GuideConservationState extends State<GuideConservation> {
  bool isFraisMode = true; // Mode de conservation par défaut

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3, // Nombre d'onglets

      child: Scaffold(
        appBar: AppBar(
          title: Text("Guide de conservation"),
          bottom: TabBar(
            dividerColor: Colors.transparent,
            tabs: [
              Tab(text: 'Fruits'),
              Tab(text: 'Légumes'),
              Tab(text: 'Tubercules'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            AlimentPage(type: "1"),
            AlimentPage(type: "2"),
            AlimentPage(type: "3"),
           /*  FruitsPage(), // Page pour les fruits
            LegumesPage(), // Page pour les légumes
            TuberculesPage(), // Page pour les tubercules */
          ],
        ),
      ),
    );
  }
}
