import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' as _;

class ColoredTriangle {
  _.Triangle trianlge;
  Color color;

  ColoredTriangle(this.trianlge, this.color);
}

class Mesh {
  List<_.Triangle> tris;
  Mesh(this.tris);

  static Future<Mesh> fromFile(String data) async {
    // final dir = await getApplicationDocumentsDirectory();
    // final file = File(dir.path + '/$filePath');
    // final data = await file.readAsString();
    final verts = <_.Vector3>[];
    final tris = <_.Triangle>[];
    if (data.isNotEmpty) {
      final lines = data.split('\n');
      for (var line in lines) {
        if (line.isNotEmpty) {
          if (line[0].toLowerCase() == 'v') {
            final coords =
                line.split(RegExp(r'\s')).sublist(1).map(double.parse).toList();
            verts.add(_.Vector3(
              coords[0],
              coords[1],
              coords[2],
            ));
          }
          if (line[0].toLowerCase() == 'f') {
            final points =
                line.split(RegExp(r'\s')).sublist(1).map(int.parse).toList();
            tris.add(_.Triangle.points(
              verts[points[0] - 1],
              verts[points[1] - 1],
              verts[points[2] - 1],
            ));
          }
        }
      }
      return Mesh(tris);
    }
    return Mesh([]);
  }
}

_.Vector3 multiplyMatrixVector(_.Vector3 v, Matrix4 m) {
  final res = _.Vector3.zero();
  res.x = v.x * m.entry(0, 0) +
      v.y * m.entry(1, 0) +
      v.z * m.entry(2, 0) +
      m.entry(3, 0);
  res.y = v.x * m.entry(0, 1) +
      v.y * m.entry(1, 1) +
      v.z * m.entry(2, 1) +
      m.entry(3, 1);
  res.z = v.x * m.entry(0, 2) +
      v.y * m.entry(1, 2) +
      v.z * m.entry(2, 2) +
      m.entry(3, 2);
  double w = v.x * m.entry(0, 3) +
      v.y * m.entry(1, 3) +
      v.z * m.entry(2, 3) +
      m.entry(3, 3);
  if (w != 0.0) {
    res.x /= w;
    res.y /= w;
    res.z /= w;
  }
  return res;
}
