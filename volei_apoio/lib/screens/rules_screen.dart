import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/game.dart';
import '../state/match_session.dart';
import '../widgets/primary_button.dart';
import 'captains_screen.dart';

/// Screen 2. All choices are local state — committed to MatchSession only on "Continuar".
/// _rotationRule must NOT be final — it is reassigned by setState via RadioGroup.onChanged.
class RulesScreen extends StatefulWidget {
  const RulesScreen({super.key});

  @override
  State<RulesScreen> createState() => _RulesScreenState();
}

class _RulesScreenState extends State<RulesScreen> {
  int _numTeams = 2;
  int _ptsPerSet = 25;
  RotationRule _rotationRule = RotationRule.winnerStays;

  void _onContinue() {
    context.read<MatchSession>().setRules(ptsSet: _ptsPerSet, rotationRule: _rotationRule);
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => CaptainsScreen(numTeams: _numTeams)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final showRotationRule = _numTeams > 2;

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
                      title: 'Número de times',
                      child: _SegmentedRow(
                        options: const [2, 3, 4, 5],
                        selected: _numTeams,
                        onSelected: (v) => setState(() => _numTeams = v),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _SectionCard(
                      title: 'Pontos por set',
                      child: _SegmentedRow(
                        options: const [15, 25],
                        selected: _ptsPerSet,
                        onSelected: (v) => setState(() => _ptsPerSet = v),
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
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            PrimaryButton(label: 'Continuar', onPressed: _onContinue),
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

class _SegmentedRow extends StatelessWidget {
  final List<int> options;
  final int selected;
  final ValueChanged<int> onSelected;

  const _SegmentedRow({required this.options, required this.selected, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: options.map((value) {
        final isSelected = value == selected;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: InkWell(
              onTap: () => onSelected(value),
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF1A6DB5) : const Color(0xFFEFF1F4),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$value',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.white : Colors.black45,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
