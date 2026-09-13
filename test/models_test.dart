import 'package:flutter_test/flutter_test.dart';
import 'package:fishbowl/models.dart';

void main() {
  group('Player', () {
    test('stores the given name', () {
      final player = Player('Alice');
      expect(player.name, 'Alice');
    });
  });

  group('Team', () {
    test('defaults score to 0', () {
      final team = Team(name: 'Team 1', players: [Player('Alice')]);
      expect(team.score, 0);
      expect(team.name, 'Team 1');
      expect(team.players, hasLength(1));
    });

    test('accepts an explicit initial score', () {
      final team = Team(name: 'Team 2', players: const [], score: 5);
      expect(team.score, 5);
    });

    test('score is mutable', () {
      final team = Team(name: 'Team 1', players: const []);
      team.score += 3;
      expect(team.score, 3);
    });
  });

  group('GameWord', () {
    test('defaults guessed to false', () {
      final word = GameWord(word: 'apple', submittedBy: Player('Alice'));
      expect(word.guessed, isFalse);
      expect(word.word, 'apple');
      expect(word.submittedBy.name, 'Alice');
    });

    test('guessed can be toggled', () {
      final word = GameWord(word: 'apple', submittedBy: Player('Alice'));
      word.guessed = true;
      expect(word.guessed, isTrue);
    });
  });

  group('FishbowlRound', () {
    test('has exactly three rounds in the expected order', () {
      expect(FishbowlRound.values, [
        FishbowlRound.taboo,
        FishbowlRound.charades,
        FishbowlRound.oneWord,
      ]);
    });
  });

  group('GameState', () {
    GameState buildState({int currentRoundIdx = 0}) {
      return GameState(
        numTeams: 2,
        numPlayers: 4,
        wordsPerPlayer: 3,
        secondsPerTurn: 60,
        players: [Player('Alice'), Player('Bob')],
        teams: [
          Team(name: 'Team 1', players: [Player('Alice')]),
          Team(name: 'Team 2', players: [Player('Bob')]),
        ],
        words: [GameWord(word: 'apple', submittedBy: Player('Alice'))],
        currentRoundIdx: currentRoundIdx,
      );
    }

    test('defaults currentTeamIdx, currentRoundIdx, currentWordIdx to 0', () {
      final state = buildState();
      expect(state.currentTeamIdx, 0);
      expect(state.currentRoundIdx, 0);
      expect(state.currentWordIdx, 0);
    });

    test('currentRound maps currentRoundIdx to the right enum value', () {
      expect(buildState(currentRoundIdx: 0).currentRound, FishbowlRound.taboo);
      expect(buildState(currentRoundIdx: 1).currentRound, FishbowlRound.charades);
      expect(buildState(currentRoundIdx: 2).currentRound, FishbowlRound.oneWord);
    });
  });
}
