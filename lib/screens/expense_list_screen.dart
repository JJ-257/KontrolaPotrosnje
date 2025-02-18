
import 'dart:io';
import 'dart:ui';
import 'package:excel/excel.dart';
import 'package:external_path/external_path.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
// Dodatno za detektiranje SDK verzije:
import 'package:device_info_plus/device_info_plus.dart';

import '../models/expense.dart';
import '../providers/settings_provider.dart';
import '../services/expense_service.dart';

class ExpenseListScreen extends StatefulWidget {
  const ExpenseListScreen({super.key});

  @override
  _ExpenseListScreenState createState() => _ExpenseListScreenState();
}

class _ExpenseListScreenState extends State<ExpenseListScreen> {
  int selectedYear = DateTime.now().year;
  int selectedMonth = DateTime.now().month;
  List<Expense> expenses = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<int> availableYears = [];
  final List<int> availableMonths = List.generate(12, (index) => index + 1);

  @override
  void initState() {
    super.initState();
    int currentYear = DateTime.now().year;
    // Godine od 2020. do trenutne
    availableYears = List<int>.generate(currentYear - 2019, (index) => 2020 + index);
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      expenses = await ExpenseService.getExpensesForMonth(selectedYear, selectedMonth);
      // Sort: najnoviji na vrhu, ako isti datum -> abecedno
      expenses.sort((a, b) {
        final dateA = DateTime(a.year, a.month, a.day);
        final dateB = DateTime(b.year, b.month, b.day);
        final cmpDate = dateB.compareTo(dateA); // descending
        if (cmpDate != 0) return cmpDate;
        return a.name.compareTo(b.name);
      });
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    }
    setState(() => _isLoading = false);
  }

  Future<void> _confirmDeleteExpense(BuildContext context, Expense expense) async {
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(settings.language == 'hr' ? 'Obriši račun' : 'Delete Expense'),
        content: Text(
          settings.language == 'hr'
              ? 'Jeste li sigurni da želite obrisati račun?'
              : 'Are you sure you want to delete this expense?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(settings.language == 'hr' ? 'Ne' : 'No'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(settings.language == 'hr' ? 'Da' : 'Yes'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ExpenseService.deleteExpense(expense.id);
      _fetchData();
    }
  }

  Future<void> _editExpense(BuildContext context, Expense expense) async {
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    final TextEditingController nameController = TextEditingController(text: expense.name);
    final TextEditingController amountController = TextEditingController(text: expense.amount.toString());

    final bool? saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(settings.language == 'hr' ? 'Uredi račun' : 'Edit Expense'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: settings.language == 'hr' ? 'Naziv računa' : 'Expense Name',
              ),
            ),
            TextField(
              controller: amountController,
              decoration: InputDecoration(
                labelText: settings.language == 'hr' ? 'Iznos' : 'Amount',
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(settings.language == 'hr' ? 'Odustani' : 'Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(settings.language == 'hr' ? 'Spremi' : 'Save'),
          ),
        ],
      ),
    );

    if (saved == true) {
      String newName = nameController.text.trim();
      double? newAmount = double.tryParse(amountController.text);
      if (newName.isNotEmpty && newAmount != null) {
        expense.name = newName;
        expense.amount = newAmount;
        // Pretpostavimo da postoji: ExpenseService.updateExpense(expense)
        await ExpenseService.updateExpense(expense);
        _fetchData();
      }
    }
  }

  // ------------------------------------------------------------------------
  //  LOGIKA ZA TRAŽENJE DOZVOLA, KOMBINACIJA:
  //   - Android < 11 -> tražimo Permission.storage
  //   - Android >= 11 -> tražimo Permission.manageExternalStorage
  // ------------------------------------------------------------------------
  Future<void> _onExportExcelPressed(BuildContext context) async {
    final settings = Provider.of<SettingsProvider>(context, listen: false);

    final androidInfo = await DeviceInfoPlugin().androidInfo;
    final sdkInt = androidInfo.version.sdkInt;

    if (sdkInt >= 30) {
      // Android 11+ -> tražimo MANAGE_EXTERNAL_STORAGE
      await _handleManageExternalStorageFlow(context, settings);
    } else {
      // Android 6..10 (SDK 23..29) -> stara logika s Permission.storage
      await _handleLegacyStorageFlow(context, settings);
    }
  }

  /// Obrada za Android 11+ (SDK >= 30), tražimo MANAGE_EXTERNAL_STORAGE dozvolu.
  Future<void> _handleManageExternalStorageFlow(
      BuildContext context, SettingsProvider settings) async {
    final status = await Permission.manageExternalStorage.status;

    if (status.isGranted) {
      // Već odobreno, samo izvozimo
      await _exportExpenseToExcel();
      return;
    }

    if (status.isDenied) {
      // Nije “Don’t ask again” – prikaži naš dijalog
      final result = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(settings.language == 'hr'
              ? 'Potrebna dozvola za spremanje'
              : 'Storage Permission Required'),
          content: Text(settings.language == 'hr'
              ? 'Aplikacija treba puni pristup datotekama za spremanje u Downloads. Odobriti pristup?'
              : 'The app needs manage-all-files permission to save in Downloads. Allow access now?'),
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
        final newStatus = await Permission.manageExternalStorage.request();
        // Na većini Android 11+ uređaja – to ide u Settings ili odmah “denied”
        if (newStatus.isGranted) {
          // Sada je dozvola odobrena
          await _exportExpenseToExcel();
        } else {
          // I dalje nije
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(settings.language == 'hr'
                  ? 'Dozvola i dalje nije odobrena.'
                  : 'Permission still not granted.'),
            ),
          );
        }
      }
      return;
    }

    if (status.isPermanentlyDenied) {
      // “Don’t ask again” – Android 11+ i dalje vodi u Postavke
      final openSettings = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(settings.language == 'hr'
              ? 'Dozvola za spremanje je onemogućena'
              : 'Storage Permission Disabled'),
          content: Text(settings.language == 'hr'
              ? 'Morate ručno omogućiti "Allow access to all files" u Postavkama. Otvoriti postavke?'
              : 'You must enable "Allow access to all files" in Settings. Open Settings now?'),
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
        await openAppSettings();
        // Vratimo se, pa ako user tamo omogući, super. Inače - i dalje denied.
      }
      return;
    }

    if (status.isRestricted || status.isLimited) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(settings.language == 'hr'
              ? 'Ograničena dozvola. Neće biti moguće spremiti Excel u Downloads.'
              : 'Manage files permission is restricted. Cannot save to Downloads.'),
        ),
      );
      return;
    }
  }

  /// Obrada za Android 6..10 (SDK < 30) -> stara Permission.storage
  Future<void> _handleLegacyStorageFlow(
      BuildContext context, SettingsProvider settings) async {
    final status = await Permission.storage.status;

    if (status.isGranted) {
      // Odmah izvoz
      await _exportExpenseToExcel();
      return;
    }

    if (status.isDenied) {
      final result = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(settings.language == 'hr'
              ? 'Potrebna dozvola za spremanje'
              : 'Storage Permission Required'),
          content: Text(settings.language == 'hr'
              ? 'Aplikacija treba pristup spremanju datoteka. Odobriti pristup?'
              : 'The app needs storage access to save files. Allow now?'),
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
        final newStatus = await Permission.storage.request();
        if (newStatus.isGranted) {
          await _exportExpenseToExcel();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(settings.language == 'hr'
                  ? 'Dozvola i dalje nije odobrena.'
                  : 'Permission still not granted.'),
            ),
          );
        }
      }
      return;
    }

    if (status.isPermanentlyDenied) {
      final openSettings = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(settings.language == 'hr'
              ? 'Dozvola za spremanje je onemogućena'
              : 'Storage Permission Disabled'),
          content: Text(settings.language == 'hr'
              ? 'Morate ručno omogućiti spremanje u Postavkama. Otvoriti postavke?'
              : 'You must enable storage in Settings. Open Settings now?'),
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
        await openAppSettings();
      }
      return;
    }

    if (status.isRestricted || status.isLimited) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(settings.language == 'hr'
              ? 'Ograničena dozvola. Neće biti moguće spremiti Excel.'
              : 'Storage permission restricted. Cannot save Excel.'),
        ),
      );
      return;
    }
  }

  // ------------------------------------------------------------------------
  //  KREIRANJE I SPREMANJE EXCEL-a U Downloads
  // ------------------------------------------------------------------------
  Future<void> _exportExpenseToExcel() async {
    try {
      if (expenses.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Nema troškova za izvoz.')),
        );
        return;
      }

      var excel = Excel.createExcel();
      Sheet sheet = excel['Sheet1'];
      sheet.appendRow([
        TextCellValue("Naziv"),
        TextCellValue("Iznos"),
        TextCellValue("Dan"),
        TextCellValue("Mjesec"),
        TextCellValue("Godina")
      ]);

      for (var expense in expenses) {
        sheet.appendRow([
          TextCellValue(expense.name),
          DoubleCellValue(expense.amount),
          IntCellValue(expense.day),
          IntCellValue(expense.month),
          IntCellValue(expense.year)
        ]);
      }

      final fileBytes = excel.encode();
      if (fileBytes == null) {
        throw Exception("Neuspješno generiranje Excel dokumenta.");
      }

      // Sanitizacija imena
      String sanitize(String input) => input.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');

      // Odredi Downloads putanju
      final downloadsPath = await ExternalPath.getExternalStoragePublicDirectory(
        ExternalPath.DIRECTORY_DOWNLOADS,
      );

      final filePath = "$downloadsPath/analysis_"
          "${sanitize(selectedYear.toString())}_"
          "${sanitize(selectedMonth.toString())}.xlsx";

      final file = File(filePath);
      await file.writeAsBytes(fileBytes, flush: true);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Datoteka spremljena u: $filePath')),
      );

      // Otvori datoteku
      await OpenFile.open(filePath);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Došlo je do pogreške pri izvozu: $e')),
      );
    }
  }

  // ------------------------------------------------------------------------
  //  BUILD
  // ------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final monthNames = settings.language == 'hr'
        ? [
      "Siječanj",
      "Veljača",
      "Ožujak",
      "Travanj",
      "Svibanj",
      "Lipanj",
      "Srpanj",
      "Kolovoz",
      "Rujan",
      "Listopad",
      "Studeni",
      "Prosinac"
    ]
        : [
      "January",
      "February",
      "March",
      "April",
      "May",
      "June",
      "July",
      "August",
      "September",
      "October",
      "November",
      "December"
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          settings.language == 'hr' ? 'Pregled troškova' : 'Expense Overview',
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _onExportExcelPressed(context),
        child: const Icon(Icons.file_download),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE0F7FA), Color(0xFFB2EBF2)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage != null
            ? Center(
          child: Text(
            settings.language == 'hr'
                ? 'Pogreška: $_errorMessage'
                : 'Error: $_errorMessage',
            style: const TextStyle(fontSize: 16),
          ),
        )
            : Padding(
          padding: const EdgeInsets.all(16.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24.0),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Card(
                color: Colors.white.withOpacity(0.75),
                elevation: 12,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      // Gornji red - biranje godine i mjeseca
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButton<int>(
                              value: selectedYear,
                              items: availableYears
                                  .map((year) => DropdownMenuItem<int>(
                                value: year,
                                child: Text(
                                  year.toString(),
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ))
                                  .toList(),
                              onChanged: (int? value) {
                                if (value != null) {
                                  setState(() => selectedYear = value);
                                  _fetchData();
                                }
                              },
                              isExpanded: true,
                              underline: Container(height: 1, color: Colors.grey[300]),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: DropdownButton<int>(
                              value: selectedMonth,
                              items: availableMonths
                                  .map((m) => DropdownMenuItem<int>(
                                value: m,
                                child: Text(
                                  monthNames[m - 1],
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ))
                                  .toList(),
                              onChanged: (int? value) {
                                if (value != null) {
                                  setState(() => selectedMonth = value);
                                  _fetchData();
                                }
                              },
                              isExpanded: true,
                              underline: Container(height: 1, color: Colors.grey[300]),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      // Lista troškova
                      Expanded(
                        child: expenses.isEmpty
                            ? Center(
                          child: Text(
                            settings.language == 'hr'
                                ? 'Nema troškova za odabrani period.'
                                : 'No expenses for the selected period.',
                            style: const TextStyle(fontSize: 16),
                          ),
                        )
                            : ListView.builder(
                          itemCount: expenses.length,
                          itemBuilder: (context, index) {
                            final expense = expenses[index];
                            final expenseInfo =
                                '${expense.name}, ${expense.amount} ${settings.currency}, '
                                '${expense.day}.${expense.month}.${expense.year}.';
                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 8.0),
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: ListTile(
                                leading: IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.blue),
                                  onPressed: () => _editExpense(context, expense),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                title: Text(
                                  expenseInfo,
                                  style: const TextStyle(fontWeight: FontWeight.w600),
                                ),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _confirmDeleteExpense(context, expense),
                                ),
                              ),
                            );
                          },
                        ),
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
}
