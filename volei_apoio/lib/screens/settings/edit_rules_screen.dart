import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/game.dart';
import '../../state/match_session.dart';
import '../../widgets/primary_button.dart';

/// Screen 12. Like RulesScreen but without the team-count selector.
/// Team count is managed in EditTeamsScreen instead.
/// _onSave commits and pops back to SettingsScreen.
class EditRulesScreen extends StatefulWidget {
  const EditRulesScreen({super.key});

  @override
  State<EditRulesScreen> createState() => _EditRulesScreenState();
}

class _EditRulesScreenState extends State<EditRulesScreen> {
  late int _ptsPerSet;
  late RotationRule _rotationRule;

  @override
  void initState() {
    super.initState();
    final game = context.read<MatchSession>().game;
    _ptsPerSet = game.ptsSet;
    _rotationRule = game.rotationRule;
  }

  void _onSave() {
    context.read<MatchSession>().setRules(ptsSet: _ptsPerSet, rotationRule: _rotationRule);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final showRotationRule = context.watch<MatchSession>().game.teams.length > 2;

    return Scaffold(
      appBar: AppBar(title: const Text('REGRAS')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SectionCard(
                      title: 'Pontos por set',
                      child: Row(
                        children: [15, 25].map((value) {
                          final selected = value == _ptsPerSet;
                          return Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              child: InkWell(
                                onTap: () => setState(() => _ptsPerSet = value),
                                borderRadius: BorderRadius.circular(10),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: selected ? const Color(0xFF1A6DB5) : const Color(0xFFEFF1F4),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    '$value',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: selected ? Colors.white : Colors.black45,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    if (showRotationRule) ...[
                      const SizedBox(height: 16),
                      _SectionCard(
                        title: 'Regra do vencedor',
                        badge: '3+ TIMES',
                        child: RadioGroup<RotationRule>(
                          groupValue: _rotationRule,
                          onChanged: (v) => setState(() => _rotationRule = v!),
                          child: Column(
                            children: const [
                              RadioListTile<RotationRule>(
                                value: RotationRule.winnerStays,
                                title: Text('Vencedor continua'),
                              ),
                              RadioListTile<RotationRule>(
                                value: RotationRule.twoMatchesOut,
                                title: Text('Quem jogou 2x sai'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(color: const Color(0xFFEFF1F4), borderRadius: BorderRadius.circular(12)),
                      child: const Text(
                        'O número de times não muda durante um jogo em andamento.',
                        style: TextStyle(color: Colors.black54, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            PrimaryButton(label: 'Salvar', onPressed: _onSave),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final String? badge;
  final Widget child;

  const _SectionCard({required this.title, required this.child, this.badge});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Color(0x14000000), blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              if (badge != null) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE3EEF8),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(badge!, style: const TextStyle(fontSize: 10, color: Color(0xFF1A6DB5))),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}
