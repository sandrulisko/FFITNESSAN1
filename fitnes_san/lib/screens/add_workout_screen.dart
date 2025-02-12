import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddWorkoutScreen extends StatefulWidget {
  @override
  _AddWorkoutScreenState createState() => _AddWorkoutScreenState();
}

class _AddWorkoutScreenState extends State<AddWorkoutScreen> {
  final TextEditingController durationController = TextEditingController();
  String selectedWorkout = 'Bieg';

  final Map<String, double> caloriesPerMinute = {
    'Bieg': 10.0,
    'Bieg na bieżni': 9.5,
    'Spacer': 4.0,
    'Wspinaczka': 8.0,
    'Jazda na rowerze': 7.0,
    'Jazda na łyżwach': 6.5,
    'Jazda na rolkach': 6.0,
    'Joga': 3.0,
    'Squash': 12.0,
  };

  void _addWorkout() {
    if (durationController.text.isEmpty || int.tryParse(durationController.text) == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Wpisz poprawny czas trwania!')),
      );
      return;
    }

    int duration = int.parse(durationController.text);
    double calories = duration * (caloriesPerMinute[selectedWorkout] ?? 0);

    FirebaseFirestore.instance.collection('workouts').add({
      'type': selectedWorkout,
      'duration': duration,
      'calories': calories.toInt(),
      'timestamp': Timestamp.now(),
    });

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Dodaj trening')),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              value: selectedWorkout,
              items: caloriesPerMinute.keys.map((String workout) {
                return DropdownMenuItem<String>(
                  value: workout,
                  child: Text(workout),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedWorkout = value!;
                });
              },
              decoration: InputDecoration(labelText: 'Rodzaj ćwiczenia'),
            ),
            TextField(
              controller: durationController,
              decoration: InputDecoration(labelText: 'Czas trwania (min)'),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _addWorkout,
              child: Text('Dodaj'),
            ),
          ],
        ),
      ),
    );
  }
}

