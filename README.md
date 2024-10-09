# StateFlow:  State Management

StateFlow provides a simple and efficient way to manage state in your Flutter applications. This guide will walk you through the core concepts and usage of StateFlow's state management features.

<img src="https://i.imghippo.com/files/16zy61727790035.png">

## Core Concepts

StateFlow's state management is built around these key concepts:

- **StateFlowController**: A base class for creating controllers that manage application logic and state.
- **take()**: A reactive value holder that notifies listeners when its value changes.
- **StateFlowApp**: A widget that sets up the StateFlow environment and dependency injection.
- **StateValueBuilder**: A widget that rebuilds when specified states change.


## Setting Up
Add the dependency to your `pubspec.yaml` file:

~~~yaml
dependencies:
  state_flow: ^0.0.8
~~~

Wrap your app with `StateFlowApp` to enable the StateFlow functionality. Make sure to pass the controllers you want to use in the `controllers` parameter.

~~~dart
void main() {
  runApp(StateFlowApp(
    controllers: [
      () => CounterController(),
    ],
    child: MyApp(),
  ));
}
~~~

## Creating Controllers

Controllers are the core of StateFlow's state management. They manage application logic and state, and can be used to create reactive UIs.

To create a controller, extend `StateFlowController`:

#### Declare Variables

```dart
  // int
  final counter = take(0);
  // String
  final name = take('');
  // bool
  final isLoading = take(false);
  // List
  final todos = take([]);
  // Map
  final user = take({});
  // Object
  final user = take(User());

```
 

```dart
class CounterController extends StateFlowController {
  final counter = take(0);

  void increment() {
    counter.value++;
  }
}
```

## Using StateValueBuilder

```dart
final counterController = listen(CounterController)

StateValueBuilder(
  value: counterController.counter,
  builder: (value) => Text('Counter: $value'),
),
```


# Networking

StateFlow provides networking features using the `StateFlowClient`.

### Use the StateFlowClient
At first you need to create a StateFlowClient. This is used to send requests to the server.

```dart
final client = StateFlowClient(baseUrl: 'example.com');

final response = await client.sendRequest('/todos', HttpMethod.GET);
```

### HttpMethod
You use these methods to send requests to the server. 

```dart
enum HttpMethod {
  GET,
  POST,
  PUT,
  DELETE,
}
```

## Creating a Network Controller

To create a network controller, extend `StateFlowController`: 
If you want to use the Controller to fetch data or or perform any kind of logic then you can extend `StateFlowController` with your normal controller.

```dart
class TodoController extends StateFlowController {
  final todos = take<List<Todo>>([]);
  // Base url for the api
  final StateFlowClient _client =
      StateFlowClient(baseUrl: 'example.com');

  Future<List<Todo>> fetchTodos() async {
    // Set the state to loading
    todos.setLoading();
    try {
      final response = await _client.sendRequest('/todos', HttpMethod.GET);
      if (response.statusCode == 200) {
        // Set the state to loaded
        final List<dynamic> jsonData = jsonDecode(response.body);
        final todoList = jsonData.map((json) => Todo.fromJson(json)).toList();
        // Set the state to loaded
        todos.setLoaded(todoList);
        return todos.value;
      } else {
        // Set the state to error
        todos.setError('Failed to load todos');
        return [];
      }
    } catch (e) {
      // Set the state to error
      todos.setError(e);
      todos.stopLoading();
      rethrow;
    }
  }
}
```

## Building Reactive UI

You can use the `listen` function to listen to the state of the controller. If you want to build a widget that rebuilds when the state changes, you can use the `WidgetStateValueBuilder` widget.
```dart
final todoController = listen(TodoController);

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
```


You can pass multiple values to the `StateValueBuilder` by using the `StateValueBuilder`.

```dart
    StateValueBuilder(
              values: [
                counterController.count,
                false,
                'Hello',
                false,
              ],
              builder: (values) {
                var [count, isActive, greeting, otherValue] = values;
                
                return Column(
                  children: [
                    Text('Counter: $count'),
                    Icon(isActive ? Icons.check : Icons.close),
                    Text(greeting),
                    Text('Other value: $otherValue'),
                  ],
                );
              },
            ),
  ```

### Animation Controller
If you want to use the animation controller without StateFulWidget, you can use the `takeAnimationController` function.
```dart
class TestApp extends StatelessWidget {
  const TestApp({super.key});

  @override
  Widget build(BuildContext context) {
    final animationController = takeAnimationController();
    return const Placeholder();
  }
}
```

### StateFlowWidget
If you want to use initState and disposeState to be called, you can use StateFlowWidget.

```dart
class TestApp extends StateFlowWidget {
  TestApp({super.key}) : super();
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
    return const Placeholder();
  }
}
```

### StateFlow Navigation

For enabling navigation in your app, you can use the `navigatorKey: StateFlow.navigatorKey` in your MaterialApp.

```dart
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'StateFlow Demo',
      navigatorKey: StateFlow.navigatorKey,
      theme: ThemeData(primarySwatch: Colors.blue),
    );
  }
}
```

Use the `StateFlow.to` method to navigate to a new screen.

```dart
StateFlow.to(DetailScreen());
```

For going back to the previous screen, you can use the `StateFlow.back` method.

```dart
StateFlow.back();
```

```dart
StateFlow.off(DetailScreen());
StateFlow.offAll(DetailScreen());
StateFlow.maybePop();
StateFlow.currentRoute();
StateFlow.getHistory();
 onGenerateRoute: (settings) => StateFlow.onGenerateRoute(settings),
```

#### You can create your App Routes like this

```dart
class AppRoutes {
  static const String home = '/';
  static const String second = '/second';

  static final routes = {
    home: (context) => HomeScreen(),
    second: (context) => SecondScreen(),
  };
}
```

Modify the MaterialApp like this use `onGenerateRoute: (settings) => StateFlow.onGenerateRoute(settings)`, ` routes: AppRoutes.routes` and `navigatorKey: StateFlow.navigatorKey`

```dart
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
```

Now You can use with your routes

```dart
onPressed: () => StateFlow.to('/second')
onPressed: () => StateFlow.to(AppRoutes.second)
```






