class GameLogic {
  static const List<List<int>> winPatterns = [
    [0, 1, 2],
    [3, 4, 5],
    [6, 7, 8],
    [0, 3, 6],
    [1, 4, 7],
    [2, 5, 8],
    [0, 4, 8],
    [2, 4, 6],
  ];

  static Map<String, dynamic> checkWinnerWithPattern(List<String> board) {
    for (var pattern in winPatterns) {
      String a = board[pattern[0]];
      String b = board[pattern[1]];
      String c = board[pattern[2]];

      if (a != '' && a == b && b == c) {
        return {
          'winner': a,
          'pattern': pattern,
        };
      }
    }

    if (!board.contains('')) {
      return {'winner': 'Draw'};
    }

    return {'winner': ''};
  }
}
