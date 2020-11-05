import 'package:custompaint/geom.dart';
import 'package:flutter/material.dart';

Mesh cube = Mesh([
  // SOUTH
  Triangle(
    Vec3d(0, 0, 0),
    Vec3d(0, 1, 0),
    Vec3d(1, 1, 0),
    Colors.blue,
    Vec2d(0, 1),
    Vec2d(0, 0),
    Vec2d(1, 0),
  ),
  Triangle(
    Vec3d(0, 0, 0),
    Vec3d(1, 1, 0),
    Vec3d(1, 0, 0),
    Colors.blue,
    Vec2d(0, 1),
    Vec2d(1, 0),
    Vec2d(1, 1),
  ),
  // EAST
  Triangle(
    Vec3d(1, 0, 0),
    Vec3d(1, 1, 0),
    Vec3d(1, 1, 1),
    Colors.blue,
    Vec2d(0, 1),
    Vec2d(0, 0),
    Vec2d(1, 0),
  ),
  Triangle(
    Vec3d(1, 0, 0),
    Vec3d(1, 1, 1),
    Vec3d(1, 0, 1),
    Colors.blue,
    Vec2d(0, 1),
    Vec2d(1, 0),
    Vec2d(1, 1),
  ),
  // NORTH
  Triangle(
    Vec3d(1, 0, 1),
    Vec3d(1, 1, 1),
    Vec3d(0, 1, 1),
    Colors.blue,
    Vec2d(0, 1),
    Vec2d(0, 0),
    Vec2d(1, 0),
  ),
  Triangle(
    Vec3d(1, 0, 1),
    Vec3d(0, 1, 1),
    Vec3d(0, 0, 1),
    Colors.blue,
    Vec2d(0, 1),
    Vec2d(1, 0),
    Vec2d(1, 1),
  ),
  // WEST
  Triangle(
    Vec3d(0, 0, 1),
    Vec3d(0, 1, 1),
    Vec3d(0, 1, 0),
    Colors.blue,
    Vec2d(0, 1),
    Vec2d(0, 0),
    Vec2d(1, 0),
  ),
  Triangle(
    Vec3d(0, 0, 1),
    Vec3d(0, 1, 0),
    Vec3d(0, 0, 0),
    Colors.blue,
    Vec2d(0, 1),
    Vec2d(1, 0),
    Vec2d(1, 1),
  ),
  // TOP
  Triangle(
    Vec3d(0, 1, 0),
    Vec3d(0, 1, 1),
    Vec3d(1, 1, 1),
    Colors.blue,
    Vec2d(0, 1),
    Vec2d(0, 0),
    Vec2d(1, 0),
  ),
  Triangle(
    Vec3d(0, 1, 0),
    Vec3d(1, 1, 1),
    Vec3d(1, 1, 0),
    Colors.blue,
    Vec2d(0, 1),
    Vec2d(1, 0),
    Vec2d(1, 1),
  ),
  // BOTTOM
  Triangle(
    Vec3d(1, 0, 1),
    Vec3d(0, 0, 1),
    Vec3d(0, 0, 0),
    Colors.blue,
    Vec2d(0, 1),
    Vec2d(0, 0),
    Vec2d(1, 0),
  ),
  Triangle(
    Vec3d(1, 0, 1),
    Vec3d(0, 0, 0),
    Vec3d(1, 0, 0),
    Colors.blue,
    Vec2d(0, 1),
    Vec2d(1, 0),
    Vec2d(1, 1),
  ),
]);
