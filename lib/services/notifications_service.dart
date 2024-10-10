import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fresh_front/pages/notification.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:get/get.dart'; // Import Get pour la navigation
import 'package:intl/intl.dart';

class NotificationService {
  static final NotificationService _notificationService =
      NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  factory NotificationService() {
    return _notificationService;
  }

  NotificationService._internal();

  // Initialiser la notification avec demande de permission
  Future<void> initNotification() async {
    await _requestPermissions();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        print('Notification clicked: ${response.payload}');
        if (response.payload != null) {
          // Vérification du payload pour la redirection
          if (response.payload == 'go_to_notifications') {
            print('Redirecting to NotificationPage');
            Get.to(NotificationsPage()); // Redirection vers la page des notifications
          }
        }
      },
    );
  }

  // Méthode pour demander les permissions de notification
  Future<void> _requestPermissions() async {
    PermissionStatus status = await Permission.notification.status;

    if (!status.isGranted) {
      status = await Permission.notification.request();
    }

    if (status.isGranted) {
      print('Permission accordée');
    } else {
      print('Permission refusée');
    }
  }

  // Méthode pour afficher la notification
  Future<void> showNotification(
      {required int id,
      required String title,
      required String body,
      String? payload}) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'high_importance_channel',
      'High Importance Notifications',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    await flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      platformChannelSpecifics,
      payload: payload, // Inclure le payload pour la redirection
    );

    FirebaseFirestore firestore = FirebaseFirestore.instance;
    String formattedDate =
        DateFormat('yyyy-MM-dd – kk:mm').format(DateTime.now());
    print('Notification shown with payload: $payload');

    firestore.collection('Notifications').doc(id.toString()).set({
      'id': id,
      'title': title,
      'body': body,
      'date': formattedDate,
      'read': false,
    });

    print('Notification enregistrée dans la base');
  }

 
}
