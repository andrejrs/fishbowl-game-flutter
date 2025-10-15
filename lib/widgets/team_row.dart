import 'package:flutter/material.dart';

class TeamRow extends StatelessWidget {
  final List<String> players;
  final Color avatarBaseColor;
  final MainAxisAlignment mainAxisAlignment;

  /// Kreira TeamCard
  const TeamRow({
    super.key,
    required this.players,
    required this.mainAxisAlignment,
    this.avatarBaseColor = Colors.blue,
  });

  /// Generiše boju avatara po imenu (stabilno, da se ne menja)
  Color _getAvatarColor(String name) {
    final colors = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.brown,
    ];
    final code = name.codeUnits.fold(0, (a, b) => a + b);
    return colors[code % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    return 
      Row(
        mainAxisAlignment: mainAxisAlignment,
        children: players.map((name) {
          final color = _getAvatarColor(name);
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: color,
                  child: Text(
                    name[0].toUpperCase(),
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  name,
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          );
        }).toList(),
      );
          
  }
}
