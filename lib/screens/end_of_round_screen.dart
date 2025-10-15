import 'package:flutter/material.dart';

class EndOfRoundScreen extends StatelessWidget {
  final int roundNumber;
  final List<int> teamScores;
  final VoidCallback onNextRound;

  const EndOfRoundScreen({
    super.key,
    required this.roundNumber,
    required this.teamScores,
    required this.onNextRound,
  });

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final int numTeams = args['numTeams'];
    return Scaffold(
      backgroundColor: const Color(0xFF399EF1),
      appBar: AppBar(
        backgroundColor: const Color(0xFF399EF1),
        foregroundColor: Colors.white,
        title: Text('End of Round $roundNumber', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text('Current Scores:', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),

            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: List.generate(numTeams, (i) {
                final int maxScore = teamScores.reduce((a, b) => a > b ? a : b);
                final double percentage = maxScore == 0 ? 0 : teamScores[i] / maxScore;
                final Color textColor = percentage < 0.2 ? Colors.black : Colors.white;

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Stack(
                    alignment: Alignment.centerLeft,
                    children: [
                      // empty bar
                      Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),

                      // blue part
                      FractionallySizedBox(
                        widthFactor: percentage,
                        child: Container(
                          height: 50,
                          decoration: BoxDecoration(
                            color: const Color(0xFF399EF1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.symmetric(horizontal: 16),

                        ),
                      ),

                      // name outside for 0 points
                        Positioned(
                          left: 16,
                          child: Text(
                            'Team ${i + 1}',
                            style: TextStyle(
                              color: textColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),

                      // Krug sa rezultatom (uvek vidljiv)
                      Positioned(
                        right: 16,
                        child: CircleAvatar(
                          backgroundColor: const Color(0xFFFFA500),
                          child: Text(
                            '${teamScores[i]}',
                            style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),

            const SizedBox(height: 32),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF399EF1),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 32),
                textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: onNextRound,
              child: const Text('Start Next Round'),
            ),
          ],
        ),
        ),
      ),
    );
  }
}
