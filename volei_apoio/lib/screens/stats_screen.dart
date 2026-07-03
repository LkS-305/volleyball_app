import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/team.dart';
import '../state/match_session.dart';
import '../widgets/primary_button.dart';
import 'intro_screen.dart';

/// Screen 8. Read-only end-of-session summary.
class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  void _playAgain(BuildContext context) {
    context.read<MatchSession>().resetSession();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const IntroScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final game = context.read<MatchSession>().game;
    final ranked = [...game.teams]..sort((a, b) => b.numWins.compareTo(a.numWins));
    final leader = ranked.first;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('FIM DO JOGO', style: TextStyle(color: Colors.black45, fontSize: 12)),
              const Text('Estatísticas', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A6DB5),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    const CircleAvatar(backgroundColor: Color(0xFFF2A623), child: Text('1º')),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('MAIS VITÓRIAS', style: TextStyle(color: Colors.white70, fontSize: 11)),
                          Text(
                            leader.displayName,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '${leader.numWins}v',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text('CLASSIFICAÇÃO', style: TextStyle(fontSize: 12, color: Colors.black54)),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.separated(
                  itemCount: ranked.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, i) {
                    final team = ranked[i];
                    return _RankRow(position: i + 1, team: team, color: game.colorOf(team));
                  },
                ),
              ),
              Row(
                children: [
                  Expanded(child: _StatBox(value: '${game.matchHistory.length}', label: 'PARTIDAS')),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatBox(
                      value: '${game.longestWinStreak?.streak ?? 0}',
                      label: 'MAIOR SEQUÊNCIA',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              PrimaryButton(label: 'Jogar de novo', onPressed: () => _playAgain(context)),
              const SizedBox(height: 8),
              TextButton(onPressed: () => _playAgain(context), child: const Text('Sair')),
            ],
          ),
        ),
      ),
    );
  }
}

class _RankRow extends StatelessWidget {
  final int position;
  final Team team;
  final Color color;

  const _RankRow({required this.position, required this.team, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(color: const Color(0xFFF7F7F7), borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Text('$position', style: const TextStyle(color: Colors.black38, fontWeight: FontWeight.bold)),
          const SizedBox(width: 12),
          Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 10),
          Expanded(child: Text(team.displayName, style: const TextStyle(fontWeight: FontWeight.w600))),
          Text('${team.numWins}v', style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String value;
  final String label;

  const _StatBox({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFF0D2240), borderRadius: BorderRadius.circular(14)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
          Text(label, style: const TextStyle(color: Colors.white54, fontSize: 10)),
        ],
      ),
    );
  }
}
