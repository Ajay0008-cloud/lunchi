import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login_page.dart';

class QRBuyLunchPage extends StatefulWidget {
  final String employeeId;

  const QRBuyLunchPage({super.key, required this.employeeId});

  @override
  State<QRBuyLunchPage> createState() => _QRBuyLunchPageState();
}

class _QRBuyLunchPageState extends State<QRBuyLunchPage> {
  String? qrData;
  bool showFruitQR = false;
  bool showNormalQR = false;

  bool isBefore11AM() {
    final now = DateTime.now();
    final deadline = DateTime(now.year, now.month, now.day, 11, 0);
    return now.isBefore(deadline);
  }

  Future<void> handleFruitLunch() async {
    if (!isBefore11AM()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ Fruit lunch only available before 11:00 AM")),
      );
      return;
    }

    try {
      final now = DateTime.now();
      final dateStr = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

      await FirebaseFirestore.instance.collection('coupon_logs').add({
        'employeeId': widget.employeeId,
        'type': 'fruit',
        'timestamp': now,
        'date': dateStr,
      });

      setState(() {
        qrData = "fruit_lunch_${widget.employeeId}_$dateStr";
        showFruitQR = true;
        showNormalQR = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ 1 coupon deducted for Fruit Lunch")),
      );
    } catch (e) {
      print("Error saving fruit lunch: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error processing fruit lunch.")),
      );
    }
  }

  Future<void> handleNormalLunch() async {
    final now = DateTime.now();
    final dateStr = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

    setState(() {
      qrData = "normal_lunch_${widget.employeeId}_$dateStr";
      showFruitQR = false;
      showNormalQR = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isFruitTime = isBefore11AM();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Buy Lunch & Show QR"),
        backgroundColor: Colors.deepOrange,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const LoginPage()),
                  (route) => false,
            ),
            tooltip: 'Logout',
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              "Select your lunch option:",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 30),

            ElevatedButton.icon(
              onPressed: isFruitTime ? handleFruitLunch : null,
              icon: const Icon(Icons.local_florist),
              label: const Text("Fruit Lunch (Before 11:00 AM)"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
            const SizedBox(height: 20),

            ElevatedButton.icon(
              onPressed: handleNormalLunch,
              icon: const Icon(Icons.rice_bowl),
              label: const Text("Normal Lunch"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrange,
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
            const SizedBox(height: 40),

            if (qrData != null) ...[
              QrImageView(
                data: qrData!,
                version: QrVersions.auto,
                size: 250,
                backgroundColor: Colors.white,
              ),
              const SizedBox(height: 20),
              Text(
                showFruitQR
                    ? "✅ 1 coupon deducted for Fruit Lunch"
                    : "ℹ️ Show this QR at the counter for Normal Lunch",
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

