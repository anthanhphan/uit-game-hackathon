import 'dart:math';

import 'package:flame/components.dart';

import '/game/gas.dart';
import '/game/dino_run.dart';
import '/models/gas_data.dart';

// This class is responsible for spawning random enemies at certain
// interval of time depending upon players current score.
class GasManager extends Component with HasGameRef<DinoRun> {
  // A list to hold data for all the enemies.
  final List<GasData> _data = [];

  // Random generator required for randomly selecting enemy type.
  final Random _random = Random();

  // Timer to decide when to spawn next enemy.
  final Timer _timer = Timer(5, repeat: true);

  GasManager() {
    _timer.onTick = spawnRandomEnemy;
  }

  // This method is responsible for spawning a random enemy.
  void spawnRandomEnemy() {
    /// Generate a random index within [_data] and get an [EnemyData].
    final randomIndex = _random.nextInt(_data.length);
    final gasData = _data.elementAt(randomIndex);
    final gas = Gas(gasData);

    // Help in setting all enemies on ground.
    gas.anchor = Anchor.bottomLeft;
    gas.position = Vector2(
      gameRef.size.x + 32,
      gameRef.size.y - 24,
    );

    // If this enemy can fly, set its y position randomly.
    if (gasData.canFly) {
      final newHeight = _random.nextDouble() * 2 * gasData.textureSize.y;
      gas.position.y -= newHeight;
    }

    // Due to the size of our viewport, we can
    // use textureSize as size for the components.
    gas.size = gasData.textureSize;
    gameRef.add(gas);
  }

  @override
  void onMount() {
    if (isMounted) {
      removeFromParent();
    }

    // Don't fill list again and again on every mount.
    if (_data.isEmpty) {
      // As soon as this component is mounted, initilize all the data.
      _data.addAll([
        GasData(
          image: gameRef.images.fromCache('Gas/Gas (46x50).png'),
          nFrames: 1,
          stepTime: 0.1,
          textureSize: Vector2(46, 50),
          speedX: 200,
          canFly: false,
        ),
      ]);
    }
    _timer.start();
    super.onMount();
  }

  @override
  void update(double dt) {
    _timer.update(dt);
    super.update(dt);
  }

  void removeAllObjects() {
    final enemies = gameRef.children.whereType<Gas>();
    for (var enemy in enemies) {
      enemy.removeFromParent();
    }
  }
}
