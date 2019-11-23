import 'package:flutter/material.dart' show Color;

class Vec3d {
  double x;
  double y;
  double z;
  double w;
  Vec3d([this.x = 0.0, this.y = 0.0, this.z = 0.0, this.w = 1.0]);
}

class Triangle {
  Vec3d point0;
  Vec3d point1;
  Vec3d point2;
  Color color;

  Triangle(this.point0, this.point1, this.point2, [this.color]);
}

class Mesh {
  List<Triangle> tris;
  Mesh(this.tris);

  static Future<Mesh> fromObjText(String data) async {
    final verts = <Vec3d>[];
    final tris = <Triangle>[];
    if (data.isEmpty) return Mesh(tris);
    final lines = data.split('\n');
    for (var line in lines) {
      if (line.isNotEmpty) {
        if (line[0].toLowerCase() == 'v') {
          final coords =
              line.split(RegExp(r'\s')).sublist(1).map(double.parse).toList();
          verts.add(Vec3d(
            coords[0],
            coords[1],
            coords[2],
          ));
        }
        if (line[0].toLowerCase() == 'f') {
          final points =
              line.split(RegExp(r'\s')).sublist(1).map(int.parse).toList();
          tris.add(Triangle(
            verts[points[0] - 1],
            verts[points[1] - 1],
            verts[points[2] - 1],
          ));
        }
      }
    }
    return Mesh(tris);
  }
}
