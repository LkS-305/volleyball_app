import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../screens/captains_screen.dart';
import '../screens/stats_screen.dart';
import '../screens/team_selection_screen.dart';
import '../state/match_session.dart';

/// Screen 9. Bottom sheet triggered by the X button on ScoreScreen.
/// "Voltar ao placar" dismisses with no state change.
/// The other two options call invalidateCurrentMatch() before navigating.
Future<void> showEndMatchSheet(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => const _EndMatchSheetContent(),
  );
}

class _EndMatchSheetContent extends StatelessWidget {
  const _EndMatchSheetContent();

  @override
  Widget build(BuildContext context) {
    final session = context.watch<MatchSession>();
    final game = session.game;
    final cm = game.currentMatch;
    final teamA = cm != null ? game.teamById(cm.teamAId) : null;
    final teamB = cm != null ? game.teamById(cm.teamBId) : null;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Encerrar a partida atual?',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          if (cm != null && teamA != null && teamB != null)
            Text(
              '${teamA.captainName} ${cm.ptsA} — ${cm.ptsB} ${teamB.captainName}. '
              'O que você quer fazer?',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.black54),
            ),
          const SizedBox(height: 24),
          _OptionTile(
            icon: Icons.refresh,
            title: 'Trocar os times',
            subtitle: 'volta para escolher quem joga',
            onTap: () {
              session.invalidateCurrentMatch();
              Navigator.of(context).pop();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (_) => game.hasTwoTeams
                      ? CaptainsScreen(numTeams: game.teams.length)
                      : const TeamSelectionScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          _OptionTile(
            icon: Icons.close,
            title: 'Encerrar jogo',
            subtitle: 'ver estatísticas do dia',
            highlighted: true,
            onTap: () {
              session.invalidateCurrentMatch();
              Navigator.of(context).pop();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const StatsScreen()),
              );
            },
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Voltar ao placar'),
          ),
        ],
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool highlighted;
  final VoidCallback onTap;

  const _OptionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.highlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    final bg = highlighted ? const Color(0xFF1A6DB5) : const Color(0xFFF2F2F2);
    final fg = highlighted ? Colors.white : Colors.black87;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(14)),
        child: Row(
          children: [
            Icon(icon, color: fg),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(color: fg, fontWeight: FontWeight.bold)),
                  Text(subtitle, style: TextStyle(color: fg.withValues(alpha: 0.7), fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
