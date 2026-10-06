import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../models/player.dart';
import '../theme/app_colors.dart';

/// A dual-mode card that displays a [Player] in either Vault or Match-Day context.
///
/// **Vault mode** (`isMatchDay = false`):
/// - Shows avatar placeholder, name, country/grade, and position chips.
/// - Wrapped in a [Slidable] — swipe **right** to delete, swipe **left** to edit.
/// - [onEdit] and [onDelete] callbacks should call the relevant [RosterNotifier]
///   method from the parent.
///
/// **Match-Day context**:
/// - Displays large jersey numbers and bold names.
/// - Used for both active squad management and historical results.
///
/// **Design contract**: this widget is purely presentational — no provider
/// access allowed here. All state mutations are delegated via callbacks.
class PlayerCard extends StatelessWidget {
  final Player player;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final Color? accentColor;

  const PlayerCard({
    super.key,
    required this.player,
    this.onEdit,
    this.onDelete,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardColorLight,
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(8),
          bottomRight: Radius.circular(8),
          topLeft: Radius.circular(4),
          bottomLeft: Radius.circular(4),
        ),
        border: Border(
          left: BorderSide(color: accentColor ?? Colors.transparent, width: 4),
        ),
      ),
      child: Row(
        children: [
          // Jersey Number (Leading)
          Text(
            '${player.number ?? 0}',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: AppColors.primaryYellow,
            ),
          ),
          const SizedBox(width: 16),
          // Name & Grade (Middle)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  player.name.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 2),
                if (player.grade.isNotEmpty) ...[
                  Text(
                    player.grade.toUpperCase(),
                    style: const TextStyle(
                      color: AppColors.textGray,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ],
            ),
          ),
          // Actions (Trailing)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: onEdit,
                icon: const Icon(
                  Icons.edit_outlined,
                  color: AppColors.textGray,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: onDelete,
                icon: const Icon(
                  Icons.delete_outline,
                  color: Colors.redAccent,
                  size: 18,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
