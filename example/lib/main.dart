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
      navigatorKey: StateFlow.navigatorKey,
      onGenerateRoute: (settings) => StateFlow.onGenerateRoute(settings),
      theme: ThemeData(primarySwatch: Colors.blue),
      routes: AppRoutes.routes,
    );
  }
}

class AppRoutes {
  static const String home = '/';
  static const String second = '/second';

  static final routes = {
    home: (context) => TestApp(),
    second: (context) => SecondScreen(),
  };
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Home')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
                child: Text('Go to Second Screen'),
                onPressed: () => StateFlow.to('/second')),
            ElevatedButton(
              child: Text('Replace with Third Screen'),
              onPressed: () => StateFlow.off('/third'),
            ),
            ElevatedButton(
              child: Text('Go to Fourth Screen and clear history'),
              onPressed: () => StateFlow.offAll('/fourth'),
            ),
            ElevatedButton(
              child: Text('Go to Fifth Screen and clear history'),
              onPressed: () => StateFlow.offAll('/fifth'),
            ),
            ElevatedButton(
              child: Text('Print Current Route'),
              onPressed: () => print(StateFlow.currentRoute()),
            ),
            ElevatedButton(
              child: Text('Print Navigation History'),
              onPressed: () => print(StateFlow.getHistory()),
            ),
          ],
        ),
      ),
    );
  }
}

class SecondScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Second Screen')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              child: Text('Go Back'),
              onPressed: () => StateFlow.back(),
            ),
            ElevatedButton(
              child: Text('Can Pop?'),
              onPressed: () => print('Can pop: ${StateFlow.canPop()}'),
            ),
            ElevatedButton(
              child: Text('Maybe Pop'),
              onPressed: () async {
                bool didPop = await StateFlow.maybePop();
                print('Did pop: $didPop');
              },
            ),
          ],
        ),
      ),
    );
  }
}

class Hi extends StateFlowWidget {
  const Hi({super.key}) : super();
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

// THIRD, FOURTH, FIFTH SCREENS
class ThirdScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Third Screen')),
      body: Center(child: Text('Third Screen')),
    );
  }
}

class FourthScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Fourth Screen')),
      body: Center(child: Text('Fourth Screen')),
    );
  }
}

class FifthScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Fifth Screen')),
      body: Center(child: Text('Fifth Screen')),
    );
  }
}

class CounterController extends StateFlowController {
  late final StateValue<int> count;
  late final StateValue<String> status;
  int count23 = 2;


add (){
  count23++;
}
  @override
  void onInit() {
    count = take(2);
    print('CounterController initialized with count: ${count.value}');
    status = take('Zero');
    print('CounterController status initialized: ${status.value}');
  }

  void increment() {
    count.value++;
    updateStatus();
  }

  void decrement() {
    count.value--;
    updateStatus();
  }

  void updateStatus() {
    status.value = count.value == 0 ? 'Zero' : 'Non-zero';
  }

  @override
  void onDispose() {
    print('Disposing CounterController');
    print('Final count: ${count.value}');
    print('Final status: ${status.value}');
    super.onDispose();
  }
}

class TodoController extends StateFlowController {
  @override
  void onInit() {}
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
  const TestApp({super.key}) : super();
  @override
  void onInit(context) {
    print('TestApp onInit');
  }

  @override
  void onDispose() {
    print('TestApp onDispose');
  }

  @override
  Widget build(BuildContext context) {
    final todoController = listen(TodoController);
    final CounterController counterController = listen(CounterController);

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          counterController.add();
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
                if (data.isEmpty) {
                  return Text('No todos');
                }
                return Expanded(
                  child: ListView.builder(
                    itemCount: data.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(data[index].title),
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
              value: counterController.count,
              builder: (count) {
                return Text(count.toString());
                
                
              },
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class TestAppNew extends StatelessWidget {
  const TestAppNew({super.key});

  @override
  Widget build(BuildContext context) {
    final animationController = takeAnimationController();
    return const Placeholder();
  }
}
