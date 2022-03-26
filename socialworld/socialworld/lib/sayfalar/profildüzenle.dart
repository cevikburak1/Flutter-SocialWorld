//@dart=2.9
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:socialworld/modeller/kullanici.dart';
import 'package:socialworld/servisler/firestoreservisi.dart';
import 'package:socialworld/servisler/storageservisi.dart';
import 'package:socialworld/servisler/yetkilendirme.dart';

class ProfilDuzenle extends StatefulWidget {
  final Kullanici profil;

  const ProfilDuzenle({Key key, this.profil}) : super(key: key);
  @override
  _ProfilDuzenleState createState() => _ProfilDuzenleState();
}

class _ProfilDuzenleState extends State<ProfilDuzenle> {
  var formkey = GlobalKey<FormState>();
  String Kullaniciadi;
  String Hakkimda;
  File secilmisfoto;
  bool yukleniyor = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[300],
        title: Text(
          "Profili Düzenle",
          style: TextStyle(color: Colors.black),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.close,
            color: Colors.black,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.check,
              color: Colors.black,
            ),
            onPressed: () => guncelle(),
          ),
        ],
      ),
      body: ListView(
        children: <Widget>[
          yukleniyor ? LinearProgressIndicator() : SizedBox(height: 0.0),
          profilfoto(),
          kullanicibilgileri()
        ],
      ),
    );
  }

  guncelle() async {
    if (formkey.currentState.validate()) {
      setState(() {
        yukleniyor = true;
      });

      formkey.currentState.save();

      String profilFotoUrl;
      if (secilmisfoto == null) {
        profilFotoUrl = widget.profil.fotoUrl;
      } else {
        profilFotoUrl = await StorageServisi().profilResmiYukle(secilmisfoto);
      }

      String kullaniciid =
          Provider.of<YetkilendirmeServisi>(context, listen: false)
              .aktifkullaniciid;
      FirestoreServisi().kullaniciguncelle(
          KullaniciId: kullaniciid,
          kullaniciAdi: Kullaniciadi,
          fotoUrl: profilFotoUrl,
          hakkimda: Hakkimda);

      setState(() {
        yukleniyor = false;
      });
      Navigator.pop(context);
    }
  }

  profilfoto() {
    return Padding(
      padding: const EdgeInsets.only(top: 15.0, bottom: 20.0),
      child: Center(
        child: InkWell(
          onTap: galeridensec,
          child: CircleAvatar(
            backgroundImage: secilmisfoto == null
                ? NetworkImage(widget.profil.fotoUrl)
                : FileImage(secilmisfoto),
            backgroundColor: Colors.grey,
            radius: 55.0,
          ),
        ),
      ),
    );
  }

  galeridensec() async {
    var galeridenal = await ImagePicker().getImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 600,
        imageQuality: 80);
    setState(() {
      secilmisfoto = File(galeridenal.path);
    });
  }

  kullanicibilgileri() {
    return Form(
      key: formkey,
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(left: 30, right: 40, top: 60),
            child: TextFormField(
              initialValue: widget.profil.kullaniciAdi,
              decoration: InputDecoration(labelText: "Kullanici Adı"),
              validator: (girilendeger) {
                return girilendeger.trim().length <= 3
                    ? "Kullanici Adı en az 4 Karakter Olmalı"
                    : null;
              },
              onSaved: (girilendeger) {
                Kullaniciadi = girilendeger;
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 30, right: 40, top: 60),
            child: TextFormField(
              initialValue: widget.profil.hakkimda,
              decoration: InputDecoration(labelText: "Hakkımda"),
              validator: (girilendeger) {
                return girilendeger.trim().length <= 3
                    ? "Hakkımda Alanı en az 30 Karakter Olmalı"
                    : null;
              },
              onSaved: (girilendeger) {
                Hakkimda = girilendeger;
              },
            ),
          ),
        ],
      ),
    );
  }
}
