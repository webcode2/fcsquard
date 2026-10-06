import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/player.dart';
import '../theme/app_colors.dart';
import '../providers/result_provider.dart';

class TeamResultDialog extends ConsumerWidget {
  const TeamResultDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final result = ref.watch(latestResultProvider);
    if (result == null) return const SizedBox.shrink();

    return Dialog(
      backgroundColor: AppColors.backgroundDark,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'GENERATED TEAMS',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: AppColors.primaryYellow,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: result.teams.length,
                separatorBuilder: (context, index) => const Divider(
                  color: AppColors.cardColor,
                  thickness: 1,
                  height: 32,
                ),
                itemBuilder: (context, index) {
                  return _buildTeamList(
                    ref,
                    result.teamNames[index],
                    result.teams[index],
                    index,
                    result.teams.length,
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryYellow,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'DISMISS',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTeamList(
    WidgetRef ref,
    String name,
    List<Player> players,
    int teamIndex,
    int totalTeams,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          name,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: AppColors.textGray,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 12),
        ...players.map(
          (p) => Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        p.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        p.positions.first.name.toUpperCase(),
                        style: const TextStyle(
                          color: AppColors.primaryYellowDark,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Tooltip(
                        message: 'SWITCH TEAM',
                        child: GestureDetector(
                          onTap: () {
                            // Simple logic: switch to the next team
                            final nextIndex = (teamIndex + 1) % totalTeams;
                            ref
                                .read(latestResultProvider.notifier)
                                .switchPlayer(p, teamIndex, nextIndex);
                          },
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.swap_horiz,
                                color: AppColors.primaryYellow,
                                size: 14,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'SWITCH',
                                style: TextStyle(
                                  color: AppColors.primaryYellow,
                                  fontSize: 8,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
