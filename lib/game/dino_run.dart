import 'package:dino_run/game/bullet_manager.dart';
import 'package:dino_run/widgets/end_game.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:hive/hive.dart';
import 'package:flame/parallax.dart';
import 'package:flutter/material.dart';
import 'package:flame/components.dart';

import '/game/dino.dart';
import '/widgets/hud.dart';
import '/models/settings.dart';

import '/game/audio_manager.dart';
import '/game/enemy_manager.dart';
import '/game/friend_manager.dart';
import '/game/gas_manager.dart';
import '/game/boss_manager.dart';
import '/game/bonus_manager.dart';

import '/models/player_data.dart';
import '/widgets/pause_menu.dart';
import '/widgets/shop_menu.dart';
import '/widgets/game_over_menu.dart';

// This is the main flame game class.
class DinoRun extends FlameGame with TapDetector, HasCollisionDetection {
  // List of all the image assets.
  static const _imageAssets = [
    'DinoSprites - tard.png',
    'Bat/Flying (92x60).png',
    'Rino/Run (52x34).png',
    'Gas/Gas (46x50).png',
    'Tincan/Tincan (36x30).png',
    'Paper/Paper (32x35).png',
    'Owl/Owl (45x45).png',
    'Penguin/Penguin (25x25).png',
    'Tree/Tree (50x60).png',
    'Bush/Bush (35x30).png',
    'Bread/Bread (24x25).png',
    'Monster/Monster (95x92).png',
    'parallax/plx-1.png',
    'parallax/plx-2.png',
    'parallax/plx-3.png',
    'parallax/plx-4.png',
    'parallax/plx-5.png',
    'parallax/plx-6.png',
    'Bullet/fire_bullet.png',
    'Bullet/blue_flame.png',
  ];

  // List of all the audio assets.
  static const _audioAssets = [
    '8BitPlatformerLoop.wav',
    'hurt7.wav',
    'jump14.wav',
  ];

  late Dino _dino;
  late Settings settings;
  late PlayerData playerData;
  late EnemyManager _enemyManager;
  late FriendManager _friendManager;
  late GasManager _gasManager;
  late BossManager _bossManager;
  late BonusManager _bonusManager;
  late BulletManager _bulletManager;

  @override
  late bool isLoaded;
  late Vector2 parallaxSpeed;
  late ParallaxComponent parallaxBackground;

  // This method get called while flame is preparing this game.
  @override
  Future<void> onLoad() async {
    parallaxSpeed = Vector2(10, 0);
    isLoaded = false;

    /// Read [PlayerData] and [Settings] from hive.
    playerData = await _readPlayerData();
    settings = await _readSettings();

    /// Initilize [AudioManager].
    await AudioManager.instance.init(_audioAssets, settings);

    // Start playing background music. Internally takes care
    // of checking user settings.
    AudioManager.instance.startBgm('8BitPlatformerLoop.wav');

    // Cache all the images.
    await images.loadAll(_imageAssets);

    // Set a fixed viewport to avoid manually scaling
    // and handling different screen sizes.
    camera.viewport = FixedResolutionViewport(Vector2(360, 180));

    /// Create a [ParallaxComponent] and add it to game.
    parallaxBackground = await loadParallaxComponent(
      [
        ParallaxImageData('parallax/plx-1.png'),
        ParallaxImageData('parallax/plx-2.png'),
        ParallaxImageData('parallax/plx-3.png'),
        ParallaxImageData('parallax/plx-4.png'),
        ParallaxImageData('parallax/plx-5.png'),
        ParallaxImageData('parallax/plx-6.png'),
      ],
      baseVelocity: parallaxSpeed,
      velocityMultiplierDelta: Vector2(1.4, 0),
    );

    add(parallaxBackground);

    return super.onLoad();
  }

  /// This method add the already created [Dino]
  /// and [EnemyManager] to this game.
  void startGamePlay() async {
    _dino = Dino(images.fromCache('DinoSprites - tard.png'), playerData);
    _enemyManager = EnemyManager();
    _bossManager = BossManager();
    _friendManager = FriendManager();
    _gasManager = GasManager();
    _bonusManager = BonusManager();
    _bulletManager = BulletManager();
    isLoaded = false;

    parallaxBackground.removeFromParent();

    parallaxBackground = await loadParallaxComponent(
      [
        ParallaxImageData('parallax/plx-1.png'),
        ParallaxImageData('parallax/plx-2.png'),
        ParallaxImageData('parallax/plx-3.png'),
        ParallaxImageData('parallax/plx-4.png'),
        ParallaxImageData('parallax/plx-5.png'),
        ParallaxImageData('parallax/plx-6.png'),
      ],
      baseVelocity: Vector2(10, 0),
      velocityMultiplierDelta: Vector2(1.4, 0),
    );

    playerData.currentTime = 30;
    add(parallaxBackground);
    add(_dino);
    add(_enemyManager);
    add(_friendManager);
    add(_gasManager);
    add(_bonusManager);
  }

  // This method remove all the actors from the game.
  void _disconnectActors() {
    if (playerData.currentTime > 0) {
      _dino.removeFromParent();
      _enemyManager.removeAllObjects();
      _enemyManager.removeFromParent();

      _friendManager.removeAllObjects();
      _friendManager.removeFromParent();

      _gasManager.removeAllObjects();
      _gasManager.removeFromParent();

      _bonusManager.removeAllEnemies();
      _bonusManager.removeFromParent();
    } else {
      _dino.removeFromParent();
      _bossManager.removeAllEnemies();
      _bossManager.removeFromParent();
    }
  }

  // This method reset the whole game world to initial state.
  void reset() {
    // First disconnect all actions from game world.
    _disconnectActors();

    // Reset player data to inital values.
    playerData.currentScore = 0;
    playerData.currentTime = 30;
    playerData.lives = 5;
    playerData.bosshp = 10;
  }

  // This method gets called for each tick/frame of the game.
  @override
  void update(double dt) async {
    // If number of lives is 0 or less, game is over.
    if (playerData.lives <= 0) {
      overlays.add(GameOverMenu.id);
      overlays.remove(Hud.id);
      pauseEngine();
      AudioManager.instance.pauseBgm();
    }

    if (playerData.bosshp <= 0) {
      overlays.add(EndGameMenu.id);
      overlays.remove(Hud.id);
      pauseEngine();
      AudioManager.instance.pauseBgm();
    }

    if (playerData.currentTime == 0.0 && !isLoaded) {
      overlays.add(ShopMenu.id);
      overlays.remove(Hud.id);
      pauseEngine();
      isLoaded = true;

      _enemyManager.removeAllObjects();
      _enemyManager.removeFromParent();

      _friendManager.removeAllObjects();
      _friendManager.removeFromParent();

      _gasManager.removeAllObjects();
      _gasManager.removeFromParent();

      _bonusManager.removeAllEnemies();
      _bonusManager.removeFromParent();

      _dino.removeFromParent();

      parallaxBackground.removeFromParent();

      parallaxBackground = await loadParallaxComponent(
        [
          ParallaxImageData('parallax/plx-1.png'),
          ParallaxImageData('parallax/plx-2.png'),
          ParallaxImageData('parallax/plx-3.png'),
          ParallaxImageData('parallax/plx-4.png'),
          ParallaxImageData('parallax/plx-5.png'),
          ParallaxImageData('parallax/plx-6.png'),
        ],
        baseVelocity: Vector2(0, 0),
        velocityMultiplierDelta: Vector2(1.4, 0),
      );

      _dino = Dino(images.fromCache('DinoSprites - tard.png'), playerData);
      _enemyManager = EnemyManager();
      _bossManager = BossManager();
      isLoaded = true;
      add(parallaxBackground);
      add(_dino);
      add(_bossManager);
      add(_bulletManager);
    }

    if (isLoaded) {
      playerData.currentTime = 0;
    }
    // print("out: ${playerData.currentTime}");

    super.update(dt);
  }

  // This will get called for each tap on the screen.
  @override
  void onTapDown(TapDownInfo info) {
    // Make dino jump only when game is playing.
    // When game is in playing state, only Hud will be the active overlay.
    if (overlays.isActive(Hud.id)) {
      _dino.jump();
    }
    super.onTapDown(info);
  }

  /// This method reads [PlayerData] from the hive box.
  Future<PlayerData> _readPlayerData() async {
    final playerDataBox =
        await Hive.openBox<PlayerData>('DinoRun.PlayerDataBox');
    final playerData = playerDataBox.get('DinoRun.PlayerData');

    // If data is null, this is probably a fresh launch of the game.
    if (playerData == null) {
      // In such cases store default values in hive.
      await playerDataBox.put('DinoRun.PlayerData', PlayerData());
    }

    // Now it is safe to return the stored value.
    return playerDataBox.get('DinoRun.PlayerData')!;
  }

  /// This method reads [Settings] from the hive box.
  Future<Settings> _readSettings() async {
    final settingsBox = await Hive.openBox<Settings>('DinoRun.SettingsBox');
    final settings = settingsBox.get('DinoRun.Settings');

    // If data is null, this is probably a fresh launch of the game.
    if (settings == null) {
      // In such cases store default values in hive.
      await settingsBox.put(
        'DinoRun.Settings',
        Settings(bgm: true, sfx: true),
      );
    }

    // Now it is safe to return the stored value.
    return settingsBox.get('DinoRun.Settings')!;
  }

  @override
  void lifecycleStateChange(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        // On resume, if active overlay is not PauseMenu,
        // resume the engine (lets the parallax effect play).
        if (!(overlays.isActive(PauseMenu.id)) &&
            !(overlays.isActive(GameOverMenu.id)) &&
            !(overlays.isActive(EndGameMenu.id))) {
          resumeEngine();
        }
        break;
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
      case AppLifecycleState.inactive:
        // If game is active, then remove Hud and add PauseMenu
        // before pausing the game.
        if (overlays.isActive(Hud.id)) {
          overlays.remove(Hud.id);
          overlays.add(PauseMenu.id);
        }
        pauseEngine();
        break;
    }
    super.lifecycleStateChange(state);
  }
}
