/// Ein Wasser-Log-Eintrag (Menge, Zeitpunkt, Notizen).
class WaterLogModel {
  WaterLogModel({required this.amountMl, required this.loggedAt, this.notes});

  final int amountMl;
  final DateTime loggedAt;
  final String? notes;
}
