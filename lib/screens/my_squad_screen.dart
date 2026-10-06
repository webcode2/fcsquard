import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/player.dart';
import '../theme/app_colors.dart';
import '../providers/roster_provider.dart';
import '../providers/summary_provider.dart';
import '../providers/result_provider.dart';
import '../providers/navigation_provider.dart';
import '../widgets/player_card.dart';
import 'update_player_screen.dart';
import 'settings_screen.dart';

class MySquadScreen extends ConsumerStatefulWidget {
  const MySquadScreen({super.key});

  @override
  ConsumerState<MySquadScreen> createState() => _MySquadScreenState();
}

class _MySquadScreenState extends ConsumerState<MySquadScreen> {
  String _searchQuery = '';
  PlayerPosition? _selectedPosition;
  bool _searchVisible = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    setState(() {
      _searchVisible = !_searchVisible;
      if (!_searchVisible) {
        _searchQuery = '';
        _searchController.clear();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final playersAsync = ref.watch(rosterProvider);
    final summary = ref.watch(rosterSummaryProvider);
    final latestResult = ref.watch(latestResultProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('MY SQUAD'),
        leading: null,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Settings',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: playersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Text('Error: $e', style: const TextStyle(color: Colors.red)),
        ),
        data: (players) {
          // ── Filtering Logic ──────────────────────────────
          final filteredPlayers = players.where((p) {
            final matchesSearch =
                p.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                p.grade.toLowerCase().contains(_searchQuery.toLowerCase());

            final matchesPosition =
                _selectedPosition == null ||
                p.positions.contains(_selectedPosition);

            return matchesSearch && matchesPosition;
          }).toList();

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      // ── Single summary card ──────────────────────────────
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 20,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.cardColor,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: const [
                            BoxShadow(
                              color: Color.fromRGBO(0, 0, 0, 0.25),
                              blurRadius: 12,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            // Total Players
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'TOTAL PLAYERS',
                                    style: TextStyle(
                                      color: AppColors.textGray,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    '${summary.total}',
                                    style: const TextStyle(
                                      fontSize: 42,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white,
                                      height: 1,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Placeholder or just empty space? Let's just keep the total for now.
                            const Spacer(),
                          ],
                        ),
                      ),
                      if (latestResult == null) ...[
                        const SizedBox(height: 16),
                        GestureDetector(
                          onTap: () =>
                              ref.read(navigationProvider.notifier).setTab(1),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: AppColors.primaryYellow.withValues(
                                alpha: 0.1,
                              ),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: AppColors.primaryYellow.withValues(
                                  alpha: 0.3,
                                ),
                              ),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.bolt,
                                  color: AppColors.primaryYellow,
                                  size: 18,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'GENERATE TEAMS FOR MATCH',
                                  style: TextStyle(
                                    color: AppColors.primaryYellow,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 12,
                                    letterSpacing: 1.1,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 20),
                      // ── Filter chips + search toggle ──────────────────
                      Row(
                        children: [
                          Expanded(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  _buildChip(
                                    'ALL',
                                    _selectedPosition == null,
                                    () => setState(
                                      () => _selectedPosition = null,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  _buildChip(
                                    'DEF',
                                    _selectedPosition == PlayerPosition.def,
                                    () => setState(
                                      () => _selectedPosition =
                                          PlayerPosition.def,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  _buildChip(
                                    'MID',
                                    _selectedPosition == PlayerPosition.mid,
                                    () => setState(
                                      () => _selectedPosition =
                                          PlayerPosition.mid,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  _buildChip(
                                    'FWD',
                                    _selectedPosition == PlayerPosition.fwd,
                                    () => setState(
                                      () => _selectedPosition =
                                          PlayerPosition.fwd,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Clear Squad Button
                          GestureDetector(
                            onTap: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  backgroundColor: AppColors.backgroundDark,
                                  title: const Text(
                                    'CLEAR CURRENT SQUAD?',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 1.1,
                                    ),
                                  ),
                                  content: const Text(
                                    'This will remove all players from the current list. History and all-time stats will NOT be affected.',
                                    style: TextStyle(
                                      color: AppColors.textGray,
                                      fontSize: 13,
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(ctx, false),
                                      child: const Text(
                                        'CANCEL',
                                        style: TextStyle(
                                          color: AppColors.textGray,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.pop(ctx, true),
                                      child: const Text(
                                        'CLEAR ALL',
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
                                ref.read(rosterProvider.notifier).clearAll();
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.cardColor,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.delete_sweep_outlined,
                                size: 18,
                                color: Colors.red,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Search toggle icon
                          GestureDetector(
                            onTap: _toggleSearch,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: _searchVisible
                                    ? AppColors.primaryYellow
                                    : AppColors.cardColor,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                _searchVisible ? Icons.close : Icons.search,
                                size: 18,
                                color: _searchVisible
                                    ? Colors.black
                                    : AppColors.textGray,
                              ),
                            ),
                          ),
                        ],
                      ),
                      // ── Animated search bar ──────────────────────────
                      AnimatedSize(
                        duration: const Duration(milliseconds: 220),
                        curve: Curves.easeInOut,
                        child: _searchVisible
                            ? Column(
                                children: [
                                  const SizedBox(height: 12),
                                  TextField(
                                    controller: _searchController,
                                    autofocus: true,
                                    onChanged: (v) =>
                                        setState(() => _searchQuery = v),
                                    style: const TextStyle(color: Colors.white),
                                    decoration: InputDecoration(
                                      hintText: 'Search players...',
                                      hintStyle: const TextStyle(
                                        color: AppColors.textGray,
                                      ),
                                      prefixIcon: const Icon(
                                        Icons.search,
                                        color: AppColors.textGray,
                                        size: 20,
                                      ),
                                      filled: true,
                                      fillColor: AppColors.backgroundDark,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide.none,
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 12,
                                          ),
                                    ),
                                  ),
                                ],
                              )
                            : const SizedBox.shrink(),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
              ..._buildRoleSections(context, ref, filteredPlayers),
            ],
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

  void _showAddPlayerDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => _AddPlayerRosterDialog(
        onSave: (player) {
          ref.read(rosterProvider.notifier).addPlayer(player);
        },
      ),
    );
  }

  List<Widget> _buildRoleSections(
    BuildContext context,
    WidgetRef ref,
    List<Player> allPlayers,
  ) {
    if (allPlayers.isEmpty) {
      return [_buildEmptyState()];
    }

    final accentColor = AppColors.primaryYellow;

    return [
      SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        sliver: SliverList(
          delegate: SliverChildListDelegate([
            _buildPositionSection(
              context,
              ref,
              'DEFENDERS',
              PlayerPosition.def,
              allPlayers,
              accentColor,
            ),
            _buildPositionSection(
              context,
              ref,
              'MIDFIELDERS',
              PlayerPosition.mid,
              allPlayers,
              accentColor,
            ),
            _buildPositionSection(
              context,
              ref,
              'FORWARDS',
              PlayerPosition.fwd,
              allPlayers,
              accentColor,
            ),
            const SizedBox(height: 32),
          ]),
        ),
      ),
    ];
  }

  Widget _buildPositionSection(
    BuildContext context,
    WidgetRef ref,
    String label,
    PlayerPosition pos,
    List<Player> players,
    Color accentColor,
  ) {
    final filtered = players
        .where((p) => p.positions.isNotEmpty && p.positions.first == pos)
        .toList();
    if (filtered.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          margin: const EdgeInsets.only(bottom: 12, top: 8),
          decoration: BoxDecoration(
            color: AppColors.cardColor,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            label,
            style: const TextStyle(
              color: AppColors.textGray,
              fontSize: 9,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
            ),
          ),
        ),
        ...filtered.map((p) => _buildPlayerCard(context, ref, p, accentColor)),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildPlayerCard(
    BuildContext context,
    WidgetRef ref,
    Player player,
    Color accentColor,
  ) {
    return PlayerCard(
      player: player,
      accentColor: accentColor,
      onEdit: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => UpdatePlayerScreen(player: player),
          ),
        );
      },
      onDelete: () async {
        final confirm = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: AppColors.backgroundDark,
            title: const Text(
              'DELETE PLAYER?',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.1,
              ),
            ),
            content: Text(
              'Are you sure you want to remove ${player.name}? This action is irreversible for the current roster.',
              style: const TextStyle(color: AppColors.textGray, fontSize: 13),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text(
                  'CANCEL',
                  style: TextStyle(
                    color: AppColors.textGray,
                    fontWeight: FontWeight.bold,
                  ),
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
          ref.read(rosterProvider.notifier).removePlayer(player.id);
        }
      },
    );
  }

  Widget _buildChip(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.cardColorLight : AppColors.cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.transparent : AppColors.backgroundDark,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.textGray,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: AppColors.cardColor,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.groups_outlined,
                size: 64,
                color: AppColors.textGray,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'NO TEAMS FOUND',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'GENERATE TEAMS TO VIEW YOUR SQUAD',
              style: TextStyle(
                color: AppColors.textGray,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddPlayerRosterDialog extends StatefulWidget {
  final void Function(Player player) onSave;

  const _AddPlayerRosterDialog({required this.onSave});

  @override
  State<_AddPlayerRosterDialog> createState() => _AddPlayerRosterDialogState();
}

class _AddPlayerRosterDialogState extends State<_AddPlayerRosterDialog> {
  final _nameController = TextEditingController();
  final _numberController = TextEditingController();
  PlayerPosition _selectedPosition = PlayerPosition.def;

  @override
  void dispose() {
    _nameController.dispose();
    _numberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.backgroundDark,
      title: const Text(
        'ADD NEW PLAYER',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w900,
          fontSize: 18,
          letterSpacing: 1.1,
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLabel('PLAYER NAME'),
            TextField(
              controller: _nameController,
              autofocus: true,
              style: const TextStyle(color: Colors.white),
              decoration: _inputDecoration('e.g. MARCUS THORNE'),
            ),
            const SizedBox(height: 20),
            _buildLabel('JERSEY NO.'),
            TextField(
              controller: _numberController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: AppColors.primaryYellow),
              decoration: _inputDecoration('00'),
            ),
            const SizedBox(height: 24),
            _buildLabel('PRIMARY POSITION'),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _posChip(PlayerPosition.def, 'DEF'),
                _posChip(PlayerPosition.mid, 'MID'),
                _posChip(PlayerPosition.fwd, 'FWD'),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            'CANCEL',
            style: TextStyle(color: AppColors.textGray),
          ),
        ),
        TextButton(
          onPressed: () {
            if (_nameController.text.isNotEmpty) {
              final player = Player(
                id: const Uuid().v4(),
                name: _nameController.text.toUpperCase(),
                number: int.tryParse(_numberController.text) ?? 0,
                ovr: 50, // Default OVR
                positions: [_selectedPosition],
                team: '', // No team initially
                grade: 'C', // Default grade
              );
              widget.onSave(player);
              Navigator.pop(context);
            }
          },
          child: const Text(
            'ADD PLAYER',
            style: TextStyle(
              color: AppColors.primaryYellow,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.textGray,
          fontSize: 10,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.0,
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.white24),
      filled: true,
      fillColor: AppColors.cardColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }

  Widget _posChip(PlayerPosition pos, String label) {
    final isSelected = _selectedPosition == pos;
    return GestureDetector(
      onTap: () => setState(() => _selectedPosition = pos),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryYellow : AppColors.cardColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppColors.primaryYellow : Colors.transparent,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.black : Colors.white70,
            fontWeight: FontWeight.w900,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
