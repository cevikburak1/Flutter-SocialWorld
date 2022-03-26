// @dart=2.9
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:socialworld/modeller/duyurular.dart';
import 'package:socialworld/modeller/kullanici.dart';
import 'package:socialworld/sayfalar/profil.dart';
import 'package:socialworld/sayfalar/tekli.dart';
import 'package:socialworld/servisler/firestoreservisi.dart';
import 'package:socialworld/servisler/yetkilendirme.dart';
import 'package:timeago/timeago.dart' as timeago;

class Duyurular extends StatefulWidget {
  @override
  _DuyurularState createState() => _DuyurularState();
}

class _DuyurularState extends State<Duyurular> {
  List<Duyuru> _duyurular;
  String _aktifkullanicId;
  bool yukleniyor = true;

  @override
  void initState() {
    super.initState();
    _aktifkullanicId = Provider.of<YetkilendirmeServisi>(context, listen: false)
        .aktifkullaniciid;
    duyurularigetir();
    timeago.setLocaleMessages('tr', timeago.TrMessages());
  }

  Future<void> duyurularigetir() async {
    List<Duyuru> duyurular =
        await FirestoreServisi().duyurlarigetir(_aktifkullanicId);

    if (mounted) {
      setState(() {
        _duyurular = duyurular;
        yukleniyor = false;
      });
    }
  }

  duyurularigoster() {
    if (yukleniyor) {
      return Center(child: CircularProgressIndicator());
    }

    if (_duyurular.isEmpty) {
      return Center(child: Text("Hiç duyurunuz yok."));
    }

    return RefreshIndicator(
      onRefresh: duyurularigetir,
      child: ListView.builder(
        itemCount: _duyurular.length,
        itemBuilder: (context, index) {
          Duyuru duyuru = _duyurular[index];
          return duyurusatiri(duyuru);
        },
      ),
    );
  }

  duyurusatiri(Duyuru duyuru) {
    String mesaj = mesajolustur(duyuru.aktivitetipi);
    return FutureBuilder(
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return SizedBox(
              height: 0.0,
            );
          }

          Kullanici aktiviteyapan = snapshot.data;

          return ListTile(
            leading: InkWell(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => Profil(
                              profilsahibiId: duyuru.aktiviteYapanId,
                            )));
              },
              child: CircleAvatar(
                backgroundImage: NetworkImage(aktiviteyapan.fotoUrl),
              ),
            ),
            title: RichText(
              text: TextSpan(
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => Profil(
                                    profilsahibiId: duyuru.aktiviteYapanId,
                                  )));
                    },
                  text: "${aktiviteyapan.kullaniciAdi}",
                  style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 16),
                  children: [
                    TextSpan(
                        text: " $mesaj",
                        style: TextStyle(fontWeight: FontWeight.normal))
                  ]),
            ),
            subtitle: Text(timeago.format(duyuru.olusuturlmazamani.toDate(),
                locale: "tr")),
            trailing: gonderigorsel(
                duyuru.aktivitetipi, duyuru.gonderiFoto, duyuru.gonderiId),
          );
        },
        future: FirestoreServisi().kullanicigeti(duyuru.aktiviteYapanId));
  }

  gonderigorsel(String aktivitetipi, String gonderiFoto, String gonderiId) {
    if (aktivitetipi == "Takip") {
      return null;
    } else if (aktivitetipi == "Begeni" || aktivitetipi == "Yorum") {
      return GestureDetector(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => TekliGonderi(
                        gonderiId: gonderiId,
                        gondersahibiid: _aktifkullanicId,
                      )));
        },
        child: Image.network(
          gonderiFoto,
          width: 50,
          height: 50,
          fit: BoxFit.cover,
        ),
      );
    }
  }

  mesajolustur(String aktivitetipi) {
    if (aktivitetipi == "Begeni") {
      return "Gönderini Begenedi";
    } else if (aktivitetipi == "Takip") {
      return "Seni Takip Etti";
    } else if (aktivitetipi == "Yorum") {
      return "Gönderine Yorum Yaptı";
    } else {
      return "BOŞ 2";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey,
        title: Text(
          "Duyurular",
          style: TextStyle(
            color: Colors.black,
          ),
        ),
      ),
      body: duyurularigoster(),
    );
  }
}
