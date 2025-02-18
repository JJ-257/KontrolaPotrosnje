// // // import 'package:cloud_firestore/cloud_firestore.dart';
// // //
// // // class Expense {
// // //   final String id;
// // //   final String name;
// // //   final double amount;
// // //   final DateTime date;  // i dalje čuvamo puni datum za prikaz
// // //   final int year;       // polje za godinu
// // //   final int month;      // polje za mjesec
// // //   final int day;        // polje za dan
// // //
// // //   Expense({
// // //     required this.id,
// // //     required this.name,
// // //     required this.amount,
// // //     required this.date,
// // //     required this.year,
// // //     required this.month,
// // //     required this.day,
// // //   });
// // //
// // //   // Pretvaranje u Map za Firestore
// // //   Map<String, dynamic> toMap() {
// // //     return {
// // //       'name': name,
// // //       'amount': amount,
// // //       'dateTimestamp': Timestamp.fromDate(date), // po želji, nije obavezno
// // //       'year': year,
// // //       'month': month,
// // //       'day': day,
// // //     };
// // //   }
// // //
// // //   // Kreiranje Expense iz Firestore dokumenata
// // //   factory Expense.fromMap(String docId, Map<String, dynamic> data) {
// // //     // Ako postoji dateTimestamp, uzmemo ga. Ako ga nema, složit ćemo datum iz year/month/day
// // //     final ts = data['dateTimestamp'] as Timestamp?;
// // //     final dateFromTs = ts?.toDate();
// // //
// // //     final date = dateFromTs ?? DateTime(
// // //       data['year'],
// // //       data['month'],
// // //       data['day'],
// // //     );
// // //
// // //     return Expense(
// // //       id: docId,
// // //       name: data['name'],
// // //       amount: (data['amount'] as num).toDouble(),
// // //       date: date,
// // //       year: data['year'],
// // //       month: data['month'],
// // //       day: data['day'],
// // //     );
// // //   }
// // // }
// // import 'package:cloud_firestore/cloud_firestore.dart';
// //
// // /// Model za trošak
// // class Expense {
// //   final String id;
// //   final String name;
// //   final double amount;
// //   final DateTime date;
// //   final int year;
// //   final int month;
// //   final int day;
// //
// //   Expense({
// //     required this.id,
// //     required this.name,
// //     required this.amount,
// //     required this.date,
// //     required this.year,
// //     required this.month,
// //     required this.day,
// //   });
// //
// //   /// Pretvara objekt u Map za Firestore
// //   Map<String, dynamic> toMap() {
// //     return {
// //       'name': name,
// //       'amount': amount,
// //       'dateTimestamp': Timestamp.fromDate(date),
// //       'year': year,
// //       'month': month,
// //       'day': day,
// //     };
// //   }
// //
// //   /// Kreira Expense objekt iz Firestore dokumenta
// //   factory Expense.fromMap(String docId, Map<String, dynamic> data) {
// //     final ts = data['dateTimestamp'] as Timestamp?;
// //     final dateFromTs = ts?.toDate();
// //
// //     final date = dateFromTs ??
// //         DateTime(
// //           data['year'] as int,
// //           data['month'] as int,
// //           data['day'] as int,
// //         );
// //
// //     return Expense(
// //       id: docId,
// //       name: data['name'] as String,
// //       amount: (data['amount'] as num).toDouble(),
// //       date: date,
// //       year: data['year'] as int,
// //       month: data['month'] as int,
// //       day: data['day'] as int,
// //     );
// //   }
// //
// //   @override
// //   String toString() {
// //     return 'Expense(id: $id, name: $name, amount: $amount, date: $date)';
// //   }
// // }
// import 'package:cloud_firestore/cloud_firestore.dart';
//
// class Expense {
//   final String id;
//   late final String name;
//   late final double amount;
//   final DateTime date;
//   final int year;
//   final int month;
//   final int day;
//
//   Expense({
//     required this.id,
//     required this.name,
//     required this.amount,
//     required this.date,
//     required this.year,
//     required this.month,
//     required this.day,
//   });
//
//   Map<String, dynamic> toMap() {
//     return {
//       'name': name,
//       'amount': amount,
//       'dateTimestamp': Timestamp.fromDate(date),
//       'year': year,
//       'month': month,
//       'day': day,
//     };
//   }
//
//   factory Expense.fromMap(String docId, Map<String, dynamic> data) {
//     final ts = data['dateTimestamp'] as Timestamp?;
//     final dateFromTs = ts?.toDate();
//
//     // Pokušaj dohvaćanja year, month i day; ako ne postoje, postavit će se na null
//     int? year = data['year'] is int ? data['year'] as int : null;
//     int? month = data['month'] is int ? data['month'] as int : null;
//     int? day = data['day'] is int ? data['day'] as int : null;
//
//     // Odredi finalni datum: prvo provjeri dateTimestamp, pa year/month/day, a ako ništa ne postoji, koristi trenutni datum
//     DateTime finalDate;
//     if (dateFromTs != null) {
//       finalDate = dateFromTs;
//     } else if (year != null && month != null && day != null) {
//       finalDate = DateTime(year, month, day);
//     } else {
//       finalDate = DateTime.now();
//       year ??= finalDate.year;
//       month ??= finalDate.month;
//       day ??= finalDate.day;
//     }
//
//     return Expense(
//       id: docId,
//       name: data['name'] as String,
//       amount: (data['amount'] as num).toDouble(),
//       date: finalDate,
//       year: year ?? finalDate.year,
//       month: month ?? finalDate.month,
//       day: day ?? finalDate.day,
//     );
//   }
// }
import 'package:cloud_firestore/cloud_firestore.dart';

class Expense {
  final String id;
  String name;         // Uklonjeno final – omogućava mutaciju
  double amount;       // Uklonjeno final – omogućava mutaciju
  final DateTime date;
  final int year;
  final int month;
  final int day;

  Expense({
    required this.id,
    required this.name,
    required this.amount,
    required this.date,
    required this.year,
    required this.month,
    required this.day,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'amount': amount,
      'dateTimestamp': Timestamp.fromDate(date),
      'year': year,
      'month': month,
      'day': day,
    };
  }

  factory Expense.fromMap(String docId, Map<String, dynamic> data) {
    final ts = data['dateTimestamp'] as Timestamp?;
    final dateFromTs = ts?.toDate();

    int? year = data['year'] is int ? data['year'] as int : null;
    int? month = data['month'] is int ? data['month'] as int : null;
    int? day = data['day'] is int ? data['day'] as int : null;

    DateTime finalDate;
    if (dateFromTs != null) {
      finalDate = dateFromTs;
    } else if (year != null && month != null && day != null) {
      finalDate = DateTime(year, month, day);
    } else {
      finalDate = DateTime.now();
      year ??= finalDate.year;
      month ??= finalDate.month;
      day ??= finalDate.day;
    }

    return Expense(
      id: docId,
      name: data['name'] as String,
      amount: (data['amount'] as num).toDouble(),
      date: finalDate,
      year: year ?? finalDate.year,
      month: month ?? finalDate.month,
      day: day ?? finalDate.day,
    );
  }
}
