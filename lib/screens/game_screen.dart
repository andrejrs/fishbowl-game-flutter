import 'package:flutter/material.dart';
import 'dart:async';
import 'end_of_round_screen.dart';
import 'components/circular_countdown.dart';
import 'package:fishbowl/widgets/team_row.dart';

/// Main gameplay screen for the Fishbowl game.
/// Handles team turns, word guessing, scoring, and round transitions.
class GameScreen extends StatefulWidget {
  /// Creates a [GameScreen].
  const GameScreen({super.key});
  @override
  State<GameScreen> createState() => _GameScreenState();
}

/// State for [GameScreen]. Manages game logic, timers, and UI updates.
class _GameScreenState extends State<GameScreen> {
  /// Starts a team's turn, initializing timer and shuffling remaining words.
  ///
  /// [secondsPerTurn] - The number of seconds for each team's turn.
  void _startTurn(int secondsPerTurn) {
    setState(() {
      _isPlaying = true;
      _secondsLeft = secondsPerTurn;
      _score = 0;
      _remainingWords = List<String>.from(_roundWords);
      _remainingWords.shuffle();
      _wordIdx = 0;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _secondsLeft--;
        if (_secondsLeft <= 0) {
          _endTurn();
        }
      });
    });
  }

  /// Ends the current team's turn, updates scores, and advances to the next team or ends the round.
  void _endTurn() {
    _timer?.cancel();
    setState(() {
      _isPlaying = false;
      _teamScores[_teamIdx] += _score;
    });
    Future.delayed(const Duration(milliseconds: 500), () {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args == null) return;
      final int numTeams = args['numTeams'];
      if (mounted) {
        if (_roundWords.isEmpty) {
          setState(() {
            _showEndOfRound = true;
          });
        } else {
          setState(() {
            _teamIdx = (_teamIdx + 1) % numTeams;
            _waitingForNextTeam = true;
          });
        }
      }
    });
  }

  /// Advances to the next round or ends the game if all rounds are complete.
  ///
  /// [numTeams] - The number of teams in the game.
  /// [numRounds] - The total number of rounds in the game.
  void _nextRoundOrEnd(int numTeams, int numRounds) {
    if (_roundIdx < numRounds - 1) {
      setState(() {
        _showEndOfRound = false;
        _roundIdx++;
        _teamIdx = 0;
        _waitingForNextTeam = true;
        final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
        if (args != null) {
          _roundWords = List<String>.from(args['words']);
        }
      });
    } else {
      Navigator.pushReplacementNamed(context, '/results', arguments: {
        'teamScores': _teamScores,
      });
    }
  }

  /// Builds the main game UI, including timer, word display, and score.
  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final int numTeams = args['numTeams'];
    final int secondsPerTurn = args['secondsPerTurn'];
    final List<List<String>> teams = (args['teams'] as List).map((e) => List<String>.from(e)).toList();
    final List<String> words = List<String>.from(args['words']);

    if (_teamScores.length != numTeams) {
      _teamScores = List.filled(numTeams, 0);
    }
    // Initialize round words at start of each round
    if (_roundWords.isEmpty && !_showEndOfRound) {
      _roundWords = List<String>.from(words);
    }

    if (_showEndOfRound) {
      // Show EndOfRoundScreen and wait for pop, then continue to next round or results
      return EndOfRoundScreen(
        roundNumber: _roundIdx + 1,
        teamScores: _teamScores,
        onNextRound: () {
          _nextRoundOrEnd(numTeams, 3);
        },
      );
    }
    return Scaffold(
      backgroundColor: const Color(0xFF399EF1),
      appBar: AppBar(
        backgroundColor: const Color(0xFF399EF1),
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        title: Text('Round ${_roundIdx + 1} of 3 - ${roundNames[_roundIdx]}', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: Container(
          width: double.infinity,
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
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              if (!_isPlaying) ...[
                Text(roundNames[_roundIdx], style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                Text(roundDescriptions[_roundIdx], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 24),
                Text('Team ${_teamIdx + 1} are you ready?', style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: Color(0xFF399EF1))),
                // Text('Players: ${teams[_teamIdx].join(", ")}', style: const TextStyle(fontSize: 12)),
                const SizedBox(height: 24),
                TeamRow(
                  players: teams[_teamIdx],
                  mainAxisAlignment: MainAxisAlignment.center,
                ),
              ],
              const SizedBox(height: 24),
              if (!_isPlaying && _waitingForNextTeam)
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF399EF1),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () {
                    setState(() {
                      _waitingForNextTeam = false;
                    });
                    _startTurn(secondsPerTurn);
                  },
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Start'),
                ),
              if (!_isPlaying && !_waitingForNextTeam && !_teamScores.any((s) => s > 0))
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF399EF1),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () => _startTurn(secondsPerTurn),
                  child: const Text('Start'),
                ),
              if (_isPlaying) ...[
                CircularCountdown(
                  secondsLeft: _secondsLeft,
                  totalSeconds: secondsPerTurn,
                ),
                const SizedBox(height: 16),
                if (_remainingWords.isNotEmpty)
                  Column(
                    children: [
                      Text(_remainingWords[_wordIdx], style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Color(0xFF399EF1))),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(255, 48, 199, 48),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: () {
                          setState(() {
                            _score++;
                            String guessed = _remainingWords[_wordIdx];
                            _roundWords.remove(guessed);
                            _remainingWords.removeAt(_wordIdx);
                            if (_roundWords.isEmpty) {
                              // End round immediately if last word guessed
                              _timer?.cancel();
                              _isPlaying = false;
                              _teamScores[_teamIdx] += _score;
                              _showEndOfRound = true;
                            } else if (_remainingWords.isEmpty) {
                              _endTurn();
                            } else {
                              _wordIdx = _wordIdx % _remainingWords.length;
                            }
                          });
                        },
                        icon: const Icon(Icons.check),
                        label: const Text('Correct'),
                      ),
                    ],
                  )
                else
                  const Text('No more words!'),
                const SizedBox(height: 24),
                Text('Score this turn: $_score'),
                Text('Words left: ${_roundWords.length}'),
              ],
              // const SizedBox(height: 24),
              // if (!_isPlaying && !_waitingForNextTeam) ...[
              // Text('Scores:', style: const TextStyle(fontWeight: FontWeight.bold)),
              // for (int i = 0; i < numTeams; i++)
              //   Text('Team ${i + 1}: ${_teamScores[i]}'),
              // ],
            ],
          ),
        ),
      ),
    );
  }
  bool _showEndOfRound = false;
  int _roundIdx = 0;
  int _teamIdx = 0;
  int _wordIdx = 0;
  int _score = 0;
  int _secondsLeft = 0;
  bool _isPlaying = false;
  Timer? _timer;
  List<String> _remainingWords = [];
  List<String> _roundWords = [];
  List<int> _teamScores = [];
  bool _waitingForNextTeam = false;

  static const List<String> roundNames = [
    'Taboo',
    'Charades',
    'One Word',
  ];

  static const List<String> roundDescriptions = [
    '(Verbal Explanation)',
    '(Act it out silently)',
    '(Give only a single-word clue)',
  ];

  // ...methods and build() go here...
}
