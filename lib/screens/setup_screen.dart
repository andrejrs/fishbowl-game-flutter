import 'package:flutter/material.dart';
import 'package:fishbowl/config/environment.dart';
import 'package:fishbowl/data/dummy_data.dart';

/// The initial setup screen for the Fishbowl game.
/// Allows users to configure teams, players, words per player, and turn duration.
class SetupScreen extends StatefulWidget {
  /// Creates a [SetupScreen].
  const SetupScreen({super.key});

  /// Builds the setup UI for entering game parameters.
  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  final _formKey = GlobalKey<FormState>();
  int _numTeams = 2;
  int _numPlayers = useDummyData ? dummyPlayerNames.length : 2;
  int _wordsPerPlayer = useDummyData ? totalWordsPerUser : 2;
  int _secondsPerTurn = useDummyData ? 10 : 60;

  final List<String> _playerNames = useDummyData ? dummyPlayerNames : [];
  final TextEditingController _nameController = TextEditingController();
  final FocusNode _wordFocusNode = FocusNode();

  @override
  void dispose() {
    _nameController.dispose();
    _wordFocusNode.dispose();
    super.dispose();
  }

  void _addPlayerName() {
    final name = _nameController.text.trim();
    if (name.isNotEmpty && !_playerNames.contains(name) && _playerNames.length < _numPlayers) {
      setState(() {
        _playerNames.add(name);
        _nameController.clear();
      });
      // Refocus the input after adding a word
      Future.delayed(const Duration(milliseconds: 100), () {
        _wordFocusNode.requestFocus();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF399EF1),
      appBar: AppBar(
        backgroundColor: const Color(0xFF399EF1),
        foregroundColor: Colors.white,
        title: const Text('Fishbowl Setup', style: TextStyle(color: Colors.white)),
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
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      initialValue: _numTeams.toString(),
                      decoration: const InputDecoration(labelText: 'Number of teams'),
                      keyboardType: TextInputType.number,
                      onChanged: (val) {
                        final v = int.tryParse(val) ?? 2;
                        setState(() {
                          _numTeams = v.clamp(2, 10);
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      initialValue: _numPlayers.toString(),
                      decoration: const InputDecoration(labelText: 'Number of players'),
                      keyboardType: TextInputType.number,
                      onChanged: (val) {
                        final v = int.tryParse(val) ?? 4;
                        setState(() {
                          _numPlayers = v.clamp(_numTeams, 20);
                          if (_playerNames.length > _numPlayers) {
                            _playerNames.removeRange(_numPlayers, _playerNames.length);
                          }
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      initialValue: _wordsPerPlayer.toString(),
                      decoration: const InputDecoration(labelText: 'Words per player'),
                      keyboardType: TextInputType.number,
                      onChanged: (val) {
                        final v = int.tryParse(val) ?? 5;
                        setState(() {
                          _wordsPerPlayer = v.clamp(1, 20);
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      initialValue: _secondsPerTurn.toString(),
                      decoration: const InputDecoration(labelText: 'Seconds per turn'),
                      keyboardType: TextInputType.number,
                      onChanged: (val) {
                        final v = int.tryParse(val) ?? 60;
                        setState(() {
                          _secondsPerTurn = v.clamp(10, 300);
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text('Enter player names:'),
              ..._playerNames.asMap().entries.map((entry) {
                final index = entry.key;
                final name = entry.value;
                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey[50], // svetla pozadina
                    border: Border.all(color: Colors.grey.shade300), // tanak okvir
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      )
                    ],
                  ),
                  child: Row(
                    children: [
                      Text('${index + 1}. ', style: const TextStyle(fontWeight: FontWeight.bold)),
                      Expanded(child: Text(name)),
                    ],
                  ),
                );
              }).toList(),

              if (_playerNames.length < _numPlayers)
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _nameController,
                        focusNode: _wordFocusNode,
                        decoration: const InputDecoration(labelText: 'Player name'),
                        onSubmitted: (_) => _addPlayerName(),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.check),
                      onPressed: _addPlayerName,
                    ),
                  ],
                ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF399EF1),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: _playerNames.length == _numPlayers
                    ? () {
                        Navigator.pushNamed(context, '/teams', arguments: {
                          'numTeams': _numTeams,
                          'numPlayers': _numPlayers,
                          'wordsPerPlayer': _wordsPerPlayer,
                          'secondsPerTurn': _secondsPerTurn,
                          'playerNames': List<String>.from(_playerNames),
                        });
                      }
                    : null,
                child: const Text('Continue'),
              ),
            ],
          ),
        ),
        ),
      ),
    );
  }
}

