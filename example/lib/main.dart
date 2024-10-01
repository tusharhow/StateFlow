import 'package:flutter/material.dart';
import 'package:state_flow/state_flow.dart';
import 'dart:convert';

void main() {
  runApp(StateFlowApp(
    controllers: [
      () => TodoController(),
      () => CounterController(),
    ],
    child: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'StateFlow Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: TestApp(),
    );
  }
}

class CounterController extends StateFlowController {
  final counter = take(0);

  void increment() {
    counter.value++;
  }

  final toggleSwitch = take(false);

  void toggleSwitchhhhhh() {
    toggleSwitch.value = !toggleSwitch.value;
  }
}

class TodoController extends StateFlowController {
  final todos = take<List<Todo>>([]);
  final StateFlowClient _client =
      StateFlowClient(baseUrl: 'https://jsonplaceholder.typicode.com');

  Future<List<Todo>> fetchTodos() async {
    todos.setLoading();
    try {
      final response = await _client.sendRequest('/todos', HttpMethod.GET);
      if (response.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(response.body);
        final todoList = jsonData.map((json) => Todo.fromJson(json)).toList();
        todos.setLoaded(todoList);
        return todos.value;
      } else {
        todos.setError('Failed to load todos');
        return [];
      }
    } catch (e) {
      todos.setError(e);
      todos.stopLoading();
      rethrow;
    }
  }
}

class Todo {
  final int id;
  final String title;
  final bool completed;

  Todo.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        title = json['title'],
        completed = json['completed'];
}

 
class TestApp extends StateFlowWidget {
  TestApp({super.key}) : super(
    onInit: (context) {
      print('Initializing TestApp');
      
    },
    onDispose: () {
      print('Disposing TestApp');
    },
  );
  @override
  Widget build(BuildContext context) {
    final todoController = listen(TodoController);
    final counterController = listen(CounterController);
    
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          counterController.increment();
          print('Pressed');
        },
        child: Icon(Icons.refresh),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            WidgetStateValueBuilder<List<Todo>>(
              state: todoController.todos,
              dataBuilder: (data) {
                if (data == null || data.isEmpty) {
                  return Text('No todos');
                }
                return Expanded(
                  child: ListView.builder(
                    itemCount: data.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(data[index].title),
                        leading: Checkbox(
                          value: data[index].completed,
                          onChanged: (_) {
                          
                          }, // Add toggle functionality if needed
                        ),
                      );
                    },
                  ),
                );
              },
              errorBuilder: (error) => Text('Error: ${error.toString()}'),
              loadingBuilder: () => CircularProgressIndicator(),
            ),
            SizedBox(height: 20),
            StateValueBuilder(
              value: counterController.counter,
              builder: (value) => Text('Counter: $value', style: TextStyle(fontSize: 18)),
            ),
            SizedBox(height: 20),
            
          ],
        ),
      ),
    );
  }
}
