import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../models/game.dart';
import '../models/match.dart';
import '../models/team.dart';

class MatchSession extends ChangeNotifier {
  Game _game = Game.initial();

  Game get game => _game;

  void setRules({required int ptsSet, required RotationRule rotationRule}) {
    _game = _game.copyWith(ptsSet: ptsSet, rotationRule: rotationRule);
    notifyListeners();
  }

  void setTeams(List<Team> teams) {
    _game = _game.copyWith(teams: teams);
    notifyListeners();
  }

  void startMatch({required String teamAId, required String teamBId}) {
    _game = _game.copyWith(
      currentMatch: ActiveMatch.start(teamAId: teamAId, teamBId: teamBId),
    );
    notifyListeners();
  }

  void continueSameMatchup() {
    final last = _game.matchHistory.last;
    _game = _game.copyWith(
      currentMatch:
          ActiveMatch.start(teamAId: last.teamAId, teamBId: last.teamBId),
    );
    notifyListeners();
  }

  void startNextMatch({
    required String stayingTeamId,
    required String enteringTeamId,
  }) {
    final updatedTeams = _game.teams.map((t) {
      if (t.id == enteringTeamId) return t.copyWith(consecutiveGamesPlayed: 0);
      return t;
    }).toList();

    _game = _game.copyWith(
      teams: updatedTeams,
      currentMatch: ActiveMatch.start(
        teamAId: stayingTeamId,
        teamBId: enteringTeamId,
      ),
    );
    notifyListeners();
  }

  /// Returns true if the point won the set.
  /// Win condition: reach ptsSet with at least a 2-point lead.
  bool addPoint(String teamId) {
    final cm = _game.currentMatch;
    if (cm == null) return false;

    final isTeamA = teamId == cm.teamAId;
    final newPtsA = isTeamA ? cm.ptsA + 1 : cm.ptsA;
    final newPtsB = isTeamA ? cm.ptsB : cm.ptsB + 1;
    final updated = cm.copyWith(
      ptsA: newPtsA,
      ptsB: newPtsB,
      servingTeamId: teamId,
    );

    final leader = newPtsA > newPtsB ? newPtsA : newPtsB;
    final lead = (newPtsA - newPtsB).abs();
    final setWon = leader >= _game.ptsSet && lead >= 2;

    if (setWon) {
      _endCurrentMatch(updated, winnerId: teamId);
    } else {
      _game = _game.copyWith(currentMatch: updated);
    }
    notifyListeners();
    return setWon;
  }

  void removePoint(String teamId) {
    final cm = _game.currentMatch;
    if (cm == null) return;

    final isTeamA = teamId == cm.teamAId;
    final newPtsA = isTeamA ? (cm.ptsA > 0 ? cm.ptsA - 1 : 0) : cm.ptsA;
    final newPtsB = isTeamA ? cm.ptsB : (cm.ptsB > 0 ? cm.ptsB - 1 : 0);

    _game = _game.copyWith(currentMatch: cm.copyWith(ptsA: newPtsA, ptsB: newPtsB));
    notifyListeners();
  }

  void _endCurrentMatch(ActiveMatch finished, {required String winnerId}) {
    final completed =
        finished.toCompleted(id: const Uuid().v4(), winnerId: winnerId);

    final updatedTeams = _game.teams.map((t) {
      if (t.id != finished.teamAId && t.id != finished.teamBId) return t;
      final won = t.id == winnerId;
      return t.copyWith(
        consecutiveGamesPlayed: t.consecutiveGamesPlayed + 1,
        numWins: won ? t.numWins + 1 : t.numWins,
        currentWinStreak: won ? t.currentWinStreak + 1 : 0,
      );
    }).toList();

    _game = _game.copyWith(
      teams: updatedTeams,
      matchHistory: [..._game.matchHistory, completed],
      clearCurrentMatch: true,
    );
  }

  String determineOutgoingTeamId() {
    final last = _game.matchHistory.last;
    final teamA = _game.teamById(last.teamAId);
    final teamB = _game.teamById(last.teamBId);

    if (_game.rotationRule == RotationRule.twoMatchesOut) {
      if (teamA.consecutiveGamesPlayed >= 2) return teamA.id;
      if (teamB.consecutiveGamesPlayed >= 2) return teamB.id;
    }
    return last.winnerId == teamA.id ? teamB.id : teamA.id;
  }

  void invalidateCurrentMatch() {
    _game = _game.copyWith(clearCurrentMatch: true);
    notifyListeners();
  }

  void resetSession() {
    _game = Game.initial();
    notifyListeners();
  }
}
