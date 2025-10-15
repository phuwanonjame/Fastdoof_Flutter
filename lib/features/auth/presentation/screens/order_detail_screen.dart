import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart'; 
// *** ตรวจสอบว่าคุณมีไฟล์ uuid: ^4.0.0 ใน pubspec.yaml แล้ว ***

// **********************************************
// 1. MODELS ที่ใช้ในหน้านี้ (ย้ายมาไว้ด้านบนสุด)
// **********************************************

// โมเดลสำหรับรายการอาหารที่สั่ง
class OrderItem {
  final String name;
  final double price;
  int quantity;

  OrderItem({required this.name, required this.price, this.quantity = 1});
}

// โมเดลสำหรับเมนูทั้งหมด (จำลองฐานข้อมูล)
class MenuItem {
  final String name;
  final double price;
  final String category;

  MenuItem({required this.name, required this.price, required this.category});
}

// โมเดลสำหรับ Order ที่ผูกกับโต๊ะ
class TableOrder {
  final String orderId;
  final int tableId;
  List<OrderItem> items;
  bool isPaid;
  bool isComplete;

  TableOrder({
    required this.orderId,
    required this.tableId,
    required this.items,
    this.isPaid = false,
    this.isComplete = false,
  });
}

// **********************************************
// 2. WIDGET หลัก: OrderDetailScreen (ปรับปรุง Layout)
// **********************************************

class OrderDetailScreen extends StatefulWidget {
  final int tableId;
  final String tableName;
  final TableOrder? currentOrder; // ออร์เดอร์ปัจจุบันของโต๊ะ (ถ้ามี)
  final Function(TableOrder order) onOrderUpdated;

  const OrderDetailScreen({
    super.key,
    required this.tableId,
    required this.tableName,
    this.currentOrder,
    required this.onOrderUpdated,
  });

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> with TickerProviderStateMixin { // **ต้องมี with TickerProviderStateMixin**
  final Color _primaryColor = const Color(0xFF007AFF);
  final Color _darkBackgroundColor = const Color(0xFF121212);
  final Color _darkCardColor = const Color(0xFF1E1E1E);
  final Uuid _uuid = const Uuid(); 
  
  late TabController _tabController; // สำหรับ Mobile View
  
  late TableOrder _order;
  late List<MenuItem> _fullMenu;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // 1. จำลอง Menu ทั้งหมด
    _fullMenu = [
      MenuItem(name: 'เบอร์เกอร์เนื้อ', price: 120.0, category: 'Main'),
      MenuItem(name: 'ฟิช แอนด์ ชิปส์', price: 95.0, category: 'Main'),
      MenuItem(name: 'เฟรนช์ฟรายส์ใหญ่', price: 50.0, category: 'Side'),
      MenuItem(name: 'น้ำอัดลม', price: 35.0, category: 'Drink'),
      MenuItem(name: 'กาแฟเย็น', price: 60.0, category: 'Drink'),
      MenuItem(name: 'นักเก็ตไก่ (6 ชิ้น)', price: 80.0, category: 'Side'),
    ];

    // 2. กำหนด Order ปัจจุบัน
    if (widget.currentOrder != null) {
      _order = widget.currentOrder!;
    } else {
      _order = TableOrder(
        orderId: _uuid.v4(),
        tableId: widget.tableId,
        items: [],
      );
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ******************************
  // การคำนวณยอดรวม
  // ******************************

  double get _subtotal { return _order.items.fold(0.0, (sum, item) => sum + (item.price * item.quantity)); }
  double get _vat { return _subtotal * 0.07; }
  double get _grandTotal { return _subtotal + _vat; }

  // ******************************
  // ฟังก์ชันจัดการรายการอาหาร
  // ******************************

  void _addItemToOrder(MenuItem item) {
    setState(() {
      final existingItem = _order.items.firstWhere(
        (i) => i.name == item.name,
        orElse: () => OrderItem(name: '', price: 0),
      );

      if (existingItem.name.isNotEmpty) {
        existingItem.quantity++;
      } else {
        _order.items.add(OrderItem(name: item.name, price: item.price));
      }
      _updateOrderCallback();
    });
  }

  void _updateQuantity(OrderItem item, int change) {
    setState(() {
      item.quantity += change;
      if (item.quantity <= 0) {
        _order.items.remove(item);
      }
      _updateOrderCallback();
    });
  }
  
  void _updateOrderCallback() {
    widget.onOrderUpdated(_order);
  }

  // ******************************
  // ฟังก์ชันปิดบิล / ชำระเงิน
  // ******************************
  void _checkout() {
    _showPaymentDialog();
  }

  void _showPaymentDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: _darkCardColor,
          title: Text('การชำระเงิน: โต๊ะ ${widget.tableName}', style: const TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('ยอดรวมสุทธิ: ${_grandTotal.toStringAsFixed(2)} บาท', 
                style: TextStyle(color: _primaryColor, fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              Icon(Icons.qr_code_2, size: 150, color: Colors.white), 
              const SizedBox(height: 10),
              Text('สแกน QR Code เพื่อชำระเงิน', style: TextStyle(color: Colors.grey[400])),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _confirmPayment();
              },
              child: Text('ยืนยันการชำระเงิน', style: TextStyle(color: Colors.green, fontSize: 16)),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('ยกเลิก', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _confirmPayment() {
    setState(() {
      _order.isPaid = true;
      _order.isComplete = true; 
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('บิล ${widget.tableName} ถูกปิดและชำระเงินแล้ว'),
        backgroundColor: Colors.green,
      ),
    );
    _updateOrderCallback();
    Navigator.of(context).pop(); 
  }

  // ******************************
  // REFACTOR WIDGETS
  // ******************************

  Widget _buildOrderItem(OrderItem item) {
     return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: _darkCardColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                ),
                Text(
                  '${item.price.toStringAsFixed(2)} บาท/หน่วย',
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                ),
              ],
            ),
          ),
          
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                onPressed: () => _updateQuantity(item, -1),
              ),
              Text(
                '${item.quantity}',
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
              IconButton(
                icon: Icon(Icons.add_circle_outline, color: _primaryColor),
                onPressed: () => _updateQuantity(item, 1),
              ),
            ],
          ),
          
          SizedBox(
            width: 70,
            child: Text(
              '${(item.price * item.quantity).toStringAsFixed(2)}',
              textAlign: TextAlign.right,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildMenuButton(MenuItem item) {
    return Padding(
      padding: const EdgeInsets.only(right: 10, bottom: 10),
      child: ActionChip(
        avatar: Icon(Icons.add, color: _primaryColor),
        label: Text('${item.name} (${item.price.toStringAsFixed(0)})', style: const TextStyle(color: Colors.white)),
        backgroundColor: _darkCardColor,
        onPressed: () => _addItemToOrder(item),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: _primaryColor.withOpacity(0.5)),
        ),
      ),
    );
  }
  
  Widget _buildTotalSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _darkCardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _buildTotalRow('ยอดรวม (Subtotal)', _subtotal),
          _buildTotalRow('VAT (7%)', _vat, isTax: true),
          const Divider(color: Colors.grey),
          _buildTotalRow('ยอดรวมสุทธิ', _grandTotal, isGrandTotal: true),
        ],
      ),
    );
  }
  
  Widget _buildTotalRow(String label, double amount, {bool isTax = false, bool isGrandTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: isGrandTotal ? Colors.white : Colors.grey[400],
              fontSize: isGrandTotal ? 18 : 14,
              fontWeight: isGrandTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            '${amount.toStringAsFixed(2)} บาท',
            style: TextStyle(
              color: isGrandTotal ? Colors.white : Colors.grey[400],
              fontSize: isGrandTotal ? 18 : 14,
              fontWeight: isGrandTotal ? FontWeight.bold : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildOrderListPanel() {
    return Column(
      children: [
        Expanded(
          child: _order.items.isEmpty
              ? Center(
                  child: Text(
                    'ยังไม่มีรายการสั่ง.',
                    style: TextStyle(color: Colors.grey[500]),
                  ),
                )
              : ListView(
                  children: _order.items.map(_buildOrderItem).toList(),
                ),
        ),
        const SizedBox(height: 20),
        
        _buildTotalSummary(),
        const SizedBox(height: 20),
        
        ElevatedButton.icon(
          onPressed: _order.items.isEmpty ? null : _checkout,
          icon: const Icon(Icons.qr_code_2, color: Colors.white),
          label: Text(
            'ปิดบิล & รับชำระ (QR Scan) (${_grandTotal.toStringAsFixed(2)} บาท)',
            style: const TextStyle(fontSize: 18),
          ),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 60),
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    );
  }
  
  Widget _buildMenuSelectionPanel() {
    return Container(
      padding: const EdgeInsets.all(8.0),
      color: _darkCardColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'เลือกเมนู',
            style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const Divider(color: Colors.grey),
          
          Expanded(
            child: SingleChildScrollView(
              child: Wrap(
                children: _fullMenu.map(_buildMenuButton).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ******************************
  // BUILD METHOD
  // ******************************
  
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTabletLayout = screenWidth > 800; 

    return Scaffold(
      backgroundColor: _darkBackgroundColor,
      appBar: AppBar(
        title: Text(
          'จัดการออร์เดอร์: ${widget.tableName}',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: _darkBackgroundColor,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        bottom: isTabletLayout
            ? null
            : TabBar(
                controller: _tabController,
                indicatorColor: _primaryColor,
                labelColor: _primaryColor,
                unselectedLabelColor: Colors.grey,
                tabs: const [
                  Tab(text: '1. รายการที่สั่ง'),
                  Tab(text: '2. เพิ่มเมนู'),
                ],
              ),
      ),
      body: isTabletLayout
          ? Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: _buildOrderListPanel(),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: _buildMenuSelectionPanel(),
                  ),
                ],
              ),
            )
          : TabBarView(
              controller: _tabController,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: _buildOrderListPanel(),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: _buildMenuSelectionPanel(),
                ),
              ],
            ),
    );
  }
}