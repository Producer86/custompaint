import 'package:custompaint/geom.dart';
import 'package:custompaint/mesh_painter.dart';
import 'package:flutter/material.dart';

class Cube extends StatefulWidget {
  final Matrix4 matProj;

  Cube(this.matProj);

  @override
  _CubeState createState() => _CubeState();
}

class _CubeState extends State<Cube> with SingleTickerProviderStateMixin {
  final mesh = Mesh([
    // SOUTH
    Triangle(Vec3d(0, 0, 0), Vec3d(0, 1, 0), Vec3d(1, 1, 0)),
    Triangle(Vec3d(0, 0, 0), Vec3d(1, 1, 0), Vec3d(1, 0, 0)),
    // EAST
    Triangle(Vec3d(1, 0, 0), Vec3d(1, 1, 0), Vec3d(1, 1, 1)),
    Triangle(Vec3d(1, 0, 0), Vec3d(1, 1, 1), Vec3d(1, 0, 1)),
    // NORTH
    Triangle(Vec3d(1, 0, 1), Vec3d(1, 1, 1), Vec3d(0, 1, 1)),
    Triangle(Vec3d(1, 0, 1), Vec3d(0, 1, 1), Vec3d(0, 0, 1)),
    // WEST
    Triangle(Vec3d(0, 0, 1), Vec3d(0, 1, 1), Vec3d(0, 1, 0)),
    Triangle(Vec3d(0, 0, 1), Vec3d(0, 1, 0), Vec3d(0, 0, 0)),
    // TOP
    Triangle(Vec3d(0, 1, 0), Vec3d(0, 1, 1), Vec3d(1, 1, 1)),
    Triangle(Vec3d(0, 1, 0), Vec3d(1, 1, 1), Vec3d(1, 1, 0)),
    // BOTTOM
    Triangle(Vec3d(1, 0, 1), Vec3d(0, 0, 1), Vec3d(0, 0, 0)),
    Triangle(Vec3d(1, 0, 1), Vec3d(0, 0, 0), Vec3d(1, 0, 0)),
  ]);
  Animation<double> animation;
  AnimationController controller;

  @override
  void initState() {
    super.initState();
    controller =
        AnimationController(duration: Duration(minutes: 1), vsync: this);
    animation = Tween<double>(begin: 0, end: 75).animate(controller)
      ..addListener(() {
        setState(() {});
      });
    controller.forward();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: MeshPainter(mesh, widget.matProj, animation.value),
    );
  }
}
