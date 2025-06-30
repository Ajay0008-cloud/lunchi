import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EmployeeSnackOrderPage extends StatefulWidget {
  final String employeeId;

  const EmployeeSnackOrderPage({super.key, required this.employeeId});

  @override
  State<EmployeeSnackOrderPage> createState() => _EmployeeSnackOrderPageState();
}

class _EmployeeSnackOrderPageState extends State<EmployeeSnackOrderPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _roomController = TextEditingController();
  bool _orderPlaced = false;

  final List<String> _availableSnacks = [
    'Samosa',
    'Sandwich',
    'Burger',
    'Tea',
    'Coffee',
    'Juice',
  ];

  final Map<String, String> _snackImages = {
    'Samosa': '🥟',
    'Sandwich': '🥪',
    'Burger': '🍔',
    'Tea': '🍵',
    'Coffee': '☕',
    'Juice': '🧃',
  };

  Map<String, int> _selectedSnacks = {};

  final Map<String, String> _weeklyChart = {
    'Monday': 'Samosa',
    'Tuesday': 'Sandwich',
    'Wednesday': 'Burger',
    'Thursday': 'Tea',
    'Friday': 'Coffee',
    'Saturday': 'Juice',
  };

  Future<void> _submitOrder() async {
    if (_roomController.text.trim().isEmpty || _selectedSnacks.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select snacks and enter your room number."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    for (var entry in _selectedSnacks.entries) {
      await FirebaseFirestore.instance.collection('snackOrders').add({
        'snack': entry.key,
        'quantity': entry.value,
        'employeeId': widget.employeeId,
        'room': _roomController.text.trim(),
        'timestamp': Timestamp.now(),
        'amount': null,
      });
    }

    setState(() {
      _selectedSnacks.clear();
      _roomController.clear();
      _orderPlaced = true;
    });

    Future.delayed(const Duration(seconds: 3), () {
      setState(() {
        _orderPlaced = false;
      });
    });
  }

  void _showAddSnackDialog() {
    final TextEditingController snackController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Add New Snack"),
        content: TextField(
          controller: snackController,
          decoration: const InputDecoration(hintText: "Snack name"),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              final newSnack = snackController.text.trim();
              if (newSnack.isNotEmpty && !_availableSnacks.contains(newSnack)) {
                setState(() {
                  _availableSnacks.add(newSnack);
                  _snackImages[newSnack] = '🍽️';
                });
              }
              Navigator.pop(context);
            },
            child: const Text("Add"),
          )
        ],
      ),
    );
  }

  Widget _buildWeeklyChart() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.teal.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: _weeklyChart.entries.map((entry) {
          return ListTile(
            dense: true,
            leading: Text(entry.key, style: const TextStyle(fontWeight: FontWeight.w600)),
            trailing: Text("${_snackImages[entry.value] ?? "🍽️"} ${entry.value}",
                style: const TextStyle(fontWeight: FontWeight.bold)),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSnackGrid() {
    return GridView.builder(
      shrinkWrap: true,
      itemCount: _availableSnacks.length,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.9,
      ),
      itemBuilder: (context, index) {
        final snack = _availableSnacks[index];
        final isSelected = _selectedSnacks.containsKey(snack);
        final qty = _selectedSnacks[snack] ?? 1;

        return GestureDetector(
          onTap: () {
            setState(() {
              if (isSelected) {
                _selectedSnacks.remove(snack);
              } else {
                _selectedSnacks[snack] = 1;
              }
            });
          },
          child: Container(
            decoration: BoxDecoration(
              color: isSelected ? Colors.teal[100] : Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? Colors.teal : Colors.transparent,
                width: 2,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(_snackImages[snack] ?? "🍽️", style: const TextStyle(fontSize: 32)),
                const SizedBox(height: 8),
                Text(snack, style: const TextStyle(fontSize: 16)),
                if (isSelected)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove, size: 18),
                        onPressed: () {
                          if (qty > 1) {
                            setState(() => _selectedSnacks[snack] = qty - 1);
                          }
                        },
                      ),
                      Text('$qty'),
                      IconButton(
                        icon: const Icon(Icons.add, size: 18),
                        onPressed: () {
                          setState(() => _selectedSnacks[snack] = qty + 1);
                        },
                      ),
                    ],
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final orderPreview = _selectedSnacks.entries
        .map((e) => "${_snackImages[e.key] ?? ''} ${e.key}×${e.value}")
        .join(', ');

    return Scaffold(
      appBar: AppBar(
        title: const Text("Lunchify - Snacks"),
        backgroundColor: Colors.teal.shade700,
        elevation: 0,
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
            child: ListView(
              children: [
                const Text("🗓️ Weekly Snack Chart",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                _buildWeeklyChart(),
                const SizedBox(height: 20),

                const Text("🍴 Select Snacks",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                const SizedBox(height: 10),
                _buildSnackGrid(),

                const SizedBox(height: 20),
                TextFormField(
                  controller: _roomController,
                  decoration: const InputDecoration(
                    labelText: '🏠 Room Number',
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 20),
                ElevatedButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text("Add New Snack"),
                  onPressed: _showAddSnackDialog,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orangeAccent),
                ),

                const SizedBox(height: 30),
                const Divider(thickness: 2),
                const Text("📜 Your Orders",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),

                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('snackOrders')
                      .where('employeeId', isEqualTo: widget.employeeId)
                      .orderBy('timestamp', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Text("No snack orders yet.");
                    }

                    return Column(
                      children: snapshot.data!.docs.map((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        return ListTile(
                          leading: const Icon(Icons.fastfood),
                          title: Text("${data['snack']} × ${data['quantity']}"),
                          subtitle: Text("Room: ${data['room']}"),
                          trailing: Text(
                            (data['timestamp'] as Timestamp)
                                .toDate()
                                .toLocal()
                                .toString()
                                .split('.')[0],
                            style: const TextStyle(fontSize: 12),
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
              ],
            ),
          ),

          // Place Order Button
          if (_selectedSnacks.isNotEmpty)
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.check_circle_outline),
                label: Text("Place Order: $orderPreview"),
                onPressed: _submitOrder,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 16),
                ),
              ),
            ),

          // Success Message
          if (_orderPlaced)
            Positioned(
              bottom: 80,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.green.shade600,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Text(
                    "✅ Order Placed Successfully!",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
