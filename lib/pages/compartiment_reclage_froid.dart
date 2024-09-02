import 'package:flutter/material.dart';
import 'package:fresh_front/constant/colors.dart';
import 'package:fresh_front/widget/compartiment_reclage_widget.dart';


class PageCompartimentReclageFroid extends StatefulWidget {
  @override
  _PageCompartimentFroidReclageState createState() => _PageCompartimentFroidReclageState();
}

class _PageCompartimentFroidReclageState extends State<PageCompartimentReclageFroid> {
  // Variables de l'état pour le compartiment froid

  late bool isSliderPlageManuelle = false;
  late bool isSliderPlageAuto = false;
  late bool isSliderEtatCircuit = false;

  TextEditingController minControllerPlageManuelle = TextEditingController();
  TextEditingController maxControllerPlageManuelle = TextEditingController();
  TextEditingController minControllerPlageAuto = TextEditingController(text: '-2');
  TextEditingController maxControllerPlageAuto = TextEditingController(text: '80');

 onChangePlageManuelle (bool v) {
  setState(() {
    isSliderPlageManuelle = v;
  });
 }

 onChangePlageAuto (bool v) {
  setState(() {
    isSliderPlageAuto = v;
  });
 }

 onChangeEtatCircuit(bool v) {
  setState(() {
    isSliderEtatCircuit = v;
  });
 }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: greenColor,
        title:Text(
            "Compartiment Froid",
             style: TextStyle(
              fontSize: 20,
              color: whiteColor,
              fontWeight: FontWeight.bold
             ),
      ),
      ),
      body:  SingleChildScrollView(
        child: Padding(
          padding:  EdgeInsets.all(20.0),
          child: CompartimentReclageWidget(
            isSliderPlageManuelle: isSliderPlageManuelle,
            isSliderPlageAuto: isSliderPlageAuto, 
            isSliderEtatCircuit: isSliderEtatCircuit,
            minControllerPlageManuelle: minControllerPlageManuelle,
            maxControllerPlageManuelle: maxControllerPlageManuelle,
            minControllerPlageAuto: minControllerPlageAuto,
            maxControllerPlageAuto: maxControllerPlageAuto,
            onChangePlageManuelle: onChangePlageManuelle,
            onChangePlageAuto: onChangePlageAuto,
            onChangeEtatCircuit: onChangeEtatCircuit,
          )
        ),
      ),
    );
  }
}
