import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'screens/intro_screen.dart';
import 'state/match_session.dart';

void main() {
  runApp(const VoleiApoioApp());
}

class VoleiApoioApp extends StatelessWidget {
  const VoleiApoioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MatchSession(),
      child: MaterialApp(
        title: 'Vôlei Apoio',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorSchemeSeed: const Color(0xFF1A6DB5),
        ),
        home: const IntroScreen(),
      ),
    );
  }
}
