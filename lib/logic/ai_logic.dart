import 'game_logic.dart';

class AiLogic {
  // AI plays as 'O'
  static int bestMove(List<String> board) {
    int bestScore = -1000;
    int move = -1;

    for (int i = 0; i < board.length; i++) {
      if (board[i] == '') {
        board[i] = 'O';
        int score = minimax(board, 0, false);
        board[i] = '';

        if (score > bestScore) {
          bestScore = score;
          move = i;
        }
      }
    }
    return move;
  }

  static int minimax(List<String> board, int depth, bool isMaximizing) {
    final result = GameLogic.checkWinnerWithPattern(board);
    final winner = result['winner'];

    if (winner == 'O') return 10 - depth;   // AI wins
    if (winner == 'X') return depth - 10;   // Player wins
    if (winner == 'Draw') return 0;         // Draw

    if (isMaximizing) {
      int bestScore = -1000;
      for (int i = 0; i < board.length; i++) {
        if (board[i] == '') {
          board[i] = 'O';
          int score = minimax(board, depth + 1, false);
          board[i] = '';
          bestScore = score > bestScore ? score : bestScore;
        }
      }
      return bestScore;
    } else {
      int bestScore = 1000;
      for (int i = 0; i < board.length; i++) {
        if (board[i] == '') {
          board[i] = 'X';
          int score = minimax(board, depth + 1, true);
          board[i] = '';
          bestScore = score < bestScore ? score : bestScore;
        }
      }
      return bestScore;
    }
  }
}
