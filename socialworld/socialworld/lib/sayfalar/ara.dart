// @dart=2.9
import 'package:flutter/material.dart';
import 'package:socialworld/modeller/kullanici.dart';
import 'package:socialworld/sayfalar/profil.dart';
import 'package:socialworld/servisler/firestoreservisi.dart';

class Ara extends StatefulWidget {
  @override
  _AraState createState() => _AraState();
}

class _AraState extends State<Ara> {
  TextEditingController aramakontrol = TextEditingController();
  Future<List<Kullanici>> aramasomucu;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appbarolustur(),
      body: aramasomucu != null ? sonuclariGetir() : aramaYok(),
    );
  }

  AppBar appbarolustur() {
    return AppBar(
      titleSpacing: 0,
      backgroundColor: Colors.grey,
      title: TextFormField(
        onChanged: (girilendeger) {
          if (girilendeger.toString().length > 2) {
            setState(() {
              aramasomucu = FirestoreServisi().kullaniciara(girilendeger);
            });
          }
        },
        onFieldSubmitted: (girilendeger) {
          setState(() {
            aramasomucu = FirestoreServisi().kullaniciara(girilendeger);
          });
        },
        controller: aramakontrol,
        decoration: InputDecoration(
            prefixIcon: Icon(Icons.search, size: 30.0),
            suffixIcon: IconButton(
              icon: Icon(
                Icons.clear,
              ),
              onPressed: () {
                aramakontrol.clear();
                setState(() {
                  aramasomucu = null;
                });
              },
            ),
            border: InputBorder.none,
            fillColor: Colors.white,
            filled: true,
            hintText: "Kullanıcı Ara...",
            contentPadding: EdgeInsets.only(top: 16.0)),
      ),
    );
  }

  aramaYok() {
    return Center(child: Text("Kullanıcı ara"));
  }

  sonuclariGetir() {
    return FutureBuilder<List<Kullanici>>(
        future: aramasomucu,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.data.length == 0) {
            return Center(child: Text("Bu arama için sonuç bulunamadı!"));
          }

          return ListView.builder(
              itemCount: snapshot.data.length,
              itemBuilder: (context, index) {
                Kullanici kullanici = snapshot.data[index];
                return kullanicisatiri(kullanici);
              });
        });
  }

  kullanicisatiri(Kullanici kullanici) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => Profil(
                      profilsahibiId: kullanici.id,
                    )));
      },
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: NetworkImage(kullanici.fotoUrl),
        ),
        title: Text(
          kullanici.kullaniciAdi,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
