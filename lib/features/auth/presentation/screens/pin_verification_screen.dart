import 'package:flutter/material.dart';

// หน้าจอสำหรับใส่ PIN เพื่อยืนยันตัวตนก่อนเข้าสู่หน้าหลัก
class PinVerificationScreen extends StatefulWidget {
  final String correctPin; // PIN ที่ถูกต้องที่ถูกส่งมาจาก RoleSelectionScreen
  final Widget nextScreen; // หน้าจอถัดไปที่จะนำทางไปเมื่อ PIN ถูกต้อง

  const PinVerificationScreen({
    super.key,
    required this.correctPin,
    required this.nextScreen,
  });

  @override
  State<PinVerificationScreen> createState() => _PinVerificationScreenState();
}

class _PinVerificationScreenState extends State<PinVerificationScreen> {
  String _inputPin = '';
  String _message = 'ป้อน PIN 6 หลักเพื่อเข้าใช้งาน';
  int _attemptCount = 0; // นับจำนวนครั้งที่ลองผิด

  final Color _primaryColor = const Color(0xFF007AFF);
  final Color _darkBackgroundColor = const Color(0xFF121212);
  final Color _keypadColor = const Color(0xFF1E1E1E);

  // ฟังก์ชันสำหรับการกดตัวเลข
  void _onNumberTap(int number) {
    if (_inputPin.length < 6) {
      setState(() {
        _inputPin += number.toString();
        if (_inputPin.length == 6) {
          _verifyPin();
        }
      });
    }
  }

  // ฟังก์ชันสำหรับการลบตัวเลข
  void _onBackspace() {
    setState(() {
      if (_inputPin.isNotEmpty) {
        _inputPin = _inputPin.substring(0, _inputPin.length - 1);
      }
    });
  }

  // ฟังก์ชันตรวจสอบ PIN
  void _verifyPin() {
    if (_inputPin == widget.correctPin) {
      // PIN ถูกต้อง: นำทางไปยังหน้าจอถัดไป
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => widget.nextScreen),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('PIN ถูกต้อง! ยินดีต้อนรับ'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 1),
        ),
      );
    } else {
      // PIN ผิด
      setState(() {
        _inputPin = '';
        _attemptCount++;
        _message = 'PIN ไม่ถูกต้อง! ($_attemptCount/3)';

        if (_attemptCount >= 3) {
          // ถ้าลองผิด 3 ครั้ง ให้กลับไปหน้าเลือกบทบาท
          _message = 'ลองผิดเกินจำนวนครั้งที่กำหนด กรุณาเลือกบทบาทใหม่';
          Future.delayed(const Duration(seconds: 2), () {
            Navigator.of(context).pop(); // กลับไปหน้า RoleSelection
          });
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('PIN ไม่ถูกต้อง กรุณาลองใหม่'),
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
    return Scaffold(
      backgroundColor: _darkBackgroundColor,
      appBar: AppBar(
        backgroundColor: _darkBackgroundColor,
        elevation: 0,
        // เพิ่มปุ่มกลับเพื่อความยืดหยุ่น ถ้าผู้ใช้เปลี่ยนใจ
        iconTheme: const IconThemeData(color: Colors.white), 
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                children: [
                  Icon(Icons.lock_person, size: 60, color: _primaryColor),
                  const SizedBox(height: 20),
                  Text(
                    _message,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _attemptCount >= 3 ? Colors.red : Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 40),
                  _buildPinIndicator(6, _inputPin),
                ],
              ),
              
              // Keypad
              SizedBox(
                width: 300,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildNumberButton(1),
                        _buildNumberButton(2),
                        _buildNumberButton(3),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildNumberButton(4),
                        _buildNumberButton(5),
                        _buildNumberButton(6),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildNumberButton(7),
                        _buildNumberButton(8),
                        _buildNumberButton(9),
                      ],
                    ),
                    const SizedBox(height: 20),
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