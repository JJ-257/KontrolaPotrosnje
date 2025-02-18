
import 'dart:io';
import 'dart:ui';
import 'dart:typed_data' as typed;
import 'package:device_info_plus/device_info_plus.dart';
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../services/expense_service.dart';
import '../services/income_service.dart';
import 'package:open_file/open_file.dart';
import 'package:external_path/external_path.dart';
import 'package:permission_handler/permission_handler.dart';
class AnalysisScreen extends StatefulWidget {
  const AnalysisScreen({super.key});

  @override
  _AnalysisScreenState createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen> {
  int selectedYear = DateTime.now().year;
  int selectedMonth = DateTime.now().month;

  double _dailyExpense = 0.0;
  double _monthlyExpense = 0.0;
  double _yearlyExpense = 0.0;
  double _monthlyIncome = 0.0;
  double _yearlyIncome = 0.0;
  double _monthlyDifference = 0.0;

  bool _isLoading = false;
  String? _errorMessage;

  List<int> availableYears = [];
  final List<int> availableMonths = List.generate(12, (index) => index + 1);

  @override
  void initState() {
    super.initState();
    int currentYear = DateTime.now().year;
    availableYears = List<int>.generate(currentYear - 2019, (index) => 2020 + index);
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final now = DateTime.now();
      if (selectedYear == now.year && selectedMonth == now.month) {
        final dailyExpenses = await ExpenseService.getExpensesForDay(now.year, now.month, now.day);
        _dailyExpense = dailyExpenses.fold<double>(0.0, (sum, expense) => sum + expense.amount);
      } else {
        _dailyExpense = 0.0;
      }
      final monthlyExpenses = await ExpenseService.getExpensesForMonth(selectedYear, selectedMonth);
      final yearlyExpenses = await ExpenseService.getExpensesForYear(selectedYear);
      _monthlyExpense = monthlyExpenses.fold<double>(0.0, (sum, expense) => sum + expense.amount);
      _yearlyExpense = yearlyExpenses.fold<double>(0.0, (sum, expense) => sum + expense.amount);

      final monthlyIncomes = await IncomeService.getIncomesForMonth(selectedYear, selectedMonth);
      final yearlyIncomes = await IncomeService.getIncomesForYear(selectedYear);
      _monthlyIncome = monthlyIncomes.fold<double>(0.0, (sum, income) => sum + income.amount);
      _yearlyIncome = yearlyIncomes.fold<double>(0.0, (sum, income) => sum + income.amount);

      _monthlyDifference = _monthlyIncome - _monthlyExpense;
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    }
    setState(() => _isLoading = false);
  }

  String _formatAmount(double amount, String currency) {
    return '${amount.toStringAsFixed(2)} $currency';
  }

  /// Metoda koja traži potrebne dozvole za čitanje/pisanje u spoljašnju memoriju.
  // Future<bool> _requestPermissions() async {
  //   // 1. Za Android 6 do 10 (SDK 23 do 29)
  //   var storageStatus = await Permission.storage.request();
  //
  //   // 2. Za Android 11 i novije (MANAGE_EXTERNAL_STORAGE)
  //   // Kod ispod pokušava da traži "Manage all files" dozvolu.
  //   if (storageStatus.isGranted) {
  //     var manageStorageStatus = await Permission.manageExternalStorage.request();
  //     // Ako je i to odobreno ili nije primenljivo (na starijim verzijama),
  //     // možemo nastaviti dalje.
  //     if (manageStorageStatus.isGranted || manageStorageStatus.isLimited) {
  //       return true;
  //     }
  //     // Ako nije odobreno, ali je storageStatus bio granted, vratimo true
  //     // za starije verzije Androida.
  //     // (Na novijima će ipak baciti grešku ako korisnik ne odobri "manage external storage".)
  //     return true;
  //   }
  //
  //   // Ako nije ni storage dozvola odobrena, vrati false.
  //   return false;
  // }

  // Ovo možeš staviti npr. u neki util fajl, ili unutar samog screen-a:
  // Future<bool> requestStoragePermissions() async {
  //   // 1. Tražimo klasičnu dozvolu za storage (za Android 6 do 10).
  //   final storageStatus = await Permission.storage.request();
  //
  //   // 2. Ako smo dobili storage dozvolu, onda za Android 11+ (manageExternalStorage).
  //   //    Ako je telefon stariji (SDK < 30), ovo neće praviti problem.
  //   if (storageStatus.isGranted) {
  //     final manageExternalStatus = await Permission.manageExternalStorage.request();
  //
  //     // Ako je odobreno (ili nije neophodno), vrati true.
  //     // Napomena: .isLimited može se pojaviti na iOS-u, ali ne i na Androidu.
  //     if (manageExternalStatus.isGranted || manageExternalStatus.isLimited) {
  //       return true;
  //     }
  //
  //     // Ako je korisnik odbio MANAGE_EXTERNAL_STORAGE, ali je ipak dao osnovnu dozvolu,
  //     // za starije verzije Androida to može biti dovoljno.
  //     // Možeš vratiti true da bar starije verzije rade.
  //     return true;
  //   }
  //
  //   // Ako storageStatus nije ni odobren, vrati false.
  //   return false;
  // }
  // Future<bool> requestStoragePermissions(BuildContext context) async {
  //   // Uzimamo SettingsProvider da bismo doznali jezik
  //   final settings = Provider.of<SettingsProvider>(context, listen: false);
  //
  //   // Definišemo stringove za poruke
  //   final permanentlyDeniedMessageHr = 'Omogućite dozvolu u Postavkama kako biste mogli sačuvati Excel datoteke.';
  //   final permanentlyDeniedMessageEn = 'Allow permission in Settings to be able to save Excel files.';
  //
  //   final settingsLabelHr = 'Postavke';
  //   final settingsLabelEn = 'Settings';
  //
  //   // 1. Proverimo trenutni status “storage” dozvole (READ/WRITE)
  //   PermissionStatus storageStatus = await Permission.storage.status;
  //
  //   // Ako je trajno odbijena (“Don’t ask again”)
  //   if (storageStatus.isPermanentlyDenied) {
  //     // Pokažemo SnackBar sa akcijom “Postavke”/”Settings”
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text(
  //           settings.language == 'hr'
  //               ? permanentlyDeniedMessageHr
  //               : permanentlyDeniedMessageEn,
  //         ),
  //         action: SnackBarAction(
  //           label: settings.language == 'hr'
  //               ? settingsLabelHr
  //               : settingsLabelEn,
  //           onPressed: () {
  //             // Otvaramo App Settings
  //             openAppSettings();
  //           },
  //         ),
  //       ),
  //     );
  //     return false;
  //   }
  //
  //   // 2. Ako nije permanentlyDenied, onda zatražimo storage dozvolu
  //   storageStatus = await Permission.storage.request();
  //
  //   // Ako i posle traženja nije odobreno, obavestimo korisnika
  //   if (!storageStatus.isGranted) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text(
  //           settings.language == 'hr'
  //               ? 'Storage dozvola nije odobrena.'
  //               : 'Storage permission not granted.',
  //         ),
  //       ),
  //     );
  //     return false;
  //   }
  //
  //   // 3. Za Android 11+ treba i MANAGE_EXTERNAL_STORAGE (ako hoćeš pristup Downloads folderu)
  //   PermissionStatus manageStatus = await Permission.manageExternalStorage.status;
  //
  //   if (manageStatus.isPermanentlyDenied) {
  //     // Isti scenario: SnackBar s akcijom
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text(
  //           settings.language == 'hr'
  //               ? permanentlyDeniedMessageHr
  //               : permanentlyDeniedMessageEn,
  //         ),
  //         action: SnackBarAction(
  //           label: settings.language == 'hr'
  //               ? settingsLabelHr
  //               : settingsLabelEn,
  //           onPressed: () {
  //             openAppSettings();
  //           },
  //         ),
  //       ),
  //     );
  //     return false;
  //   }
  //
  //   // Ako još nije odobreno (samo "denied"), probamo da tražimo
  //   if (!manageStatus.isGranted) {
  //     manageStatus = await Permission.manageExternalStorage.request();
  //     if (!manageStatus.isGranted) {
  //       // Korisnik je odbio
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Text(
  //             settings.language == 'hr'
  //                 ? 'Pristup svim datotekama nije odobren.'
  //                 : 'Manage all files permission not granted.',
  //           ),
  //         ),
  //       );
  //       return false;
  //     }
  //   }
  //
  //   // Ako smo stigli ovde, sve dozvole su OK
  //   return true;
  // }

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
      await _exportAnalysisToExcel();
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
          await _exportAnalysisToExcel();
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
      await _exportAnalysisToExcel();
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
          await _exportAnalysisToExcel();
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

  Future<void> _exportAnalysisToExcel() async {
    try {



      // 1. Kreiraj Excel dokument i preimenuj default list
      var excel = Excel.createExcel();
      excel.rename("Sheet1", "Analysis");
      Sheet sheet = excel['Analysis'];

      // 2. Postavi zaglavlje
      sheet.appendRow([
        TextCellValue("Godina"),
        TextCellValue("Mjesec"),
        TextCellValue("Dnevni trošak"),
        TextCellValue("Mjesečni trošak"),
        TextCellValue("Godišnji trošak"),
        TextCellValue("Mjesečni prihod"),
        TextCellValue("Godišnji prihod"),
        TextCellValue("Razlika mjeseči prihod - mjesečni trošak")
      ]);

      // 3. Dodaj podatke
      sheet.appendRow([
        IntCellValue(selectedYear),
        IntCellValue(selectedMonth),
        DoubleCellValue(_dailyExpense),
        DoubleCellValue(_monthlyExpense),
        DoubleCellValue(_yearlyExpense),
        DoubleCellValue(_monthlyIncome),
        DoubleCellValue(_yearlyIncome),
        DoubleCellValue(_monthlyDifference)
      ]);

      List<int>? fileBytes = excel.encode();

      if (fileBytes == null) {
        throw Exception("Neuspješno generiranje Excel dokumenta.");
      }

      // Sanitiziraj ime datoteke (opcionalno)
      String sanitize(String input) => input.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');
      String fileName = "analysis_${sanitize(selectedYear.toString())}_${sanitize(selectedMonth.toString())}.xlsx";

      // Preuzimanje puta do Downloads direktorija
      String downloadsPath = await ExternalPath.getExternalStoragePublicDirectory(
        ExternalPath.DIRECTORY_DOWNLOADS,
      );
      String filePath = "$downloadsPath/$fileName";

      File file = File(filePath);
      await file.writeAsBytes(fileBytes, flush: true);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Datoteka spremljena u: $filePath')),
      );

      OpenFile.open(filePath);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Došlo je do pogreške pri izvozu: $e')),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final String title = settings.language == 'hr' ? 'Analiza potrošnje' : 'Expense Analysis';
    final List<String> monthNames = settings.language == 'hr'
        ? ["Siječanj", "Veljača", "Ožujak", "Travanj", "Svibanj", "Lipanj", "Srpanj", "Kolovoz", "Rujan", "Listopad", "Studeni", "Prosinac"]
        : ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"];

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _onExportExcelPressed(context),
        child: const Icon(Icons.file_download),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFB3E5FC), Color(0xFFE1F5FE)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage != null
            ? Center(child: Text(
          settings.language == 'hr' ? 'Pogreška: $_errorMessage' : 'Error: $_errorMessage',
          style: const TextStyle(fontSize: 16),
        ))
            : Padding(
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                              onChanged: (value) {
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
                                  .map((month) => DropdownMenuItem<int>(
                                value: month,
                                child: Text(
                                  monthNames[month - 1],
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ))
                                  .toList(),
                              onChanged: (value) {
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
                      if (selectedYear == DateTime.now().year && selectedMonth == DateTime.now().month) ...[
                        Text(
                          settings.language == 'hr'
                              ? 'Današnji trošak: ${_formatAmount(_dailyExpense, settings.currency)}'
                              : 'Daily Expense: ${_formatAmount(_dailyExpense, settings.currency)}',
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 16),
                      ],
                      Text(
                        settings.language == 'hr'
                            ? 'Mjesečni trošak: ${_formatAmount(_monthlyExpense, settings.currency)}'
                            : 'Monthly Expense: ${_formatAmount(_monthlyExpense, settings.currency)}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        settings.language == 'hr'
                            ? 'Godišnji trošak: ${_formatAmount(_yearlyExpense, settings.currency)}'
                            : 'Yearly Expense: ${_formatAmount(_yearlyExpense, settings.currency)}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        settings.language == 'hr'
                            ? 'Mjesečni prihod: ${_formatAmount(_monthlyIncome, settings.currency)}'
                            : 'Monthly Income: ${_formatAmount(_monthlyIncome, settings.currency)}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        settings.language == 'hr'
                            ? 'Godišnji prihod: ${_formatAmount(_yearlyIncome, settings.currency)}'
                            : 'Yearly Income: ${_formatAmount(_yearlyIncome, settings.currency)}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        settings.language == 'hr'
                            ? 'Razlika (mjesečni prihod - mjesečni trošak): ${_formatAmount(_monthlyDifference, settings.currency)}'
                            : 'Difference (monthly income - monthly expense): ${_formatAmount(_monthlyDifference, settings.currency)}',
                        style: TextStyle(
                          fontSize: 16,
                          color: _monthlyDifference >= 0 ? Colors.green : Colors.red,
                          fontWeight: FontWeight.bold,
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

