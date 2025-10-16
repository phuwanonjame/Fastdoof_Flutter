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

// *** เพิ่ม with SingleTickerProviderStateMixin เพื่อรองรับ TabController ***
class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  
  // Tab Controller (ประกาศแบบ late และจะถูกกำหนดค่าใน initState)
  late TabController _tabController; 

  final TextEditingController _securityKeyController = TextEditingController();
  
  // 1. สีหลัก (CI Color) ของแอป: สีน้ำเงินสว่าง
  final Color _primaryColor = const Color(0xFF007AFF); 

  // 2. สีพื้นหลังของ Dark Mode
  final Color _darkBackgroundColor = const Color(0xFF121212); 
  final Color _darkCardColor = const Color(0xFF1E1E1E); 

  @override
  void initState() {
    super.initState();
    // สร้าง TabController ที่มี 2 tabs
    _tabController = TabController(length: 2, vsync: this); 
  }

  // ฟังก์ชันจำลองการเข้าสู่ระบบด้วย Security Key
  void _loginWithSecurityKey() {
    final key = _securityKeyController.text;

    // จำลอง: อนุญาตให้เข้าสู่ระบบหากมี Pin 4 หลักขึ้นไป (ในแอปจริงต้องตรวจสอบกับ API/DB)
    if (key.length >= 4) {
      // *** นำทางไปยังหน้าเลือกบทบาท ***
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const RoleSelectionScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('กรุณากรอก Security Key 4 ตัวขึ้นไป', style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  
  // ฟังก์ชันจำลองการเข้าสู่ระบบด้วย QR Code (สมมติว่า QR Scanner ทำงานเสร็จแล้ว)
  void _loginWithQRCode() {
    // ในแอปจริง: โค้ดส่วนนี้จะถูกเรียกหลังจากการสแกนสำเร็จ
    // ตัวอย่างการจำลองการสแกนสำเร็จ:
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('สแกน QR Code สำเร็จ! กำลังนำทาง...', style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.green,
        ),
      );
    // *** นำทางไปยังหน้าเลือกบทบาท ***
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const RoleSelectionScreen()),
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
    _securityKeyController.dispose();
    _tabController.dispose(); // *** ต้อง dispose TabController ด้วย ***
    super.dispose();
  }

  // **********************************
  // WIDGETS สำหรับแต่ละ Tab
  // **********************************
  
  // Tab 1: การเข้าสู่ระบบด้วย Security Key
  Widget _buildSecurityKeyLogin() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ฟิลด์ Security Key
        TextField(
          controller: _securityKeyController,
          style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold), 
          keyboardType: TextInputType.number,
          obscureText: true, // ซ่อน Pin
          decoration: InputDecoration(
            labelText: 'Security Key (รหัสพนักงาน/PIN)',
            labelStyle: TextStyle(color: Colors.grey[500]),
            hintText: 'ป้อนรหัส 4-6 หลัก',
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
            prefixIcon: Icon(Icons.vpn_key, color: Colors.grey[500]),
          ),
        ),
        const SizedBox(height: 30),

        // ปุ่มเข้าสู่ระบบ
        ElevatedButton(
          onPressed: _loginWithSecurityKey,
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
            'เข้าสู่ระบบด้วยรหัส',
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
            'สแกน QR Code พนักงาน',
            style: TextStyle(fontSize: 18, color: Colors.grey[400]),
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
      backgroundColor: _darkBackgroundColor,
      
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
                  style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: Colors.white),
                ),
                const SizedBox(height: 10),
                Text(
                  'เข้าสู่ระบบพนักงาน',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey[400]),
                ),
                const SizedBox(height: 40),
                
                // Tab Bar
                TabBar(
                  controller: _tabController,
                  indicatorColor: _primaryColor,
                  labelColor: _primaryColor,
                  unselectedLabelColor: Colors.grey,
                  tabs: const [
                    Tab(icon: Icon(Icons.lock), text: 'Security Key'),
                    Tab(icon: Icon(Icons.qr_code), text: 'QR Code'),
                  ],
                ),
                const SizedBox(height: 30),
                
                // Tab View
                SizedBox(
                  height: 300, // กำหนดความสูงเพื่อให้ TabBarView ไม่เกิด Overflow
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildSecurityKeyLogin(),
                      _buildQRCodeLogin(),
                    ],
                  ),
                ),
                
                // ลืมรหัสผ่าน (Option)
                const SizedBox(height: 15),
                TextButton(
                  onPressed: _goToForgotPassword, 
                  child: Text(
                    'รายงานปัญหา/ลืม Security Key?',
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