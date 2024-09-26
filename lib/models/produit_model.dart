class Produit {
  String categorieProduit;  // Catégorie du produit
  String description;       // Description du produit
  String id;                // Identifiant unique du produit
  String image;             // URL de l'image du produit
  String modeConservation;  // Mode de conservation (frais ou chaud)
  String nom;               // Nom du produit
  String tempMax;           // Température maximale de conservation
  String tempMin;           // Température minimale de conservation

  Produit({
    required this.categorieProduit,
    required this.description,
    required this.id,
    required this.image,
    required this.modeConservation,
    required this.nom,
    required this.tempMax,
    required this.tempMin,
  });

  // Méthode pour créer un produit à partir d'une carte (Map) (utile avec Firestore)
  factory Produit.fromMap(Map<String, dynamic> map) {
    return Produit(
      categorieProduit: map['categorie_produit'] ?? '',
      description: map['description'] ?? '',
      id: map['id'] ?? '',
      image: map['image'] ?? '',
      modeConservation: map['mode_conservation'] ?? '',
      nom: map['nom'] ?? '',
      tempMax: map['temp_max'] ?? '',
      tempMin: map['temp_min'] ?? '',
    );
  }

  // Méthode pour convertir un produit en carte (Map)
  Map<String, dynamic> toMap() {
    return {
      'categorie_produit': categorieProduit,
      'description': description,
      'id': id,
      'image': image,
      'mode_conservation': modeConservation,
      'nom': nom,
      'temp_max': tempMax,
      'temp_min': tempMin,
    };
  }
}
