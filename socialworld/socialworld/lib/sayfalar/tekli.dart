// @dart=2.9
import 'package:flutter/material.dart';
import 'package:socialworld/modeller/gonderi.dart';
import 'package:socialworld/modeller/kullanici.dart';
import 'package:socialworld/servisler/firestoreservisi.dart';
import 'package:socialworld/widgetlar/gonderiKarti.dart';

class TekliGonderi extends StatefulWidget {
  final String gonderiId;
  final String gondersahibiid;

  const TekliGonderi({Key key, this.gonderiId, this.gondersahibiid})
      : super(key: key);

  @override
  _TekliGonderiState createState() => _TekliGonderiState();
}

class _TekliGonderiState extends State<TekliGonderi> {
  Gonderi gonderi;
  Kullanici kullanici;
  bool yukleniyor = true;

  @override
  void initState() {
    super.initState();
    gonderigetir();
  }

  gonderigetir() async {
    Gonderi gonderiii = await FirestoreServisi()
        .tekligonderi(widget.gonderiId, widget.gondersahibiid);
    if (gonderiii != null) {
      Kullanici gonderisahip =
          await FirestoreServisi().kullanicigeti(gonderiii.yayinlayanId);

      setState(() {
        gonderi = gonderiii;
        kullanici = gonderisahip;
        yukleniyor = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.grey,
          title: Text(
            "Tekli Gönderi",
            style: TextStyle(
              color: Colors.black,
            ),
          ),
          iconTheme: IconThemeData(color: Colors.black),
        ),
        body: !yukleniyor
            ? GonderiKarti(
                kartgonderi: gonderi,
                yayinlayan: kullanici,
              )
            : Center(child: CircularProgressIndicator()));
  }
}
