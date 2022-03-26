//@dart=2.9
import 'package:cloud_firestore/cloud_firestore.dart';

class Yorum {
  final String id;
  final String icerik;
  final String yayinlayanId;
  final Timestamp olusturulmazamani;

  Yorum({this.id, this.icerik, this.yayinlayanId, this.olusturulmazamani});

  factory Yorum.dokumandanUret(DocumentSnapshot doc) {
    var docData = doc.data();
    return Yorum(
        id: doc.id,
        icerik: docData['icerik'],
        olusturulmazamani: docData['olusturulmazamani'],
        yayinlayanId: docData['yayinlayanId']);
  }
}
