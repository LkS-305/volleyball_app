import 'package:flutter/material.dart';
import '../models/team.dart';

/// Colored dot + team name row. Used in screens 4, 7, 11.
class TeamListTile extends StatelessWidget {
  final Team team;
  final Color color;
  final bool selected;
  final VoidCallback? onTap;
  final Widget? trailing;

  const TeamListTile({
    super.key,
    required this.team,
    required this.color,
    this.selected = false,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(
            color: selected ? const Color(0xFF1A6DB5) : const Color(0xFFE0E0E0),
            width: selected ? 1.5 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(team.displayName, style: const TextStyle(fontWeight: FontWeight.w600)),
            ),
            if (trailing != null) trailing!,
            if (selected)
              const Padding(
                padding: EdgeInsets.only(left: 8),
                child: Icon(Icons.check_circle, color: Color(0xFF1A6DB5), size: 20),
              ),
          ],
        ),
      ),
    );
  }
}
