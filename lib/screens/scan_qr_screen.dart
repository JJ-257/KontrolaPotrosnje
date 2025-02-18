
import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;
import '../models/expense.dart';
import '../services/expense_service.dart';

class ScanQrScreen extends StatefulWidget {
  const ScanQrScreen({Key? key}) : super(key: key);

  @override
  _ScanQrScreenState createState() => _ScanQrScreenState();
}

class _ScanQrScreenState extends State<ScanQrScreen> {
  final MobileScannerController _controller = MobileScannerController(
    facing: CameraFacing.back,
    detectionSpeed: DetectionSpeed.noDuplicates,
    detectionTimeoutMs: 500,
    autoStart: true,
    formats: [BarcodeFormat.qrCode],
  );

  bool _flashOn = false;
  bool _isProcessing = false;
  Timer? _scanTimer;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Skeniraj QR račun'),
        actions: [
          IconButton(
            icon: Icon(_flashOn ? Icons.flash_on : Icons.flash_off),
            onPressed: _toggleFlash,
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFB3E5FC), Color(0xFFE1F5FE)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
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
                    Text('Procesiram račun...', style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
            CustomPaint(painter: _QrScannerOverlay()),
          ],
        ),
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
      if (rawValue == null) throw Exception('Prazan QR kod');
      final expense = await _fetchAndParseWebData(rawValue);
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

  Future<Expense> _fetchAndParseWebData(String url) async {
    try {
      final response = await http.get(Uri.parse(url)).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw TimeoutException('Vrijeme čekanja isteklo'),
      );
      if (response.statusCode != 200) {
        throw Exception('Ne mogu dohvatiti podatke sa stranice');
      }
      final document = parser.parse(response.body);
      final dateInput = document.getElementById('datumIzdavanja');
      final amountInput = document.getElementById('iznos');
      if (dateInput == null || amountInput == null) {
        throw Exception('Nedostaju potrebna polja na stranici');
      }
      final dateStr = dateInput.attributes['value']?.trim() ?? '';
      final amountStr = amountInput.attributes['value']?.trim() ?? '';
      if (dateStr.isEmpty) throw Exception('Datum nije postavljen');
      if (amountStr.isEmpty) throw Exception('Iznos nije postavljen');
      final parsedDate = _parseDate(dateStr);
      return Expense(
        id: '',
        name: 'Račun (QR)',
        amount: _parseAmount(amountStr),
        date: parsedDate,
        year: parsedDate.year,
        month: parsedDate.month,
        day: parsedDate.day,
      );
    } on FormatException {
      throw Exception('Neispravan format podataka');
    } on TimeoutException {
      throw Exception('Server ne odgovara');
    } catch (e) {
      throw Exception('Greška pri obradi podataka: ${e.toString()}');
    }
  }

  DateTime _parseDate(String input) {
    try {
      final cleaned = input.replaceAll(RegExp(r'[^\d]'), '');
      if (cleaned.length != 8) throw Exception('Neispravan format datuma');
      return DateTime(
        int.parse(cleaned.substring(4, 8)),
        int.parse(cleaned.substring(2, 4)),
        int.parse(cleaned.substring(0, 2)),
      );
    } catch (e) {
      throw Exception('Neispravan datum: $input');
    }
  }

  double _parseAmount(String input) {
    try {
      return double.parse(
        input.replaceAll(',', '.').replaceAll(RegExp(r'[^0-9.]'), ''),
      );
    } catch (e) {
      throw Exception('Neispravan iznos: $input');
    }
  }

  void _showSuccessMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Račun uspješno spremljen!')),
    );
  }

  void _showErrorMessage(dynamic e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Greška: ${e.toString().replaceAll('Exception: ', '')}')),
    );
  }

  void _resetScanner() {
    _scanTimer?.cancel();
    _scanTimer = Timer(const Duration(seconds: 1), () {
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

class _QrScannerOverlay extends CustomPainter {
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
