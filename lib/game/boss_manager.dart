// ignore_for_file: unnecessary_brace_in_string_interps, avoid_print

import 'dart:math';

import 'package:flame/components.dart';

import '/game/boss.dart';
import '/game/dino_run.dart';
import '/models/boss_data.dart';

// This class is responsible for spawning random enemies at certain
// interval of time depending upon players current score.
class BossManager extends Component with HasGameRef<DinoRun> {
  double yMax = 0.0;
  double speedY = 0.0;
  late double positionY;

  static const double gravity = 1000;

  // A list to hold data for all the enemies.
  final List<BossData> _data = [];

  // Random generator required for randomly selecting enemy type.
  final Random _random = Random();

  // Timer to decide when to spawn next enemy.
  final Timer _timer = Timer(2, repeat: false);

  final Timer _bossJump = Timer(2, repeat: true);

  BossManager() {
    _timer.onTick = spawnRandomEnemy;
    _bossJump.onTick = () {
      speedY = -300;
    };
  }

  // This method is responsible for spawning a random enemy.
  void spawnRandomEnemy() {
    /// Generate a random index within [_data] and get an [BossData].
    final randomIndex = _random.nextInt(_data.length);
    final bossData = _data.elementAt(randomIndex);
    final boss = Boss(bossData);

    // Help in setting all enemies on ground.
    boss.anchor = Anchor.bottomLeft;
    boss.position = Vector2(
      gameRef.size.x - 62,
      gameRef.size.y - 15,
    );

    // Due to the size of our viewport, we can
    // use textureSize as size for the components.
    boss.size = bossData.textureSize;
    gameRef.add(boss);
  }

  @override
  void onMount() {
    if (isMounted) {
      removeFromParent();
    }

    positionY = gameRef.size.y - 24;
    print('positionY: ${positionY}');

    // Don't fill list again and again on every mount.
    if (_data.isEmpty) {
      // As soon as this component is mounted, initilize all the data.
      _data.addAll([
        BossData(
          image: gameRef.images.fromCache('Monster/Monster (95x92).png'),
          nFrames: 7,
          stepTime: 0.1,
          textureSize: Vector2(95, 92),
          speedX: 0,
          speedY: 50,
          canFly: false,
        ),
      ]);
    }
    // _singleBullet.start();
    _timer.start();
    super.onMount();
  }

  @override
  void update(double dt) {
    speedY += gravity * dt;
    positionY += speedY * dt;

    _timer.update(dt);
    super.update(dt);
  }

  void removeAllEnemies() {
    final enemies = gameRef.children.whereType<Boss>();
    for (var enemy in enemies) {
      enemy.removeFromParent();
    }
  }
}
