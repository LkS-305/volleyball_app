import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/match_session.dart';
import '../widgets/end_match_sheet.dart';
import '../widgets/score_counter.dart';
import 'settings/settings_screen.dart';
import 'team_selection_screen.dart';
import 'winner_screen.dart';

/// Screen 5. Main scoreboard.
/// Middle strip uses Stack (not Row+Expanded) so the center widget is
/// truly centered against the full strip width, not just the space left
/// after the two buttons — button widths vary slightly by platform.
class ScoreScreen extends StatelessWidget {
  const ScoreScreen({super.key});

  void _onPoint(BuildContext context, String teamId, int delta) {
    final session = context.read<MatchSession>();
    if (delta > 0) {
      final wonSet = session.addPoint(teamId);
      if (wonSet) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const WinnerScreen()),
        );
      }
    } else {
      session.removePoint(teamId);
    }
  }

  void _onSettingsTap(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Mudar configurações?'),
        content: const Text('Mudar times ou regras encerra a partida atual.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Voltar ao jogo'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<MatchSession>().invalidateCurrentMatch();
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
            child: const Text('Mudar configurações'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final game = context.watch<MatchSession>().game;
    final match = game.currentMatch;

    if (match == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Nenhuma partida em andamento'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const TeamSelectionScreen()),
                    (route) => route.isFirst,
                  );
                },
                child: const Text('Escolher times'),
              ),
            ],
          ),
        ),
      );
    }

    final teamA = game.teamById(match.teamAId);
    final teamB = game.teamById(match.teamBId);

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              color: const Color(0xFF1A6DB5),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _TeamLabel(name: teamA.displayName, isServing: match.servingTeamId == teamA.id),
                    ScoreCounter(
                      points: match.ptsA,
                      onIncrement: () => _onPoint(context, teamA.id, 1),
                      onDecrement: () => _onPoint(context, teamA.id, -1),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(
            height: 64,
            width: double.infinity,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Center(
                  child: game.hasTwoTeams
                      ? _SetCounter(setsA: game.setsWonBy(teamA.id), setsB: game.setsWonBy(teamB.id))
                      : const _VoleiApoioLogo(),
                ),
                Positioned(
                  left: 0,
                  child: IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => showEndMatchSheet(context),
                  ),
                ),
                Positioned(
                  right: 0,
                  child: IconButton(
                    icon: const Icon(Icons.settings_outlined),
                    onPressed: () => _onSettingsTap(context),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              width: double.infinity,
              color: const Color(0xFF0D2240),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ScoreCounter(
                      points: match.ptsB,
                      onIncrement: () => _onPoint(context, teamB.id, 1),
                      onDecrement: () => _onPoint(context, teamB.id, -1),
                    ),
                    _TeamLabel(name: teamB.displayName, isServing: match.servingTeamId == teamB.id),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TeamLabel extends StatelessWidget {
  final String name;
  final bool isServing;

  const _TeamLabel({required this.name, required this.isServing});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isServing) ...[
          const Icon(Icons.circle, color: Colors.white, size: 8),
          const SizedBox(width: 6),
        ],
        Text(name.toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

class _SetCounter extends StatelessWidget {
  final int setsA;
  final int setsB;

  const _SetCounter({required this.setsA, required this.setsB});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('$setsA — $setsB', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const Text('SETS', style: TextStyle(fontSize: 10, color: Colors.black45)),
      ],
    );
  }
}

class _VoleiApoioLogo extends StatelessWidget {
  const _VoleiApoioLogo();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Icon(Icons.sports_volleyball, size: 22, color: Color(0xFF1A6DB5)),
        Text('VÔLEI APOIO', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
