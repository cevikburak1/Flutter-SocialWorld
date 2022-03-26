//@dart=2.9
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:socialworld/modeller/kullanici.dart';
import 'package:socialworld/servisler/firestoreservisi.dart';
import 'package:socialworld/servisler/yetkilendirme.dart';

class SifremiUnuttum extends StatefulWidget {
  @override
  State<SifremiUnuttum> createState() => _SifremiUnuttumState();
}

class _SifremiUnuttumState extends State<SifremiUnuttum> {
  bool yukleniyor = false;
  final _formanahtari = GlobalKey<FormState>();
  final _scaffoldanahtar = GlobalKey<FormState>();
  String mail;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldanahtar,
        appBar: AppBar(
          title: Text("Şifre Yenile"),
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
                      Container(
                        width: double.infinity,
                        child: FlatButton(
                          onPressed: _kullanicikaydi,
                          child: Text(
                            "Şifremi Sıfırla",
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
        await _yetkilendirmeservisi.sifremisifirla(mail);
        Navigator.pop(context);
      } catch (hata) {
        setState() {
          yukleniyor = false;
        }

        uyariGoster(hataKodu: hata.hashCode);
      }
    }
  }

  uyariGoster({hataKodu}) {
    String hataMesaji;

    if (hataKodu == "invalid-email") {
      hataMesaji = "Girdiğiniz eposta adresi geçersizdir!";
    } else if (hataKodu == "email-already-in-use") {
      hataMesaji = "Girdiğiniz eposta adresi zaten kayıtlıdır!";
    }
    var snackBar = SnackBar(
      content: Text(hataMesaji),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
