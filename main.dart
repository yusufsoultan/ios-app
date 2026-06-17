import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const CalculatorApp());
}

class CalculatorApp extends StatelessWidget {
  const CalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calculator',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
        primaryColor: Colors.black,
      ),
      home: const CalculatorScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String _display = '0';
  double _currentNumber = 0;
  double _previousNumber = 0;
  String? _operation;
  bool _isNewEntry = true;
  bool _isError = false;

  final List<List<String>> _buttons = [
    ['AC', '±', '%', '÷'],
    ['7', '8', '9', '×'],
    ['4', '5', '6', '−'],
    ['1', '2', '3', '+'],
    ['0', '.', '='],
  ];

  void _tapButton(String button) {
    setState(() {
      if (_isError) {
        _clearAll();
        return;
      }

      switch (button) {
        case 'AC':
          _clearAll();
          break;

        case '±':
          if (_display != '0') {
            if (_display.startsWith('-')) {
              _display = _display.substring(1);
            } else {
              _display = '-$_display';
            }
            _currentNumber = double.tryParse(_display) ?? 0;
          }
          break;

        case '%':
          final num = double.tryParse(_display) ?? 0;
          _display = (num / 100).toString();
          // Remove trailing zeros
          _display = _formatNumber(_display);
          _currentNumber = double.tryParse(_display) ?? 0;
          break;

        case '÷':
        case '×':
        case '−':
        case '+':
          _previousNumber = double.tryParse(_display) ?? 0;
          _operation = button;
          _isNewEntry = true;
          break;

        case '=':
          _calculateResult();
          break;

        default: // Numbers and dot
          if (_isNewEntry) {
            _display = button == '.' ? '0.' : button;
            _isNewEntry = false;
          } else {
            if (button == '.' && _display.contains('.')) return;
            if (_display == '0' && button != '.') {
              _display = button;
            } else {
              _display += button;
            }
          }
          _currentNumber = double.tryParse(_display) ?? 0;
      }
    });
  }

  void _calculateResult() {
    final current = double.tryParse(_display) ?? 0;
    double result = 0;

    switch (_operation) {
      case '+':
        result = _previousNumber + current;
        break;
      case '−':
        result = _previousNumber - current;
        break;
      case '×':
        result = _previousNumber * current;
        break;
      case '÷':
        if (current == 0) {
          _display = 'Error';
          _isError = true;
          return;
        }
        result = _previousNumber / current;
        break;
      default:
        return;
    }

    _display = _formatNumber(result.toString());
    _currentNumber = result;
    _operation = null;
    _isNewEntry = true;
  }

  void _clearAll() {
    _display = '0';
    _currentNumber = 0;
    _previousNumber = 0;
    _operation = null;
    _isNewEntry = true;
    _isError = false;
  }

  String _formatNumber(String number) {
    // Remove trailing zeros and decimal point if unnecessary
    if (number.contains('.')) {
      number = number.replaceAll(RegExp(r'0+$'), '');
      if (number.endsWith('.')) {
        number = number.substring(0, number.length - 1);
      }
    }
    return number;
  }

  Color _getButtonColor(String button) {
    if (['÷', '×', '−', '+', '='].contains(button)) {
      return Colors.orange;
    } else if (['AC', '±', '%'].contains(button)) {
      return Colors.grey.shade700;
    } else {
      return Colors.grey.shade800;
    }
  }

  double _getButtonWidth(String button) {
    return button == '0' ? 170 : 80;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Display
            Expanded(
              flex: 1,
              child: Container(
                alignment: Alignment.bottomRight,
                padding: const EdgeInsets.all(20),
                child: SingleChildScrollView(
                  reverse: true,
                  child: Text(
                    _display,
                    style: const TextStyle(
                      fontSize: 64,
                      color: Colors.white,
                      fontWeight: FontWeight.w300,
                    ),
                    maxLines: 1,
                  ),
                ),
              ),
            ),
            // Buttons Grid
            Expanded(
              flex: 2,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: _buttons.map((row) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: row.map((button) {
                      return Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: _buildButton(button),
                      );
                    }).toList(),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(String button) {
    final isZero = button == '0';
    final width = isZero ? 170.0 : 80.0;
    
    return SizedBox(
      width: width,
      height: 80,
      child: ElevatedButton(
        onPressed: () => _tapButton(button),
        style: ElevatedButton.styleFrom(
          backgroundColor: _getButtonColor(button),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(40),
          ),
          padding: const EdgeInsets.symmetric(vertical: 20),
          elevation: 0,
        ),
        child: Text(
          button,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }
}