import 'package:flame/extensions.dart';

// This class stores all the data
// necessary for creation of an enemy.
class BulletData {
  final Image image;
  final int nFrames;
  final double stepTime;
  final Vector2 textureSize;
  final double speedX;
  final bool canFly;

  const BulletData({
    required this.image,
    required this.nFrames,
    required this.stepTime,
    required this.textureSize,
    required this.speedX,
    required this.canFly,
  });
}
