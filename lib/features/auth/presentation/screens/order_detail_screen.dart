// lib/features/auth/presentation/screens/order_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

// 💡 IMPORT Model จากไฟล์กลาง:
import '../../../../models/order_models.dart'; 

// **********************************************
// 1. WIDGET ใหม่: PaymentScreen (จัดการการชำระเงินแยกส่วน)
// **********************************************
class PaymentScreen extends StatefulWidget {
  final TableOrder currentOrder;
  // Callback รับ Order ที่เหลือ, PaymentType, ยอดรวมที่จ่าย และ รายการที่ถูกชำระ
  final Function(TableOrder, PaymentType, double, List<OrderItem>) onOrderPaid; 

  const PaymentScreen({
    super.key,
    required this.currentOrder,
    required this.onOrderPaid,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  late List<OrderItem> _tempItems; 
  PaymentType _selectedPaymentType = PaymentType.cash; 
  Set<String> _selectedSources = {}; 

  @override
  void initState() {
    super.initState();
    // คัดลอกรายการมาเพื่อจัดการในหน้านี้ (ป้องกันการเปลี่ยน order เดิมก่อนจ่าย)
    _tempItems = List.from(widget.currentOrder.items);
    // เริ่มต้นเลือกรายการทั้งหมด
    _selectedSources.addAll(widget.currentOrder.items.map((e) => e.orderSource));
  }
  
  // กลุ่มรายการสั่งตาม orderSource
  Map<String, List<OrderItem>> _groupItemsBySource() {
    Map<String, List<OrderItem>> grouped = {};
    for (var item in _tempItems) {
      if (!grouped.containsKey(item.orderSource)) {
        grouped[item.orderSource] = [];
      }
      grouped[item.orderSource]!.add(item);
    }
    return grouped;
  }

  // การจัดการการเลือกกลุ่ม Order Source (จ่ายแยกบิลตามอุปกรณ์)
  void _toggleSourceSelection(String source) {
    setState(() {
      if (_selectedSources.contains(source)) {
        _selectedSources.remove(source);
      } else {
        _selectedSources.add(source);
      }
    });
  }

  // คำนวณยอดรวมที่เลือก
  double _calculateSelectedTotal() {
    // 1. คำนวณยอดรวมก่อน VAT
    final subtotal = _tempItems
        .where((item) => _selectedSources.contains(item.orderSource))
        .fold(0.0, (sum, item) => sum + (item.price * item.quantity));
    // 2. คำนวณ VAT 7%
    final vat = subtotal * 0.07;
    return subtotal + vat;
  }

  // ฟังก์ชันดำเนินการชำระเงิน
  void _processPayment() {
    final total = _calculateSelectedTotal();
    if (total == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('โปรดเลือรายการที่จะชำระเงิน')),
      );
      return;
    }

    // 1. รายการที่เหลือ
    final remainingItems = _tempItems
        .where((item) => !_selectedSources.contains(item.orderSource))
        .toList();
        
    // 2. รายการที่ถูกจ่าย (ใช้สำหรับบันทึกประวัติและพิมพ์สลิป)
    final paidItems = _tempItems
        .where((item) => _selectedSources.contains(item.orderSource))
        .toList();


    // 3. สร้าง Order ใหม่
    TableOrder newOrder;
    if (remainingItems.isEmpty) {
      // ชำระเงินทั้งหมด -> ปิดบิล
      newOrder = widget.currentOrder.copyWith(items: remainingItems, isPaid: true, isComplete: true);
    } else {
      // ชำระเงินบางส่วน -> อัปเดตรายการที่เหลือ
      newOrder = widget.currentOrder.copyWith(items: remainingItems, isPaid: false, isComplete: false);
    }
    
    // แจ้งการอัปเดตกลับไปยัง OrderDetailScreen พร้อมรายการที่ถูกชำระ
    widget.onOrderPaid(newOrder, _selectedPaymentType, total, paidItems);
  }
  
  // *** ฟังก์ชันจำลองการพิมพ์สลิป ***
  void _mockPrintReceipt(double total, PaymentType type, List<OrderItem> items) {
     final paymentMethod = type == PaymentType.cash ? "เงินสด" : "สแกน QR";
     
     // ปิด Bottom Sheet ก่อน
     Navigator.of(context).pop(); 
     
     // แสดง Modal จำลอง
     showDialog(
       context: context,
       builder: (context) {
         return AlertDialog(
           title: const Text('✅ สลิปพร้อมพิมพ์', style: TextStyle(color: Colors.green)),
           content: Column(
             mainAxisSize: MainAxisSize.min,
             crossAxisAlignment: CrossAxisAlignment.start,
             children: [
               const Text('จำลองการส่งข้อมูลใบเสร็จไปเครื่องพิมพ์:', style: TextStyle(fontWeight: FontWeight.bold)),
               const Divider(),
               Text('ยอดรวม: ${total.toStringAsFixed(2)} บาท'),
               Text('วิธีชำระ: $paymentMethod'),
               Text('รายการที่พิมพ์: ${items.length} ชนิด'),
               const SizedBox(height: 10),
               const Text('--- กำลังเชื่อมต่อ Bluetooth/LAN... ---'),
             ],
           ),
           actions: [
             TextButton(
               onPressed: () => Navigator.of(context).pop(),
               child: const Text('ปิด (ถือว่าพิมพ์แล้ว)'),
             ),
           ],
         );
       },
     );
  }

  @override
  Widget build(BuildContext context) {
    final groupedItems = _groupItemsBySource();
    final total = _calculateSelectedTotal();

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('ชำระเงิน: ${widget.currentOrder.tableName}', 
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const Divider(),

            // 1. ส่วนเลือกกลุ่ม Order Source (บิลย่อย)
            const Text('💡 เลือกกลุ่มบิลที่ต้องการชำระเงิน (จัดกลุ่มตาม Source)', 
              style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8.0,
              runSpacing: 4.0,
              children: groupedItems.keys.map((source) {
                final isSelected = _selectedSources.contains(source);
                return ActionChip(
                  label: Text('บิล: $source'),
                  backgroundColor: isSelected ? Colors.blue.withOpacity(0.2) : Colors.grey[200],
                  onPressed: () => _toggleSourceSelection(source),
                  side: isSelected ? const BorderSide(color: Colors.blue) : BorderSide.none,
                );
              }).toList(),
            ),
            const SizedBox(height: 15),

            // 2. รายการที่ถูกเลือก
            Expanded(
              child: ListView(
                children: [
                  ..._tempItems
                      .where((item) => _selectedSources.contains(item.orderSource))
                      .map((item) => ListTile(
                            title: Text('${item.name} x ${item.quantity}'),
                            subtitle: Text('บิล: ${item.orderSource}', style: const TextStyle(fontSize: 12)),
                            trailing: Text('${((item.price * item.quantity)*1.07).toStringAsFixed(2)} บาท'), // แสดงราคารวม VAT
                          ))
                      .toList(),
                  if (total == 0)
                    const Center(child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: Text('โปรดเลือรายการที่จะชำระเงิน', style: TextStyle(color: Colors.red)),
                    )),
                ],
              ),
            ),

            // 3. ส่วนสรุปยอดและเลือกวิธีการชำระ
            Container(
              padding: const EdgeInsets.only(top: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'ยอดรวมสุทธิที่ต้องชำระ: ${total.toStringAsFixed(2)} บาท',
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.indigo),
                  ),
                  const SizedBox(height: 16),
                  
                  // เลือกวิธีการชำระเงิน (เงินสด/สแกน)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ChoiceChip(
                        label: const Text('รับเงินสด 💵'),
                        selected: _selectedPaymentType == PaymentType.cash,
                        onSelected: (selected) {
                          setState(() {
                            _selectedPaymentType = PaymentType.cash;
                          });
                        },
                        selectedColor: Colors.green[100],
                      ),
                      ChoiceChip(
                        label: const Text('สแกน QR 📲'),
                        selected: _selectedPaymentType == PaymentType.scan,
                        onSelected: (selected) {
                          setState(() {
                            _selectedPaymentType = PaymentType.scan;
                          });
                        },
                        selectedColor: Colors.blue[100],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // ปุ่มชำระเงิน
                  ElevatedButton(
                    onPressed: total > 0 ? _processPayment : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: total > 0 ? Colors.green : Colors.grey,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: Text(
                      'ยืนยันชำระเงิน: (${_selectedPaymentType == PaymentType.cash ? "เงินสด" : "สแกน"})',
                      style: const TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  // *** ปุ่มพิมพ์สลิป (จำลอง) ***
                  ElevatedButton.icon(
                    onPressed: total > 0 
                      ? () => _mockPrintReceipt(
                            total, 
                            _selectedPaymentType, 
                            _tempItems.where((item) => _selectedSources.contains(item.orderSource)).toList()
                          )
                      : null,
                    icon: const Icon(Icons.print_rounded, color: Colors.blueGrey),
                    label: const Text('พิมพ์สลิปที่เลือก (Mock Print)'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 45),
                      backgroundColor: Colors.grey[200],
                      foregroundColor: Colors.blueGrey[800],
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      elevation: 0,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// **********************************************
// 2. WIDGET หลัก: OrderDetailScreen
// **********************************************

class OrderDetailScreen extends StatefulWidget {
  final int tableId;
  final String tableName;
  final String tableQrCode; // รับ QR Code
  final TableOrder? currentOrder; 
  final Function(TableOrder order) onOrderUpdated;

  const OrderDetailScreen({
    super.key,
    required this.tableId,
    required this.tableName,
    required this.tableQrCode, // เพิ่ม Required
    this.currentOrder,
    required this.onOrderUpdated,
  });

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> with TickerProviderStateMixin { 
  final Color _primaryColor = const Color(0xFF007AFF); 
  
  final Color _lightBackgroundColor = Colors.white;
  final Color _lightCardColor = Colors.white; 
  final Color _onLightBackground = Colors.black87; 
  final Color _secondaryTextColor = Colors.grey[700]!; 

  final Uuid _uuid = const Uuid(); 
  
  late TabController _tabController; 
  
  late TableOrder _order;
  late List<MenuItem> _fullMenu;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // 1. จำลอง Menu ทั้งหมด (ใช้ MenuItem จาก order_models.dart)
    _fullMenu = [
      MenuItem(name: 'เบอร์เกอร์เนื้อ', price: 120.0, category: 'Main'),
      MenuItem(name: 'ฟิช แอนด์ ชิปส์', price: 95.0, category: 'Main'),
      MenuItem(name: 'เฟรนช์ฟรายส์ใหญ่', price: 50.0, category: 'Side'),
      MenuItem(name: 'น้ำอัดลม', price: 35.0, category: 'Drink'),
      MenuItem(name: 'กาแฟเย็น', price: 60.0, category: 'Drink'),
      MenuItem(name: 'นักเก็ตไก่ (6 ชิ้น)', price: 80.0, category: 'Side'),
    ];

    // 2. กำหนด Order ปัจจุบัน (ใช้ TableOrder จาก order_models.dart)
    if (widget.currentOrder != null) {
      _order = widget.currentOrder!;
    } else {
      // โต๊ะว่าง: สร้าง Order ใหม่ โดยไม่มีรายการอาหารจำลอง
      _order = TableOrder(
        orderId: _uuid.v4(),
        tableId: widget.tableId,
        tableName: widget.tableName, 
        items: [], // เริ่มต้นด้วยรายการว่างเปล่า
      );
      
      // ส่ง Order ใหม่กลับไป WaiterScreen ทันทีที่มีการสร้าง
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _updateOrderCallback();
      });
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
        (i) => i.name == item.name && i.orderSource == 'T${widget.tableId}-Waiter', // หาจากชื่อและ Source (Waiter)
        orElse: () => OrderItem(name: '', price: 0, orderSource: ''),
      );

      if (existingItem.name.isNotEmpty) {
        existingItem.quantity++;
      } else {
        // กำหนด orderSource เป็น 'T(tableId)-Waiter' สำหรับรายการที่เพิ่มผ่านหน้านี้
        _order.items.add(OrderItem(name: item.name, price: item.price, orderSource: 'T${widget.tableId}-Waiter'));
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
  
  // *** ฟังก์ชันใหม่: ยกเลิกรายการ (สมมติ: เมนูหมด) ***
  void _cancelItem(OrderItem item) {
    setState(() {
      _order.items.remove(item);
      _updateOrderCallback();
    });
    // แสดง SnackBar แจ้งว่ายกเลิกแล้ว
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('ยกเลิกรายการ "${item.name}" แล้ว'),
        backgroundColor: Colors.red.shade700,
      ),
    );
  }
  
  void _updateOrderCallback() {
    widget.onOrderUpdated(_order);
  }
  
  // ฟังก์ชันใหม่: ส่งออเดอร์ไปครัว
  void _sendToKitchen() {
    setState(() {
      _order = _order.copyWith(isSentToKitchen: true); // อัปเดตสถานะ
    });
    _updateOrderCallback();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('ส่งออเดอร์ไปห้องครัวแล้ว'), backgroundColor: Colors.orange),
    );
  }

  // ******************************
  // ฟังก์ชันปิดบิล / ชำระเงิน
  // ******************************
  void _checkout() {
    // ต้องมี currentOrder ก่อน เพื่อใช้ OrderId ในการบันทึก History
    if (widget.currentOrder == null) return;
    _showPaymentSheet();
  }

  // ปรับ Callback รับ 4 ค่า: updatedOrder, paymentType, paidGrandTotal, paidItems
  void _confirmPayment(TableOrder updatedOrder, PaymentType paymentType, double paidGrandTotal, List<OrderItem> paidItems) {
    setState(() {
      _order = updatedOrder; // อัปเดต Order ด้วยรายการที่เหลือ
    });

    if (updatedOrder.isComplete) {
        // *** 1. บันทึกประวัติเมื่อปิดบิลและรายการเหลือ 0 แล้วเท่านั้น ***
        
        // รายการที่ถูกจ่าย คือ paidItems ที่ส่งมาจาก PaymentScreen
        final List<OrderItem> itemsPaid = List.from(paidItems);

        final OrderHistory historyRecord = OrderHistory(
            historyId: const Uuid().v4(),
            orderId: widget.currentOrder!.orderId, 
            tableName: widget.tableName,
            qrCode: widget.tableQrCode, 
            items: itemsPaid, 
            grandTotal: paidGrandTotal, 
            paymentTime: DateTime.now(),
            paymentType: paymentType,
        );
        
        // 2. บันทึกเข้า Global History
        globalOrderHistory.add(historyRecord);
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ชำระเงินและปิดบิลเรียบร้อยแล้ว'), backgroundColor: Colors.green),
        );
        _updateOrderCallback();
        Navigator.of(context).pop(); // ปิด OrderDetailScreen หากปิดบิลแล้ว
    } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ชำระเงินบางส่วนเรียบร้อยแล้ว'), backgroundColor: Colors.orange),
        );
        _updateOrderCallback();
    }
  }
  
  // สร้าง Payment Bottom Sheet ใหม่
  void _showPaymentSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return PaymentScreen(
          currentOrder: _order,
          // ส่ง 4 ค่าเข้า _confirmPayment
          onOrderPaid: (updatedOrder, paymentType, paidGrandTotal, paidItems) { 
            // ไม่ต้องปิด Bottom Sheet ตรงนี้ เพราะ _processPayment ใน PaymentScreen จะทำเอง
            _confirmPayment(updatedOrder, paymentType, paidGrandTotal, paidItems); 
          },
        );
      },
    );
  }

  // ******************************
  // REFACTOR WIDGETS
  // ******************************

  Widget _buildOrderItem(OrderItem item) {
      return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: _lightCardColor,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2), 
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: TextStyle(color: _onLightBackground, fontSize: 16, fontWeight: FontWeight.w600),
                ),
                Text(
                  // แสดง Order Source
                  'Source: ${item.orderSource}', 
                  style: TextStyle(color: Colors.blueGrey, fontSize: 12),
                ),
              ],
            ),
          ),
          
          Row(
            children: [
              // *** ปุ่มยกเลิกรายการ (เพิ่มเข้ามา) ***
              IconButton(
                icon: Icon(Icons.cancel_outlined, color: Colors.red.shade900, size: 24),
                onPressed: () => _cancelItem(item), // เรียกฟังก์ชันยกเลิก
                tooltip: 'ยกเลิกรายการ (เมนูหมด/ลูกค้ายกเลิก)',
              ),
              
              IconButton(
                icon: Icon(Icons.remove_circle_outline, color: Colors.red.shade600),
                onPressed: () => _updateQuantity(item, -1),
              ),
              Text(
                '${item.quantity}',
                style: TextStyle(color: _onLightBackground, fontSize: 16),
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
              style: TextStyle(color: _onLightBackground, fontWeight: FontWeight.bold),
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
        label: Text('${item.name} (${item.price.toStringAsFixed(0)})', style: TextStyle(color: _onLightBackground)),
        backgroundColor: _lightCardColor,
        onPressed: () => _addItemToOrder(item),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: Colors.grey.withOpacity(0.5)), 
        ),
      ),
    );
  }
  
  Widget _buildTotalSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _lightCardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          _buildTotalRow('ยอดรวม (Subtotal)', _subtotal),
          _buildTotalRow('VAT (7%)', _vat, isTax: true),
          Divider(color: Colors.grey.shade300),
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
              color: isGrandTotal ? _onLightBackground : _secondaryTextColor,
              fontSize: isGrandTotal ? 18 : 14,
              fontWeight: isGrandTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            '${amount.toStringAsFixed(2)} บาท',
            style: TextStyle(
              color: isGrandTotal ? _primaryColor : _secondaryTextColor, 
              fontSize: isGrandTotal ? 18 : 14,
              fontWeight: isGrandTotal ? FontWeight.bold : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildOrderListPanel() {
    // ใช้ Getter ที่ปลอดภัย safeIsSentToKitchen
    final bool canSendToKitchen = !_order.safeIsSentToKitchen && _order.items.isNotEmpty;
    final bool canCheckout = _order.items.isNotEmpty;
    
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
        
        // ปุ่มส่งออเดอร์ไปครัว (แสดงเมื่อยังไม่ถูกส่งเท่านั้น)
        if (!_order.safeIsSentToKitchen) ...[
          ElevatedButton.icon(
            onPressed: canSendToKitchen ? _sendToKitchen : null,
            icon: const Icon(Icons.send_rounded, color: Colors.white),
            label: const Text(
              'ส่งออเดอร์ไปครัว',
              style: TextStyle(fontSize: 18),
            ),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 60),
              backgroundColor: Colors.orange.shade700, 
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 10),
        ],
        
        // ปุ่มชำระเงิน/ปิดบิล
        ElevatedButton.icon(
          onPressed: canCheckout ? _checkout : null, // เรียก _checkout() เพื่อเปิด Payment Sheet
          icon: const Icon(Icons.payment, color: Colors.white),
          label: Text(
            'ชำระเงิน / ปิดบิล (${_grandTotal.toStringAsFixed(2)} บาท)',
            style: const TextStyle(fontSize: 18),
          ),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 60),
            backgroundColor: _primaryColor, // ใช้สีหลัก
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    );
  }
  
  Widget _buildMenuSelectionPanel() {
    // จัดกลุ่มเมนูตาม Category
    final Map<String, List<MenuItem>> groupedMenu = {};
    for (var item in _fullMenu) {
      groupedMenu.putIfAbsent(item.category, () => []).add(item);
    }
    
    return Container(
      padding: const EdgeInsets.all(8.0),
      color: _lightBackgroundColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'เลือกเมนู',
            style: TextStyle(color: _onLightBackground, fontSize: 24, fontWeight: FontWeight.bold),
          ),
          Divider(color: Colors.grey.shade300),
          
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: groupedMenu.entries.map((entry) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 10.0, bottom: 5),
                        child: Text(
                          entry.key,
                          style: TextStyle(color: _primaryColor, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Wrap(
                        children: entry.value.map(_buildMenuButton).toList(),
                      ),
                      Divider(),
                    ],
                  );
                }).toList(),
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
      backgroundColor: _lightBackgroundColor,
      appBar: AppBar(
        title: Text(
          'จัดการออร์เดอร์: ${widget.tableName}',
          style: TextStyle(color: _onLightBackground, fontWeight: FontWeight.bold),
        ),
        backgroundColor: _lightBackgroundColor,
        iconTheme: IconThemeData(color: _onLightBackground), 
        elevation: 1, 
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