import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';

class NumericCalculatorKeyboard extends StatefulWidget {
  final TextEditingController controller;
  final VoidCallback onOk;

  const NumericCalculatorKeyboard({
    Key? key,
    required this.controller,
    required this.onOk,
  }) : super(key: key);

  @override
  State<NumericCalculatorKeyboard> createState() => _NumericCalculatorKeyboardState();
}

class _NumericCalculatorKeyboardState extends State<NumericCalculatorKeyboard> {
  String _expression = '';

  @override
  void initState() {
    super.initState();
    _expression = widget.controller.text;
  }

  void _onPressed(String text) {
    setState(() {
      if (text == 'C') {
        _expression = '';
      } else if (text == '⌫') {
        if (_expression.isNotEmpty) {
          _expression = _expression.substring(0, _expression.length - 1);
        }
      } else if (text == 'OK') {
        _calculate();
        widget.onOk();
        return;
      } else if (text == '=') {
        _calculate();
      } else {
        _expression += text;
      }
      widget.controller.text = _expression;
    });
  }

  void _calculate() {
    if (_expression.isEmpty) return;
    try {
      // Thay thế các ký tự hiển thị sang ký tự toán học
      String finalExpression = _expression.replaceAll('x', '*').replaceAll('÷', '/');
      
      Parser p = Parser();
      Expression exp = p.parse(finalExpression);
      ContextModel cm = ContextModel();
      double eval = exp.evaluate(EvaluationType.REAL, cm);
      
      // Chuyển kết quả thành chuỗi, bỏ phần thập phân nếu là số nguyên
      if (eval == eval.toInt()) {
        _expression = eval.toInt().toString();
      } else {
        _expression = eval.toStringAsFixed(0); // Thường tiền tệ không để lẻ quá nhiều hoặc tùy định dạng
      }
      widget.controller.text = _expression;
    } catch (e) {
      // Nếu lỗi (vô lý), không làm gì hoặc báo lỗi nhẹ
    }
  }

  Widget _buildButton(String text, {Color? color, Color? textColor, int flex = 1}) {
    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Material(
          color: color ?? Colors.grey.shade200,
          borderRadius: BorderRadius.circular(8),
          child: InkWell(
            onTap: () => _onPressed(text),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              height: 60,
              alignment: Alignment.center,
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: textColor ?? Colors.black87,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              _buildButton('7'),
              _buildButton('8'),
              _buildButton('9'),
              _buildButton('÷', color: Colors.orange.shade100, textColor: Colors.orange.shade900),
            ],
          ),
          Row(
            children: [
              _buildButton('4'),
              _buildButton('5'),
              _buildButton('6'),
              _buildButton('x', color: Colors.orange.shade100, textColor: Colors.orange.shade900),
            ],
          ),
          Row(
            children: [
              _buildButton('1'),
              _buildButton('2'),
              _buildButton('3'),
              _buildButton('-', color: Colors.orange.shade100, textColor: Colors.orange.shade900),
            ],
          ),
          Row(
            children: [
              _buildButton('0'),
              _buildButton('000'),
              _buildButton('.'),
              _buildButton('+', color: Colors.orange.shade100, textColor: Colors.orange.shade900),
            ],
          ),
          Row(
            children: [
              _buildButton('C', color: Colors.red.shade100, textColor: Colors.red.shade900),
              _buildButton('⌫', color: Colors.blue.shade100, textColor: Colors.blue.shade900),
              _buildButton('OK', color: Colors.blue.shade600, textColor: Colors.white, flex: 2),
            ],
          ),
        ],
      ),
    );
  }
}
