
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../models/expense.dart';
import '../services/expense_service.dart';

class ManualExpenseScreen extends StatefulWidget {
  const ManualExpenseScreen({super.key});

  @override
  _ManualExpenseScreenState createState() => _ManualExpenseScreenState();
}

class _ManualExpenseScreenState extends State<ManualExpenseScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() => _selectedDate = pickedDate);
    }
  }

  Future<void> _saveExpense() async {
    if (_formKey.currentState!.validate()) {
      final name = _nameController.text;
      final amount = double.parse(_amountController.text);
      final newExpense = Expense(
        id: '',
        name: name,
        amount: amount,
        date: _selectedDate,
        year: _selectedDate.year,
        month: _selectedDate.month,
        day: _selectedDate.day,
      );
      await ExpenseService.addExpense(newExpense);
      _nameController.clear();
      _amountController.clear();
      setState(() => _selectedDate = DateTime.now());
      final settings = Provider.of<SettingsProvider>(context, listen: false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(settings.language == 'hr'
              ? 'Trošak spremljen!'
              : 'Expense saved!'),
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
        title: Text(settings.language == 'hr'
            ? 'Unos troška'
            : 'Manual Expense Entry'),
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
            padding:
            const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
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
                    padding: const EdgeInsets.all(32.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          Text(
                            settings.language == 'hr'
                                ? 'Unesite podatke o trošku'
                                : 'Enter expense details',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 32),
                          TextFormField(
                            controller: _nameController,
                            decoration: InputDecoration(
                              labelText: settings.language == 'hr'
                                  ? 'Naziv troška'
                                  : 'Expense Name',
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
                            controller: _amountController,
                            decoration: InputDecoration(
                              labelText: settings.language == 'hr'
                                  ? 'Iznos (EUR)'
                                  : 'Amount (EUR)',
                              prefixIcon: const Icon(Icons.attach_money),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || double.tryParse(value) == null) {
                                return settings.language == 'hr'
                                    ? 'Unesite ispravan iznos'
                                    : 'Enter a valid amount';
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
                            onPressed: _saveExpense,
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
                              settings.language == 'hr' ? 'Spremi' : 'Save',
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
