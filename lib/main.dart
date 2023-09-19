import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('YouTube Video Info'),
        ),
        body: Center(
          child: ElevatedButton(
            onPressed: handlePress,
            child: const Text('Fetch Video Info'),
          ),
        ),
      ),
    );
  }

  Future<void> handlePress() async {
    
  }


}


