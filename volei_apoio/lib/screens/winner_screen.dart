import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/match_session.dart';
import '../widgets/primary_button.dart';
import 'next_team_screen.dart';
import 'score_screen.dart';
import 'stats_screen.dart';

/// Screen 6. Reads game.matchHistory.last — currentMatch is already null
/// by this point, cleared by _endCurrentMatch inside addPoint.
/// CRITICAL: onContinue must branch on game.hasTwoTeams.
/// For 3+ teams it pushes NextTeamScreen, NOT ScoreScreen directly.
/// Going to ScoreScreen without startNextMatch leaves currentMatch null.
class WinnerScreen extends StatelessWidget {
  const WinnerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final session = context.read<MatchSession>();
    final game = session.game;
    final last = game.matchHistory.last;
    final winner = game.teamById(last.winnerId);
    final teamA = game.teamById(last.teamAId);
    final teamB = game.teamById(last.teamBId);

    void onContinue() {
      if (game.hasTwoTeams) {
        session.continueSameMatchup();
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const ScoreScreen()),
        );
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const NextTeamScreen()),
        );
      }
    }

    void onEnd() {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const StatsScreen()),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(flex: 2),
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: const Color(0xFF1A6DB5),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 32),
              ),
              const SizedBox(height: 16),
              const Text('FIM DO SET', style: TextStyle(color: Colors.black45, fontSize: 12)),
              const SizedBox(height: 4),
              Text(
                '${winner.displayName} venceu!',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 32),
                decoration: BoxDecoration(
                  color: const Color(0xFFF2F4F7),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _ScoreColumn(label: teamA.captainName.toUpperCase(), points: last.ptsA),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text('—', style: TextStyle(fontSize: 28, color: Colors.black26)),
                    ),
                    _ScoreColumn(label: teamB.captainName.toUpperCase(), points: last.ptsB),
                  ],
                ),
              ),
              const Spacer(flex: 3),
              PrimaryButton(label: 'Continuar jogando', onPressed: onContinue),
              const SizedBox(height: 8),
              TextButton(onPressed: onEnd, child: const Text('Encerrar jogo')),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScoreColumn extends StatelessWidget {
  final String label;
  final int points;

  const _ScoreColumn({required this.label, required this.points});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('$points', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.black45)),
      ],
    );
  }
}
