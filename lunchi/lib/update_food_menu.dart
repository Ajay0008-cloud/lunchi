import 'package:flutter/material.dart';
import 'today_menu.dart'; // <- contains todayFoodMenu variable

class UpdateFoodMenu extends StatelessWidget {
  final TextEditingController controller = TextEditingController();

  void updateMenu(BuildContext context) {
    List<String> items = controller.text.split(',').map((e) => e.trim()).toList();

    // Save to the shared variable
    todayFoodMenu = items.join(', ');

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Food menu updated successfully!")),
    );

    Navigator.pop(context); // return to Admin Page
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Update Food Menu")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: 'Enter food items separated by commas',
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => updateMenu(context),
              child: const Text("Update"),
            ),
          ],
        ),
      ),
    );
  }
}
