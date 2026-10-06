import 'dart:math';
import '../models/player.dart';
import '../theme/app_colors.dart';

class PositionalBalanceError {
  final Map<PlayerPosition, ({int remainder, int perTeam, int total})> issues;
  PositionalBalanceError(this.issues);
}

class TeamBalancer {
  static final _random = Random();

  static List<List<Player>> generateTeams(
    List<Player> players,
    int numberOfTeams, {
    bool allowUnequal = false,
  }) {
    if (players.length < numberOfTeams) {
      throw 'NOT ENOUGH PLAYERS TO FORM $numberOfTeams TEAMS';
    }

    final defPool = players
        .where(
          (p) =>
              p.positions.isNotEmpty && p.positions.first == PlayerPosition.def,
        )
        .toList();
    final midPool = players
        .where(
          (p) =>
              p.positions.isNotEmpty && p.positions.first == PlayerPosition.mid,
        )
        .toList();
    final fwdPool = players
        .where(
          (p) =>
              p.positions.isNotEmpty && p.positions.first == PlayerPosition.fwd,
        )
        .toList();

    final issues =
        <PlayerPosition, ({int remainder, int perTeam, int total})>{};

    void check(PlayerPosition pos, List<Player> pool) {
      final total = pool.length;
      final remainder = total % numberOfTeams;
      final perTeam = total ~/ numberOfTeams;
      if (remainder != 0) {
        issues[pos] = (remainder: remainder, perTeam: perTeam, total: total);
      }
    }

    if (!allowUnequal) {
      check(PlayerPosition.def, defPool);
      check(PlayerPosition.mid, midPool);
      check(PlayerPosition.fwd, fwdPool);

      if (issues.isNotEmpty) throw PositionalBalanceError(issues);
    }

    defPool.shuffle(_random);
    midPool.shuffle(_random);
    fwdPool.shuffle(_random);

    final teams = List.generate(numberOfTeams, (_) => <Player>[]);
    int nextTeamIndex = 0;

    void deal(List<Player> pool) {
      if (pool.isEmpty) return;
      // Round-robin distribution continues across pools to ensure global equality
      for (int i = 0; i < pool.length; i++) {
        teams[nextTeamIndex].add(pool[i]);
        nextTeamIndex = (nextTeamIndex + 1) % numberOfTeams;
      }
    }

    deal(defPool);
    deal(midPool);
    deal(fwdPool);

    return teams;
  }
}

class TeamResult {
  final String? matchId;
  final List<List<Player>> teams;
  final List<String> teamNames;
  final List<int> teamColors;
  final Map<String, int> playerGoals;
  final Map<String, int> playerAssists;

  TeamResult({
    this.matchId,
    required this.teams,
    List<String>? teamNames,
    List<int>? teamColors,
    this.playerGoals = const {},
    this.playerAssists = const {},
  }) : teamNames =
           teamNames ?? List.generate(teams.length, (i) => 'TEAM ${i + 1}'),
       teamColors =
           teamColors ??
           List.generate(
             teams.length,
             (i) => AppColors.getTeamColor(i).toARGB32(),
           );

  TeamResult copyWith({
    String? matchId,
    List<List<Player>>? teams,
    List<String>? teamNames,
    List<int>? teamColors,
    Map<String, int>? playerGoals,
    Map<String, int>? playerAssists,
  }) {
    return TeamResult(
      matchId: matchId ?? this.matchId,
      teams: teams ?? this.teams,
      teamNames: teamNames ?? this.teamNames,
      teamColors: teamColors ?? this.teamColors,
      playerGoals: playerGoals ?? this.playerGoals,
      playerAssists: playerAssists ?? this.playerAssists,
    );
  }
}
