//@dart=2.9
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:socialworld/servisler/firestoreservisi.dart';
import 'package:socialworld/servisler/storageservisi.dart';
import 'package:socialworld/servisler/yetkilendirme.dart';

class Yukle extends StatefulWidget {
  @override
  _YukleState createState() => _YukleState();
}

class _YukleState extends State<Yukle> {
  File dosya;
  bool yukleniyor = false;

  TextEditingController aciklamatextkumandasi = TextEditingController();
  TextEditingController konumtextkumandasi = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return dosya == null ? yuklebutonu() : gonderiformu();
  }

  Widget yuklebutonu() {
    return IconButton(
        onPressed: () {
          fotografsec();
        },
        icon: Icon(
          Icons.file_upload,
          size: 50.0,
        ));
  }

  Widget gonderiformu() {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[100],
        title: Text(
          "Gönderi Oluştur",
          style: TextStyle(color: Colors.black),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
          onPressed: () {
            setState(() {
              dosya = null;
            });
          },
        ),
        actions: <Widget>[
          IconButton(
              onPressed: _gonderiolustur,
              icon: Icon(
                Icons.send,
                color: Colors.black,
              ))
        ],
      ),
      body: ListView(
        children: <Widget>[
          yukleniyor ? LinearProgressIndicator() : SizedBox(height: 0.0),
          AspectRatio(
            child: Image.file(
              dosya,
              fit: BoxFit.cover,
            ),
            aspectRatio: 30.0 / 25.0,
          ),
          SizedBox(height: 20.0),
          TextFormField(
            controller: aciklamatextkumandasi,
            decoration: InputDecoration(
              hintText: "Açıklama Ekle",
              contentPadding: EdgeInsets.only(left: 15, right: 15),
            ),
          ),
          TextFormField(
            controller: konumtextkumandasi,
            decoration: InputDecoration(
              hintText: "Konum",
              contentPadding: EdgeInsets.only(left: 15, right: 15),
            ),
          ),
        ],
      ),
    );
  }

  void _gonderiolustur() async {
    if (!yukleniyor) {
      setState(() {
        yukleniyor = true;
      });
      String resimurl = await StorageServisi().gonderiResmiYukle(dosya);
      String aktifkullaniciid =
          Provider.of<YetkilendirmeServisi>(context, listen: false)
              .aktifkullaniciid;

      await FirestoreServisi().gonderiOlustur(
          gonderiResmiUrl: resimurl,
          aciklama: aciklamatextkumandasi.text,
          yayinlayanid: aktifkullaniciid,
          konum: konumtextkumandasi.text);
      setState(() {
        yukleniyor = false;
        aciklamatextkumandasi.clear();
        konumtextkumandasi.clear();
        dosya = null;
      });
    } else {}
  }

  fotografsec() {
    return showDialog(
        context: context,
        builder: (context) {
          return SimpleDialog(
            title: Text("Gönderi Oluştur"),
            children: <Widget>[
              SimpleDialogOption(
                child: Text("Fotograf Çek"),
                onPressed: () {
                  fotocek();
                },
              ),
              SimpleDialogOption(
                child: Text("Galeriden  Yükle"),
                onPressed: () {
                  galeridensec();
                },
              ),
              SimpleDialogOption(
                child: Text("İptal"),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          );
        });
  }

  fotocek() async {
    Navigator.pop(context);
    var image = await ImagePicker().getImage(
        source: ImageSource.camera,
        maxWidth: 800,
        maxHeight: 600,
        imageQuality: 80);
    setState(() {
      dosya = File(image.path);
    });
  }

  galeridensec() async {
    Navigator.pop(context);
    var galeridenal = await ImagePicker().getImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 600,
        imageQuality: 80);
    setState(() {
      dosya = File(galeridenal.path);
    });
  }
}
