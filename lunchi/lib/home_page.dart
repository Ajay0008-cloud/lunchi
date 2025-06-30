import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login_page.dart';
import 'today_menu.dart';
import 'qr_buy_lunch_page.dart';
import 'snack_order_employee.dart';
import 'coupon_count.dart';

class LunchifyHomePage extends StatefulWidget {
  final String employeeName;
  final String employeeId;

  const LunchifyHomePage({
    super.key,
    required this.employeeName,
    required this.employeeId,
  });

  @override
  State<LunchifyHomePage> createState() => _LunchifyHomePageState();
}

class _LunchifyHomePageState extends State<LunchifyHomePage>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeIn;
  int _couponCount = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _fadeIn = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _controller.forward();
    _fetchCouponCount();
  }

  Future<void> _fetchCouponCount() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('coupon_logs')
          .where('employeeId', isEqualTo: widget.employeeId)
          .get();

      setState(() {
        _couponCount = snapshot.docs.length;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching coupon count: $e');
      setState(() => _isLoading = false);
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
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.deepOrangeAccent,
        elevation: 0,
        title: Text(
          "Hi, ${widget.employeeName}",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
          )
        ],
      ),
      body: isLoading()
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: _fetchCouponCount,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _buildHeaderCard(),
            const SizedBox(height: 20),
            _buildFeatureCard(
              context,
              icon: Icons.restaurant_menu,
              label: "Today's Menu",
              page: const TodayMenuPage(),
              color: Colors.deepOrange,
            ),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildFeatureCard(
              context,
              icon: Icons.confirmation_num,
              label: "Coupons Used: $_couponCount",
              page: CouponCount(employeeId: widget.employeeId),
              color: Colors.orange,
            ),
            _buildFeatureCard(
              context,
              icon: Icons.qr_code_scanner,
              label: "Buy Lunch & Show QR",
              page: QRBuyLunchPage(employeeId: widget.employeeId),
              color: Colors.brown,
            ),
            _buildFeatureCard(
              context,
              icon: Icons.fastfood,
              label: "Snacks Order",
              page: EmployeeSnackOrderPage(employeeId: widget.employeeId),
              color: Colors.teal,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.deepOrangeAccent, Colors.orangeAccent],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.deepOrange.withOpacity(0.4),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.person, color: Colors.white, size: 36),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Welcome to Lunchify!",
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
                Text(widget.employeeName,
                    style: const TextStyle(fontSize: 16, color: Colors.white70)),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildFeatureCard(BuildContext context,
      {required IconData icon,
        required String label,
        required Widget? page,
        required Color color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 5,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            if (page != null) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => page),
              );
            }
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                colors: [color.withOpacity(0.9), color.withOpacity(0.7)],
              ),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.white.withOpacity(0.2),
                  child: Icon(icon, color: Colors.white),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ),
                const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool isLoading() => _isLoading;
}
