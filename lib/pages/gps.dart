import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as loc;
import 'package:geocoding/geocoding.dart';
import 'dart:async';

class MapPage extends StatefulWidget {
  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  loc.LocationData? _currentLocation;
  String _currentAddress = "Chargement...";
  late GoogleMapController _mapController;
  final loc.Location _location = loc.Location();
  MapType _currentMapType = MapType.normal;
  StreamSubscription<loc.LocationData>? _locationSubscription;

  @override
  void initState() {
    super.initState();
    _requestLocationPermission();
  }

  @override
  void dispose() {
    _locationSubscription
        ?.cancel(); // Annule l'abonnement pour éviter les appels à setState après dispose
    super.dispose();
  }

  Future<void> _requestLocationPermission() async {
    bool _serviceEnabled;
    loc.PermissionStatus _permissionGranted;

    _serviceEnabled = await _location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await _location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await _location.hasPermission();
    if (_permissionGranted == loc.PermissionStatus.denied) {
      _permissionGranted = await _location.requestPermission();
      if (_permissionGranted != loc.PermissionStatus.granted) {
        return;
      }
    }

    _locationSubscription =
        _location.onLocationChanged.listen((loc.LocationData currentLocation) {
      if (mounted) {
        setState(() {
          _currentLocation = currentLocation;
          _getAddressFromLatLng();
        });
      }
    });

    // Assure que la localisation est obtenue une fois
    _currentLocation = await _location.getLocation();
    _getAddressFromLatLng();
  }

  Future<void> _getAddressFromLatLng() async {
    if (_currentLocation != null) {
      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(
          _currentLocation!.latitude!,
          _currentLocation!.longitude!,
        );

        Placemark place = placemarks[0];

        if (mounted) {
          setState(() {
            _currentAddress =
                "${place.name}, ${place.subLocality}, ${place.locality}, ${place.administrativeArea}, ${place.country}";
          });
        }
      } catch (e) {
        print(e);
      }
    }
  }

  void _onMapTypeChanged(MapType mapType) {
    if (mounted) {
      setState(() {
        _currentMapType = mapType;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Position du dispositif"),
      ),
      body: _currentLocation == null
          ? Center(child: CircularProgressIndicator())
          : Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Adresse actuelle : $_currentAddress',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: LatLng(
                        _currentLocation!.latitude!,
                        _currentLocation!.longitude!,
                      ),
                      zoom: 15,
                    ),
                    myLocationEnabled: true,
                    myLocationButtonEnabled: true,
                    onMapCreated: (GoogleMapController controller) {
                      _mapController = controller;
                    },
                    mapType: _currentMapType,
                    markers: {
                      Marker(
                        markerId: MarkerId('currentLocation'),
                        position: LatLng(
                          _currentLocation!.latitude!,
                          _currentLocation!.longitude!,
                        ),
                        infoWindow: InfoWindow(title: 'Vous êtes ici'),
                      ),
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20),
                  child: _buildMapTypeSelector(),
                )
              ],
            ),
    );
  }

  Widget _buildMapTypeSelector() {
    return Row(
  mainAxisAlignment: MainAxisAlignment.center,
  children: [
    Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30), // Coins arrondis
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2), // Ombre légère pour un effet de profondeur
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3), // Position de l'ombre
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10), // Espacement interne pour le confort
      child: Row(
        children: [
          Icon(
            Icons.map_outlined, // Icône de carte minimaliste
            color: Colors.blueAccent, // Couleur accentuée
          ),
          const SizedBox(width: 8), // Espacement entre l'icône et le texte
          DropdownButton<MapType>(
            value: _currentMapType,
            dropdownColor: Colors.white, // Fond blanc pour le dropdown
            icon: Icon(Icons.arrow_drop_down_circle, color: Colors.blueAccent), // Icône personnalisée de dropdown
            style: TextStyle(
              color: Colors.black, // Couleur du texte
              fontSize: 15,
            ),
            items: [
              DropdownMenuItem(
                child: Text("Défaut"),
                value: MapType.normal,
              ),
              DropdownMenuItem(
                child: Text("Satellite"),
                value: MapType.satellite,
              ),
              DropdownMenuItem(
                child: Text("Relief"),
                value: MapType.terrain,
              ),
              DropdownMenuItem(
                child: Text("Hybride"),
                value: MapType.hybrid,
              ),
            ],
            onChanged: (value) {
              _onMapTypeChanged(value!);
            },
            underline: Container(), // Supprime la ligne par défaut du DropdownButton
          ),
        ],
      ),
    ),
  ],
);
  }
}
