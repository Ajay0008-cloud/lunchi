import 'package:flutter/material.dart';

String todayFoodMenu = "Rice, Dal, Salad, Roti";
String todayFruitMenu = "Banana, Apple";

class TodayMenuPage extends StatelessWidget {
  const TodayMenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange[50],
      appBar: AppBar(
        title: const Text("Today's Menu"),
        backgroundColor: Colors.deepOrange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildMenuCard(
              context,
              icon: Icons.restaurant_menu,
              emoji: '🍱',
              title: "Food Menu",
              content: todayFoodMenu,
              color: Colors.deepOrange.shade100,
            ),
            const SizedBox(height: 20),
            _buildMenuCard(
              context,
              icon: Icons.local_grocery_store,
              emoji: '🍓',
              title: "Fruit Menu",
              content: todayFruitMenu,
              color: Colors.green.shade100,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard(BuildContext context,
      {required IconData icon,
        required String emoji,
        required String title,
        required String content,
        required Color color}) {
    return Card(
      elevation: 4,
      color: color,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 32, color: Colors.deepOrange),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "$emoji $title",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    content,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
