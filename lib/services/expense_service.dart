//
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import '../models/expense.dart';
//
// class ExpenseService {
//   static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//
//   // Dodaj novi trošak
//   static Future<void> addExpense(Expense expense) async {
//     final uid = FirebaseAuth.instance.currentUser?.uid;
//     if (uid == null) return;
//     await _firestore
//         .collection('users')
//         .doc(uid)
//         .collection('expenses')
//         .add(expense.toMap());
//   }
//
//   // Stream svih troškova
//   static Stream<List<Expense>> getExpensesStream() {
//     final uid = FirebaseAuth.instance.currentUser?.uid;
//     if (uid == null) {
//       return const Stream.empty();
//     }
//     return _firestore
//         .collection('users')
//         .doc(uid)
//         .collection('expenses')
//         .orderBy('dateTimestamp', descending: true)
//         .snapshots()
//         .map((snapshot) => snapshot.docs
//         .map((doc) => Expense.fromMap(doc.id, doc.data()))
//         .toList());
//   }
//
//   // Dohvat troškova za određeni dan
//   static Future<List<Expense>> getExpensesForDay(
//       int year, int month, int day) async {
//     final uid = FirebaseAuth.instance.currentUser?.uid;
//     if (uid == null) return [];
//     final querySnapshot = await _firestore
//         .collection('users')
//         .doc(uid)
//         .collection('expenses')
//         .where('year', isEqualTo: year)
//         .where('month', isEqualTo: month)
//         .where('day', isEqualTo: day)
//         .get();
//
//     return querySnapshot.docs
//         .map((doc) => Expense.fromMap(doc.id, doc.data()))
//         .toList();
//   }
//
//   // Dohvat troškova za mjesec
//   static Future<List<Expense>> getExpensesForMonth(
//       int year, int month) async {
//     final uid = FirebaseAuth.instance.currentUser?.uid;
//     if (uid == null) return [];
//     final querySnapshot = await _firestore
//         .collection('users')
//         .doc(uid)
//         .collection('expenses')
//         .where('year', isEqualTo: year)
//         .where('month', isEqualTo: month)
//         .get();
//
//     return querySnapshot.docs
//         .map((doc) => Expense.fromMap(doc.id, doc.data()))
//         .toList();
//   }
//
//   // Dohvat troškova za godinu
//   static Future<List<Expense>> getExpensesForYear(int year) async {
//     final uid = FirebaseAuth.instance.currentUser?.uid;
//     if (uid == null) return [];
//     final querySnapshot = await _firestore
//         .collection('users')
//         .doc(uid)
//         .collection('expenses')
//         .where('year', isEqualTo: year)
//         .get();
//
//     return querySnapshot.docs
//         .map((doc) => Expense.fromMap(doc.id, doc.data()))
//         .toList();
//   }
//
//   // Brisanje troška
//   static Future<void> deleteExpense(String expenseId) async {
//     final uid = FirebaseAuth.instance.currentUser?.uid;
//     if (uid == null) return;
//     await _firestore
//         .collection('users')
//         .doc(uid)
//         .collection('expenses')
//         .doc(expenseId)
//         .delete();
//   }
//
//   // Ažuriranje troška
//   static Future<void> updateExpense(Expense expense) async {
//     final uid = FirebaseAuth.instance.currentUser?.uid;
//     if (uid == null) return;
//     await _firestore
//         .collection('users')
//         .doc(uid)
//         .collection('expenses')
//         .doc(expense.id)
//         .update(expense.toMap());
//   }
// }
//
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/expense.dart';

class ExpenseService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Dodaj novi trošak
  static Future<void> addExpense(Expense expense) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('expenses')
        .add(expense.toMap());
  }

  // Stream svih troškova
  static Stream<List<Expense>> getExpensesStream() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return const Stream.empty();
    }
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('expenses')
        .orderBy('dateTimestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => Expense.fromMap(doc.id, doc.data()))
        .toList());
  }

  // Dohvat troškova za određeni dan
  static Future<List<Expense>> getExpensesForDay(int year, int month, int day) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return [];
    final querySnapshot = await _firestore
        .collection('users')
        .doc(uid)
        .collection('expenses')
        .where('year', isEqualTo: year)
        .where('month', isEqualTo: month)
        .where('day', isEqualTo: day)
        .get();

    return querySnapshot.docs
        .map((doc) => Expense.fromMap(doc.id, doc.data()))
        .toList();
  }

  // Dohvat troškova za mjesec
  static Future<List<Expense>> getExpensesForMonth(int year, int month) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return [];
    final querySnapshot = await _firestore
        .collection('users')
        .doc(uid)
        .collection('expenses')
        .where('year', isEqualTo: year)
        .where('month', isEqualTo: month)
        .get();

    return querySnapshot.docs
        .map((doc) => Expense.fromMap(doc.id, doc.data()))
        .toList();
  }

  // Dohvat troškova za godinu
  static Future<List<Expense>> getExpensesForYear(int year) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return [];
    final querySnapshot = await _firestore
        .collection('users')
        .doc(uid)
        .collection('expenses')
        .where('year', isEqualTo: year)
        .get();

    return querySnapshot.docs
        .map((doc) => Expense.fromMap(doc.id, doc.data()))
        .toList();
  }

  // Brisanje troška
  static Future<void> deleteExpense(String expenseId) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('expenses')
        .doc(expenseId)
        .delete();
  }

  // Ažuriranje troška
  static Future<void> updateExpense(Expense expense) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('expenses')
        .doc(expense.id)
        .update(expense.toMap());
  }
}
