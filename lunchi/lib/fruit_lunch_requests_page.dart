import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FruitLunchRequestsPage extends StatelessWidget {
  const FruitLunchRequestsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange[50],
      appBar: AppBar(
        title: const Text("Fruit Lunch Requests"),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('fruit_lunch_requests')
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(
                child: Text("No fruit lunch requests yet.",
                    style: TextStyle(fontSize: 18)),
              );
            }

            final requests = snapshot.data!.docs;

            return ListView.builder(
              itemCount: requests.length,
              itemBuilder: (context, index) {
                final data = requests[index].data() as Map<String, dynamic>;
                return Card(
                  elevation: 4,
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: const Icon(Icons.person, color: Colors.green),
                    title: Text("Employee ID: ${data['employeeId']}"),
                    subtitle: Text("Room No: ${data['room']}"),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

