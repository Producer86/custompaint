import 'package:custompaint/geom.dart';
import 'package:custompaint/mesh_painter.dart';
import 'package:flutter/services.dart';
import 'package:vector_math/vector_math_64.dart';
import 'package:flutter/material.dart';

class SpaceShip extends StatefulWidget {
  final Matrix4 matProj;

  SpaceShip(this.matProj);

  @override
  _SpaceShipState createState() => _SpaceShipState();
}

class _SpaceShipState extends State<SpaceShip>
    with SingleTickerProviderStateMixin {
  Mesh mesh;
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
    rootBundle.loadString('assets/VideoShip.obj').then((data) {
      Mesh.fromFile(data).then((m) {
        setState(() {
          mesh = m;
        });
        controller.forward();
      });
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (mesh == null) return Container();
    return CustomPaint(
      painter: MeshPainter(mesh, widget.matProj, animation.value),
    );
  }
}
