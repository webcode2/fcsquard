import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/player.dart';
import '../models/match_history.dart';
import '../services/team_balancer.dart';
import '../services/review_service.dart';
import '../storage/hive_storage.dart';
import '../theme/app_colors.dart';
import '../providers/roster_provider.dart';
import '../providers/history_provider.dart';
import '../providers/result_provider.dart';
import '../providers/import_provider.dart';
import 'results_screen.dart';

class RoleSelectionScreen extends ConsumerStatefulWidget {
  final List<String> names;
  final int numberOfTeams;

  const RoleSelectionScreen({
    super.key,
    required this.names,
    required this.numberOfTeams,
  });

  @override
  ConsumerState<RoleSelectionScreen> createState() =>
      _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends ConsumerState<RoleSelectionScreen> {
  final Map<int, PlayerPosition> _selections = {};
  final Map<int, String> _teamSelections = {};
  bool _isGenerating = false;

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < widget.names.length; i++) {
      _selections[i] = PlayerPosition.def;
      _teamSelections[i] = '';
    }
  }

  Future<void> _handleGenerate({bool force = false}) async {
    setState(() => _isGenerating = true);
    try {
      // 1. Create the players list with bulk stat lookup
      final currentRoster = ref.read(rosterProvider).value ?? [];
      final Map<String, Player> existingByName = {
        for (final p in currentRoster) p.name.trim().toUpperCase(): p,
      };

      final statsMap = HiveStorage.getBulkStatsForNames(widget.names);
      final List<Player> players = [];
      for (int i = 0; i < widget.names.length; i++) {
        final name = widget.names[i];
        final upperName = name.trim().toUpperCase();
        final historicalStats =
            statsMap[name] ?? (goals: 0, assists: 0, cleanSheets: 0);

        final existing = existingByName[upperName];

        players.add(
          Player(
            id: existing?.id ?? const Uuid().v4(),
            name: name,
            positions: [_selections[i] ?? PlayerPosition.mid],
            team: _teamSelections[i] ?? '',
            goals: historicalStats.goals,
            assists: historicalStats.assists,
          ),
        );
      }

      // 2. Generate Teams
      final teams = TeamBalancer.generateTeams(
        players,
        widget.numberOfTeams,
        allowUnequal: force,
      );
      final List<String> teamNames = List.generate(
        teams.length,
        (i) => 'TEAM ${i + 1}',
      );

      // 3. Assign final team names to players
      final List<Player> updatedRosterBatch = [];
      for (int i = 0; i < teams.length; i++) {
        final teamName = teamNames[i];
        for (final p in teams[i]) {
          updatedRosterBatch.add(p.copyWith(team: teamName));
        }
      }

      // 4. PERSIST FULL SQUAD (Merge Updated Batch with Remaining Roster)
      final batchIds = updatedRosterBatch.map((p) => p.id).toSet();
      final remainingPlayers = currentRoster
          .where((p) => !batchIds.contains(p.id))
          .toList();

      final fullSquad = [...remainingPlayers, ...updatedRosterBatch];
      await ref.read(rosterProvider.notifier).saveRoster(fullSquad);

      final teamColors = List.generate(
        teams.length,
        (i) => AppColors.getTeamColor(i).toARGB32(),
      );

      // 5. AUTO-SAVE TO VAULT (Immediate History Record)
      final history = MatchHistory(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        date: DateTime.now(),
        teams: teams,
        teamNames: teamNames,
        teamColors: teamColors,
        playerGoals: const {},
        playerAssists: const {},
      );
      await ref.read(historyProvider.notifier).addMatch(history);

      // 5b. MILESTONE-GATED REVIEW REQUEST
      // After the 2nd or 3rd match record (not the very first), the native
      // In-App Review prompt fires exactly once. Google's API has its own
      // internal frequency caps; we just ensure we only call it at the eligible
      // milestone, not on every match completion thereafter.
      await ReviewService.maybeRequestAfterMatch();

      // 6. Update UI State & Navigate
      ref.read(importProvider.notifier).clear(); // Clear the source import
      ref.read(latestResultProvider.notifier).update = TeamResult(
        matchId: history.id,
        teams: teams,
        teamNames: teamNames,
        teamColors: teamColors,
      );

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const ResultsScreen()),
        );
      }
    } on PositionalBalanceError catch (e) {
      if (mounted) _showPositionalBalanceDialog(context, e);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isGenerating = false);
    }
  }

  void _showPositionalBalanceDialog(
    BuildContext context,
    PositionalBalanceError error,
  ) {
    String posLabel(PlayerPosition pos) {
      switch (pos) {
        case PlayerPosition.def:
          return 'DEF';
        case PlayerPosition.mid:
          return 'MID';
        case PlayerPosition.fwd:
          return 'FWD';
      }
    }

    final lines = <String>[];
    for (final entry in error.issues.entries) {
      final pos = entry.key;
      final remainder = entry.value.remainder;
      final total = entry.value.total;
      final needed = widget.numberOfTeams - remainder;
      lines.add(
        '• ${posLabel(pos)}: $total players.\n'
        '  → Add $needed or remove $remainder for equal teams.',
      );
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.backgroundDark,
        title: const Text(
          'POSITION IMBALANCE',
          style: TextStyle(
            color: AppColors.primaryYellow,
            fontWeight: FontWeight.w900,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: lines
              .map(
                (l) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    l,
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                  ),
                ),
              )
              .toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'CANCEL',
              style: TextStyle(color: AppColors.textGray),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _handleGenerate(force: true);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryYellow,
              padding: const EdgeInsets.symmetric(horizontal: 16),
            ),
            child: const Text(
              'GENERATE ANYWAYS',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        title: const Text('ASSIGN ROLES'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: widget.names.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) => _buildPlayerRow(index),
            ),
          ),
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildPlayerRow(int index) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.cardColorLight,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              widget.names[index],
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          _buildRoleDropdown(index),
          const SizedBox(width: 8),
          _buildTeamSelector(index),
        ],
      ),
    );
  }

  Widget _buildRoleDropdown(int index) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<PlayerPosition>(
          value: _selections[index],
          dropdownColor: AppColors.backgroundDark,
          isDense: true,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
          onChanged: (pos) => setState(() => _selections[index] = pos!),
          items: PlayerPosition.values
              .map(
                (pos) => DropdownMenuItem(
                  value: pos,
                  child: Text(pos.name.toUpperCase()),
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  Widget _buildTeamSelector(int index) {
    final List<String> options = [
      '',
      ...List.generate(widget.numberOfTeams, (i) => 'TEAM ${i + 1}'),
    ];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.backgroundDark,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.cardColor),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _teamSelections[index],
          dropdownColor: AppColors.cardColorLight,
          isDense: true,
          icon: const Icon(
            Icons.group,
            color: AppColors.primaryYellow,
            size: 14,
          ),
          style: const TextStyle(
            color: AppColors.primaryYellow,
            fontWeight: FontWeight.bold,
            fontSize: 10,
          ),
          onChanged: (val) => setState(() => _teamSelections[index] = val!),
          items: options
              .map(
                (opt) => DropdownMenuItem(
                  value: opt,
                  child: Text(
                    opt.isEmpty ? 'AUTO' : opt,
                    style: const TextStyle(fontSize: 10),
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  Widget _buildFooter() {
    final defCount = _selections.values
        .where((v) => v == PlayerPosition.def)
        .length;
    final midCount = _selections.values
        .where((v) => v == PlayerPosition.mid)
        .length;
    final fwdCount = _selections.values
        .where((v) => v == PlayerPosition.fwd)
        .length;
    final totalCount = widget.names.length;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    _buildPosStat('DEF', '$defCount', defCount > 0),
                    const SizedBox(width: 16),
                    _buildPosStat('MID', '$midCount', midCount > 0),
                    const SizedBox(width: 16),
                    _buildPosStat('FWD', '$fwdCount', fwdCount > 0),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'TOTAL ROSTER',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textGray,
                      ),
                    ),
                    Text(
                      totalCount.toString().padLeft(2, '0'),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: _isGenerating ? null : _handleGenerate,
                icon: const Icon(Icons.bolt, color: Colors.black),
                label: Text(
                  _isGenerating ? 'GENERATING...' : 'GENERATE TEAMS',
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryYellow,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPosStat(String label, String total, bool isYellow) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: AppColors.textGray,
          ),
        ),
        Text(
          total,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: isYellow ? AppColors.primaryYellow : Colors.white,
          ),
        ),
      ],
    );
  }
}
