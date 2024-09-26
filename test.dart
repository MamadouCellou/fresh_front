import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fresh_front/constant/colors.dart';
import 'package:fresh_front/constant/theme.dart';
import 'package:fresh_front/services/cubit/controle_cubit.dart';
import 'package:fresh_front/services/notifications_service.dart';
import 'package:fresh_front/services/service_mqtt.dart';
import 'package:intl/intl.dart';

class PageCompartimentReclageFroid extends StatefulWidget {
  @override
  _PageCompartimentReclageFroidState createState() => _PageCompartimentReclageFroidState();
}

class _PageCompartimentReclageFroidState extends State<PageCompartimentReclageFroid> {
  late TextEditingController maxTemperatureController;
  late TextEditingController minTemperatureController;

  final TextEditingController minControllerManuel = TextEditingController();
  final TextEditingController maxControllerManuel = TextEditingController();

  MqttService myService = MqttService();

  List<Map<String, dynamic>> products = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    maxTemperatureController = TextEditingController();
    minTemperatureController = TextEditingController();
    getProductsData();
  }

  @override
  void dispose() {
    maxTemperatureController.dispose();
    minTemperatureController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ControlCubit(),
      child: BlocConsumer<ControlCubit, ControlState>(
        listener: (context, state) {
          // Vous pouvez écouter des changements d'état ici
          maxTemperatureController.text = state.maxTemperature ?? '-';
          minTemperatureController.text = state.minTemperature ?? '-';
        },
        builder: (context, state) {
          final theme =
              state.isDarkMode ? AppTheme.darkTheme : AppTheme.lightTheme;

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
                                    "${myService.getTemperature()} °C",
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
                    Text(
                      "Reclage de temperature",
                      style: TextStyle(
                        fontSize: 20,
                        color: blackColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SwitchListTile(
                      value: state.isSliderPlageManuelle,
                      onChanged: (value) {
                        context.read<ControlCubit>().togglePlageManuelle(value);
                      },
                      activeColor: greenColor,
                      title: Text(
                        "Regler de façon manuelle",
                        style: TextStyle(
                          fontSize: 18,
                          color: blackColor,
                        ),
                      ),
                    ),
                    state.isSliderPlageManuelle
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
                                        controller: minControllerManuel,
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
                          )
                        : Container(),
                    state.isSliderPlageManuelle
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              TextButton(
                                onPressed: onAppliqueTemperatureManuelle,
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
                        : Container(),
                    const SizedBox(
                      height: 10,
                    ),
                    state.isLoadingTemperature
                        ? Center(
                            child: CircularProgressIndicator(
                            color: greenColor,
                          ))
                        : SwitchListTile(
                            value: state.isSliderPlageAuto,
                            onChanged: (value) {
                              context
                                  .read<ControlCubit>()
                                  .togglePlageAuto(value, products);
                            },
                            activeColor: greenColor,
                            title: Text(
                              "Regler de façon adaptive",
                              style: TextStyle(
                                fontSize: 18,
                                color: blackColor,
                              ),
                            ),
                          ),
                    state.isSliderPlageAuto
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
                                        controller: minTemperatureController,
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
                                        controller: maxTemperatureController,
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
                    SwitchListTile(
                      value: state.isSliderEtatCircuitFroid,
                      onChanged: (value) {
                        context.read<ControlCubit>().toggleRelayFroid(value);
                      },
                      activeColor: greenColor,
                      title: Container(
                        padding: const EdgeInsets.all(10.0),
                        decoration: BoxDecoration(
                          color: state.isSliderEtatCircuitFroid
                              ? greenColorTransparent
                              : redColorTransparent,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Center(
                          child: Text(
                            state.isSliderEtatCircuitFroid
                                ? "Allumé"
                                : "Eteint",
                            style: TextStyle(
                              fontSize: 20,
                              color: state.isSliderEtatCircuitFroid
                                  ? greenColor
                                  : redColor,
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
        },
      ),
    );
  }

  Future<void> getProductsData() async {
    try {
      final firestore = FirebaseFirestore.instance;

      // Chargement des produits frais
      final produitsQuery = await firestore.collection('ProduitsFrais').get();

      List<Map<String, dynamic>> fetchedProducts = [];
      for (var doc in produitsQuery.docs) {
        final productData = doc.data();
        final specifiqueId = productData['specifique_frais'];

        print("Spécifique ID: $specifiqueId");

        final specifiqueQuery = await firestore
            .collection('SpecifiqueProduitFroid')
            .where('id', isEqualTo: specifiqueId)
            .get();

        if (specifiqueQuery.docs.isNotEmpty) {
          final specifiqueData = specifiqueQuery.docs.first.data();

          print(
              "Données spécifiques trouvées: $specifiqueData");

          fetchedProducts.add({
            "name": specifiqueData['nom'],
            "temp_min": specifiqueData['temp_min'],
            "temp_max": specifiqueData['temp_max'],
          });
        } else {
          print("Produit non trouvé pour spécification ID: $specifiqueId");
        }
      }

      if (fetchedProducts.isEmpty) {
        print("Aucun produit avec plage de température trouvée.");
      }

      setState(() {
        products = fetchedProducts;
      });

      print(products);
    } catch (e) {
      print("Erreur lors de la récupération des données : $e");
    }
  }

  void onAppliqueTemperatureManuelle() {
    int temperatureMinManuelle = int.parse(minControllerManuel.text);
    int temperatureMaxManuelle = int.parse(maxControllerManuel.text);

    int temperatureMinOptimale = int.parse(minTemperatureController.text);
    int temperatureMaxOptimale = int.parse(maxTemperatureController.text);

    if (temperatureMinManuelle != temperatureMinOptimale ||
        temperatureMaxManuelle != temperatureMaxOptimale) {
      int notificationId = DateTime.now().millisecondsSinceEpoch % 100000;

      NotificationService().showNotification(
          id: notificationId, // 
          title: "Avertissement de Plage de Température",
          body:
              "La plage de température définie manuellement (${temperatureMinManuelle}°C - ${temperatureMaxManuelle}°C) est différente de la plage optimale (${temperatureMinOptimale}°C - ${temperatureMaxOptimale}°C).",
          payload: "go_to_notifications");

      enregistrerNotificationFirestore(
        id: notificationId
            .toString(), 
        title: "Avertissement de Plage de Température",
        body:
            "La plage de température définie manuellement (${temperatureMinManuelle}°C - ${temperatureMaxManuelle}°C) est différente de la plage optimale (${temperatureMinOptimale}°C - ${temperatureMaxOptimale}°C).",
      );
    }

    // Envoyer le message via MQTT comme avant
    // myService.sendMessage(temperatureMin: temperatureMinManuelle, temperatureMax: temperatureMaxManuelle);
  }

  void enregistrerNotificationFirestore(
      {required String id, required String title, required String body}) {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    // Obtenir l'heure actuelle formatée
    String formattedDate =
        DateFormat('yyyy-MM-dd – kk:mm').format(DateTime.now());

    // Créer une nouvelle notification avec un champ 'id' unique
    firestore.collection('Notifications').doc(id).set({
      'id': id, // ID unique de la notification
      'title': title,
      'body': body,
      'timestamp':
          formattedDate, 
      'read': false, 
    }).then((value) {
      print("Notification enregistrée avec succès avec l'ID : $id");
    }).catchError((error) {
      print("Erreur lors de l'enregistrement de la notification : $error");
    });
  }
}
