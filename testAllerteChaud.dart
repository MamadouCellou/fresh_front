import 'dart:async'; // Ajoute ceci pour utiliser Timer
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import pour Firestore

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('On Background Message: ${message.messageId}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  Timer? timer;

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
    // Démarrer la vérification toutes les 24 heures
    timer = Timer.periodic(Duration(seconds: 3), (Timer t) => checkProductsExpiry());
  }

  Future<void> _initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> showNotification(String title, String body) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'your_channel_id',
      'your_channel_name',
      channelDescription: 'your_channel_description',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: false,
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      platformChannelSpecifics,
      payload: 'item x',
    );
  }

  Future<void> checkProductsExpiry() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('ProduitsChauds') // Change cela selon ta collection
        .get();

    for (var doc in snapshot.docs) {
      DateTime expirationDate = doc['expiration_date'].toDate();
      if (expirationDate.isAfter(DateTime.now())) {
        await showNotification(
          'Produit Expiré',
          'Le produit ${doc['description']} a expiré.',
        );
      }
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Notification App',
      home: Scaffold(
        appBar: AppBar(
          title: Text('Gestion des Produits'),
        ),
        body: Center(
          child: Text('Bienvenue dans l\'application de gestion des produits!'),
        ),
      ),
    );
  }
}
