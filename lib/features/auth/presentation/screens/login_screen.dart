import 'package:flutter/material.dart';
// แก้ไข Import: จาก lib/features/auth/ ไปยัง lib/features/menu/
import '../../../menu/presentation/screens/menu_screen.dart'; 
// เพิ่ม Import สำหรับหน้าลืมรหัสผ่าน
import 'forgot_password_screen.dart'; 
// *** เพิ่ม Import สำหรับหน้าเลือกบทบาท ***
import 'role_selection_screen.dart'; 

// หน้าจอสำหรับเข้าสู่ระบบ
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  // 1. สีหลัก (CI Color) ของแอป: สีน้ำเงินสว่าง
  final Color _primaryColor = const Color(0xFF007AFF); // iOS Blue / FastFood CI

  // 2. สีพื้นหลังของ Dark Mode
  final Color _darkBackgroundColor = const Color(0xFF121212); // ดำเข้ม
  final Color _darkCardColor = const Color(0xFF1E1E1E); 

  // ฟังก์ชันจำลองการเข้าสู่ระบบ
  void _login() {
    final username = _usernameController.text;
    final password = _passwordController.text;

    if (username.isNotEmpty && password.isNotEmpty) {
      // *** เปลี่ยน: นำทางไปยังหน้าเลือกบทบาทแทน MenuScreen ***
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const RoleSelectionScreen()),
      );
    } else {
      // แสดงข้อความแจ้งเตือนโดยใช้ SnackBar
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('กรุณากรอกชื่อผู้ใช้และรหัสผ่าน', style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ฟังก์ชันนำทางไปยังหน้าลืมรหัสผ่าน
  void _goToForgotPassword() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const ForgotPasswordScreen()),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _darkBackgroundColor,
      
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const SizedBox(height: 20),

                // โลโก้/ไอคอน FastFood
                Center(
                  child: Icon(Icons.fastfood, size: 80, color: _primaryColor),
                ),
                const SizedBox(height: 20),
                
                // ชื่อแอปฯ
                const Text(
                  'FastFood',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: Colors.white),
                ),
                const SizedBox(height: 10),
                Text(
                  'เข้าสู้ระบบเพื่อจัดการร้านของคุณ',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey[400]),
                ),
                const SizedBox(height: 40),

                // ฟิลด์ชื่อผู้ใช้
                TextField(
                  controller: _usernameController,
                  style: const TextStyle(color: Colors.white), 
                  decoration: InputDecoration(
                    labelText: 'ชื่อผู้ใช้',
                    labelStyle: TextStyle(color: Colors.grey[500]),
                    hintText: 'ป้อนชื่อผู้ใช้หรืออีเมล',
                    hintStyle: TextStyle(color: Colors.grey[700]),
                    
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
                    prefixIcon: Icon(Icons.person, color: Colors.grey[500]),
                  ),
                ),
                const SizedBox(height: 20),

                // ฟิลด์รหัสผ่าน
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  style: const TextStyle(color: Colors.white), 
                  decoration: InputDecoration(
                    labelText: 'รหัสผ่าน',
                    labelStyle: TextStyle(color: Colors.grey[500]),
                    hintText: 'ป้อนรหัสผ่าน',
                    hintStyle: TextStyle(color: Colors.grey[700]),
                    
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
                    prefixIcon: Icon(Icons.lock, color: Colors.grey[500]),
                  ),
                ),
                const SizedBox(height: 30),

                // ปุ่มเข้าสู่ระบบ
                ElevatedButton(
                  onPressed: _login,
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
                    'เข้าสู่ระบบ',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 15),
                
                // ลืมรหัสผ่าน (Option)
                TextButton(
                  onPressed: _goToForgotPassword, 
                  child: Text(
                    'ลืมรหัสผ่าน?',
                    style: TextStyle(color: _primaryColor), 
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