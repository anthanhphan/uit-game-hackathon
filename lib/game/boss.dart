import 'package:flame/geometry.dart';
import 'package:flame/components.dart';

import '/game/dino_run.dart';
import '/models/boss_data.dart';

// This represents an enemy in the game world.
class Boss extends SpriteAnimationComponent
    with HasHitboxes, Collidable, HasGameRef<DinoRun> {
  // The data required for creation of this enemy.
  final BossData bossData;

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
    // Add a hitbox for this enemy.
    final shape = HitboxRectangle(relation: Vector2.all(0.8));
    addHitbox(shape);
    // Reduce the size of enemy as they look too
    // big compared to the dino.
    size *= 0.6;
    super.onMount();
  }

  @override
  void update(double dt) {
    position.x -= bossData.speedX * dt;

    // Remove the enemy and increase player score
    // by 1, if enemy has gone past left end of the screen.
    if (position.x < -bossData.textureSize.x) {
      removeFromParent();
      gameRef.playerData.currentScore += 1;
    }

    super.update(dt);
  }
}
