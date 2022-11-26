import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

import '/game/dino_run.dart';
import '/models/bonus_data.dart';

// This represents an enemy in the game world.
class Bonus extends SpriteAnimationComponent
    with CollisionCallbacks, HasGameRef<DinoRun> {
  // The data required for creation of this enemy.
  final BonusData bossData;

  Bonus(this.bossData) {
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
    size *= 0.6;

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
    position.x -= bossData.speedX * dt;

    // Remove the enemy and increase player score
    // by 1, if enemy has gone past left end of the screen.
    if (position.x < -bossData.textureSize.x) {
      removeFromParent();
    }

    super.update(dt);
  }
}
