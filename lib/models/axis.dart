import 'package:custompaint/geom.dart';
import 'package:custompaint/mesh_painter.dart';
import 'package:flutter/services.dart';
import 'package:vector_math/vector_math_64.dart';
import 'package:flutter/material.dart';

class Teapot extends StatefulWidget {
  final Matrix4 matProj;

  Teapot(this.matProj);

  @override
  _TeapotState createState() => _TeapotState();
}

class _TeapotState extends State<Teapot> with SingleTickerProviderStateMixin {
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
    rootBundle.loadString('assets/axis.obj').then((data) {
      Mesh.fromObjText(data).then((m) {
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
    return GestureDetector(
      child: CustomPaint(
        painter: MeshPainter(mesh, widget.matProj, animation.value),
      ),
    );
  }
}
