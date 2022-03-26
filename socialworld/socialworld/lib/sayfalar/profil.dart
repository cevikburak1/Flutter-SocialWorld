// @dart=2.9
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:socialworld/modeller/gonderi.dart';
import 'package:socialworld/modeller/kullanici.dart';
import 'package:socialworld/sayfalar/profild%C3%BCzenle.dart';
import 'package:socialworld/servisler/firestoreservisi.dart';
import 'package:socialworld/servisler/yetkilendirme.dart';
import 'package:socialworld/widgetlar/gonderiKarti.dart';

class Profil extends StatefulWidget {
  final String profilsahibiId;

  const Profil({Key key, this.profilsahibiId}) : super(key: key);

  @override
  _ProfilState createState() => _ProfilState();
}

class _ProfilState extends State<Profil> {
  int gonderi = 0;
  int takipci = 0;
  int takip = 0;
  List<Gonderi> gonderilerrr = [];
  String gonderiStili = "Liste";
  String aktifkullaniciId;
  Kullanici profilsahibi;
  bool takipedildi = false;

  _takipcisayisigetir() async {
    int takipcisayisi =
        await FirestoreServisi().takipcisayisi(widget.profilsahibiId);
    if (mounted) {
      setState(() {
        takipci = takipcisayisi;
      });
    }
  }

  _gonderilerigetir() async {
    List<Gonderi> gonderiler =
        await FirestoreServisi().gonderilerigetir(widget.profilsahibiId);
    if (mounted) {
      setState(() {
        gonderilerrr = gonderiler;
        gonderi = gonderiler.length;
      });
    }
  }

  _takiipkontrol() async {
    bool takipvarmi = await FirestoreServisi().takipkontrol(
        aktifKullaniciId: aktifkullaniciId,
        profilSahibiId: widget.profilsahibiId);
    setState(() {
      takipedildi = takipvarmi;
    });
  }

  @override
  void initState() {
    super.initState();
    _takipcisayisigetir();
    _takipedilensayisi();
    _gonderilerigetir();
    aktifkullaniciId = Provider.of<YetkilendirmeServisi>(context, listen: false)
        .aktifkullaniciid;
    _takiipkontrol();
  }

  Widget _gonderilerigoster(Kullanici profilData) {
    if (gonderiStili == "Liste") {
      return ListView.builder(
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: gonderilerrr.length,
        itemBuilder: (context, index) {
          return GonderiKarti(
            kartgonderi: gonderilerrr[index],
            yayinlayan: profilData,
          );
        },
      );
    } else {
      List<GridTile> fayanslar = [];
      gonderilerrr.forEach((kartgonderi) {
        fayanslar.add(_fayansolustur(kartgonderi));
      });
      return GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          mainAxisSpacing: 2.0,
          crossAxisSpacing: 2.0,
          childAspectRatio: 1.0,
          physics: NeverScrollableScrollPhysics(),
          children: fayanslar);
    }
  }

  GridTile _fayansolustur(Gonderi gonderii) {
    return GridTile(
        child: Image.network(
      gonderii.gonderiResimUrl,
      fit: BoxFit.cover,
    ));
  }

  _takipedilensayisi() async {
    int takipedilen =
        await FirestoreServisi().takipedilensayisi(widget.profilsahibiId);
    if (mounted) {
      setState(() {
        takip = takipedilen;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(
            "Profil",
            style: TextStyle(color: Colors.black),
          ),
          backgroundColor: Colors.grey[100],
          actions: <Widget>[
            widget.profilsahibiId == aktifkullaniciId
                ? IconButton(
                    onPressed: _cikisyap,
                    icon: Icon(Icons.exit_to_app),
                    color: Colors.brown[900],
                  )
                : SizedBox(height: 0.0)
          ],
          iconTheme: IconThemeData(color: Colors.black)),
      body: FutureBuilder<Object>(
          future: FirestoreServisi().kullanicigeti(widget.profilsahibiId),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(child: CircularProgressIndicator());
            }

            profilsahibi = snapshot.data;
            return ListView(
              children: <Widget>[
                _profildetaylari(snapshot.data),
                _gonderilerigoster(snapshot.data)
              ],
            );
          }),
    );
  }

  Widget _profildetaylari(Kullanici profilData) {
    print("RESİM URL");
    print(profilData.fotoUrl);
    return Padding(
      padding: const EdgeInsets.all(18.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              CircleAvatar(
                backgroundColor: Colors.grey[300],
                radius: 50,
                backgroundImage: profilData.fotoUrl.isNotEmpty
                    ? NetworkImage(profilData.fotoUrl)
                    : AssetImage("assets/images/default.jpg"),
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    _sosyalsayac(baslik: "Gönderiler", sayi: gonderi),
                    _sosyalsayac(baslik: "Takipçi", sayi: takipci),
                    _sosyalsayac(baslik: "Takip", sayi: takip),
                  ],
                ),
              )
            ],
          ),
          SizedBox(height: 10.0),
          Column(
            children: <Widget>[
              Text(
                profilData.kullaniciAdi,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),
              ),
              Text(
                profilData.hakkimda ?? "Hakkimda",
                style: TextStyle(fontSize: 14.0),
              ),
            ],
          ),
          SizedBox(
            height: 25.0,
          ),
          widget.profilsahibiId == aktifkullaniciId
              ? _profiliduzenle()
              : takipbutonu(),
        ],
      ),
    );
  }

  Widget takipbutonu() {
    return takipedildi ? takipdenCikButonu() : takipetbutonu();
  }

  Widget takipetbutonu() {
    return Container(
      width: double.infinity,
      child: FlatButton(
        color: Theme.of(context).primaryColor,
        onPressed: () {
          FirestoreServisi().takipEt(
              profilSahibiId: widget.profilsahibiId,
              aktifKullaniciId: aktifkullaniciId);
          setState(() {
            takipedildi = true;
            takipci = takipci + 1;
          });
        },
        child: Text(
          "Takip Et",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget takipdenCikButonu() {
    return Container(
      width: double.infinity,
      child: OutlineButton(
        onPressed: () {
          FirestoreServisi().takiptenCik(
              profilSahibiId: widget.profilsahibiId,
              aktifKullaniciId: aktifkullaniciId);
          setState(() {
            takipedildi = false;
            takipci = takipci - 1;
          });
        },
        child: Text(
          "Takipden Çık",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _profiliduzenle() {
    return Container(
      width: double.infinity,
      child: OutlineButton(
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ProfilDuzenle(
                        profil: profilsahibi,
                      )));
        },
        child: Text("Profili Düzenle"),
      ),
    );
  }

  Widget _sosyalsayac({String baslik, int sayi}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Text(
          sayi.toString(),
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
        ),
        SizedBox(height: 2.0),
        Text(
          baslik,
          style: TextStyle(fontSize: 15.0),
        ),
      ],
    );
  }

  void _cikisyap() {
    Provider.of<YetkilendirmeServisi>(context, listen: false).cikisYap();
  }
}
