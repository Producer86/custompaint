import 'package:custompaint/command.dart';
import 'package:custompaint/geom.dart';
import 'package:custompaint/vec_utils.dart';
import 'package:vector_math/vector_math_64.dart' show Matrix4;

abstract class Camera {
  Vec3d get position;
  Matrix4 get viewMatrix;
}

class FPSCamera implements Camera {
  Vec3d position;
  Vec3d upDir;
  Vec3d target;
  double yaw = 0.0;

  FPSCamera(this.position, this.target, this.upDir);

  Vec3d get forward {
    return vecMul(lookDir, 3.0);
  }

  Vec3d get lookDir {
    var rotation = makeRotationY(yaw);
    return matXvec(rotation, target);
  }

  Matrix4 get cameraMatrix {
    return matPointAt(position, vecAdd(position, lookDir), upDir);
  }

  Matrix4 get viewMatrix {
    return matQuickInvesre(cameraMatrix);
  }

  void movePosY(double delta) {
    position.y += delta;
  }

  void movePosX(double delta) {
    position.x += delta;
  }

  void turn(double delta) {
    yaw += delta;
  }

  void moveForward() {
    position = vecAdd(position, forward);
  }

  void moveBackward() {
    position = vecSub(position, forward);
  }
}

class MovePosY implements Command<FPSCamera> {
  double delta;

  MovePosY(this.delta);

  @override
  void execute(FPSCamera actor) {
    actor.movePosY(delta);
  }
}
