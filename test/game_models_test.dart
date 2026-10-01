import 'package:flutter_test/flutter_test.dart';
import 'package:okey_defteri/models/game_models.dart';

void main() {
  group('GameRules', () {
    test('Default rules are standard 101 rules', () {
      final rules = GameRules();

      expect(rules.isKatlamali, isFalse);
      expect(rules.penaltyPoints, 101);
      expect(rules.cantOpenPoints, 202);
      expect(rules.finishPoints, -101);
      expect(rules.currentKatlamaliThreshold, 101);
    });

    test('getPointsFor returns correct penalty points based on rule config', () {
      final customRules = GameRules(
        penaltyPoints: 202,
        cantOpenPoints: 404,
        finishPoints: -202,
      );

      // Penalties
      expect(customRules.getPointsFor(ScoreType.islekAtti), 202);
      expect(customRules.getPointsFor(ScoreType.okeyAtti), 202);
      expect(customRules.getPointsFor(ScoreType.okeyiniAldilar), 202);
      expect(customRules.getPointsFor(ScoreType.yanlisElActi), 202);
      expect(customRules.getPointsFor(ScoreType.attigiTasiAldilar), 0);
      expect(customRules.getPointsFor(ScoreType.acamadi), 404);

      // Finishes (negative values)
      expect(customRules.getPointsFor(ScoreType.normalBitti), -202);
      expect(customRules.getPointsFor(ScoreType.eldenBitti), -404);
      expect(customRules.getPointsFor(ScoreType.okeyAtarakBitti), -404);
      expect(customRules.getPointsFor(ScoreType.okeyAtarakEldenBitti), -808);
    });

    test('Katlamali threshold updates to new maximum and resets correctly', () {
      final game = Game(
        id: 'test_game',
        createdAt: DateTime.now(),
        team1: Team(
          id: 't1',
          name: 'Takım 1',
          player1: Player(id: 'p1', name: 'P1', seatIndex: 0),
          player2: Player(id: 'p2', name: 'P2', seatIndex: 2),
        ),
        team2: Team(
          id: 't2',
          name: 'Takım 2',
          player1: Player(id: 'p3', name: 'P3', seatIndex: 1),
          player2: Player(id: 'p4', name: 'P4', seatIndex: 3),
        ),
        rules: GameRules(isKatlamali: true),
      );

      expect(game.rules.currentKatlamaliThreshold, 101);

      // First hand opened with 114
      game.updateKatlamaliThreshold(114);
      expect(game.rules.currentKatlamaliThreshold, 114);

      // Trying to update with lower value does not decrease threshold
      game.updateKatlamaliThreshold(108);
      expect(game.rules.currentKatlamaliThreshold, 114);

      // Higher hand opened with 125
      game.updateKatlamaliThreshold(125);
      expect(game.rules.currentKatlamaliThreshold, 125);

      // Next round resets threshold back to initial 101
      game.resetKatlamaliThreshold();
      expect(game.rules.currentKatlamaliThreshold, 101);
    });

    test('GameRules serialization and deserialization works seamlessly', () {
      final original = GameRules(
        isKatlamali: true,
        penaltyPoints: 202,
        cantOpenPoints: 404,
        finishPoints: 202,
        currentKatlamaliThreshold: 130,
      );

      final json = original.toJson();
      final restored = GameRules.fromJson(json);

      expect(restored.isKatlamali, isTrue);
      expect(restored.penaltyPoints, 202);
      expect(restored.cantOpenPoints, 404);
      expect(restored.finishPoints, 202);
      expect(restored.currentKatlamaliThreshold, 130);
    });

    test('Backward compatibility: Game.fromJson handles missing rules gracefully', () {
      final legacyJson = {
        'id': 'legacy_game',
        'createdAt': DateTime.now().toIso8601String(),
        'mode': 'okey101',
        'currentRound': 1,
        'team1': {
          'id': 't1',
          'name': 'Team 1',
          'player1': {'id': 'p1', 'name': 'Player 1', 'seatIndex': 0, 'scores': []},
          'player2': {'id': 'p2', 'name': 'Player 2', 'seatIndex': 2, 'scores': []},
        },
        'team2': {
          'id': 't2',
          'name': 'Team 2',
          'player1': {'id': 'p3', 'name': 'Player 3', 'seatIndex': 1, 'scores': []},
          'player2': {'id': 'p4', 'name': 'Player 4', 'seatIndex': 3, 'scores': []},
        },
      };

      final game = Game.fromJson(legacyJson);

      expect(game.rules, isNotNull);
      expect(game.rules.isKatlamali, isFalse);
      expect(game.rules.penaltyPoints, 101);
      expect(game.rules.cantOpenPoints, 202);
    });

    test('Americano score types have correct updated points', () {
      expect(ScoreType.americanoKazandi.defaultPoints, -30);
      expect(ScoreType.americanoOkeyElindeKaldi.defaultPoints, 30);
      expect(ScoreType.americanoOkeyAtarakBitti.defaultPoints, -100);
      expect(ScoreType.americanoIslek.defaultPoints, 50);
      expect(ScoreType.americanoHile.defaultPoints, 50);
      expect(ScoreType.americanoIslekAtarakBitti.defaultPoints, 100);
      expect(ScoreType.americanoYanlisBitti.defaultPoints, 100);
    });
  });
}
