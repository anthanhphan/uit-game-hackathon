import 'package:dino_run/game/dino_run.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

// //
// //
// // Bullet class is a PositionComponent so we get the angle and position of the
// // element.
// class Bullet extends PositionComponent with HasGameRef<DinoRun> {
//   // color of the bullet
//   late Image _paint;
//   // the bullet speed in pixles per second
//   final double _speed = 150;
//   // velocity vector for the bullet.
//   late Vector2 _velocity;
//
//   //
//   // default constructor with default values
//   Bullet(Vector2 position, Vector2 velocity)
//       : _velocity = velocity,
//         super(
//           position: position,
//           size: Vector2.all(4), // 2x2 bullet
//           anchor: Anchor.center,
//         );
//
//   @override
//   Future<void> onMount() async {
//     await super.onLoad();
//     // _velocity is a unit vector so we need to make it account for the actual
//     // speed.
//     _velocity = (_velocity)..scaleTo(_speed);
//     // _paint = gameRef.images.fromCache('Bat/Flying (92x60).png');
//
//     // Reduce the size of enemy as they look too
//     // big compared to the dino.
//     size *= 0.6;
//
//     // Add a hitbox for this enemy.
//     add(
//       RectangleHitbox.relative(
//         Vector2.all(0.8),
//         parentSize: size,
//         position: Vector2(size.x * 0.2, size.y * 0.2) / 2,
//       ),
//     );
//     super.onMount();
//   }
//
//   @override
//   void render(Canvas canvas) {
//     super.render(canvas);
//   }
//
//   @override
//   void update(double dt) {
//     position.add(_velocity * dt);
//   }
// }
