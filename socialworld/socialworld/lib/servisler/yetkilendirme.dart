//@dart=2.9
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:socialworld/modeller/kullanici.dart';

class YetkilendirmeServisi {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  String aktifkullaniciid;

  Kullanici _kullaniciOlustur(User kullanici) {
    // ignore: unnecessary_null_comparison
    return kullanici == null ? null : Kullanici.firebasedenUret(kullanici);
  }

  Stream<Kullanici> get durumTakipcisi {
    return _firebaseAuth.authStateChanges().map(_kullaniciOlustur);
  }

  Future<Kullanici> maililekayit(String eposta, String sifre) async {
    var giriskarti = await _firebaseAuth.createUserWithEmailAndPassword(
        email: eposta, password: sifre);
    return _kullaniciOlustur(giriskarti.user);
  }

  Future<Kullanici> maililegiris(String eposta, String sifre) async {
    var giriskarti = await _firebaseAuth.signInWithEmailAndPassword(
        email: eposta, password: sifre);
    return _kullaniciOlustur(giriskarti.user);
  }

  Future<void> cikisYap() {
    return _firebaseAuth.signOut();
  }

  Future<void> sifremisifirla(String eposta) async {
    await _firebaseAuth.sendPasswordResetEmail(email: eposta);
  }

  Future<Kullanici> googleilegiris() async {
    GoogleSignInAccount googlehesabi = await GoogleSignIn().signIn();
    GoogleSignInAuthentication googleyetkikarti =
        await googlehesabi.authentication;
    AuthCredential sifresizgirisbelgesi = GoogleAuthProvider.getCredential(
        idToken: googleyetkikarti.idToken,
        accessToken: googleyetkikarti.accessToken);
    UserCredential giriskarti =
        await _firebaseAuth.signInWithCredential(sifresizgirisbelgesi);
    return _kullaniciOlustur(giriskarti.user);
  }
}
