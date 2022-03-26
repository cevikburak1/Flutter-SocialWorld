//@dart=2.9
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:socialworld/modeller/gonderi.dart';
import 'package:socialworld/modeller/kullanici.dart';
import 'package:socialworld/modeller/yorum.dart';
import 'package:socialworld/servisler/firestoreservisi.dart';
import 'package:socialworld/servisler/yetkilendirme.dart';
import 'package:timeago/timeago.dart' as timeago;

class Yorumlar extends StatefulWidget {
  final Gonderi gonderi;

  const Yorumlar({Key key, this.gonderi}) : super(key: key);
  @override
  _YorumlarState createState() => _YorumlarState();
}

class _YorumlarState extends State<Yorumlar> {
  TextEditingController yorumkontrolcusu = TextEditingController();
  @override
  void initState() {
    super.initState();
    timeago.setLocaleMessages('tr', timeago.TrMessages());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.grey[600]),
        backgroundColor: Colors.grey[100],
        title: Text(
          "Yorumlar",
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: Column(
        children: <Widget>[
          yorumlariGoster(),
          yorumlariekle(),
        ],
      ),
    );
  }

  yorumlariGoster() {
    return Expanded(
        child: StreamBuilder<QuerySnapshot>(
      stream: FirestoreServisi().yorumlariGeti(widget.gonderi.id),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircleAvatar());
        }

        return ListView.builder(
          itemCount: snapshot.data.documents.length,
          itemBuilder: (context, index) {
            Yorum yorum = Yorum.dokumandanUret(snapshot.data.documents[index]);
            return yorumsatiri(yorum);
          },
        );
      },
    ));
  }

  yorumsatiri(Yorum yorum) {
    return FutureBuilder<Kullanici>(
        future: FirestoreServisi().kullanicigeti(yorum.yayinlayanId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return SizedBox(
              height: 0.0,
            );
          }

          Kullanici yayinlayan = snapshot.data;
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.grey,
              backgroundImage: NetworkImage(yayinlayan.fotoUrl),
            ),
            title: RichText(
              text: TextSpan(
                text: yayinlayan.kullaniciAdi + " ",
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
                children: [
                  TextSpan(
                    text: yorum.icerik,
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.normal,
                        color: Colors.grey[600]),
                  )
                ],
              ),
            ),
            subtitle: Text(
                timeago.format(yorum.olusturulmazamani.toDate(), locale: "tr")),
          );
        });
  }

  yorumlariekle() {
    return ListTile(
      title: TextFormField(
        controller: yorumkontrolcusu,
        decoration: InputDecoration(hintText: "YORUM YAZ"),
      ),
      trailing: IconButton(
        icon: Icon(Icons.announcement),
        onPressed: yorumgonder,
      ),
    );
  }

  void yorumgonder() {
    String aktifkullaniciId =
        Provider.of<YetkilendirmeServisi>(context, listen: false)
            .aktifkullaniciid;
    FirestoreServisi().yorumekle(
        aktifkullaniciid: aktifkullaniciId,
        gonderi: widget.gonderi,
        icerik: yorumkontrolcusu.text);
    yorumkontrolcusu.clear();
  }
}
