import 'package:flutter/material.dart';

// หน้าจอสำหรับลืมรหัสผ่าน (โทนสีขาว - Light Mode)
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();

  // สีหลัก (CI Color) ของแอป: สีน้ำเงินสว่าง
  final Color _primaryColor = const Color(0xFF007AFF); // iOS Blue / FastFood CI

  // --- ปรับเปลี่ยนสีสำหรับ Light Mode ---
  // สีพื้นหลังหลัก
  final Color _lightBackgroundColor = Colors.white; // สีขาว
  // สีพื้นหลังสำหรับ Card/TextField (ควรเป็นสีขาวหรือเทาอ่อนมาก)
  final Color _lightCardColor = const Color(0xFFF0F0F0); // เทาอ่อนมาก สำหรับพื้นหลัง TextField/Card

  // ฟังก์ชันจำลองการส่งคำขอรีเซ็ตรหัสผ่าน
  void _sendResetLink() {
    final email = _emailController.text;

    if (email.isNotEmpty && email.contains('@')) {
      // แสดงข้อความแจ้งเตือนว่าส่งลิงก์ไปแล้ว
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('ส่งลิงก์รีเซ็ตรหัสผ่านไปยัง $email เรียบร้อยแล้ว', style: const TextStyle(color: Colors.white)),
          backgroundColor: _primaryColor,
          duration: const Duration(seconds: 3),
        ),
      );
      
      // กลับไปยังหน้า Login หลังจากส่งสำเร็จ
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          Navigator.of(context).pop();
        }
      });
      
    } else {
      // แสดงข้อความแจ้งเตือน
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('กรุณากรอกอีเมลที่ถูกต้อง', style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // กำหนดสีของข้อความและไอคอนบนพื้นหลังขาว
    final Color _onLightBackground = Colors.black87; 

    return Scaffold(
      appBar: AppBar(
        // สีตัวอักษรเป็นสีดำ
        title: Text('ลืมรหัสผ่าน', style: TextStyle(color: _onLightBackground)), 
        // พื้นหลัง AppBar เป็นสีขาว
        backgroundColor: _lightBackgroundColor, 
        // สีของปุ่มย้อนกลับเป็นสีดำ
        iconTheme: IconThemeData(color: _onLightBackground), 
        elevation: 0, // ลบเงาเพื่อความสะอาดตา
      ),
      // กำหนดพื้นหลังหลักเป็นสีขาว
      backgroundColor: _lightBackgroundColor,
      
      // Center: เพื่อให้ SingleChildScrollView ถูกจัดให้อยู่กึ่งกลางหน้าจอในแนวตั้ง
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const SizedBox(height: 20),
                
                // ไอคอนแสดงการรีเซ็ต
                Center(
                  child: Icon(Icons.lock_reset, size: 80, color: _primaryColor),
                ),
                const SizedBox(height: 20),
                
                Text(
                  'รีเซ็ตรหัสผ่าน',
                  textAlign: TextAlign.center,
                  // สีตัวอักษรเป็นสีดำ
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: _onLightBackground), 
                ),
                const SizedBox(height: 10),
                
                Text(
                  'ป้อนอีเมลที่ลงทะเบียนไว้เพื่อรับลิงก์สำหรับรีเซ็ตรหัสผ่าน',
                  textAlign: TextAlign.center,
                  // สีตัวอักษรเป็นสีเทาเข้ม
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]), 
                ),
                const SizedBox(height: 40),

                // ฟิลด์อีเมล
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  // สีตัวอักษรที่ป้อนเป็นสีดำ
                  style: TextStyle(color: _onLightBackground), 
                  decoration: InputDecoration(
                    labelText: 'อีเมล',
                    // สีของ Label และ Icon เป็นสีเทา
                    labelStyle: TextStyle(color: Colors.grey[500]), 
                    hintText: 'your.email@example.com',
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    
                    // การออกแบบฟิลด์ใน Light Mode (Clean UI)
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12), 
                      borderSide: BorderSide.none, // ไม่มีเส้นขอบเริ่มต้น
                    ),
                    focusedBorder: OutlineInputBorder( // เส้นขอบเมื่อ Focus เป็นสี CI
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: _primaryColor, width: 2),
                    ),
                    filled: true,
                    // พื้นหลังฟิลด์เป็นสีเทาอ่อน
                    fillColor: _lightCardColor, 
                    // สีของ Icon เป็นสีเทา
                    prefixIcon: Icon(Icons.email, color: Colors.grey[500]), 
                  ),
                ),
                const SizedBox(height: 30),

                // ปุ่มส่งคำขอรีเซ็ต
                ElevatedButton(
                  onPressed: _sendResetLink,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 56),
                    backgroundColor: _primaryColor, // สีปุ่มเป็นสี CI
                    foregroundColor: Colors.white, // สีตัวอักษรบนปุ่มเป็นสีขาว
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 5, // เพิ่มเงาเพื่อให้ดูนูนออกมาเล็กน้อย
                  ),
                  child: const Text(
                    'ส่งลิงก์รีเซ็ต',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}