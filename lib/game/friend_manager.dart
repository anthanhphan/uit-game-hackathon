import 'dart:math';

import 'package:flame/components.dart';

import '/game/friend.dart';
import '/game/dino_run.dart';
import '/models/friend_data.dart';

// This class is responsible for spawning random enemies at certain
// interval of time depending upon players current score.
class FriendManager extends Component with HasGameRef<DinoRun> {
  // A list to hold data for all the enemies.
  final List<FriendData> _data = [];

  // Random generator required for randomly selecting enemy type.
  final Random _random = Random();

  // Timer to decide when to spawn next enemy.
  final Timer _timer = Timer(7, repeat: true);

  FriendManager() {
    _timer.onTick = spawnRandomEnemy;
  }

  // This method is responsible for spawning a random enemy.
  void spawnRandomEnemy() {
    /// Generate a random index within [_data] and get an [EnemyData].
    final randomIndex = _random.nextInt(_data.length);
    final friendData = _data.elementAt(randomIndex);
    final friend = Friend(friendData);

    // Help in setting all enemies on ground.
    friend.anchor = Anchor.bottomLeft;
    friend.position = Vector2(
      gameRef.size.x + 32,
      gameRef.size.y - 24,
    );

    // If this enemy can fly, set its y position randomly.
    if (friendData.canFly) {
      final newHeight = _random.nextDouble() * 2 * friendData.textureSize.y;
      friend.position.y -= newHeight;
    }

    // Due to the size of our viewport, we can
    // use textureSize as size for the components.
    friend.size = friendData.textureSize;
    gameRef.add(friend);
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
        FriendData(
          image: gameRef.images.fromCache('Bread/Bread (24x25).png'),
          nFrames: 12,
          stepTime: 0.1,
          textureSize: Vector2(24, 25),
          speedX: 100,
          canFly: true,
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
    final enemies = gameRef.children.whereType<Friend>();
    for (var enemy in enemies) {
      enemy.removeFromParent();
    }
  }
}
