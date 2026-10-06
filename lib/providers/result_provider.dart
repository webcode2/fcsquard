import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/team_balancer.dart';
import '../models/player.dart';

class LatestResultNotifier extends Notifier<TeamResult?> {
  @override
  TeamResult? build() => null;

  set update(TeamResult? value) => state = value;

  void updateTeams(List<List<Player>> teams) {
    state = TeamResult(teams: teams);
  }

  void switchPlayer(Player player, int fromTeamIndex, int toTeamIndex) {
    if (state == null) return;
    final current = state!;
    if (fromTeamIndex >= current.teams.length ||
        toTeamIndex >= current.teams.length) {
      return;
    }

    final updatedTeams = List<List<Player>>.from(
      current.teams.map((t) => List<Player>.from(t)),
    );
    updatedTeams[fromTeamIndex].removeWhere((p) => p.id == player.id);
    updatedTeams[toTeamIndex].add(player);

    state = current.copyWith(teams: updatedTeams);
  }

  void clear() => state = null;
}

final latestResultProvider =
    NotifierProvider<LatestResultNotifier, TeamResult?>(
      LatestResultNotifier.new,
    );
