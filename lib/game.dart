import 'dart:async';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';

const green = Colors.green;
const black = Colors.black;

List<Map<String, dynamic>> highScores = [];

Future<void> loadScores() async {
  final prefs = await SharedPreferences.getInstance();
  final saved = prefs.getStringList('scores') ?? [];
  highScores = saved.map((e) {
    final parts = e.split('|');
    return {
      'name': parts[0],
      'score': int.parse(parts[1]),
    };
  }).toList();
}
Future<void> saveScores() async {
  final prefs = await SharedPreferences.getInstance();
  // Convert List<Map<String, dynamic>> to List<String> (JSON)
  final encoded = highScores.map((e) => jsonEncode(e)).toList();
  await prefs.setStringList('highScores', encoded);
}
class GamePageWrapper extends StatefulWidget {
  const GamePageWrapper({super.key});

  @override
  State<GamePageWrapper> createState() => _GamePageWrapperState();
}
class _GamePageWrapperState extends State<GamePageWrapper> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: GameTab(),
    );
  }
}
// ------------------- GAME -------------------
class GameTab extends StatefulWidget {
  const GameTab({super.key});

  @override
  State<GameTab> createState() => _GameTabState();
}

class _GameTabState extends State<GameTab> {
  List<Point<int>> snake = [const Point(10, 10)];
  Point<int> apple = const Point(5, 5);

  int dx = 1;
  int dy = 0;
  int score = 0;
  Timer? gameLoop;

int rowCount = 20;
int colCount = 20;
double cellSize = 20;


@override
void initState() {
  super.initState();
  // Load scores first
  loadScores().then((_) {
    // Start the game after first layout
    WidgetsBinding.instance.addPostFrameCallback((_) => resetGame());
  });
}

// Make loadScores a separate method of your State class
Future<void> loadScores() async {
  final prefs = await SharedPreferences.getInstance();
  final saved = prefs.getStringList('highScores') ?? [];
  highScores = saved.map((e) => jsonDecode(e) as Map<String, dynamic>).toList();
}


  void startGameLoop() {
    gameLoop?.cancel();
    gameLoop = Timer.periodic(const Duration(milliseconds: 200), (_) {
      setState(() => moveSnake());
    });
  }

  @override
  void dispose() {
    gameLoop?.cancel();
    super.dispose();
  }
  void moveSnake() {
    final head = snake.first;
    final newHead = Point(head.x + dx, head.y + dy);
    if (newHead.x < 0 ||
        newHead.x >= colCount ||
        newHead.y < 0 ||
        newHead.y >= rowCount ||
        snake.contains(newHead)) {
      gameOver();
      return;
    }
    snake.insert(0, newHead);

    if (newHead == apple) {
      score += 1;
      placeApple();
    } else {
      snake.removeLast();
    }
  }

  void placeApple() {
    final rand = Random();
    Point<int> newApple;
    do {
      newApple = Point(rand.nextInt(colCount), rand.nextInt(rowCount));
    } while (snake.contains(newApple));
    apple = newApple;
  }

  void gameOver() async {
  gameLoop?.cancel();

  final bestScore = getBestScore();
  String playerName = '';
  // ---------- CASE 1: NEW HIGH SCORE ----------
  if (score > bestScore) {
    // Ask ONLY for name first
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('🎉 New High Score!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Your score: $score'),
            const SizedBox(height: 10),
            TextField(
              decoration: const InputDecoration(labelText: 'Enter your name'),
              onChanged: (value) => playerName = value,
            ),
          ],
        ),
       actions: [
  TextButton(
    onPressed: () async {
      if (playerName.trim().isNotEmpty) {
        // Add new high score with date
        highScores.add({
          'name': playerName,
          'score': score,
          'date': DateTime.now().toString().split(' ')[0], // YYYY-MM-DD
        });
        // Sort descending by score
        highScores.sort((a, b) => (b['score'] as int).compareTo(a['score'] as int));

        // Keep only top 5
        if (highScores.length > 5) highScores.removeLast();

        // Save to SharedPreferences
        await saveScores();
      }

      Navigator.of(context).pop(); // Close "New High Score" dialog
    },
    child: const Text('Save Score'),
  ),
],
),
);
    // AFTER saving → show restart menu
    await _showEndMenu();
  }

  // ---------- CASE 2: NORMAL GAME OVER ----------
  else {
    await _showEndMenu();
  }
}

Future<void> _showEndMenu() async {
  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => AlertDialog(
      title: const Text('Game Over'),
      content: Text('Your score: $score'),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            Navigator.of(context).pop(); // go home
          },
          child: const Text('Home'),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            resetGame();
          },
          child: const Text('Restart'),
        ),
      ],
    ),
  );
}

int getBestScore() {
  if (highScores.isEmpty) return 0;
  return highScores.map((e) => e['score'] as int).reduce(max);
}

  void resetGame() {
    final size = MediaQuery.of(context).size;
    final maxCells = 30; // maximum grid size
    cellSize = min(size.width / maxCells, (size.height - 150) / maxCells);
    colCount = (size.width / cellSize).floor();
    rowCount = ((size.height - 150) / cellSize).floor();

    setState(() {
      snake = [Point((colCount / 2).floor(), (rowCount / 2).floor())];
      dx = 1;
      dy = 0;
      score = 0;
      placeApple();
      startGameLoop();
    });
  }

  void changeDirection(String dir) {
    switch (dir) {
      case 'up':
        if (dy == 0) {
          dx = 0;
          dy = -1;
        }
        break;
      case 'down':
        if (dy == 0) {
          dx = 0;
          dy = 1;
        }
        break;
      case 'left':
        if (dx == 0) {
          dx = -1;
          dy = 0;
        }
        break;
      case 'right':
        if (dx == 0) {
          dx = 1;
          dy = 0;
        }
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: black,
      body: Focus(
        autofocus: true,
        onKeyEvent: (node, event) {
          if (event is KeyDownEvent) {
            final key = event.logicalKey;
            if (key == LogicalKeyboardKey.arrowUp ||
                key == LogicalKeyboardKey.keyW) {
              changeDirection('up');
            }
            if (key == LogicalKeyboardKey.arrowDown ||
                key == LogicalKeyboardKey.keyS) {
              changeDirection('down');
            }
            if (key == LogicalKeyboardKey.arrowLeft ||
                key == LogicalKeyboardKey.keyA) {
              changeDirection('left');
            }
            if (key == LogicalKeyboardKey.arrowRight ||
                key == LogicalKeyboardKey.keyD) {
              changeDirection('right');
            }
          }
          return KeyEventResult.handled;
        },
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Score: $score',
                style: const TextStyle(
                    color: green, fontSize: 30, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final boardSize = min(constraints.maxWidth, constraints.maxHeight);
                  final dynamicCellSize = boardSize / min(rowCount, colCount);

                  return Center(
                    child: Container(
                      width: colCount * dynamicCellSize,
                      height: rowCount * dynamicCellSize,
                      decoration: BoxDecoration(
                        color: black,
                        border: Border.all(
                          color: Colors.green,
                          width: 3,
                        ),
                      ),
                      child: Stack(
                        children: [
                          for (var p in snake.skip(1))
                            Positioned(
                              left: p.x * dynamicCellSize,
                              top: p.y * dynamicCellSize,
                              child: Container(
                                  width: dynamicCellSize,
                                  height: dynamicCellSize,
                                  color: green),
                            ),
                          // Head with eyes

                          Positioned(
                            left: snake.first.x * dynamicCellSize,
                            top: snake.first.y * dynamicCellSize,
                            child: Container(
                              width: dynamicCellSize,
                              height: dynamicCellSize,
                              decoration: const BoxDecoration(
                                color: green,
                                shape: BoxShape.rectangle,
                              ),
                              child: Stack(
                                children: [
                                  // Left eye
                                  Positioned(
                                    left: dx == 1
                                        ? dynamicCellSize * 0.65 // moving right
                                        : dx == -1
                                            ? dynamicCellSize * 0.15 // moving left
                                            : dynamicCellSize * 0.25, // moving up/down
                                    top: dy == 1
                                        ? dynamicCellSize * 0.65 // moving down
                                        : dy == -1
                                            ? dynamicCellSize * 0.15 // moving up
                                            : dynamicCellSize * 0.25, // moving left/right
                                    child: Container(
                                      width: dynamicCellSize * 0.2,
                                      height: dynamicCellSize * 0.2,
                                      decoration: const BoxDecoration(
                                        color: Colors.black,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ),

                                  // Right eye
                                  Positioned(
                                    left: dx == 1
                                        ? dynamicCellSize * 0.65
                                        : dx == -1
                                            ? dynamicCellSize * 0.15
                                            : dynamicCellSize * 0.55,
                                    top: dy == 1
                                        ? dynamicCellSize * 0.65
                                        : dy == -1
                                            ? dynamicCellSize * 0.15
                                            : dynamicCellSize * 0.55,
                                    child: Container(
                                      width: dynamicCellSize * 0.2,
                                      height: dynamicCellSize * 0.2,
                                      decoration: const BoxDecoration(
                                        color: Colors.black,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Apple
                          Positioned(
                            left: apple.x * dynamicCellSize,
                            top: apple.y * dynamicCellSize,
                            child: Container(
                                width: dynamicCellSize,
                                height: dynamicCellSize,
                                color: Colors.red),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                      icon: const Icon(Icons.arrow_left, color: green),
                      onPressed: () => changeDirection('left')),
                  Column(
                    children: [
                      IconButton(
                          icon: const Icon(Icons.arrow_drop_up, color: green),
                          onPressed: () => changeDirection('up')),
                      const SizedBox(height: 40),
                      IconButton(
                          icon:
                              const Icon(Icons.arrow_drop_down, color: green),
                          onPressed: () => changeDirection('down')),
                    ],
                  ),
                  IconButton(
                      icon: const Icon(Icons.arrow_right, color: green),
                      onPressed: () => changeDirection('right')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
