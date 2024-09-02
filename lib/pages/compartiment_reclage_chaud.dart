import 'package:flutter/material.dart';
import 'package:fresh_front/widget/compartiment_widget.dart';

class PageCompartimentReclageChaud extends StatefulWidget {
  @override
  _PageCompartimentChaudReclageState createState() => _PageCompartimentChaudReclageState();
}

class _PageCompartimentChaudReclageState extends State<PageCompartimentReclageChaud> {
  // Variables de l'état pour le compartiment chaud
  bool _isExpandedIconChaud = false;
  bool _isExpandedTemperateurChaud= false;
  bool _isExpandedEtatCircuitChaud = false;
  
  bool _isSliderPlageChaud = false;
  bool _isSliderAdaptiveChaud = false;
  bool _isSliderEtatChaud = false;

  TextEditingController minControllerChaudPlage = TextEditingController(); 
  TextEditingController maxControllerChaudPlage = TextEditingController();
  TextEditingController minControllerChaudAdaptive = TextEditingController(text: '29');
  TextEditingController maxControllerChaudAdaptive = TextEditingController(text: '90');

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
    return Scaffold(
      appBar: AppBar(
        title: Text('Compartiment Chaud'),
      ),
      body: SingleChildScrollView(
        child: Text("reclage")
      ),
    );
  }
}
