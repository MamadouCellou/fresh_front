import 'package:flutter/material.dart';
import 'package:fresh_front/constant/colors.dart';
import 'package:fresh_front/widget/card_widget.dart';
import 'package:fresh_front/widget/plage_temperature_widget.dart';
import 'package:fresh_front/widget/switch_etat_circuit_widget.dart';
import 'package:fresh_front/widget/switch_temperateur_widget.dart';

class CompartimentReclageWidget extends StatelessWidget {

  final bool  isSliderPlageManuelle;
  final bool isSliderPlageAuto;
  final bool isSliderEtatCircuit;

  final TextEditingController  minControllerPlageManuelle;
  final TextEditingController  maxControllerPlageManuelle;
  final TextEditingController minControllerPlageAuto;
  final TextEditingController maxControllerPlageAuto;

  final void Function(bool)?  onChangePlageManuelle;
  final void Function(bool)? onChangePlageAuto;
  final void Function(bool)? onChangeEtatCircuit;

  const CompartimentReclageWidget({
    super.key,
    required this.isSliderPlageManuelle,
    required this.isSliderPlageAuto, 
    required this.isSliderEtatCircuit, 
    required this.minControllerPlageManuelle, 
    required this.maxControllerPlageManuelle, 
    required this.minControllerPlageAuto, 
    required this.maxControllerPlageAuto, 
    this.onChangePlageManuelle, 
    this.onChangePlageAuto, 
    this.onChangeEtatCircuit
  });

  

  @override
  Widget build(BuildContext context) {

    
    return Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 10,
              ),
              Center(
                child: CardWidget(
                  height: 150,
                  width: 200,
                  temperature: "20",
                  title: "Temperature actuelle",
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
                fontWeight: FontWeight.bold
              ),  
            ),
            SwitchTemperateurWidget(
              isSlider: isSliderPlageManuelle,
              title: "Regler de façon manuelle",
              onChange: onChangePlageManuelle ,
            ),
            isSliderPlageManuelle ? PlageTemperatureWidget(
              minController: minControllerPlageManuelle,
              maxController: maxControllerPlageManuelle
            ) : Container(),
            isSliderPlageManuelle ?
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: null,
                  child: Text(
                    'Appliquer',
                    style: TextStyle(
                      fontSize: 13,
                      color: greenColor, 
                      fontWeight: FontWeight.bold
                    ),
                  ),
                  ),
              ],
            ) : Container(),
            const SizedBox(
              height: 10,
            ),
            SwitchTemperateurWidget(
              isSlider: isSliderPlageAuto,
              title: "Regler de façon adaptive",
              onChange: onChangePlageAuto ,
            ),
            isSliderPlageAuto ? PlageTemperatureWidget(
              minController: minControllerPlageAuto,
              maxController: maxControllerPlageAuto
            ) : Container(),
            SwitchEtatCircuitWidget(
              isSlider: isSliderEtatCircuit,
              title: "Etat du circuit",
              onChange: onChangeEtatCircuit,
            ),
            ],
          );
  }
}