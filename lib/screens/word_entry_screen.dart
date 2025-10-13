import 'package:flutter/material.dart';

class WordEntryScreen extends StatefulWidget {
  const WordEntryScreen({super.key});
  @override
  State<WordEntryScreen> createState() => _WordEntryScreenState();
}

class _WordEntryScreenState extends State<WordEntryScreen> {
  String? _duplicateWord;
  int _currentPlayerIdx = 0;
  final Map<String, List<String>> _playerWords = {};
  final TextEditingController _wordController = TextEditingController();
  final FocusNode _wordFocusNode = FocusNode();

  @override
  void dispose() {
    _wordController.dispose();
    _wordFocusNode.dispose();
    super.dispose();
  }

  void _addWord(List<String> words, String currentPlayer, int wordsPerPlayer) {
    final word = _wordController.text.trim();
    final allWords = <String>[];
    _playerWords.forEach((_, w) => allWords.addAll(w));
    final isDuplicate = allWords.contains(word);
    if (word.isEmpty || words.length >= wordsPerPlayer) return;
    if (isDuplicate) {
      setState(() {
        _duplicateWord = word;
      });
      return;
    }
    setState(() {
      _playerWords[currentPlayer] = [...words, word];
      _wordController.clear();
      _duplicateWord = null;
    });
    // Refocus the input after adding a word
    Future.delayed(const Duration(milliseconds: 100), () {
      _wordFocusNode.requestFocus();
    });
  }

  void _nextPlayer(List<String> playerNames, Map<String, dynamic> args) {
    if (_currentPlayerIdx < playerNames.length - 1) {
      setState(() {
        _currentPlayerIdx++;
      });
    } else {
      // All words entered, flatten and continue
      final allWords = <String>[];
      _playerWords.forEach((_, w) => allWords.addAll(w));
      Navigator.pushNamed(context, '/game', arguments: {
        ...args,
        'words': allWords,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final List<String> playerNames = List<String>.from(args['playerNames']);
    final int wordsPerPlayer = args['wordsPerPlayer'];

    final String currentPlayer = playerNames[_currentPlayerIdx];
    final words = _playerWords[currentPlayer] ?? <String>[];

    return Scaffold(
      appBar: AppBar(title: const Text('Word Entry')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Player: $currentPlayer', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Enter $wordsPerPlayer words:'),
            ...words.map((w) => ListTile(title: Text(w))),
            if (words.length < wordsPerPlayer)
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _wordController,
                      focusNode: _wordFocusNode,
                      decoration: InputDecoration(
                        labelText: 'Word',
                        errorText: _duplicateWord != null ? 'This word has already been entered.' : null,
                        enabledBorder: _duplicateWord != null
                            ? OutlineInputBorder(borderSide: BorderSide(color: Colors.red))
                            : null,
                        focusedBorder: _duplicateWord != null
                            ? OutlineInputBorder(borderSide: BorderSide(color: Colors.red, width: 2))
                            : null,
                      ),
                      onChanged: (_) {
                        if (_duplicateWord != null) {
                          setState(() {
                            _duplicateWord = null;
                          });
                        }
                      },
                      onSubmitted: (_) => _addWord(words, currentPlayer, wordsPerPlayer),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.check),
                    onPressed: () => _addWord(words, currentPlayer, wordsPerPlayer),
                  ),
                ],
              ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: words.length == wordsPerPlayer ? () => _nextPlayer(playerNames, args) : null,
              child: Text(_currentPlayerIdx < playerNames.length - 1 ? 'Next Player' : 'Continue'),
            ),
          ],
        ),
      ),
    );
  }
}
