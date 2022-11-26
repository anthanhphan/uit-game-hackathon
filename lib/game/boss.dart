import 'dart:ui';

import 'package:dino_run/game/bullet.dart';
import 'package:dino_run/game/bullet_manager.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '/game/dino_run.dart';
import '/models/boss_data.dart';

// This represents an enemy in the game world.
class Boss extends SpriteAnimationComponent
    with CollisionCallbacks, HasGameRef<DinoRun> {
  // The data required for creation of this enemy.

  List<RectangleComponent> lifeBarElements = List<RectangleComponent>.filled(
      3, RectangleComponent(size: Vector2(1, 1)),
      growable: false
  );

  createLifeBar() {
    var lifeBarSize = Vector2(24, 6);
    var backgroundFillColor = Paint()
      ..color = Colors.grey.withOpacity(0.35)
      ..style = PaintingStyle.fill;
    var outlineColor = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    var lifeDangerColor = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill;

    // All positions here are in relation to the parent's position
    lifeBarElements = [
      //
      // The outline of the life bar
      RectangleComponent(
        position: Vector2(size.x - lifeBarSize.x - 52, -lifeBarSize.y - 2),
        size: lifeBarSize,
        angle: 0,
        paint: outlineColor,
      ),
      //
      // The fill portion of the bar. The semi-transparent portion
      RectangleComponent(
        position: Vector2(size.x - lifeBarSize.x - 52, -lifeBarSize.y - 2),
        size: lifeBarSize,
        angle: 0,
        paint: backgroundFillColor,
      ),
      //
      // The actual life percentage as a fill of red or green
      RectangleComponent(
        position: Vector2(size.x - lifeBarSize.x - 52, -lifeBarSize.y - 2),
        size: Vector2(6, 6),
        angle: 0,
        paint: lifeDangerColor,
      ),
    ];

    //
    // add all lifebar elements to the children of the Square instance
    addAll(lifeBarElements);
  }

  final BossData bossData;

  final Timer _switchDirection = Timer(
    2,
    repeat: true,
  );
  late double positionY;
  late BulletManager _bulletCreation;

  bool _moveUp = true;

  final Timer _shootCountDown = Timer(1,
    repeat: true,
  );

  Boss(this.bossData) {
    animation = SpriteAnimation.fromFrameData(
      bossData.image,
      SpriteAnimationData.sequenced(
        amount: bossData.nFrames,
        stepTime: bossData.stepTime,
        textureSize: bossData.textureSize,
      ),
    );
  }

  @override
  void onMount() {
    // Reduce the size of enemy as they look too
    // big compared to the dino.
    createLifeBar();
    _bulletCreation = BulletManager();
    size *= 0.6;
    _switchDirection.onTick = () {
      _moveUp = !_moveUp;
    };

    print('positionx: ${position.x}');

    _shootCountDown.onTick = () {
      positionY = position.y;
      add(_bulletCreation.spawnBullet(gameRef.size.x - 28, 50, gameRef.images.fromCache('Bullet/fire_bullet.png')));
    };

    // Add a hitbox for this enemy.
    add(
      RectangleHitbox.relative(
        Vector2.all(0.8),
        parentSize: size,
        position: Vector2(size.x * 0.2, size.y * 0.2) / 2,
      ),
    );
    super.onMount();
  }

  @override
  void update(double dt) {
    // position.x -= bossData.speedX * dt;

    if (_moveUp) {
      position.y -= bossData.speedY * dt;
    } else {
      position.y += bossData.speedY * dt;
    }

    // Remove the enemy and increase player score
    // by 1, if enemy has gone past left end of the screen.
    if (position.x < -bossData.textureSize.x) {
      removeFromParent();
      gameRef.playerData.currentScore += 1;
    }
    _shootCountDown.update(dt);
    _switchDirection.update(dt);
    super.update(dt);
  }
}
