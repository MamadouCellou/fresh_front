import 'package:fresh_front/widget/compartiment_widget.dart';

import 'package:flutter/material.dart';

class  PageCompartiment extends StatefulWidget {
  @override
  _PageCompartimentState createState() => _PageCompartimentState();
}

class _PageCompartimentState extends State<PageCompartiment> {

  // Expand Froid
  bool _isExpandedIconFroid = false;
  bool _isExpandedTemperateurFroid= false;
  bool _isExpandedEtatCircuitFoid = false;

  // Expand Chaud
  bool _isExpandedIconChaud = false;
  bool _isExpandedTemperateurChaud= false;
  bool _isExpandedEtatCircuitChaud = false;
  
  // Slider Froid
  bool _isSliderPlageFroid = false;
  bool _isSliderAdaptiveFroid = false;
  bool _isSliderEtatFroid = false;

  // Slider Chaud
  bool _isSliderPlageChaud = false;
  bool _isSliderAdaptiveChaud = false;
  bool _isSliderEtatChaud = false;

  // controller Froid
  TextEditingController minControllerFroidPlage = TextEditingController();
  TextEditingController maxControllerFroidPlage = TextEditingController();
  TextEditingController minControllerFroidAdaptive = TextEditingController(
    text: '-2'
  );
  TextEditingController maxControllerFroidAdaptive = TextEditingController(
    text: '80'
  );

  // controller Chaud
  TextEditingController minControllerChaudPlage = TextEditingController(); 
  TextEditingController maxControllerChaudPlage = TextEditingController();
  TextEditingController minControllerChaudAdaptive = TextEditingController(
    text: '29'
  );
  TextEditingController maxControllerChaudAdaptive = TextEditingController(
    text: '90'
  );

  


  // setState Froid
  void _onPressedTemperatureFroid() {
    setState(() {
      _isExpandedTemperateurFroid = !_isExpandedTemperateurFroid;
    });
  }

  void _onPressedEtatCircuitFroid() {
    setState(() {
      _isExpandedEtatCircuitFoid = !_isExpandedEtatCircuitFoid;
    });
  }

  void _onExpandedIconFroid() {
    setState(() {
       _isExpandedIconFroid = !_isExpandedIconFroid;
    });
          
  }

  void _onChangeFroidPlage(bool v) {
    setState(() {
      _isSliderPlageFroid = v;
    });
  }
  void _onChangeFroidAdaptive(bool v) {
    setState(() {
      _isSliderAdaptiveFroid = v;
    });
  }

  void _onSliderEtatFroid(bool v) {
    setState(() {
      _isSliderEtatFroid = v;
    });
  }

 // setState Chaud
 void _onPressedTemperatureChaud() {
    setState(() {
      _isExpandedTemperateurChaud = !_isExpandedTemperateurChaud;
    });
  }

  void _onPressedEtatCircuitChaud() {
    setState(() {
      _isExpandedEtatCircuitChaud = !_isExpandedEtatCircuitChaud;
    });
  }

  void _onExpandedIconChaud() {
    setState(() {
       _isExpandedIconChaud = !_isExpandedIconChaud;
    });
          
  }

  void _onChangeChaudPlage(bool v) {
    setState(() {
      _isSliderPlageChaud = v;
    });
  }
  void _onChangeChaudAdaptive(bool v) {
    setState(() {
      _isSliderAdaptiveChaud = v;
    });
  }

  void _onSliderEtatChaud(bool v) {
    setState(() {
      _isSliderEtatChaud = v;
    });
  }

  
  

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          CompartmentWidget(
            title: "Compartiment Froid",
            temperature: "5°c",
            isExpandedIcon: _isExpandedIconFroid,
            isExpandedTemperateur: _isExpandedTemperateurFroid,
            isExpandedEtatCircuit: _isExpandedEtatCircuitFoid,
            isSliderPlage: _isSliderPlageFroid,
            isSliderAdaptive: _isSliderAdaptiveFroid,
            isSliderEtat: _isSliderEtatFroid,
            minControllerPlage: minControllerFroidPlage,
            maxControllerPlage: maxControllerFroidPlage,
            minControllerAdaptive: minControllerFroidAdaptive,
            maxControllerAdaptive: maxControllerFroidAdaptive,
            onExpandedIcon: _onExpandedIconFroid,
            onPressedEtatCircuit: _onPressedEtatCircuitFroid,
            onPressedTemperature: _onPressedTemperatureFroid,
            onChangeAdaptive: _onChangeFroidAdaptive,
            onChangePlage: _onChangeFroidPlage,
            onChangeEtat: _onSliderEtatFroid,
          ),
          const Divider(),
          CompartmentWidget(
            title: "Compartiment Chaud",
                    temperature: "45°c",
            isExpandedIcon: _isExpandedIconChaud,
            isExpandedTemperateur: _isExpandedTemperateurChaud,
            isExpandedEtatCircuit: _isExpandedEtatCircuitChaud,
            isSliderPlage: _isSliderPlageChaud,
            isSliderAdaptive: _isSliderAdaptiveChaud,
            isSliderEtat: _isSliderEtatChaud,
            minControllerPlage: minControllerChaudPlage,
            maxControllerPlage: maxControllerChaudPlage,
            minControllerAdaptive: minControllerChaudAdaptive,
            maxControllerAdaptive: maxControllerChaudAdaptive,
            onExpandedIcon: _onExpandedIconChaud,
            onPressedEtatCircuit: _onPressedEtatCircuitChaud,
            onPressedTemperature: _onPressedTemperatureChaud,
            onChangeAdaptive: _onChangeChaudAdaptive,
            onChangePlage: _onChangeChaudPlage,
            onChangeEtat: _onSliderEtatChaud,
          )
        ]
      ),
    );
  }
}
