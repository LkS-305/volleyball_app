import 'package:flutter/material.dart';

class ScoreCounter extends StatelessWidget {
  final int points;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const ScoreCounter({
    super.key,
    required this.points,
    required this.onIncrement,
    required this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _circleButton(icon: Icons.remove, onTap: onDecrement),
        SizedBox(
          width: 140,
          child: Text(
            '$points',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 88, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
        _circleButton(icon: Icons.add, onTap: onIncrement, filled: true),
      ],
    );
  }

  Widget _circleButton({required IconData icon, required VoidCallback onTap, bool filled = false}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(28),
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: filled ? const Color(0xFF1E88E5) : Colors.transparent,
          border: filled ? null : Border.all(color: Colors.white70, width: 1.5),
        ),
        child: Icon(icon, color: Colors.white, size: 24),
      ),
    );
  }
}
