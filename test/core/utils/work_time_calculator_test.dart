// work_time_calculator_test.dart
//
// Verifies Phase 3.5's calculation utility, including the four worked
// examples from that phase's own brief, overnight wraparound, and the
// validation edge cases (break exceeding duration, zero-length shifts).

import 'package:flutter_test/flutter_test.dart';
import 'package:shift_companion/core/utils/work_time_calculator.dart';

void main() {
  group('calculateWorkedHours — brief examples', () {
    test('Example 1: 07:00-15:30, 30 min break -> 8.0 hours', () {
      final hours = WorkTimeCalculator.calculateWorkedHours(
        startMinutes: 7 * 60,
        endMinutes: 15 * 60 + 30,
        breakMinutes: 30,
      );
      expect(hours, 8.0);
    });

    test('Example 2: 07:00-15:30, 60 min break -> 7.5 hours', () {
      final hours = WorkTimeCalculator.calculateWorkedHours(
        startMinutes: 7 * 60,
        endMinutes: 15 * 60 + 30,
        breakMinutes: 60,
      );
      expect(hours, 7.5);
    });

    test('Example 3: 22:00-06:00 (overnight), 30 min break -> 7.5 hours', () {
      final hours = WorkTimeCalculator.calculateWorkedHours(
        startMinutes: 22 * 60,
        endMinutes: 6 * 60,
        breakMinutes: 30,
      );
      expect(hours, 7.5);
      expect(WorkTimeCalculator.isOvernight(22 * 60, 6 * 60), isTrue);
    });

    test('Example 4: 18:15-23:45, 15 min break -> 5.25 hours', () {
      final hours = WorkTimeCalculator.calculateWorkedHours(
        startMinutes: 18 * 60 + 15,
        endMinutes: 23 * 60 + 45,
        breakMinutes: 15,
      );
      expect(hours, 5.25);
    });
  });

  group('formatHours', () {
    test('formats whole and half hours with one decimal place', () {
      expect(WorkTimeCalculator.formatHours(8.0), '8.0');
      expect(WorkTimeCalculator.formatHours(7.5), '7.5');
    });

    test('formats quarter hours with two decimal places', () {
      expect(WorkTimeCalculator.formatHours(5.25), '5.25');
    });

    test('rounds away floating-point noise for uneven minute counts', () {
      // 100 minutes / 60 = 1.6666666666666667 unrounded.
      final hours = WorkTimeCalculator.calculateWorkedHours(
        startMinutes: 0,
        endMinutes: 100,
        breakMinutes: 0,
      );
      expect(WorkTimeCalculator.formatHours(hours), '1.67');
    });
  });

  group('overnight handling', () {
    test(
      'isOvernight is true when finish is earlier in the day than start',
      () {
        expect(WorkTimeCalculator.isOvernight(22 * 60, 6 * 60), isTrue);
      },
    );

    test('isOvernight is false for a same-day shift', () {
      expect(WorkTimeCalculator.isOvernight(7 * 60, 15 * 60), isFalse);
    });

    test('isOvernight is false when start and finish are identical', () {
      expect(WorkTimeCalculator.isOvernight(600, 600), isFalse);
    });
  });

  group('edge cases', () {
    test(
      'zero-length shift (same start and finish) yields zero hours, not a crash',
      () {
        final hours = WorkTimeCalculator.calculateWorkedHours(
          startMinutes: 600,
          endMinutes: 600,
          breakMinutes: 0,
        );
        expect(hours, 0.0);
      },
    );

    test(
      'a break longer than the shift clamps worked hours to zero, never negative',
      () {
        final hours = WorkTimeCalculator.calculateWorkedHours(
          startMinutes: 7 * 60,
          endMinutes: 8 * 60, // 60 minutes raw duration
          breakMinutes: 90, // longer than the shift itself
        );
        expect(hours, 0.0);
      },
    );

    test('isBreakTooLong flags a break exceeding the raw duration', () {
      final tooLong = WorkTimeCalculator.isBreakTooLong(
        startMinutes: 7 * 60,
        endMinutes: 8 * 60,
        breakMinutes: 90,
      );
      expect(tooLong, isTrue);
    });

    test('isBreakTooLong is false for a break within the raw duration', () {
      final tooLong = WorkTimeCalculator.isBreakTooLong(
        startMinutes: 7 * 60,
        endMinutes: 15 * 60 + 30,
        breakMinutes: 30,
      );
      expect(tooLong, isFalse);
    });

    test(
      'a negative break is treated as no break, never inflating worked time',
      () {
        // Without the guard, duration(480) - (-30) would wrongly yield 510
        // minutes (8.5h) — more than the shift's own raw span.
        final hours = WorkTimeCalculator.calculateWorkedHours(
          startMinutes: 9 * 60,
          endMinutes: 17 * 60,
          breakMinutes: -30,
        );
        expect(hours, 8.0);
      },
    );

    test('isNegativeBreak flags a negative break value', () {
      expect(WorkTimeCalculator.isNegativeBreak(-1), isTrue);
      expect(WorkTimeCalculator.isNegativeBreak(0), isFalse);
      expect(WorkTimeCalculator.isNegativeBreak(30), isFalse);
    });
  });

  group('Phase 3.6 — unpaid break clarification', () {
    test(
      '07:00-16:30, 40 min unpaid break -> 8h 50m (real-world opening shift)',
      () {
        final minutes = WorkTimeCalculator.calculateWorkedMinutes(
          startMinutes: 7 * 60,
          endMinutes: 16 * 60 + 30,
          breakMinutes: 40,
        );
        // 8h 50m = 530 minutes. Asserted in minutes (not hours) so this
        // test can't be fooled by a formatting bug — 530 minutes is
        // unambiguously "8h 50m", independent of how it's later displayed.
        expect(minutes, 530);
      },
    );

    test('a paid rest break must never be folded into breakMinutes — only the '
        'unpaid amount is deducted', () {
      // A worker with a paid 10-minute rest break *and* a 40-minute
      // unpaid break must still pass breakMinutes: 40, not 50 — this
      // test locks in that WorkTimeCalculator's input is the unpaid
      // amount alone, matching decisions/0005.
      final withUnpaidOnly = WorkTimeCalculator.calculateWorkedMinutes(
        startMinutes: 7 * 60,
        endMinutes: 16 * 60 + 30,
        breakMinutes: 40,
      );
      // Raw duration is 570 minutes (07:00-16:30); wrongly including the
      // paid 10-minute rest break would deduct 50 instead of 40.
      final ifPaidBreakWereWronglyIncluded =
          WorkTimeCalculator.calculateWorkedMinutes(
            startMinutes: 7 * 60,
            endMinutes: 16 * 60 + 30,
            breakMinutes: 50,
          );
      expect(withUnpaidOnly, 530);
      expect(ifPaidBreakWereWronglyIncluded, 520);
      expect(withUnpaidOnly, isNot(ifPaidBreakWereWronglyIncluded));
    });
  });

  group('spec examples (09:00-17:00 family)', () {
    test('09:00-17:00, no break -> 8 hours', () {
      final hours = WorkTimeCalculator.calculateWorkedHours(
        startMinutes: 9 * 60,
        endMinutes: 17 * 60,
        breakMinutes: 0,
      );
      expect(hours, 8.0);
    });

    test('09:00-17:00, 30 min break -> 7.5 hours', () {
      final hours = WorkTimeCalculator.calculateWorkedHours(
        startMinutes: 9 * 60,
        endMinutes: 17 * 60,
        breakMinutes: 30,
      );
      expect(hours, 7.5);
    });

    test('09:00-17:00, 60 min break -> 7 hours', () {
      final hours = WorkTimeCalculator.calculateWorkedHours(
        startMinutes: 9 * 60,
        endMinutes: 17 * 60,
        breakMinutes: 60,
      );
      expect(hours, 7.0);
    });

    test('11:00-20:30, no break -> 9.5 hours', () {
      final hours = WorkTimeCalculator.calculateWorkedHours(
        startMinutes: 11 * 60,
        endMinutes: 20 * 60 + 30,
        breakMinutes: 0,
      );
      expect(hours, 9.5);
    });

    test(
      'break exactly equal to the shift duration -> zero hours, not negative',
      () {
        final hours = WorkTimeCalculator.calculateWorkedHours(
          startMinutes: 9 * 60,
          endMinutes: 17 * 60, // 480 minutes raw
          breakMinutes: 480,
        );
        expect(hours, 0.0);
      },
    );

    test(
      'break far exceeding the shift duration -> zero hours, not negative',
      () {
        final hours = WorkTimeCalculator.calculateWorkedHours(
          startMinutes: 9 * 60,
          endMinutes: 17 * 60,
          breakMinutes: 600,
        );
        expect(hours, 0.0);
      },
    );
  });

  group('minute-level boundaries', () {
    test('a one-minute shift (09:00-09:01) calculates correctly', () {
      final minutes = WorkTimeCalculator.calculateWorkedMinutes(
        startMinutes: 9 * 60,
        endMinutes: 9 * 60 + 1,
        breakMinutes: 0,
      );
      expect(minutes, 1);
    });

    test('a two-minute overnight shift (23:59-00:01) calculates correctly', () {
      final minutes = WorkTimeCalculator.calculateWorkedMinutes(
        startMinutes: 23 * 60 + 59,
        endMinutes: 1,
        breakMinutes: 0,
      );
      expect(minutes, 2);
      expect(WorkTimeCalculator.isOvernight(23 * 60 + 59, 1), isTrue);
    });
  });
}
