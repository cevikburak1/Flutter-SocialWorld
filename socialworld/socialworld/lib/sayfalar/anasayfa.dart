// @dart=2.9
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:socialworld/sayfalar/ak%C4%B1%C5%9F.dart';
import 'package:socialworld/sayfalar/ara.dart';
import 'package:socialworld/sayfalar/duyurular.dart';
import 'package:socialworld/sayfalar/profil.dart';
import 'package:socialworld/sayfalar/y%C3%BCkle.dart';
import 'package:socialworld/servisler/yetkilendirme.dart';

class Anasayfa extends StatefulWidget {
  @override
  _AnasayfaState createState() => _AnasayfaState();
}

class _AnasayfaState extends State<Anasayfa> {
  int _aktifssayfano = 0;
  PageController _sayfakumandasi;

  @override
  void initState() {
    super.initState();
    _sayfakumandasi = PageController();
  }

  @override
  void dispose() {
    _sayfakumandasi.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String aktifkullaniciid =
        Provider.of<YetkilendirmeServisi>(context, listen: false)
            .aktifkullaniciid;

    return Scaffold(
      body: PageView(
        physics: NeverScrollableScrollPhysics(),
        onPageChanged: (acilansayfano) {
          setState(() {
            _aktifssayfano = acilansayfano;
          });
        },
        controller: _sayfakumandasi,
        children: <Widget>[
          Akis(),
          Ara(),
          Yukle(),
          Duyurular(),
          Profil(
            profilsahibiId: aktifkullaniciid,
          )
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _aktifssayfano,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey[600],
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), title: Text("Akış")),
          BottomNavigationBarItem(
              icon: Icon(Icons.explore), title: Text("Keşfet")),
          BottomNavigationBarItem(
              icon: Icon(Icons.file_upload), title: Text("Yükle")),
          BottomNavigationBarItem(
              icon: Icon(Icons.notifications), title: Text("Duyurular")),
          BottomNavigationBarItem(
              icon: Icon(Icons.person), title: Text("Profil")),
        ],
        onTap: (secilensayfano) {
          setState(() {
            _aktifssayfano = secilensayfano;
            _sayfakumandasi.jumpToPage(_aktifssayfano);
          });
        },
      ),
    );
  }
}
