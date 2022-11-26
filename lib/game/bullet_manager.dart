import 'dart:math';
import 'dart:ui';

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
  // final Timer _timer = Timer(3, repeat: true);

  // BulletManager() {
  //   _timer.onTick = spawnBullet;
  // }

  // This method is responsible for spawning a random enemy.
  Bullet spawnBullet(double bulletX, double bulletY, Image bulletImage,
      Vector2 bulletSize, double speed) {
    if (_data.isNotEmpty) {
      removeFromParent();
    }
    _data.add(
      BulletData(
        image: bulletImage,
        nFrames: 1,
        stepTime: 0.1,
        textureSize: bulletSize,
        speedX: speed,
        canFly: false,
      ),
    );

    final randomIndex = _random.nextInt(_data.length);
    final bulletData = _data.elementAt(randomIndex);
    final bullet = Bullet(bulletData);

    // Help in setting all enemies on ground.
    bullet.anchor = Anchor.bottomLeft;
    bullet.position = Vector2(
      bulletX,
      30,
    );

    // Due to the size of our viewport, we can
    // use textureSize as size for the components.
    bullet.size = bulletData.textureSize;
    return bullet;
  }

  //
  @override
  void onMount() {
    if (isMounted) {
      removeFromParent();
    }

    // Don't fill list again and again on every mount.
    if (_data.isEmpty) {
      // As soon as this component is mounted, initilize all the data.
    }
    super.onMount();
  }

  void removeAllEnemies() {
    final enemies = gameRef.children.whereType<Bullet>();
    for (var enemy in enemies) {
      enemy.removeFromParent();
    }
  }
}
