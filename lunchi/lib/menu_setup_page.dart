import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MenuSetupPage extends StatefulWidget {
  const MenuSetupPage({super.key});

  @override
  State<MenuSetupPage> createState() => _MenuSetupPageState();
}

class _MenuSetupPageState extends State<MenuSetupPage> {
  final List<String> foodOptions = ['Rice', 'Dal', 'Paneer', 'Roti', 'Salad'];
  final List<String> fruitOptions = ['Apple', 'Banana', 'Orange', 'Grapes'];

  String selectedFood = 'Rice';
  String selectedFruit = 'Apple';

  List<String> addedFood = [];
  List<String> addedFruit = [];

  void addFood() {
    if (!addedFood.contains(selectedFood)) {
      setState(() {
        addedFood.add(selectedFood);
      });
    }
  }

  void addFruit() {
    if (!addedFruit.contains(selectedFruit)) {
      setState(() {
        addedFruit.add(selectedFruit);
      });
    }
  }

  Future<void> saveMenu() async {
    try {
      await FirebaseFirestore.instance.collection('today_menu').doc('current').set({
        'food': addedFood,
        'fruits': addedFruit,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Menu saved successfully!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error saving menu: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange[50],
      appBar: AppBar(
        title: const Text("Setup Today's Menu"),
        backgroundColor: Colors.deepOrange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            const Text("🍱 Add Food Items", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: selectedFood,
                    decoration: const InputDecoration(
                      labelText: "Select food",
                      border: OutlineInputBorder(),
                    ),
                    items: foodOptions.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
                    onChanged: (val) => setState(() => selectedFood = val!),
                  ),
                ),
                IconButton(
                  onPressed: addFood,
                  icon: const Icon(Icons.add_circle, color: Colors.green),
                )
              ],
            ),
            Wrap(
              spacing: 8,
              children: addedFood.map((e) => Chip(label: Text(e))).toList(),
            ),

            const SizedBox(height: 30),
            const Text("🍓 Add Fruit Items", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: selectedFruit,
                    decoration: const InputDecoration(
                      labelText: "Select fruit",
                      border: OutlineInputBorder(),
                    ),
                    items: fruitOptions.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
                    onChanged: (val) => setState(() => selectedFruit = val!),
                  ),
                ),
                IconButton(
                  onPressed: addFruit,
                  icon: const Icon(Icons.add_circle, color: Colors.green),
                )
              ],
            ),
            Wrap(
              spacing: 8,
              children: addedFruit.map((e) => Chip(label: Text(e))).toList(),
            ),

            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: saveMenu,
              icon: const Icon(Icons.save),
              label: const Text("Save Menu"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
