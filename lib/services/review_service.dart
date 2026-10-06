import 'package:in_app_review/in_app_review.dart';
import '../storage/hive_storage.dart';

/// Handles Google Play In-App Review requests.
///
/// Two entry points:
/// 1. [maybeRequestAfterMatch] — the automatic, milestone-gated path. Called
///    after each match record is created. Fires the native prompt exactly once,
///    at the 2nd or 3rd completed match (never the very first).
/// 2. [requestReviewManually] — the Settings "Rate this App" path. Always
///    attempts the native prompt (subject to Google's own frequency caps).
///
/// Policy compliance (Google Play Developer Policy — Ratings & Reviews):
/// - No incentives: nothing here grants points/unlocks/rewards for rating.
/// - No review gating: there is no "are you enjoying the app?" pre-check that
///   routes only happy users to the prompt. Every user who reaches the trigger
///   point gets the same native prompt.
///
/// The Play Store deep-link ([openStoreListing]) is used ONLY as a fallback
/// when the native In-App Review API is unavailable on the device/Play version.
class ReviewService {
  ReviewService._();

  static final InAppReview _inAppReview = InAppReview.instance;

  /// Play Store application id, used for the fallback store-listing deep link.
  /// Matches `applicationId` in android/app/build.gradle.kts.
  static const String _androidAppId = 'com.ecslab.fcsquad';

  /// Milestone match counts that make the user eligible for the review prompt.
  /// Deliberately excludes the 1st match (avoid prompting on first success).
  static const Set<int> _eligibleMilestones = {2, 3};

  /// Automatic path: increments the completion counter and, if this is an
  /// eligible milestone and we've never asked before, fires the review request
  /// exactly once.
  ///
  /// Safe to call after every match completion — it self-limits via the
  /// persisted [HiveStorage.getHasRequestedReview] flag so the API is not
  /// spammed on every single completion.
  static Future<void> maybeRequestAfterMatch() async {
    await HiveStorage.incrementMatchCompletedCount();

    // Already prompted once — never ask again from the automatic path.
    if (HiveStorage.getHasRequestedReview()) return;

    final count = HiveStorage.getMatchCompletedCount();
    if (!_eligibleMilestones.contains(count)) return;

    // Mark as requested BEFORE the async call so a rebuild / rapid second
    // completion can't double-trigger the milestone.
    await HiveStorage.setHasRequestedReview(true);
    await _requestReview();
  }

  /// Manual path: invoked from the Settings "Rate this App" tile.
  /// Always attempts the native prompt; falls back to the store listing.
  static Future<void> requestReviewManually() async {
    await _requestReview();
  }

  /// Shared request logic. Prefers the native In-App Review flow; only falls
  /// back to opening the Play Store listing when the native API is unavailable.
  static Future<void> _requestReview() async {
    try {
      if (await _inAppReview.isAvailable()) {
        await _inAppReview.requestReview();
      } else {
        await _inAppReview.openStoreListing(appStoreId: _androidAppId);
      }
    } catch (_) {
      // Never let a review request crash a user flow. Best-effort fallback.
      try {
        await _inAppReview.openStoreListing(appStoreId: _androidAppId);
      } catch (_) {
        // Swallow — rating is non-critical.
      }
    }
  }
}
