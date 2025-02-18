// //
// // import 'package:flutter/material.dart';
// // import 'package:provider/provider.dart';
// // import '../providers/settings_provider.dart';
// // import '../services/auth_service.dart';
// //
// // class LoginScreen extends StatefulWidget {
// //   const LoginScreen({super.key});
// //
// //   @override
// //   _LoginScreenState createState() => _LoginScreenState();
// // }
// //
// // class _LoginScreenState extends State<LoginScreen> {
// //   final AuthService _authService = AuthService();
// //
// //   Future<void> _googleSignIn() async {
// //     final userCredential = await _authService.signInWithGoogle();
// //     if (userCredential != null) {
// //       Navigator.pushReplacementNamed(context, '/home');
// //     } else {
// //       ScaffoldMessenger.of(context).showSnackBar(
// //         SnackBar(
// //           content: Text(
// //             Provider.of<SettingsProvider>(context, listen: false).language == 'hr'
// //                 ? 'Neuspjela prijava'
// //                 : 'Login failed',
// //           ),
// //           behavior: SnackBarBehavior.floating,
// //         ),
// //       );
// //     }
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     final settings = Provider.of<SettingsProvider>(context);
// //     return Scaffold(
// //       appBar: AppBar(
// //         title: Text(settings.language == 'hr' ? 'Prijava' : 'Login'),
// //         actions: [
// //           DropdownButton<String>(
// //             value: settings.language,
// //             underline: const SizedBox(),
// //             icon: const Icon(Icons.language, color: Colors.white),
// //             items: const [
// //               DropdownMenuItem(value: 'hr', child: Text('HR')),
// //               DropdownMenuItem(value: 'en', child: Text('EN')),
// //             ],
// //             onChanged: (String? value) {
// //               if (value != null) settings.setLanguage(value);
// //             },
// //           ),
// //         ],
// //       ),
// //       body: Container(
// //         decoration: const BoxDecoration(
// //           gradient: LinearGradient(
// //             colors: [Color(0xFFB2EBF2), Color(0xFFE0F7FA)],
// //             begin: Alignment.topLeft,
// //             end: Alignment.bottomRight,
// //           ),
// //         ),
// //         child: Center(
// //           child: Card(
// //             elevation: 8,
// //             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
// //             margin: const EdgeInsets.symmetric(horizontal: 32),
// //             child: Padding(
// //               padding: const EdgeInsets.all(24.0),
// //               child: Column(
// //                 mainAxisSize: MainAxisSize.min,
// //                 children: [
// //                   Text(
// //                     settings.language == 'hr' ? 'Prijava' : 'Login',
// //                     style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
// //                   ),
// //                   const SizedBox(height: 16),
// //                   ElevatedButton.icon(
// //                     onPressed: _googleSignIn,
// //                     icon: const Icon(Icons.login),
// //                     label: Text(
// //                       settings.language == 'hr'
// //                           ? 'Prijavite se s Google računom'
// //                           : 'Sign in with Google',
// //                       style: const TextStyle(fontSize: 16),
// //                     ),
// //                     style: ElevatedButton.styleFrom(
// //                       minimumSize: const Size(double.infinity, 50),
// //                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //             ),
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// // }
// import 'package:flutter/material.dart';
// import 'package:flutter/gestures.dart';
// import 'package:provider/provider.dart';
// import '../providers/settings_provider.dart';
// import '../services/auth_service.dart';
//
// class LoginScreen extends StatefulWidget {
//   const LoginScreen({super.key});
//
//   @override
//   _LoginScreenState createState() => _LoginScreenState();
// }
//
// class _LoginScreenState extends State<LoginScreen> {
//   final AuthService _authService = AuthService();
//   bool _agreedToPrivacyPolicy = false;
//
//   Future<void> _googleSignIn() async {
//     if (!_agreedToPrivacyPolicy) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(
//             Provider.of<SettingsProvider>(context, listen: false).language == 'hr'
//                 ? 'Morate se složiti s pravilima privatnosti'
//                 : 'You must agree to the privacy policy',
//           ),
//           behavior: SnackBarBehavior.floating,
//         ),
//       );
//       return;
//     }
//     final userCredential = await _authService.signInWithGoogle();
//     if (userCredential != null) {
//       Navigator.pushReplacementNamed(context, '/home');
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(
//             Provider.of<SettingsProvider>(context, listen: false).language == 'hr'
//                 ? 'Neuspjela prijava'
//                 : 'Login failed',
//           ),
//           behavior: SnackBarBehavior.floating,
//         ),
//       );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final settings = Provider.of<SettingsProvider>(context);
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(settings.language == 'hr' ? 'Prijava' : 'Login'),
//         actions: [
//           DropdownButton<String>(
//             value: settings.language,
//             underline: const SizedBox(),
//             icon: const Icon(Icons.language, color: Colors.white),
//             items: const [
//               DropdownMenuItem(value: 'hr', child: Text('HR')),
//               DropdownMenuItem(value: 'en', child: Text('EN')),
//             ],
//             onChanged: (String? value) {
//               if (value != null) settings.setLanguage(value);
//             },
//           ),
//         ],
//       ),
//       body: Container(
//         decoration: const BoxDecoration(
//           gradient: LinearGradient(
//             colors: [Color(0xFFB2EBF2), Color(0xFFE0F7FA)],
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//           ),
//         ),
//         child: Center(
//           child: Card(
//             elevation: 8,
//             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//             margin: const EdgeInsets.symmetric(horizontal: 32),
//             child: Padding(
//               padding: const EdgeInsets.all(24.0),
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Text(
//                     settings.language == 'hr' ? 'Prijava' : 'Login',
//                     style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//                   ),
//                   const SizedBox(height: 16),
//                   ElevatedButton.icon(
//                     onPressed: _agreedToPrivacyPolicy ? _googleSignIn : null,
//                     icon: Image.asset(
//                       'assets/google_logo.png', // Ensure this asset exists and is declared in pubspec.yaml
//                       height: 24,
//                       width: 24,
//                     ),
//                     label: Text(
//                       settings.language == 'hr'
//                           ? 'Prijavite se s Google računom'
//                           : 'Sign in with Google',
//                       style: const TextStyle(fontSize: 16),
//                     ),
//                     style: ElevatedButton.styleFrom(
//                       minimumSize: const Size(double.infinity, 50),
//                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//       // Bottom widget for privacy policy agreement
//       bottomNavigationBar: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//           child: Row(
//             children: [
//               Checkbox(
//                 value: _agreedToPrivacyPolicy,
//                 onChanged: (bool? value) {
//                   setState(() {
//                     _agreedToPrivacyPolicy = value ?? false;
//                   });
//                 },
//               ),
//               Expanded(
//                 child: RichText(
//                   text: TextSpan(
//                     style: TextStyle(
//                       color: Theme.of(context).textTheme.bodyLarge?.color,
//                       fontSize: 14,
//                     ),
//                     children: [
//                       TextSpan(
//                         text: settings.language == 'hr'
//                             ? 'Slažem se s '
//                             : 'I agree to the ',
//                       ),
//                       TextSpan(
//                         text: settings.language == 'hr'
//                             ? 'pravilima privatnosti'
//                             : 'privacy policy',
//                         style: const TextStyle(
//                           color: Colors.blue,
//                           decoration: TextDecoration.underline,
//                         ),
//                         recognizer: TapGestureRecognizer()
//                           ..onTap = () {
//                             // TODO: Implement navigation to your privacy policy page or open a URL.
//                              Navigator.pushNamed(context, 'https://sites.google.com/view/kontrolapotrosnje/po%C4%8Detna-stranica');
//                           },
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
// import 'package:flutter/material.dart';
// import 'package:flutter/gestures.dart';
// import 'package:provider/provider.dart';
// import 'package:url_launcher/url_launcher.dart';
// import '../providers/settings_provider.dart';
// import '../services/auth_service.dart';
//
// class LoginScreen extends StatefulWidget {
//   const LoginScreen({super.key});
//
//   @override
//   _LoginScreenState createState() => _LoginScreenState();
// }
//
// class _LoginScreenState extends State<LoginScreen> {
//   final AuthService _authService = AuthService();
//   bool _agreedToPrivacyPolicy = false;
//
//   // Replace with your actual privacy policy URL
//   final Uri _privacyPolicyUrl = Uri.parse('https://sites.google.com/view/kontrolapotrosnje/po%C4%8Detna-stranica');
//
//   Future<void> _googleSignIn() async {
//     if (!_agreedToPrivacyPolicy) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(
//             Provider.of<SettingsProvider>(context, listen: false).language == 'hr'
//                 ? 'Morate se složiti s pravilima privatnosti'
//                 : 'You must agree to the privacy policy',
//           ),
//           behavior: SnackBarBehavior.floating,
//         ),
//       );
//       return;
//     }
//     final userCredential = await _authService.signInWithGoogle();
//     if (userCredential != null) {
//       Navigator.pushReplacementNamed(context, '/home');
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(
//             Provider.of<SettingsProvider>(context, listen: false).language == 'hr'
//                 ? 'Neuspjela prijava'
//                 : 'Login failed',
//           ),
//           behavior: SnackBarBehavior.floating,
//         ),
//       );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final settings = Provider.of<SettingsProvider>(context);
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(settings.language == 'hr' ? 'Prijava' : 'Login'),
//         actions: [
//           DropdownButton<String>(
//             value: settings.language,
//             underline: const SizedBox(),
//             icon: const Icon(Icons.language, color: Colors.white),
//             items: const [
//               DropdownMenuItem(value: 'hr', child: Text('HR')),
//               DropdownMenuItem(value: 'en', child: Text('EN')),
//             ],
//             onChanged: (String? value) {
//               if (value != null) settings.setLanguage(value);
//             },
//           ),
//         ],
//       ),
//       body: Container(
//         decoration: const BoxDecoration(
//           gradient: LinearGradient(
//             colors: [Color(0xFFB2EBF2), Color(0xFFE0F7FA)],
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//           ),
//         ),
//         child: Center(
//           child: Card(
//             elevation: 8,
//             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//             margin: const EdgeInsets.symmetric(horizontal: 32),
//             child: Padding(
//               padding: const EdgeInsets.all(24.0),
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Text(
//                     settings.language == 'hr' ? 'Prijava' : 'Login',
//                     style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//                   ),
//                   const SizedBox(height: 16),
//                   ElevatedButton.icon(
//                     onPressed: _agreedToPrivacyPolicy ? _googleSignIn : null,
//                     icon: Image.asset(
//                       'assets/google_logo.png',
//                       height: 24,
//                       width: 24,
//                     ),
//                     label: Text(
//                       settings.language == 'hr'
//                           ? 'Prijavite se s Google računom'
//                           : 'Sign in with Google',
//                       style: const TextStyle(fontSize: 16),
//                     ),
//                     style: ElevatedButton.styleFrom(
//                       minimumSize: const Size(double.infinity, 50),
//                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//       bottomNavigationBar: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//           child: Row(
//             children: [
//               Checkbox(
//                 value: _agreedToPrivacyPolicy,
//                 onChanged: (bool? value) {
//                   setState(() {
//                     _agreedToPrivacyPolicy = value ?? false;
//                   });
//                 },
//               ),
//               Expanded(
//                 child: RichText(
//                   text: TextSpan(
//                     style: TextStyle(
//                       color: Theme.of(context).textTheme.bodyLarge?.color,
//                       fontSize: 14,
//                     ),
//                     children: [
//                       TextSpan(
//                         text: settings.language == 'hr'
//                             ? 'Slažem se s '
//                             : 'I agree to the ',
//                       ),
//                       TextSpan(
//                         text: settings.language == 'hr'
//                             ? 'pravilima privatnosti'
//                             : 'privacy policy',
//                         style: const TextStyle(
//                           color: Colors.blue,
//                           decoration: TextDecoration.underline,
//                         ),
//                         recognizer: TapGestureRecognizer()
//                           ..onTap = () async {
//                             if (!await launchUrl(_privacyPolicyUrl)) {
//                               throw Exception('Could not launch $_privacyPolicyUrl');
//                             }
//                           },
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/settings_provider.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _authService = AuthService();
  bool _agreedToPrivacyPolicy = false;
  bool _isLoading = false; // 🚀 Varijabla za prikaz loading indikatora

  // URL pravila privatnosti
  final Uri _privacyPolicyUrl = Uri.parse('https://sites.google.com/view/kontrolapotrosnje/po%C4%8Detna-stranica');

  Future<void> _googleSignIn() async {
    if (!_agreedToPrivacyPolicy) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            Provider.of<SettingsProvider>(context, listen: false).language == 'hr'
                ? 'Morate se složiti s pravilima privatnosti'
                : 'You must agree to the privacy policy',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true; // 🚀 Prikaži kružić dok traje prijava
    });

    final userCredential = await _authService.signInWithGoogle();

    if (userCredential != null) {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      setState(() {
        _isLoading = false; // 🚀 Sakrij kružić ako prijava ne uspije
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            Provider.of<SettingsProvider>(context, listen: false).language == 'hr'
                ? 'Neuspjela prijava'
                : 'Login failed',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(settings.language == 'hr' ? 'Prijava' : 'Login'),
        actions: [
          DropdownButton<String>(
            value: settings.language,
            underline: const SizedBox(),
            icon: const Icon(Icons.language, color: Colors.white),
            items: const [
              DropdownMenuItem(value: 'hr', child: Text('HR')),
              DropdownMenuItem(value: 'en', child: Text('EN')),
            ],
            onChanged: (String? value) {
              if (value != null) settings.setLanguage(value);
            },
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFB2EBF2), Color(0xFFE0F7FA)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            margin: const EdgeInsets.symmetric(horizontal: 32),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    settings.language == 'hr' ? 'Prijava' : 'Login',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  // 🚀 Ako se korisnik prijavljuje, prikaži loader, inače prikaži gumb
                  _isLoading
                      ? const CircularProgressIndicator() // Prikazuje kružić dok traje prijava
                      : ElevatedButton.icon(
                    onPressed: _agreedToPrivacyPolicy ? _googleSignIn : null,
                    icon: Image.asset(
                      'assets/google_logo.png',
                      height: 24,
                      width: 24,
                    ),
                    label: Text(
                      settings.language == 'hr'
                          ? 'Prijavite se s Google računom'
                          : 'Sign in with Google',
                      style: const TextStyle(fontSize: 16),
                    ),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Checkbox(
                value: _agreedToPrivacyPolicy,
                onChanged: (bool? value) {
                  setState(() {
                    _agreedToPrivacyPolicy = value ?? false;
                  });
                },
              ),
              Expanded(
                child: RichText(
                  text: TextSpan(
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                      fontSize: 14,
                    ),
                    children: [
                      TextSpan(
                        text: settings.language == 'hr'
                            ? 'Slažem se s '
                            : 'I agree to the ',
                      ),
                      TextSpan(
                        text: settings.language == 'hr'
                            ? 'pravilima privatnosti'
                            : 'privacy policy',
                        style: const TextStyle(
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () async {
                            if (!await launchUrl(_privacyPolicyUrl)) {
                              throw Exception('Could not launch $_privacyPolicyUrl');
                            }
                          },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
