import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../state/match_session.dart';
import '../../widgets/primary_button.dart';
import '../score_screen.dart';
import '../team_selection_screen.dart';
import 'edit_rules_screen.dart';
import 'edit_teams_screen.dart';

/// Screen 10. Reached only after invalidateCurrentMatch() was already called
/// from score_screen.dart's AlertDialog. No "Voltar ao jogo" option.
/// EditTeamsScreen and EditRulesScreen both pop() back here on save.
/// The only forward path is the PrimaryButton.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  void _startNewMatch(BuildContext context) {
    final session = context.read<MatchSession>();
    final teams = session.game.teams;

    if (teams.length > 2) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const TeamSelectionScreen()),
        (route) => route.isFirst,
      );
    } else {
      session.startMatch(teamAId: teams[0].id, teamBId: teams[1].id);
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const ScoreScreen()),
        (route) => route.isFirst,
      );
    }
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
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Ajustes', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      const Text(
                        'A partida anterior foi encerrada. Ajuste o que precisar e comece a próxima.',
                        style: TextStyle(color: Colors.black54),
                      ),
                      const SizedBox(height: 20),
                      _SettingsTile(
                        title: 'Mudar times',
                        subtitle: 'nomes e cores dos times',
                        icon: Icons.people_outline,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const EditTeamsScreen()),
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      _SettingsTile(
                        title: 'Mudar regras',
                        subtitle: 'pontos por set e regra do vencedor',
                        icon: Icons.menu,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const EditRulesScreen()),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              PrimaryButton(
                label: game.teams.length > 2 ? 'Selecionar times' : 'Iniciar nova partida',
                onPressed: () => _startNewMatch(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: const Color(0xFFF7F7F7), borderRadius: BorderRadius.circular(14)),
        child: Row(
          children: [
            Icon(icon, color: Colors.black87),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text(subtitle, style: TextStyle(color: Colors.black87.withValues(alpha: 0.7), fontSize: 12)),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.black87.withValues(alpha: 0.4)),
          ],
        ),
      ),
    );
  }
}
