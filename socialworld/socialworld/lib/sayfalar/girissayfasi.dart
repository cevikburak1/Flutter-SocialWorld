// @dart=2.9
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:socialworld/modeller/kullanici.dart';
import 'package:socialworld/sayfalar/hesapolustur.dart';
import 'package:socialworld/sayfalar/sifremiUnuttum.dart';
import 'package:socialworld/servisler/firestoreservisi.dart';
import 'package:socialworld/servisler/yetkilendirme.dart';

final _formAnahtari = GlobalKey<FormState>();
bool yukleniyor = false;
String mail, sifre;
final _scaffoldanahtar = GlobalKey<FormState>();

class GirisSayfasi extends StatefulWidget {
  @override
  _GirisSayfasiState createState() => _GirisSayfasiState();
}

class _GirisSayfasiState extends State<GirisSayfasi> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldanahtar,
        body: Stack(
          children: <Widget>[
            _sayfaelemanlari(),
            _yuklemeanimasyonu(),
          ],
        ));
  }

  Widget _yuklemeanimasyonu() {
    if (yukleniyor == true) {
      return Center(child: CircularProgressIndicator());
    } else {
      return Center();
    }
  }

  Widget _sayfaelemanlari() {
    return Form(
      key: _formAnahtari,
      child: ListView(
        padding: EdgeInsets.only(left: 20, right: 20, top: 60),
        children: <Widget>[
          FlutterLogo(
            size: 90,
          ),
          SizedBox(
            height: 80,
          ),
          TextFormField(
            validator: (girilendeger) {
              if (girilendeger.isEmpty) {
                return "E-Mail boş olamaz";
              } else if (!girilendeger.contains("@")) {
                return "Girilen Deger mail formatında olmalı";
              }
              return null;
            },
            onSaved: (girilendeger) => mail = girilendeger,
            autocorrect: true,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
                hintText: "E-mail adresinizi girin",
                errorStyle: TextStyle(fontSize: 14),
                prefixIcon: Icon(Icons.mail)),
          ),
          SizedBox(
            height: 40,
          ),
          TextFormField(
            validator: (girilendeger) {
              if (girilendeger.isEmpty) {
                return "Şifre boş olamaz";
              } else if (girilendeger.trim().length < 4) {
                return "Şifre en az 4 karakter olmalı";
              }
              return null;
            },
            obscureText: true,
            decoration: InputDecoration(
                errorStyle: TextStyle(fontSize: 14),
                hintText: "Şifrenizi girin",
                prefixIcon: Icon(Icons.lock)),
            onSaved: (girilendeger) => sifre = girilendeger,
          ),
          SizedBox(
            height: 40,
          ),
          Row(
            children: <Widget>[
              Expanded(
                child: FlatButton(
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => Hesapolustur()));
                  },
                  child: Text(
                    "Hesap Oluştur",
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  color: Theme.of(context).primaryColor,
                ),
              ),
              SizedBox(
                width: 10,
              ),
              Expanded(
                child: FlatButton(
                  onPressed: _girisyap,
                  child: Text(
                    "Giriş Yap",
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  color: Theme.of(context).primaryColorDark,
                ),
              )
            ],
          ),
          SizedBox(
            height: 20,
          ),
          Center(
            child: Column(
              children: <Widget>[
                Text(
                  "Veya",
                  style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[600]),
                ),
                SizedBox(height: 20.0),
                InkWell(
                  onTap: _googleilegiris,
                  child: Text(
                    "Google ile Giriş Yap",
                    style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[600]),
                  ),
                ),
                SizedBox(height: 20.0),
                InkWell(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => SifremiUnuttum()));
                  },
                  child: Text(
                    "Şifremi Unuttum",
                    style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[600]),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  void _girisyap() async {
    final _yetkilendirmeservisi =
        Provider.of<YetkilendirmeServisi>(context, listen: false);
    if (_formAnahtari.currentState.validate()) {
      _formAnahtari.currentState.save();
      setState(() {
        yukleniyor = true;
      });
      try {
        await _yetkilendirmeservisi.maililegiris(mail, sifre);
      } catch (hata) {
        setState() {
          yukleniyor = false;
        }

        uyariGoster(hataKodu: hata.code);
      }
    }
  }

  uyariGoster({hataKodu}) {
    String hataMesaji;

    if (hataKodu == "invalid-email") {
      hataMesaji = "E mail veya Şifre Hatalı";
    } else if (hataKodu == "user-disabled") {
      hataMesaji = "Kullanıcı Engellenmiş";
      print(hataMesaji);
    } else if (hataKodu == "wrong-password") {
      hataMesaji = "E mail veya Şifre Hatalı";
    } else if (hataKodu == "user-not-found") {
      hataMesaji = "E mail veya Şifre Hatalı";
    }
    var snackBar = SnackBar(
      content: Text(hataMesaji.toString()),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void _googleilegiris() async {
    final _yetkilendirmeservisi =
        Provider.of<YetkilendirmeServisi>(context, listen: false);
    setState(() {
      yukleniyor = true;
    });
    try {
      Kullanici kullinici = await _yetkilendirmeservisi.googleilegiris();
      if (kullinici != null) {
        Kullanici firestorekullanici =
            await FirestoreServisi().kullanicigeti(kullinici.id);
        if (firestorekullanici == null) {
          FirestoreServisi().kullaniciOlustur(
              id: kullinici.id,
              mail: mail,
              kullaniciaAdi: kullinici.kullaniciAdi,
              fotourl: kullinici.fotoUrl);
        }
      }
    } catch (hata) {
      setState(() {
        yukleniyor = false;
      });
      uyariGoster(hataKodu: hata.code);
    }
  }
}
