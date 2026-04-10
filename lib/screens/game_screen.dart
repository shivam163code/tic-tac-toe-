import 'dart:math';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../logic/game_logic.dart';
import '../logic/ai_logic.dart';
import '../logic/theme_logic.dart';
import '../widgets/result_dialog.dart';

enum AiLevel { easy, hard }

class GameScreen extends StatefulWidget {
  final bool vsAI;

  const GameScreen({super.key, required this.vsAI});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  List<String> board = List.filled(9, '');
  bool isBlueTurn = true;
  bool gameOver = false;
  List<int> winningPattern = [];

  AiLevel aiLevel = AiLevel.hard;

  int blueScore = 0;
  int redScore = 0;
  int drawScore = 0;

  String funnyComment = "Let's Battle! ⚔️";

  final AudioPlayer player = AudioPlayer();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Initialize turn message
    final theme = Provider.of<GameTheme>(context, listen: false);
    funnyComment = theme.getTurnMessage(true);
  }

  // ---------------- RESET GAME ----------------
  void resetGame() {
    setState(() {
      board = List.filled(9, '');
      winningPattern.clear();
      isBlueTurn = true;
      gameOver = false;
      
      final theme = Provider.of<GameTheme>(context, listen: false);
      funnyComment = theme.getTurnMessage(true);
    });
  }

  // ---------------- SOUND ----------------
  void playSound(String file) {
    player.play(AssetSource('sounds/$file'));
  }

  // ---------------- EASY AI ----------------
  int getEasyAiMove() {
    List<int> empty = [];
    for (int i = 0; i < board.length; i++) {
      if (board[i] == '') empty.add(i);
    }
    return empty[Random().nextInt(empty.length)];
  }

  // ---------------- GAME TAP ----------------
  void onTap(int index) {
    if (widget.vsAI && !isBlueTurn) return;
    if (board[index] != '' || gameOver) return;

    playSound('tap.mp3');

    setState(() {
      board[index] = isBlueTurn ? 'X' : 'O';
    });

    checkGameState();

    if (!gameOver) {
      if (widget.vsAI) {
        isBlueTurn = false;
        setState(() {
             final theme = Provider.of<GameTheme>(context, listen: false);
             funnyComment = theme.getTurnMessage(false);
        });

        Future.delayed(const Duration(milliseconds: 600), () {
          if (gameOver) return;

          int aiMove = aiLevel == AiLevel.easy
              ? getEasyAiMove()
              : AiLogic.bestMove(board);

          setState(() {
            board[aiMove] = 'O';
            isBlueTurn = true;
            final theme = Provider.of<GameTheme>(context, listen: false);
            funnyComment = theme.getTurnMessage(true);
          });

          playSound('tap.mp3');
          checkGameState();
        });
      } else {
        isBlueTurn = !isBlueTurn;
         setState(() {
             final theme = Provider.of<GameTheme>(context, listen: false);
             funnyComment = theme.getTurnMessage(isBlueTurn);
        });
      }
    }
  }

  // ---------------- CHECK RESULT ----------------
  void checkGameState() {
    var result = GameLogic.checkWinnerWithPattern(board);
    final theme = Provider.of<GameTheme>(context, listen: false);

    if (result['winner'] != '') {
      gameOver = true;
      winningPattern = result['pattern'] ?? [];

      String winner = result['winner'];

      if (winner == 'X') {
        blueScore++;
        playSound('win.mp3');
      } else if (winner == 'O') {
        redScore++;
        playSound('win.mp3');
      } else {
        drawScore++;
        playSound('draw.mp3');
      }
      
      String markerToCheck = winner == 'X' ? theme.getPlayer1Marker() : (winner == 'O' ? theme.getPlayer2Marker() : '');
      funnyComment = theme.getCommentary(markerToCheck, winner == 'Draw');

      showResult(winner, theme);
      setState(() {});
    }
  }

  // ---------------- RESULT DIALOG ----------------
  void showResult(String result, GameTheme theme) {
    String title = result == 'Draw' 
        ? 'Draw!' 
        : (result == 'X' ? '${theme.getPlayer1Marker()} Wins!' : '${theme.getPlayer2Marker()} Wins!');
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => ResultDialog(
        title: title,
        message: funnyComment,
        icon: result == 'Draw' ? "🤝" : "🏆",
        isDark: theme.themeMode == ThemeMode.dark,
        onPlayAgain: () {
          Navigator.pop(context);
          Future.delayed(const Duration(milliseconds: 100), resetGame);
        },
      ),
    );
  }

  bool isWinningTile(int index) => winningPattern.contains(index);

  // ---------------- UI ----------------
  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<GameTheme>(context);
    final isDark = theme.themeMode == ThemeMode.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(widget.vsAI ? 'You vs AI' : 'PvP', style: GoogleFonts.bangers(fontSize: 28)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: widget.vsAI
            ? [
          DropdownButton<AiLevel>(
            value: aiLevel,
            dropdownColor: isDark ? Colors.grey[900] : Colors.white,
            underline: const SizedBox(),
            icon: const Icon(Icons.psychology, color: Colors.white),
            items: const [
              DropdownMenuItem(value: AiLevel.easy, child: Text('Easy 👶')),
              DropdownMenuItem(value: AiLevel.hard, child: Text('Hard 🤖')),
            ],
            onChanged: (value) => setState(() => aiLevel = value!),
          ),
          const SizedBox(width: 10),
        ]
            : [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: resetGame,
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark 
                ? [const Color(0xFF232526), const Color(0xFF414345)] 
                : [Colors.teal.shade50, Colors.blue.shade50],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 100),
            
            // SCOREBOARD
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: isDark ? Colors.white10 : Colors.white70,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white24),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildScoreItem(theme.getPlayer1Marker(), blueScore, Colors.blue, theme),
                  _buildScoreItem('Draw', drawScore, Colors.grey, theme),
                  _buildScoreItem(theme.getPlayer2Marker(), redScore, Colors.red, theme),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // FUNNY COMMENTARY AREA
            Container(
               padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
               child: Text(
                 funnyComment,
                 textAlign: TextAlign.center,
                 style: GoogleFonts.bubblegumSans(
                   fontSize: 24,
                   color: isDark ? Colors.yellowAccent : Colors.deepOrange,
                   shadows: [
                      const Shadow(blurRadius: 2, color: Colors.black26, offset: Offset(1,1))
                   ]
                 ),
               ),
            ),

            // GRID
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(20),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: 9,
                itemBuilder: (context, index) {
                  String val = board[index];
                  String displayChar = '';
                  if (val == 'X') displayChar = theme.getPlayer1Marker();
                  if (val == 'O') displayChar = theme.getPlayer2Marker();

                  return GestureDetector(
                    onTap: () => onTap(index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      decoration: BoxDecoration(
                        color: isWinningTile(index)
                            ? Colors.green.withOpacity(0.6)
                            : (isDark ? Colors.black45 : Colors.white),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                           BoxShadow(
                             color: Colors.black12,
                             blurRadius: 5,
                             offset: const Offset(2, 4)
                           )
                        ],
                      ),
                      child: Center(
                        child: AnimatedScale(
                          scale: isWinningTile(index) ? 1.2 : 1,
                          duration: const Duration(milliseconds: 400),
                          child: Text(
                            displayChar,
                            style: TextStyle(
                              fontSize: 50, // Emoji size
                              fontWeight: FontWeight.bold,
                              color: isWinningTile(index) 
                                  ? Colors.white 
                                  : (val == 'X' ? Colors.blue : Colors.red),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreItem(String label, int score, Color color, GameTheme theme) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 20)),
        Text('$score', style: GoogleFonts.bangers(fontSize: 24, color: color)),
      ],
    );
  }
}
