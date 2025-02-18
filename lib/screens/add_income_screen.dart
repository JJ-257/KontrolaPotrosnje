
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../models/income.dart';
import '../services/income_service.dart';

class AddIncomeScreen extends StatefulWidget {
  const AddIncomeScreen({super.key});

  @override
  _AddIncomeScreenState createState() => _AddIncomeScreenState();
}

class _AddIncomeScreenState extends State<AddIncomeScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _incomeNameController = TextEditingController();
  final TextEditingController _incomeAmountController = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  @override
  void dispose() {
    _incomeNameController.dispose();
    _incomeAmountController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _saveIncome() async {
    if (_formKey.currentState!.validate()) {
      final name = _incomeNameController.text;
      final amount = double.tryParse(_incomeAmountController.text) ?? 0.0;
      final newIncome = Income(
        id: '',
        name: name,
        amount: amount,
        date: _selectedDate,
        year: _selectedDate.year,
        month: _selectedDate.month,
        day: _selectedDate.day,
      );
      await IncomeService.addIncome(newIncome);
      _incomeNameController.clear();
      _incomeAmountController.clear();
      setState(() => _selectedDate = DateTime.now());
      final settings = Provider.of<SettingsProvider>(context, listen: false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            settings.language == 'hr' ? 'Prihod spremljen!' : 'Income saved!',
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
        title: Text(settings.language == 'hr' ? 'Unos prihoda' : 'Add Income'),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFB3E5FC), Color(0xFFE1F5FE)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24.0),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Card(
                  color: Colors.white.withOpacity(0.75),
                  elevation: 12,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          Text(
                            settings.language == 'hr'
                                ? 'Unesite podatke o prihodu'
                                : 'Enter income details',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 32),
                          TextFormField(
                            controller: _incomeNameController,
                            decoration: InputDecoration(
                              labelText: settings.language == 'hr'
                                  ? 'Naziv prihoda'
                                  : 'Income Name',
                              prefixIcon: const Icon(Icons.title),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return settings.language == 'hr'
                                    ? 'Unesite naziv'
                                    : 'Enter name';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),
                          TextFormField(
                            controller: _incomeAmountController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: settings.language == 'hr'
                                  ? 'Iznos (${settings.currency})'
                                  : 'Amount (${settings.currency})',
                              prefixIcon: const Icon(Icons.attach_money),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return settings.language == 'hr'
                                    ? 'Unesite iznos'
                                    : 'Enter amount';
                              }
                              if (double.tryParse(value) == null) {
                                return settings.language == 'hr'
                                    ? 'Unesite važeći broj'
                                    : 'Enter a valid number';
                              }
                              if (double.parse(value) < 0) {
                                return settings.language == 'hr'
                                    ? 'Iznos ne može biti negativan'
                                    : 'Amount cannot be negative';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  settings.language == 'hr'
                                      ? 'Datum: ${_selectedDate.day}.${_selectedDate.month}.${_selectedDate.year}'
                                      : 'Date: ${_selectedDate.day}.${_selectedDate.month}.${_selectedDate.year}',
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ),
                              TextButton.icon(
                                onPressed: () => _selectDate(context),
                                icon: const Icon(Icons.calendar_today),
                                label: Text(
                                  settings.language == 'hr'
                                      ? 'Promijeni datum'
                                      : 'Change date',
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 32),
                          ElevatedButton(
                            onPressed: _saveIncome,
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              textStyle: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            child: Text(
                              settings.language == 'hr'
                                  ? 'Spremi prihod'
                                  : 'Save Income',
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
        ),
      ),
    );
  }
}
