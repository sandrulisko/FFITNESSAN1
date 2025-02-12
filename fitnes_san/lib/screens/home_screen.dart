import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'add_workout_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final CollectionReference workouts =
      FirebaseFirestore.instance.collection('workouts');

  Future<Map<String, int>> _getWorkoutStats(DateTime startDate) async {
    try {
      QuerySnapshot snapshot = await workouts
          .where('timestamp', isGreaterThanOrEqualTo: startDate)
          .get();

      int totalWorkouts = snapshot.docs.length;
      int totalCalories = snapshot.docs.fold(0, (sum, doc) {
        return sum + (doc['calories'] as int? ?? 0);
      });

      debugPrint('🔥 Pobieranie danych od $startDate → Treningi: $totalWorkouts, Kalorie: $totalCalories');

      return {'workouts': totalWorkouts, 'calories': totalCalories};
    } catch (e) {
      debugPrint('❌ Błąd pobierania danych: $e');
      return {'workouts': 0, 'calories': 0};
    }
  }

  DateTime get _startOfWeek => DateTime.now().subtract(Duration(days: DateTime.now().weekday - 1));
  DateTime get _startOfMonth => DateTime(DateTime.now().year, DateTime.now().month, 1);
  DateTime get _startOfYear => DateTime(DateTime.now().year, 1, 1);

  Widget _buildPieChart(String title, int value) {
    return Column(
      children: [
        Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        SizedBox(height: 10),
        value > 0
            ? SizedBox(
                height: 150,
                child: PieChart(
                  PieChartData(
                    sections: [
                      PieChartSectionData(
                        value: value.toDouble(),
                        title: '$value',
                        color: Colors.blue,
                        radius: 50,
                      ),
                    ],
                    centerSpaceRadius: 40,
                  ),
                ),
              )
            : Center(child: Text('Brak danych', style: TextStyle(color: Colors.grey))),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Twoje Treningi')),
      body: FutureBuilder(
        future: Future.wait([
          _getWorkoutStats(_startOfWeek),
          _getWorkoutStats(_startOfMonth),
          _getWorkoutStats(_startOfYear),
        ]),
        builder: (context, AsyncSnapshot<List<Map<String, int>>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.hasError) {
            return Center(child: Text('Błąd ładowania danych.'));
          }

          var weeklyStats = snapshot.data![0];
          var monthlyStats = snapshot.data![1];
          var yearlyStats = snapshot.data![2];

          return ListView(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildPieChart("Treningi (Tydzień)", weeklyStats['workouts']!),
                  _buildPieChart("Kalorie (Tydzień)", weeklyStats['calories']!),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildPieChart("Treningi (Miesiąc)", monthlyStats['workouts']!),
                  _buildPieChart("Kalorie (Miesiąc)", monthlyStats['calories']!),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildPieChart("Treningi (Rok)", yearlyStats['workouts']!),
                  _buildPieChart("Kalorie (Rok)", yearlyStats['calories']!),
                ],
              ),
              SizedBox(height: 20),
              StreamBuilder<QuerySnapshot>(
                stream: workouts.orderBy('timestamp', descending: true).snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(child: Text('Brak zapisanych treningów.'));
                  }

                  return ListView(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    children: snapshot.data!.docs.map((doc) {
                      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
                      return Card(
                        margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                        child: ListTile(
                          title: Text(data['type']),
                          subtitle: Text(
                            'Czas: ${data['duration']} min, Kalorie: ${data['calories']} kcal',
                          ),
                          trailing: IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              FirebaseFirestore.instance.collection('workouts').doc(doc.id).delete();
                            },
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ],
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
}

