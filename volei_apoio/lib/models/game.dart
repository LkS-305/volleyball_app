import 'package:flutter/material.dart';

import 'match.dart';
import 'team.dart';
import '../theme/team_colors.dart';

enum RotationRule { winnerStays, twoMatchesOut }

class Game {
  final List<Team> teams;
  final int ptsSet;
  final RotationRule rotationRule;
  final ActiveMatch? currentMatch;
  final List<CompletedMatch> matchHistory;

  const Game({
    required this.teams,
    required this.ptsSet,
    required this.rotationRule,
    this.currentMatch,
    this.matchHistory = const [],
  });

  factory Game.initial() => const Game(
        teams: [],
        ptsSet: 25,
        rotationRule: RotationRule.winnerStays,
      );

  bool get hasTwoTeams => teams.length == 2;

  Team teamById(String id) => teams.firstWhere((t) => t.id == id);

  Color colorOf(Team team) {
    final index = teams.indexWhere((t) => t.id == team.id);
    return teamColors[index % teamColors.length];
  }

  int setsWonBy(String teamId) =>
      matchHistory.where((m) => m.winnerId == teamId).length;

  List<Team> get benchTeams {
    final cm = currentMatch;
    if (cm == null) return teams;
    return teams.where((t) => t.id != cm.teamAId && t.id != cm.teamBId).toList();
  }

  /// Returns null if no matches played yet.
  /// Uses per-team streak counters — only the LOSER resets to 0,
  /// teams that sat out keep their streak intact.
  /// This correctly handles the twoMatchesOut rotation rule.
  ({String teamId, int streak})? get longestWinStreak {
    final streaks = <String, int>{};
    String? bestTeamId;
    var best = 0;

    for (final m in matchHistory) {
      final loserId = m.winnerId == m.teamAId ? m.teamBId : m.teamAId;
      final winnerStreak = (streaks[m.winnerId] ?? 0) + 1;
      streaks[m.winnerId] = winnerStreak;
      streaks[loserId] = 0;
      if (winnerStreak > best) {
        best = winnerStreak;
        bestTeamId = m.winnerId;
      }
    }

    if (bestTeamId == null) return null;
    return (teamId: bestTeamId, streak: best);
  }

  Game copyWith({
    List<Team>? teams,
    int? ptsSet,
    RotationRule? rotationRule,
    ActiveMatch? currentMatch,
    bool clearCurrentMatch = false,
    List<CompletedMatch>? matchHistory,
  }) {
    return Game(
      teams: teams ?? this.teams,
      ptsSet: ptsSet ?? this.ptsSet,
      rotationRule: rotationRule ?? this.rotationRule,
      currentMatch:
          clearCurrentMatch ? null : (currentMatch ?? this.currentMatch),
      matchHistory: matchHistory ?? this.matchHistory,
    );
  }
}
