import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Static Help / FAQ screen, reachable from Settings.
///
/// Independent of the onboarding walkthrough — users can open this at any time,
/// even after onboarding has been completed or skipped.
class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  static const List<({String question, String answer})> _faqs = [
    (
      question: 'How do I generate teams?',
      answer:
          'Go to the GENERATE tab and add your players — type them in one per '
          'line or paste a whole list at once. Pick how many teams you want, '
          'then tap GENERATE TEAMS. You\'ll land on the ASSIGN ROLES screen '
          'next, where you set each player\'s position before the final draw.',
    ),
    (
      question: 'How does FC Squad balance the teams?',
      answer:
          'Players are split into three position pools — DEF, MID and FWD. '
          'Each pool is shuffled, then dealt out one at a time across your '
          'teams in rotation, so every side ends up with a similar mix of '
          'positions rather than all the defenders landing on one team. '
          'Because the draw is shuffled, generating again gives you fresh '
          'line-ups from the same squad.',
    ),
    (
      question: 'What does the "POSITION IMBALANCE" message mean?',
      answer:
          'For perfectly even teams, the number of players in each position '
          'needs to divide equally between your teams — for example, 6 '
          'midfielders across 2 teams. When a position doesn\'t divide '
          'evenly, FC Squad tells you how many players to add or drop to even '
          'it out. You can also tap GENERATE ANYWAYS to draw slightly uneven '
          'teams if you\'re happy with that.',
    ),
    (
      question: 'Can I put specific players on the same team?',
      answer:
          'Yes. On the ASSIGN ROLES screen each player has a team selector set '
          'to AUTO by default. Switch it from AUTO to a specific team (e.g. '
          'TEAM 1) to lock that player there, and leave the rest on AUTO to be '
          'drawn automatically around your picks.',
    ),
    (
      question: 'How are player stats tracked?',
      answer:
          'FC Squad keeps a running total of goals, assists and clean sheets '
          'for each player by name. These carry over from match to match and '
          'stay on the STATS tab even if a player isn\'t in your current '
          'roster, so a player\'s history follows them whenever their name '
          'comes back into a squad.',
    ),
    (
      question: 'Where are my past matches saved?',
      answer:
          'Every time you generate teams, the line-up is saved automatically '
          'to your match history. Open a saved match to view the teams again, '
          'or swipe a match left and tap DELETE to remove it. Deleting a match '
          'record is permanent and can\'t be undone.',
    ),
    (
      question: 'Is my data stored online?',
      answer:
          'No. Your squad, stats and match history are all stored locally on '
          'your device — nothing is uploaded to a server or shared. Clearing '
          'the app\'s data or uninstalling it will remove this information.',
    ),
    (
      question: 'How do I rate FC Squad?',
      answer:
          'Open Settings (the gear icon on the MY SQUAD screen) and tap "Rate '
          'this App" to leave a rating on Google Play. It only takes a moment '
          'and it genuinely helps other teams find the app.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(title: const Text('HELP & FAQ')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 16, left: 4),
            child: Text(
              'Frequently asked questions',
              style: TextStyle(
                color: AppColors.textGray,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ),
          ..._faqs.map(_buildFaqCard),
        ],
      ),
    );
  }

  Widget _buildFaqCard(({String question, String answer}) faq) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Theme(
        // Remove the default ExpansionTile divider lines for a cleaner card.
        data: ThemeData(
          dividerColor: Colors.transparent,
          colorScheme: const ColorScheme.dark(primary: AppColors.primaryYellow),
        ),
        child: ExpansionTile(
          iconColor: AppColors.primaryYellow,
          collapsedIconColor: AppColors.textGray,
          title: Text(
            faq.question,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          expandedAlignment: Alignment.centerLeft,
          expandedCrossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              faq.answer,
              style: const TextStyle(
                color: AppColors.textGray,
                fontSize: 13,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
