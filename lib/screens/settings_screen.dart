
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/settings_provider.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _handleLogout(BuildContext context) async {
    final result = await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(_getTranslation(context, 'Potvrda odjave', 'Logout Confirmation')),
        content: Text(_getTranslation(context, 'Jeste li sigurni da se želite odjaviti?', 'Are you sure you want to logout?')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(_getTranslation(context, 'Ne', 'No')),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(_getTranslation(context, 'Da', 'Yes')),
          ),
        ],
      ),
    );
    if (result == true) {
      try {
        await AuthService().signOut();
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      } catch (e) {
        _showError(context, e.toString());
      }
    }
  }

  Future<void> _handleDeleteAccount(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(_getTranslation(context, 'Brisanje računa', 'Account Deletion')),
        content: Text(_getTranslation(
          context,
          'Jeste li sigurni da želite trajno izbrisati račun? Sve vaše podatke će biti nepovratno izbrisani!',
          'Are you sure you want to permanently delete your account? All your data will be irreversibly deleted!',
        )),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(_getTranslation(context, 'Odustani', 'Cancel')),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              _getTranslation(context, 'Izbriši', 'Delete'),
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
    if (result == true) {
      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          await FirestoreService().deleteUserData(user.uid);
          await user.delete();
          await AuthService().signOut();
          await _clearAllLocalData();
          Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
        }
      } on FirebaseAuthException catch (e) {
        if (e.code == 'requires-recent-login') {
          _showError(context, _getTranslation(
            context,
            'Morate se ponovno prijaviti prije brisanja računa.',
            'You must reauthenticate before deleting your account.',
          ));
        } else {
          _showError(context, _getTranslation(
            context,
            'Greška pri brisanju računa: ${e.message}',
            'Error deleting account: ${e.message}',
          ));
        }
      } catch (e) {
        _showError(context, _getTranslation(
          context,
          'Greška pri brisanju računa: $e',
          'Error deleting account: $e',
        ));
      }
    }
  }

  Future<void> _clearAllLocalData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      await FirebaseAuth.instance.signOut();
      await FirebaseFirestore.instance.clearPersistence();
    } catch (e) {
      print('Error clearing local data: $e');
    }
  }

  String _getTranslation(BuildContext context, String hr, String en) {
    return Provider.of<SettingsProvider>(context, listen: false).language == 'hr' ? hr : en;
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final isCroatian = settings.language == 'hr';

    return Scaffold(
      appBar: AppBar(
        title: Text(isCroatian ? 'Postavke' : 'Settings'),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFB3E5FC), Color(0xFFE1F5FE)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24.0),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Card(
                color: Colors.white.withOpacity(0.75),
                elevation: 12,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      _buildSettingsButton(
                        icon: Icons.exit_to_app,
                        text: isCroatian ? 'Odjava' : 'Logout',
                        color: Colors.orange,
                        onPressed: () => _handleLogout(context),
                      ),
                      const Divider(),
                      _buildSettingsButton(
                        icon: Icons.delete_forever,
                        text: isCroatian ? 'Izbriši račun' : 'Delete account',
                        color: Colors.red,
                        onPressed: () => _handleDeleteAccount(context),
                      ),
                      const SizedBox(height: 16),
                      // Dodajemo napomenu u kurzivu ispod gumba
                      Text(
                        isCroatian
                            ? '*QR skener radi samo za račune izdane u Republici Hrvatskoj!'
                            : '*QR code scanner works only for receipts issued in the Republic of Croatia!',
                        style: const TextStyle(
                          fontStyle: FontStyle.italic,
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsButton({
    required IconData icon,
    required String text,
    Color color = Colors.blue,
    required VoidCallback onPressed,
  }) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(text, style: TextStyle(color: color)),
      onTap: onPressed,
    );
  }
}
