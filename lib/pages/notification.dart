import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fresh_front/constant/colors.dart';

class NotificationsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: greenColor,
        title: Text(
          "Notifications",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: StreamBuilder<QuerySnapshot>(
          // Récupérer les notifications en temps réel
          stream: FirebaseFirestore.instance
              .collection('Notifications')
              .orderBy('date', descending: true) // Tri par date
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text("Erreur de chargement des notifications"));
            }

            // Si le snapshot contient des données
            if (snapshot.hasData) {
              final notifications = snapshot.data!.docs;

              if (notifications.isEmpty) {
                return Center(child: Text("Aucune notification pour le moment."));
              }

              return ListView.builder(
                itemCount: notifications.length,
                itemBuilder: (context, index) {
                  var notification = notifications[index];
                  return Dismissible(
                    key: Key(notification.id), // Utilisation de l'ID de la notification pour le Dismissible
                    background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Icon(Icons.delete, color: Colors.white),
                      ),
                    ),
                    direction: DismissDirection.startToEnd,
                    onDismissed: (direction) {
                      // Supprimer la notification de Firestore
                      FirebaseFirestore.instance
                          .collection('Notifications')
                          .doc(notification.id)
                          .delete();

                      // Afficher un message Snackbar pour confirmer la suppression
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Notification supprimée."),
                        ),
                      );
                    },
                    child: Card(
                      elevation: 5, // Effet d'ombre
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15), // Coins arrondis
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.teal.withOpacity(0.1),
                          child: Icon(
                            Icons.notifications,
                            color: greenColor,
                          ),
                        ),
                        title: Text(
                          notification['title'] ?? 'Sans titre',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              notification['body'] ?? 'Sans message',
                              style: TextStyle(
                                color: Colors.black54,
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              notification['date'] ?? 'Date inconnue',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        trailing: Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.grey,
                          size: 16,
                        ),
                      ),
                    ),
                  );
                },
              );
            }

            return Center(child: Text("Aucune notification disponible."));
          },
        ),
      ),
    );
  }
}