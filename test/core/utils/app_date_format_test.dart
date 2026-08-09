// app_date_format_test.dart
//
// Verifies Phase 3.5's minutesFromTimeOfDay — the one place the app still
// parses a time string, used only to seed the shift form's time pickers
// when reopening an existing shift for editing. Round-trips against
// timeOfDayFromMinutes (its own inverse, from Phase 3.4) to confirm every
// value this app has ever actually written to `startTime`/`endTime`
// parses back correctly, plus the graceful-failure case for unparseable
// input.

import 'package:flutter_test/flutter_test.dart';
import 'package:shift_companion/core/utils/app_date_format.dart';

void main() {
  group('minutesFromTimeOfDay', () {
    test(
      'round-trips every minute of the day through timeOfDayFromMinutes',
      () {
        for (var minutes = 0; minutes < 24 * 60; minutes += 5) {
          final formatted = AppDateFormat.timeOfDayFromMinutes(minutes);
          expect(
            AppDateFormat.minutesFromTimeOfDay(formatted),
            minutes,
            reason: 'Failed to round-trip $formatted (expected $minutes)',
          );
        }
      },
    );

    test('parses midnight and noon correctly', () {
      expect(AppDateFormat.minutesFromTimeOfDay('12:00 AM'), 0);
      expect(AppDateFormat.minutesFromTimeOfDay('12:00 PM'), 720);
    });

    test('is case-insensitive on AM/PM', () {
      expect(AppDateFormat.minutesFromTimeOfDay('7:00 am'), 420);
      expect(AppDateFormat.minutesFromTimeOfDay('7:00 pm'), 1140);
    });

    test('returns null for unparseable legacy free-text values', () {
      expect(AppDateFormat.minutesFromTimeOfDay('morning shift'), isNull);
      expect(AppDateFormat.minutesFromTimeOfDay(''), isNull);
      expect(AppDateFormat.minutesFromTimeOfDay('25:00 AM'), isNull);
    });
  });
}
