import 'dart:math' show sqrt, cos, sin, tan, pi;
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' show Matrix4;

import 'geom.dart';

Matrix4 makeRotationX(double rad) {
  final m = Matrix4.identity();
  final c = cos(rad);
  final s = sin(rad);
  m.setEntry(1, 1, c);
  m.setEntry(1, 2, s);
  m.setEntry(2, 1, -s);
  m.setEntry(2, 2, c);
  return m;
}

Matrix4 makeRotationY(double rad) {
  final m = Matrix4.identity();
  final c = cos(rad);
  final s = sin(rad);
  m.setEntry(0, 0, c);
  m.setEntry(0, 2, s);
  m.setEntry(2, 0, -s);
  m.setEntry(2, 2, c);
  return m;
}

Matrix4 makeRotationZ(double rad) {
  final m = Matrix4.identity();
  final c = cos(rad);
  final s = sin(rad);
  m.setEntry(0, 0, c);
  m.setEntry(0, 1, s);
  m.setEntry(1, 0, -s);
  m.setEntry(1, 1, c);
  return m;
}

Matrix4 makeTranslation(double x, double y, double z) {
  final m = Matrix4.identity();
  m.setEntry(3, 0, x);
  m.setEntry(3, 1, y);
  m.setEntry(3, 2, z);
  return m;
}

Matrix4 makeProjection(
  double fovDeg,
  double aspectRatio,
  double near,
  double far,
) {
  final fovRad = 1.0 / tan(fovDeg / 2.0 / 180.0 * pi);
  final m = Matrix4.zero();
  m.setEntry(0, 0, aspectRatio * fovRad);
  m.setEntry(1, 1, fovRad);
  m.setEntry(2, 2, far / (far - near));
  m.setEntry(3, 2, (-far * near) / (far - near));
  m.setEntry(2, 3, 1.0);
  m.setEntry(3, 3, 0.0);
  return m;
}

Vec3d matXvec(Matrix4 m, Vec3d i) {
  Vec3d v = Vec3d();
  v.x = i.x * m.entry(0, 0) +
      i.y * m.entry(1, 0) +
      i.z * m.entry(2, 0) +
      i.w * m.entry(3, 0);
  v.y = i.x * m.entry(0, 1) +
      i.y * m.entry(1, 1) +
      i.z * m.entry(2, 1) +
      i.w * m.entry(3, 1);
  v.z = i.x * m.entry(0, 2) +
      i.y * m.entry(1, 2) +
      i.z * m.entry(2, 2) +
      i.w * m.entry(3, 2);
  v.w = i.x * m.entry(0, 3) +
      i.y * m.entry(1, 3) +
      i.z * m.entry(2, 3) +
      i.w * m.entry(3, 3);
  return v;
}

Matrix4 matXmat(Matrix4 m1, Matrix4 m2) {
  final m = Matrix4.zero();
  for (var c = 0; c < 4; c++) {
    for (var r = 0; r < 4; r++) {
      m.setEntry(
          r,
          c,
          m1.entry(r, 0) * m2.entry(0, c) +
              m1.entry(r, 1) * m2.entry(1, c) +
              m1.entry(r, 2) * m2.entry(2, c) +
              m1.entry(r, 3) * m2.entry(3, c));
    }
  }
  return m;
}

Matrix4 matPointAt(Vec3d pos, Vec3d target, Vec3d up) {
  var forward = vecSub(target, pos);
  forward = vecNormal(forward);

  var a = vecMul(forward, vecDotProd(up, forward));
  var newUp = vecSub(up, a);
  newUp = vecNormal(newUp);

  var right = vecXvec(newUp, forward);

  final m = Matrix4.zero();
  m.setEntry(0, 0, right.x);
  m.setEntry(0, 1, right.y);
  m.setEntry(0, 2, right.z);
  m.setEntry(1, 0, newUp.x);
  m.setEntry(1, 1, newUp.y);
  m.setEntry(1, 2, newUp.z);
  m.setEntry(2, 0, forward.x);
  m.setEntry(2, 1, forward.y);
  m.setEntry(2, 2, forward.z);
  m.setEntry(3, 0, pos.x);
  m.setEntry(3, 1, pos.y);
  m.setEntry(3, 2, pos.z);
  m.setEntry(3, 3, 1.0);
  return m;
}

/// Only for rot/tran matrices
Matrix4 matQuickInvesre(Matrix4 m) {
  final res = Matrix4.zero();
  res.setEntry(0, 0, m.entry(0, 0));
  res.setEntry(0, 1, m.entry(1, 0));
  res.setEntry(0, 2, m.entry(2, 0));
  res.setEntry(1, 0, m.entry(0, 1));
  res.setEntry(1, 1, m.entry(1, 1));
  res.setEntry(1, 2, m.entry(2, 1));
  res.setEntry(2, 0, m.entry(0, 2));
  res.setEntry(2, 1, m.entry(1, 2));
  res.setEntry(2, 2, m.entry(2, 2));
  res.setEntry(
      3,
      0,
      -(m.entry(3, 0) * res.entry(0, 0) +
          m.entry(3, 1) * res.entry(1, 0) +
          m.entry(3, 2) * res.entry(2, 0)));
  res.setEntry(
      3,
      1,
      -(m.entry(3, 0) * res.entry(0, 1) +
          m.entry(3, 1) * res.entry(1, 1) +
          m.entry(3, 2) * res.entry(2, 1)));
  res.setEntry(
      3,
      2,
      -(m.entry(3, 0) * res.entry(0, 2) +
          m.entry(3, 1) * res.entry(1, 2) +
          m.entry(3, 2) * res.entry(2, 2)));
  res.setEntry(3, 3, 1.0);
  return res;
}

Vec3d vecAdd(Vec3d v1, Vec3d v2) {
  return Vec3d(v1.x + v2.x, v1.y + v2.y, v1.z + v2.z);
}

Vec3d vecSub(Vec3d v1, Vec3d v2) {
  return Vec3d(v1.x - v2.x, v1.y - v2.y, v1.z - v2.z);
}

Vec3d vecMul(Vec3d v1, double k) {
  return Vec3d(v1.x * k, v1.y * k, v1.z * k);
}

Vec3d vecDiv(Vec3d v1, double k) {
  return Vec3d(v1.x / k, v1.y / k, v1.z / k);
}

double vecDotProd(Vec3d v1, Vec3d v2) {
  return (v1.x * v2.x) + (v1.y * v2.y) + (v1.z * v2.z);
}

double vecLen(Vec3d v) {
  return sqrt(vecDotProd(v, v));
}

Vec3d vecNormal(Vec3d v) {
  final l = vecLen(v);
  return Vec3d(v.x / l, v.y / l, v.z / l);
}

Vec3d vecXvec(Vec3d v1, Vec3d v2) {
  final v = Vec3d();
  v.x = v1.y * v2.z - v1.z * v2.y;
  v.y = v1.z * v2.x - v1.x * v2.z;
  v.z = v1.x * v2.y - v1.y * v2.x;
  return v;
}

Vec3d vecIntersectPlane(
  Vec3d planePoint,
  Vec3d planeNorm,
  Vec3d lineStart,
  Vec3d lineEnd,
) {
  final pNorm = vecNormal(planeNorm);
  double planed = -vecDotProd(pNorm, planePoint);
  double ad = vecDotProd(lineStart, pNorm);
  double bd = vecDotProd(lineEnd, pNorm);
  double t = (-planed - ad) / (bd - ad);
  Vec3d lineStartToEnd = vecSub(lineEnd, lineStart);
  Vec3d lineToIntersect = vecMul(lineStartToEnd, t);
  return vecAdd(lineStart, lineToIntersect);
}

List<Triangle> triClipAgainstPlane(
  Vec3d planePoint,
  Vec3d planeNorm,
  Triangle tri,
) {
  final pNorm = vecNormal(planeNorm);
  // distance of p from our plane
  final dist = (Vec3d p) =>
      pNorm.x * p.x +
      pNorm.y * p.y +
      pNorm.z * p.z -
      vecDotProd(pNorm, planePoint);
  // store points as in or outside by sign of distance
  final inside = <Vec3d>[];
  final outside = <Vec3d>[];
  // calc signed dist of each points
  double d0 = dist(tri.point0);
  double d1 = dist(tri.point1);
  double d2 = dist(tri.point2);
  if (d0.isNegative) {
    outside.add(tri.point0);
  } else {
    inside.add(tri.point0);
  }
  if (d1.isNegative) {
    outside.add(tri.point1);
  } else {
    inside.add(tri.point1);
  }
  if (d2.isNegative) {
    outside.add(tri.point2);
  } else {
    inside.add(tri.point2);
  }
  // now classify triangle based on how many points are outside
  if (inside.length == 0) {
    return [];
  }
  if (inside.length == 3) {
    return [tri];
  }
  if (inside.length == 1 && outside.length == 2) {
    // in this case build one new triangle
    return [
      Triangle(
        inside[0],
        vecIntersectPlane(planePoint, pNorm, inside[0], outside[0]),
        vecIntersectPlane(planePoint, pNorm, inside[0], outside[1]),
        tri.color,
        // Colors.blue,
      )
    ];
  }
  if (inside.length == 2 && outside.length == 1) {
    // in this case we need 2 new triangles
    final newPoint =
        vecIntersectPlane(planePoint, pNorm, inside[0], outside[0]);
    return [
      Triangle(
        inside[0],
        inside[1],
        newPoint,
        tri.color,
        // Colors.red,
      ),
      Triangle(
        inside[1],
        newPoint,
        vecIntersectPlane(planePoint, pNorm, inside[1], outside[0]),
        tri.color,
        // Colors.green,
      ),
    ];
  }
  return [];
}
