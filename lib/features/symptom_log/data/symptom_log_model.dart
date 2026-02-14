/// Symptom-Log-Eintrag (Symptome, Schweregrad, Zeitpunkt, Notizen).
class SymptomLogModel {
  SymptomLogModel({
    required this.symptoms,
    required this.severity,
    required this.loggedAt,
    this.notes,
    this.hasPhoto = false,
  });

  final List<SymptomType> symptoms;
  final int severity;
  final DateTime loggedAt;
  final String? notes;
  final bool hasPhoto;
}

enum SymptomType { vomiting, noAppetite, diarrhea, lethargy, coughing, other }
