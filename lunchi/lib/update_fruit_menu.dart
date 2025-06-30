import 'package:flutter/material.dart';
import 'today_menu.dart'; // contains: String todayFoodMenu

class UpdateFoodMenu extends StatefulWidget {
  const UpdateFoodMenu({super.key});

  @override
  State<UpdateFoodMenu> createState() => _UpdateFoodMenuState();
}

class _UpdateFoodMenuState extends State<UpdateFoodMenu> {
  final TextEditingController controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    controller.text = todayFoodMenu; // pre-fill existing menu
  }

  void updateMenu(BuildContext context) {
    final updatedItems = controller.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    todayFoodMenu = updatedItems.join(', ');

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("✅ Food menu updated!")),
    );

    Navigator.pop(context); // return to AdminPage
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Update Food Menu")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text(
              'Enter today’s food items:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              maxLines: 3,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'e.g., Rice, Dal, Roti, Salad',
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => updateMenu(context),
              icon: const Icon(Icons.save),
              label: const Text("Update Menu"),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: Colors.deepOrange,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
