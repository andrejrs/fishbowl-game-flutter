import 'package:flutter/material.dart';

class SetupScreen extends StatefulWidget {
  const SetupScreen({super.key});
  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  final _formKey = GlobalKey<FormState>();
  int _numTeams = 2;
  int _numPlayers = 2;
  int _wordsPerPlayer = 2;
  int _secondsPerTurn = 10;
  final List<String> _playerNames = [];
  final TextEditingController _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _addPlayerName() {
    final name = _nameController.text.trim();
    if (name.isNotEmpty && !_playerNames.contains(name) && _playerNames.length < _numPlayers) {
      setState(() {
        _playerNames.add(name);
        _nameController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Fishbowl Setup')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
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
              ..._playerNames.map((name) => ListTile(title: Text(name))),
              if (_playerNames.length < _numPlayers)
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _nameController,
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
    );
  }
}
