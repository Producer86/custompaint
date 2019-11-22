import 'dart:math';
import 'dart:ui';
import 'package:custompaint/geom.dart';
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' as _;

class MeshPainter extends CustomPainter {
  Paint _paint;
  Paint _wire;
  Matrix4 matProj;
  Mesh mesh;
  double time;
  Matrix4 matRotZ = Matrix4.zero();
  Matrix4 matRotX = Matrix4.zero();
  _.Vector3 camera = _.Vector3.zero();
  _.Vector3 lightDirection = _.Vector3(0.0, 0.0, 1.0);

  MeshPainter(this.mesh, this.matProj, this.time) {
    _paint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.blue
      ..strokeWidth = 1.0
      ..strokeCap = StrokeCap.butt;
    _wire = Paint()
      ..color = Colors.black
      ..strokeWidth = 1.0
      ..strokeCap = StrokeCap.butt;

    // hardcoded rotations for showcasing
    matRotZ.setEntry(0, 0, cos(time));
    matRotZ.setEntry(0, 1, sin(time));
    matRotZ.setEntry(1, 0, -sin(time));
    matRotZ.setEntry(1, 1, cos(time));
    matRotZ.setEntry(2, 2, 1);
    matRotZ.setEntry(3, 3, 1);

    matRotX.setEntry(0, 0, 1);
    matRotX.setEntry(1, 1, cos(time / 2));
    matRotX.setEntry(1, 2, sin(time / 2));
    matRotX.setEntry(2, 1, -sin(time / 2));
    matRotX.setEntry(2, 2, cos(time / 2));
    matRotX.setEntry(3, 3, 1);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final trisToRaster = <ColoredTriangle>[];
    for (var tri in mesh.tris) {
      //rotate
      // around Z
      var p0 = multiplyMatrixVector(tri.point0, matRotZ);
      var p1 = multiplyMatrixVector(tri.point1, matRotZ);
      var p2 = multiplyMatrixVector(tri.point2, matRotZ);
      // around X
      p0 = multiplyMatrixVector(p0, matRotX);
      p1 = multiplyMatrixVector(p1, matRotX);
      p2 = multiplyMatrixVector(p2, matRotX);
      //push it back a bit
      p0.z += 10;
      p1.z += 10;
      p2.z += 10;
      //calc normal
      _.Vector3 normal = _.Vector3.zero();
      _.Vector3 line1 = _.Vector3.zero();
      _.Vector3 line2 = _.Vector3.zero();
      line1.x = p1.x - p0.x;
      line1.y = p1.y - p0.y;
      line1.z = p1.z - p0.z;
      line2.x = p2.x - p0.x;
      line2.y = p2.y - p0.y;
      line2.z = p2.z - p0.z;
      normal.x = line1.y * line2.z - line1.z * line2.y;
      normal.y = line1.z * line2.x - line1.x * line2.z;
      normal.z = line1.x * line2.y - line1.y * line2.x;
      final double nL =
          sqrt(normal.x * normal.x + normal.y * normal.y + normal.z * normal.z);
      normal.x /= nL;
      normal.y /= nL;
      normal.z /= nL;
      // if camera can see it
      if ((normal.x * (p0.x - camera.x) +
              normal.y * (p0.y - camera.y) +
              normal.z * (p0.z - camera.z)) <
          0.0) {
        // illuminate
        final double lL = sqrt(lightDirection.x * lightDirection.x +
            lightDirection.y * lightDirection.y +
            lightDirection.z * lightDirection.z);
        lightDirection.x /= lL;
        lightDirection.y /= lL;
        lightDirection.z /= lL;
        final dp = normal.x * lightDirection.x +
            normal.y * lightDirection.y +
            normal.z * lightDirection.z;
        final color = Color.lerp(Colors.blue[800], Colors.black, dp);
        // apply projection
        p0 = multiplyMatrixVector(p0, matProj);
        p1 = multiplyMatrixVector(p1, matProj);
        p2 = multiplyMatrixVector(p2, matProj);
        // scale into view
        p0.x += 1.0;
        p0.y += 1.0;
        p1.x += 1.0;
        p1.y += 1.0;
        p2.x += 1.0;
        p2.y += 1.0;
        final oX = size.width / 2.0;
        final oY = size.height / 2.0;
        p0.x *= oX;
        p0.y *= oY;
        p1.x *= oX;
        p1.y *= oY;
        p2.x *= oX;
        p2.y *= oY;
        trisToRaster.add(ColoredTriangle(_.Triangle.points(p0, p1, p2), color));
      }
    }

    // no Z-buffering per pixel so just paint furthest first
    trisToRaster.sort((ColoredTriangle t1, ColoredTriangle t2) {
      final a = t1.trianlge;
      final b = t2.trianlge;
      double z1 = (a.point0.z + a.point1.z + a.point2.z) / 3.0;
      double z2 = (b.point0.z + b.point1.z + b.point2.z) / 3.0;
      return z1 > z2 ? -1 : z2 > z1 ? 1 : 0;
    });

    // rasterize
    for (var coltri in trisToRaster) {
      final tri = coltri.trianlge;
      _paint.color = coltri.color;

      final shape = Path();
      shape.addPolygon(
        [
          Offset(tri.point0.x, tri.point0.y),
          Offset(tri.point1.x, tri.point1.y),
          Offset(tri.point2.x, tri.point2.y),
        ],
        true,
      );
      canvas.drawPath(shape, _paint);
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
      //   _paint,
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
      //   _wire,
      // );
    }
  }

  @override
  bool shouldRepaint(MeshPainter oldDelegate) {
    return oldDelegate.time != time;
  }
}
