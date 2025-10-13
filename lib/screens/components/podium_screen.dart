import 'package:flutter/material.dart';

class PodiumWidget extends StatelessWidget {
  final List<int> teamScores;

  const PodiumWidget({super.key, required this.teamScores});

  @override
  Widget build(BuildContext context) {
    final numTeams = teamScores.length;

    // Sort teams descending
    final List<Map<String, dynamic>> teams = List.generate(numTeams, (i) {
      return {'team': i + 1, 'score': teamScores[i]};
    });
    teams.sort((a, b) => b['score'].compareTo(a['score']));

    final top3 = teams.take(3).toList();
    final rest = teams.skip(3).toList();

    return Column(
      children: [
        SizedBox(
          height: 200,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildPodiumBlock(top3.length > 1 ? top3[1] : null, Colors.grey, 120),
              const SizedBox(width: 16),
              _buildPodiumBlock(top3.isNotEmpty ? top3[0] : null, Colors.amber, 160),
              const SizedBox(width: 16),
              _buildPodiumBlock(top3.length > 2 ? top3[2] : null, Colors.brown, 100),
            ],
          ),
        ),
        const SizedBox(height: 32),
        // Rest of the teams as list
        Column(
          children: rest.map((team) {
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.deepOrange,
                child: Text('${team['team']}', style: const TextStyle(color: Colors.white)),
              ),
              title: Text('Team ${team['team']}'),
              trailing: Text('${team['score']}', style: const TextStyle(fontWeight: FontWeight.bold)),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildPodiumBlock(Map<String, dynamic>? team, Color color, double height) {
    if (team == null) return SizedBox(width: 80);
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 80,
          height: height,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              '${team['score']}',
              style: const TextStyle(color: Colors.white, fontSize: 29, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Team ${team['team']}',
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
