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

  void _useItem(String item) {
    setState(() {
      _gameState.useItem(item);
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
            onUseItem: _useItem,
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
    required this.onUseItem,
  });

  final GameState state;
  final void Function(Offset delta) onMove;
  final VoidCallback onAttack;
  final VoidCallback onLoot;
  final void Function(String stat) onUpgrade;
  final void Function(String item) onUseItem;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Container(
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
                _StatChip(label: 'Supplies', value: state.supplies),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              state.logMessage,
              style: const TextStyle(color: Colors.white70),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            const TabBar(
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white54,
              indicatorColor: Colors.amber,
              tabs: [
                Tab(text: 'Actions', icon: Icon(Icons.sports_martial_arts)),
                Tab(text: 'Inventory', icon: Icon(Icons.backpack)),
                Tab(text: 'Upgrades', icon: Icon(Icons.trending_up)),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 180,
              child: TabBarView(
                children: [
                  _ActionsTab(onMove: onMove, onAttack: onAttack, onLoot: onLoot),
                  _InventoryTab(state: state, onUseItem: onUseItem),
                  _UpgradesTab(state: state, onUpgrade: onUpgrade),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionsTab extends StatelessWidget {
  const _ActionsTab({
    required this.onMove,
    required this.onAttack,
    required this.onLoot,
  });

  final void Function(Offset delta) onMove;
  final VoidCallback onAttack;
  final VoidCallback onLoot;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _MovementControls(onMove: onMove),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
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
      ],
    );
  }
}

class _InventoryTab extends StatelessWidget {
  const _InventoryTab({required this.state, required this.onUseItem});

  final GameState state;
  final void Function(String item) onUseItem;

  @override
  Widget build(BuildContext context) {
    if (state.inventory.isEmpty) {
      return const Center(
        child: Text(
          'Inventory empty. Loot crates to collect gear.',
          style: TextStyle(color: Colors.white70),
          textAlign: TextAlign.center,
        ),
      );
    }
    return ListView.separated(
      itemCount: state.inventory.length,
      separatorBuilder: (_, __) => const Divider(color: Colors.white12),
      itemBuilder: (context, index) {
        final item = state.inventory[index];
        final actionLabel = state.actionLabelForItem(item);
        final isActionable = actionLabel != null;
        return ListTile(
          dense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 4),
          title: Text(item, style: const TextStyle(color: Colors.white)),
          subtitle: Text(
            state.itemDescription(item),
            style: const TextStyle(color: Colors.white54, fontSize: 12),
          ),
          trailing: isActionable
              ? OutlinedButton(
                  onPressed: () => onUseItem(item),
                  style: OutlinedButton.styleFrom(foregroundColor: Colors.white),
                  child: Text(actionLabel!),
                )
              : const Text('Equipped', style: TextStyle(color: Colors.white54)),
        );
      },
    );
  }
}

class _UpgradesTab extends StatelessWidget {
  const _UpgradesTab({required this.state, required this.onUpgrade});

  final GameState state;
  final void Function(String stat) onUpgrade;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _UpgradeCard(
          label: 'HP Boost',
          description: '+5 max HP for 3 supplies + 1 level',
          enabled: state.canUpgrade('hp'),
          onPressed: () => onUpgrade('hp'),
        ),
        const SizedBox(height: 8),
        _UpgradeCard(
          label: 'Armor Plating',
          description: '+1 armor for 2 supplies + 1 level',
          enabled: state.canUpgrade('armor'),
          onPressed: () => onUpgrade('armor'),
        ),
        const SizedBox(height: 8),
        _UpgradeCard(
          label: 'Weapon Edge',
          description: '+1 damage for 2 supplies + 1 level',
          enabled: state.canUpgrade('damage'),
          onPressed: () => onUpgrade('damage'),
        ),
      ],
    );
  }
}

class _UpgradeCard extends StatelessWidget {
  const _UpgradeCard({
    required this.label,
    required this.description,
    required this.enabled,
    required this.onPressed,
  });

  final String label;
  final String description;
  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF231E18),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(description, style: const TextStyle(color: Colors.white54, fontSize: 12)),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: enabled ? onPressed : null,
            child: const Text('Upgrade'),
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
    const tileWidth = 36.0;
    const tileHeight = 18.0;
    final projection = _IsoProjection(
      tileWidth: tileWidth,
      tileHeight: tileHeight,
      screenSize: size,
      focus: state.player.position,
    );
    final paint = Paint()..style = PaintingStyle.fill;

    paint.color = const Color(0xFF1C1A18);
    canvas.drawRect(Offset.zero & size, paint);

    final maxSum = state.mapWidth + state.mapHeight;
    for (var sum = 0; sum < maxSum; sum++) {
      for (var x = 0; x < state.mapWidth; x++) {
        final y = sum - x;
        if (y < 0 || y >= state.mapHeight) {
          continue;
        }
        final position = Point<int>(x, y);
        final screenCenter = projection.tileToScreen(position);
        final terrainType = state.terrain[y][x];
        _paintIsoTile(canvas, screenCenter, terrainType, projection);
      }
    }

    final renderables = <_Renderable>[
      ...state.decorations.map((decor) => _Renderable.decoration(decor)),
      ...state.crates.map((crate) => _Renderable.crate(crate)),
      ...state.enemies.map((enemy) => _Renderable.enemy(enemy)),
      _Renderable.player(state.player),
    ]..sort((a, b) => a.depth.compareTo(b.depth));

    for (final renderable in renderables) {
      final screenCenter = projection.tileToScreen(renderable.position);
      switch (renderable.type) {
        case _RenderableType.decoration:
          _paintDecoration(canvas, screenCenter, tileWidth, renderable.decoration!);
          break;
        case _RenderableType.crate:
          _paintCrateIso(canvas, screenCenter, tileWidth, renderable.crate!);
          break;
        case _RenderableType.enemy:
          _paintEnemyIso(canvas, screenCenter, tileWidth, renderable.enemy!);
          break;
        case _RenderableType.player:
          _paintPlayerIso(canvas, screenCenter, tileWidth);
          break;
      }
    }
  }

  void _paintIsoTile(
    Canvas canvas,
    Offset center,
    TerrainType type,
    _IsoProjection projection,
  ) {
    final palette = _TerrainPalette.forType(type);
    final elevation = palette.elevation;
    final halfW = projection.tileWidth / 2;
    final halfH = projection.tileHeight / 2;
    final top = Offset(center.dx, center.dy - halfH - elevation);
    final right = Offset(center.dx + halfW, center.dy - elevation);
    final bottom = Offset(center.dx, center.dy + halfH - elevation);
    final left = Offset(center.dx - halfW, center.dy - elevation);
    final baseRight = right + Offset(0, elevation);
    final baseBottom = bottom + Offset(0, elevation);
    final baseLeft = left + Offset(0, elevation);

    final topFace = Path()
      ..moveTo(top.dx, top.dy)
      ..lineTo(right.dx, right.dy)
      ..lineTo(bottom.dx, bottom.dy)
      ..lineTo(left.dx, left.dy)
      ..close();

    canvas.drawPath(topFace, Paint()..color = palette.top);

    if (elevation > 0) {
      final leftFace = Path()
        ..moveTo(left.dx, left.dy)
        ..lineTo(bottom.dx, bottom.dy)
        ..lineTo(baseBottom.dx, baseBottom.dy)
        ..lineTo(baseLeft.dx, baseLeft.dy)
        ..close();
      final rightFace = Path()
        ..moveTo(right.dx, right.dy)
        ..lineTo(bottom.dx, bottom.dy)
        ..lineTo(baseBottom.dx, baseBottom.dy)
        ..lineTo(baseRight.dx, baseRight.dy)
        ..close();
      canvas.drawPath(leftFace, Paint()..color = palette.left);
      canvas.drawPath(rightFace, Paint()..color = palette.right);
    }

    final outlinePaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = Colors.black.withOpacity(0.12);
    canvas.drawPath(topFace, outlinePaint);
  }

  void _paintDecoration(
    Canvas canvas,
    Offset center,
    double tileWidth,
    Decoration decoration,
  ) {
    switch (decoration.type) {
      case DecorationType.tree:
        _paintTreeIso(canvas, center, tileWidth);
        break;
      case DecorationType.rock:
        _paintRockIso(canvas, center, tileWidth);
        break;
      case DecorationType.camp:
        _paintCampIso(canvas, center, tileWidth);
        break;
    }
  }

  void _paintTreeIso(Canvas canvas, Offset center, double tileWidth) {
    final trunkHeight = tileWidth * 0.35;
    final canopyHeight = tileWidth * 0.6;
    final trunkPaint = Paint()..color = const Color(0xFF5A3C2A);
    final canopyPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF1F6B3A), Color(0xFF3FA35C)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(
        Rect.fromCenter(
          center: center.translate(0, -trunkHeight),
          width: tileWidth,
          height: canopyHeight,
        ),
      );
    final shadowPaint = Paint()..color = Colors.black.withOpacity(0.25);
    canvas.drawOval(
      Rect.fromCenter(center: center.translate(0, tileWidth * 0.2), width: tileWidth * 0.9, height: tileWidth * 0.35),
      shadowPaint,
    );
    final trunkRect = Rect.fromCenter(
      center: center.translate(0, -trunkHeight * 0.1),
      width: tileWidth * 0.18,
      height: trunkHeight,
    );
    canvas.drawRect(trunkRect, trunkPaint);
    canvas.drawOval(
      Rect.fromCenter(
        center: center.translate(0, -trunkHeight - canopyHeight * 0.2),
        width: tileWidth * 0.9,
        height: canopyHeight,
      ),
      canopyPaint,
    );
  }

  void _paintRockIso(Canvas canvas, Offset center, double tileWidth) {
    final rockRect = Rect.fromCenter(center: center.translate(0, -tileWidth * 0.1), width: tileWidth * 0.7, height: tileWidth * 0.4);
    final paint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF596066), Color(0xFF9AA1A8)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(rockRect);
    canvas.drawRRect(RRect.fromRectAndRadius(rockRect, const Radius.circular(6)), paint);
  }

  void _paintCampIso(Canvas canvas, Offset center, double tileWidth) {
    final firePaint = Paint()
      ..shader = const RadialGradient(
        colors: [Color(0xFFFFF2B0), Color(0xFFE58A2E), Color(0xFFB3471D)],
      ).createShader(Rect.fromCenter(center: center, width: tileWidth * 0.6, height: tileWidth * 0.6));
    final logPaint = Paint()..color = const Color(0xFF6A4630);
    canvas.drawOval(
      Rect.fromCenter(center: center.translate(0, -tileWidth * 0.05), width: tileWidth * 0.5, height: tileWidth * 0.25),
      firePaint,
    );
    canvas.drawRect(
      Rect.fromCenter(center: center.translate(0, tileWidth * 0.12), width: tileWidth * 0.6, height: tileWidth * 0.1),
      logPaint,
    );
  }

  void _paintCrateIso(Canvas canvas, Offset center, double tileWidth, Crate crate) {
    final boxRect = Rect.fromCenter(center: center.translate(0, -tileWidth * 0.1), width: tileWidth * 0.45, height: tileWidth * 0.3);
    final cratePaint = Paint()
      ..shader = LinearGradient(
        colors: crate.isOpened
            ? [const Color(0xFF5C4B3E), const Color(0xFF6B5B4D)]
            : [const Color(0xFF8C5C2D), const Color(0xFFB1783E)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(boxRect);
    canvas.drawRRect(RRect.fromRectAndRadius(boxRect, const Radius.circular(6)), cratePaint);
    if (!crate.isOpened) {
      final latch = Rect.fromCenter(center: boxRect.center, width: boxRect.width * 0.2, height: boxRect.height * 0.2);
      canvas.drawRect(latch, Paint()..color = const Color(0xFFE3C177));
    }
  }

  void _paintEnemyIso(Canvas canvas, Offset center, double tileWidth, Enemy enemy) {
    final bodyHeight = tileWidth * 0.45;
    final bodyRect = Rect.fromCenter(
      center: center.translate(0, -bodyHeight * 0.4),
      width: tileWidth * 0.35,
      height: bodyHeight,
    );
    final basePaint = Paint()
      ..shader = LinearGradient(
        colors: enemy.type == EnemyType.zombie
            ? [const Color(0xFF3E8A54), const Color(0xFF6ED98C)]
            : [const Color(0xFFB1453F), const Color(0xFFE98A6F)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(bodyRect);
    canvas.drawRRect(RRect.fromRectAndRadius(bodyRect, const Radius.circular(6)), basePaint);
    canvas.drawCircle(center.translate(0, -bodyHeight * 0.9), tileWidth * 0.12, basePaint);
    if (enemy.isBoss) {
      canvas.drawCircle(center.translate(0, -bodyHeight * 1.3), tileWidth * 0.07, Paint()..color = Colors.amber);
    }
  }

  void _paintPlayerIso(Canvas canvas, Offset center, double tileWidth) {
    final bodyHeight = tileWidth * 0.5;
    final bodyRect = Rect.fromCenter(
      center: center.translate(0, -bodyHeight * 0.4),
      width: tileWidth * 0.38,
      height: bodyHeight,
    );
    final armorPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF2C6CA3), Color(0xFF5CB0E6)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(bodyRect);
    final outlinePaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawRRect(RRect.fromRectAndRadius(bodyRect, const Radius.circular(6)), armorPaint);
    canvas.drawRRect(RRect.fromRectAndRadius(bodyRect, const Radius.circular(6)), outlinePaint);
    canvas.drawCircle(center.translate(0, -bodyHeight * 0.95), tileWidth * 0.12, armorPaint);
    final shield = Path()
      ..moveTo(center.dx + tileWidth * 0.18, center.dy - tileWidth * 0.1)
      ..lineTo(center.dx + tileWidth * 0.3, center.dy)
      ..lineTo(center.dx + tileWidth * 0.22, center.dy + tileWidth * 0.18)
      ..lineTo(center.dx + tileWidth * 0.08, center.dy)
      ..close();
    final shieldPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF9B7B3E), Color(0xFFD8B56E)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(shield.getBounds());
    canvas.drawPath(shield, shieldPaint);
    canvas.drawPath(shield, outlinePaint);
  }

  @override
  bool shouldRepaint(covariant GamePainter oldDelegate) => true;
}

class _IsoProjection {
  _IsoProjection({
    required this.tileWidth,
    required this.tileHeight,
    required Size screenSize,
    required Point<int> focus,
  }) : offset = _calculateOffset(tileWidth, tileHeight, screenSize, focus);

  final double tileWidth;
  final double tileHeight;
  final Offset offset;

  Offset tileToScreen(Point<int> position) {
    final screenX = (position.x - position.y) * tileWidth / 2;
    final screenY = (position.x + position.y) * tileHeight / 2;
    return Offset(screenX, screenY) + offset;
  }

  static Offset _calculateOffset(
    double tileWidth,
    double tileHeight,
    Size screenSize,
    Point<int> focus,
  ) {
    final focusX = (focus.x - focus.y) * tileWidth / 2;
    final focusY = (focus.x + focus.y) * tileHeight / 2;
    return Offset(screenSize.width / 2 - focusX, screenSize.height / 2 - focusY);
  }
}

enum _RenderableType { decoration, crate, enemy, player }

class _Renderable {
  _Renderable.decoration(this.decoration)
      : type = _RenderableType.decoration,
        crate = null,
        enemy = null,
        player = null;

  _Renderable.crate(this.crate)
      : type = _RenderableType.crate,
        decoration = null,
        enemy = null,
        player = null;

  _Renderable.enemy(this.enemy)
      : type = _RenderableType.enemy,
        decoration = null,
        crate = null,
        player = null;

  _Renderable.player(this.player)
      : type = _RenderableType.player,
        decoration = null,
        crate = null,
        enemy = null;

  final _RenderableType type;
  final Decoration? decoration;
  final Crate? crate;
  final Enemy? enemy;
  final Player? player;

  Point<int> get position {
    switch (type) {
      case _RenderableType.decoration:
        return decoration!.position;
      case _RenderableType.crate:
        return crate!.position;
      case _RenderableType.enemy:
        return enemy!.position;
      case _RenderableType.player:
        return player!.position;
    }
  }

  int get depth => position.x + position.y;
}

class _TerrainPalette {
  _TerrainPalette({required this.top, required this.left, required this.right, required this.elevation});

  final Color top;
  final Color left;
  final Color right;
  final double elevation;

  static _TerrainPalette forType(TerrainType type) {
    switch (type) {
      case TerrainType.grass:
        return _TerrainPalette(
          top: const Color(0xFF4D6B3B),
          left: const Color(0xFF3E5630),
          right: const Color(0xFF36502C),
          elevation: 6,
        );
      case TerrainType.road:
        return _TerrainPalette(
          top: const Color(0xFF5A4734),
          left: const Color(0xFF4A3A2A),
          right: const Color(0xFF3E2F22),
          elevation: 4,
        );
      case TerrainType.water:
        return _TerrainPalette(
          top: const Color(0xFF2C5B7C),
          left: const Color(0xFF1E3D54),
          right: const Color(0xFF173444),
          elevation: 0,
        );
      case TerrainType.forest:
        return _TerrainPalette(
          top: const Color(0xFF2E5C44),
          left: const Color(0xFF244938),
          right: const Color(0xFF1E3A2C),
          elevation: 7,
        );
      case TerrainType.sand:
        return _TerrainPalette(
          top: const Color(0xFFB0955E),
          left: const Color(0xFF8B7349),
          right: const Color(0xFF7C643D),
          elevation: 3,
        );
    }
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
  final Set<String> equippedItems = {};
  final List<List<TerrainType>> terrain = [];
  final Set<Point<int>> roadTiles = {};
  String logMessage = 'Explore the medieval frontier and survive.';
  int supplies = 0;

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
    final gainedSupplies = 1 + random.nextInt(2);
    supplies += gainedSupplies;
    logMessage = 'Looted $item (+$gainedSupplies supplies). Inventory size ${inventory.length}.';
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

  void upgrade(String stat) {
    if (!canUpgrade(stat)) {
      logMessage = 'Need 1 level and enough supplies to upgrade.';
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
    supplies -= upgradeCost(stat);
    logMessage = 'Upgraded $stat. Remaining level ${player.level}.';
  }

  int upgradeCost(String stat) {
    switch (stat) {
      case 'hp':
        return 3;
      case 'armor':
      case 'damage':
        return 2;
    }
    return 2;
  }

  bool canUpgrade(String stat) {
    return player.level > 0 && supplies >= upgradeCost(stat);
  }

  String? actionLabelForItem(String item) {
    if (item.contains('Healing')) {
      return 'Use';
    }
    if (equippedItems.contains(item)) {
      return null;
    }
    if (item.contains('Armor') || item.contains('Sword') || item.contains('Axe') || item.contains('Crossbow')) {
      return 'Equip';
    }
    return 'Use';
  }

  String itemDescription(String item) {
    if (item.contains('Healing')) {
      return 'Consume to restore 6 HP.';
    }
    if (item.contains('Armor')) {
      return 'Equip to gain +1 armor.';
    }
    if (item.contains('Sword') || item.contains('Axe') || item.contains('Crossbow')) {
      return 'Equip to gain +1 damage.';
    }
    return 'Use this item.';
  }

  void useItem(String item) {
    if (!inventory.contains(item)) {
      return;
    }
    if (item.contains('Healing')) {
      player.health += 6;
      inventory.remove(item);
      logMessage = 'Used $item. HP now ${player.health}.';
      return;
    }
    if (equippedItems.contains(item)) {
      logMessage = '$item already equipped.';
      return;
    }
    if (item.contains('Armor')) {
      player.armor += 1;
      equippedItems.add(item);
      inventory.remove(item);
      logMessage = 'Equipped $item. Armor now ${player.armor}.';
      return;
    }
    if (item.contains('Sword') || item.contains('Axe') || item.contains('Crossbow')) {
      player.damage += 1;
      equippedItems.add(item);
      inventory.remove(item);
      logMessage = 'Equipped $item. Damage now ${player.damage}.';
      return;
    }
    inventory.remove(item);
    logMessage = 'Used $item.';
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
