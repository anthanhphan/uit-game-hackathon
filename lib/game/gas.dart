import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

import '/game/dino_run.dart';
import '/models/gas_data.dart';

// This represents an gas in the game world.
class Gas extends SpriteAnimationComponent
    with CollisionCallbacks, HasGameRef<DinoRun> {
  // The data required for creation of this gas.
  final GasData gasData;

  Gas(this.gasData) {
    animation = SpriteAnimation.fromFrameData(
      gasData.image,
      SpriteAnimationData.sequenced(
        amount: gasData.nFrames,
        stepTime: gasData.stepTime,
        textureSize: gasData.textureSize,
      ),
    );
  }

  @override
  void onMount() {
    // Reduce the size of gas as they look too
    // big compared to the dino.
    size *= 0.6;

    // Add a hitbox for this gas.
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
    position.x -= gasData.speedX * dt;

    // Remove the gas and increase player score
    // by 1, if gas has gone past left end of the screen.
    if (position.x < -gasData.textureSize.x) {
      removeFromParent();
    }

    super.update(dt);
  }
}
