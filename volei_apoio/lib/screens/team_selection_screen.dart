import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/match_session.dart';
import '../widgets/primary_button.dart';
import '../widgets/team_list_tile.dart';
import 'score_screen.dart';

/// Screen 4. 3+ teams only. Picks exactly 2 teams for the first match.
/// Button enabled only when _selectedIds.length == 2.
class TeamSelectionScreen extends StatefulWidget {
  const TeamSelectionScreen({super.key});

  @override
  State<TeamSelectionScreen> createState() => _TeamSelectionScreenState();
}

class _TeamSelectionScreenState extends State<TeamSelectionScreen> {
  final Set<String> _selectedIds = {};

  void _toggle(String teamId) {
    setState(() {
      if (_selectedIds.contains(teamId)) {
        _selectedIds.remove(teamId);
      } else if (_selectedIds.length < 2) {
        _selectedIds.add(teamId);
      }
    });
  }

  void _onStart() {
    final ids = _selectedIds.toList();
    context.read<MatchSession>().startMatch(teamAId: ids[0], teamBId: ids[1]);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const ScoreScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final game = context.watch<MatchSession>().game;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Selecione 2', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                  Text(
                    '${_selectedIds.length}/2',
                    style: const TextStyle(color: Color(0xFF1A6DB5), fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.separated(
                  itemCount: game.teams.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, i) {
                    final team = game.teams[i];
                    return TeamListTile(
                      team: team,
                      color: game.colorOf(team),
                      selected: _selectedIds.contains(team.id),
                      onTap: () => _toggle(team.id),
                    );
                  },
                ),
              ),
              PrimaryButton(
                label: 'Iniciar Partida',
                onPressed: _selectedIds.length == 2 ? _onStart : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
