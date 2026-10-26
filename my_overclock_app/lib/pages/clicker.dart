import 'dart:async';
import 'dart:math';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr/dom.dart';

@client
class ClickerGame extends StatefulComponent {
  const ClickerGame({super.key});

  @override
  State<ClickerGame> createState() => _ClickerGameState();
}

class _ClickerGameState extends State<ClickerGame> {
  // --- Game State Variables ---
  int score = 0;
  int targetIndex = 0; // The cell index (0 to 2) that the player needs to click
  bool isPlaying = false;
  
  // Reusing the three colors from your core grid project
  final List<String> colors = ["#ff5722", "#4caf50", "#2196f3"]; 
  Timer? gameTimer;

  void startGame() {
    setState(() {
      score = 0;
      isPlaying = true;
    });
    _spawnNextTarget();
  }

  void _spawnNextTarget() {
    gameTimer?.cancel();
    
    // Pick a random grid position (0, 1, or 2) for the block to appear in
    setState(() {
      targetIndex = Random().nextInt(3);
    });

    // Speed increases slightly as score goes up! (Game Loop Speed Cap: 400ms)
    int currentSpeed = max(400, 1500 - (score * 80));

    // Force-spawn the next cycle if the player misses it
    gameTimer = Timer(Duration(milliseconds: currentSpeed), () {
      if (isPlaying) {
        setState(() {
          // Penalty: Missing drops score by 1
          if (score > 0) score--; 
        });
        _spawnNextTarget();
      }
    });
  }

  void handleCellClick(int clickedIndex) {
    if (!isPlaying) return;

    if (clickedIndex == targetIndex) {
      setState(() {
        score++; // Hit!
      });
      _spawnNextTarget();
    } else {
      setState(() {
        if (score > 0) score--; // Miss penalty
      });
    }
  }

  void endGame() {
    gameTimer?.cancel();
    setState(() {
      isPlaying = false;
    });
  }

  @override
  void dispose() {
    gameTimer?.cancel();
    super.dispose();
  }

  @override
  Component build(BuildContext context) {
    return div([
      h1([Component.text("Reflex Speed Matcher")]),
      
      div(classes: "timer-text", [
        Component.text("Current Score: $score")
      ]),

      // Control Center Button System
      div([
        if (!isPlaying)
          button(
            events: {'click': (e) => startGame()},
            [Component.text("START GAME")]
          )
        else
          button(
            events: {'click': (e) => endGame()},
            [Component.text("STOP / FORFEIT")]
          ),
      ]),

      br(),

      // Reusing your exact '.container' class layout wrapper 
      div(classes: "container", [
        // Generate a 1x3 dynamic target row array matching your block sizes
        for (int i = 0; i < 3; i++)
          div(
            classes: "grid-cell",
            events: {
              'click': (e) => handleCellClick(i),
            },
            [
              // If this index is the current active target index, draw the colored block
              if (isPlaying && i == targetIndex)
                div(
                  classes: "color-block",
                  attributes: {
                    "style": "background-color: ${colors[i]}; cursor: pointer;"
                  },
                  []
                )
              else
                // Simple placeholder text reusing your existing typography styles
                Component.text("Empty Slot")
            ]
          )
      ]),
    ]);
  }
}
