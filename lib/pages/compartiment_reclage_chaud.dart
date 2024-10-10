import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fresh_front/constant/colors.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class PageCompartimentReclageChaud extends StatefulWidget {
  @override
  _PageCompartimentReclageChaudState createState() =>
      _PageCompartimentReclageChaudState();
}

class _PageCompartimentReclageChaudState
    extends State<PageCompartimentReclageChaud> {
  late bool isSliderEtatCircuit = false;

  void onChangeEtatCircuit(bool v) {
    setState(() {
      isSliderEtatCircuit = v;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: greenColor,
        title: Text(
          "Compartiment Chaud",
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
                              "20 °C",
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
              SizedBox(
                height: 20,
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
