/// A team in the session. Color is not stored here — it's derived from
/// the team's position in [Game.teams] via the fixed palette in
/// theme/team_colors.dart.
class Team {
  final String id;
  final String captainName;
  final int consecutiveGamesPlayed; // for the "2 games out" rotation rule
  final int currentWinStreak; // resets to 0 on a loss
  final int numWins;

  const Team({
    required this.id,
    required this.captainName,
    this.consecutiveGamesPlayed = 0,
    this.currentWinStreak = 0,
    this.numWins = 0,
  });

  String get displayName => 'Time de $captainName';

  Team copyWith({
    String? captainName,
    int? consecutiveGamesPlayed,
    int? currentWinStreak,
    int? numWins,
  }) {
    return Team(
      id: id,
      captainName: captainName ?? this.captainName,
      consecutiveGamesPlayed:
          consecutiveGamesPlayed ?? this.consecutiveGamesPlayed,
      currentWinStreak: currentWinStreak ?? this.currentWinStreak,
      numWins: numWins ?? this.numWins,
    );
  }
}
