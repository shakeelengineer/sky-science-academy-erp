import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import '../models/student.dart';
import '../models/academy_notice.dart';

class DatabaseHelper {
  DatabaseHelper._();
  static final instance = DatabaseHelper._();
  Database? _database;
  Future<Database> get database async => _database ??= await _open();

  Future<Database> _open() async {
    final base = await getDatabasesPath();
    return openDatabase(
      p.join(base, 'sky_academy.db'),
      version: 1,
      onConfigure: (db) async => db.execute('PRAGMA foreign_keys = ON'),
      onCreate: (db, version) async {
        await db.execute(
          '''CREATE TABLE students(id INTEGER PRIMARY KEY AUTOINCREMENT, admission_no TEXT NOT NULL UNIQUE, name TEXT NOT NULL,
        guardian TEXT NOT NULL, phone TEXT NOT NULL, grade TEXT NOT NULL, section TEXT NOT NULL, roll_no TEXT NOT NULL,
        monthly_fee INTEGER NOT NULL DEFAULT 0, admission_date TEXT NOT NULL, status TEXT NOT NULL DEFAULT 'Active')''',
        );
        await db.execute(
          'CREATE INDEX idx_students_grade ON students(grade, section)',
        );
        await db.execute('CREATE INDEX idx_students_name ON students(name)');
        await db.execute(
          '''CREATE TABLE attendance(id INTEGER PRIMARY KEY AUTOINCREMENT, student_id INTEGER NOT NULL REFERENCES students(id) ON DELETE CASCADE,
        day TEXT NOT NULL, status TEXT NOT NULL, UNIQUE(student_id,day))''',
        );
        await db.execute(
          '''CREATE TABLE payments(id INTEGER PRIMARY KEY AUTOINCREMENT, student_id INTEGER NOT NULL REFERENCES students(id),
        amount INTEGER NOT NULL, paid_at TEXT NOT NULL, month TEXT NOT NULL, reference TEXT NOT NULL UNIQUE, note TEXT NOT NULL DEFAULT '')''',
        );
        await db.execute('CREATE INDEX idx_payments_month ON payments(month)');
        await db.execute(
          '''CREATE TABLE notices(id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT NOT NULL, body TEXT NOT NULL, date TEXT NOT NULL, important INTEGER NOT NULL DEFAULT 0)''',
        );
        await db.execute(
          '''CREATE TABLE staff(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL, designation TEXT NOT NULL, phone TEXT NOT NULL, status TEXT NOT NULL DEFAULT 'Active')''',
        );
        await db.execute(
          '''CREATE TABLE classes(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL UNIQUE, section TEXT NOT NULL DEFAULT 'A')''',
        );
        await db.execute(
          '''CREATE TABLE activities(id INTEGER PRIMARY KEY AUTOINCREMENT, label TEXT NOT NULL, created_at TEXT NOT NULL)''',
        );
      },
    );
  }

  Future<List<Student>> students({
    String query = '',
    String grade = 'All classes',
  }) async {
    final db = await database;
    final args = <Object>[];
    final where = <String>["status = 'Active'"];
    if (query.trim().isNotEmpty) {
      where.add('(name LIKE ? OR admission_no LIKE ? OR guardian LIKE ?)');
      final q = '%${query.trim()}%';
      args.addAll([q, q, q]);
    }
    if (grade != 'All classes') {
      where.add('grade = ?');
      args.add(grade);
    }
    final rows = await db.query(
      'students',
      where: where.join(' AND '),
      whereArgs: args,
      orderBy: 'name COLLATE NOCASE',
    );
    return rows.map(Student.fromMap).toList();
  }

  Future<int> saveStudent(Student s) async {
    final db = await database;
    return db.transaction((txn) async {
      final id = await txn.insert(
        'students',
        s.toMap(),
        conflictAlgorithm: ConflictAlgorithm.abort,
      );
      await txn.insert('activities', {
        'label': '${s.name} added as a student',
        'created_at': DateTime.now().toIso8601String(),
      });
      return id;
    });
  }

  Future<void> updateStudent(Student s) async {
    await (await database).update(
      'students',
      s.toMap(),
      where: 'id=?',
      whereArgs: [s.id],
    );
  }

  Future<void> archiveStudent(Student s) async {
    await (await database).update(
      'students',
      {'status': 'Archived'},
      where: 'id=?',
      whereArgs: [s.id],
    );
  }

  Future<List<Map<String, Object?>>> attendance(
    String day, {
    String? grade,
  }) async {
    final db = await database;
    final args = <Object?>[day];
    final condition = grade == null ? '' : ' AND s.grade = ?';
    if (grade != null) args.add(grade);
    return db.rawQuery(
      '''SELECT s.*, COALESCE(a.status,'Unmarked') AS attendance_status FROM students s LEFT JOIN attendance a ON a.student_id=s.id AND a.day=? WHERE s.status='Active'$condition ORDER BY s.grade,s.roll_no''',
      args,
    );
  }

  Future<void> markAttendance(int studentId, String day, String status) async =>
      (await database).insert('attendance', {
        'student_id': studentId,
        'day': day,
        'status': status,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
  Future<int> recordPayment(int studentId, int amount, String month) async {
    final db = await database;
    return db.transaction((txn) async {
      final ref = 'SKY-${DateTime.now().microsecondsSinceEpoch}';
      final id = await txn.insert('payments', {
        'student_id': studentId,
        'amount': amount,
        'paid_at': DateTime.now().toIso8601String(),
        'month': month,
        'reference': ref,
      });
      final row = await txn.query(
        'students',
        columns: ['name'],
        where: 'id=?',
        whereArgs: [studentId],
        limit: 1,
      );
      await txn.insert('activities', {
        'label': 'Fee payment recorded for ${row.first['name']}',
        'created_at': DateTime.now().toIso8601String(),
      });
      return id;
    });
  }

  Future<List<Map<String, Object?>>> feeRows(String month) async =>
      (await database).rawQuery(
        '''SELECT s.id,s.name,s.grade,s.roll_no,s.monthly_fee,
    COALESCE((SELECT SUM(p.amount) FROM payments p WHERE p.student_id=s.id AND p.month=?),0) AS paid FROM students s WHERE s.status='Active' ORDER BY s.grade,s.name''',
        [month],
      );
  Future<List<AcademyNotice>> notices() async => (await (await database).query(
    'notices',
    orderBy: 'important DESC,date DESC',
  )).map(AcademyNotice.fromMap).toList();
  Future<int> addNotice(AcademyNotice n) async =>
      (await database).insert('notices', n.toMap());
  Future<void> deleteNotice(int id) async =>
      (await database).delete('notices', where: 'id=?', whereArgs: [id]);
  Future<Map<String, Object?>> dashboard() async {
    final db = await database;
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final month = today.substring(0, 7);
    final students =
        (Sqflite.firstIntValue(
          await db.rawQuery(
            "SELECT COUNT(*) FROM students WHERE status='Active'",
          ),
        ) ??
        0);
    final classes =
        Sqflite.firstIntValue(
          await db.rawQuery(
            "SELECT COUNT(DISTINCT grade) FROM students WHERE status='Active'",
          ),
        ) ??
        0;
    final staff =
        Sqflite.firstIntValue(
          await db.rawQuery("SELECT COUNT(*) FROM staff WHERE status='Active'"),
        ) ??
        0;
    final present =
        Sqflite.firstIntValue(
          await db.rawQuery(
            "SELECT COUNT(*) FROM attendance WHERE day=? AND status='Present'",
            [today],
          ),
        ) ??
        0;
    final collected =
        Sqflite.firstIntValue(
          await db.rawQuery(
            'SELECT COALESCE(SUM(amount),0) FROM payments WHERE month=?',
            [month],
          ),
        ) ??
        0;
    final billed =
        Sqflite.firstIntValue(
          await db.rawQuery(
            "SELECT COALESCE(SUM(monthly_fee),0) FROM students WHERE status='Active'",
          ),
        ) ??
        0;
    final absent =
        Sqflite.firstIntValue(
          await db.rawQuery(
            "SELECT COUNT(*) FROM attendance WHERE day=? AND status='Absent'",
            [today],
          ),
        ) ??
        0;
    return {
      'students': students,
      'classes': classes,
      'staff': staff,
      'present': present,
      'absent': absent,
      'collected': collected,
      'pending': (billed - collected).clamp(0, 1 << 30),
    };
  }

  Future<List<Map<String, Object?>>> activities() async =>
      (await (await database).query(
        'activities',
        orderBy: 'id DESC',
        limit: 6,
      ));
}
