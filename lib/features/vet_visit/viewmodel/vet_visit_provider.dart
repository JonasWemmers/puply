import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:publy/features/vet_visit/data/vet_visit_model.dart';

/// Hält den nächsten Tierarzttermin; Persistenz im Firestore-Benutzerdokument (users/{uid}).
class VetVisitProvider extends ChangeNotifier {
  VetVisitModel? _nextVetVisit;

  VetVisitModel? get nextVetVisit => _nextVetVisit;

  /// Speichert den Termin im Profil des Users (users/{uid}) und aktualisiert den lokalen State.
  Future<void> setNextVetVisit(VetVisitModel? visit) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      _nextVetVisit = visit;
      notifyListeners();
      return;
    }
    final ref = FirebaseFirestore.instance.collection('users').doc(uid);
    if (visit == null) {
      await ref.update({
        'nextVetVisitDateTime': FieldValue.delete(),
        'nextVetVisitVetName': FieldValue.delete(),
        'nextVetVisitReason': FieldValue.delete(),
        'nextVetVisitPrepNotes': FieldValue.delete(),
      });
      _nextVetVisit = null;
    } else {
      final dt = DateTime(
        visit.date.year,
        visit.date.month,
        visit.date.day,
        visit.timeOfDay.$1,
        visit.timeOfDay.$2,
      );
      await ref.set({
        'nextVetVisitDateTime': Timestamp.fromDate(dt),
        'nextVetVisitVetName': visit.vetName,
        'nextVetVisitReason': visit.reasonForVisit.name,
        'nextVetVisitPrepNotes': visit.prepNotes ?? '',
      }, SetOptions(merge: true));
      _nextVetVisit = visit;
    }
    notifyListeners();
  }

  /// Entfernt den Termin aus dem User-Dokument und aus dem lokalen State.
  Future<void> clearNextVetVisit() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      try {
        await FirebaseFirestore.instance.collection('users').doc(uid).update({
          'nextVetVisitDateTime': FieldValue.delete(),
          'nextVetVisitVetName': FieldValue.delete(),
          'nextVetVisitReason': FieldValue.delete(),
          'nextVetVisitPrepNotes': FieldValue.delete(),
        });
      } catch (_) {}
    }
    _nextVetVisit = null;
    notifyListeners();
  }

  /// Lädt den nächsten Tierarzttermin aus dem User-Dokument (users/{uid}).
  Future<void> loadFromFirestore(String uid) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();
      final data = doc.data();
      final ts = data?['nextVetVisitDateTime'] as Timestamp?;
      final vetName = data?['nextVetVisitVetName'] as String?;
      if (ts == null || vetName == null || vetName.isEmpty) {
        _nextVetVisit = null;
        notifyListeners();
        return;
      }
      final dt = ts.toDate();
      final reasonStr = data?['nextVetVisitReason'] as String? ?? 'vaccination';
      final reason = VetVisitReason.values.firstWhere(
        (e) => e.name == reasonStr,
        orElse: () => VetVisitReason.vaccination,
      );
      final prepNotes = data?['nextVetVisitPrepNotes'] as String?;
      _nextVetVisit = VetVisitModel(
        date: DateTime(dt.year, dt.month, dt.day),
        timeOfDay: (dt.hour, dt.minute),
        vetName: vetName,
        reasonForVisit: reason,
        prepNotes: prepNotes?.isEmpty == true ? null : prepNotes,
      );
      notifyListeners();
    } catch (_) {
      _nextVetVisit = null;
      notifyListeners();
    }
  }
}
