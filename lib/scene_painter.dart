import 'dart:collection';
import 'dart:math';
import 'dart:ui';
import 'package:custompaint/camera.dart';
import 'package:custompaint/geom.dart';
import 'package:flutter/material.dart';
import 'package:custompaint/vec_utils.dart';

class ScenePainter extends CustomPainter {
  Paint fillPaint;
  Paint wirePaint;
  Matrix4 matProj;
  Matrix4 matWorld;
  Camera camera;
  Mesh mesh;
  double tick;
  Vec3d lightDirection;
  Vec3d viewOffset = Vec3d(1, 1, 0);

  ScenePainter(this.mesh, this.matProj, this.camera, this.tick) {
    fillPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.blue
      ..strokeWidth = 1.0
      ..strokeCap = StrokeCap.butt;
    wirePaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 1.0
      ..strokeCap = StrokeCap.butt;

    lightDirection = Vec3d(0, 1.0, -1.0);
    lightDirection = vecNormal(lightDirection);

    // set up rotations, translations
    // final rotZ = makeRotationZ(tick / 2);
    // final rotX = makeRotationX(tick);
    final trans = makeTranslation(0, 0, 16);
    matWorld = Matrix4.identity();
    // matWorld = matXmat(rotZ, rotX);
    matWorld = matXmat(matWorld, trans);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final trisToRaster = <Triangle>[];
    for (var tri in mesh.tris) {
      // rotate, translate
      Vec3d p0 = matXvec(matWorld, tri.point0);
      Vec3d p1 = matXvec(matWorld, tri.point1);
      Vec3d p2 = matXvec(matWorld, tri.point2);
      // calc normal
      Vec3d line1 = vecSub(p1, p0);
      Vec3d line2 = vecSub(p2, p0);
      Vec3d normal = vecXvec(line1, line2);
      normal = vecNormal(normal);
      // if camera can see it
      Vec3d cameraRay = vecSub(p0, camera.position);
      if (vecDotProd(normal, cameraRay) < 0.0) {
        // illuminate
        final dp = max(0.1, vecDotProd(lightDirection, normal));
        final color = Color.lerp(Colors.blue, Colors.black, dp);
        // convert from world space to view space
        p0 = matXvec(camera.viewMatrix, p0);
        p1 = matXvec(camera.viewMatrix, p1);
        p2 = matXvec(camera.viewMatrix, p2);
        // clip against the near plane
        final triangle = Triangle(p0, p1, p2, color);
        final clipped =
            triClipAgainstPlane(Vec3d(0, 0, 0.1), Vec3d(0, 0, 1), triangle);
        for (var tri in clipped) {
          // apply projection
          tri.point0 = matXvec(matProj, tri.point0);
          tri.point1 = matXvec(matProj, tri.point1);
          tri.point2 = matXvec(matProj, tri.point2);
          tri.point0 = vecDiv(tri.point0, tri.point0.w);
          tri.point1 = vecDiv(tri.point1, tri.point1.w);
          tri.point2 = vecDiv(tri.point2, tri.point2.w);
          //invert x/y back
          tri.point0.x *= -1.0;
          tri.point1.x *= -1.0;
          tri.point2.x *= -1.0;
          tri.point0.y *= -1.0;
          tri.point1.y *= -1.0;
          tri.point2.y *= -1.0;
          // scale into view
          tri.point0 = vecAdd(tri.point0, viewOffset);
          tri.point1 = vecAdd(tri.point1, viewOffset);
          tri.point2 = vecAdd(tri.point2, viewOffset);
          final oX = size.width / 2.0;
          final oY = size.height / 2.0;
          tri.point0.x *= oX;
          tri.point0.y *= oY;
          tri.point1.x *= oX;
          tri.point1.y *= oY;
          tri.point2.x *= oX;
          tri.point2.y *= oY;
          trisToRaster.add(tri);
        }
      }
    }
    // no Z-buffering per pixel so just paint furthest first
    trisToRaster.sort((Triangle a, Triangle b) {
      double az = (a.point0.z + a.point1.z + a.point2.z) / 3.0;
      double bz = (b.point0.z + b.point1.z + b.point2.z) / 3.0;
      return az > bz ? -1 : bz > az ? 1 : 0;
    });
    // rasterize
    for (var tri in trisToRaster) {
      // clip triangle against the screen edges
      List<Triangle> clipped;
      final triQueue = ListQueue();
      triQueue.add(tri);
      var numNewTris = 1;
      for (var i = 0; i < 4; i++) {
        while (numNewTris > 0) {
          var test = triQueue.removeFirst();
          numNewTris--;
          switch (i) {
            case 0:
              clipped =
                  triClipAgainstPlane(Vec3d(0, 0, 0), Vec3d(0, 1, 0), test);
              break;
            case 1:
              clipped = triClipAgainstPlane(
                  Vec3d(0, size.height - 1, 0), Vec3d(0, -1, 0), test);
              break;
            case 2:
              clipped =
                  triClipAgainstPlane(Vec3d(0, 0, 0), Vec3d(1, 0, 0), test);
              break;
            case 3:
              clipped = triClipAgainstPlane(
                  Vec3d(size.width - 1, 0, 0), Vec3d(-1, 0, 0), test);
              break;
            default:
              break;
          }
          triQueue.addAll(clipped);
        }
        numNewTris = triQueue.length;
      }
      for (Triangle t in triQueue) {
        fillPaint.color = t.color;
        final shape = Path();
        shape.moveTo(t.point0.x, t.point0.y);
        shape.lineTo(t.point1.x, t.point1.y);
        shape.lineTo(t.point2.x, t.point2.y);
        shape.close();
        canvas.drawPath(shape, fillPaint);
        // canvas.drawPoints(
        //   PointMode.polygon,
        //   [
        //     Offset(t.point0.x, t.point0.y),
        //     Offset(t.point1.x, t.point1.y),
        //     Offset(t.point2.x, t.point2.y),
        //     Offset(t.point0.x, t.point0.y),
        //   ],
        //   wirePaint,
        // );
      }
    }
  }

  @override
  bool shouldRepaint(ScenePainter oldDelegate) {
    // return oldDelegate.tick != tick;
    return true;
  }
}
