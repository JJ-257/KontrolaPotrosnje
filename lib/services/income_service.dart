// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import '../models/income.dart';
//
// class IncomeService {
//   static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//
//   static Future<void> addIncome(Income income) async {
//     final uid = FirebaseAuth.instance.currentUser?.uid;
//     if (uid == null) return;
//     await _firestore
//         .collection('users')
//         .doc(uid)
//         .collection('incomes')
//         .add(income.toMap());
//   }
//
//   // Dohvat prihoda za određeni mjesec
//   static Future<List<Income>> getIncomesForMonth(int year, int month) async {
//     final uid = FirebaseAuth.instance.currentUser?.uid;
//     if (uid == null) return [];
//     final querySnapshot = await _firestore
//         .collection('users')
//         .doc(uid)
//         .collection('incomes')
//         .where('year', isEqualTo: year)
//         .where('month', isEqualTo: month)
//         .get();
//     return querySnapshot.docs
//         .map((doc) => Income.fromMap(doc.id, doc.data()))
//         .toList();
//   }
//
//   static Future<List<Income>> getIncomesForYear(int selectedYear) async {
//     final uid = FirebaseAuth.instance.currentUser?.uid;
//     if (uid == null) return [];
//     final querySnapshot = await _firestore
//         .collection('users')
//         .doc(uid)
//         .collection('incomes')
//         .where('year', isEqualTo: selectedYear)
//         .get();
//
//     return querySnapshot.docs
//         .map((doc) => Income.fromMap(doc.id, doc.data()))
//         .toList();
//   }
//
//   static Future<void> deleteIncome(String id) async {
//     final uid = FirebaseAuth.instance.currentUser?.uid;
//     if (uid == null) return;
//     await _firestore
//         .collection('users')
//         .doc(uid)
//         .collection('incomes')
//         .doc(id)
//         .delete();
//   }
// }
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/income.dart';

class IncomeService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<void> addIncome(Income income) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('incomes')
        .add(income.toMap());
  }

  // Dohvat prihoda za određeni mjesec
  static Future<List<Income>> getIncomesForMonth(int year, int month) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return [];
    final querySnapshot = await _firestore
        .collection('users')
        .doc(uid)
        .collection('incomes')
        .where('year', isEqualTo: year)
        .where('month', isEqualTo: month)
        .get();
    return querySnapshot.docs
        .map((doc) => Income.fromMap(doc.id, doc.data()))
        .toList();
  }

  static Future<List<Income>> getIncomesForYear(int selectedYear) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return [];
    final querySnapshot = await _firestore
        .collection('users')
        .doc(uid)
        .collection('incomes')
        .where('year', isEqualTo: selectedYear)
        .get();

    return querySnapshot.docs
        .map((doc) => Income.fromMap(doc.id, doc.data()))
        .toList();
  }

  static Future<void> deleteIncome(String id) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('incomes')
        .doc(id)
        .delete();
  }

  // Ažuriranje prihoda
  static Future<void> updateIncome(Income income) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('incomes')
        .doc(income.id)
        .update(income.toMap());
  }
}
