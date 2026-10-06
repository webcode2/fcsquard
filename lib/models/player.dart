import 'package:hive/hive.dart';

// Generated Hive adapter — re-run `dart run build_runner build` after model changes.
part 'player.g.dart';

/// Tactical positions a player can occupy on the field.
///
/// The first position in a player's [Player.positions] list is considered
/// their *primary* position and is highlighted in the UI.
@HiveType(typeId: 0)
enum PlayerPosition {
  @HiveField(0)
  def, // Defender

  @HiveField(1)
  mid, // Midfielder

  @HiveField(2)
  fwd, // Forward
}

// PlayerTeam enum removed in favor of flexible String team names.

/// Core domain model for a squad member.
///
/// Persisted locally via Hive (typeId: 2). Each instance is identified by a
/// UUID [id] so deletions and status updates can be performed safely.
///
/// **Important**: all string display values (name, country, grade) are stored
/// in UPPER_CASE to match the app's design system — normalise on write, not
/// on read.
@HiveType(typeId: 2)
class Player extends HiveObject {
  /// Unique identifier — generated with the `uuid` package on creation.
  @HiveField(0)
  final String id;

  /// Full display name, stored in uppercase (e.g. "MARCUS THORNE").
  @HiveField(1)
  final String name;

  /// Country / nationality label (e.g. "UNITED KINGDOM").
  @HiveField(2)
  final String country;

  /// Informal role or skill tier displayed on the card (e.g. "ELITE GRADE").
  @HiveField(3)
  final String grade;

  /// Ordered list of positions; index 0 is the primary position.
  @HiveField(4)
  final List<PlayerPosition> positions;

  /// Optional avatar asset / network URL for future profile images.
  @HiveField(6)
  final String? avatarUrl;

  /// Player's jersey number (e.g. 10).
  @HiveField(7)
  final int? number;

  /// Player's overall rating (e.g. 88).
  @HiveField(8)
  final int? ovr;

  /// Manually assigned team name for the next match (e.g. "TEAM 1").
  @HiveField(9)
  final String team;

  /// Number of goals scored.
  @HiveField(10)
  final int goals;

  /// Number of assists provided.
  @HiveField(11)
  final int assists;

  /// Number of clean sheets.
  @HiveField(12, defaultValue: 0)
  final int cleanSheets;

  Player({
    required this.id,
    required this.name,
    this.country = '',
    this.grade = '',
    required this.positions,
    this.avatarUrl,
    int? number = 0,
    int? ovr = 50,
    this.team = '',
    this.goals = 0,
    this.assists = 0,
    this.cleanSheets = 0,
  }) : number = number ?? 0,
       ovr = ovr ?? 50;

  /// Returns a new [Player] with the given fields replaced.
  ///
  /// Follows the immutable-data pattern: mutate state in the provider but
  /// never modify an existing [Player] instance in place.
  Player copyWith({
    String? id,
    String? name,
    String? country,
    String? grade,
    List<PlayerPosition>? positions,
    String? avatarUrl,
    int? number,
    int? ovr,
    String? team,
    int? goals,
    int? assists,
    int? cleanSheets,
  }) {
    return Player(
      id: id ?? this.id,
      name: name ?? this.name,
      country: country ?? this.country,
      grade: grade ?? this.grade,
      positions: positions ?? this.positions,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      number: number ?? this.number,
      ovr: ovr ?? this.ovr,
      team: team ?? this.team,
      goals: goals ?? this.goals,
      assists: assists ?? this.assists,
      cleanSheets: cleanSheets ?? this.cleanSheets,
    );
  }
}
