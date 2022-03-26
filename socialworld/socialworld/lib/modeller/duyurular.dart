// @dart=2.9
import 'package:cloud_firestore/cloud_firestore.dart';

class Duyuru {
  final String id;
  final String aktiviteYapanId;
  final String aktivitetipi;
  final String gonderiId;
  final String gonderiFoto;
  final String yorum;
  final Timestamp olusuturlmazamani;

  Duyuru(
      {this.id,
      this.aktiviteYapanId,
      this.aktivitetipi,
      this.gonderiId,
      this.gonderiFoto,
      this.yorum,
      this.olusuturlmazamani});

  factory Duyuru.dokumandanUret(DocumentSnapshot doc) {
    var docData = doc.data();
    return Duyuru(
        id: doc.id,
        gonderiId: docData['gonderiId'],
        aktiviteYapanId: docData['aktiviteYapanId'],
        aktivitetipi: docData['aktiviteyapantipi'],
        gonderiFoto: docData['gonderiFoto'],
        yorum: docData['yorum'],
        olusuturlmazamani: docData["olusturulmazamani"]);
  }
}
