import 'package:flutter/material.dart';

enum MarkerSkin {
  classic,
  emoji,
  food,
  space,
}

class GameTheme extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.dark;
  MarkerSkin _skin = MarkerSkin.emoji;

  ThemeMode get themeMode => _themeMode;
  MarkerSkin get skin => _skin;

  void toggleTheme(bool isDark) {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  void setSkin(MarkerSkin newSkin) {
    _skin = newSkin;
    notifyListeners();
  }

  String getPlayer1Marker() {
    switch (_skin) {
      case MarkerSkin.classic: return 'X';
      case MarkerSkin.emoji: return '🐶';
      case MarkerSkin.food: return '🍔';
      case MarkerSkin.space: return '🚀';
    }
  }

  String getPlayer2Marker() {
    switch (_skin) {
      case MarkerSkin.classic: return 'O';
      case MarkerSkin.emoji: return '🐱';
      case MarkerSkin.food: return '🍕';
      case MarkerSkin.space: return '👾';
    }
  }

  String getSkinName(MarkerSkin s) {
    switch (s) {
      case MarkerSkin.classic: return 'Classic (X/O)';
      case MarkerSkin.emoji: return 'Pets (🐶/🐱)';
      case MarkerSkin.food: return 'Food (🍔/🍕)';
      case MarkerSkin.space: return 'Space (🚀/👾)';
    }
  }

  // Funny commentary logic
  String getCommentary(String winner, bool isDraw) {
    if (isDraw) {
      return "It's a tie! Boring... 😴";
    }
    if (winner == getPlayer1Marker()) {
      return "Player 1 cooked! 🔥";
    } else {
      return "Player 2 stole the W! 💀";
    }
  }

  String getTurnMessage(bool isPlayer1Turn) {
    String marker = isPlayer1Turn ? getPlayer1Marker() : getPlayer2Marker();
    if (isPlayer1Turn) {
      return "Your turn, $marker! Don't mess up.";
    } else {
      return "Waiting for $marker... (plotting doom)";
    }
  }
}
