import 'dart:math';
import 'dart:ui';
import 'package:custompaint/geom.dart';
import 'package:flutter/material.dart';
import 'package:custompaint/vec_utils.dart';

class MeshPainter extends CustomPainter {
  Paint fillPaint;
  Paint wirePaint;
  Matrix4 matProj;
  Matrix4 matWorld;
  Mesh mesh;
  double tick;
  Vec3d camera;
  Matrix4 matCam;
  Matrix4 matView;
  Vec3d lookDir;
  Vec3d target;
  Vec3d lightDirection;
  Vec3d viewOffset = Vec3d(1, 1, 0);
  Vec3d upVec = Vec3d(0, 1, 0);

  MeshPainter(this.mesh, this.matProj, this.tick) {
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

    camera = Vec3d();
    camera.y += tick;
    lookDir = Vec3d(0, 0, 1);
    target = vecAdd(camera, lookDir);
    matCam = matPointAt(camera, target, upVec);
    matView = matQuickInvesre(matCam);

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
      Vec3d cameraRay = vecSub(p0, camera);
      if (dotProd(normal, cameraRay) < 0.0) {
        // illuminate
        final dp = max(0.1, dotProd(lightDirection, normal));
        final color = Color.lerp(Colors.blue, Colors.black, dp);
        // convert from world space to view space
        p0 = matXvec(matView, p0);
        p1 = matXvec(matView, p1);
        p2 = matXvec(matView, p2);
        // apply projection
        p0 = matXvec(matProj, p0);
        p1 = matXvec(matProj, p1);
        p2 = matXvec(matProj, p2);
        p0 = vecDiv(p0, p0.w);
        p1 = vecDiv(p1, p1.w);
        p2 = vecDiv(p2, p2.w);
        // scale into view
        p0 = vecAdd(p0, viewOffset);
        p1 = vecAdd(p1, viewOffset);
        p2 = vecAdd(p2, viewOffset);
        final oX = size.width / 2.0;
        final oY = size.height / 2.0;
        p0.x *= oX;
        p0.y *= oY;
        p1.x *= oX;
        p1.y *= oY;
        p2.x *= oX;
        p2.y *= oY;
        trisToRaster.add(Triangle(p0, p1, p2, color));
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
      fillPaint.color = tri.color;

      final shape = Path();
      shape.addPolygon(
        [
          Offset(tri.point0.x, tri.point0.y),
          Offset(tri.point1.x, tri.point1.y),
          Offset(tri.point2.x, tri.point2.y),
        ],
        true,
      );
      canvas.drawPath(shape, fillPaint);
      // ***
      // canvas.drawVertices(
      //   Vertices(
      //     VertexMode.triangles,
      //     [
      //       Offset(tri.point0.x, tri.point0.y),
      //       Offset(tri.point1.x, tri.point1.y),
      //       Offset(tri.point2.x, tri.point2.y),
      //       Offset(tri.point0.x, tri.point0.y),
      //     ],
      //   ),
      //   BlendMode.srcOver,
      //   fillPaint,
      // );
      // ***
      // canvas.drawPoints(
      //   PointMode.polygon,
      //   [
      //     Offset(tri.point0.x, tri.point0.y),
      //     Offset(tri.point1.x, tri.point1.y),
      //     Offset(tri.point2.x, tri.point2.y),
      //     Offset(tri.point0.x, tri.point0.y),
      //   ],
      //   wirePaint,
      // );
    }
  }

  @override
  bool shouldRepaint(MeshPainter oldDelegate) {
    return oldDelegate.tick != tick;
  }
}
