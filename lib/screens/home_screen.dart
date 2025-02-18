//
// import 'package:flutter/material.dart';
// import 'package:google_mobile_ads/google_mobile_ads.dart';
// import 'package:provider/provider.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:firebase_auth/firebase_auth.dart'; // Firebase Auth
// import '../helpers/ad_helper.dart';
// import '../providers/settings_provider.dart';
//
// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});
//
//   @override
//   _HomeScreenState createState() => _HomeScreenState();
// }
//
// class _HomeScreenState extends State<HomeScreen> {
//   BannerAd? _topBannerAd;
//   BannerAd? _bottomBannerAd;
//
//   @override
//   void initState() {
//     super.initState();
//     _loadBannerAds();
//   }
//
//   void _loadBannerAds() {
//     _topBannerAd = BannerAd(
//       adUnitId: getBannerAdUnitId(),
//       size: AdSize.banner,
//       request: const AdRequest(),
//       listener: BannerAdListener(
//         onAdLoaded: (_) => setState(() {}),
//         onAdFailedToLoad: (ad, error) {
//           ad.dispose();
//         },
//       ),
//     )..load();
//
//     _bottomBannerAd = BannerAd(
//       adUnitId: getBannerAdUnitId(),
//       size: AdSize.banner,
//       request: const AdRequest(),
//       listener: BannerAdListener(
//         onAdLoaded: (_) => setState(() {}),
//         onAdFailedToLoad: (ad, error) {
//           ad.dispose();
//         },
//       ),
//     )..load();
//   }
//
//
//
//   Future<void> _onScanQrPressed(BuildContext context) async {
//     final settings = Provider.of<SettingsProvider>(context, listen: false);
//
//     // Uvijek najprije provjerimo trenutni status dozvole
//     final status = await Permission.camera.status;
//
//     if (status.isGranted) {
//       // 1. Dozvola je već odobrena
//       _navigateToQrScreen(context);
//       return;
//     }
//
//     if (status.isDenied) {
//       // 2. Korisnik je prvi (ili ponovni) put kliknuo "deny" – ali nije "ne pitaj više"
//       final result = await showDialog<bool>(
//         context: context,
//         builder: (ctx) => AlertDialog(
//           title: Text(settings.language == 'hr'
//               ? 'Potrebna dozvola za kameru'
//               : 'Camera Permission Required'),
//           content: Text(settings.language == 'hr'
//               ? 'Aplikacija treba pristup kameri za skeniranje QR kodova. Želite li sada odobriti pristup?'
//               : 'The app needs camera access to scan QR codes. Would you like to grant access now?'),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(ctx, false),
//               child: Text(settings.language == 'hr' ? 'Kasnije' : 'Later'),
//             ),
//             TextButton(
//               onPressed: () => Navigator.pop(ctx, true),
//               child: Text(settings.language == 'hr' ? 'Odobri' : 'Allow'),
//             ),
//           ],
//         ),
//       );
//
//       if (result == true) {
//         // Ako je korisnik odabrao "Odobri", tražimo kameru ponovno
//         final newStatus = await Permission.camera.request();
//         if (newStatus.isGranted) {
//           _navigateToQrScreen(context);
//         }
//         // Ako user opet odbije, ostaje isDenied ili prelazi u isPermanentlyDenied
//         // ali ne rušimo aplikaciju, samo ne navigiramo nigdje
//       }
//       return;
//     }
//
//     if (status.isPermanentlyDenied || status.isRestricted) {
//       // 3. Korisnik je "zauvijek" odbio (na Androidu "Don't ask again") ili iOS ima restrikciju
//       final openSettings = await showDialog<bool>(
//         context: context,
//         builder: (ctx) => AlertDialog(
//           title: Text(settings.language == 'hr'
//               ? 'Dozvola za kameru je onemogućena'
//               : 'Camera Permission Disabled'),
//           content: Text(settings.language == 'hr'
//               ? 'Morate ručno omogućiti kameru u Postavkama. Želite li otvoriti Postavke sada?'
//               : 'You must enable camera permission from Settings. Open Settings now?'),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(ctx, false),
//               child: Text(settings.language == 'hr' ? 'Ne' : 'No'),
//             ),
//             TextButton(
//               onPressed: () => Navigator.pop(ctx, true),
//               child: Text(settings.language == 'hr' ? 'Da' : 'Yes'),
//             ),
//           ],
//         ),
//       );
//
//       if (openSettings == true) {
//         // Otvaramo postavke aplikacije
//         await openAppSettings();
//         // Kada se korisnik vrati iz postavki, možda i dalje ostaje isPermanentlyDenied ili isRestricted
//         // ili se promijeni na isGranted. Sljedeći put kad klikne gumb, opet ćemo provjeriti status.
//       }
//       return;
//     }
//
//     if (status.isLimited) {
//       // 4. iOS slučaj – dozvola je djelomično ograničena
//       // Za QR skeniranje obično treba full camera access,
//       // stoga možemo pokušati ponovno tražiti dozvolu ili upozoriti korisnika
//       final result = await showDialog<bool>(
//         context: context,
//         builder: (ctx) => AlertDialog(
//           title: Text(settings.language == 'hr'
//               ? 'Ograničen pristup kameri'
//               : 'Limited Camera Access'),
//           content: Text(settings.language == 'hr'
//               ? 'Trenutačno imate djelomičnu dozvolu za kameru. Možda neće raditi skeniranje. Želite li zatražiti potpunu dozvolu?'
//               : 'You currently have limited camera permission. QR scanning may not work properly. Would you like to request full permission?'),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(ctx, false),
//               child: Text(settings.language == 'hr' ? 'Kasnije' : 'Later'),
//             ),
//             TextButton(
//               onPressed: () => Navigator.pop(ctx, true),
//               child: Text(settings.language == 'hr' ? 'Traži ponovo' : 'Request Again'),
//             ),
//           ],
//         ),
//       );
//
//       if (result == true) {
//         final newStatus = await Permission.camera.request();
//         if (newStatus.isGranted) {
//           _navigateToQrScreen(context);
//         }
//         // Inače ostaje limited ili prelazi na denied/permanentlyDenied
//       }
//       return;
//     }
//   }
//
//   void _navigateToQrScreen(BuildContext context) {
//     // Navigacija na tvoj QR screen, primjer:
//     Navigator.pushNamed(context, '/scanQr');
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return ElevatedButton(
//       onPressed: () => _onScanQrPressed(context),
//       child: const Text('Scan QR'),
//     );
//   }
//
//   // Prikazuje dijalog s podacima o korisniku iz Firebase Auth
//   void _showProfileDialog() {
//     final settings = Provider.of<SettingsProvider>(context, listen: false);
//     final User? user = FirebaseAuth.instance.currentUser;
//     if (user == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(settings.language == 'hr'
//               ? 'Korisnik nije prijavljen.'
//               : 'User is not signed in.'),
//         ),
//       );
//       return;
//     }
//
//     // Parsiramo displayName da bismo dobili ime i prezime
//     String? displayName = user.displayName;
//     String firstName = '';
//     String lastName = '';
//     if (displayName != null && displayName.contains(' ')) {
//       final names = displayName.split(' ');
//       firstName = names.first;
//       lastName = names.sublist(1).join(' ');
//     } else {
//       firstName = displayName ?? '';
//     }
//
//     showDialog(
//       context: context,
//       builder: (ctx) => AlertDialog(
//         title: Text(settings.language == 'hr'
//             ? 'Profil korisnika'
//             : 'User Profile'),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(settings.language == 'hr'
//                 ? 'Ime: $firstName'
//                 : 'Name: $firstName'),
//             Text(settings.language == 'hr'
//                 ? 'Prezime: $lastName'
//                 : 'Surname: $lastName'),
//             Text('Email: ${user.email}'),
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(ctx),
//             child: Text(settings.language == 'hr' ? 'Zatvori' : 'Close'),
//           ),
//         ],
//       ),
//     );
//   }
//
//   @override
//   void dispose() {
//     _topBannerAd?.dispose();
//     _bottomBannerAd?.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final settings = Provider.of<SettingsProvider>(context);
//
//     // Definiramo stavke akcija koje će se prikazati u gridu
//     final List<Map<String, dynamic>> actionItems = [
//       {
//         'title_hr': 'Unos troška',
//         'title_en': 'Expense Entry',
//         'icon': Icons.attach_money,
//         'route': '/manualExpense',
//       },
//       {
//         'title_hr': 'Unos prihoda',
//         'title_en': 'Add Income',
//         'icon': Icons.add_circle_outline,
//         'route': '/addIncome',
//       },
//       {
//         'title_hr': 'Pregled troškova',
//         'title_en': 'Expense Overview',
//         'icon': Icons.list_alt,
//         'route': '/expenseList',
//       },
//       {
//         'title_hr': 'Pregled prihoda',
//         'title_en': 'Income Overview',
//         'icon': Icons.receipt_long,
//         'route': '/incomeOverview',
//       },
//       {
//         'title_hr': 'Analiza potrošnje',
//         'title_en': 'Expense Analysis',
//         'icon': Icons.analytics,
//         'route': '/analysis',
//       },
//       {
//         'title_hr': 'Skeniraj QR',
//         'title_en': 'Scan QR',
//         'icon': Icons.qr_code_scanner,
//         'action': (BuildContext ctx) => _onScanQrPressed(ctx),
//       },
//     ];
//
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           settings.language == 'hr' ? 'KontrolaPotrošnje' : 'ExpenseControl',
//         ),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.settings),
//             onPressed: () => Navigator.pushNamed(context, '/settings'),
//           ),
//           DropdownButton<String>(
//             value: settings.language,
//             underline: const SizedBox(),
//             icon: const Icon(Icons.language, color: Colors.white),
//             items: const [
//               DropdownMenuItem(value: 'hr', child: Text('HR')),
//               DropdownMenuItem(value: 'en', child: Text('EN')),
//             ],
//             onChanged: (String? value) {
//               if (value != null) {
//                 settings.setLanguage(value);
//               }
//             },
//           ),
//         ],
//       ),
//       body: Container(
//         decoration: const BoxDecoration(
//           gradient: LinearGradient(
//             colors: [Color(0xFFE0F7FA), Color(0xFFB2EBF2)],
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//           ),
//         ),
//         child: Column(
//           children: [
//             if (_topBannerAd != null)
//               Container(
//                 width: _topBannerAd!.size.width.toDouble(),
//                 height: _topBannerAd!.size.height.toDouble(),
//                 child: AdWidget(ad: _topBannerAd!),
//               ),
//             Expanded(
//               child: SingleChildScrollView(
//                 padding: const EdgeInsets.all(16.0),
//                 child: Column(
//                   children: [
//                     // Kartica profila s ikonom i verzijom aplikacije
//                     Card(
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(16),
//                       ),
//                       elevation: 4,
//                       child: Padding(
//                         padding: const EdgeInsets.all(16.0),
//                         child: Row(
//                           children: [
//                             IconButton(
//                               icon: const Icon(
//                                 Icons.account_circle,
//                                 size: 64,
//                                 color: Colors.blue,
//                               ),
//                               onPressed: _showProfileDialog,
//                             ),
//                             const SizedBox(width: 16),
//                             Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text(
//                                   settings.language == 'hr'
//                                       ? 'Dobrodošli!'
//                                       : 'Welcome!',
//                                   style: const TextStyle(
//                                     fontSize: 20,
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                 ),
//                                 const SizedBox(height: 8),
//                                 Text(
//                                   settings.language == 'hr'
//                                       ? 'Verzija aplikacije: 1.0.0'
//                                       : 'App Version: 1.0.0',
//                                   style: const TextStyle(fontSize: 16),
//                                 ),
//                               ],
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                     const SizedBox(height: 24),
//                     // Grid prikaz akcija
//                     GridView.count(
//                       crossAxisCount: 2,
//                       shrinkWrap: true,
//                       physics: const NeverScrollableScrollPhysics(),
//                       mainAxisSpacing: 16,
//                       crossAxisSpacing: 16,
//                       childAspectRatio: 1.0,
//                       children: actionItems.map((action) {
//                         final String title = settings.language == 'hr'
//                             ? action['title_hr']
//                             : action['title_en'];
//                         return Card(
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(16),
//                           ),
//                           elevation: 4,
//                           child: InkWell(
//                             borderRadius: BorderRadius.circular(16),
//                             onTap: () {
//                               if (action.containsKey('route')) {
//                                 Navigator.pushNamed(context, action['route']);
//                               } else if (action.containsKey('action')) {
//                                 action['action'](context);
//                               }
//                             },
//                             child: Center(
//                               child: Column(
//                                 mainAxisSize: MainAxisSize.min,
//                                 children: [
//                                   Icon(
//                                     action['icon'],
//                                     size: 48,
//                                     color: Theme.of(context).primaryColor,
//                                   ),
//                                   const SizedBox(height: 8),
//                                   Text(
//                                     title,
//                                     textAlign: TextAlign.center,
//                                     style: const TextStyle(
//                                       fontSize: 16,
//                                       fontWeight: FontWeight.w600,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ),
//                         );
//                       }).toList(),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//             if (_bottomBannerAd != null)
//               Container(
//                 width: _bottomBannerAd!.size.width.toDouble(),
//                 height: _bottomBannerAd!.size.height.toDouble(),
//                 child: AdWidget(ad: _bottomBannerAd!),
//               ),
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Firebase Auth
import '../helpers/ad_helper.dart';
import '../providers/settings_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  BannerAd? _topBannerAd;
  BannerAd? _bottomBannerAd;

  @override
  void initState() {
    super.initState();
    _loadBannerAds();
  }

  void _loadBannerAds() {
    _topBannerAd = BannerAd(
      adUnitId: getBannerAdUnitId(),
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) => setState(() {}),
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
        },
      ),
    )..load();

    _bottomBannerAd = BannerAd(
      adUnitId: getBannerAdUnitId(),
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) => setState(() {}),
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
        },
      ),
    )..load();
  }

  // ------------------------------------------------------------------------
  //  LOGIKA ZA DOZVOLU KAMERE (QR SCAN)
  // ------------------------------------------------------------------------
  Future<void> _onScanQrPressed(BuildContext context) async {
    final settings = Provider.of<SettingsProvider>(context, listen: false);

    // Uvijek najprije provjerimo trenutni status dozvole
    final status = await Permission.camera.status;

    if (status.isGranted) {
      // 1. Dozvola je već odobrena
      _navigateToQrScreen(context);
      return;
    }

    if (status.isDenied) {
      // 2. Korisnik je prvi (ili ponovni) put kliknuo "deny" – ali nije "Ne pitaj više"
      final result = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(settings.language == 'hr'
              ? 'Potrebna dozvola za kameru'
              : 'Camera Permission Required'),
          content: Text(settings.language == 'hr'
              ? 'Aplikacija treba pristup kameri za skeniranje QR kodova. Želite li sada odobriti pristup?'
              : 'The app needs camera access to scan QR codes. Would you like to grant access now?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(settings.language == 'hr' ? 'Kasnije' : 'Later'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(settings.language == 'hr' ? 'Odobri' : 'Allow'),
            ),
          ],
        ),
      );

      if (result == true) {
        // Ako je korisnik odabrao "Odobri", tražimo kameru ponovno
        final newStatus = await Permission.camera.request();
        if (newStatus.isGranted) {
          _navigateToQrScreen(context);
        }
        // Ako user opet odbije, ostaje isDenied ili prelazi u isPermanentlyDenied
        // ali ne rušimo aplikaciju, samo ne navigiramo nigdje
      }
      return;
    }

    if (status.isPermanentlyDenied || status.isRestricted) {
      // 3. Korisnik je "zauvijek" odbio (na Androidu "Don't ask again") ili iOS ima restrikciju
      final openSettings = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(settings.language == 'hr'
              ? 'Dozvola za kameru je onemogućena'
              : 'Camera Permission Disabled'),
          content: Text(settings.language == 'hr'
              ? 'Morate ručno omogućiti kameru u Postavkama. Želite li otvoriti Postavke sada?'
              : 'You must enable camera permission from Settings. Open Settings now?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(settings.language == 'hr' ? 'Ne' : 'No'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(settings.language == 'hr' ? 'Da' : 'Yes'),
            ),
          ],
        ),
      );

      if (openSettings == true) {
        // Otvaramo postavke aplikacije
        await openAppSettings();
        // Kada se korisnik vrati iz postavki, možda i dalje ostaje isPermanentlyDenied ili isRestricted
        // ili se promijeni na isGranted. Sljedeći put kad klikne gumb, opet ćemo provjeriti status.
      }
      return;
    }

    if (status.isLimited) {
      // 4. iOS slučaj – dozvola je djelomično ograničena
      // Za QR skeniranje obično treba full camera access,
      // stoga možemo pokušati ponovno tražiti dozvolu ili upozoriti korisnika
      final result = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(settings.language == 'hr'
              ? 'Ograničen pristup kameri'
              : 'Limited Camera Access'),
          content: Text(settings.language == 'hr'
              ? 'Trenutačno imate djelomičnu dozvolu za kameru. Možda neće raditi skeniranje. Želite li zatražiti potpunu dozvolu?'
              : 'You currently have limited camera permission. QR scanning may not work properly. Would you like to request full permission?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(settings.language == 'hr' ? 'Kasnije' : 'Later'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(settings.language == 'hr' ? 'Traži ponovo' : 'Request Again'),
            ),
          ],
        ),
      );

      if (result == true) {
        final newStatus = await Permission.camera.request();
        if (newStatus.isGranted) {
          _navigateToQrScreen(context);
        }
        // Inače ostaje limited ili prelazi na denied/permanentlyDenied
      }
      return;
    }
  }

  void _navigateToQrScreen(BuildContext context) {
    // Navigacija na tvoj QR screen, primjer:
    Navigator.pushNamed(context, '/scanQr');
  }

  // ------------------------------------------------------------------------
  //  PRIKAZ PROFILA (FirebaseAuth User)
  // ------------------------------------------------------------------------
  void _showProfileDialog() {
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    final User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(settings.language == 'hr'
              ? 'Korisnik nije prijavljen.'
              : 'User is not signed in.'),
        ),
      );
      return;
    }

    // Parsiramo displayName da bismo dobili ime i prezime
    String? displayName = user.displayName;
    String firstName = '';
    String lastName = '';

    if (displayName != null && displayName.contains(' ')) {
      final names = displayName.split(' ');
      firstName = names.first;
      lastName = names.sublist(1).join(' ');
    } else {
      firstName = displayName ?? '';
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(settings.language == 'hr'
            ? 'Profil korisnika'
            : 'User Profile'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(settings.language == 'hr'
                ? 'Ime: $firstName'
                : 'Name: $firstName'),
            Text(settings.language == 'hr'
                ? 'Prezime: $lastName'
                : 'Surname: $lastName'),
            Text('Email: ${user.email}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(settings.language == 'hr' ? 'Zatvori' : 'Close'),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------------------
  //  DISPOSE
  // ------------------------------------------------------------------------
  @override
  void dispose() {
    _topBannerAd?.dispose();
    _bottomBannerAd?.dispose();
    super.dispose();
  }

  // ------------------------------------------------------------------------
  //  BUILD
  // ------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);

    // Definiramo stavke akcija koje će se prikazati u gridu
    final List<Map<String, dynamic>> actionItems = [
      {
        'title_hr': 'Unos troška',
        'title_en': 'Expense Entry',
        'icon': Icons.attach_money,
        'route': '/manualExpense',
      },
      {
        'title_hr': 'Unos prihoda',
        'title_en': 'Add Income',
        'icon': Icons.add_circle_outline,
        'route': '/addIncome',
      },
      {
        'title_hr': 'Pregled troškova',
        'title_en': 'Expense Overview',
        'icon': Icons.list_alt,
        'route': '/expenseList',
      },
      {
        'title_hr': 'Pregled prihoda',
        'title_en': 'Income Overview',
        'icon': Icons.receipt_long,
        'route': '/incomeOverview',
      },
      {
        'title_hr': 'Analiza potrošnje',
        'title_en': 'Expense Analysis',
        'icon': Icons.analytics,
        'route': '/analysis',
      },
      {
        'title_hr': 'Skeniraj QR',
        'title_en': 'Scan QR',
        'icon': Icons.qr_code_scanner,
        'action': (BuildContext ctx) => _onScanQrPressed(ctx),
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          settings.language == 'hr' ? 'KontrolaPotrošnje' : 'ExpenseControl',
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.pushNamed(context, '/settings'),
          ),
          DropdownButton<String>(
            value: settings.language,
            underline: const SizedBox(),
            icon: const Icon(Icons.language, color: Colors.white),
            items: const [
              DropdownMenuItem(value: 'hr', child: Text('HR')),
              DropdownMenuItem(value: 'en', child: Text('EN')),
            ],
            onChanged: (String? value) {
              if (value != null) {
                settings.setLanguage(value);
              }
            },
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE0F7FA), Color(0xFFB2EBF2)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            if (_topBannerAd != null)
              SizedBox(
                width: _topBannerAd!.size.width.toDouble(),
                height: _topBannerAd!.size.height.toDouble(),
                child: AdWidget(ad: _topBannerAd!),
              ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Kartica profila s ikonom i verzijom aplikacije
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.account_circle,
                                size: 64,
                                color: Colors.blue,
                              ),
                              onPressed: _showProfileDialog,
                            ),
                            const SizedBox(width: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  settings.language == 'hr'
                                      ? 'Dobrodošli!'
                                      : 'Welcome!',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  settings.language == 'hr'
                                      ? 'Verzija aplikacije: 1.0.0'
                                      : 'App Version: 1.0.0',
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Grid prikaz akcija
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 1.0,
                      children: actionItems.map((action) {
                        final String title = settings.language == 'hr'
                            ? action['title_hr']
                            : action['title_en'];
                        return Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 4,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () {
                              if (action.containsKey('route')) {
                                Navigator.pushNamed(context, action['route']);
                              } else if (action.containsKey('action')) {
                                action['action'](context);
                              }
                            },
                            child: Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    action['icon'],
                                    size: 48,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    title,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
            if (_bottomBannerAd != null)
              SizedBox(
                width: _bottomBannerAd!.size.width.toDouble(),
                height: _bottomBannerAd!.size.height.toDouble(),
                child: AdWidget(ad: _bottomBannerAd!),
              ),
          ],
        ),
      ),
    );
  }
}
