import 'dart:math';

import 'package:flame/components.dart';

import '/game/bullet.dart';
import '/game/dino_run.dart';
import '/models/bullet_data.dart';

// This class is responsible for spawning random enemies at certain
// interval of time depending upon players current score.
class BulletManager extends Component with HasGameRef<DinoRun> {
  // A list to hold data for all the enemies.
  final List<BulletData> _data = [];

  // Random generator required for randomly selecting enemy type.
  final Random _random = Random();

  // Timer to decide when to spawn next enemy.
  final Timer _timer = Timer(3, repeat: true);

  BulletManager() {
    _timer.onTick = spawnBullet;
  }

  // This method is responsible for spawning a random enemy.
  void spawnBullet() {
    final randomIndex = _random.nextInt(_data.length);
    final bulletData = _data.elementAt(randomIndex);
    final bonus = Bullet(bulletData);

    // Help in setting all enemies on ground.
    bonus.anchor = Anchor.bottomLeft;
    bonus.position = Vector2(
      gameRef.size.x - 62,
      gameRef.size.y - 24,
    );

    // Due to the size of our viewport, we can
    // use textureSize as size for the components.
    bonus.size = bulletData.textureSize;
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
      _data.add(
        BulletData(
          image: gameRef.images.fromCache('Bullet/fire_bullet.png'),
          nFrames: 1,
          stepTime: 0.1,
          textureSize: Vector2(100, 30),
          speedX: 550,
          canFly: false,
        ),
        );
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
    final enemies = gameRef.children.whereType<Bullet>();
    for (var enemy in enemies) {
      enemy.removeFromParent();
    }
  }
}
