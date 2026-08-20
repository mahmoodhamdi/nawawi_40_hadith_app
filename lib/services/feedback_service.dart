import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/constants.dart';

/// In-app feedback that respects offline-first / no-tracking guarantees.
///
/// We deliberately avoid any custom HTTP feedback endpoint:
///   - No backend means nothing to operate, nothing to breach.
///   - No analytics SDK means we don't even know who sent feedback.
///   - share_plus delegates to the OS share sheet, so the user picks
///     where to send (email, GitHub mobile app, WhatsApp to maintainer,
///     etc.). Their preference, their choice.
///
/// The feedback body includes minimal, non-identifying device info so the
/// maintainer can reproduce the issue. We do NOT include device IDs, IPs,
/// usernames, or any installed-app inventory.
/// Where a feedback message actually ended up.
enum FeedbackChannel { whatsapp, shareSheet }

class FeedbackService {
  /// Public GitHub issues URL — the canonical channel for bug reports
  /// and feature requests. Always shown in the body so users have a
  /// fallback if their share-sheet pick doesn't work out.
  static const String issuesUrl =
      'https://github.com/mahmoodhamdi/nawawi_40_hadith_app/issues/new';

  /// Build a feedback body string. Caller passes their user-typed
  /// message; we append a "diagnostics" block with non-identifying
  /// device info.
  static String buildBody({
    required String userMessage,
    required String appVersion,
    required String locale,
  }) {
    final platform = _platformName();
    final osVersion = _osVersion();

    return [
      userMessage.trim(),
      '',
      '---',
      'App: Forty Hadith Nawawi $appVersion',
      'Locale: $locale',
      'Platform: $platform $osVersion',
      'Report channel: $issuesUrl',
    ].join('\n');
  }

  /// A short header to prefill the WhatsApp compose box with: what the app
  /// and platform are, then a label for the user to type after.
  ///
  /// Deliberately two short lines rather than the full [buildBody] block —
  /// the user's cursor lands at the end of the prefilled text, so anything
  /// long would leave them typing underneath a wall of diagnostics.
  static String buildWhatsappPrefill({
    required String appVersion,
    required String locale,
    required String noteLabel,
  }) {
    final platform = _platformName();
    final osVersion = _osVersion();
    final env = [
      'Forty Hadith Nawawi $appVersion',
      locale,
      '$platform $osVersion'.trim(),
    ].where((part) => part.isNotEmpty).join(' · ');
    return '$env\n$noteLabel ';
  }

  /// Open WhatsApp addressed to the maintainer with [message] prefilled,
  /// falling back to the OS share sheet when WhatsApp cannot be opened
  /// (not installed, or a platform with no handler for the link).
  ///
  /// Handing off to another app is not a network request by this app — the
  /// offline guarantee is unchanged. Nothing is transmitted until the user
  /// presses send inside WhatsApp.
  static Future<FeedbackChannel> sendFeedback({
    required String message,
    required String appVersion,
  }) async {
    try {
      final opened = await launchUrl(
        ContactInfo.whatsappUri(message),
        mode: LaunchMode.externalApplication,
      );
      if (opened) return FeedbackChannel.whatsapp;
    } catch (e) {
      debugPrint('Could not open WhatsApp for feedback: $e');
    }

    await SharePlus.instance.share(
      ShareParams(
        text: message,
        subject: 'Feedback: Forty Hadith Nawawi $appVersion',
      ),
    );
    return FeedbackChannel.shareSheet;
  }

  /// Copy the feedback body to the clipboard — useful as a fallback when
  /// the share sheet on a particular device doesn't list a suitable
  /// destination, or when the user prefers to paste it into the GitHub
  /// issues page manually.
  static Future<void> copyFeedbackToClipboard({
    required String userMessage,
    required String appVersion,
    required String locale,
  }) async {
    final body = buildBody(
      userMessage: userMessage,
      appVersion: appVersion,
      locale: locale,
    );
    await Clipboard.setData(ClipboardData(text: body));
  }

  static String _platformName() {
    if (kIsWeb) return 'Web';
    if (Platform.isAndroid) return 'Android';
    if (Platform.isIOS) return 'iOS';
    if (Platform.isMacOS) return 'macOS';
    if (Platform.isLinux) return 'Linux';
    if (Platform.isWindows) return 'Windows';
    return 'Unknown';
  }

  static String _osVersion() {
    if (kIsWeb) return '';
    try {
      return Platform.operatingSystemVersion;
    } catch (_) {
      return '';
    }
  }
}
