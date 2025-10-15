// lib/features/pinning/presentation/screens/pinning_main_screen.dart

import 'package:flutter/material.dart';
import '../widgets/main_pin_design_widget.dart'; 

class PinningMainScreen extends StatefulWidget {
  // รับ callback เพื่อจัดการ Logout
  final VoidCallback onLogout;
  const PinningMainScreen({super.key, required this.onLogout});

  @override
  State<PinningMainScreen> createState() => _PinningMainScreenState();
}

class _PinningMainScreenState extends State<PinningMainScreen> {
  // สถานะปัจจุบันของ Pinning Process
  // 0: Design Pin, 1: Choose Person, 2: Pin Person, 3: Apply to Role Page
  int currentStep = 0;
  String? selectedUser;

  void nextStep() {
    setState(() {
      if (currentStep < 3) {
        currentStep++;
      }
    });
  }

  String get currentStatusText {
    switch (currentStep) {
      case 0: return '1. Design Pin หลัก (Main Pin)';
      case 1: return '2. เลือกคน (Choose Person)';
      case 2: return '3. Pin คน (Pin Person)';
      case 3: return '4. หน้านั้นๆ ตาม Role (That Page according to Role) - เสร็จสมบูรณ์';
      default: return 'Process Ready';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pinning Process'),
        backgroundColor: currentStep == 3 ? Colors.green : Colors.blue,
        actions: [
          // 💡 ปุ่ม Logout ที่เรียก callback กลับไป main.dart
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: widget.onLogout, // เรียกใช้ callback
            tooltip: 'ออกจากระบบ',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              'สถานะปัจจุบัน: $currentStatusText',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: currentStep == 3 ? Colors.green.shade700 : Colors.blue.shade700,
              ),
            ),
            const Divider(height: 30),

            // ขั้นตอนที่ 1: Design Pin หลัก
            const Text('✔ ขั้นตอนที่ 1: Main Pin Design', style: TextStyle(fontStyle: FontStyle.italic)),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 10.0),
              child: MainPinDesignWidget(),
            ),
            
            const SizedBox(height: 30),
            
            // ขั้นตอนที่ 2: เลือกคน
            _buildActionButton(
              title: '2. เลือกคน (Choose Person)',
              stepIndex: 1,
              onPressed: () {
                setState(() { selectedUser = 'User A (Role: Admin)'; });
                nextStep();
              },
            ),
            
            if (currentStep >= 1)
              Padding(
                padding: const EdgeInsets.only(top: 8.0, bottom: 15),
                child: Text('✅ ได้ทำการเลือก: ${selectedUser ?? 'User A'}', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.w500)),
              ),

            // ขั้นตอนที่ 3: Pin คน
            _buildActionButton(
              title: '3. Pin คน (Execute Pinning)',
              stepIndex: 2,
              onPressed: () {
                nextStep();
              },
            ),

            const SizedBox(height: 15),

            // ขั้นตอนที่ 4: ไปยังหน้าตาม Role
            _buildActionButton(
              title: '4. ไปยังหน้าตาม Role (Apply Role Access)',
              stepIndex: 3,
              onPressed: () {
                nextStep(); 
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('✅ Pinning Process เสร็จสมบูรณ์! นำทางตาม Role...'))
                );
              },
              color: Colors.green,
            ),
          ],
        ),
      ),
    );
  }
  
  // Helper function สำหรับสร้างปุ่มที่เปิด/ปิดตามสถานะ
  Widget _buildActionButton({
    required String title,
    required int stepIndex,
    required VoidCallback onPressed,
    Color color = Colors.blue,
  }) {
    // ปุ่มจะทำงานได้เมื่อขั้นตอนปัจจุบัน "ถึง" หรือ "ผ่าน" ขั้นตอนก่อนหน้า
    bool isEnabled = currentStep == stepIndex - 1 || currentStep == stepIndex;
    
    return ElevatedButton(
      onPressed: isEnabled && currentStep < stepIndex ? onPressed : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withOpacity(isEnabled && currentStep < stepIndex ? 1.0 : 0.5),
        padding: const EdgeInsets.symmetric(vertical: 15),
        foregroundColor: Colors.white,
      ),
      child: Text(
        title,
        style: const TextStyle(fontSize: 16),
      ),
    );
  }
}