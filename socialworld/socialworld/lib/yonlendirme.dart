// @dart=2.9
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:socialworld/modeller/kullanici.dart';
import 'package:socialworld/sayfalar/anasayfa.dart';
import 'package:socialworld/sayfalar/girissayfasi.dart';
import 'package:socialworld/servisler/yetkilendirme.dart';

class Yonlendirme extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final _yetkilendirmeservisi =
        Provider.of<YetkilendirmeServisi>(context, listen: false);
    return StreamBuilder(
        stream: _yetkilendirmeservisi.durumTakipcisi,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasData) {
            Kullanici aktifkullnaici = snapshot.data;
            _yetkilendirmeservisi.aktifkullaniciid = aktifkullnaici.id;
            return Anasayfa();
          } else {
            return GirisSayfasi();
          }
        });
  }
}
