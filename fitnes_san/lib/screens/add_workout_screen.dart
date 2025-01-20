import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddWorkoutScreen extends StatelessWidget {
  final TextEditingController typeController = TextEditingController();
  final TextEditingController durationController = TextEditingController();
  final TextEditingController caloriesController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Dodaj trening')),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: typeController,
              decoration: InputDecoration(labelText: 'Rodzaj ćwiczenia'),
            ),
            TextField(
              controller: durationController,
              decoration: InputDecoration(labelText: 'Czas trwania (min)'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: caloriesController,
              decoration: InputDecoration(labelText: 'Spalone kalorie'),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Dodanie treningu do Firestore
                FirebaseFirestore.instance.collection('workouts').add({
                  'type': typeController.text,
                  'duration': int.parse(durationController.text),
                  'calories': int.parse(caloriesController.text),
                  'timestamp': Timestamp.now(),
                });

                // Powrót na poprzedni ekran
                Navigator.pop(context);
              },
              child: Text('Dodaj'),
            ),
          ],
        ),
      ),
    );
  }
}
