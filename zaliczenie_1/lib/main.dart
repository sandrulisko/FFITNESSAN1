import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Hive.initFlutter();
  Hive.registerAdapter(TaskAdapter());
  await Hive.openBox<Task>('tasks');

  runApp(MyApp());
}

class User {
  String name;

  User({required this.name});
}

class Task {
  late String name;
  String description;
  DateTime createdAt;
  bool isCompleted;
  Key? key;

  Task({
    required this.name,
    required this.description,
    required this.createdAt,
    required this.isCompleted,
  });
}

class TaskAdapter extends TypeAdapter<Task> {
  @override
  final int typeId = 0;

  @override
  Task read(BinaryReader reader) {
    return Task(
      name: reader.read(),
      description: reader.read(),
      createdAt: DateTime.parse(reader.read()),
      isCompleted: reader.read(),
    );
  }

  @override
  void write(BinaryWriter writer, Task obj) {
    writer.write(obj.name);
    writer.write(obj.description);
    writer.write(obj.createdAt.toIso8601String());
    writer.write(obj.isCompleted);
  }
}

class DatabaseHelper {
  Box<Task> tasksBox = Hive.box<Task>('tasks');

  Future<void> insertTask(Task task) async {
    await tasksBox.add(task);
  }

  Future<List<Task>> getTasks() async {
    return tasksBox.values.toList();
  }

  Future<void> updateTask(Task oldTask, Task newTask) async {
    int taskIndex = tasksBox.keys.toList().indexOf(oldTask.key);
    await tasksBox.putAt(taskIndex, newTask);
  }

  Future<void> deleteTask(Task task) async {
    int taskIndex = tasksBox.keys.toList().indexOf(task.key);
    await tasksBox.deleteAt(taskIndex);
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: FutureBuilder(
        future: SharedPreferences.getInstance(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data!.containsKey('user_name')) {
              return SecondScreen(
                  user: User(name: snapshot.data!.getString('user_name')!));
            } else {
              return FirstScreen();
            }
          } else {
            return CircularProgressIndicator();
          }
        },
      ),
    );
  }
}

class FirstScreen extends StatefulWidget {
  @override
  _FirstScreenState createState() => _FirstScreenState();
}

class _FirstScreenState extends State<FirstScreen> {
  late TextEditingController _nameController;
  late bool _isNameValid;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _isNameValid = true;
  }

  Future<void> _saveName() async {
    String name = _nameController.text.trim();

    if (name.length >= 3) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('user_name', name);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => SecondScreen(user: User(name: name))),
      );
    } else {
      setState(() {
        _isNameValid = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Cześć')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Wprowadź swoje imię:',
                errorText:
                    _isNameValid ? null : 'Imię musi zawierać minimum 3 znaki',
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isNameValid ? _saveName : null,
              child: Text('Zapisz'),
            ),
          ],
        ),
      ),
    );
  }
}

class SecondScreen extends StatefulWidget {
  final User user;

  SecondScreen({required this.user});

  @override
  _SecondScreenState createState() => _SecondScreenState();
}

class _SecondScreenState extends State<SecondScreen> {
  late DatabaseHelper _databaseHelper;
  late List<Task> _tasks;

  @override
  void initState() {
    super.initState();
    _databaseHelper = DatabaseHelper();
    _tasks = [];
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    _tasks = await _databaseHelper.getTasks();
    setState(() {});
  }

  Future<void> _markTaskAsCompleted(Task task) async {
    Task updatedTask = Task(
      name: task.name,
      description: task.description,
      createdAt: task.createdAt,
      isCompleted: !task.isCompleted,
    );

    await _databaseHelper.updateTask(task, updatedTask);
    _loadTasks();
  }

  Future<void> _deleteTask(Task task) async {
    await _databaseHelper.deleteTask(task);
    _loadTasks();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Witaj, ${widget.user.name}!')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ThirdScreen()),
                ).then((_) => _loadTasks());
              },
              child: Text('Dodaj zadanie'),
            ),
            SizedBox(height: 16),
            Text('Zadania:'),
            Expanded(
              child: ListView.builder(
                itemCount: _tasks.length,
                itemBuilder: (context, index) {
                  Task task = _tasks[index];
                  return Dismissible(
                    key: Key(task.createdAt.toString()),
                    background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      child: Icon(
                        Icons.delete,
                        color: Colors.white,
                      ),
                    ),
                    onDismissed: (direction) async {
                      await _deleteTask(task);
                      setState(() {
                        _tasks.removeAt(index);
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Zadanie usunięte'),
                        ),
                      );
                    },
                    child: ListTile(
                      title: Text(task.name),
                      subtitle: Text(
                        'Utworzone: ${task.createdAt.toLocal()}',
                        style: TextStyle(fontSize: 12),
                      ),
                      trailing: Checkbox(
                        value: task.isCompleted,
                        onChanged: (_) => _markTaskAsCompleted(task),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ThirdScreen extends StatefulWidget {
  @override
  _ThirdScreenState createState() => _ThirdScreenState();
}

class _ThirdScreenState extends State<ThirdScreen> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late bool _isNameValid;
  late DatabaseHelper _databaseHelper;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _descriptionController = TextEditingController();
    _isNameValid = true;
    _databaseHelper = DatabaseHelper();
  }

  Future<void> _saveTask() async {
    String name = _nameController.text.trim();

    if (name.isNotEmpty) {
      Task newTask = Task(
        name: name,
        description: _descriptionController.text.trim(),
        createdAt: DateTime.now(),
        isCompleted: false,
      );

      await _databaseHelper.insertTask(newTask);
      Navigator.pop(context); // Wróć do poprzedniego ekranu
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Dodaj nowe zadanie')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Nazwij zadanie',
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Dodaj opis',
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _saveTask,
              child: Text('Zapisz zadanie'),
            ),
          ],
        ),
      ),
    );
  }
}
