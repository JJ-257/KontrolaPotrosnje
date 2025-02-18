import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../models/expense.dart';
import '../services/expense_service.dart';

class ScanBarcodeScreen extends StatefulWidget {
  const ScanBarcodeScreen({Key? key}) : super(key: key);

  @override
  _ScanBarcodeScreenState createState() => _ScanBarcodeScreenState();
}

class _ScanBarcodeScreenState extends State<ScanBarcodeScreen> {
  final MobileScannerController _controller = MobileScannerController(
    facing: CameraFacing.back,
    detectionSpeed: DetectionSpeed.noDuplicates,
    detectionTimeoutMs: 500,
    autoStart: true,
    formats: [ BarcodeFormat.aztec,
      BarcodeFormat.code128,
      BarcodeFormat.code39,
      BarcodeFormat.code93,
      BarcodeFormat.codabar,
      BarcodeFormat.dataMatrix,
      BarcodeFormat.ean13,
      BarcodeFormat.ean8,
      BarcodeFormat.itf,
      BarcodeFormat.pdf417,
      BarcodeFormat.qrCode,
      BarcodeFormat.upcA,
      BarcodeFormat.upcE],
  );

  bool _flashOn = false;
  bool _isProcessing = false;
  Timer? _scanTimer;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Skeniraj Barkod'),
        actions: [
          IconButton(
            icon: Icon(_flashOn ? Icons.flash_on : Icons.flash_off),
            onPressed: _toggleFlash,
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: _handleDetection,
          ),
          if (_isProcessing)
            const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 20),
                  Text('Obrađujem podatke...', style: TextStyle(color: Colors.white)),
                ],
              ),
            ),
          CustomPaint(painter: _BarcodeScannerOverlay()),
        ],
      ),
    );
  }

  void _toggleFlash() {
    setState(() => _flashOn = !_flashOn);
    _controller.toggleTorch();
  }

  Future<void> _handleDetection(BarcodeCapture capture) async {
    if (_isProcessing) return;
    final barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    setState(() => _isProcessing = true);
    _controller.stop();

    try {
      final rawValue = barcodes.first.rawValue;
      if (rawValue == null) throw Exception('Prazan barkod');

      final expense = _parseBarcodeData(rawValue);
      await ExpenseService.addExpense(expense);

      if (!mounted) return;
      _showSuccessMessage();
    } catch (e) {
      if (!mounted) return;
      _showErrorMessage(e);
    } finally {
      _resetScanner();
    }
  }

  Expense _parseBarcodeData(String rawData) {
  //  final lines = rawData.split('\n').map((line) => line.trim()).toList();

    // Parsiranje iznosa
   // final amountLine = lines.firstWhere((line) => line.startsWith('0000000'), orElse: () => '');
    final amount = _parseAmount(rawData);

    // Parsiranje naziva troška
    final expenseName = _extractExpenseName(rawData);

    // Trenutni datum skeniranja
    final now = DateTime.now();

    return Expense(
      id: '',
      name: expenseName,
      amount: amount,
      date: now,
      year: now.year,
      month: now.month,
      day: now.day,
    );
  }

  // double _parseAmount(String amountStr) {
  //   if (amountStr.isEmpty) throw Exception('Nema iznosa u barkodu');
  //   final cleanAmount = amountStr.replaceAll(RegExp(r'[^0-9]'), '');
  //
  //   if (cleanAmount.length < 3) throw Exception('Neispravan format iznosa');
  //
  //   // Posljednje dvije znamenke su decimalne
  //   final mainPart = cleanAmount.substring(0, cleanAmount.length - 2);
  //   final decimalPart = cleanAmount.substring(cleanAmount.length - 2);
  //   return double.parse('$mainPart.$decimalPart');
  // }

  // double _parseAmount(String rawData) {
  //   // Razdvajamo barkod podatke po novom redu, tabovima ili drugim separatorima
  //   final fields = rawData.split(RegExp(r'[\n|\t|;]')).map((e) => e.trim()).toList();
  //
  //   // Provjera ima li dovoljno polja (barem 2)
  //   if (fields.length < 3) {
  //     throw Exception('Barkod nema dovoljno polja za iznos');
  //   }
  //
  //   final amountStr = fields[2]; // Drugo polje (indeks 1 jer indeksiranje kreće od 0)
  //
  //   if (amountStr.isEmpty) throw Exception('Iznos nije pronađen u barkodu');
  //
  //   // Čistimo iznos tako da ostanu samo brojevi
  //   final cleanAmount = amountStr.replaceAll(RegExp(r'[^0-9]'), '');
  //
  //   if (cleanAmount.length < 3) throw Exception('Neispravan format iznosa');
  //
  //   // Posljednje dvije znamenke su decimalne
  //   final mainPart = cleanAmount.substring(0, cleanAmount.length - 2);
  //   final decimalPart = cleanAmount.substring(cleanAmount.length - 2);
  //
  //   return double.parse('$mainPart.$decimalPart');
  // }

  double _parseAmount(String rawData) {
    // Razdvajamo barkod podatke po novom redu, tabovima ili drugim separatorima
    final fields = rawData.split(RegExp(r'[\n|\t|;]')).map((e) => e.trim()).toList();

    // Provjera ima li dovoljno polja (barem 3)
    if (fields.length < 3) {
      throw Exception('Barkod nema dovoljno polja za iznos');
    }

    final amountStr = fields[2]; // Treće polje (indeks 2 jer indeksiranje kreće od 0)

    if (amountStr.isEmpty) throw Exception('Iznos nije pronađen u barkodu');

    // Čistimo iznos tako da ostanu samo brojevi
    String cleanAmount = amountStr.replaceAll(RegExp(r'[^0-9]'), '');

    if (cleanAmount.isEmpty) throw Exception('Iznos nije u ispravnom formatu');

    // Ignoriramo početne nule
    cleanAmount = cleanAmount.replaceFirst(RegExp(r'^0+'), '');

    // Ako je ostalo manje od 3 znamenke, dodajemo vodeću nulu za decimalni dio
    if (cleanAmount.length == 1) cleanAmount = '00$cleanAmount';
    if (cleanAmount.length == 2) cleanAmount = '0$cleanAmount';

    // Posljednje dvije znamenke su decimalne
    final mainPart = cleanAmount.substring(0, cleanAmount.length - 2);
    final decimalPart = cleanAmount.substring(cleanAmount.length - 2);

    return double.parse('$mainPart.$decimalPart');
  }



  String _extractExpenseName(String rawData) {
    // Podaci su odvojeni novim redom, tabovima ili drugim separatorima
    final fields = rawData.split(RegExp(r'[\n|\t|;]')).map((e) => e.trim()).toList();

    // Provjera ima li dovoljno polja (barem 7)
    if (fields.length >= 7) {
      return fields[6];
    } else {
      throw Exception('Nema dovoljno podataka u barkodu');
    }
  }


  void _showSuccessMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Trošak uspješno spremljen!')),
    );
  }

  void _showErrorMessage(dynamic e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Greška: ${e.toString().replaceAll('Exception: ', '')}')),
    );
  }

  void _resetScanner() {
    _scanTimer?.cancel();
    _scanTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) setState(() => _isProcessing = false);
      _controller.start();
    });
  }

  @override
  void dispose() {
    _scanTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }
}

class _BarcodeScannerOverlay extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.red.withOpacity(0.3)
      ..strokeWidth = 4.0
      ..style = PaintingStyle.stroke;
    const borderLength = 30.0;
    const cornerRadius = 10.0;
    final width = size.width * 0.7;
    final height = size.height * 0.2;
    final center = Offset(size.width / 2, size.height / 2);
    final rect = Rect.fromCenter(center: center, width: width, height: height);
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(cornerRadius)),
      paint,
    );
    _drawCorner(canvas, paint, rect.topLeft, borderLength);
    _drawCorner(canvas, paint, rect.topRight, -borderLength);
    _drawCorner(canvas, paint, rect.bottomLeft, borderLength, isBottom: true);
    _drawCorner(canvas, paint, rect.bottomRight, -borderLength, isBottom: true);
  }

  void _drawCorner(Canvas canvas, Paint paint, Offset offset, double length, {bool isBottom = false}) {
    final dx = length;
    final dy = isBottom ? -length : length;
    canvas.drawLine(offset, offset.translate(dx, 0), paint);
    canvas.drawLine(offset, offset.translate(0, dy), paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
