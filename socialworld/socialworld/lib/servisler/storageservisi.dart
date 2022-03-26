//@dart=2.9
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

class StorageServisi {
  Reference _storage = FirebaseStorage.instanceFor().ref();
  String resimid;

  Future<String> gonderiResmiYukle(File resimDosyasi) async {
    resimid = Uuid().v4();
    //çekilen veya seçilen resim dosyası buraya parametre olarak gelecek
    UploadTask uploadTask = _storage
        .child("resimler/gonderiler/gonderi_$resimid.jpg")
        .putFile(resimDosyasi);
    TaskSnapshot snapshot = await uploadTask;
    String url = await snapshot.ref.getDownloadURL();
    return url;
  }

  Future<String> profilResmiYukle(File resimDosyasi) async {
    resimid = Uuid().v4();
    //çekilen veya seçilen resim dosyası buraya parametre olarak gelecek
    UploadTask uploadTask = _storage
        .child("resimler/profil/profil_$resimid.jpg")
        .putFile(resimDosyasi);
    TaskSnapshot snapshot = await uploadTask;
    String url = await snapshot.ref.getDownloadURL();
    return url;
  }

  void gonderiresmisil(String gonderiresmiurl) {
    RegExp arama = RegExp(r"gonderi_.+\.jpg");
    var eslesme = arama.firstMatch(gonderiresmiurl);
    String dosyaadi = eslesme[0];

    if (dosyaadi != null) {
      _storage.child("resimler/gonderiler/$dosyaadi").delete();
    }
  }
}
