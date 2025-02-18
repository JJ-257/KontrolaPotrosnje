// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter/material.dart';
// import 'package:potrosnja_plus/screens/income_overview_screen.dart';
// import 'package:potrosnja_plus/screens/scan_qr_screen.dart';
// import 'package:potrosnja_plus/screens/settings_screen.dart';
// import 'package:provider/provider.dart';
// import '../providers/settings_provider.dart';
// import 'screens/home_screen.dart';
// import 'screens/manual_expense_screen.dart';
// import 'screens/add_income_screen.dart';
// import 'screens/analysis_screen.dart';
// import 'screens/login_screen.dart';
// import 'screens/expense_list_screen.dart';
// import 'package:google_mobile_ads/google_mobile_ads.dart';
// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   // Inicijalizacija Google Mobile Ads
//   await MobileAds.instance.initialize();
//   await Firebase.initializeApp();
//   // await FirebaseAuth.instance.setPersistence(Persistence.NONE);
//   // await FirebaseFirestore.instance.disableNetwork();
//   // await FirebaseFirestore.instance.clearPersistence();
//   runApp(
//     ChangeNotifierProvider(
//       create: (_) => SettingsProvider(),
//       child: const MyApp(),
//     ),
//   );
// }
//
// class MyApp extends StatelessWidget {
//   const MyApp({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Consumer<SettingsProvider>(
//       builder: (context, settings, _) {
//         return MaterialApp(
//           title: 'TrošKontrola',
//           theme: settings.darkMode ? ThemeData.dark() : ThemeData.light(),
//           initialRoute: '/login',
//           routes: {
//             '/login': (context) => const LoginScreen(),
//             '/home': (context) => const HomeScreen(),
//             '/expenseList': (context) => const ExpenseListScreen(),
//             '/manualExpense': (context) => const ManualExpenseScreen(),
//             '/addIncome': (context) => const AddIncomeScreen(),
//             '/analysis': (context) => const AnalysisScreen(),
//             '/incomeOverview': (context) => const IncomeOverviewScreen(),
//             '/scanQr': (context) => const ScanQrScreen(),
//             '/settings': (context) => const SettingsScreen()
//             //'/scanReceipt': (context) => const ScanReceiptScreen(),
//           },
//         );
//       },
//     );
//   }
// }
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';

import '../providers/settings_provider.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/manual_expense_screen.dart';
import 'screens/add_income_screen.dart';
import 'screens/analysis_screen.dart';
import 'screens/expense_list_screen.dart';
import 'screens/income_overview_screen.dart';
import 'screens/scan_qr_screen.dart';
import 'screens/settings_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Inicijalizacija Firebase-a
  await Firebase.initializeApp();
  // Inicijalizacija Google Mobile Ads
  await MobileAds.instance.initialize();

  runApp(
    ChangeNotifierProvider(
      create: (_) => SettingsProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, _) {
        return MaterialApp(
          title: 'TrošKontrola',
          theme: settings.darkMode ? ThemeData.dark() : ThemeData.light(),
          home: const AuthWrapper(), // Koristimo AuthWrapper umjesto fiksne početne rute
          routes: {
            '/login': (context) => const LoginScreen(),
            '/home': (context) => const HomeScreen(),
            '/expenseList': (context) => const ExpenseListScreen(),
            '/manualExpense': (context) => const ManualExpenseScreen(),
            '/addIncome': (context) => const AddIncomeScreen(),
            '/analysis': (context) => const AnalysisScreen(),
            '/incomeOverview': (context) => const IncomeOverviewScreen(),
            '/scanQr': (context) => const ScanQrScreen(),
            '/settings': (context) => const SettingsScreen(),
          },
        );
      },
    );
  }
}

// ✅ Ova klasa automatski provjerava status prijave korisnika
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(), // Prati stanje prijave
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()), // Prikazuje loading dok provjerava prijavu
          );
        }
        if (snapshot.hasData) {
          return const HomeScreen(); // Ako je korisnik prijavljen, ide direktno na HomeScreen
        } else {
          return const LoginScreen(); // Inače ide na LoginScreen
        }
      },
    );
  }
}
