import 'package:flutter/material.dart';
import 'admin_dashboard.dart'; // ✅ Import the new file

class AdminPage extends StatelessWidget {
  final String adminName; // ✅ Add this line

  const AdminPage({super.key, required this.adminName}); // ✅ Update constructor

  @override
  Widget build(BuildContext context) {
    return AdminDashboard(adminName: adminName); // ✅ Pass it to the dashboard
  }
}

