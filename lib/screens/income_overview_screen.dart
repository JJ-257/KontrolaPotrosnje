
import 'dart:io';
import 'dart:ui';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:excel/excel.dart';
import 'package:external_path/external_path.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import '../models/income.dart';
import '../providers/settings_provider.dart';
import '../services/income_service.dart';
import 'package:open_file/open_file.dart';

class IncomeOverviewScreen extends StatefulWidget {
  const IncomeOverviewScreen({super.key});

  @override
  _IncomeOverviewScreenState createState() => _IncomeOverviewScreenState();
}

class _IncomeOverviewScreenState extends State<IncomeOverviewScreen> {
  int selectedYear = DateTime.now().year;
  int selectedMonth = DateTime.now().month;
  List<Income> incomes = [];
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
      incomes = await IncomeService.getIncomesForMonth(selectedYear, selectedMonth);
      // Sortiranje: najnoviji (po datumu) na vrhu, a ako je datum isti, abecedno uzlazno
      incomes.sort((a, b) {
        final dateA = DateTime(a.year, a.month, a.day);
        final dateB = DateTime(b.year, b.month, b.day);
        final cmpDate = dateB.compareTo(dateA); // descending
        if (cmpDate != 0) return cmpDate;
        return a.name.compareTo(b.name); // abecedno uzlazno
      });
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    }
    setState(() => _isLoading = false);
  }

  Future<void> _confirmDeleteIncome(BuildContext context, Income income) async {
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(settings.language == 'hr' ? 'Obriši prihod' : 'Delete Income'),
        content: Text(settings.language == 'hr'
            ? 'Jeste li sigurni da želite obrisati prihod?'
            : 'Are you sure you want to delete this income?'),
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
      await IncomeService.deleteIncome(income.id);
      _fetchData();
    }
  }

  Future<void> _editIncome(BuildContext context, Income income) async {
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    final TextEditingController nameController = TextEditingController(text: income.name);
    final TextEditingController amountController = TextEditingController(text: income.amount.toString());

    final bool? saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(settings.language == 'hr' ? 'Uredi prihod' : 'Edit Income'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: settings.language == 'hr' ? 'Naziv prihoda' : 'Income Name',
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
        // Ažurirajte podatke prihoda
        income.name = newName;
        income.amount = newAmount;
        // Pretpostavlja se da metoda updateIncome postoji u IncomeService
        await IncomeService.updateIncome(income);
        _fetchData();
      }
    }
  }


  // /// Metoda koja traži potrebne dozvole za čitanje/pisanje u spoljašnju memoriju.
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
  Future<void> _onIncomeExcelPressed(BuildContext context) async {
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
      await _exportIncomeToExcel();
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
          await _exportIncomeToExcel();
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
      await _exportIncomeToExcel();
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
          await _exportIncomeToExcel();
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

  Future<void> _exportIncomeToExcel() async {
    try {
      if (incomes.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Nema prihoda za izvoz.')),
        );
        return;
      }
      // Prvo tražimo dozvole
      // bool hasPermission = await _requestPermissions();
      // if (!hasPermission) {
      //   ScaffoldMessenger.of(context).showSnackBar(
      //     const SnackBar(content: Text('Nemate dozvolu za spremanje datoteke.')),
      //   );
      //   return;
      // }

      // // 1. Proveri prvo da li imaš dozvolu
      // bool hasPermission = await requestStoragePermissions(context);
      // if (!hasPermission) {
      //   // Korisnik je odbio dozvolu ili je "Don’t ask again"
      //   // (u kom slučaju se dijalog više ne pojavljuje)
      //   ScaffoldMessenger.of(context).showSnackBar(
      //     const SnackBar(content: Text('Nemate dozvolu za spremanje datoteke.')),
      //   );
      //   return; // Prekini izvođenje
      // }

      // 1. Kreiranje Excel dokumenta
      final Excel excel = Excel.createExcel();
      final Sheet sheet = excel['Sheet1'];

      // 2. Postavljanje zaglavlja
      sheet.appendRow([
        //TextCellValue("ID"),
        TextCellValue("Naziv"),
        TextCellValue("Iznos"),
        TextCellValue("Dan"),
        TextCellValue("Mjesec"),
        TextCellValue("Godina")
      ]);

      // 3. Popunjavanje podacima
      for (final income in incomes) {
        sheet.appendRow([
         // TextCellValue(income.id),
          TextCellValue(income.name),
          DoubleCellValue(income.amount),
          IntCellValue(income.day),
          IntCellValue(income.month),
          IntCellValue(income.year)
        ]);
      }


      List<int>? fileBytes = excel.encode();

      if (fileBytes == null) {
        throw Exception("Neuspješno generiranje Excel dokumenta.");
      }

      // Ispravak 2: Dodana sanitizacija imena datoteke
      String sanitize(String input) => input.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');

      String downloadsPath = await ExternalPath.getExternalStoragePublicDirectory(
        ExternalPath.DIRECTORY_DOWNLOADS,
      );

      String filePath = "$downloadsPath/analysis_"
          "${sanitize(selectedYear.toString())}_"
          "${sanitize(selectedMonth.toString())}.xlsx";

      File file = File(filePath);

      // Ispravak 3: Uklonjen nepotreban cast
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
    final List<String> monthNames = settings.language == 'hr'
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
        title: Text(settings.language == 'hr' ? 'Pregled prihoda' : 'Income Overview'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _onIncomeExcelPressed(context),
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
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
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
                      Expanded(
                        child: incomes.isEmpty
                            ? Center(
                          child: Text(
                            settings.language == 'hr'
                                ? 'Nema prihoda za odabrani period.'
                                : 'No incomes for the selected period.',
                            style: const TextStyle(fontSize: 16),
                          ),
                        )
                            : ListView.builder(
                          itemCount: incomes.length,
                          itemBuilder: (context, index) {
                            final income = incomes[index];
                            final incomeInfo =
                                '${income.name}, ${income.amount} ${settings.currency}, ${income.day}.${income.month}.${income.year}.';
                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 8.0),
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: ListTile(
                                leading: IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.blue),
                                  onPressed: () => _editIncome(context, income),
                                ),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                title: Text(
                                  incomeInfo,
                                  style: const TextStyle(fontWeight: FontWeight.w600),
                                ),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _confirmDeleteIncome(context, income),
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
