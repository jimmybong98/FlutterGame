import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(const MedievalSurvivalGame());
}

class MedievalSurvivalGame extends StatelessWidget {
  const MedievalSurvivalGame({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Medieval Survival RPG',
      theme: ThemeData(colorSchemeSeed: Colors.brown, useMaterial3: true),
      home: const GameScreen(),
    );
  }
}

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final GameState _gameState = GameState(seed: 42);

  void _movePlayer(Offset delta) {
    setState(() {
      _gameState.movePlayer(delta);
    });
  }

  void _attack() {
    setState(() {
      _gameState.attack();
    });
  }

  void _lootNearestCrate() {
    setState(() {
      _gameState.lootNearestCrate();
    });
  }

  void _upgrade(String stat) {
    setState(() {
      _gameState.upgrade(stat);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF101010),
      appBar: AppBar(
        title: const Text('Medieval Survival RPG'),
        backgroundColor: const Color(0xFF3B2C1F),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return CustomPaint(
                  size: Size(constraints.maxWidth, constraints.maxHeight),
                  painter: GamePainter(_gameState),
                );
              },
            ),
          ),
          _ControlPanel(
            state: _gameState,
            onMove: _movePlayer,
            onAttack: _attack,
            onLoot: _lootNearestCrate,
            onUpgrade: _upgrade,
          ),
        ],
      ),
    );
  }
}

class _ControlPanel extends StatelessWidget {
  const _ControlPanel({
    required this.state,
    required this.onMove,
    required this.onAttack,
    required this.onLoot,
    required this.onUpgrade,
  });

  final GameState state;
  final void Function(Offset delta) onMove;
  final VoidCallback onAttack;
  final VoidCallback onLoot;
  final void Function(String stat) onUpgrade;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      color: const Color(0xFF1B1B1B),
      child: Column(
        children: [
          Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: [
              _StatChip(label: 'HP', value: state.player.health),
              _StatChip(label: 'Armor', value: state.player.armor),
              _StatChip(label: 'Damage', value: state.player.damage),
              _StatChip(label: 'Level', value: state.player.level),
              _StatChip(label: 'Loot', value: state.inventory.length),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            state.logMessage,
            style: const TextStyle(color: Colors.white70),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _MovementControls(onMove: onMove),
              Column(
                children: [
                  ElevatedButton.icon(
                    onPressed: onAttack,
                    icon: const Icon(Icons.flash_on),
                    label: const Text('Attack'),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: onLoot,
                    icon: const Icon(Icons.inventory_2),
                    label: const Text('Loot Crate'),
                  ),
                ],
              ),
              Column(
                children: [
                  const Text('Upgrades', style: TextStyle(color: Colors.white)),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    children: [
                      _UpgradeButton(label: 'HP', onPressed: () => onUpgrade('hp')),
                      _UpgradeButton(label: 'Armor', onPressed: () => onUpgrade('armor')),
                      _UpgradeButton(label: 'Damage', onPressed: () => onUpgrade('damage')),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MovementControls extends StatelessWidget {
  const _MovementControls({required this.onMove});

  final void Function(Offset delta) onMove;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        IconButton(
          onPressed: () => onMove(const Offset(0, -1)),
          icon: const Icon(Icons.keyboard_arrow_up, color: Colors.white),
        ),
        Row(
          children: [
            IconButton(
              onPressed: () => onMove(const Offset(-1, 0)),
              icon: const Icon(Icons.keyboard_arrow_left, color: Colors.white),
            ),
            IconButton(
              onPressed: () => onMove(const Offset(1, 0)),
              icon: const Icon(Icons.keyboard_arrow_right, color: Colors.white),
            ),
          ],
        ),
        IconButton(
          onPressed: () => onMove(const Offset(0, 1)),
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
        ),
      ],
    );
  }
}

class _UpgradeButton extends StatelessWidget {
  const _UpgradeButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.white,
        side: const BorderSide(color: Colors.white24),
      ),
      child: Text(label),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.label, required this.value});

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Chip(
      backgroundColor: const Color(0xFF2C241C),
      label: Text(
        '$label: $value',
        style: const TextStyle(color: Colors.white),
      ),
    );
  }
}

class GamePainter extends CustomPainter {
  GamePainter(this.state);

  final GameState state;

  @override
  void paint(Canvas canvas, Size size) {
    const tileSize = 24.0;
    final viewport = _Viewport.fromPlayer(
      player: state.player.position,
      mapWidth: state.mapWidth,
      mapHeight: state.mapHeight,
      tileSize: tileSize,
      screenSize: size,
    );
    final paint = Paint()..style = PaintingStyle.fill;

    paint.color = const Color(0xFF2E241C);
    canvas.drawRect(Offset.zero & size, paint);

    for (var y = viewport.startY; y < viewport.endY; y++) {
      for (var x = viewport.startX; x < viewport.endX; x++) {
        final rect = Rect.fromLTWH(
          (x * tileSize) + viewport.offset.dx,
          (y * tileSize) + viewport.offset.dy,
          tileSize,
          tileSize,
        );
        _paintTerrain(canvas, rect, state.terrain[y][x]);
      }
    }

    for (final decoration in state.decorations) {
      if (!viewport.contains(decoration.position)) {
        continue;
      }
      final rect = _tileRect(decoration.position, tileSize, viewport.offset);
      switch (decoration.type) {
        case DecorationType.tree:
          _paintTree(canvas, rect, tileSize);
          break;
        case DecorationType.rock:
          _paintRock(canvas, rect, tileSize);
          break;
        case DecorationType.camp:
          _paintCamp(canvas, rect, tileSize);
          break;
      }
    }

    for (final crate in state.crates) {
      if (!viewport.contains(crate.position)) {
        continue;
      }
      _paintCrate(canvas, _tileRect(crate.position, tileSize, viewport.offset), crate.isOpened);
    }

    for (final enemy in state.enemies) {
      if (!viewport.contains(enemy.position)) {
        continue;
      }
      _paintEnemy(canvas, _tileCenter(enemy.position, tileSize, viewport.offset), tileSize, enemy);
    }

    _paintPlayer(
      canvas,
      _tileCenter(state.player.position, tileSize, viewport.offset),
      tileSize,
    );
  }

  void _paintTerrain(Canvas canvas, Rect rect, TerrainType type) {
    final paint = Paint()..style = PaintingStyle.fill;
    switch (type) {
      case TerrainType.grass:
        paint.shader = const LinearGradient(
          colors: [Color(0xFF3E5630), Color(0xFF566B45)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(rect);
        canvas.drawRect(rect, paint);
        paint.shader = null;
        paint.color = const Color(0xFF4A6B3D);
        canvas.drawCircle(rect.center + const Offset(4, -6), rect.width * 0.15, paint);
        break;
      case TerrainType.road:
        paint.shader = const LinearGradient(
          colors: [Color(0xFF4F3C2B), Color(0xFF6B523B)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(rect);
        canvas.drawRect(rect, paint);
        paint.shader = null;
        paint.color = const Color(0xFF3B2C1F);
        canvas.drawRect(rect.deflate(rect.width * 0.2), paint);
        break;
      case TerrainType.water:
        paint.shader = const LinearGradient(
          colors: [Color(0xFF1A3C5C), Color(0xFF356FA5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(rect);
        canvas.drawRect(rect, paint);
        paint.shader = null;
        paint.color = const Color(0xFF5EA4D8);
        canvas.drawArc(rect.deflate(rect.width * 0.1), 0.2, 2.1, false, paint);
        break;
      case TerrainType.forest:
        paint.shader = const LinearGradient(
          colors: [Color(0xFF1F3D2D), Color(0xFF325C44)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(rect);
        canvas.drawRect(rect, paint);
        paint.shader = null;
        paint.color = const Color(0xFF2E6A44);
        canvas.drawCircle(rect.center, rect.width * 0.18, paint);
        break;
      case TerrainType.sand:
        paint.shader = const LinearGradient(
          colors: [Color(0xFF8B7349), Color(0xFFB0955E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(rect);
        canvas.drawRect(rect, paint);
        paint.shader = null;
        paint.color = const Color(0xFFC4A76A);
        canvas.drawCircle(rect.center + const Offset(6, 6), rect.width * 0.12, paint);
        break;
    }
  }

  void _paintTree(Canvas canvas, Rect rect, double tileSize) {
    final trunkPaint = Paint()..color = const Color(0xFF5A3C2A);
    final leavesPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF1F6B3A), Color(0xFF3FA35C)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(rect);
    final shadowPaint = Paint()..color = Colors.black.withOpacity(0.25);
    canvas.drawOval(rect.shift(Offset(3, tileSize * 0.2)).deflate(tileSize * 0.2), shadowPaint);
    final trunk = Rect.fromCenter(
      center: rect.center + Offset(0, tileSize * 0.2),
      width: rect.width * 0.2,
      height: rect.height * 0.35,
    );
    canvas.drawRect(trunk, trunkPaint);
    canvas.drawCircle(rect.center + Offset(0, -tileSize * 0.12), rect.width * 0.4, leavesPaint);
  }

  void _paintRock(Canvas canvas, Rect rect, double tileSize) {
    final paint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF596066), Color(0xFF9AA1A8)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(rect);
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect.deflate(tileSize * 0.2), const Radius.circular(8)),
      paint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect.deflate(tileSize * 0.2), const Radius.circular(8)),
      Paint()
        ..color = Colors.black.withOpacity(0.25)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  void _paintCamp(Canvas canvas, Rect rect, double tileSize) {
    final firePaint = Paint()
      ..shader = const RadialGradient(
        colors: [Color(0xFFFFF2B0), Color(0xFFE58A2E), Color(0xFFB3471D)],
      ).createShader(rect);
    final logPaint = Paint()..color = const Color(0xFF6A4630);
    canvas.drawOval(rect.deflate(tileSize * 0.25), firePaint);
    canvas.drawRect(
      Rect.fromCenter(center: rect.center, width: rect.width * 0.7, height: rect.height * 0.12),
      logPaint,
    );
  }

  void _paintCrate(Canvas canvas, Rect rect, bool opened) {
    final cratePaint = Paint()
      ..shader = LinearGradient(
        colors: opened
            ? [const Color(0xFF5C4B3E), const Color(0xFF6B5B4D)]
            : [const Color(0xFF8C5C2D), const Color(0xFFB1783E)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(rect);
    final outlinePaint = Paint()
      ..color = const Color(0xFF2E2015)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(6)), cratePaint);
    canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(6)), outlinePaint);
    if (!opened) {
      final latch = Rect.fromCenter(center: rect.center, width: rect.width * 0.2, height: rect.height * 0.1);
      canvas.drawRect(latch, Paint()..color = const Color(0xFFE3C177));
    }
  }

  void _paintEnemy(Canvas canvas, Offset center, double tileSize, Enemy enemy) {
    final bodyRect = Rect.fromCenter(center: center, width: tileSize * 0.6, height: tileSize * 0.65);
    final basePaint = Paint()
      ..shader = LinearGradient(
        colors: enemy.type == EnemyType.zombie
            ? [const Color(0xFF3E8A54), const Color(0xFF6ED98C)]
            : [const Color(0xFFB1453F), const Color(0xFFE98A6F)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(bodyRect);
    final outlinePaint = Paint()
      ..color = const Color(0xFF1B1B1B)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawShadow(Path()..addOval(bodyRect), Colors.black, 4, true);
    canvas.drawRRect(RRect.fromRectAndRadius(bodyRect, const Radius.circular(8)), basePaint);
    canvas.drawRRect(RRect.fromRectAndRadius(bodyRect, const Radius.circular(8)), outlinePaint);
    canvas.drawCircle(center + Offset(0, -tileSize * 0.28), tileSize * 0.16, basePaint);
    if (enemy.isBoss) {
      canvas.drawCircle(center + Offset(0, -tileSize * 0.45), tileSize * 0.09, Paint()..color = Colors.amber);
    }
  }

  void _paintPlayer(Canvas canvas, Offset center, double tileSize) {
    final bodyRect = Rect.fromCenter(center: center, width: tileSize * 0.62, height: tileSize * 0.7);
    final armorPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF2C6CA3), Color(0xFF5CB0E6)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(bodyRect);
    final shieldPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF9B7B3E), Color(0xFFD8B56E)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(bodyRect);
    final outlinePaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawShadow(Path()..addOval(bodyRect), Colors.black, 6, true);
    canvas.drawRRect(RRect.fromRectAndRadius(bodyRect, const Radius.circular(8)), armorPaint);
    canvas.drawRRect(RRect.fromRectAndRadius(bodyRect, const Radius.circular(8)), outlinePaint);
    canvas.drawCircle(center + Offset(0, -tileSize * 0.32), tileSize * 0.18, armorPaint);
    final shield = Path()
      ..moveTo(center.dx + tileSize * 0.26, center.dy - tileSize * 0.1)
      ..lineTo(center.dx + tileSize * 0.42, center.dy + tileSize * 0.05)
      ..lineTo(center.dx + tileSize * 0.32, center.dy + tileSize * 0.3)
      ..lineTo(center.dx + tileSize * 0.18, center.dy + tileSize * 0.05)
      ..close();
    canvas.drawPath(shield, shieldPaint);
    canvas.drawPath(shield, outlinePaint);
  }

  Rect _tileRect(Point<int> position, double tileSize, Offset cameraOffset) {
    return Rect.fromLTWH(
      position.x * tileSize + tileSize * 0.1 + cameraOffset.dx,
      position.y * tileSize + tileSize * 0.1 + cameraOffset.dy,
      tileSize * 0.8,
      tileSize * 0.8,
    );
  }

  Offset _tileCenter(Point<int> position, double tileSize, Offset cameraOffset) {
    return Offset(
      position.x * tileSize + tileSize * 0.5 + cameraOffset.dx,
      position.y * tileSize + tileSize * 0.5 + cameraOffset.dy,
    );
  }

  @override
  bool shouldRepaint(covariant GamePainter oldDelegate) => true;
}

class _Viewport {
  _Viewport({
    required this.startX,
    required this.startY,
    required this.endX,
    required this.endY,
    required this.offset,
  });

  final int startX;
  final int startY;
  final int endX;
  final int endY;
  final Offset offset;

  bool contains(Point<int> point) {
    return point.x >= startX && point.x < endX && point.y >= startY && point.y < endY;
  }

  static _Viewport fromPlayer({
    required Point<int> player,
    required int mapWidth,
    required int mapHeight,
    required double tileSize,
    required Size screenSize,
  }) {
    final tilesWide = (screenSize.width / tileSize).ceil() + 2;
    final tilesHigh = (screenSize.height / tileSize).ceil() + 2;
    final halfWide = (tilesWide / 2).floor();
    final halfHigh = (tilesHigh / 2).floor();
    final startX = (player.x - halfWide).clamp(0, max(0, mapWidth - tilesWide));
    final startY = (player.y - halfHigh).clamp(0, max(0, mapHeight - tilesHigh));
    final endX = min(mapWidth, startX + tilesWide);
    final endY = min(mapHeight, startY + tilesHigh);
    final offset = Offset(-startX * tileSize, -startY * tileSize);
    return _Viewport(
      startX: startX,
      startY: startY,
      endX: endX,
      endY: endY,
      offset: offset,
    );
  }
}

enum TerrainType { grass, road, water, forest, sand }

enum DecorationType { tree, rock, camp }

class GameState {
  GameState({required int seed})
      : random = Random(seed),
        player = Player(position: const Point(60, 40)) {
    _generateWorld();
  }

  final Random random;
  final Player player;
  final int mapWidth = 120;
  final int mapHeight = 80;
  final List<Crate> crates = [];
  final List<Enemy> enemies = [];
  final List<Decoration> decorations = [];
  final List<String> inventory = [];
  final List<List<TerrainType>> terrain = [];
  final Set<Point<int>> roadTiles = {};
  String logMessage = 'Explore the medieval frontier and survive.';

  void _generateWorld() {
    _generateTerrain();
    _carveRoads();

    for (var i = 0; i < 80; i++) {
      crates.add(Crate(position: _randomOpenTile()));
    }

    for (var i = 0; i < 70; i++) {
      decorations.add(Decoration(position: _randomOpenTile(), type: DecorationType.tree));
    }

    for (var i = 0; i < 40; i++) {
      decorations.add(Decoration(position: _randomOpenTile(), type: DecorationType.rock));
    }

    for (var i = 0; i < 12; i++) {
      decorations.add(Decoration(position: _randomOpenTile(), type: DecorationType.camp));
    }

    for (var i = 0; i < 18; i++) {
      enemies.add(Enemy(
        type: EnemyType.human,
        position: _randomOpenTile(),
        isBoss: i == 0 || i == 9,
      ));
    }

    for (var i = 0; i < 22; i++) {
      enemies.add(Enemy(
        type: EnemyType.zombie,
        position: _randomOpenTile(),
        isBoss: i == 0 || i == 21,
      ));
    }
  }

  void _generateTerrain() {
    terrain.clear();
    for (var y = 0; y < mapHeight; y++) {
      final row = <TerrainType>[];
      for (var x = 0; x < mapWidth; x++) {
        final height = _fractalNoise(x, y, scale: 0.08, octaves: 4);
        final moisture = _fractalNoise(x + 200, y + 200, scale: 0.1, octaves: 3);
        if (height < 0.32) {
          row.add(TerrainType.water);
        } else if (height < 0.38) {
          row.add(TerrainType.sand);
        } else if (height < 0.75 && moisture > 0.62) {
          row.add(TerrainType.forest);
        } else {
          row.add(TerrainType.grass);
        }
      }
      terrain.add(row);
    }
  }

  void _carveRoads() {
    final pathStarts = [
      Point(10, mapHeight ~/ 2),
      Point(mapWidth ~/ 2, 10),
      Point(mapWidth - 12, mapHeight - 12),
    ];
    for (final start in pathStarts) {
      var current = start;
      for (var step = 0; step < 120; step++) {
        roadTiles.add(current);
        terrain[current.y][current.x] = TerrainType.road;
        final dx = random.nextInt(3) - 1;
        final dy = random.nextInt(3) - 1;
        final next = Point(
          (current.x + dx).clamp(1, mapWidth - 2),
          (current.y + dy).clamp(1, mapHeight - 2),
        );
        current = next;
      }
    }
  }

  double _fractalNoise(int x, int y, {required double scale, required int octaves}) {
    var value = 0.0;
    var amplitude = 1.0;
    var frequency = 1.0;
    var maxValue = 0.0;
    for (var i = 0; i < octaves; i++) {
      value += _valueNoise(x * scale * frequency, y * scale * frequency) * amplitude;
      maxValue += amplitude;
      amplitude *= 0.5;
      frequency *= 2.0;
    }
    return value / maxValue;
  }

  double _valueNoise(double x, double y) {
    final xi = x.floor();
    final yi = y.floor();
    final xf = x - xi;
    final yf = y - yi;

    final topLeft = _hash(xi, yi);
    final topRight = _hash(xi + 1, yi);
    final bottomLeft = _hash(xi, yi + 1);
    final bottomRight = _hash(xi + 1, yi + 1);

    final u = _fade(xf);
    final v = _fade(yf);

    final top = _lerp(topLeft, topRight, u);
    final bottom = _lerp(bottomLeft, bottomRight, u);
    return _lerp(top, bottom, v);
  }

  double _hash(int x, int y) {
    var n = x * 374761393 + y * 668265263;
    n = (n ^ (n >> 13)) * 1274126177;
    return ((n ^ (n >> 16)) & 0x7fffffff) / 0x7fffffff;
  }

  double _fade(double t) => t * t * (3 - 2 * t);

  double _lerp(double a, double b, double t) => a + (b - a) * t;

  Point<int> _randomOpenTile() {
    Point<int> position;
    do {
      position = Point(random.nextInt(mapWidth), random.nextInt(mapHeight));
    } while (_isOccupied(position));
    return position;
  }

  bool _isOccupied(Point<int> position) {
    return position == player.position ||
        crates.any((crate) => crate.position == position) ||
        enemies.any((enemy) => enemy.position == position) ||
        decorations.any((decor) => decor.position == position);
  }

  void movePlayer(Offset delta) {
    final next = Point<int>(
      (player.position.x + delta.dx.toInt()).clamp(0, mapWidth - 1),
      (player.position.y + delta.dy.toInt()).clamp(0, mapHeight - 1),
    );
    player.position = next;
    logMessage = 'Moved to ${next.x}, ${next.y}.';
    _resolveNearbyThreats();
  }

  void _resolveNearbyThreats() {
    final nearby = enemies.where((enemy) => _distance(enemy.position, player.position) <= 1.5);
    if (nearby.isNotEmpty) {
      final enemy = nearby.first;
      player.health = max(0, player.health - max(1, enemy.damage - player.armor));
      logMessage = '${enemy.name} strikes! HP now ${player.health}.';
    }
  }

  void attack() {
    final target = enemies
        .where((enemy) => _distance(enemy.position, player.position) <= 2)
        .toList();
    if (target.isEmpty) {
      logMessage = 'No enemies in range.';
      return;
    }
    final enemy = target.first;
    enemy.health -= player.damage;
    logMessage = 'You hit ${enemy.name} for ${player.damage}.';
    if (enemy.health <= 0) {
      enemies.remove(enemy);
      player.level++;
      logMessage = '${enemy.name} defeated! Level ${player.level}.';
    }
  }

  void lootNearestCrate() {
    final crate = crates
        .where((crate) => !crate.isOpened)
        .firstWhere(
          (crate) => _distance(crate.position, player.position) <= 1.5,
          orElse: () => Crate.invalid(),
        );
    if (crate.id == -1) {
      logMessage = 'No unopened crate nearby.';
      return;
    }
    crate.isOpened = true;
    final item = _rollLoot();
    inventory.add(item);
    _applyLoot(item);
    logMessage = 'Looted $item. Inventory size ${inventory.length}.';
  }

  String _rollLoot() {
    const lootTable = [
      'Leather Armor',
      'Iron Armor',
      'Steel Sword',
      'War Axe',
      'Healing Herb',
      'Crossbow',
      'Chainmail',
    ];
    return lootTable[random.nextInt(lootTable.length)];
  }

  void _applyLoot(String item) {
    if (item.contains('Armor')) {
      player.armor += 1;
    } else if (item.contains('Sword') || item.contains('Axe') || item.contains('Crossbow')) {
      player.damage += 1;
    } else if (item.contains('Healing')) {
      player.health += 3;
    }
  }

  void upgrade(String stat) {
    if (player.level <= 0) {
      logMessage = 'Earn levels by defeating enemies.';
      return;
    }
    switch (stat) {
      case 'hp':
        player.health += 5;
        break;
      case 'armor':
        player.armor += 1;
        break;
      case 'damage':
        player.damage += 1;
        break;
    }
    player.level -= 1;
    logMessage = 'Upgraded $stat. Remaining level ${player.level}.';
  }

  double _distance(Point<int> a, Point<int> b) {
    final dx = a.x - b.x;
    final dy = a.y - b.y;
    return sqrt(dx * dx + dy * dy);
  }
}

class Player {
  Player({required this.position});

  Point<int> position;
  int health = 20;
  int armor = 1;
  int damage = 3;
  int level = 0;
}

class Crate {
  Crate({required this.position}) : id = _nextId++;

  Crate.invalid()
      : id = -1,
        position = const Point(-1, -1);

  static int _nextId = 0;
  final int id;
  final Point<int> position;
  bool isOpened = false;
}

class Decoration {
  Decoration({required this.position, required this.type});

  final Point<int> position;
  final DecorationType type;
}

enum EnemyType { human, zombie }

class Enemy {
  Enemy({required this.type, required this.position, required this.isBoss});

  final EnemyType type;
  final Point<int> position;
  final bool isBoss;
  int health = 10;
  int damage = 3;

  String get name => isBoss
      ? (type == EnemyType.zombie ? 'Zombie Warlord' : 'Bandit Captain')
      : (type == EnemyType.zombie ? 'Zombie' : 'Raider');
}
