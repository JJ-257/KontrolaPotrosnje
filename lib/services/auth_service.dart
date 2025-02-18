
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'firestore_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<UserCredential?> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null; // korisnik odustao
      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      return await _auth.signInWithCredential(credential);
    } catch (e) {
      print("Greška: $e");
      return null;
    }
  }

  // Future<void> signOut() async {
  //   await _googleSignIn.signOut();
  //   await _auth.signOut();
  // }

  Stream<User?> get userChanges => _auth.userChanges();

  //
  // Future<void> deleteAccount() async {
  //   final user = _auth.currentUser;
  //   if (user != null) {
  //     // Potrebna reautentikacija prije brisanja
  //     await user.delete();
  //   }
  // }
// // auth_service.dart
//   Future<void> deleteAccount() async {
//     try {
//       final user = _auth.currentUser;
//
//       // Potrebna reautentikacija za Google provider
//       if (user != null && user.providerData.any((info) => info.providerId == 'google.com')) {
//         await _auth.signInWithPopup(GoogleAuthProvider());
//       }
//
//       // Brisanje Firestore podataka prvo
//       await FirestoreService().deleteUserData(user!.uid);
//
//       // Brisanje auth računa
//       await user.delete();
//
//       // Odjava
//       await _auth.signOut();
//     } on FirebaseAuthException catch (e) {
//       throw Exception(e.message ?? 'Greška pri brisanju računa');
//     }
// //   }
//   Future<void> deleteAccount() async {
//     final user = _auth.currentUser;
//     if (user != null) {
//       // Potrebna reautentikacija za sigurno brisanje
//       await user.delete();
//     }
//   }

  Future<void> signOut() async {
    // Očisti sve providerske podatke
    await _auth.signOut();

    // Očisti Google sign-in cache
    await GoogleSignIn().signOut();

    // Očisti Facebook sign-in cache (ako se koristi)
    // await FacebookAuth.instance.logOut();

    // Dodatni cleanup za druge providere
  }

  // Future<void> reauthenticateGoogleUser(User user) async {
  //   try {
  //     // Primjer za Google provider
  //     final credential = await GoogleAuthProvider.credential(
  //       accessToken: (await user.getIdToken()),
  //     );
  //     await user.reauthenticateWithCredential(credential);
  //   } catch (e) {
  //     throw Exception('Reautentikacija potrebna za brisanje računa');
  //   }
  // }
  Future<void> reauthenticateGoogleUser(User user) async {
    try {
      // 1. Pokreni Google sign-in dijalog
      final googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        // Korisnik je odustao
        throw Exception('Korisnik je odustao od Google prijave');
      }

      // 2. Dohvati GoogleAuth objekt (sadrži ID token i access token)
      final googleAuth = await googleUser.authentication;

      // 3. Kreiraj credential iz GoogleAuth providera
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // 4. Reautentificiraj korisnika
      await user.reauthenticateWithCredential(credential);
    } catch (e) {
      throw Exception('Reautentikacija nije uspjela: $e');
    }
  }

  Future<void> deleteAccount() async {
    final user = _auth.currentUser;
    // if (user != null) {
    // Osiguraj reautentikaciju za sigurno brisanje
    // await _reauthenticateUser(user);
    //  await user.delete();

    if (user == null) return;

    // 1. Reautenticiraj
    if (user.providerData.any((p) => p.providerId == 'google.com')) {
      await reauthenticateGoogleUser(user);
    }

    // 2. Briši Firestore podatke
    await FirestoreService().deleteUserData(user.uid);

    // 3. Briši Auth račun
    await user.delete();


    // }
    //

  }
}
