import 'package:flutter/material.dart';
import 'game.dart';
import 'score.dart';

const green = Colors.green;
const black = Colors.black;

void main() {
  runApp(const MainApp());
}
class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: black,
        appBarTheme: const AppBarTheme(
          backgroundColor: green, // AppBar green
          foregroundColor: black, // title text
        ),
      ),
      home: const MainPage(),
    );
  }
}
class MainPage extends StatefulWidget {
  const MainPage({super.key});
  @override
  State<MainPage> createState() => _MainPageState();
}
class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;
  // Pages for each tab
  final List<Widget> _pages = [
    const HomeTab(),
    ScoreTab(),
    const SettingsTab(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _currentIndex == 0
              ? 'Snake Game'
              : _currentIndex == 1
                  ? 'High Scores'
                  : 'Settings',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: _pages[_currentIndex],
      // Bottom Navigation Bar
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: green,
        selectedItemColor: black,
        unselectedItemColor: Colors.black54,
        currentIndex: _currentIndex,
        onTap: (index) => setState(() {
          _currentIndex = index;
        }),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.emoji_events),
            label: 'Scores',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
// =================== TABS ===================
class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Welcome to the Snake Game!',
            style: TextStyle(color: green, fontSize: 40, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Press Start to begin.',
            style: TextStyle(color: green, fontSize: 20),
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: green,
              foregroundColor: black,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
              textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            onPressed: () {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => const GamePageWrapper()),
  );
},
            child: const Text('Start'),
          ),
          const SizedBox(height: 6),
const Text(
  'Hints: Use Arrow Keys, WASD, or the on-screen buttons to control the snake\n'
  'The eyes indicate the face of the snake\n'' Good Luck.',
  textAlign: TextAlign.center,
  style: TextStyle(
    color: green,
    fontSize: 12,     // smaller font
  ),
),
        ],
      ),
    );
  }
} 
class SettingsTab extends StatelessWidget {
  const SettingsTab({super.key});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Text('Settings', style: TextStyle(color: green, fontSize: 22, fontWeight: FontWeight.bold)),
          SizedBox(height: 10),
          Text('To change the speed of the snake use the slider below', style: TextStyle(color: green, fontSize: 18)),
        ],
      ),
    );
  }
}
