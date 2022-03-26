// @dart=2.9
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:socialworld/modeller/gonderi.dart';
import 'package:socialworld/modeller/kullanici.dart';
import 'package:socialworld/modeller/yorum.dart';
import 'package:socialworld/sayfalar/profil.dart';
import 'package:socialworld/sayfalar/yorumlar.dart';
import 'package:socialworld/servisler/firestoreservisi.dart';
import 'package:socialworld/servisler/yetkilendirme.dart';

class GonderiKarti extends StatefulWidget {
  final Gonderi kartgonderi;
  final Kullanici yayinlayan;

  const GonderiKarti({Key key, this.kartgonderi, this.yayinlayan})
      : super(key: key);
  @override
  _GonderiKartiState createState() => _GonderiKartiState();
}

class _GonderiKartiState extends State<GonderiKarti> {
  int begenisayisi = 0;
  bool begendin = false;
  String aktifkullaniciId;

  @override
  void initState() {
    super.initState();
    aktifkullaniciId = Provider.of<YetkilendirmeServisi>(context, listen: false)
        .aktifkullaniciid;
    begenisayisi = widget.kartgonderi.begeniSayisi;
    begeniVarmi();
  }

  begeniVarmi() async {
    bool begeniVarmi = await FirestoreServisi()
        .begenivarmi(widget.kartgonderi, aktifkullaniciId);
    print(begeniVarmi);
    print(begendin);
    if (begeniVarmi = true) {
      if (mounted) {
        setState(() {
          begendin = true;
        });
      }
    } else {
      begendin = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Column(
          children: <Widget>[_gonderibasligi(), _gonderiresmi(), _gonderialt()],
        ));
  }

  gonderisecenekleri() {
    showDialog(
        context: context,
        builder: (context) {
          return SimpleDialog(
            title: Text("Seçim Yap"),
            children: <Widget>[
              SimpleDialogOption(
                child: Text(
                  "Gönderiyi Sil",
                  style:
                      TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                  FirestoreServisi().gonderisil(
                      aktifkullanicId: aktifkullaniciId,
                      gonderi: widget.kartgonderi);
                  Navigator.pop(context);
                },
              ),
              SimpleDialogOption(
                child: Text("Vazgeç"),
                onPressed: () {
                  Navigator.pop(context);
                },
              )
            ],
          );
        });
  }

  Widget _gonderibasligi() {
    return ListTile(
      leading: Padding(
        padding: const EdgeInsets.only(left: 2.0),
        child: GestureDetector(
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => Profil(
                          profilsahibiId: widget.kartgonderi.yayinlayanId,
                        )));
          },
          child: CircleAvatar(
            backgroundColor: Colors.blue,
            backgroundImage: NetworkImage(widget.yayinlayan.fotoUrl),
          ),
        ),
      ),
      title: GestureDetector(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => Profil(
                        profilsahibiId: widget.kartgonderi.yayinlayanId,
                      )));
        },
        child: Text(
          widget.yayinlayan.kullaniciAdi,
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
      ),
      trailing: aktifkullaniciId == widget.kartgonderi.yayinlayanId
          ? IconButton(
              icon: Icon(Icons.more_vert),
              onPressed: gonderisecenekleri,
            )
          : null,
      contentPadding: EdgeInsets.all(9.0),
    );
  }

  Widget _gonderiresmi() {
    return GestureDetector(
      onDoubleTap: _begenidegistir,
      child: Image.network(
        widget.kartgonderi.gonderiResimUrl,
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.width,
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _gonderialt() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            IconButton(
              icon: !begendin
                  ? Icon(Icons.favorite_border, size: 35.0)
                  : Icon(Icons.favorite_sharp, size: 35.0, color: Colors.red),
              onPressed: _begenidegistir,
            ),
            IconButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => Yorumlar(
                              gonderi: widget.kartgonderi,
                            )));
              },
              icon: Icon(Icons.comment, size: 35.0),
            )
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(left: 10.0),
          child: Text(
            "${begenisayisi}  Begeni",
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(
          height: 2.0,
        ),
        Padding(
          padding: const EdgeInsets.only(left: 10.0),
          child: RichText(
            text: TextSpan(
              text: widget.yayinlayan.kullaniciAdi + " ",
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
              children: [
                TextSpan(
                  text: widget.kartgonderi.aciklama,
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.normal,
                      color: Colors.grey[600]),
                )
              ],
            ),
          ),
        )
      ],
    );
  }

  void _begenidegistir() {
    if (begendin == true) {
      setState(() {
        begendin = false;
        begenisayisi = begenisayisi - 1;
      });
      FirestoreServisi().gonderibegenme(widget.kartgonderi, aktifkullaniciId);
    } else {
      setState(() {
        begendin = true;
        begenisayisi = begenisayisi + 1;
      });
      FirestoreServisi().gonderibegen(widget.kartgonderi, aktifkullaniciId);
    }
  }
}
