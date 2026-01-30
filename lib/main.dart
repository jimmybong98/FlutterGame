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
    final tileSize = min(size.width / state.mapWidth, size.height / state.mapHeight);
    final paint = Paint()..style = PaintingStyle.fill;

    paint.color = const Color(0xFF3E3A2D);
    canvas.drawRect(Offset.zero & size, paint);

    final grassPaint = Paint()..color = const Color(0xFF475034);
    final roadPaint = Paint()..color = const Color(0xFF5B4E3A);
    for (var y = 0; y < state.mapHeight; y++) {
      for (var x = 0; x < state.mapWidth; x++) {
        final tileOffset = Offset(x * tileSize, y * tileSize);
        final isRoad = state.roadTiles.contains(Point(x, y));
        canvas.drawRect(
          tileOffset & Size(tileSize, tileSize),
          isRoad ? roadPaint : grassPaint,
        );
      }
    }

    for (final crate in state.crates) {
      paint.color = crate.isOpened ? Colors.grey : const Color(0xFF9B6A3C);
      canvas.drawRect(_tileRect(crate.position, tileSize), paint);
    }

    for (final enemy in state.enemies) {
      paint.color = enemy.type == EnemyType.zombie ? Colors.greenAccent : Colors.redAccent;
      canvas.drawCircle(_tileCenter(enemy.position, tileSize), tileSize * 0.35, paint);
      if (enemy.isBoss) {
        paint.color = Colors.amber;
        canvas.drawCircle(_tileCenter(enemy.position, tileSize), tileSize * 0.15, paint);
      }
    }

    paint.color = Colors.blueAccent;
    canvas.drawCircle(
      _tileCenter(state.player.position, tileSize),
      tileSize * 0.4,
      paint,
    );
  }

  Rect _tileRect(Point<int> position, double tileSize) {
    return Rect.fromLTWH(
      position.x * tileSize + tileSize * 0.1,
      position.y * tileSize + tileSize * 0.1,
      tileSize * 0.8,
      tileSize * 0.8,
    );
  }

  Offset _tileCenter(Point<int> position, double tileSize) {
    return Offset(
      position.x * tileSize + tileSize * 0.5,
      position.y * tileSize + tileSize * 0.5,
    );
  }

  @override
  bool shouldRepaint(covariant GamePainter oldDelegate) => true;
}

class GameState {
  GameState({required int seed})
      : random = Random(seed),
        player = Player(position: const Point(20, 12)) {
    _generateWorld();
  }

  final Random random;
  final Player player;
  final int mapWidth = 40;
  final int mapHeight = 24;
  final List<Crate> crates = [];
  final List<Enemy> enemies = [];
  final List<String> inventory = [];
  final Set<Point<int>> roadTiles = {};
  String logMessage = 'Explore the open world and survive.';

  void _generateWorld() {
    for (var x = 4; x < mapWidth - 4; x++) {
      roadTiles.add(Point(x, mapHeight ~/ 2));
    }
    for (var y = 2; y < mapHeight - 2; y++) {
      roadTiles.add(Point(mapWidth ~/ 2, y));
    }

    for (var i = 0; i < 30; i++) {
      crates.add(Crate(position: _randomOpenTile()));
    }

    for (var i = 0; i < 8; i++) {
      enemies.add(Enemy(
        type: EnemyType.human,
        position: _randomOpenTile(),
        isBoss: i == 0,
      ));
    }

    for (var i = 0; i < 10; i++) {
      enemies.add(Enemy(
        type: EnemyType.zombie,
        position: _randomOpenTile(),
        isBoss: i == 9,
      ));
    }
  }

  Point<int> _randomOpenTile() {
    Point<int> position;
    do {
      position = Point(random.nextInt(mapWidth), random.nextInt(mapHeight));
    } while (position == player.position || crates.any((crate) => crate.position == position));
    return position;
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

enum EnemyType { human, zombie }

class Enemy {
  Enemy({required this.type, required this.position, required this.isBoss});

  final EnemyType type;
  final Point<int> position;
  final bool isBoss;
  int health = 8;
  int damage = 2;

  String get name => isBoss
      ? (type == EnemyType.zombie ? 'Zombie Warlord' : 'Bandit Captain')
      : (type == EnemyType.zombie ? 'Zombie' : 'Raider');
}
