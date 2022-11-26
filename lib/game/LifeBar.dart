import 'package:flame/components.dart';
import 'package:flutter/material.dart';

/// relative placement enumeration
///
/// This allows the user to place the bar as either [left], [center], or [right]
/// in relation to the top left corner of the bounding rectangle of the parent.
enum LifeBarPlacement { left, center, right }

/// Class for represening a configurable Health Bar
///
/// It can be added to any other component through composability:
/// To add this component simply call the add() method in the parent
/// component.
/// ```dart
///   LifeBar myLifeBar = LifeBar.initData(size); \\ parent size is required
///   add(myLifeBar);
/// ```
///
/// The component is configurable through its named constructor.
/// Here is an example:
/// ```dart
///   LifeBar.initData(size                    \\ parent size
///       , size: Vector2(size.x - 10, 3)      \\ size of the bar you want
///       , placement: LifeBarPlacement.left); \\ relative placement of the bar
/// ```
///
/// Once the [LifeBar] has been edded to its parent you can notify it
/// about any changes to its life data by using either of these two methods:
/// ```dart
///   incrementCurrentLifeBy(int incrementValue)
///   decrementCurrentLifeBy(int decrementValue)
/// ```
class LifeBar extends PositionComponent {
  // default red color used for danger
  static const Color _redColor = Colors.red;

  // default green color used for healthy state
  static const Color _greenColor = Colors.green;

  // background color of the bar when the health element is missing
  static final Paint _backgroundFillColor = Paint()
    ..color = Colors.grey.withOpacity(0.35)
    ..style = PaintingStyle.fill;

  // the ourline of the bar color and style
  static final Paint _outlineColor = Paint()
    ..color = Colors.white
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1;

  // max allowable life value
  static const int _maxLife = 100;
  // default threshold separating a healthy bar from danger
  static const int _healthThreshold = 25;
  // default offset of the bar from the edge of the parent in pixels
  static const double _defaultBarOffset = 2;

  // internal state for the current life
  int _life = _maxLife;
  // the current color in the bar
  late Paint _color;
  // the set threshold for warning color to show up
  late int _warningThreshold;
  // the warning color being used
  late Paint _warningColorStyled;
  late Color _warningColor;
  // the hearlthy color being used
  late Paint _healthyColorStyled;
  late Color _healthyColor;
  // the size of this life bar
  late Vector2 _size;
  // the bounding rectangle for the parent's size
  late Vector2 _parentSize;
  // the number of pixels away form the parent's edge
  late double _barToParentOffset;
  // the placement of the bar in relation to the parent
  late LifeBarPlacement _placement;
  // the 3 rectangles that comprise the bar's rectangles
  List<RectangleComponent> _lifeBarElements = List<RectangleComponent>.filled(
      3, RectangleComponent(size: Vector2(1, 1)),
      growable: false);

  /// the only constructor
  ///
  /// **required parameters:**
  /// [parentsSize] initializes the component with teh size of the parent.
  ///
  /// **optional parameters:**
  /// if you want to chage the threshold of when the warning color kicks in you
  /// can set it with [warningThreshold]
  /// You can set the specific color of the warning with [warningColor] and
  /// also the specific color foe the healthy color with [healthyColor]
  /// If you want to set the specific size of the LifeBar you can do that with
  /// [size] and if you want the bar to be offset by a number of pixels away
  /// from the parent you can use [barOffset]
  /// In addition, you can specific if the bar should be placed in the center,
  /// ,left, or right relative to the upper right corner of the parent with the
  /// [placement] parameter
  ///
  LifeBar.initData(Vector2 parentSize,
      {int? warningThreshold,
      Color? warningColor,
      Color? healthyColor,
      Vector2? size,
      double? barOffset,
      LifeBarPlacement? placement}) {
    _warningColor = warningColor ?? _redColor;
    _warningThreshold = warningThreshold ?? _healthThreshold;
    _healthyColor = healthyColor ?? _greenColor;
    _parentSize = parentSize;
    _size = size ?? Vector2(_parentSize.x, 5);
    _barToParentOffset = barOffset ?? _defaultBarOffset;
    _placement = placement ?? LifeBarPlacement.left;

    /// additional data
    ///
    anchor = Anchor.center;
    _healthyColorStyled = Paint()
      ..color = _healthyColor
      ..style = PaintingStyle.fill;
    _warningColorStyled = Paint()
      ..color = _warningColor
      ..style = PaintingStyle.fill;

    _updateCurrentColor();
  }

  /// current life state [0..100]
  int get currentLife {
    return _life;
  }

  /// Direct method for setting the life state
  ///
  /// [value] being set will be bounded into the [0.100] range
  set currentLife(int value) {
    if (value > _maxLife) {
      _life = _maxLife;
    } else if (value < 0) {
      _life = 0;
    } else {
      _life = value;
    }
  }

  /// Notification for the component to update its life data
  ///
  /// This will increment the current value by [incrementValue] with the
  /// provision that it cannot be larger than maximum life.
  void incrementCurrentLifeBy(int incrementValue) {
    currentLife = _life + incrementValue;
  }

  /// Notification for the component to update its life data
  ///
  /// This will decrement the current value by [decrementValue] wuth the
  /// provision that it cannot be smaller than 0 - which is the minimum life.
  void decrementCurrentLifeBy(int decrementValue) {
    currentLife = _life - decrementValue;
  }

  /// get the color used for warning
  ///
  Color get warningColor {
    return _warningColorStyled.color;
  }

  /// get the color used for good health
  Color get healthyColor {
    return _healthyColorStyled.color;
  }

  /// determine the bar color based on current state
  ///
  void _updateCurrentColor() {
    if (_life < _warningThreshold) {
      _color = _warningColorStyled;
    } else {
      _color = _healthyColorStyled;
    }
  }

  /// Helper method to calculate the position of the bar relative to the parent
  ///
  Vector2 _calculateBarPosition() {
    Vector2 result;

    switch (_placement) {
      case LifeBarPlacement.left:
        {
          result = Vector2(0, -_size.y - _barToParentOffset);
        }
        break;
      case LifeBarPlacement.center:
        {
          result = Vector2(
              (_parentSize.x - _size.x) / 2, -_size.y - _barToParentOffset);
        }
        break;
      case LifeBarPlacement.right:
        {
          result =
              Vector2(_parentSize.x - _size.x, -_size.y - _barToParentOffset);
        }
        break;
    }

    return result;
  }

  @override

  /// create the actual bar visuals based on the initialization data
  ///
  Future<void>? onLoad() {
    // All positions here are in relation to the parent's position
    _lifeBarElements = [
      //
      // The outline of the life bar
      RectangleComponent(
        position: _calculateBarPosition(),
        size: _size,
        angle: 0,
        paint: _outlineColor,
      ),
      //
      // The fill portion of the bar. The semi-transparent portion
      RectangleComponent(
        position: _calculateBarPosition(),
        size: _size,
        angle: 0,
        paint: _backgroundFillColor,
      ),
      //
      // The actual life percentage as a fill of red or green
      RectangleComponent(
        position: _calculateBarPosition(),
        size: Vector2(40, _size.y),
        angle: 0,
        paint: _color,
      ),
    ];
    addAll(_lifeBarElements);
    return super.onLoad();
  }

  @override

  /// Update the state of the bar with reference to its color
  ///
  void update(double dt) {
    _updateCurrentColor();
    print('${_life}');
    _lifeBarElements[2].paint = _color;
    _lifeBarElements[2].size.x = (_size.x / _maxLife) * _life;
    super.update(dt);
  }
}
