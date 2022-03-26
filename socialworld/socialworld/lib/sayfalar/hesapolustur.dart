//@dart=2.9
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:socialworld/modeller/kullanici.dart';
import 'package:socialworld/sayfalar/anasayfa.dart';
import 'package:socialworld/servisler/firestoreservisi.dart';
import 'package:socialworld/servisler/yetkilendirme.dart';

class Hesapolustur extends StatefulWidget {
  @override
  _HesapolusturState createState() => _HesapolusturState();
}

class _HesapolusturState extends State<Hesapolustur> {
  bool yukleniyor = false;
  final _formanahtari = GlobalKey<FormState>();
  final _scaffoldanahtar = GlobalKey<FormState>();
  String kullaniciadi;
  String mail;
  String sifre;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldanahtar,
        appBar: AppBar(
          title: Text("Hesap Oluştur"),
        ),
        body: ListView(
          children: <Widget>[
            yukleniyor
                ? LinearProgressIndicator()
                : SizedBox(
                    height: 0.0,
                  ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                  key: _formanahtari,
                  child: Column(
                    children: <Widget>[
                      TextFormField(
                        validator: (girilendeger) {
                          if (girilendeger.isEmpty) {
                            return "Kullanıcı adı Boş Geçilemez";
                          } else {
                            return null;
                          }
                        },
                        decoration: InputDecoration(
                          errorStyle: TextStyle(fontSize: 14),
                          hintText: "Kullanıcı adını giriniz",
                          prefixIcon: Icon(Icons.accessibility),
                        ),
                        onSaved: (girilendeger) {
                          kullaniciadi = girilendeger;
                        },
                      ),
                      SizedBox(
                        height: 20.0,
                      ),
                      TextFormField(
                        validator: (girilendeger) {
                          if (girilendeger.isEmpty) {
                            return "Mail adresi boş olamaz";
                          } else if (!girilendeger.contains("@")) {
                            return "Lütfen Uygun Bir mail adresi giriniz";
                          }
                          return null;
                        },
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          errorStyle: TextStyle(fontSize: 14),
                          hintText: "Mail Giriniz",
                          prefixIcon: Icon(Icons.mail_outlined),
                        ),
                        onSaved: (girilendeger) {
                          mail = girilendeger;
                        },
                      ),
                      SizedBox(
                        height: 20.0,
                      ),
                      TextFormField(
                        validator: (girilendeger) {
                          if (girilendeger.isEmpty) {
                            return "Şifre Boş Geçilemez";
                          } else if (girilendeger.trim().length < 4) {
                            return "Şifre 4 karakterde az olamaz";
                          }
                          return null;
                        },
                        obscureText: true,
                        decoration: InputDecoration(
                          errorStyle: TextStyle(fontSize: 14),
                          hintText: "Şifre Giriniz",
                          prefixIcon: Icon(Icons.lock),
                        ),
                        onSaved: (girilendeger) {
                          sifre = girilendeger;
                        },
                      ),
                      SizedBox(
                        height: 20.0,
                      ),
                      Container(
                        width: double.infinity,
                        child: FlatButton(
                          onPressed: _kullanicikaydi,
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
                    ],
                  )),
            )
          ],
        ));
  }

  void _kullanicikaydi() async {
    final _yetkilendirmeservisi =
        Provider.of<YetkilendirmeServisi>(context, listen: false);
    var _formState = _formanahtari.currentState;
    if (_formState.validate()) {
      _formState.save();
      setState() {
        yukleniyor = true;
      }

      try {
        Kullanici kullanici =
            await _yetkilendirmeservisi.maililekayit(mail, sifre);
        if (kullanici != null) {
          FirestoreServisi().kullaniciOlustur(
              id: kullanici.id, mail: mail, kullaniciaAdi: kullaniciadi);
        }
        Navigator.pop(context);
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
      hataMesaji = "Girdiğiniz eposta adresi geçersizdir!";
    } else if (hataKodu == "email-already-in-use") {
      hataMesaji = "Girdiğiniz eposta adresi zaten kayıtlıdır!";
      print(hataMesaji);
    } else if (hataKodu == "weak-password") {
      hataMesaji = "Girilen şifre çok zayıf!";
    } else if (hataKodu == "operation-not-allowed") {
      hataMesaji = "işlem onaylanmadı!";
    }
    var snackBar = SnackBar(
      content: Text(hataMesaji.toString()),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
