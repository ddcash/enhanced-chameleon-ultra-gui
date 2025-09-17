import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Enhanced Chameleon Ultra GUI',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Enhanced Chameleon Ultra GUI'),
        ),
        body: const Center(
          child: Text('Hello World'),
        ),
      ),
    );
  }
}