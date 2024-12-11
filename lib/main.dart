// IM/2021/057 kauthaman thayaparan

import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';
import 'dart:math';

void main() {
  runApp(const MyCalculator());
}

class MyCalculator extends StatelessWidget {
  const MyCalculator({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: CalculatorScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  _CalculatorScreenState createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String displayText = '0';
  String expression = '';
  bool isDarkMode = true;
  List<String> history = []; 
void _onButtonPressed(String buttonText) {
  setState(() {
    if (buttonText == "AC") {
      displayText = '0'; 
      expression = ''; 
    } else if (buttonText == "+/-") {
      if (displayText.startsWith('-')) {
        displayText = displayText.substring(1); 
      } else {
        displayText = '-$displayText'; 
      }
      expression = displayText;
    } else if (buttonText == "=") {
      if (expression.isEmpty || expression == '0') {
        return; 
      }

      
      if (expression.contains('÷0')) {
        _showErrorDialog("Cannot divide by zero!");
        return; 
      }

      try {
        double result = _evaluateExpression(expression);

        
        if (result.isInfinite || result.isNaN) {
          _showErrorDialog("Invalid Operation");
          return; 
        } else {
          displayText = _formatResult(result);
          history.insert(0, "$expression = $displayText"); 
          expression = displayText; 
        }
      } catch (e) {
        _showErrorDialog("Invalid Operation");
        return; 
      }
    } else if (buttonText == "√") {
      try {
        double number = double.tryParse(displayText) ?? 0;
        if (number < 0) {
          _showErrorDialog("Invalid Operation: Square root of negative number!");
          return; 
        }

        double result = sqrt(number);
        displayText = _formatResult(result);
        expression = displayText; 
      } catch (e) {
        _showErrorDialog("Error evaluating square root.");
        return;
      }
    } else if (buttonText == "%") {
      try {
        double number = double.tryParse(displayText) ?? 0;
        double result = number / 100;
        displayText = _formatResult(result);
        expression = displayText; 
      } catch (e) {
        _showErrorDialog("Error evaluating percentage.");
        return; 
      }
    } else {
      
      if ((expression.isEmpty || expression == '0') &&
          (buttonText == '+' || buttonText == '-' || buttonText == '×' || buttonText == '÷')) {
        return; 
      }

      
      if (displayText == "0" && buttonText != ".") {
        displayText = buttonText == "÷" ? "0÷" : buttonText; 
      } else {
        displayText += buttonText; 
      }

      expression += buttonText; 
    }
  });
}


  double _evaluateExpression(String expr) {
  try {
    expr = expr
        .replaceAll('×', '*')
        .replaceAll('÷', '/')
        .replaceAll('√', 'sqrt'); 
    Parser parser = Parser();
    Expression parsedExpression = parser.parse(expr);

    ContextModel context = ContextModel();
    double result = parsedExpression.evaluate(EvaluationType.REAL, context);

    if (result.isInfinite || result.isNaN) {
      _showErrorDialog("Cannot divide by zero!");
      return 0;
    }

    return result;
  } catch (e) {
    _showErrorDialog("Error: Invalid mathematical expression.");
    return 0;
  }
}



  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Error"),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  void _toggleDarkMode() {
    setState(() {
      isDarkMode = !isDarkMode;
    });
  }

  String _formatResult(double result) {
  
  if (result % 1 == 0) {
    return result.toInt().toString(); 
  } else {
    
    return result.toStringAsFixed(10).replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
  }
}

  

  void _onBackspacePressed() {
    setState(() {
      if (displayText.length > 1) {
        displayText = displayText.substring(0, displayText.length - 1);
        expression = expression.substring(0, expression.length - 1);
      } else {
        displayText = '0'; 
        expression = '';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Expanded(
              child: Container(
                alignment: Alignment.bottomRight,
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          icon: Icon(Icons.access_time,
                              color: isDarkMode ? Colors.white : Colors.black),
                          onPressed: () {
                            
                            Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => HistoryScreen(
      history,
      isDarkMode: isDarkMode,
      onRecalculate: (calculation) {
        setState(() {
          expression = calculation.split('=')[0].trim();
          displayText = calculation.split('=')[1].trim();
        });
        Navigator.pop(context);
      },
      onDelete: (index) {
        setState(() {
          history.removeAt(index);
        });
      },
      onClearAll: () {
        setState(() {
          history.clear();
        });
      },
    ),
  ),
);}

                       ),
                        IconButton(
                          icon: Icon(
                            isDarkMode ? Icons.wb_sunny : Icons.nights_stay,
                            color: isDarkMode ? Colors.white : Colors.black,
                          ),
                          onPressed: _toggleDarkMode,
                        ),
                      ],
                    ),
                    Text(
                      displayText,
                      style: TextStyle(
                        color: isDarkMode ? Colors.white : Colors.black,
                        fontSize: 48,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Material(
                    color: isDarkMode ? Colors.black : Colors.white,
                    shape: const CircleBorder(),
                    child: InkWell(
                      onTap: _onBackspacePressed,
                      borderRadius: BorderRadius.circular(50),
                      child: Container(
                        width: 50,
                        height: 50,
                        alignment: Alignment.center,
                        child: Icon(
                          Icons.backspace,
                          color: isDarkMode ? Colors.white : Colors.black,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            _buildButtonRow(['AC', '√', '%', '÷']),
            _buildButtonRow(['7', '8', '9', '×']),
            _buildButtonRow(['4', '5', '6', '-']),
            _buildButtonRow(['1', '2', '3', '+']),
            _buildButtonRow(['+/-', '0', '.', '=']),
          ],
        ),
      ),
    );
  }

  Widget _buildButtonRow(List<String> buttons) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: buttons.map((buttonText) {
        bool isOperator = ['÷', '×', '-', '+', '%', '√'].contains(buttonText);
        bool isEquals = buttonText == '=';
        bool isClear = buttonText == 'AC';

        return Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Material(
              color: isEquals
                  ? Colors.green
                  : (isClear
                      ? Colors.red
                      : (isOperator
                          ? Colors.grey[300]
                          : (isDarkMode ? Colors.grey[800] : Colors.grey[300]))),
              shape: const CircleBorder(),
              child: InkWell(
                onTap: () => _onButtonPressed(buttonText),
                borderRadius: BorderRadius.circular(50),
                child: Container(
                  width: 70,
                  height: 70,
                  alignment: Alignment.center,
                  child: Text(
                    buttonText,
                    style: TextStyle(
                      fontSize: 30,
                      color: isOperator
                          ? Colors.green
                          : (isDarkMode ? Colors.white : Colors.black),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}



class HistoryScreen extends StatelessWidget {
  final List<String> history;
  final bool isDarkMode;
  final Function(String) onRecalculate;
  final Function(int) onDelete;
  final VoidCallback onClearAll; 

  const HistoryScreen(
    this.history, {
    super.key,
    required this.isDarkMode,
    required this.onRecalculate,
    required this.onDelete,
    required this.onClearAll,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
      appBar: AppBar(
        backgroundColor: isDarkMode ? Colors.black : Colors.white,
        iconTheme: IconThemeData(
          color: isDarkMode ? Colors.white : Colors.black,
        ),
        title: Text(
          "History",
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ),
      ),
      body: Column(
        children: [
          
          Expanded(
            child: history.isEmpty
                ? Center(
                    child: Text(
                      "No history available.",
                      style: TextStyle(
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: history.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(
                          history[index],
                          style: TextStyle(
                            color: isDarkMode ? Colors.white : Colors.black,
                          ),
                        ),
                        trailing: IconButton(
                          icon: Icon(
                            Icons.delete,
                            color: isDarkMode ? Colors.white : Colors.black,
                          ),
                          onPressed: () => onDelete(index),
                        ),
                        onTap: () => onRecalculate(history[index]),
                      );
                    },
                  ),
          ),

          
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: isDarkMode ? Colors.green : Colors.blue,
              ),
              onPressed: () {
                onClearAll(); 
              },
              child: Text(
                "Clear All",
                style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
