import 'package:flutter/material.dart';
import 'package:fishbowl/config/environment.dart';
import 'package:fishbowl/data/dummy_data.dart';

/// Screen for entering words for each player in the Fishbowl game.
/// Prevents duplicate word entry across all players.
class WordEntryScreen extends StatefulWidget {
  /// Creates a [WordEntryScreen].
  const WordEntryScreen({super.key});
  @override
  State<WordEntryScreen> createState() => _WordEntryScreenState();
}

/// State for [WordEntryScreen]. Handles word entry, duplicate checking, and player switching.
class _WordEntryScreenState extends State<WordEntryScreen> {
  /// The word that is a duplicate, if any. Used to show error state.
  String? _duplicateWord;
  int _currentPlayerIdx = useDummyData ? dummyPlayerNames.length-1 : 0;
  final Map<String, List<String>> _playerWords = useDummyData ? dummyPlayerWords : {};
  final TextEditingController _wordController = TextEditingController();
  final FocusNode _wordFocusNode = FocusNode();

  /// Disposes controllers and focus nodes.
  @override
  void dispose() {
    _wordController.dispose();
    _wordFocusNode.dispose();
    super.dispose();
  }

  /// Adds a word for the current player if it is unique and valid.
  ///
  /// [words] - The list of words already entered by the current player.
  /// [currentPlayer] - The name of the player currently entering words.
  /// [wordsPerPlayer] - The maximum number of words each player should enter.
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

  /// Advances to the next player or proceeds to the game if all words are entered.
  ///
  /// [playerNames] - The list of all player names.
  /// [args] - The arguments to pass to the game screen.
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

  /// Builds the word entry UI.
  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final List<String> playerNames = List<String>.from(args['playerNames']);
    final int wordsPerPlayer = args['wordsPerPlayer'];

    final String currentPlayer = playerNames[_currentPlayerIdx];
    final words = _playerWords[currentPlayer] ?? <String>[];

    return Scaffold(
      backgroundColor: const Color(0xFF399EF1),
      appBar: AppBar(
        backgroundColor: const Color(0xFF399EF1),
        foregroundColor: Colors.white,
        title: const Text('Word Entry', style: TextStyle(color: Colors.white)),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Player: $currentPlayer', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Enter $wordsPerPlayer words:'),
            ...words.asMap().entries.map((entry) {
              final index = entry.key;   // redni broj
              final word = entry.value;  // sama reč
              return Container(
                margin: const EdgeInsets.symmetric(vertical: 4),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.grey[50], // svetla pozadina
                  border: Border.all(color: Colors.grey.shade300), // tanka ivica
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Text('${index + 1}.', style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(width: 8),
                    Expanded(child: Text(word)),
                  ],
                ),
              );
            }).toList(),

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
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF399EF1),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: words.length == wordsPerPlayer ? () => _nextPlayer(playerNames, args) : null,
              child: Text(_currentPlayerIdx < playerNames.length - 1 ? 'Next Player' : 'Continue'),
            ),
          ],
        ),
        ),
      ),
    );
  }
}
