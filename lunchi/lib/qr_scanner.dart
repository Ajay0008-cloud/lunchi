import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class QRScannerPage extends StatefulWidget {
  const QRScannerPage({super.key});

  @override
  State<QRScannerPage> createState() => _QRScannerPageState();
}

class _QRScannerPageState extends State<QRScannerPage> {
  String? scannedData;
  bool isProcessing = false;

  void onDetect(BarcodeCapture capture) async {
    if (isProcessing || capture.barcodes.isEmpty) return;

    setState(() => isProcessing = true);

    final code = capture.barcodes.first.rawValue;
    if (code == null) return;

    setState(() => scannedData = code);

    final parts = code.split('_');
    if (parts.length < 3) {
      showSnack("❌ Invalid QR format");
      return resetProcessing();
    }

    final type = parts[0]; // fruit_lunch or normal_lunch
    final dateStr = parts[1];
    final employeeId = parts[2];

    try {
      final docRef = FirebaseFirestore.instance.collection('employees').doc(employeeId);
      final doc = await docRef.get();

      if (!doc.exists) {
        showSnack("❌ Employee not found");
        return resetProcessing();
      }

      final now = DateTime.now();
      final today = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

      if (dateStr != today) {
        showSnack("⏳ This QR is not for today");
        return resetProcessing();
      }

      final lastScanned = (doc['lastScanDate'] as Timestamp?)?.toDate();
      if (lastScanned != null &&
          lastScanned.day == now.day &&
          lastScanned.month == now.month &&
          lastScanned.year == now.year) {
        showSnack("⚠️ Already scanned today");
        return resetProcessing();
      }

      // Deduct coupon if it's fruit lunch
      if (type == 'fruit') {
        final coupons = doc['couponsLeft'] ?? 0;
        if (coupons <= 0) {
          showSnack("🚫 No coupons left for $employeeId");
          return resetProcessing();
        }

        await docRef.update({
          'couponsLeft': coupons - 1,
          'lastScanDate': FieldValue.serverTimestamp(),
        });

        showSnack("✅ Coupon deducted for $employeeId");
      } else {
        await docRef.update({
          'lastScanDate': FieldValue.serverTimestamp(),
        });

        showSnack("✅ Normal lunch verified for $employeeId");
      }
    } catch (e) {
      showSnack("❌ Error: ${e.toString()}");
    }

    resetProcessing();
  }

  void showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  void resetProcessing() async {
    await Future.delayed(const Duration(seconds: 2));
    setState(() => isProcessing = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Scan QR to Deduct Coupon"),
        backgroundColor: Colors.blueAccent,
      ),
      body: Column(
        children: [
          Expanded(
            flex: 4,
            child: MobileScanner(
              onDetect: onDetect,
              controller: MobileScannerController(facing: CameraFacing.back),
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: scannedData == null
                  ? const Text("Scan a QR code")
                  : Text("Scanned: $scannedData"),
            ),
          ),
        ],
      ),
    );
  }
}
