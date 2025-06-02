import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'angle_game.dart';
import 'angle_control_panel.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Angle Navigator',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      debugShowCheckedModeBanner: false,
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
  // Initialize AngleGame here. It will be passed to both GameWidget and AngleControlPanel.
  final AngleGame _angleGame = AngleGame();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Angle Navigator'), elevation: 2),
      body: Column(
        children: [
          AngleControlPanel(game: _angleGame), // Flutter UI for controls
          Expanded(
            child: GameWidget(game: _angleGame), // Flame game widget
          ),
        ],
      ),
    );
  }
}
