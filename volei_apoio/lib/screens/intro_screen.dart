import 'package:flutter/material.dart';

import '../widgets/primary_button.dart';
import 'rules_screen.dart';

/// Screen 1. Uses LayoutBuilder + SingleChildScrollView + ConstrainedBox +
/// IntrinsicHeight to allow Spacers while preventing bottom overflow.
/// Without IntrinsicHeight the Column has unbounded maxHeight from
/// SingleChildScrollView and Spacer throws a layout exception (blank screen).
class IntroScreen extends StatelessWidget {
  const IntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Column(
                      children: [
                        const Spacer(flex: 3),
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFF3F8),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Center(
                            child: Text('logo', style: TextStyle(color: Colors.black38)),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'VÔLEI\nAPOIO',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, height: 1.1),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Marque os pontos do rachão do bairro. Simples e rápido.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.black54),
                        ),
                        const Spacer(flex: 4),
                        PrimaryButton(
                          label: 'Novo Jogo',
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const RulesScreen()),
                            );
                          },
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Sem cadastro, sem complicação',
                          style: TextStyle(color: Colors.black38, fontSize: 12),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
