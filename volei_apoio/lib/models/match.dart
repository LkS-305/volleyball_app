/// Shared shape for a single set between two teams. Never instantiated
/// directly — see [ActiveMatch] (in progress) and [CompletedMatch] (done).
abstract class Match {
  final String teamAId;
  final String teamBId;
  final int ptsA;
  final int ptsB;

  const Match({
    required this.teamAId,
    required this.teamBId,
    required this.ptsA,
    required this.ptsB,
  });
}

/// The set currently being played. Lives at Game.currentMatch; null means
/// no set is in progress right now.
class ActiveMatch extends Match {
  final String servingTeamId;

  const ActiveMatch({
    required super.teamAId,
    required super.teamBId,
    required super.ptsA,
    required super.ptsB,
    required this.servingTeamId,
  });

  factory ActiveMatch.start({
    required String teamAId,
    required String teamBId,
  }) {
    return ActiveMatch(
      teamAId: teamAId,
      teamBId: teamBId,
      ptsA: 0,
      ptsB: 0,
      servingTeamId: teamAId,
    );
  }

  ActiveMatch copyWith({int? ptsA, int? ptsB, String? servingTeamId}) {
    return ActiveMatch(
      teamAId: teamAId,
      teamBId: teamBId,
      ptsA: ptsA ?? this.ptsA,
      ptsB: ptsB ?? this.ptsB,
      servingTeamId: servingTeamId ?? this.servingTeamId,
    );
  }

  CompletedMatch toCompleted({required String id, required String winnerId}) {
    return CompletedMatch(
      id: id,
      teamAId: teamAId,
      teamBId: teamBId,
      ptsA: ptsA,
      ptsB: ptsB,
      winnerId: winnerId,
      playedAt: DateTime.now(),
    );
  }
}

/// An immutable record of a finished set.
class CompletedMatch extends Match {
  final String id;
  final String winnerId;
  final DateTime playedAt;

  const CompletedMatch({
    required super.teamAId,
    required super.teamBId,
    required super.ptsA,
    required super.ptsB,
    required this.id,
    required this.winnerId,
    required this.playedAt,
  });
}
