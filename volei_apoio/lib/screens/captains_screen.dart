import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../models/team.dart';
import '../state/match_session.dart';
import '../theme/team_colors.dart';
import '../widgets/primary_button.dart';
import 'score_screen.dart';
import 'team_selection_screen.dart';

/// Screen 3. numTeams comes from RulesScreen local state.
/// Nothing committed to MatchSession until "Continuar" tapped.
class CaptainsScreen extends StatefulWidget {
  final int numTeams;

  const CaptainsScreen({super.key, required this.numTeams});

  @override
  State<CaptainsScreen> createState() => _CaptainsScreenState();
}

class _CaptainsScreenState extends State<CaptainsScreen> {
  late final List<TextEditingController> _controllers;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(widget.numTeams, (_) => TextEditingController());
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  bool get _allFilled => _controllers.every((c) => c.text.trim().isNotEmpty);

  void _onContinue() {
    final teams = List.generate(widget.numTeams, (i) {
      return Team(id: const Uuid().v4(), captainName: _controllers[i].text.trim());
    });

    final session = context.read<MatchSession>();
    session.setTeams(teams);

    if (widget.numTeams > 2) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const TeamSelectionScreen()),
      );
    } else {
      session.startMatch(teamAId: teams[0].id, teamBId: teams[1].id);
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const ScoreScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Capitães', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              Text('${widget.numTeams} times', style: const TextStyle(color: Colors.black54)),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.separated(
                  itemCount: widget.numTeams,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (context, i) => _CaptainField(
                    index: i,
                    controller: _controllers[i],
                    color: teamColors[i % teamColors.length],
                    onChanged: () => setState(() {}),
                  ),
                ),
              ),
              PrimaryButton(label: 'Continuar', onPressed: _allFilled ? _onContinue : null),
            ],
          ),
        ),
      ),
    );
  }
}

class _CaptainField extends StatelessWidget {
  final int index;
  final TextEditingController controller;
  final Color color;
  final VoidCallback onChanged;

  const _CaptainField({
    required this.index,
    required this.controller,
    required this.color,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
            const SizedBox(width: 8),
            Text('TIME ${index + 1}', style: const TextStyle(fontSize: 12, color: Colors.black54)),
          ],
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          onChanged: (_) => onChanged(),
          decoration: InputDecoration(
            hintText: 'Nome do capitão',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
      ],
    );
  }
}
