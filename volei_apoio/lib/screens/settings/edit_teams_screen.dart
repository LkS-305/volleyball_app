import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../models/team.dart';
import '../../state/match_session.dart';
import '../../theme/team_colors.dart';
import '../../widgets/primary_button.dart';

/// Screen 11. invalidateCurrentMatch() already ran before this screen opened.
/// _onSave commits and pops back to SettingsScreen — does NOT navigate to match.
/// captainName may be nullable in some local versions — always use ?? '' for TextEditingController.
class EditTeamsScreen extends StatefulWidget {
  const EditTeamsScreen({super.key});

  @override
  State<EditTeamsScreen> createState() => _EditTeamsScreenState();
}

class _EditTeamsScreenState extends State<EditTeamsScreen> {
  late List<Team> _teams;
  late List<TextEditingController> _controllers;

  @override
  void initState() {
    super.initState();
    _teams = List.of(context.read<MatchSession>().game.teams);
    _controllers = _teams.map((t) => TextEditingController(text: t.captainName ?? '')).toList();
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _remove(int index) {
    if (_teams.length <= 2) return;
    setState(() {
      _teams.removeAt(index);
      _controllers.removeAt(index).dispose();
    });
  }

  void _add() {
    if (_teams.length >= teamColors.length) return;
    setState(() {
      _teams.add(Team(id: const Uuid().v4(), captainName: ''));
      _controllers.add(TextEditingController());
    });
  }

  void _onSave() {
    final updated = List.generate(_teams.length, (i) {
      return _teams[i].copyWith(captainName: _controllers[i].text.trim());
    });
    context.read<MatchSession>().setTeams(updated);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('TIMES')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Expanded(
              child: ListView.separated(
                itemCount: _teams.length,
                separatorBuilder: (_, __) => const SizedBox(height: 16),
                itemBuilder: (context, i) => _EditableTeamField(
                  index: i,
                  controller: _controllers[i],
                  color: teamColors[i % teamColors.length],
                  onRemove: _teams.length > 2 ? () => _remove(i) : null,
                ),
              ),
            ),
            OutlinedButton.icon(
              onPressed: _add,
              icon: const Icon(Icons.add),
              label: const Text('Adicionar time'),
            ),
            const SizedBox(height: 16),
            PrimaryButton(label: 'Salvar', onPressed: _onSave),
          ],
        ),
      ),
    );
  }
}

class _EditableTeamField extends StatelessWidget {
  final int index;
  final TextEditingController controller;
  final Color color;
  final VoidCallback? onRemove;

  const _EditableTeamField({
    required this.index,
    required this.controller,
    required this.color,
    required this.onRemove,
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
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
            if (onRemove != null) IconButton(icon: const Icon(Icons.close), onPressed: onRemove),
          ],
        ),
      ],
    );
  }
}
