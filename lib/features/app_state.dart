import 'package:flutter/foundation.dart';
import '../database/database_helper.dart';
import '../models/student.dart';
import '../models/academy_notice.dart';

class AcademyState extends ChangeNotifier {
  AcademyState(this.db);
  final DatabaseHelper db;
  List<Student> studentsList = [];
  List<Map<String, Object?>> attendanceList = [], fees = [];
  List<AcademyNotice> noticesList = [];
  List<Map<String, Object?>> recent = [];
  Map<String, Object?> stats = {};
  bool loading = true;
  String selectedGrade = 'All classes';
  String get today => DateTime.now().toIso8601String().substring(0, 10);
  String get month => today.substring(0, 7);
  Future<void> load() async {
    loading = true;
    notifyListeners();
    await refresh();
    loading = false;
    notifyListeners();
  }

  Future<void> refresh() async {
    stats = await db.dashboard();
    studentsList = await db.students(grade: selectedGrade);
    attendanceList = await db.attendance(today);
    fees = await db.feeRows(month);
    noticesList = await db.notices();
    recent = await db.activities();
    notifyListeners();
  }

  Future<void> filterStudents(String q) async {
    studentsList = await db.students(query: q, grade: selectedGrade);
    notifyListeners();
  }

  Future<void> selectGrade(String grade) async {
    selectedGrade = grade;
    studentsList = await db.students(grade: grade);
    notifyListeners();
  }

  Future<void> addStudent(Student s) async {
    await db.saveStudent(s);
    await refresh();
  }

  Future<void> updateStudent(Student s) async {
    await db.updateStudent(s);
    await refresh();
  }

  Future<void> archiveStudent(Student s) async {
    await db.archiveStudent(s);
    await refresh();
  }

  Future<void> mark(int id, String status) async {
    await db.markAttendance(id, today, status);
    attendanceList = await db.attendance(today);
    stats = await db.dashboard();
    notifyListeners();
  }

  Future<void> markAll(String status) async {
    for (final row in attendanceList) {
      await db.markAttendance(row['id'] as int, today, status);
    }
    await refresh();
  }

  Future<void> pay(int id, int amount) async {
    await db.recordPayment(id, amount, month);
    await refresh();
  }

  Future<void> addNotice(AcademyNotice n) async {
    await db.addNotice(n);
    await refresh();
  }

  Future<void> deleteNotice(int id) async {
    await db.deleteNotice(id);
    await refresh();
  }
}
