import 'package:flutter/material.dart';
import 'package:fresh_front/constant/colors.dart';
import 'package:fresh_front/getX/getx.dart';
import 'package:get/get.dart';

class PageCompartimentReclageFroid extends StatelessWidget {
  final controleur = Get.put(CompartimentFroidController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: greenColor,
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
                              "${controleur.myService.getTemperature()} °C",
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
              Obx(() => SwitchListTile(
                    value: controleur.isSliderPlageManuelle.value,
                    onChanged: (value) {
                      if (value) {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text("Confirmation"),
                              content: Text(
                                  "Attention!\nVoulez-vous désactiver le réglage adaptatif et continuer avec le réglage manuel ?"),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: Text("Annuler"),
                                ),
                                TextButton(
                                  onPressed: () {
                                    controleur.togglePlageManuelle(true);
                                    controleur.togglePlageAuto(false);
                                    Navigator.of(context).pop();
                                  },
                                  child: Text("Continuer"),
                                ),
                              ],
                            );
                          },
                        );
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
              Obx(() => controleur.isSliderPlageManuelle.value
                  ? Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 80),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Flexible(
                                child: TextField(
                                  controller: controleur.minControllerManuel,
                                  enabled: true,
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
                                  cursorColor: blackColor,
                                  controller: controleur.maxControllerManuel,
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
                  : Container()),
              Obx(() => controleur.isSliderPlageManuelle.value
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () {
                            controleur.onAppliqueTemperatureManuelle();
                          },
                          child: Text(
                            'Appliquer',
                            style: TextStyle(
                              fontSize: 13,
                              color: greenColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    )
                  : Container()),
              const SizedBox(height: 10),
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
              Obx(() => controleur.isSliderPlageAuto.value
                  ? Obx(
                      () => controleur.isLoadingTemperature.value
                          ? Center(
                              child: CircularProgressIndicator(
                              color: Colors.green,
                            ))
                          : Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 80),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Flexible(
                                        child: TextField(
                                          controller:
                                              controleur.minControllerOptimal,
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
                                          borderRadius:
                                              BorderRadius.circular(5),
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
                                          controller:
                                              controleur.maxControllerOptimal,
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
                            ),
                    )
                  : Container()),
              Obx(() => SwitchListTile(
                    value: controleur.isSliderEtatCircuitFroid.value,
                    onChanged: (value) {
                      controleur.toggleRelayFroid(value);
                    },
                    activeColor: greenColor,
                    title: Container(
                      padding: const EdgeInsets.all(10.0),
                      decoration: BoxDecoration(
                        color: controleur.isSliderEtatCircuitFroid.value
                            ? greenColorTransparent
                            : redColorTransparent,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Center(
                        child: Text(
                          controleur.isSliderEtatCircuitFroid.value
                              ? "Allumé"
                              : "Éteint",
                          style: TextStyle(
                            fontSize: 20,
                            color: controleur.isSliderEtatCircuitFroid.value
                                ? greenColor
                                : redColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
