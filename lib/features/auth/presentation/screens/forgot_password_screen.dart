import 'package:flutter/material.dart';

// หน้าจอสำหรับลืมรหัสผ่าน
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();

  // สีหลัก (CI Color) ของแอป: สีน้ำเงินสว่าง
  final Color _primaryColor = const Color(0xFF007AFF); // iOS Blue / FastFood CI

  // สีพื้นหลังของ Dark Mode
  final Color _darkBackgroundColor = const Color(0xFF121212); // ดำเข้ม
  final Color _darkCardColor = const Color(0xFF1E1E1E); 

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
    return Scaffold(
      appBar: AppBar(
        title: const Text('ลืมรหัสผ่าน', style: TextStyle(color: Colors.white)),
        backgroundColor: _darkBackgroundColor, // ให้เป็นสีเดียวกับพื้นหลัง
        iconTheme: const IconThemeData(color: Colors.white), // สีของปุ่มย้อนกลับ
        elevation: 0,
      ),
      // กำหนดพื้นหลังหลักเป็นสีเข้ม
      backgroundColor: _darkBackgroundColor,
      
      // *** Center: เพื่อให้ SingleChildScrollView ถูกจัดให้อยู่กึ่งกลางหน้าจอในแนวตั้ง ***
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const SizedBox(height: 20), // ปรับลดขนาดลง
                
                // ไอคอนแสดงการรีเซ็ต
                Center(
                  child: Icon(Icons.lock_reset, size: 80, color: _primaryColor),
                ),
                const SizedBox(height: 20),
                
                const Text(
                  'รีเซ็ตรหัสผ่าน',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 10),
                
                Text(
                  'ป้อนอีเมลที่ลงทะเบียนไว้เพื่อรับลิงก์สำหรับรีเซ็ตรหัสผ่าน',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey[400]),
                ),
                const SizedBox(height: 40),

                // ฟิลด์อีเมล
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: const TextStyle(color: Colors.white), 
                  decoration: InputDecoration(
                    labelText: 'อีเมล',
                    labelStyle: TextStyle(color: Colors.grey[500]),
                    hintText: 'your.email@example.com',
                    hintStyle: TextStyle(color: Colors.grey[700]),
                    
                    // การออกแบบฟิลด์ใน Dark Mode
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12), 
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder( 
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: _primaryColor, width: 2),
                    ),
                    filled: true,
                    fillColor: _darkCardColor, 
                    prefixIcon: Icon(Icons.email, color: Colors.grey[500]),
                  ),
                ),
                const SizedBox(height: 30),

                // ปุ่มส่งคำขอรีเซ็ต
                ElevatedButton(
                  onPressed: _sendResetLink,
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
                    'ส่งลิงก์รีเซ็ต',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 20), // ปรับลดขนาดลง
              ],
            ),
          ),
        ),
      ),
    );
  }
}