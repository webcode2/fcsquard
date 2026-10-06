import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import '../storage/hive_storage.dart';
import '../theme/app_colors.dart';

/// First-launch onboarding walkthrough.
///
/// Shows 3 coach marks highlighting the app's main actions, anchored to the
/// bottom navigation bar so all targets are visible at once and the skip button
/// remains persistent throughout the sequence.
///
/// The walkthrough fires once per install, checked by [HiveStorage.getHasSeenOnboarding].
/// Skip button is visible on every step (required).
class OnboardingService {
  OnboardingService._();

  /// Keys for the three bottom-nav items we'll highlight.
  /// These must be assigned in [MainNavigationScreen]'s BottomNavigationBar.
  static final GlobalKey squadNavKey = GlobalKey();
  static final GlobalKey generateNavKey = GlobalKey();
  static final GlobalKey statsNavKey = GlobalKey();

  static const _stepCount = 3;

  /// Shows the walkthrough if the user hasn't seen it yet.
  /// Safe to call on every app launch — it self-gates via Hive storage.
  static Future<void> maybeShowOnboarding(BuildContext context) async {
    if (HiveStorage.getHasSeenOnboarding()) return;

    // Wait one frame so the bottom nav is fully laid out and keys are mounted.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.mounted) return;
      _showOnboarding(context);
    });
  }

  static void _showOnboarding(BuildContext context) {
    final targets = [
      _tabTarget(
        identify: 'squad',
        key: squadNavKey,
        step: 1,
        icon: Icons.people_alt_outlined,
        title: 'MY SQUAD',
        body:
            'Your persistent roster lives here. Add players with the + button, '
            'then set positions and numbers before a match.',
      ),
      _tabTarget(
        identify: 'generate',
        key: generateNavKey,
        step: 2,
        icon: Icons.bolt,
        title: 'GENERATE',
        body:
            'Paste your squad list, choose how many teams, then tap GENERATE '
            'TEAMS to assign roles and draw.',
      ),
      _tabTarget(
        identify: 'stats',
        key: statsNavKey,
        step: 3,
        icon: Icons.archive_outlined,
        title: 'STATS',
        body:
            'Goals, assists, and clean sheets stay on this tab, even after a '
            'player leaves the current roster.',
      ),
    ];

    TutorialCoachMark(
      targets: targets,
      colorShadow: const Color(0xFF050910),
      opacityShadow: 0.78,
      paddingFocus: 10,
      pulseEnable: false,
      hideSkip: false,
      alignSkip: Alignment.topRight,
      imageFilter: ImageFilter.blur(sigmaX: 2.5, sigmaY: 2.5),
      skipWidget: const _SkipTourButton(),
      onFinish: () {
        HiveStorage.setHasSeenOnboarding(true);
      },
      onSkip: () {
        HiveStorage.setHasSeenOnboarding(true);
        return true;
      },
    ).show(context: context);
  }

  static TargetFocus _tabTarget({
    required String identify,
    required GlobalKey key,
    required int step,
    required IconData icon,
    required String title,
    required String body,
  }) {
    return TargetFocus(
      identify: identify,
      keyTarget: key,
      alignSkip: Alignment.topRight,
      shape: ShapeLightFocus.RRect,
      radius: 14,
      paddingFocus: 10,
      borderSide: const BorderSide(color: AppColors.primaryYellow, width: 1.5),
      contents: [
        TargetContent(
          align: ContentAlign.top,
          builder: (context, controller) => _TourCard(
            step: step,
            total: _stepCount,
            icon: icon,
            title: title,
            body: body,
            isLast: step == _stepCount,
            onNext: controller.next,
            onSkip: controller.skip,
          ),
        ),
      ],
    );
  }
}

class _SkipTourButton extends StatelessWidget {
  const _SkipTourButton();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(right: 12, top: 4),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.cardColorLight.withValues(alpha: 0.92),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
          ),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Text(
              'SKIP',
              style: TextStyle(
                color: AppColors.textGray,
                fontWeight: FontWeight.w800,
                fontSize: 12,
                letterSpacing: 1.4,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TourCard extends StatelessWidget {
  const _TourCard({
    required this.step,
    required this.total,
    required this.icon,
    required this.title,
    required this.body,
    required this.isLast,
    required this.onNext,
    required this.onSkip,
  });

  final int step;
  final int total;
  final IconData icon;
  final String title;
  final String body;
  final bool isLast;
  final VoidCallback onNext;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x66000000),
              blurRadius: 24,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(height: 3, color: AppColors.primaryYellow),
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          '${step.toString().padLeft(2, '0')}  /  ${total.toString().padLeft(2, '0')}',
                          style: const TextStyle(
                            color: AppColors.textGray,
                            fontWeight: FontWeight.w700,
                            fontSize: 11,
                            letterSpacing: 1.6,
                          ),
                        ),
                        const Spacer(),
                        _StepDots(step: step, total: total),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: AppColors.primaryYellow.withValues(
                              alpha: 0.14,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            icon,
                            color: AppColors.primaryYellow,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            title,
                            style: const TextStyle(
                              color: AppColors.primaryYellow,
                              fontWeight: FontWeight.w900,
                              fontSize: 18,
                              letterSpacing: 1.1,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      body,
                      style: const TextStyle(
                        color: Color(0xFFE8EEF7),
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        if (!isLast)
                          TextButton(
                            onPressed: onSkip,
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.textGray,
                              minimumSize: const Size(64, 44),
                            ),
                            child: const Text(
                              'SKIP',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.2,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        const Spacer(),
                        FilledButton(
                          onPressed: onNext,
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.primaryYellow,
                            foregroundColor: Colors.black,
                            minimumSize: const Size(120, 44),
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            isLast ? 'GOT IT' : 'NEXT',
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.2,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
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

class _StepDots extends StatelessWidget {
  const _StepDots({required this.step, required this.total});

  final int step;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 1; i <= total; i++) ...[
          if (i > 1) const SizedBox(width: 6),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: i == step ? 16 : 6,
            height: 6,
            decoration: BoxDecoration(
              color: i == step
                  ? AppColors.primaryYellow
                  : Colors.white.withValues(alpha: 0.22),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ],
    );
  }
}
