import 'package:flutter/material.dart';
// แก้ไข Import: จาก lib/features/auth/ ไปยัง lib/features/menu/
import '../../../menu/presentation/screens/menu_screen.dart'; 
// เพิ่ม Import สำหรับหน้าลืมรหัสผ่าน
import 'forgot_password_screen.dart'; 
// *** เพิ่ม Import สำหรับหน้าเลือกบทบาท ***
import 'role_selection_screen.dart'; 
// 💡 แก้ไข: เปลี่ยนการ Import เป็น StoreVerificationScreen
import 'store_verification_screen.dart'; 

// หน้าจอสำหรับเข้าสู่ระบบ
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

// *** ✅ แก้ไข: เปลี่ยนจาก SingleTickerProviderProviderMixin เป็น SingleTickerProviderStateMixin ***
class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  
  // Tab Controller (ประกาศแบบ late และจะถูกกำหนดค่าใน initState)
  late TabController _tabController; 

  // ใช้ Controller นี้สำหรับป้อนรหัสร้าน (Store Key)
  final TextEditingController _storeKeyController = TextEditingController(); 
  
  // 1. สีหลัก (CI Color) ของแอป: สีน้ำเงินสว่าง
  final Color _primaryColor = const Color(0xFF007AFF); 

  // 2. สีพื้นหลังของ Light Mode (ปรับตามที่ร้องขอ)
  final Color _lightBackgroundColor = Colors.white; // สีขาว
  final Color _lightCardColor = const Color(0xFFF0F0F0); // สีเทาอ่อนมาก สำหรับพื้นหลัง TextField
  
  // สีตัวอักษรหลักบนพื้นหลังสว่าง
  final Color _onLightBackground = Colors.black87; 

  @override
  void initState() {
    super.initState();
    // สร้าง TabController ที่มี 2 tabs
    _tabController = TabController(length: 2, vsync: this); 
  }

  // ฟังก์ชันจำลองการเข้าสู่ระบบ/ยืนยันรหัสร้านด้วย Store Key (ชั้น 1)
  void _loginWithStoreKey() {
    final key = _storeKeyController.text;

    if (key.length >= 4) {
      // *** 💡 นำทางไปยังหน้ายืนยันร้านชั้น 2 ***
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const StoreVerificationScreen()), // 👈 เปลี่ยนปลายทาง
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('กรุณากรอกรหัสร้าน 4 ตัวขึ้นไป', style: TextStyle(color: Colors.white)), 
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  
  // ฟังก์ชันจำลองการเข้าสู่ระบบด้วย QR Code (สมมติว่า QR Code นั้นผูกกับรหัสร้านแล้ว)
  void _loginWithQRCode() {
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('สแกน QR Code ร้านสำเร็จ! กำลังนำทางสู่การยืนยัน...', style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.green,
        ),
      );
    // *** 💡 นำทางไปยังหน้ายืนยันร้านชั้น 2 ***
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const StoreVerificationScreen()), // 👈 เปลี่ยนปลายทาง
    );
  }


  // ฟังก์ชันนำทางไปยังหน้าลืมรหัสผ่าน
  void _goToForgotPassword() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const ForgotPasswordScreen()),
    );
  }

  @override
  void dispose() {
    _storeKeyController.dispose(); 
    _tabController.dispose(); 
    super.dispose();
  }

  // **********************************
  // WIDGETS สำหรับแต่ละ Tab
  // **********************************
  
  // Tab 1: การเข้าสู่ระบบด้วย Store Key
  Widget _buildStoreKeyLogin() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ฟิลด์ Store Key
        TextField(
          controller: _storeKeyController, 
          // สีตัวอักษรที่ป้อนเป็นสีดำ
          style: TextStyle(color: _onLightBackground, fontSize: 20, fontWeight: FontWeight.bold), 
          keyboardType: TextInputType.number,
          obscureText: true, // ซ่อน Pin
          decoration: InputDecoration(
            // 💡 เปลี่ยน Label
            labelText: 'Store Key (รหัสร้าน/สาขา)', 
            // สี Label และ Hint
            labelStyle: TextStyle(color: Colors.grey[600]), 
            // 💡 เปลี่ยน Hint
            hintText: 'ป้อนรหัสร้าน 4-6 หลัก', 
            hintStyle: TextStyle(color: Colors.grey[400]),
            
            // การออกแบบฟิลด์ใน Light Mode
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12), 
              borderSide: BorderSide.none, // ไม่มีเส้นขอบเริ่มต้น
            ),
            focusedBorder: OutlineInputBorder( 
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: _primaryColor, width: 2), // Focus สี CI
            ),
            filled: true,
            fillColor: _lightCardColor, // พื้นหลังฟิลด์สีเทาอ่อน
            prefixIcon: Icon(Icons.store, color: Colors.grey[600]), // 💡 เปลี่ยน Icon เป็น Icon ร้าน
          ),
        ),
        const SizedBox(height: 30),

        // ปุ่มเข้าสู่ระบบ
        ElevatedButton(
          onPressed: _loginWithStoreKey, // 💡 ใช้ฟังก์ชัน Store Key
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
            'ยืนยันรหัสร้าน', // 💡 เปลี่ยนข้อความปุ่ม
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
  
  // Tab 2: การเข้าสู่ระบบด้วย QR Code
  Widget _buildQRCodeLogin() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.qr_code_scanner, size: 120, color: _primaryColor),
          const SizedBox(height: 20),
          Text(
            'สแกน QR Code ร้าน', // 💡 ข้อความถูกปรับ
            // สีตัวอักษรเป็นสีดำ/เทาเข้ม
            style: TextStyle(fontSize: 18, color: Colors.grey[700]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          // ปุ่มจำลองการสแกน (ในแอปจริงจะเปิดกล้อง)
          ElevatedButton.icon(
            onPressed: _loginWithQRCode, // จำลองการสแกนสำเร็จ
            icon: const Icon(Icons.camera_alt),
            label: const Text('เปิดกล้องสแกน QR'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(200, 50),
              backgroundColor: Colors.green, 
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // พื้นหลังหลักสีขาว
      backgroundColor: _lightBackgroundColor,
      
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                // โลโก้
                Center(
                  child: Icon(Icons.fastfood, size: 80, color: _primaryColor),
                ),
                const SizedBox(height: 20),
                Text(
                  'FastFood',
                  textAlign: TextAlign.center,
                  // สีตัวอักษรเป็นสีดำ
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: _onLightBackground),
                ),
                const SizedBox(height: 10),
                Text(
                  'เข้าสู่ระบบร้านค้า/สาขา', // 💡 ข้อความถูกปรับ
                  textAlign: TextAlign.center,
                  // สีตัวอักษรเป็นสีเทาเข้ม
                  style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                ),
                const SizedBox(height: 40),
                
                // Tab Bar
                TabBar(
                  controller: _tabController,
                  indicatorColor: _primaryColor,
                  labelColor: _primaryColor, // สีป้ายที่เลือกเป็นสี CI
                  unselectedLabelColor: Colors.grey[500], // สีป้ายที่ไม่ได้เลือกเป็นสีเทาอ่อน
                  tabs: const [
                    Tab(icon: Icon(Icons.lock), text: 'Store Key'), // 💡 ข้อความถูกปรับ
                    Tab(icon: Icon(Icons.qr_code), text: 'QR Code'),
                  ],
                ),
                const SizedBox(height: 30),
                
                // Tab View
                SizedBox(
                  height: 300, 
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildStoreKeyLogin(), // 💡 ใช้ฟังก์ชัน Store Key
                      _buildQRCodeLogin(),
                    ],
                  ),
                ),
                
                // ลืมรหัสผ่าน (Option)
                const SizedBox(height: 15),
                TextButton(
                  onPressed: _goToForgotPassword, 
                  child: Text(
                    'รายงานปัญหา/ลืม Store Key?', // 💡 ข้อความถูกปรับ
                    style: TextStyle(color: _primaryColor), // สีลิงก์เป็นสี CI
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