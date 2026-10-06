import 'package:hive/hive.dart';
import 'player.dart';

part 'match_history.g.dart';

@HiveType(typeId: 4)
class MatchHistory extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final DateTime date;

  @HiveField(2)
  final List<List<Player>> teams;

  @HiveField(3)
  final Map<String, int> playerGoals;

  @HiveField(4)
  final Map<String, int> playerAssists;

  @HiveField(5)
  final List<String> teamNames;

  @HiveField(6)
  final List<int> teamColors;

  MatchHistory({
    required this.id,
    required this.date,
    required this.teams,
    required this.teamNames,
    required this.teamColors,
    this.playerGoals = const {},
    this.playerAssists = const {},
  });

  MatchHistory copyWith({
    String? id,
    DateTime? date,
    List<List<Player>>? teams,
    List<String>? teamNames,
    List<int>? teamColors,
    Map<String, int>? playerGoals,
    Map<String, int>? playerAssists,
  }) {
    return MatchHistory(
      id: id ?? this.id,
      date: date ?? this.date,
      teams: teams ?? this.teams,
      teamNames: teamNames ?? this.teamNames,
      teamColors: teamColors ?? this.teamColors,
      playerGoals: playerGoals ?? this.playerGoals,
      playerAssists: playerAssists ?? this.playerAssists,
    );
  }
}
