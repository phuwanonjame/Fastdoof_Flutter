import 'package:flutter/material.dart';
// 1. IMPORT หน้าจอจัดการออร์เดอร์และ Models
import 'order_detail_screen.dart'; 

// โมเดลสำหรับสถานะโต๊ะ (ใช้ TableStatus เดิม แต่เพิ่ม Order เข้าไป)
class TableStatus {
  final int id;
  final String name;
  final bool isOccupied;
  final int peopleCount;
  final String qrCode; 
  final TableOrder? order; // <<-- เพิ่ม Order object
  final Color statusColor;

  TableStatus({
    required this.id,
    required this.name,
    required this.isOccupied,
    this.peopleCount = 0,
    required this.qrCode,
    this.order, // <<-- เพิ่ม order ใน constructor
    required this.statusColor,
  });
  
  // ฟังก์ชันช่วยในการ Copy (เพื่อให้ง่ายต่อการอัปเดตสถานะใน setState)
  TableStatus copyWith({
    bool? isOccupied,
    int? peopleCount,
    TableOrder? order,
    Color? statusColor,
  }) {
    return TableStatus(
      id: id,
      name: name,
      qrCode: qrCode,
      isOccupied: isOccupied ?? this.isOccupied,
      peopleCount: peopleCount ?? this.peopleCount,
      order: order, // ไม่ใส่ ?? this.order เนื่องจากต้องการล้าง order ได้
      statusColor: statusColor ?? this.statusColor,
    );
  }
}

// *** สมมติว่ามี TableOrder และ OrderItem ใน order_detail_screen.dart
// (จำเป็นต้องเพิ่มเพื่อให้โค้ดนี้รันได้)
class OrderItem {
  final String name;
  final double price;
  int quantity;

  OrderItem({required this.name, required this.price, this.quantity = 1});
}

class TableOrder {
  final int tableId;
  List<OrderItem> items;
  bool isComplete;

  TableOrder({required this.tableId, List<OrderItem>? items, this.isComplete = false})
      : items = items ?? [];
}


// หน้าจอหลักสำหรับบริกร (Waiter/Server)
class WaiterScreen extends StatefulWidget {
  const WaiterScreen({super.key});

  @override
  State<WaiterScreen> createState() => _WaiterScreenState();
}

class _WaiterScreenState extends State<WaiterScreen> {
  // *** ปรับสีสำหรับ Light Mode (ใช้ Material 3 Palette) ***
  final Color _primaryColor = const Color(0xFF007AFF); // สีน้ำเงินหลัก (เดิม)
  final Color _lightBackgroundColor = const Color(0xFFF7F7F7); // พื้นหลังจอ (เกือบขาว)
  final Color _lightCardColor = const Color(0xFFFFFFFF); // พื้นหลัง Card (ขาว)
  final Color _textColor = const Color(0xFF1F1F1F); // สีข้อความหลัก (ดำเข้ม)
  final Color _secondaryTextColor = const Color(0xFF5A5A5A); // สีข้อความรอง (เทาเข้ม)


  // สถานะโต๊ะจำลอง (ปรับให้ใช้ Order object เป็น Null)
  List<TableStatus> _tables = [
    // เพิ่ม Order ตัวอย่างเพื่อให้ดูสวยงาม
    TableStatus(id: 1, name: 'A1', isOccupied: false, qrCode: 'FASTFOOD-A1', statusColor: Colors.green.shade600),
    TableStatus(id: 2, name: 'A2', isOccupied: true, peopleCount: 2, qrCode: 'FASTFOOD-A2', statusColor: Colors.red.shade600),
    TableStatus(id: 3, name: 'B1', isOccupied: false, peopleCount: 0, qrCode: 'FASTFOOD-B1', statusColor: Colors.green.shade600),
    TableStatus(id: 4, name: 'B2', isOccupied: true, peopleCount: 4, qrCode: 'FASTFOOD-B2', 
      order: TableOrder(tableId: 4, items: [OrderItem(name: 'Pizza', price: 299, quantity: 1), OrderItem(name: 'Coke', price: 45, quantity: 3)]), 
      statusColor: Colors.red.shade600),
    TableStatus(id: 5, name: 'C1', isOccupied: true, peopleCount: 1, qrCode: 'FASTFOOD-C1', statusColor: Colors.red.shade600),
    TableStatus(id: 6, name: 'C2', isOccupied: false, qrCode: 'FASTFOOD-C2', statusColor: Colors.green.shade600),
    TableStatus(id: 7, name: 'D1', isOccupied: false, qrCode: 'FASTFOOD-D1', statusColor: Colors.green.shade600),
    TableStatus(id: 8, name: 'D2', isOccupied: true, peopleCount: 3, qrCode: 'FASTFOOD-D8', 
      order: TableOrder(tableId: 8, items: [OrderItem(name: 'Burger', price: 120, quantity: 2)]), 
      statusColor: Colors.red.shade600),
  ];

  // ******************************
  // ฟังก์ชันจัดการ Order ใหม่ (ไม่เปลี่ยนแปลง Logic)
  // ******************************
  
  // ฟังก์ชันจัดการเมื่อ Order มีการเปลี่ยนแปลง
  void _handleOrderUpdate(int tableId, TableOrder newOrder) {
    setState(() {
      final index = _tables.indexWhere((table) => table.id == tableId);
      if (index != -1) {
        
        // ใช้เฉดสีเข้มขึ้นเพื่อให้เข้ากับ Light Mode ที่ปรับปรุงแล้ว
        Color newStatusColor = Colors.green.shade600; 
        bool isOccupied = newOrder.items.isNotEmpty || !newOrder.isComplete;
        
        // กำหนดสีตามสถานะใหม่
        if (newOrder.items.isNotEmpty && !newOrder.isComplete) {
            newStatusColor = Colors.red.shade600; // ไม่ว่าง มีรายการสั่ง
        } else if (newOrder.isComplete) {
            // โต๊ะว่างทันที (ปิดบิลแล้ว)
            newStatusColor = Colors.green.shade600;
            isOccupied = false;
        }

        // อัปเดต TableStatus
        _tables[index] = _tables[index].copyWith(
          isOccupied: isOccupied,
          peopleCount: isOccupied ? (_tables[index].peopleCount > 0 ? _tables[index].peopleCount : 1) : 0, // ถ้าไม่ว่างแต่ไม่มีคนให้เป็น 1
          order: newOrder.isComplete ? null : newOrder, // ล้าง Order ถ้าปิดบิลแล้ว
          statusColor: newStatusColor,
        );
      }
    });
  }

  // ฟังก์ชันเปิดหน้า OrderDetailScreen (ไม่เปลี่ยนแปลง Logic)
  void _openOrderDetails(TableStatus table) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => OrderDetailScreen(
          tableId: table.id,
          tableName: table.name,
          currentOrder: table.order, // ส่ง Order ที่มีอยู่ไป
          onOrderUpdated: (updatedOrder) => _handleOrderUpdate(table.id, updatedOrder),
        ),
      ),
    );
  }

  // ******************************
  // Widget Builder Methods
  // ******************************

  // Widget แสดงสถานะโต๊ะ (ปรับปรุง UI)
  Widget _buildTableCard(TableStatus table) {
    final title = 'โต๊ะ ${table.name}';
    final itemCount = table.order?.items.fold(0, (sum, item) => sum + item.quantity) ?? 0;
    
    final subtitle = table.isOccupied 
        ? (itemCount > 0 ? 'มี $itemCount รายการ' : 'ไม่ว่าง (รอสั่ง)') 
        : 'ว่าง';
        
    final statusIcon = table.isOccupied ? Icons.restaurant_menu_rounded : Icons.event_seat_rounded;
    final peopleIcon = table.isOccupied && table.peopleCount > 0 ? Icons.people_alt_rounded : null;
    
    // ใช้ Card ที่ยกตัวเพื่อความสวยงาม
    return Card(
      elevation: 2,
      color: _lightCardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: table.statusColor.withOpacity(0.5), width: 1.5), // ขอบสีอ่อนลง
      ),
      child: InkWell(
        onTap: () => _openOrderDetails(table), 
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // แถวที่ 1: ชื่อโต๊ะและไอคอนสถานะหลัก
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: _textColor, 
                      fontSize: 22, 
                      fontWeight: FontWeight.bold
                    ), 
                  ),
                  Icon(statusIcon, color: table.statusColor, size: 30),
                ],
              ),
              const SizedBox(height: 10),
              
              // แถวที่ 2: สถานะย่อย
              Row(
                children: [
                  if (peopleIcon != null) ...[
                    Icon(peopleIcon, color: _secondaryTextColor, size: 18),
                    const SizedBox(width: 4),
                    Text(
                      '${table.peopleCount}',
                      style: TextStyle(color: _secondaryTextColor, fontSize: 16),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: table.isOccupied && itemCount > 0 ? Colors.orange.shade700 : table.statusColor, 
                      fontSize: 16,
                      fontWeight: FontWeight.w500
                    ),
                  ),
                ],
              ),
              
              const Spacer(),
              
              // ส่วนแสดง QR Code (จำลอง)
              Align(
                alignment: Alignment.bottomRight,
                child: Text(
                  'ID: ${table.qrCode}',
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 11), 
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final emptyTables = _tables.where((t) => !t.isOccupied).length;
    final occupiedTables = _tables.where((t) => t.isOccupied).length;
    final occupiedWithOrder = _tables.where((t) => t.isOccupied && t.order?.items.isNotEmpty == true).length;
    final occupiedWaiting = occupiedTables - occupiedWithOrder;

    return Scaffold(
      backgroundColor: _lightBackgroundColor, 
      appBar: AppBar(
        title: Text(
          'บริกร (Server View)', 
          style: TextStyle(
            color: _textColor, 
            fontWeight: FontWeight.bold,
            fontSize: 20,
          )
        ), 
        backgroundColor: _lightCardColor, 
        elevation: 0.5, // เพิ่มเงาเล็กน้อย
        surfaceTintColor: Colors.transparent, // สำหรับ Material 3
        automaticallyImplyLeading: false, 
        actions: [
          IconButton(
            icon: Icon(Icons.logout_rounded, color: Colors.red.shade600), 
            onPressed: () {
              Navigator.of(context).popUntil((route) => route.isFirst); 
            },
            tooltip: 'ออกจากระบบ',
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // สรุปสถานะ
            Wrap(
              spacing: 10.0,
              runSpacing: 10.0,
              children: [
                _buildStatusChip(Icons.event_seat_rounded, 'ว่าง', emptyTables, Colors.green.shade600),
                _buildStatusChip(Icons.access_time_filled_rounded, 'รอสั่ง', occupiedWaiting, Colors.orange.shade700),
                _buildStatusChip(Icons.shopping_cart_rounded, 'มี Order', occupiedWithOrder, Colors.red.shade600),
                _buildStatusChip(Icons.grid_on_rounded, 'ทั้งหมด', _tables.length, _primaryColor),
              ],
            ),
            const SizedBox(height: 20),
            
            Expanded(
              // Grid View แสดงสถานะโต๊ะทั้งหมด
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16.0,
                  mainAxisSpacing: 16.0,
                  childAspectRatio: 1.0, 
                ),
                itemCount: _tables.length,
                itemBuilder: (context, index) {
                  return _buildTableCard(_tables[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // Widget สำหรับแสดงสรุปสถานะ (ปรับปรุง UI)
  Widget _buildStatusChip(IconData icon, String label, int count, Color color) {
    return Chip(
      avatar: Icon(icon, color: color, size: 20),
      label: Text(
        '$label: $count',
        style: TextStyle(color: _textColor, fontWeight: FontWeight.w600), 
      ),
      // ใช้สีพื้นหลังที่อ่อนลง
      backgroundColor: color.withOpacity(0.1), 
      // เพิ่มขอบ
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: color.withOpacity(0.5), width: 1),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
    );
  }
}