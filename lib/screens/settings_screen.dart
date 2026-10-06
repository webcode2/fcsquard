import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../services/review_service.dart';
import 'help_screen.dart';

/// Settings screen — reachable via the gear icon on the MY SQUAD AppBar.
///
/// Contains:
/// - "Rate this App" → triggers the native In-App Review flow (manual path).
/// - "Help & FAQ" → navigates to the static Help screen.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(title: const Text('SETTINGS')),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          _buildTile(
            context: context,
            icon: Icons.star_border,
            label: 'Rate this App',
            subtitle: 'Leave a rating on Google Play',
            onTap: () async {
              await ReviewService.requestReviewManually();
            },
          ),
          const Divider(height: 1, color: AppColors.cardColor),
          _buildTile(
            context: context,
            icon: Icons.help_outline,
            label: 'Help & FAQ',
            subtitle: 'Answers to common questions',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const HelpScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTile({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primaryYellow),
      title: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 15,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(color: AppColors.textGray, fontSize: 12),
      ),
      trailing: const Icon(Icons.chevron_right, color: AppColors.textGray),
      onTap: onTap,
    );
  }
}
