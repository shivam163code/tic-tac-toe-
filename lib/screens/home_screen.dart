import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../logic/theme_logic.dart';
import 'game_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<GameTheme>(context);

    // Helper to build nice gradient buttons
    Widget buildGameButton(String label, IconData icon, Color color, VoidCallback onTap) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Ink(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 40),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color.withOpacity(0.8), color],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.4),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: Colors.white, size: 28),
                const SizedBox(width: 15),
                Text(
                  label,
                  style: GoogleFonts.fredoka(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: theme.themeMode == ThemeMode.dark
                ? [const Color(0xFF141E30), const Color(0xFF243B55)]
                : [Colors.blue.shade100, Colors.purple.shade100],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Title
            Text(
              'TIC TAC TOE',
              style: GoogleFonts.bangers(
                fontSize: 60,
                color: theme.themeMode == ThemeMode.dark ? Colors.white : Colors.black87,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 10),
            Text(
               theme.getSkinName(theme.skin).split(' ')[0] + ' Edition', // "Classic", "Pets", etc.
               style: GoogleFonts.fredoka(
                 fontSize: 20,
                 color: Colors.grey[600],
                 fontWeight: FontWeight.bold
               ),
            ),
            const SizedBox(height: 60),

            // Buttons
            buildGameButton('Vs AI', Icons.android, Colors.purple, () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const GameScreen(vsAI: true)),
              );
            }),
            buildGameButton('Vs Friend', Icons.person, Colors.blue, () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const GameScreen(vsAI: false)),
              );
            }),

            const SizedBox(height: 40),

            // Settings / Theme Toggle
            IconButton(
              icon: Icon(
                Icons.settings,
                size: 30, 
                color: theme.themeMode == ThemeMode.dark ? Colors.white70 : Colors.black54
              ),
              onPressed: () => _showSettings(context),
            ),
            Text('Settings', style: GoogleFonts.fredoka(color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  void _showSettings(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _SettingsSheet(),
    );
  }
}

class _SettingsSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<GameTheme>(context);
    final isDark = theme.themeMode == ThemeMode.dark;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2C3E50) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Customize!',
            style: GoogleFonts.fredoka(
              fontSize: 24,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 20),
          
          // Theme Toggle
          ListTile(
            leading: Icon(isDark ? Icons.dark_mode : Icons.light_mode, color: Colors.orange),
            title: Text('Dark Mode', style: TextStyle(color: isDark ? Colors.white : Colors.black)),
            trailing: Switch(
              value: isDark,
              onChanged: (val) => theme.toggleTheme(val),
              activeColor: Colors.orange,
            ),
          ),

          const Divider(),

          // Skin Selector
          Text('Choose Skin', style: GoogleFonts.fredoka(color: Colors.grey)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 15,
            children: MarkerSkin.values.map((skin) {
              final isSelected = theme.skin == skin;
              return ChoiceChip(
                label: Text(theme.getSkinName(skin).split(' ')[0]), // "Classic"
                selected: isSelected,
                onSelected: (selected) {
                  if (selected) theme.setSkin(skin);
                },
                selectedColor: Colors.blueAccent,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                ),
                backgroundColor: isDark ? Colors.black26 : Colors.grey[200],
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
