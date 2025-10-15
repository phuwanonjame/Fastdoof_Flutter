import 'package:flutter/material.dart';

// หน้าจอสำหรับตั้งค่า PIN 6 หลัก
class PinSetupScreen extends StatefulWidget {
  final Function(String pin) onPinSet; // Callback function เมื่อตั้ง PIN สำเร็จ

  const PinSetupScreen({super.key, required this.onPinSet});

  @override
  State<PinSetupScreen> createState() => _PinSetupScreenState();
}

class _PinSetupScreenState extends State<PinSetupScreen> {
  String _pin = '';
  String _confirmPin = '';
  bool _isConfirming = false;
  String _message = 'ตั้งค่า PIN 6 หลัก';

  final Color _primaryColor = const Color(0xFF007AFF);
  final Color _darkBackgroundColor = const Color(0xFF121212);
  final Color _keypadColor = const Color(0xFF1E1E1E);

  // ฟังก์ชันสำหรับการกดตัวเลข
  void _onNumberTap(int number) {
    setState(() {
      if (!_isConfirming) {
        if (_pin.length < 6) {
          _pin += number.toString();
        }
        if (_pin.length == 6) {
          _isConfirming = true;
          _message = 'ยืนยัน PIN 6 หลักอีกครั้ง';
        }
      } else {
        if (_confirmPin.length < 6) {
          _confirmPin += number.toString();
        }
        if (_confirmPin.length == 6) {
          _verifyPins();
        }
      }
    });
  }

  // ฟังก์ชันสำหรับการลบตัวเลข
  void _onBackspace() {
    setState(() {
      if (_isConfirming) {
        if (_confirmPin.isNotEmpty) {
          _confirmPin = _confirmPin.substring(0, _confirmPin.length - 1);
        } else {
          _isConfirming = false;
          _message = 'ตั้งค่า PIN 6 หลัก';
        }
      } else {
        if (_pin.isNotEmpty) {
          _pin = _pin.substring(0, _pin.length - 1);
        }
      }
    });
  }

  // ฟังก์ชันตรวจสอบ PIN
  void _verifyPins() {
    if (_pin == _confirmPin) {
      // PIN ตรงกัน
      widget.onPinSet(_pin); // เรียก callback เพื่อส่ง PIN กลับไปยังหน้าหลักและนำทางต่อ
    } else {
      // PIN ไม่ตรงกัน
      setState(() {
        _message = 'PIN ไม่ตรงกัน! ตั้งค่าใหม่';
        _pin = '';
        _confirmPin = '';
        _isConfirming = false;
      });
      // แสดง SnackBar แจ้งเตือน
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('PIN ที่ตั้งไม่ตรงกัน กรุณาลองใหม่'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  // Widget แสดงจุดสำหรับ PIN
  Widget _buildPinIndicator(int length, String currentPin) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(length, (index) {
        bool filled = index < currentPin.length;
        return Container(
          width: 15,
          height: 15,
          margin: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: filled ? _primaryColor : Colors.grey.withOpacity(0.5),
            shape: BoxShape.circle,
          ),
        );
      }),
    );
  }

  // Widget ปุ่มตัวเลข
  Widget _buildNumberButton(int number) {
    return InkWell(
      onTap: () => _onNumberTap(number),
      borderRadius: BorderRadius.circular(50),
      child: Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          color: _keypadColor,
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Text(
          number.toString(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentPin = _isConfirming ? _confirmPin : _pin;
    
    return Scaffold(
      backgroundColor: _darkBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 40.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                children: [
                  Icon(Icons.lock_open, size: 60, color: _primaryColor),
                  const SizedBox(height: 20),
                  Text(
                    _message,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 40),
                  _buildPinIndicator(6, currentPin),
                ],
              ),
              
              // Keypad
              SizedBox(
                width: 300,
                child: Column(
                  children: [
                    // Row 1: 1, 2, 3
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildNumberButton(1),
                        _buildNumberButton(2),
                        _buildNumberButton(3),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Row 2: 4, 5, 6
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildNumberButton(4),
                        _buildNumberButton(5),
                        _buildNumberButton(6),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Row 3: 7, 8, 9
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildNumberButton(7),
                        _buildNumberButton(8),
                        _buildNumberButton(9),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Row 4: Empty, 0, Backspace
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const SizedBox(width: 70), // Placeholder
                        _buildNumberButton(0),
                        InkWell(
                          onTap: _onBackspace,
                          borderRadius: BorderRadius.circular(50),
                          child: Container(
                            width: 70,
                            height: 70,
                            alignment: Alignment.center,
                            child: Icon(Icons.backspace_outlined, size: 30, color: Colors.grey[500]),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}