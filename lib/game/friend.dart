import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

import '/game/dino_run.dart';
import '/models/friend_data.dart';

// This represents an enemy in the game world.
class Friend extends SpriteAnimationComponent
    with CollisionCallbacks, HasGameRef<DinoRun> {
  // The data required for creation of this enemy.
  final FriendData friendData;

  Friend(this.friendData) {
    animation = SpriteAnimation.fromFrameData(
      friendData.image,
      SpriteAnimationData.sequenced(
        amount: friendData.nFrames,
        stepTime: friendData.stepTime,
        textureSize: friendData.textureSize,
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
    position.x -= friendData.speedX * dt;

    // Remove the enemy and increase player score
    // by 1, if enemy has gone past left end of the screen.
    if (position.x < -friendData.textureSize.x) {
      removeFromParent();
      gameRef.playerData.currentScore += 1;
    }

    super.update(dt);
  }
}
