// lib/features/auth/presentation/screens/order_history_screen.dart

import 'package:flutter/material.dart';
import '../../../../models/order_models.dart'; 

class OrderHistoryScreen extends StatelessWidget {
  final List<OrderHistory> history;

  const OrderHistoryScreen({super.key, required this.history});
  
  // *** ฟังก์ชันจำลองการพิมพ์สลิปย้อนหลัง ***
  void _mockPrintReceipt(BuildContext context, OrderHistory record) {
     final paymentMethod = record.paymentType == PaymentType.cash ? "เงินสด" : "สแกน QR";
     
     // แสดง Modal จำลอง
     showDialog(
       context: context,
       builder: (ctx) {
         return AlertDialog(
           title: Text('✅ พิมพ์สลิปบิลย้อนหลัง: ${record.tableName}', style: const TextStyle(color: Colors.indigo)),
           content: Column(
             mainAxisSize: MainAxisSize.min,
             crossAxisAlignment: CrossAxisAlignment.start,
             children: [
               const Text('จำลองการส่งข้อมูลใบเสร็จไปเครื่องพิมพ์:', style: TextStyle(fontWeight: FontWeight.bold)),
               const Divider(),
               Text('Order ID: ${record.orderId}'),
               Text('เวลาจ่าย: ${record.paymentTime.toLocal().toString().split('.')[0]}'),
               Text('ยอดรวมสุทธิ: ${record.grandTotal.toStringAsFixed(2)} บาท'),
               Text('วิธีชำระ: $paymentMethod'),
               const SizedBox(height: 10),
               const Text('--- กำลังเชื่อมต่อเครื่องพิมพ์... ---'),
             ],
           ),
           actions: [
             TextButton(
               onPressed: () => Navigator.of(ctx).pop(),
               child: const Text('ตกลง'),
             ),
           ],
         );
       },
     );
  }
  
  // ... (ส่วน _buildTotalRow เหมือนเดิม) ...
  Widget _buildTotalRow(String label, double amount, {bool isGrandTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isGrandTotal ? 16 : 14,
              fontWeight: isGrandTotal ? FontWeight.bold : FontWeight.normal,
              color: isGrandTotal ? Colors.black : Colors.grey[700],
            ),
          ),
          Text(
            '${amount.toStringAsFixed(2)} บาท',
            style: TextStyle(
              fontSize: isGrandTotal ? 16 : 14,
              fontWeight: isGrandTotal ? FontWeight.bold : FontWeight.w500,
              color: isGrandTotal ? Colors.black : Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ประวัติการชำระเงิน (ปิดบิลแล้ว)', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: history.isEmpty
          ? const Center(
              child: Text(
                'ยังไม่มีประวัติการชำระเงินที่ปิดบิลแล้ว',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: history.length,
              itemBuilder: (context, index) {
                final record = history[index];
                // คำนวณ VAT และ Subtotal เพื่อแสดงในรายละเอียด
                final subtotal = record.items.fold(0.0, (sum, item) => sum + (item.price * item.quantity));
                final vat = record.grandTotal - subtotal;
                
                return Card(
                  margin: const EdgeInsets.only(bottom: 15),
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ExpansionTile(
                    tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    title: Text('บิล: ${record.tableName} | ${record.paymentTime.toLocal().toString().split(' ')[0]}', 
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('ยอดรวม: ${record.grandTotal.toStringAsFixed(2)} บาท', 
                          style: const TextStyle(color: Colors.indigo, fontWeight: FontWeight.bold)),
                        Text('ช่องทาง: ${record.paymentType == PaymentType.cash ? 'เงินสด 💵' : 'สแกน QR 📲'}', 
                          style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                      ],
                    ),
                    children: [
                      const Divider(height: 1, indent: 16, endIndent: 16),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('รายละเอียดรายการอาหาร:', style: TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 5),
                            ...record.items.map((item) => Padding(
                              padding: const EdgeInsets.only(left: 8.0, bottom: 4),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(child: Text('${item.name} x ${item.quantity}', style: const TextStyle(fontSize: 14))),
                                  Text('${(item.price * item.quantity).toStringAsFixed(2)} บาท', style: const TextStyle(fontSize: 14)),
                                ],
                              ),
                            )).toList(),
                            const Divider(),
                            _buildTotalRow('ยอดรวมก่อน VAT', subtotal),
                            _buildTotalRow('VAT (7%)', vat),
                            _buildTotalRow('ยอดรวมสุทธิ', record.grandTotal, isGrandTotal: true),
                            const SizedBox(height: 10),
                            // *** ปุ่มใหม่: พิมพ์สลิปย้อนหลัง ***
                            ElevatedButton.icon(
                              onPressed: () => _mockPrintReceipt(context, record),
                              icon: const Icon(Icons.print_rounded, size: 20),
                              label: const Text('พิมพ์สลิปย้อนหลัง'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.teal,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text('QR Code: ${record.qrCode}', style: const TextStyle(fontSize: 12, color: Colors.blueGrey)),
                            Text('Order ID: ${record.orderId}', style: const TextStyle(fontSize: 12, color: Colors.blueGrey)),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}