import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'qr_scanner.dart';
import 'menu_setup_page.dart';
import 'fruit_lunch_requests_page.dart';
import 'snacks_orders_page.dart';
import 'login_page.dart';

class AdminDashboard extends StatefulWidget {
  final String adminName;

  const AdminDashboard({super.key, required this.adminName});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int totalFruitRequests = 0;
  int totalCouponsCollected = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDashboardData();
  }

  Future<void> _fetchDashboardData() async {
    try {
      final fruitSnapshot = await FirebaseFirestore.instance
          .collection('fruit_lunch_requests')
          .get();

      final couponSnapshot = await FirebaseFirestore.instance
          .collection('coupon_logs')
          .get();

      setState(() {
        totalFruitRequests = fruitSnapshot.docs.length;
        totalCouponsCollected = couponSnapshot.docs.length;
        isLoading = false;
      });
    } catch (e) {
      print("Error loading dashboard data: $e");
      setState(() => isLoading = false);
    }
  }

  void _logout(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.deepOrangeAccent,
        elevation: 0,
        title: Row(
          children: [
            const CircleAvatar(
              backgroundImage: AssetImage('assets/admin_avatar.png'),
              radius: 18,
            ),
            const SizedBox(width: 10),
            Text("Hi, ${widget.adminName}", style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
          )
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: _fetchDashboardData,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Dashboard Overview',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      "Fruit Requests",
                      "$totalFruitRequests",
                      Icons.local_florist,
                      Colors.green.shade600,
                      Colors.green.shade100,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatCard(
                      "Coupons Collected",
                      "$totalCouponsCollected",
                      Icons.confirmation_num,
                      Colors.deepOrange,
                      Colors.orange.shade100,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              const Text(
                'Admin Tools',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              const SizedBox(height: 16),
              _buildActionGrid(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color, Color bgColor) {
    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 30, color: color),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: color),
          ),
          Text(title, style: const TextStyle(fontSize: 14, color: Colors.black87)),
        ],
      ),
    );
  }

  Widget _buildActionGrid() {
    final actions = [
      {
        'label': 'Setup Menu',
        'icon': Icons.restaurant_menu,
        'color': Colors.deepOrange,
        'page': const MenuSetupPage()
      },
      {
        'label': 'Fruit Lunch Requests',
        'icon': Icons.local_florist,
        'color': Colors.green,
        'page': const FruitLunchRequestsPage()
      },
      {
        'label': 'Snacks Orders',
        'icon': Icons.fastfood,
        'color': Colors.brown,
        'page': const SnacksOrdersPage()
      },
      {
        'label': 'Scan QR',
        'icon': Icons.qr_code_scanner,
        'color': Colors.blue,
        'page': const QRScannerPage()
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: actions.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.1,
      ),
      itemBuilder: (context, index) {
        final item = actions[index];
        final Color itemColor = item['color'] as Color;

        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              colors: [itemColor.withOpacity(0.9), itemColor.withOpacity(0.7)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: itemColor.withOpacity(0.4),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => item['page'] as Widget),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(item['icon'] as IconData, size: 32, color: Colors.white),
                    const SizedBox(height: 10),
                    Text(
                      item['label'] as String,
                      style: const TextStyle(fontSize: 14, color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
