// import 'package:custompaint/models/cube.dart';
// import 'package:custompaint/models/spaceship.dart';
// import 'package:custompaint/models/teapot.dart';
import 'package:custompaint/models/axis.dart';
import 'package:flutter/material.dart';
import 'package:custompaint/vec_utils.dart';

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
    final matProj = makeProjection(90, fAspectRatio, 0.1, 1000);

    return Scaffold(
      body: Center(
        child: AspectRatio(
          aspectRatio: 1 / fAspectRatio,
          child: Teapot(matProj),
        ),
      ),
    );
  }
}
