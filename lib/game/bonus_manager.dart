import 'dart:math';

import 'package:flame/components.dart';

import '/game/bonus.dart';
import '/game/dino_run.dart';
import '/models/bonus_data.dart';

// This class is responsible for spawning random enemies at certain
// interval of time depending upon players current score.
class BonusManager extends Component with HasGameRef<DinoRun> {
  // A list to hold data for all the enemies.
  final List<BonusData> _data = [];

  // Random generator required for randomly selecting enemy type.
  final Random _random = Random();

  // Timer to decide when to spawn next enemy.
  final Timer _timer = Timer(7, repeat: true);

  BonusManager() {
    _timer.onTick = spawnRandomEnemy;
  }

  // This method is responsible for spawning a random enemy.
  void spawnRandomEnemy() {
    /// Generate a random index within [_data] and get an [BossData].
    final randomIndex = _random.nextInt(_data.length);
    final bonusData = _data.elementAt(randomIndex);
    final bonus = Bonus(bonusData);

    // Help in setting all enemies on ground.
    bonus.anchor = Anchor.bottomLeft;
    bonus.position = Vector2(
      gameRef.size.x - 62,
      gameRef.size.y - 24,
    );

    // If this enemy can fly, set its y position randomly.
    if (bonusData.canFly) {
      final newHeight = _random.nextDouble() * 2 * bonusData.textureSize.y;
      bonus.position.y -= newHeight;
    }

    // Due to the size of our viewport, we can
    // use textureSize as size for the components.
    bonus.size = bonusData.textureSize;
    gameRef.add(bonus);
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
        BonusData(
          image: gameRef.images.fromCache('Tincan/Tincan (36x30).png'),
          nFrames: 6,
          stepTime: 0.1,
          textureSize: Vector2(36, 30),
          speedX: 150,
          canFly: false,
        ),
        BonusData(
            image: gameRef.images.fromCache('Paper/Paper (32x35).png'),
            nFrames: 10,
            stepTime: 0.1,
            textureSize: Vector2(32, 35),
            speedX: 170,
            canFly: true)
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

  void removeAllEnemies() {
    final enemies = gameRef.children.whereType<Bonus>();
    for (var enemy in enemies) {
      enemy.removeFromParent();
    }
  }
}
