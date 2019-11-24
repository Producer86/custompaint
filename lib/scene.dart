import 'package:custompaint/camera.dart';
import 'package:custompaint/geom.dart';
import 'package:custompaint/scene_painter.dart';
import 'package:custompaint/vec_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Scene extends StatefulWidget {
  final double aspectRatio;
  final String worldData;

  Scene({this.aspectRatio, this.worldData});

  @override
  _SceneState createState() => _SceneState();
}

class _SceneState extends State<Scene> with SingleTickerProviderStateMixin {
  Matrix4 matProj;
  Mesh world;
  FPSCamera camera;
  Animation<double> animation;
  AnimationController controller;

  @override
  void initState() {
    super.initState();
    // set up animation controllers
    controller =
        AnimationController(duration: Duration(minutes: 1), vsync: this);
    animation = Tween<double>(begin: 0, end: 75).animate(controller)
      ..addListener(() {
        setState(() {});
      });
    // load world data
    rootBundle.loadString(widget.worldData).then((data) {
      Mesh.fromObjText(data).then((m) {
        setState(() {
          world = m;
        });
        controller.repeat();
      });
    });
    // set up camera
    camera = FPSCamera(Vec3d(), Vec3d(0, 0, 1), Vec3d(0, 1, 0));
    matProj = makeProjection(90, widget.aspectRatio, 0.1, 1000);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (world == null) return Container();
    return GestureDetector(
      onHorizontalDragUpdate: (details) {
        camera.turn(details.delta.dx * 0.005);
      },
      onVerticalDragUpdate: (details) {
        camera.movePosY(details.delta.dy * 0.05);
      },
      onTapDown: (details) {
        if (details.localPosition.dy > MediaQuery.of(context).size.height / 2) {
          camera.moveBackward();
        } else {
          camera.moveForward();
        }
      },
      child: CustomPaint(
        painter: ScenePainter(world, matProj, camera, animation.value),
      ),
    );
  }
}
