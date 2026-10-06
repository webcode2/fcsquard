import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/player.dart';
import '../providers/roster_provider.dart';
import '../theme/app_colors.dart';

class UpdatePlayerScreen extends ConsumerStatefulWidget {
  final Player player;

  const UpdatePlayerScreen({super.key, required this.player});

  @override
  ConsumerState<UpdatePlayerScreen> createState() => _UpdatePlayerScreenState();
}

class _UpdatePlayerScreenState extends ConsumerState<UpdatePlayerScreen> {
  late TextEditingController _nameController;
  late TextEditingController _numberController;
  late List<PlayerPosition> _selectedPositions;
  late String _selectedTeam;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.player.name);
    _numberController = TextEditingController(
      text: widget.player.number.toString(),
    );
    _selectedPositions = List.from(widget.player.positions);
    _selectedTeam = widget.player.team;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _numberController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    final updatedPlayer = widget.player.copyWith(
      name: _nameController.text.toUpperCase(),
      number: int.tryParse(_numberController.text) ?? 0,
      ovr: widget.player.ovr,
      positions: _selectedPositions,
      team: _selectedTeam,
    );

    await ref.read(rosterProvider.notifier).updatePlayerInfo(updatedPlayer);

    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'UPDATE PLAYER',
          style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.2),
        ),
        actions: [
          TextButton(
            onPressed: _handleSave,
            child: const Text(
              'SAVE',
              style: TextStyle(
                color: AppColors.primaryYellow,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('IDENTITY'),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _nameController,
              label: 'FULL NAME',
              hint: 'e.g. MARCUS THORNE',
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: _numberController,
                    label: 'JERSEY NO.',
                    hint: '00',
                    keyboardType: TextInputType.number,
                  ),
                ),
                const Spacer(),
              ],
            ),
            const SizedBox(height: 32),
            _buildSectionHeader('TACTICAL POSITION'),
            const SizedBox(height: 16),
            _buildPositionSelector(),
            const SizedBox(height: 32),
            _buildSectionHeader('TEAM ASSIGNMENT'),
            const SizedBox(height: 16),
            _buildTeamSelector(),
            const SizedBox(height: 48),
            _buildDeleteButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: AppColors.textGray,
        fontSize: 12,
        fontWeight: FontWeight.w900,
        letterSpacing: 1.1,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.cardColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.cardColorLight),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: AppColors.textGray),
              contentPadding: const EdgeInsets.all(16),
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPositionSelector() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: PlayerPosition.values.map((pos) {
        final isSelected = _selectedPositions.contains(pos);
        final isPrimary =
            _selectedPositions.isNotEmpty && _selectedPositions.first == pos;

        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedPositions = [pos];
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: isPrimary
                  ? AppColors.primaryYellow
                  : (isSelected
                        ? AppColors.primaryYellow.withValues(alpha: 0.3)
                        : AppColors.cardColor),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected
                    ? AppColors.primaryYellow
                    
                    : AppColors.cardColorLight,
              ),
            ),
            child: Text(
              pos.name.toUpperCase(),
              style: TextStyle(
                color: isPrimary ? Colors.black : Colors.white,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTeamSelector() {
    final teams = ['', 'TEAM 1', 'TEAM 2', 'TEAM 3'];

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: teams.map((team) {
        final isSelected = _selectedTeam == team;
        final label = team.isEmpty ? 'AUTO (NONE)' : team;

        return GestureDetector(
          onTap: () => setState(() => _selectedTeam = team),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primaryYellow : AppColors.cardColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected
                    ? AppColors.primaryYellow
                    : AppColors.cardColorLight,
              ),
            ),
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.black : Colors.white70,
                fontSize: 11,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDeleteButton() {
    return SizedBox(
      width: double.infinity,
      child: TextButton.icon(
        onPressed: () async {
          final confirm = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              backgroundColor: AppColors.backgroundDark,
              title: const Text(
                'DELETE PLAYER?',
                style: TextStyle(color: Colors.white),
              ),
              content: const Text(
                'This action cannot be undone.',
                style: TextStyle(color: AppColors.textGray),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('CANCEL'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: const Text(
                    'DELETE',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ),
          );

          if (confirm == true && mounted) {
            await ref
                .read(rosterProvider.notifier)
                .removePlayer(widget.player.id);
            if (mounted) Navigator.pop(context);
          }
        },
        icon: const Icon(Icons.delete_outline, color: Colors.red),
        label: const Text(
          'REMOVE FROM SQUAD',
          style: TextStyle(color: Colors.red),
        ),
      ),
    );
  }
}
