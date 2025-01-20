class Workout {
  String id;
  String type;
  int duration; // w minutach
  int calories;

  Workout({
    required this.id,
    required this.type,
    required this.duration,
    required this.calories,
  });

  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'duration': duration,
      'calories': calories,
    };
  }
}
