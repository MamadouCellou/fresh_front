import 'package:fresh_front/constant/colors.dart';
import 'package:fresh_front/widget/plage_temperature_widget.dart';
import 'package:fresh_front/widget/subTitle_compartiment_widget.dart';
import 'package:fresh_front/widget/switch_etat_circuit_widget.dart';
import 'package:fresh_front/widget/switch_temperateur_widget.dart';
import 'package:flutter/material.dart';

class CompartmentWidget extends StatelessWidget {
  final String title;
  final String temperature;
  final bool isExpandedIcon; 
  final bool isExpandedTemperateur;
  final bool isExpandedEtatCircuit;

  final bool isSliderPlage;
  final bool isSliderAdaptive;

  final bool isSliderEtat;

  final TextEditingController minControllerPlage;
  final TextEditingController maxControllerPlage;
  final TextEditingController minControllerAdaptive;
  final TextEditingController maxControllerAdaptive;

  final void Function() onExpandedIcon;
  final void Function() onPressedEtatCircuit;
  final void Function() onPressedTemperature;

  final void Function(bool)? onChangePlage;
  final void Function(bool)? onChangeAdaptive;
  final Function(bool)? onChangeEtat;

  CompartmentWidget({
    super.key,
    required this.title,
    required this.temperature,
    required this.isExpandedIcon,
    required this.isExpandedTemperateur,
    required this.isExpandedEtatCircuit,
    required this.isSliderPlage,
    required this.isSliderAdaptive,
    required this.isSliderEtat,
    required this.minControllerPlage,
    required this.maxControllerPlage,
    required this.minControllerAdaptive,
    required this.maxControllerAdaptive,
    required this.onExpandedIcon,
    required this.onPressedEtatCircuit,
    required this.onPressedTemperature,
    required this.onChangePlage,
    required this.onChangeAdaptive,
    required this.onChangeEtat,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                color: blackColor,
                fontWeight: FontWeight.bold
              ),
            ),
            IconButton(
              icon: Icon(
                isExpandedIcon ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                color: greyColor,
              ),
              onPressed: onExpandedIcon,
            ),
          ],
        ),
        Visibility(
          visible: isExpandedIcon,
          child: AnimatedCrossFade(
            firstChild: SizedBox.shrink(), // No content when collapsed
            secondChild: Column(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Temperature actuelle",
                      style: TextStyle(fontSize: 18),
                    ),
                    Row(
                      children: [
                        Icon(Icons.thermostat),
                        Text(
                          temperature,
                          style: TextStyle(fontSize: 15),
                        ),
                      ],
                    ),
                  ],
                ),
                SubTitleCompartimentWidget(
                  isExpanded: isExpandedTemperateur,
                  title: "Temperature",
                  onPressed: onPressedTemperature
                ),
                Visibility(
                  visible: isExpandedTemperateur,
                  child: Column(
                    children: [
                       SwitchTemperateurWidget(
                        isSlider: isSliderPlage,
                        title: ("Plage Temperature"),
                        onChange: onChangePlage,
                       ),
                       isSliderPlage ? PlageTemperatureWidget(
                          minController: minControllerPlage,
                          maxController: maxControllerPlage,
                          isEnabled: true,
                        ) : Container(),
                      SwitchTemperateurWidget(
                        isSlider: isSliderAdaptive,
                        title: ("Temperature adaptive"),
                        onChange: onChangeAdaptive,
                      ),
                      isSliderAdaptive ? PlageTemperatureWidget(
                          minController: minControllerAdaptive,
                          maxController: maxControllerAdaptive,
                          isEnabled: false,
                        ) : Container(),
                      SubTitleCompartimentWidget(
                        isExpanded: isExpandedEtatCircuit,
                        title: "Etat du circuit",
                        onPressed: onPressedEtatCircuit,
                        numberPadding: 0,
                      ),
                      Visibility(
                        visible: isExpandedEtatCircuit,
                        child: SwitchEtatCircuitWidget(
                          isSlider: isSliderEtat,
                          title: "Etat du circuit",
                          onChange: onChangeEtat,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            crossFadeState: isExpandedIcon ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 300),
          ),
        ),
      ],
    );
  }
}
