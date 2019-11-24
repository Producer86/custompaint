import 'package:custompaint/scene.dart';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    final fAspectRatio =
        MediaQuery.of(context).size.height / MediaQuery.of(context).size.width;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: AspectRatio(
            aspectRatio: 1 / fAspectRatio,
            child: Scene(
              aspectRatio: fAspectRatio,
              worldData: 'assets/mountains.obj',
            ),
          ),
        ),
      ),
    );
  }
}
