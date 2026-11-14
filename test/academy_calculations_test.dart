import 'package:flutter_test/flutter_test.dart';
import 'package:sky_science_academy_erp/core/utils/academy_calculations.dart';

void main() {
  group('fee calculations', () {
    test('keeps partial balances outstanding', () {
      expect(outstandingFee(2500, 1000), 1500);
    });

    test('does not create a negative balance after overpayment', () {
      expect(outstandingFee(2500, 3000), 0);
    });

    test('accepts only positive payments up to the due', () {
      expect(isValidFeePayment(amount: 1, due: 2500), isTrue);
      expect(isValidFeePayment(amount: 2501, due: 2500), isFalse);
      expect(isValidFeePayment(amount: 0, due: 2500), isFalse);
    });
  });

  group('attendance calculations', () {
    test('returns zero for an empty academy', () {
      expect(attendancePercentage(present: 0, enrolled: 0), 0);
    });

    test('caps attendance at enrolled learners', () {
      expect(attendancePercentage(present: 12, enrolled: 10), 100);
    });
  });
}
