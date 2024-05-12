class GroupModel {
  late String id;
  late String numFlot;
  late String ville;
  late int indexEnergieDebut;
  late int indexEnergieFinal;
  late int energieConso;

  GroupModel({
    this.id = '',
    required this.numFlot,
    required this.ville,
    required this.indexEnergieDebut,
    required this.indexEnergieFinal,
    required this.energieConso,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'numFlot': numFlot,
      'ville': ville,
      'indexEnergieDebut': indexEnergieDebut,
      'indexEnergieFinal': indexEnergieFinal,
      'energieConso': energieConso,
    };
  }

  factory GroupModel.fromJson(Map<String, dynamic> json) {
    return GroupModel(
      id: json['id'] ?? '',
      numFlot: json['numFlot'] ?? '',
      ville: json['ville'] ?? '',
      indexEnergieDebut: json['indexEnergieDebut'] ?? 0,
      indexEnergieFinal: json['indexEnergieFinal'] ?? 0,
      energieConso: json['energieConso'] ?? 0,
    );
  }
}
