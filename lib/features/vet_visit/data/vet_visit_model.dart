/// Ein Tierarzttermin (nur im Speicher, keine Persistenz-Funktion bisher).
class VetVisitModel {
  VetVisitModel({
    required this.date,
    required this.timeOfDay,
    required this.vetName,
    this.reasonForVisit = VetVisitReason.vaccination,
    this.prepNotes,
  });

  final DateTime date;
  final (int, int) timeOfDay; // (hour, minute)
  final String vetName;
  final VetVisitReason reasonForVisit;
  final String? prepNotes;
}

enum VetVisitReason { vaccination, checkup, emergency, surgery }
