// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
//
// class FirestoreService {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//
//   Future<void> deleteUserData() async {
//     final user = FirebaseAuth.instance.currentUser;
//     if (user != null) {
//       await _firestore.collection('users').doc(user.uid).delete();
//     }
//   }
// }
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Future<void> deleteUserData(String userId) async {
  //   await _firestore.collection('users').doc(userId).delete();
  //   // Dodatno: brisanje svih podkolekcija ako postoje
  //   await _firestore.collection('users/$userId/expenses').get().then((snapshot) {
  //     for (var doc in snapshot.docs) {
  //       doc.reference.delete();
  //     }
  //   });
  // }
  Future<void> deleteUserData(String userId) async {
    // Brisanje glavnog user dokumenta
    await _firestore.collection('users').doc(userId).delete();

    // Brisanje svih podkolekcija
    final collections = ['expenses', 'incomes', 'categories'];
    for (var collection in collections) {
      final query = await _firestore.collection('users/$userId/$collection').get();
      for (var doc in query.docs) {
        await doc.reference.delete();
      }
    }
  }
}