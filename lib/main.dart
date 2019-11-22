import 'package:custompaint/cube.dart';
import 'package:custompaint/spaceship.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

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
  double fNear = 10;
  double fFar = 1000.0;
  double fFov = 90.0;
  double fFovRad;
  double fAspectRatio;
  Matrix4 matProj;

  @override
  void initState() {
    super.initState();
    fFovRad = 1.0 / math.tan(fFov * 0.5 / 180.0 * math.pi);
  }

  @override
  Widget build(BuildContext context) {
    fAspectRatio =
        MediaQuery.of(context).size.height / MediaQuery.of(context).size.width;
    matProj = Matrix4.zero()
      ..setEntry(0, 0, fAspectRatio * fFovRad)
      ..setEntry(1, 1, fFovRad)
      ..setEntry(2, 2, fFar / (fFar - fNear))
      ..setEntry(3, 2, (-fFar * fNear) / (fFar - fNear))
      ..setEntry(2, 3, 1.0);

    return Scaffold(
      body: Center(
        child: AspectRatio(
          aspectRatio: 1 / fAspectRatio,
          child: SpaceShip(matProj),
        ),
      ),
    );
  }
}
