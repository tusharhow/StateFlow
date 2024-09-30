import 'package:flutter/material.dart';
import 'package:state_flow/state_flow.dart';


void main() {
  runApp(
    StateFlowApp(
      controllers: [
        () => CounterController(),
      ],
      child: MyApp(),
    ),
  );
}

class CounterController extends StateFlowController {
  final counter = take(0);

  void increment() {
    counter.value++;
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});
  @override
  Widget build(BuildContext context) {
    final counterController = context.listen<CounterController>();
    return Scaffold(
      appBar: AppBar(
        title: Text('Counter'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            StateValueBuilder(value: counterController.counter, builder: (ctx, value) => Text(value.toString())),
            ElevatedButton(
              onPressed: counterController.increment,
              child: Text('Increment'),
            ),
          ],
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(),
    );
  }
}
