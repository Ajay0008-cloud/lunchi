import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CouponCount extends StatelessWidget {
  final String employeeId;

  const CouponCount({super.key, required this.employeeId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Coupons Used"),
        backgroundColor: Colors.orange,
      ),
      body: FutureBuilder<QuerySnapshot>(
        future: FirebaseFirestore.instance
            .collection('coupon_logs')
            .where('employeeId', isEqualTo: employeeId)
            .orderBy('timestamp', descending: true)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No coupons used yet."));
          }

          final logs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: logs.length,
            itemBuilder: (context, index) {
              final data = logs[index].data() as Map<String, dynamic>;
              final date = data['timestamp']?.toDate().toString().split(" ")[0] ?? "Unknown";
              return ListTile(
                leading: const Icon(Icons.confirmation_num, color: Colors.deepOrange),
                title: Text("Coupon used on $date"),
              );
            },
          );
        },
      ),
    );
  }
}
