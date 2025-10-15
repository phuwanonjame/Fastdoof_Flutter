import 'package:flutter/material.dart';

class MainPinDesignWidget extends StatelessWidget {
  const MainPinDesignWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.blueAccent, width: 2),
        ),
        child: const Column(
          children: [
            Icon(Icons.push_pin, size: 40, color: Colors.blueAccent),
            SizedBox(height: 8),
            Text(
              'Pin Design Template (Main)',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.blueAccent,
              ),
            ),
            Text(
              'นี่คือส่วนประกอบ UI/UX พื้นฐานสำหรับ Pin',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}