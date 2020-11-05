import 'dart:math' show sqrt, cos, sin, tan, pi;
import 'dart:ui';
import 'package:flutter/material.dart' show Color, Paint, Canvas;
import 'package:vector_math/vector_math_64.dart' show Matrix4;
import 'package:image/image.dart' show Image;

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

class _IntersectInfo {
  Vec3d vec;
  double t;

  _IntersectInfo(this.vec, this.t);
}

_IntersectInfo vecIntersectPlane(
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
  return _IntersectInfo(vecAdd(lineStart, lineToIntersect), t);
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
  final insidePnts = <Vec3d>[];
  final outsidePnts = <Vec3d>[];
  final insideTexs = <Vec2d>[];
  final outsideTexs = <Vec2d>[];
  // calc signed dist of each points
  double d0 = dist(tri.point0);
  double d1 = dist(tri.point1);
  double d2 = dist(tri.point2);
  if (d0.isNegative) {
    outsidePnts.add(tri.point0);
    if (tri.tex0 != null) {
      outsideTexs.add(tri.tex0);
    }
  } else {
    insidePnts.add(tri.point0);
    if (tri.tex0 != null) {
      insideTexs.add(tri.tex0);
    }
  }
  if (d1.isNegative) {
    outsidePnts.add(tri.point1);
    if (tri.tex1 != null) {
      outsideTexs.add(tri.tex1);
    }
  } else {
    insidePnts.add(tri.point1);
    if (tri.tex1 != null) {
      insideTexs.add(tri.tex1);
    }
  }
  if (d2.isNegative) {
    outsidePnts.add(tri.point2);
    if (tri.tex2 != null) {
      outsideTexs.add(tri.tex2);
    }
  } else {
    insidePnts.add(tri.point2);
    if (tri.tex2 != null) {
      insideTexs.add(tri.tex2);
    }
  }
  // now classify triangle based on how many points are outside
  if (insidePnts.length == 0) {
    return [];
  }
  if (insidePnts.length == 3) {
    return [tri];
  }
  if (insidePnts.length == 1 && outsidePnts.length == 2) {
    // in this case build one new triangle
    final i0 =
        vecIntersectPlane(planePoint, pNorm, insidePnts[0], outsidePnts[0]);
    final i1 =
        vecIntersectPlane(planePoint, pNorm, insidePnts[0], outsidePnts[1]);
    Vec2d t0;
    Vec2d t1;
    Vec2d t2;
    // if model has texture coordinates clip those too
    if (insideTexs.length == 1 && outsideTexs.length == 2) {
      t0 = insideTexs[0];
      t1 = Vec2d(
        i0.t * (outsideTexs[0].u - insideTexs[0].u) + insideTexs[0].u,
        i0.t * (outsideTexs[0].v - insideTexs[0].v) + insideTexs[0].v,
      );
      t2 = Vec2d(
        i1.t * (outsideTexs[1].u - insideTexs[0].u) + insideTexs[0].u,
        i1.t * (outsideTexs[1].v - insideTexs[0].v) + insideTexs[0].v,
      );
    }
    return [
      Triangle(
        insidePnts[0],
        i0.vec,
        i1.vec,
        tri.color,
        t0,
        t1,
        t2,
      )
    ];
  }
  if (insidePnts.length == 2 && outsidePnts.length == 1) {
    // in this case we need 2 new triangles
    final commonPoint =
        vecIntersectPlane(planePoint, pNorm, insidePnts[0], outsidePnts[0]);
    final i0 =
        vecIntersectPlane(planePoint, pNorm, insidePnts[1], outsidePnts[0]);
    Vec2d t0t0;
    Vec2d t0t1;
    Vec2d t0t2;
    Vec2d t1t0;
    Vec2d t1t1;
    Vec2d t1t2;
    if (insideTexs.length == 2 && outsideTexs.length == 1) {
      t0t0 = insideTexs[0];
      t0t1 = insideTexs[1];
      t0t2 = Vec2d(
        commonPoint.t * (outsideTexs[0].u - insideTexs[0].u) + insideTexs[0].u,
        commonPoint.t * (outsideTexs[0].v - insideTexs[0].v) + insideTexs[0].v,
      );
      t1t0 = insideTexs[1];
      t1t0 = t0t2;
      t1t2 = Vec2d(
        i0.t * (outsideTexs[0].u - insideTexs[1].u) + insideTexs[1].u,
        i0.t * (outsideTexs[0].v - insideTexs[1].v) + insideTexs[1].v,
      );
    }
    return [
      Triangle(
        insidePnts[0],
        insidePnts[1],
        commonPoint.vec,
        tri.color,
        t0t0,
        t0t1,
        t0t2,
      ),
      Triangle(
        insidePnts[1],
        commonPoint.vec,
        i0.vec,
        tri.color,
        t1t0,
        t1t1,
        t1t2,
      ),
    ];
  }
  return [];
}

class TexPoint {
  int x;
  int y;
  double u;
  double v;

  TexPoint(this.x, this.y, this.u, this.v);
}

void drawTexturedTriangle(TexPoint point1, TexPoint point2, TexPoint point3,
    Image img, Canvas canvas, Paint paint) {
  final p = <TexPoint>[point1, point2, point3];
  // order points by Y value descending
  p.sort((TexPoint a, TexPoint b) => b.y - a.y);
  // calc gradient values
  int dy1 = p[1].y - p[0].y;
  int dx1 = p[1].x - p[0].x;
  double du1 = p[1].u - p[0].u;
  double dv1 = p[1].v - p[0].v;

  int dy2 = p[2].y - p[1].y;
  int dx2 = p[2].x - p[1].x;
  double du2 = p[2].u - p[1].u;
  double dv2 = p[2].v - p[1].v;

  double daxStep = 0;
  double dbxStep = 0;
  double du1Step = 0;
  double dv1Step = 0;
  double du2Step = 0;
  double dv2Step = 0;

  if (dy1 != 0) {
    final dy = dy1.abs();
    daxStep = dx1 / dy;
    du1Step = du1 / dy;
    dv1Step = dv1 / dy;
  }
  if (dy2 != 0) {
    final dy = dy2.abs();
    dbxStep = dx2 / dy;
    du2Step = du2 / dy;
    dv2Step = dv2 / dy;
  }

  double texU;
  double texV;

  // then start drawing from top to bottom
  if (dy1 != 0) {
    for (var i = p[0].y; i < p[1].y; i++) {
      int ax = p[0].x + ((i - p[0].y) * daxStep).toInt();
      int bx = p[0].x + ((i - p[0].y) * dbxStep).toInt();
      double startU = p[0].u + (i - p[0].y) * du1Step;
      double startV = p[0].v + (i - p[0].y) * dv1Step;
      double endU = p[0].u + (i - p[0].y) * du2Step;
      double endV = p[0].v + (i - p[0].y) * dv2Step;

      if (ax > bx) {
        int tempi = ax;
        ax = bx;
        bx = tempi;
        double tempf = startU;
        startU = endU;
        endU = tempf;
        tempf = startV;
        startV = endV;
        endV = tempf;
      }

      double tstep = 1 / (bx - ax);
      double t = 0;

      for (var j = ax; j < bx; j++) {
        texU = (1 - t) * startU + t * endU;
        texV = (1 - t) * startV + t * endV;
        paint.color = Color(img.getPixelLinear(texU, texV));
        canvas.drawPoints(
            PointMode.points, [Offset(j.toDouble(), i.toDouble())], paint);
        t += tstep;
      }
    }
    // halfway there, now the bottom half
    dy1 = p[2].y - p[1].y;
    dx1 = p[2].x - p[1].x;
    du1 = p[2].u - p[1].u;
    dv1 = p[2].v - p[1].v;

    if (dy1 != 0) {
      final dy = dy1.abs();
      daxStep = dx1 / dy;
      du1Step = du1 / dy;
      dv1Step = dv1 / dy;
    }

    for (var i = p[1].y; i < p[2].y; i++) {
      int ax = p[1].x + ((i - p[1].y) * daxStep).toInt();
      int bx = p[0].x + ((i - p[0].y) * dbxStep).toInt();
      double startU = p[1].u + (i - p[1].y) * du1Step;
      double startV = p[1].v + (i - p[1].y) * dv1Step;
      double endU = p[0].u + (i - p[0].y) * du2Step;
      double endV = p[0].v + (i - p[0].y) * dv2Step;

      if (ax > bx) {
        int tempi = ax;
        ax = bx;
        bx = tempi;
        double tempf = startU;
        startU = endU;
        endU = tempf;
        tempf = startV;
        startV = endV;
        endV = tempf;
      }

      double tstep = 1 / (bx - ax);
      double t = 0;

      for (var j = ax; j < bx; j++) {
        texU = (1 - t) * startU + t * endU;
        texV = (1 - t) * startV + t * endV;
        paint.color = Color(img.getPixelLinear(texU, texV));
        canvas.drawPoints(
            PointMode.points, [Offset(j.toDouble(), i.toDouble())], paint);
        t += tstep;
      }
    }
  }
}
