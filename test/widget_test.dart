import 'package:flutter_test/flutter_test.dart';
import 'package:okey_defteri/models/game_models.dart';

void main() {
  test('isFinishType identifies all finishing score types correctly', () {
    expect(ScoreType.normalBitti.isFinishType, isTrue);
    expect(ScoreType.eldenBitti.isFinishType, isTrue);
    expect(ScoreType.okeyAtarakBitti.isFinishType, isTrue);
    expect(ScoreType.okeyAtarakEldenBitti.isFinishType, isTrue);
    expect(ScoreType.americanoKazandi.isFinishType, isTrue);

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
}
