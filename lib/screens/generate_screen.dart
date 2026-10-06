import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_colors.dart';
import '../providers/roster_provider.dart';
import '../providers/import_provider.dart';
import '../models/player.dart';
import 'role_selection_screen.dart';
import 'match_history_screen.dart';

class GenerateScreen extends ConsumerStatefulWidget {
  const GenerateScreen({super.key});

  @override
  ConsumerState<GenerateScreen> createState() => _GenerateScreenState();
}

class _GenerateScreenState extends ConsumerState<GenerateScreen> {
  int _numberOfTeams = 3;

  // Import related state
  final TextEditingController _importController = TextEditingController();
  List<String> _parsedNames = [];

  @override
  void initState() {
    super.initState();
    // Initialize controller with current provider value
    _importController.text = ref.read(importProvider);
    _importController.addListener(_handleImportTextChanged);
  }

  @override
  void dispose() {
    _importController.removeListener(_handleImportTextChanged);
    _importController.dispose();
    super.dispose();
  }

  void _handleImportTextChanged() {
    final text = _importController.text;
    final names = _parseNames(text);
    // Sync to provider for external access/clearing
    ref.read(importProvider.notifier).update = text;
    setState(() {
      _parsedNames = names;
    });
  }

  List<String> _parseNames(String text) {
    if (text.trim().isEmpty) return [];
    final lines = text.split('\n');
    final scrubRegex = RegExp(r'^[\s\d\.\-\*\•\)\>]+');
    final List<String> names = [];
    for (var line in lines) {
      final cleaned = line.replaceFirst(scrubRegex, '').trim();
      if (cleaned.isNotEmpty) {
        names.add(cleaned.toUpperCase());
      }
    }
    return names;
  }

  @override
  Widget build(BuildContext context) {
    final allPlayersAsync = ref.watch(rosterProvider);
    final playersList = allPlayersAsync.value ?? [];

    // Listen for external clearing (e.g. from RoleSelectionScreen)
    ref.listen(importProvider, (prev, next) {
      if (next.isEmpty && _importController.text.isNotEmpty) {
        _importController.clear();
      }
    });

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        title: const Text('GENERATE'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history, color: AppColors.primaryYellow),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const MatchHistoryScreen(),
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          _buildImportView(),
          if (_parsedNames.isNotEmpty)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _buildBottomPanel(context, playersList),
            ),
        ],
      ),
    );
  }

  Widget _buildImportView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(
        left: 24.0,
        right: 24.0,
        top: 24.0,
        bottom: 300.0, // Enough space for the generation settings panel
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Paste your squad list below. Our parser handles bullets and numbering automatically.',
            style: TextStyle(
              color: AppColors.textGray,
              fontSize: 13,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 32),
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: const Color(0xFF070D18),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.cardColor, width: 1),
            ),
            child: TextField(
              controller: _importController,
              maxLines: null,
              style: const TextStyle(
                color: Colors.white,
                fontFamily: 'monospace',
                fontSize: 15,
              ),
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.all(20),
                border: InputBorder.none,
                hintText: '1. PLAYER NAME\n2. ANOTHER PLAYER...',
                hintStyle: TextStyle(color: AppColors.textGray),
              ),
            ),
          ),
          const SizedBox(height: 32),
          if (_parsedNames.isNotEmpty) ...[
            ..._parsedNames.take(5).map((name) => _buildPreviewItem(name)),
            if (_parsedNames.length > 5)
              Text(
                '+ ${_parsedNames.length - 5} MORE',
                style: const TextStyle(color: AppColors.textGray, fontSize: 10),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildPreviewItem(String name) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        name,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildBottomPanel(BuildContext context, List<Player> players) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.3),
            blurRadius: 10,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Text(
                  'NO. OF TEAMS',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textGray,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(width: 16),
                _buildTeamCountBtn(Icons.remove, () {
                  if (_numberOfTeams > 2) setState(() => _numberOfTeams--);
                }),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    '$_numberOfTeams',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: AppColors.primaryYellow,
                    ),
                  ),
                ),
                _buildTeamCountBtn(Icons.add, () {
                  if (_numberOfTeams < 8) setState(() => _numberOfTeams++);
                }),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: () {
                  if (_parsedNames.isNotEmpty) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => RoleSelectionScreen(
                          names: _parsedNames,
                          numberOfTeams: _numberOfTeams,
                        ),
                      ),
                    );
                    return;
                  }
                  // For existing players, we still need to assign roles/teams
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => RoleSelectionScreen(
                        names: players.map((p) => p.name).toList(),
                        numberOfTeams: _numberOfTeams,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.bolt, color: Colors.black),
                label: Text(
                  _parsedNames.isNotEmpty ? 'ASSIGN ROLES' : 'GENERATE TEAMS',
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.0,
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

  Widget _buildTeamCountBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: AppColors.backgroundDark,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Icon(icon, size: 20, color: Colors.white),
      ),
    );
  }
}
