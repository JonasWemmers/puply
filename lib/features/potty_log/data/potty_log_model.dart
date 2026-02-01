/// Ein Geschäft/Potty-Log-Eintrag (Typ, Qualität, Zeitpunkt, Notizen).
class PottyLogModel {
  PottyLogModel({
    required this.type,
    required this.quality,
    required this.loggedAt,
    this.abnormalities,
  });

  final PottyLogType type;
  final PottyLogQuality quality;
  final DateTime loggedAt;
  final String? abnormalities;
}

enum PottyLogType { pee, poop }

enum PottyLogQuality { hard, normal, soft }
