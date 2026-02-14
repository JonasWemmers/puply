/// Walk-Log-Eintrag (Dauer, Typ, Route, GPS-Flag, Zeitpunkt, Notizen).
class WalkLogModel {
  WalkLogModel({
    required this.durationMinutes,
    required this.walkType,
    required this.routeName,
    required this.trackGps,
    required this.loggedAt,
    this.notes,
    this.hasPhoto = false,
  });

  final int durationMinutes;
  final WalkType walkType;
  final String routeName;
  final bool trackGps;
  final DateTime loggedAt;
  final String? notes;
  final bool hasPhoto;
}

enum WalkType { quickBreak, standardWalk }
