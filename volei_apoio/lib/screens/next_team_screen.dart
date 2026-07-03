import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/match_session.dart';
import '../widgets/primary_button.dart';
import '../widgets/team_list_tile.dart';
import 'score_screen.dart';

/// Screen 7. 3+ teams only. Staying team highlighted in blue.
/// Outgoing team greyed out with game count. Bench teams selectable.
/// Button enabled only once _enteringTeamId is set.
class NextTeamScreen extends StatefulWidget {
  const NextTeamScreen({super.key});

  @override
  State<NextTeamScreen> createState() => _NextTeamScreenState();
}

class _NextTeamScreenState extends State<NextTeamScreen> {
  String? _enteringTeamId;

  @override
  Widget build(BuildContext context) {
    final session = context.watch<MatchSession>();
    final game = session.game;
    final last = game.matchHistory.last;

    final outgoingId = session.determineOutgoingTeamId();
    final stayingId = outgoingId == last.teamAId ? last.teamBId : last.teamAId;

    final outgoing = game.teamById(outgoingId);
    final staying = game.teamById(stayingId);
    final bench = game.teams.where((t) => t.id != stayingId && t.id != outgoingId).toList();

    void onStart() {
      session.startNextMatch(stayingTeamId: stayingId, enteringTeamId: _enteringTeamId!);
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const ScoreScreen()),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Próxima partida', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A6DB5),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('FICA', style: TextStyle(color: Colors.white70, fontSize: 11)),
                        Text(
                          staying.displayName,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                      ],
                    ),
                    const Icon(Icons.check_circle, color: Colors.white),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Text('SAI DA QUADRA', style: TextStyle(fontSize: 12, color: Colors.black38)),
                  const SizedBox(width: 8),
                  Text(
                    outgoing.displayName,
                    style: const TextStyle(color: Colors.black38, fontWeight: FontWeight.w500),
                  ),
                  const Spacer(),
                  Text(
                    'jogou ${outgoing.consecutiveGamesPlayed}x',
                    style: const TextStyle(color: Colors.black26, fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text('ESCOLHA QUEM ENTRA', style: TextStyle(fontSize: 12, color: Colors.black54)),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.separated(
                  itemCount: bench.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, i) {
                    final team = bench[i];
                    return TeamListTile(
                      team: team,
                      color: game.colorOf(team),
                      selected: _enteringTeamId == team.id,
                      onTap: () => setState(() => _enteringTeamId = team.id),
                    );
                  },
                ),
              ),
              PrimaryButton(
                label: 'Começar Partida',
                onPressed: _enteringTeamId != null ? onStart : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
