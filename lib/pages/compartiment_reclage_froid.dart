import 'package:flutter/material.dart';
import 'package:fresh_front/constant/colors.dart';
import 'package:fresh_front/widget/compartiment_widget.dart';

class PageCompartimentReclageFroid extends StatefulWidget {
  @override
  _PageCompartimentFroidReclageState createState() => _PageCompartimentFroidReclageState();
}

class _PageCompartimentFroidReclageState extends State<PageCompartimentReclageFroid> {
  // Variables de l'état pour le compartiment froid
  bool _isExpandedIconFroid = false;
  bool _isExpandedTemperateurFroid= false;
  bool _isExpandedEtatCircuitFoid = false;
  
  bool _isSliderPlageFroid = false;
  bool _isSliderAdaptiveFroid = false;
  bool _isSliderEtatFroid = false;

  TextEditingController minControllerFroidPlage = TextEditingController();
  TextEditingController maxControllerFroidPlage = TextEditingController();
  TextEditingController minControllerFroidAdaptive = TextEditingController(text: '-2');
  TextEditingController maxControllerFroidAdaptive = TextEditingController(text: '80');

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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              
            ],
          )
        ),
      ),
    );
  }
}
