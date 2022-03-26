// @dart=2.9

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:socialworld/modeller/duyurular.dart';
import 'package:socialworld/modeller/gonderi.dart';
import 'package:socialworld/modeller/kullanici.dart';
import 'package:socialworld/servisler/storageservisi.dart';

class FirestoreServisi {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final DateTime zaman = DateTime.now();

  Future<void> kullaniciOlustur(
      {id, mail, kullaniciaAdi, fotourl = "", hakkimda}) async {
    await _firestore.collection("kullanıcılar").document(id).setData({
      "kullaniciAdi": kullaniciaAdi,
      "mail": mail,
      "FotoUrl": fotourl,
      "hakkimda": hakkimda,
      "olusturulmazamani": zaman
    });
  }

  Future<Kullanici> kullanicigeti(id) async {
    DocumentSnapshot doc =
        await _firestore.collection("kullanıcılar").document(id).get();

    //EGER BÖLYE BİR DÖKÜMAN VARSA = DOC.EXİSTS
    if (doc.exists) {
      var docData = doc.data();
      return Kullanici(
        id: doc.id,
        kullaniciAdi: docData['kullaniciAdi'],
        email: docData['email'],
        fotoUrl: docData['FotoUrl'],
        hakkimda: docData['hakkimda'],
      );
    }
    return null;
  }

  void kullaniciguncelle(
      {String KullaniciId,
      String kullaniciAdi,
      String fotoUrl = "",
      String hakkimda}) {
    _firestore.collection("kullanıcılar").document(KullaniciId).updateData({
      "kullaniciAdi": kullaniciAdi,
      "FotoUrl": fotoUrl,
      "hakkimda": hakkimda
    });
  }

  Future<int> takipcisayisi(kullaniciid) async {
    QuerySnapshot snapshot = await _firestore
        .collection("takipciler")
        .document(kullaniciid)
        .collection("kullanicininTakipcileri")
        .getDocuments();

    return snapshot.documents.length;
  }

  Future<int> takipedilensayisi(kullaniciid) async {
    QuerySnapshot snapshot = await _firestore
        .collection("takipedilenler")
        .document(kullaniciid)
        .collection("kullanicininTakipleri")
        .getDocuments();

    return snapshot.documents.length;
  }

  Future<void> gonderiOlustur(
      {gonderiResmiUrl, aciklama, yayinlayanid, konum}) async {
    await _firestore
        .collection("gonderiler")
        .document(yayinlayanid)
        .collection("kullaniciGonderileri")
        .add({
      "gonderiResimUrl": gonderiResmiUrl,
      "aciklama": aciklama,
      "yayinlayanId": yayinlayanid,
      "konum": konum,
      "begeniSayisi": 0,
      "olusturulmazamani": zaman
    });
  }

  Future<List<Gonderi>> gonderilerigetir(kullaniciId) async {
    QuerySnapshot snapshot = await _firestore
        .collection("gonderiler")
        .document(kullaniciId)
        .collection("kullaniciGonderileri")
        .orderBy("olusturulmazamani", descending: true)
        .getDocuments();

    List<Gonderi> gonderiler =
        snapshot.documents.map((doc) => Gonderi.dokumandanUret(doc)).toList();
    return gonderiler;
  }

  Future<List<Gonderi>> akisGonderileriniGetir(kullaniciId) async {
    QuerySnapshot snapshot = await _firestore
        .collection("akislar")
        .doc(kullaniciId)
        .collection("kullaniciAkisGonderileri")
        .orderBy("olusturulmazamani", descending: true)
        .get();
    List<Gonderi> gonderiler =
        snapshot.docs.map((doc) => Gonderi.dokumandanUret(doc)).toList();
    return gonderiler;
  }

  Future<void> gonderisil({String aktifkullanicId, Gonderi gonderi}) async {
    _firestore
        .collection("gonderiler")
        .document(aktifkullanicId)
        .collection("kullaniciGonderileri")
        .document(gonderi.id)
        .get()
        .then((DocumentSnapshot doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });

    //Gonderiye Ait Yorumu Silme
    QuerySnapshot yorumlarsnapshot = await _firestore
        .collection("yorumlar")
        .document(gonderi.id)
        .collection("gonderiYorumlari")
        .getDocuments();
    yorumlarsnapshot.documents.forEach((DocumentSnapshot doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });

    //Gönderiye Ait Duyuruları Silme
    QuerySnapshot duyurularSnapshot = await _firestore
        .collection("duyurular")
        .doc(gonderi.yayinlayanId)
        .collection("kullanicininDuyurulari")
        .where("gonderiId", isEqualTo: gonderi.id)
        .get();
    duyurularSnapshot.docs.forEach((DocumentSnapshot doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });

    //Storage Serviisinden Gönderi Resmi Sil
    StorageServisi().gonderiresmisil(gonderi.gonderiResimUrl);
  }

  Future<Gonderi> tekligonderi(String gonderiId, String gonderiSahibiId) async {
    DocumentSnapshot doc = await _firestore
        .collection("gonderiler")
        .document(gonderiSahibiId)
        .collection("kullaniciGonderileri")
        .document(gonderiId)
        .get();
    Gonderi gonderi = Gonderi.dokumandanUret(doc);
    return gonderi;
  }

  Future<void> gonderibegen(
      Gonderi kartgonderi, String aktifkullaniciid) async {
    var docref = _firestore
        .collection("gonderiler")
        .document(kartgonderi.yayinlayanId)
        .collection("kullaniciGonderileri")
        .document(kartgonderi.id);

    DocumentSnapshot doc = await docref.get();

    if (doc.exists) {
      Gonderi kartgonderi = Gonderi.dokumandanUret(doc);
      int yenibegenisayisi = kartgonderi.begeniSayisi + 1;
      docref.updateData({"begeniSayisi": yenibegenisayisi});

      _firestore
          .collection("begeniler")
          .document(kartgonderi.id)
          .collection("gonderiBegenileri")
          .document(aktifkullaniciid)
          .setData({});

      duyuruEkle(
        aktivitetipi: "Begeni",
        aktiviteYapanId: aktifkullaniciid,
        gonderi: kartgonderi,
        profilsahibiId: kartgonderi.yayinlayanId,
      );
    }
  }

  Future<void> gonderibegenme(
      Gonderi kartgonderi, String aktifkullaniciid) async {
    var docref = _firestore
        .collection("gonderiler")
        .document(kartgonderi.yayinlayanId)
        .collection("kullaniciGonderileri")
        .document(kartgonderi.id);

    DocumentSnapshot doc = await docref.get();

    if (doc.exists) {
      Gonderi kartgonderi = Gonderi.dokumandanUret(doc);
      int yenibegenisayisi = kartgonderi.begeniSayisi - 1;
      docref.updateData({"begeniSayisi": yenibegenisayisi});

      DocumentSnapshot dcbegeni = await _firestore
          .collection("begeniler")
          .document(kartgonderi.id)
          .collection("gonderiBegenileri")
          .document(aktifkullaniciid)
          .get();

      if (dcbegeni.exists) {
        dcbegeni.reference.delete();
      }
    }
  }

  Future<bool> begenivarmi(Gonderi kartgonderi, String aktifkullaniciid) async {
    DocumentSnapshot dcbegeni = await _firestore
        .collection("begeniler")
        .document(kartgonderi.id)
        .collection("gonderiBegenileri")
        .document(aktifkullaniciid)
        .get();

    if (dcbegeni.exists) {
      return true;
    } else {
      return false;
    }
  }

  Stream<QuerySnapshot> yorumlariGeti(String gonderiId) {
    return _firestore
        .collection("yorumlar")
        .document(gonderiId)
        .collection("gonderiYorumlari")
        .orderBy("olusturulmazamani", descending: true)
        .snapshots();
  }

  void yorumekle({
    String aktifkullaniciid,
    Gonderi gonderi,
    String icerik,
  }) {
    _firestore
        .collection("yorumlar")
        .document(gonderi.id)
        .collection("gonderiYorumlari")
        .add({
      "icerik": icerik,
      "yayinlayanId": aktifkullaniciid,
      "olusturulmazamani": zaman
    });

    //Yorumun Duyurusu OLucak Burada
    duyuruEkle(
        aktivitetipi: "Yorum",
        aktiviteYapanId: aktifkullaniciid,
        gonderi: gonderi,
        profilsahibiId: gonderi.yayinlayanId,
        yorum: icerik);
  }

  Future<List<Kullanici>> kullaniciara(String kelime) async {
    QuerySnapshot snapshot = await _firestore
        .collection("kullanıcılar")
        //.where("kullaniciAdi", isGreaterThanOrEqualTo: kelime)
        .getDocuments();
    List<Kullanici> kullanicilar = [];
    for (var doc in snapshot.documents) {
      print(Kullanici.dokumandanUret(doc, kelime: kelime));
      if (Kullanici.dokumandanUret(doc, kelime: kelime) != null) {
        kullanicilar.add(Kullanici.dokumandanUret(doc, kelime: kelime));
      } else {
        print("eses");
      }
    }

    /*List<Kullanici> kullanicilar = snapshot.documents
        .map((doc) => Kullanici.dokumandanUret(doc, kelime))
        .toList();*/
    return kullanicilar;
  }

  void takipEt({String aktifKullaniciId, String profilSahibiId}) {
    _firestore
        .collection("takipciler")
        .doc(profilSahibiId)
        .collection("kullanicininTakipcileri")
        .doc(aktifKullaniciId)
        .set({});
    _firestore
        .collection("takipedilenler")
        .doc(aktifKullaniciId)
        .collection("kullanicininTakipleri")
        .doc(profilSahibiId)
        .set({});

    duyuruEkle(
      aktivitetipi: "Takip",
      aktiviteYapanId: aktifKullaniciId,
      profilsahibiId: profilSahibiId,
    );
  }

  void takiptenCik({String aktifKullaniciId, String profilSahibiId}) {
    print(aktifKullaniciId);
    print(profilSahibiId);
    _firestore
        .collection("takipciler")
        .doc(profilSahibiId)
        .collection("kullanicininTakipcileri")
        .doc(aktifKullaniciId)
        .get()
        .then((DocumentSnapshot doc) {
      if (doc.exists) {
        doc.reference.delete();
        print("var");
      }
    });
    _firestore
        .collection("takipedilenler")
        .doc(aktifKullaniciId)
        .collection("kullanicininTakipleri")
        .doc(profilSahibiId)
        .get()
        .then((DocumentSnapshot doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
  }

  Future<bool> takipkontrol(
      {String aktifKullaniciId, String profilSahibiId}) async {
    DocumentSnapshot doc = await _firestore
        .collection("takipedilenler")
        .doc(aktifKullaniciId)
        .collection("kullanicininTakipleri")
        .doc(profilSahibiId)
        .get();

    if (doc.exists) {
      return true;
    }
    return false;
  }

  void duyuruEkle(
      {String aktiviteYapanId,
      String aktivitetipi,
      String profilsahibiId,
      String yorum,
      Gonderi gonderi}) {
    if (aktiviteYapanId == profilsahibiId) {
      return;
    }
    _firestore
        .collection("duyurular")
        .document(profilsahibiId)
        .collection("kullanicininDuyurulari")
        .add({
      "aktiviteYapanId": aktiviteYapanId,
      "aktiviteyapantipi": aktivitetipi,
      "yorum": yorum,
      "gonderiId": gonderi?.id,
      "gonderiFoto": gonderi?.gonderiResimUrl,
      "olusturulmazamani": zaman
    });
  }

  Future<List<Duyuru>> duyurlarigetir(String profilsahibiId) async {
    QuerySnapshot snapshot = await _firestore
        .collection("duyurular")
        .doc(profilsahibiId)
        .collection("kullanicininDuyurulari")
        .orderBy("olusturulmazamani", descending: true)
        .limit(20)
        .get();

    List<Duyuru> duyurular = [];

    snapshot.docs.forEach((DocumentSnapshot doc) {
      Duyuru duyuru = Duyuru.dokumandanUret(doc);
      duyurular.add(duyuru);
    });

    return duyurular;
  }
}
