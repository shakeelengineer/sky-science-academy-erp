import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../models/student.dart';
import '../../widgets/section_title.dart';
import '../app_state.dart';

const grades = ['6th', '7th', '8th', '9th', '10th'];

class StudentsScreen extends StatefulWidget {
  const StudentsScreen({super.key});
  @override
  State<StudentsScreen> createState() => _StudentsScreenState();
}

class _StudentsScreenState extends State<StudentsScreen> {
  final search = TextEditingController();
  @override
  void dispose() {
    search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AcademyState>();
    return PagePad(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionTitle(
            'Students',
            subtitle: '${state.stats['students'] ?? 0} enrolled',
            trailing: FilledButton.icon(
              onPressed: () => _form(context),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add'),
            ),
          ),
          const SectionTitle(
            'Student records',
            subtitle: 'Profiles, results and fee history.',
          ),
          TextField(
            controller: search,
            onChanged: state.filterStudents,
            decoration: const InputDecoration(
              hintText: 'Search name, guardian or ID',
              prefixIcon: Icon(Icons.search_rounded),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 7,
            children: ['All classes', ...grades]
                .map(
                  (g) => ChoiceChip(
                    label: Text(g),
                    selected: state.selectedGrade == g,
                    onSelected: (_) => state.selectGrade(g),
                    labelStyle: TextStyle(
                      fontSize: 11,
                      color: state.selectedGrade == g
                          ? Colors.white
                          : AcademyColors.ink,
                    ),
                    selectedColor: AcademyColors.purple,
                    showCheckmark: false,
                    backgroundColor: Colors.white,
                    side: const BorderSide(color: Color(0xFFEAE6EF)),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 14),
          if (state.studentsList.isEmpty)
            EmptyState(
              icon: Icons.school_outlined,
              title: 'No students found',
              message: search.text.isEmpty
                  ? 'Add your first student to start managing classes and attendance.'
                  : 'Try another name or admission ID.',
              action: FilledButton.icon(
                onPressed: () => _form(context),
                icon: const Icon(Icons.person_add_alt_1),
                label: const Text('Add student'),
              ),
            )
          else
            ...state.studentsList.map(
              (s) =>
                  _StudentTile(student: s, onTap: () => _profile(context, s)),
            ),
        ],
      ),
    );
  }

  Future<void> _form(BuildContext context, {Student? student}) async {
    final name = TextEditingController(text: student?.name ?? ''),
        guardian = TextEditingController(text: student?.guardian ?? ''),
        phone = TextEditingController(text: student?.phone ?? ''),
        admission = TextEditingController(text: student?.admissionNo ?? ''),
        roll = TextEditingController(text: student?.rollNo ?? ''),
        fee = TextEditingController(
          text: student?.monthlyFee.toString() ?? '0',
        );
    String grade = student?.grade ?? grades.first;
    final form = GlobalKey<FormState>();
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _ControllerOwner(
        controllers: [name, guardian, phone, admission, roll, fee],
        child: StatefulBuilder(
          builder: (ctx, setSheet) => Container(
            padding: EdgeInsets.fromLTRB(
              20,
              14,
              20,
              MediaQuery.of(ctx).viewInsets.bottom + 20,
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
            ),
            child: SingleChildScrollView(
              child: Form(
                key: form,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Center(
                      child: Container(
                        width: 38,
                        height: 4,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE2DDE8),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      student == null ? 'New admission' : 'Edit student',
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 17),
                    _field(name, 'Student full name', required: true),
                    const SizedBox(height: 11),
                    _field(guardian, 'Father / guardian name', required: true),
                    const SizedBox(height: 11),
                    _field(
                      phone,
                      'Contact number',
                      keyboard: TextInputType.phone,
                    ),
                    const SizedBox(height: 11),
                    Row(
                      children: [
                        Expanded(
                          child: _field(
                            admission,
                            'Admission no.',
                            required: true,
                          ),
                        ),
                        const SizedBox(width: 9),
                        Expanded(child: _field(roll, 'Roll no.')),
                      ],
                    ),
                    const SizedBox(height: 11),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: grade,
                            decoration: const InputDecoration(
                              labelText: 'Class',
                            ),
                            items: grades
                                .map(
                                  (g) => DropdownMenuItem(
                                    value: g,
                                    child: Text(g),
                                  ),
                                )
                                .toList(),
                            onChanged: (v) {
                              if (v != null) setSheet(() => grade = v);
                            },
                          ),
                        ),
                        const SizedBox(width: 9),
                        Expanded(
                          child: _field(
                            fee,
                            'Monthly fee (Rs)',
                            keyboard: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: FilledButton(
                        onPressed: () {
                          if (!(form.currentState?.validate() ?? false)) return;
                          final st = Student(
                            id: student?.id,
                            admissionNo: admission.text.trim(),
                            name: name.text.trim(),
                            guardian: guardian.text.trim(),
                            phone: phone.text.trim(),
                            grade: grade,
                            section: student?.section ?? 'A',
                            rollNo: roll.text.trim().isEmpty
                                ? DateTime.now().millisecondsSinceEpoch
                                      .toString()
                                      .substring(8)
                                : roll.text.trim(),
                            monthlyFee: int.tryParse(fee.text) ?? 0,
                            admissionDate:
                                student?.admissionDate ??
                                DateTime.now().toIso8601String().substring(
                                  0,
                                  10,
                                ),
                            status: 'Active',
                          );
                          final state = context.read<AcademyState>();
                          final action = student == null
                              ? state.addStudent(st)
                              : state.updateStudent(st);
                          action
                              .then((_) {
                                if (ctx.mounted) Navigator.pop(ctx);
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        student == null
                                            ? 'Student added'
                                            : 'Student updated',
                                      ),
                                    ),
                                  );
                                }
                              })
                              .catchError((e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Could not save the student. Check the admission number and try again.',
                                      ),
                                    ),
                                  );
                                }
                              });
                        },
                        child: Text(
                          student == null ? 'Save student' : 'Save changes',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController c,
    String label, {
    bool required = false,
    TextInputType? keyboard,
  }) => TextFormField(
    controller: c,
    keyboardType: keyboard,
    decoration: InputDecoration(labelText: label),
    validator: (v) =>
        required && (v == null || v.trim().isEmpty) ? 'Required' : null,
  );
  void _profile(BuildContext context, Student s) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: AcademyColors.lilac,
                  child: Text(
                    _initials(s.name),
                    style: const TextStyle(
                      color: AcademyColors.purple,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        s.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
                        ),
                      ),
                      Text(
                        'Class ${s.grade}  •  Roll ${s.rollNo}',
                        style: const TextStyle(
                          color: AcademyColors.muted,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => _form(context, student: s),
                  icon: const Icon(Icons.edit_outlined),
                ),
              ],
            ),
            const Divider(height: 25),
            _detail('Admission number', s.admissionNo),
            _detail('Father / guardian', s.guardian),
            _detail('Contact', s.phone.isEmpty ? 'Not provided' : s.phone),
            _detail('Monthly fee', 'Rs ${s.monthlyFee}'),
            _detail('Admission date', s.admissionDate),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: () async {
                final ok = await showDialog<bool>(
                  context: ctx,
                  builder: (d) => AlertDialog(
                    title: const Text('Archive student?'),
                    content: Text(
                      '${s.name} will be removed from active lists. Historical records will remain.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(d, false),
                        child: const Text('Cancel'),
                      ),
                      FilledButton(
                        onPressed: () => Navigator.pop(d, true),
                        child: const Text('Archive'),
                      ),
                    ],
                  ),
                );
                if (ok == true && ctx.mounted) {
                  try {
                    await context.read<AcademyState>().archiveStudent(s);
                    if (ctx.mounted) Navigator.pop(ctx);
                  } catch (_) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Could not archive the student.'),
                        ),
                      );
                    }
                  }
                }
              },
              icon: const Icon(
                Icons.archive_outlined,
                color: AcademyColors.red,
              ),
              label: const Text(
                'Archive student',
                style: TextStyle(color: AcademyColors.red),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detail(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(color: AcademyColors.muted, fontSize: 12),
          ),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        ),
      ],
    ),
  );
  String _initials(String s) => s
      .trim()
      .split(RegExp(r'\s+'))
      .take(2)
      .map((w) => w.isEmpty ? '' : w[0])
      .join()
      .toUpperCase();
}

/// Keeps form controllers alive through the bottom sheet's reverse transition.
class _ControllerOwner extends StatefulWidget {
  const _ControllerOwner({required this.controllers, required this.child});

  final List<TextEditingController> controllers;
  final Widget child;

  @override
  State<_ControllerOwner> createState() => _ControllerOwnerState();
}

class _ControllerOwnerState extends State<_ControllerOwner> {
  @override
  Widget build(BuildContext context) => widget.child;

  @override
  void dispose() {
    for (final controller in widget.controllers) {
      controller.dispose();
    }
    super.dispose();
  }
}

class _StudentTile extends StatelessWidget {
  const _StudentTile({required this.student, required this.onTap});
  final Student student;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final initials = student.name
        .trim()
        .split(RegExp(r'\s+'))
        .take(2)
        .map((e) => e.isEmpty ? '' : e[0])
        .join()
        .toUpperCase();
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(17),
      child: Container(
        margin: const EdgeInsets.only(bottom: 9),
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(17),
          border: Border.all(color: const Color(0xFFEDEAF1)),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 21,
              backgroundColor: AcademyColors.lilac,
              child: Text(
                initials,
                style: const TextStyle(
                  color: AcademyColors.purple,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    student.name,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Class ${student.grade}  •  Roll ${student.rollNo}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AcademyColors.muted,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AcademyColors.muted),
          ],
        ),
      ),
    );
  }
}
