import 'package:flutter/material.dart';
// Import ปลายทางสุดท้าย (หน้าเลือกบทบาท)
import 'role_selection_screen.dart';

class StoreVerificationScreen extends StatefulWidget { 
  const StoreVerificationScreen({super.key});

  @override
  State<StoreVerificationScreen> createState() => _StoreVerificationScreenState();
}

class _StoreVerificationScreenState extends State<StoreVerificationScreen> {
  // ใช้ Controller สำหรับรหัสยืนยันชั้นที่ 2
  final TextEditingController _verificationKeyController = TextEditingController(); 
  
  final Color _primaryColor = const Color(0xFF007AFF);
  final Color _lightCardColor = const Color(0xFFF0F0F0);
  final Color _onLightBackground = Colors.black87;

  // ฟังก์ชันจำลองการตรวจสอบรหัสยืนยันชั้นที่ 2 (แบบป้อนรหัส)
  void _verifyByPin() {
    final key = _verificationKeyController.text;

    // จำลอง: อนุญาตให้ผ่านหากมีรหัส 6 หลักและตรงตามเงื่อนไข (ในแอปจริงตรวจสอบกับ API/DB)
    if (key.length == 6 && key == '789012') { // สมมติรหัสยืนยันชั้น 2 คือ '789012'
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ยืนยันร้านชั้นที่ 2 สำเร็จ! กำลังนำทาง...', style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.green,
        ),
      );
      // *** นำทางไปยังหน้าเลือกบทบาท (ปลายทางสุดท้าย) ***
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const RoleSelectionScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('รหัสยืนยันไม่ถูกต้อง! กรุณาลองใหม่', style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.red,
        ),
      );
    }
  }


  @override
  void dispose() {
    _verificationKeyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ยืนยันร้านชั้น 2', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // Icon และข้อความต้อนรับ
              Icon(Icons.verified_user, size: 80, color: _primaryColor),
              const SizedBox(height: 20),
              Text(
                'การยืนยันร้านค้าชั้นที่ 2',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: _onLightBackground),
              ),
              const SizedBox(height: 10),
              Text(
                'กรุณาป้อนรหัสยืนยันร้านชั้นที่ 2 ',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey[700]),
              ),
              const SizedBox(height: 40),

              // ฟิลด์ รหัสยืนยัน (PIN)
              TextField(
                controller: _verificationKeyController,
                style: TextStyle(color: _onLightBackground, fontSize: 20, fontWeight: FontWeight.bold),
                keyboardType: TextInputType.number,
                obscureText: true,
                maxLength: 6, // จำกัดความยาว
                decoration: InputDecoration(
                  labelText: 'รหัสยืนยันร้าน (6 หลัก)',
                  labelStyle: TextStyle(color: Colors.grey[600]),
                  hintText: 'ป้อนรหัส PIN ยืนยันร้าน',
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: _primaryColor, width: 2),
                  ),
                  filled: true,
                  fillColor: _lightCardColor,
                  prefixIcon: Icon(Icons.pin, color: Colors.grey[600]),
                  counterText: "", // ซ่อนตัวนับความยาว
                ),
              ),
              const SizedBox(height: 30),

              // ปุ่มยืนยันด้วย PIN
              ElevatedButton(
                onPressed: _verifyByPin,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 56),
                  backgroundColor: _primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 5,
                ),
                child: const Text(
                  'ยืนยันด้วยรหัส PIN',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 20),

              // ปุ่มยืนยันด้วย QR Code
            

            ],
          ),
        ),
      ),
    );
  }
}