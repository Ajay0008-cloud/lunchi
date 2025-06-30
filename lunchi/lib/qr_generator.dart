import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QRGeneratorPage extends StatelessWidget {
  const QRGeneratorPage({super.key});

  @override
  Widget build(BuildContext context) {
    // You can replace this with the logged-in user's ID or email if needed
    final userId = "user123";

    final today = DateTime.now();
    final dateStr =
        "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";

    final qrData = "${userId}_$dateStr";

    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Lunch QR"),
        backgroundColor: Colors.deepOrange,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            QrImageView(
              data: qrData,
              version: QrVersions.auto,
              size: 250.0,
              backgroundColor: Colors.white,
            ),
            const SizedBox(height: 20),
            Text(
              "QR for: $qrData",
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
