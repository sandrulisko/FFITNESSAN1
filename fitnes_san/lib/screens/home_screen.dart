import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'add_workout_screen.dart';

class HomeScreen extends StatelessWidget {
  final CollectionReference workouts =
      FirebaseFirestore.instance.collection('workouts');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Twoje Treningi')),
      body: StreamBuilder<QuerySnapshot>(
        stream: workouts.orderBy('timestamp', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('Brak zapisanych treningów.'));
          }

          return ListView(
            children: snapshot.data!.docs.map((doc) {
              Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
              return Card(
                margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: ListTile(
                  title: Text(data['type']),
                  subtitle: Text(
                      'Czas: ${data['duration']} min, Kalorie: ${data['calories']} kcal'),
                  trailing: IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteWorkout(doc.id),
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => AddWorkoutScreen()),
          );
        },
        child: Icon(Icons.add),
        tooltip: 'Dodaj trening',
      ),
    );
  }

  void _deleteWorkout(String id) {
    FirebaseFirestore.instance.collection('workouts').doc(id).delete();
  }
}
