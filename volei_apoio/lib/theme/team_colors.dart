import 'package:flutter/material.dart';

/// Fixed palette: team 1 is always red, team 2 always blue, and so on —
/// resolved by a team's position in [Game.teams], never stored per-team.
const List<Color> teamColors = [
  Color(0xFFE53935), // team 1 · red
  Color(0xFF1E88E5), // team 2 · blue
  Color(0xFF43A047), // team 3 · green
  Color(0xFFF9A825), // team 4 · yellow (slightly deepened for contrast on white)
  Color(0xFF8E24AA), // team 5 · purple
];
