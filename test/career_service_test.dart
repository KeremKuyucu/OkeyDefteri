import 'package:flutter_test/flutter_test.dart';
import 'package:okey_defteri/models/game_models.dart';
import 'package:okey_defteri/services/career_service.dart';

void main() {
  group('CareerService', () {
    test('buildProfilesFromGames returns empty list when no games provided', () {
      final profiles = CareerService.buildProfilesFromGames([]);
      expect(profiles, isEmpty);
    });

    test('buildProfilesFromGames accurately calculates stats and duo synergy', () {
      // Create mock game 1: Team 1 (Ali & Veli) vs Team 2 (Ayse & Fatma)
      // Ali and Veli have lower score -> Team 1 wins
      final p1 = Player(id: 'p1', name: 'Ali', seatIndex: 0);
      final p2 = Player(id: 'p2', name: 'Veli', seatIndex: 2);
      final p3 = Player(id: 'p3', name: 'Ayse', seatIndex: 1);
      final p4 = Player(id: 'p4', name: 'Fatma', seatIndex: 3);

      // Ali throws an Okey finish (-202)
      p1.scores.add(ScoreEntry(
        id: 's1',
        type: ScoreType.okeyAtarakBitti,
        points: -202,
        timestamp: DateTime.now(),
        roundNumber: 1,
      ));

      // Ayse gets a penalty (+101) and an islek (+101)
      p3.scores.add(ScoreEntry(
        id: 's2',
        type: ScoreType.islekAtti,
        points: 101,
        timestamp: DateTime.now(),
        roundNumber: 1,
      ));
      p3.scores.add(ScoreEntry(
        id: 's3',
        type: ScoreType.yanlisElActi,
        points: 101,
        timestamp: DateTime.now(),
        roundNumber: 1,
      ));

      final game1 = Game(
        id: 'g1',
        createdAt: DateTime.now(),
        isFinished: true,
        team1: Team(id: 't1', name: 'T1', player1: p1, player2: p2),
        team2: Team(id: 't2', name: 'T2', player1: p3, player2: p4),
      );

      // Create mock game 2: Ali & Veli vs Ayse & Fatma again
      // Team 2 wins this time (Ayse finishes with normal finish)
      final p1G2 = Player(id: 'p1', name: 'Ali', seatIndex: 0);
      final p2G2 = Player(id: 'p2', name: 'Veli', seatIndex: 2);
      final p3G2 = Player(id: 'p3', name: 'Ayse', seatIndex: 1);
      final p4G2 = Player(id: 'p4', name: 'Fatma', seatIndex: 3);

      p3G2.scores.add(ScoreEntry(
        id: 's4',
        type: ScoreType.normalBitti,
        points: -101,
        timestamp: DateTime.now(),
        roundNumber: 1,
      ));

      final game2 = Game(
        id: 'g2',
        createdAt: DateTime.now(),
        isFinished: true,
        team1: Team(id: 't1', name: 'T1', player1: p1G2, player2: p2G2),
        team2: Team(id: 't2', name: 'T2', player1: p3G2, player2: p4G2),
      );

      final profiles = CareerService.buildProfilesFromGames([game1, game2]);

      expect(profiles.length, 4);

      final ali = profiles.firstWhere((p) => p.name == 'Ali');
      final veli = profiles.firstWhere((p) => p.name == 'Veli');
      final ayse = profiles.firstWhere((p) => p.name == 'Ayse');

      // Ali played 2 games, won 1 (50% win rate)
      expect(ali.gamesPlayed, 2);
      expect(ali.gamesWon, 1);
      expect(ali.winRate, 50.0);
      expect(ali.totalOkeyFinishes, 1);

      // Ayse played 2 games, won 1, had 2 penalties, 1 islek
      expect(ayse.gamesPlayed, 2);
      expect(ayse.gamesWon, 1);
      expect(ayse.totalPenalties, 2);
      expect(ayse.totalIslekAtti, 1);

      // Duo Synergy check:
      // Ali's partner is Veli (2 games together, 1 win -> 50% win rate)
      expect(ali.topPartner, isNotNull);
      expect(ali.topPartner!.partnerName, 'Veli');
      expect(ali.topPartner!.gamesTogether, 2);
      expect(ali.topPartner!.winsTogether, 1);
      expect(ali.topPartner!.winRate, 50.0);

      // Veli's partner is Ali
      expect(veli.topPartner!.partnerName, 'Ali');
      expect(veli.topPartner!.gamesTogether, 2);
      expect(veli.topPartner!.winsTogether, 1);
    });
  });
}
