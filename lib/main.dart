import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:intl/intl.dart';

void main() {
  runApp(DayPlannerApp());
}

class DayPlannerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Day Planner',
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.pink,
        scaffoldBackgroundColor: Color(0xFFFFF0F5),
        textTheme: TextTheme(
          titleLarge: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.deepPurple),
          bodyMedium: TextStyle(fontSize: 16, color: Colors.purple),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.pinkAccent,
          foregroundColor: Colors.white,
          titleTextStyle: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: Colors.pink,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide(color: Colors.pinkAccent),
          ),
        ),
      ),
      home: DayPlannerHome(),
    );
  }
}

class Task {
  final String title;
  bool isDone;
  Task({required this.title, this.isDone = false});

  Map<String, dynamic> toJson() => {'title': title, 'isDone': isDone};
  factory Task.fromJson(Map<String, dynamic> json) => Task(title: json['title'], isDone: json['isDone']);
}

class DayPlannerHome extends StatefulWidget {
  @override
  _DayPlannerHomeState createState() => _DayPlannerHomeState();
}

class _DayPlannerHomeState extends State<DayPlannerHome> {
  List<Task> tasks = [];
  TextEditingController taskController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadTasks();
  }

  void addTask(String title) async {
    if (title.trim().isEmpty) return;
    setState(() {
      tasks.add(Task(title: title));
    });
    taskController.clear();
    await saveTasks();
  }

  void deleteTask(int index) async {
    setState(() {
      tasks.removeAt(index);
    });
    await saveTasks();
  }

  void toggleTask(int index) async {
    setState(() {
      tasks[index].isDone = !tasks[index].isDone;
    });
    await saveTasks();
  }

  Future<void> saveTasks() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> taskList = tasks.map((task) => jsonEncode(task.toJson())).toList();
    await prefs.setStringList('tasks', taskList);
  }

  Future<void> loadTasks() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? taskList = prefs.getStringList('tasks');
    if (taskList != null) {
      setState(() {
        tasks = taskList.map((task) => Task.fromJson(jsonDecode(task))).toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    String dateTime = DateFormat('EEE, MMM d, yyyy - h:mm a').format(DateTime.now());

    return Scaffold(
      appBar: AppBar(
        title: Text("Day Planner", style: Theme.of(context).textTheme.titleLarge),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Today: $dateTime", style: Theme.of(context).textTheme.bodyMedium),
            SizedBox(height: 16),
            TextField(
              controller: taskController,
              decoration: InputDecoration(
                labelText: 'Add a new task',
                suffixIcon: IconButton(
                  icon: Icon(Icons.add_circle, color: Colors.purpleAccent),
                  onPressed: () => addTask(taskController.text),
                ),
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: tasks.isEmpty
                  ? Center(child: Text('No tasks yet! 📝'))
                  : ListView.builder(
                      itemCount: tasks.length,
                      itemBuilder: (context, index) {
                        return Card(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          color: tasks[index].isDone ? Color(0xFFFFDDEE) : Colors.white,
                          elevation: 3,
                          margin: EdgeInsets.symmetric(vertical: 6),
                          child: ListTile(
                            leading: IconButton(
                              icon: Icon(
                                tasks[index].isDone ? Icons.check_circle : Icons.radio_button_unchecked,
                                color: tasks[index].isDone ? Colors.purple : Colors.pinkAccent,
                              ),
                              onPressed: () => toggleTask(index),
                            ),
                            title: Text(
                              tasks[index].title,
                              style: TextStyle(
                                decoration: tasks[index].isDone ? TextDecoration.lineThrough : TextDecoration.none,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            trailing: IconButton(
                              icon: Icon(Icons.delete_outline, color: Colors.pink),
                              onPressed: () => deleteTask(index),
                            ),
                          ),
                        );
                      },
                    ),
            )
          ],
        ),
      ),
    );
  }
}
