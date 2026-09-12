import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:okey_defteri/models/game_models.dart';
import 'package:okey_defteri/services/storage_service.dart';
import 'package:okey_defteri/services/settings_service.dart';

void main() {
  test('isFinishType identifies all finishing score types correctly', () {
    expect(ScoreType.normalBitti.isFinishType, isTrue);
    expect(ScoreType.eldenBitti.isFinishType, isTrue);
    expect(ScoreType.okeyAtarakBitti.isFinishType, isTrue);
    expect(ScoreType.okeyAtarakEldenBitti.isFinishType, isTrue);
    expect(ScoreType.americanoKazandi.isFinishType, isTrue);
    expect(ScoreType.americanoOkeyAtarakBitti.isFinishType, isTrue);

    expect(ScoreType.islekAtti.isFinishType, isFalse);
    expect(ScoreType.okeyAtti.isFinishType, isFalse);
    expect(ScoreType.eldeKalanTaslar.isFinishType, isFalse);
    expect(ScoreType.americanoEldeKalan.isFinishType, isFalse);
  });

  test('Player winCount counts trophies accurately', () {
    final player = Player(id: 'p1', name: 'Ahmet', seatIndex: 0);

    expect(player.winCount, 0);

    // Normal bitiş
    player.scores.add(ScoreEntry(
      id: 's1',
      type: ScoreType.normalBitti,
      points: -101,
      timestamp: DateTime.now(),
      roundNumber: 1,
    ));
    expect(player.winCount, 1);

    // Elde kalan ceza (kazanma değil)
    player.scores.add(ScoreEntry(
      id: 's2',
      type: ScoreType.eldeKalanTaslar,
      points: 45,
      timestamp: DateTime.now(),
      roundNumber: 2,
    ));
    expect(player.winCount, 1);

    // Americano kazanma
    player.scores.add(ScoreEntry(
      id: 's3',
      type: ScoreType.americanoKazandi,
      points: -50,
      timestamp: DateTime.now(),
      roundNumber: 3,
    ));
    expect(player.winCount, 2);
  });

  test('Game identifies team partners correctly for teamed games', () {
    final p1 = Player(id: 'p1', name: 'P1', seatIndex: 0);
    final p2 = Player(id: 'p2', name: 'P2', seatIndex: 1);
    final p3 = Player(id: 'p3', name: 'P3', seatIndex: 2);
    final p4 = Player(id: 'p4', name: 'P4', seatIndex: 3);
    final team1 = Team(id: 't1', name: 'Team 1', player1: p1, player2: p3);
    final team2 = Team(id: 't2', name: 'Team 2', player1: p2, player2: p4);

    final americanoGame = Game(
      id: 'g1',
      createdAt: DateTime.now(),
      team1: team1,
      team2: team2,
      gameMode: GameMode.americano,
    );

    expect(americanoGame.isAmericanoSolo, isFalse);
    expect(americanoGame.getTeamForPlayer(p1).player2.id, equals('p3'));
    expect(americanoGame.getTeamForPlayer(p3).player1.id, equals('p1'));
    expect(americanoGame.getTeamForPlayer(p2).player2.id, equals('p4'));
    expect(americanoGame.getTeamForPlayer(p4).player1.id, equals('p2'));
  });

  test('StorageService.deleteGame removes game locally', () async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    final p1 = Player(id: 'p1', name: 'P1', seatIndex: 0);
    final p2 = Player(id: 'p2', name: 'P2', seatIndex: 1);
    final p3 = Player(id: 'p3', name: 'P3', seatIndex: 2);
    final p4 = Player(id: 'p4', name: 'P4', seatIndex: 3);
    final team1 = Team(id: 't1', name: 'Team 1', player1: p1, player2: p3);
    final team2 = Team(id: 't2', name: 'Team 2', player1: p2, player2: p4);

    final game = Game(
      id: 'test_game_1',
      createdAt: DateTime.now(),
      team1: team1,
      team2: team2,
      gameMode: GameMode.okey101,
    );

    // Save and delete
    await StorageService.saveGame(game);
    var saved = await StorageService.getSavedGames();
    expect(saved.any((g) => g.id == 'test_game_1'), isTrue);

    await StorageService.deleteGame('test_game_1', deleteFromCloud: false);
    saved = await StorageService.getSavedGames();
    expect(saved.any((g) => g.id == 'test_game_1'), isFalse);
  });

  test('Player.getNickname generates dynamic situational nicknames and avoids flicker', () async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({'toxic_nicknames_enabled': true});
    await SettingsService.init();

    final p1 = Player(id: 'p1', name: 'Ahmet', seatIndex: 0);
    final p2 = Player(id: 'p2', name: 'Mehmet', seatIndex: 1);
    final p3 = Player(id: 'p3', name: 'Ayşe', seatIndex: 2);
    final p4 = Player(id: 'p4', name: 'Fatma', seatIndex: 3);
    final players = [p1, p2, p3, p4];

    // Early game (round 1, no scores)
    final nickP1Round1 = p1.getNickname(players, 1);
    expect(nickP1Round1, isNotEmpty);
    // Stability test: calling repeatedly in the same round produces the same nickname (no flickering)
    expect(p1.getNickname(players, 1), equals(nickP1Round1));

    // When toxic nicknames disabled
    await SettingsService.setToxicNicknamesEnabled(false);
    expect(p1.getNickname(players, 1), isEmpty);
    await SettingsService.setToxicNicknamesEnabled(true);

    // P1 wins multiple rounds (on fire)
    p1.scores.add(ScoreEntry(id: 's1', type: ScoreType.okeyAtarakBitti, points: -202, timestamp: DateTime.now(), roundNumber: 1));
    p1.scores.add(ScoreEntry(id: 's2', type: ScoreType.normalBitti, points: -101, timestamp: DateTime.now(), roundNumber: 2));

    // P4 gets massive penalties (last place, score crisis)
    p4.scores.add(ScoreEntry(id: 's3', type: ScoreType.eldeKalanTaslar, points: 280, timestamp: DateTime.now(), roundNumber: 1));
    p4.scores.add(ScoreEntry(id: 's4', type: ScoreType.yanlisElActi, points: 101, timestamp: DateTime.now(), roundNumber: 2));

    final p1Nick = p1.getNickname(players, 3);
    final p4Nick = p4.getNickname(players, 3);

    expect(p1Nick, isNotEmpty);
    expect(p4Nick, isNotEmpty);
    expect(p1Nick != p4Nick, isTrue);

    // Nickname rotation across rounds
    final p1NickRound4 = p1.getNickname(players, 4);
    expect(p1NickRound4, isNotEmpty);
  });
}

