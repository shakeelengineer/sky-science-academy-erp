import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/section_title.dart';
import '../app_state.dart';
import '../students/students_screen.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});
  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  String grade = grades.first;
  @override
  Widget build(BuildContext context) {
    final state = context.watch<AcademyState>();
    final rows = state.attendanceList
        .where((r) => r['grade'] == grade)
        .toList();
    final marked = rows
        .where((r) => r['attendance_status'] != 'Unmarked')
        .length;
    int count(String value) =>
        rows.where((r) => r['attendance_status'] == value).length;
    return PagePad(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionTitle(
            'Attendance',
            subtitle:
                'Today • ${DateTime.now().day} ${_month(DateTime.now().month)} ${DateTime.now().year}',
            trailing: TextButton.icon(
              onPressed: rows.isEmpty
                  ? null
                  : () async {
                      try {
                        await state.markAll('Present');
                      } catch (_) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Could not save attendance.'),
                            ),
                          );
                        }
                      }
                    },
              icon: const Icon(Icons.done_all_rounded, size: 17),
              label: const Text('All present'),
            ),
          ),
          const SectionTitle(
            'Daily attendance',
            subtitle: 'Tap a status for each student. Saved on this device.',
          ),
          Wrap(
            spacing: 8,
            children: grades
                .map(
                  (g) => ChoiceChip(
                    label: Text('Class $g'),
                    selected: g == grade,
                    onSelected: (_) => setState(() => grade = g),
                    selectedColor: AcademyColors.purple,
                    backgroundColor: Colors.white,
                    showCheckmark: false,
                    labelStyle: TextStyle(
                      color: g == grade ? Colors.white : AcademyColors.ink,
                      fontSize: 12,
                    ),
                    side: const BorderSide(color: Color(0xFFEAE6EF)),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AcademyColors.lilac,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                _count('P', count('Present'), AcademyColors.green),
                _count('A', count('Absent'), AcademyColors.red),
                _count('L', count('Late'), AcademyColors.amber),
                const Spacer(),
                Text(
                  '$marked / ${rows.length} marked',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AcademyColors.muted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          if (rows.isEmpty)
            const EmptyState(
              icon: Icons.fact_check_outlined,
              title: 'No students in this class',
              message: 'Add student records to take attendance.',
            )
          else
            ...rows.map(
              (r) => _AttendanceRow(
                row: r,
                onMark: (value) async {
                  try {
                    await state.mark(r['id'] as int, value);
                  } catch (_) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Could not save attendance.'),
                        ),
                      );
                    }
                  }
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _count(String label, int value, Color color) => Padding(
    padding: const EdgeInsets.only(right: 15),
    child: Row(
      children: [
        Text(
          label,
          style: TextStyle(color: color, fontWeight: FontWeight.w800),
        ),
        const SizedBox(width: 4),
        Text('$value', style: const TextStyle(fontWeight: FontWeight.w700)),
      ],
    ),
  );
  String _month(int m) => [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ][m - 1];
}

class _AttendanceRow extends StatelessWidget {
  const _AttendanceRow({required this.row, required this.onMark});
  final Map<String, Object?> row;
  final ValueChanged<String> onMark;
  @override
  Widget build(BuildContext context) {
    final status = row['attendance_status'] as String;
    const colors = {
      'Present': AcademyColors.green,
      'Absent': AcademyColors.red,
      'Late': AcademyColors.amber,
      'Leave': AcademyColors.purple,
    };
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: const Color(0xFFEDEAF1)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 17,
                backgroundColor: AcademyColors.lilac,
                child: Text(
                  '${row['roll_no']}',
                  style: const TextStyle(
                    fontSize: 10,
                    color: AcademyColors.purple,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${row['name']}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'Roll ${row['roll_no']}',
                      style: const TextStyle(
                        fontSize: 10,
                        color: AcademyColors.muted,
                      ),
                    ),
                  ],
                ),
              ),
              if (status != 'Unmarked')
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: colors[status]!.withValues(alpha: .1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      color: colors[status],
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: ['Present', 'Absent', 'Late', 'Leave']
                .map(
                  (value) => Expanded(
                    child: _statusButton(value, status, colors[value]!),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _statusButton(String value, String status, Color color) {
    final selected = status == value;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: InkWell(
        onTap: () => onMark(value),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: selected
                ? color.withValues(alpha: .12)
                : const Color(0xFFF7F5F9),
            borderRadius: BorderRadius.circular(10),
            border: selected
                ? Border.all(color: color.withValues(alpha: .2))
                : null,
          ),
          child: Center(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 10,
                color: selected ? color : AcademyColors.muted,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
