// lib/features/auth/presentation/screens/login_screen.dart

import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget {
  final ValueChanged<bool> onLoginSuccess;
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  LoginScreen({super.key, required this.onLoginSuccess});

  // ฟังก์ชันจำลอง Validation และ Login
  void _performLogin(BuildContext context) {
    String username = _usernameController.text;
    String password = _passwordController.text;
    
    // 💡 Validation: ตรวจสอบว่ากรอกข้อมูลครบถ้วน
    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('กรุณากรอก Username และ Password ให้ครบถ้วน'))
      );
      return;
    }
    
    // 💡 จำลองตรรกะ Login
    if (username == 'user' && password == '123') { // ตรวจสอบแบบง่าย
      onLoginSuccess(true); 
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Username หรือ Password ไม่ถูกต้อง'), backgroundColor: Colors.red)
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('🍔 เข้าสู่ระบบสั่งอาหาร')),
      body: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.fastfood, size: 80, color: Colors.red),
            const SizedBox(height: 40),
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: 'Username',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock),
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () => _performLogin(context),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('ล็อกอิน', style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}