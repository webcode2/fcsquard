import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../providers/all_time_stats_provider.dart';
import '../theme/app_colors.dart';

class VaultHistoryScreen extends ConsumerWidget {
  const VaultHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(allTimeStatsProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(title: const Text('VAULT RECORDS')),
      body: stats.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Text('Error: $e', style: const TextStyle(color: Colors.red)),
        ),
        data: (players) {
          if (players.isEmpty) return _buildEmptyState();
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: players.length,
            itemBuilder: (context, index) =>
                _buildStatCard(context, ref, players, index),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddPlayerDialog(context, ref),
        backgroundColor: AppColors.primaryYellow,
        child: const Icon(Icons.person_add_alt_1, color: Colors.black),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.query_stats, size: 64, color: Colors.white12),
          SizedBox(height: 16),
          Text(
            'NO STATS RECORDED',
            style: TextStyle(
              color: AppColors.textGray,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Finish matches to see cumulative data.',
            style: TextStyle(color: Colors.white24, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    WidgetRef ref,
    List<PlayerAllTimeStats> players,
    int index,
  ) {
    final player = players[index];
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Slidable(
          key: ValueKey(player.name),
          endActionPane: ActionPane(
            extentRatio: 0.25,
            motion: const ScrollMotion(),
            children: [
              SlidableAction(
                onPressed: (context) async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      backgroundColor: AppColors.backgroundDark,
                      title: const Text(
                        'DELETE PLAYER RECORD?',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      content: Text(
                        'Are you sure you want to delete ${player.name}\'s all-time stats record? This action is irreversible.',
                        style: const TextStyle(
                          color: AppColors.textGray,
                          fontSize: 13,
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: const Text(
                            'CANCEL',
                            style: TextStyle(color: AppColors.textGray),
                          ),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          child: const Text(
                            'DELETE',
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );

                  if (confirm == true) {
                    ref
                        .read(allTimeStatsProvider.notifier)
                        .removePlayerStats(player.name);
                  }
                },
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                icon: Icons.delete,
                label: 'DELETE',
              ),
            ],
          ),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: AppColors.cardColorLight),
            child: Row(
              children: [
                // Rank Number (Leading)
                SizedBox(
                  width: 32,
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: AppColors.primaryYellow,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Name & Stats (Middle)
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
                      Text(
                        '${player.goals} GOALS • ${player.assists} ASSISTS • ${player.cleanSheets} CS',
                        style: const TextStyle(
                          color: AppColors.textGray,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                // Update Button (Trailing)
                GestureDetector(
                  onTap: () => _showUpdateStatsDialog(context, ref, player),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryYellow.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: AppColors.primaryYellow.withValues(alpha: 0.2),
                      ),
                    ),
                    child: const Text(
                      'UPDATE',
                      style: TextStyle(
                        color: AppColors.primaryYellow,
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showUpdateStatsDialog(
    BuildContext context,
    WidgetRef ref,
    PlayerAllTimeStats player,
  ) {
    int goals = player.goals;
    int assists = player.assists;
    int cleanSheets = player.cleanSheets;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          return _StatsEditorDialog(
            name: player.name,
            initialGoals: goals,
            initialAssists: assists,
            initialCleanSheets: cleanSheets,
            onSave: (newGoals, newAssists, newCleanSheets) {
              ref
                  .read(allTimeStatsProvider.notifier)
                  .updateStats(
                    player.name,
                    newGoals,
                    newAssists,
                    newCleanSheets,
                  );
            },
          );
        },
      ),
    );
  }

  void _showAddPlayerDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => _AddPlayerStatsDialog(
        onSave: (name, goals, assists, cleanSheets) {
          ref
              .read(allTimeStatsProvider.notifier)
              .updateStats(name, goals, assists, cleanSheets);
        },
      ),
    );
  }
}

class _StatsEditorDialog extends StatefulWidget {
  final String name;
  final int initialGoals;
  final int initialAssists;
  final int initialCleanSheets;
  final void Function(int goals, int assists, int cleanSheets) onSave;

  const _StatsEditorDialog({
    required this.name,
    required this.initialGoals,
    required this.initialAssists,
    required this.initialCleanSheets,
    required this.onSave,
  });

  @override
  State<_StatsEditorDialog> createState() => _StatsEditorDialogState();
}

class _StatsEditorDialogState extends State<_StatsEditorDialog> {
  late int goals;
  late int assists;
  late int cleanSheets;

  @override
  void initState() {
    super.initState();
    goals = widget.initialGoals;
    assists = widget.initialAssists;
    cleanSheets = widget.initialCleanSheets;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.backgroundLight,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.cardColor, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primaryYellow.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.edit_note_rounded,
                      color: AppColors.primaryYellow,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'UPDATE PLAYER STATS',
                          style: TextStyle(
                            color: AppColors.textGray,
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.2,
                          ),
                        ),
                        Text(
                          widget.name.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const Divider(color: AppColors.cardColor, height: 1),

            // Steppers
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  _StatStepper(
                    label: 'GOALS',
                    value: goals,
                    icon: Icons.sports_soccer,
                    color: AppColors.primaryYellow,
                    onChanged: (v) => setState(() => goals = v),
                  ),
                  const SizedBox(height: 12),
                  _StatStepper(
                    label: 'ASSISTS',
                    value: assists,
                    icon: Icons.handshake_rounded,
                    color: const Color(0xFF1E88E5),
                    onChanged: (v) => setState(() => assists = v),
                  ),
                  const SizedBox(height: 12),
                  _StatStepper(
                    label: 'CLEAN SHEETS',
                    value: cleanSheets,
                    icon: Icons.shield_rounded,
                    color: const Color(0xFF43A047),
                    onChanged: (v) => setState(() => cleanSheets = v),
                  ),
                ],
              ),
            ),

            // Actions
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'CANCEL',
                        style: TextStyle(
                          color: AppColors.textGray,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primaryYellow,
                            AppColors.primaryYellowDark,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryYellow.withValues(alpha: 0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          widget.onSave(goals, assists, cleanSheets);
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'SAVE CHANGES',
                          style: TextStyle(
                            color: AppColors.backgroundDark,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddPlayerStatsDialog extends StatefulWidget {
  final void Function(String name, int goals, int assists, int cleanSheets)
  onSave;

  const _AddPlayerStatsDialog({required this.onSave});

  @override
  State<_AddPlayerStatsDialog> createState() => _AddPlayerStatsDialogState();
}

class _AddPlayerStatsDialogState extends State<_AddPlayerStatsDialog> {
  final _nameController = TextEditingController();
  int goals = 0;
  int assists = 0;
  int cleanSheets = 0;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.backgroundLight,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.cardColor, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E88E5).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.person_add_rounded,
                        color: Color(0xFF1E88E5),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'NEW PLAYER ENTRY',
                            style: TextStyle(
                              color: AppColors.textGray,
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.2,
                            ),
                          ),
                          Text(
                            'CAPTURE STATS',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const Divider(color: AppColors.cardColor, height: 1),

              // Form
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.backgroundDark,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.cardColor),
                      ),
                      child: TextField(
                        controller: _nameController,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        decoration: const InputDecoration(
                          hintText: 'PLAYER NAME',
                          hintStyle: TextStyle(
                            color: AppColors.textGray,
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                          ),
                          prefixIcon: Icon(
                            Icons.person_rounded,
                            color: AppColors.textGray,
                            size: 20,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Column(
                      children: [
                        _StatStepper(
                          label: 'GOALS',
                          value: goals,
                          icon: Icons.sports_soccer,
                          color: AppColors.primaryYellow,
                          onChanged: (v) => setState(() => goals = v),
                        ),
                        const SizedBox(height: 12),
                        _StatStepper(
                          label: 'ASSISTS',
                          value: assists,
                          icon: Icons.handshake_rounded,
                          color: const Color(0xFF1E88E5),
                          onChanged: (v) => setState(() => assists = v),
                        ),
                        const SizedBox(height: 12),
                        _StatStepper(
                          label: 'CLEAN SHEETS',
                          value: cleanSheets,
                          icon: Icons.shield_rounded,
                          color: const Color(0xFF43A047),
                          onChanged: (v) => setState(() => cleanSheets = v),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Actions
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'CANCEL',
                          style: TextStyle(
                            color: AppColors.textGray,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.primaryYellow,
                              AppColors.primaryYellowDark,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryYellow.withValues(alpha: 0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: () {
                            if (_nameController.text.isNotEmpty) {
                              widget.onSave(
                                _nameController.text,
                                goals,
                                assists,
                                cleanSheets,
                              );
                              Navigator.pop(context);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'CREATE ENTRY',
                            style: TextStyle(
                              color: AppColors.backgroundDark,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
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
    );
  }
}

class _StatStepper extends StatelessWidget {
  final String label;
  final int value;
  final Color color;
  final IconData icon;
  final ValueChanged<int> onChanged;

  const _StatStepper({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.backgroundDark.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.textGray,
                fontSize: 11,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5,
              ),
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildRoundButton(
                icon: Icons.remove,
                onPressed: value > 0 ? () => onChanged(value - 1) : null,
              ),
              SizedBox(
                width: 40,
                child: Text(
                  '$value'.padLeft(2, '0'),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: color,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
              _buildRoundButton(
                icon: Icons.add,
                onPressed: () => onChanged(value + 1),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRoundButton({
    required IconData icon,
    required VoidCallback? onPressed,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: onPressed == null
                ? Colors.white.withValues(alpha: 0.05)
                : color.withValues(alpha: 0.1),
            border: Border.all(
              color: onPressed == null
                  ? Colors.white.withValues(alpha: 0.1)
                  : color.withValues(alpha: 0.3),
            ),
          ),
          child: Icon(
            icon,
            color: onPressed == null ? Colors.white24 : color,
            size: 14,
          ),
        ),
      ),
    );
  }
}
