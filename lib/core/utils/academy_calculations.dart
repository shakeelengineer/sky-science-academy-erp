/// Returns the unpaid portion of a monthly fee without allowing negatives.
int outstandingFee(int billed, int paid) => (billed - paid).clamp(0, 1 << 30);

/// Attendance percentage is zero when no learners have been enrolled.
double attendancePercentage({required int present, required int enrolled}) =>
    enrolled <= 0 ? 0 : (present.clamp(0, enrolled) * 100 / enrolled);

/// A partial fee payment is valid only when it is positive and within the due.
bool isValidFeePayment({required int amount, required int due}) =>
    amount > 0 && amount <= due;
