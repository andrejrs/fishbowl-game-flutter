// Models for Fishbowl game

enum FishbowlRound { taboo, charades, oneWord }

class Player {
  final String name;
  Player(this.name);
}

class Team {
  final String name;
  final List<Player> players;
  int score;
  Team({required this.name, required this.players, this.score = 0});
}

class GameWord {
  final String word;
  final Player submittedBy;
  bool guessed;
  GameWord({required this.word, required this.submittedBy, this.guessed = false});
}

class GameState {
  int numTeams;
  int numPlayers;
  int wordsPerPlayer;
  int secondsPerTurn;
  List<Player> players;
  List<Team> teams;
  List<GameWord> words;
  int currentTeamIdx;
  int currentRoundIdx;
  int currentWordIdx;
  FishbowlRound get currentRound => FishbowlRound.values[currentRoundIdx];

  GameState({
    required this.numTeams,
    required this.numPlayers,
    required this.wordsPerPlayer,
    required this.secondsPerTurn,
    required this.players,
    required this.teams,
    required this.words,
    this.currentTeamIdx = 0,
    this.currentRoundIdx = 0,
    this.currentWordIdx = 0,
  });
}
