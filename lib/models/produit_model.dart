class Produit {
  final String categorieProduit;
  final String description;
  final String id;
  final String image;
  final String nom;
  final String tempMin;
  final String tempMax;

  Produit({
    required this.categorieProduit,
    required this.description,
    required this.id,
    required this.image,
    required this.nom,
    required this.tempMin,
    required this.tempMax,
  });
}

class ProduitChaud {
  final String categorieProduit;
  final String description;
  final String id;
  final String image;
  final String nom;
  final String dure;
  final String temp_soleil_min;
  final String temp_soleil_max;
  final String dure_soleil_min;
  final String dure_soleil_max;

  ProduitChaud({
    required this.categorieProduit,
    required this.description,
    required this.id,
    required this.image,
    required this.nom,
    required this.dure,
    required this.dure_soleil_min,
    required this.dure_soleil_max,
    required this.temp_soleil_min,
    required this.temp_soleil_max,
  });
}
