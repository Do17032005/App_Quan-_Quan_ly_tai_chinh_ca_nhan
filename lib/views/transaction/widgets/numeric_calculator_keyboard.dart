import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';

class NumericCalculatorKeyboard extends StatefulWidget {
  final TextEditingController controller;
  final VoidCallback onOk;

  const NumericCalculatorKeyboard({
    super.key,
    required this.controller,
    required this.onOk,
  });

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
    if (_expression.isEmpty) {
      _expression = '0';
      widget.controller.text = _expression;
      return;
    }
    try {
      // Thay thế các ký tự hiển thị sang ký tự toán học
      String finalExpression = _expression.replaceAll('x', '*').replaceAll('÷', '/');
      
      GrammarParser p = GrammarParser();
      Expression exp = p.parse(finalExpression);
      ContextModel cm = ContextModel();
      double eval = exp.evaluate(EvaluationType.REAL, cm);
      
      // Chuyển kết quả thành chuỗi, bỏ phần thập phân nếu là số nguyên
      if (eval.isInfinite || eval.isNaN) {
        _expression = '0';
      } else if (eval == eval.toInt()) {
        _expression = eval.toInt().abs().toString();
      } else {
        _expression = eval.abs().toStringAsFixed(0);
      }
      widget.controller.text = _expression;
    } catch (e) {
      // Nếu lỗi (vô lý), reset về 0 hoặc giữ nguyên tùy logic
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
      padding: const EdgeInsets.only(top: 8, left: 8, right: 8, bottom: 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Vùng hiển thị số đang nhập hoặc kết quả phép tính
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: Colors.blue.shade50.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.shade100),
            ),
            child: Text(
              _expression.isEmpty ? '0' : _expression,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade800,
              ),
            ),
          ),
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
