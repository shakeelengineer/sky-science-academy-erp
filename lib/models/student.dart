class Student {
  const Student({
    required this.id,
    required this.admissionNo,
    required this.name,
    required this.guardian,
    required this.phone,
    required this.grade,
    required this.section,
    required this.rollNo,
    required this.monthlyFee,
    required this.admissionDate,
    required this.status,
  });
  final int? id;
  final String admissionNo,
      name,
      guardian,
      phone,
      grade,
      section,
      rollNo,
      admissionDate,
      status;
  final int monthlyFee;
  factory Student.fromMap(Map<String, Object?> m) => Student(
    id: m['id'] as int?,
    admissionNo: m['admission_no'] as String,
    name: m['name'] as String,
    guardian: m['guardian'] as String,
    phone: m['phone'] as String,
    grade: m['grade'] as String,
    section: m['section'] as String,
    rollNo: m['roll_no'] as String,
    monthlyFee: m['monthly_fee'] as int,
    admissionDate: m['admission_date'] as String,
    status: m['status'] as String,
  );
  Map<String, Object?> toMap() => {
    'id': id,
    'admission_no': admissionNo,
    'name': name,
    'guardian': guardian,
    'phone': phone,
    'grade': grade,
    'section': section,
    'roll_no': rollNo,
    'monthly_fee': monthlyFee,
    'admission_date': admissionDate,
    'status': status,
  };
}
