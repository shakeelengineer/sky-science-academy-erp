import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/academy_calculations.dart';
import '../../widgets/section_title.dart';
import '../app_state.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key, required this.onNavigate});
  final ValueChanged<int> onNavigate;
  @override
  Widget build(BuildContext context) {
    final s = context.watch<AcademyState>();
    final now = DateTime.now();
    final date = '${_weekday(now.weekday)}, ${now.day} ${_month(now.month)}';
    return PagePad(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Assalam-o-Alaikum',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -.6,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      date,
                      style: const TextStyle(
                        color: AcademyColors.muted,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 42,
                height: 42,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AcademyColors.purple, AcademyColors.deepPurple],
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text(
                    'AD',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1.55,
            children: [
              _StatCard(
                title: 'Active Students',
                value: '${s.stats['students'] ?? 0}',
                hint: 'Across ${s.stats['classes'] ?? 0} classes',
                icon: Icons.groups_rounded,
                color: AcademyColors.purple,
              ),
              _StatCard(
                title: 'Attendance Today',
                value: s.stats['students'] == 0
                    ? '—'
                    : '${attendancePercentage(present: s.stats['present'] as int? ?? 0, enrolled: s.stats['students'] as int).round()}%',
                hint: '${s.stats['present'] ?? 0} present',
                icon: Icons.fact_check_rounded,
                color: AcademyColors.green,
              ),
              _StatCard(
                title: 'Fee Due (${_month(now.month).substring(0, 3)})',
                value: money(s.stats['pending']),
                hint: 'Outstanding balance',
                icon: Icons.payments_rounded,
                color: AcademyColors.amber,
              ),
              _StatCard(
                title: 'Staff Members',
                value: '${s.stats['staff'] ?? 0}',
                hint: 'Teaching + admin',
                icon: Icons.badge_rounded,
                color: AcademyColors.deepPurple,
              ),
            ],
          ),
          const SizedBox(height: 24),
          const SectionTitle('QUICK ACTIONS'),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _ActionChip(
                Icons.person_add_alt_1_rounded,
                'New admission',
                () => _select(context, 2),
              ),
              _ActionChip(
                Icons.fact_check_rounded,
                'Mark attendance',
                () => _select(context, 1),
              ),
              _ActionChip(
                Icons.wallet_rounded,
                'Receive fee',
                () => _select(context, 3),
              ),
              _ActionChip(
                Icons.campaign_rounded,
                'Send notice',
                () => _select(context, 4),
              ),
            ],
          ),
          const SizedBox(height: 25),
          SectionTitle(
            'Today’s attendance',
            trailing: TextButton(
              onPressed: () => _select(context, 1),
              child: const Text('Open'),
            ),
          ),
          if (s.studentsList.isEmpty)
            const _InfoCard(
              icon: Icons.event_available_rounded,
              title: 'Attendance starts here',
              text: 'Add students to begin taking daily attendance.',
            )
          else
            _AttendanceSummary(
              present: s.stats['present'] as int? ?? 0,
              total: s.stats['students'] as int? ?? 0,
              absent: s.stats['absent'] as int? ?? 0,
            ),
          const SizedBox(height: 23),
          const SectionTitle('Latest notices'),
          if (s.noticesList.isEmpty)
            const _InfoCard(
              icon: Icons.campaign_outlined,
              title: 'No notices yet',
              text: 'Academy announcements will appear here.',
            )
          else
            ...s.noticesList
                .take(2)
                .map(
                  (n) => Container(
                    margin: const EdgeInsets.only(bottom: 9),
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFFEDEAF1)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          n.title,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          n.body,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AcademyColors.muted,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  void _select(BuildContext c, int i) => onNavigate(i);
  String _weekday(int w) => [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ][w - 1];
  String _month(int m) => [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ][m - 1];
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.title,
    required this.value,
    required this.hint,
    required this.icon,
    required this.color,
  });
  final String title, value, hint;
  final IconData icon;
  final Color color;
  @override
  Widget build(BuildContext c) => Container(
    padding: const EdgeInsets.all(13),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: const Color(0xFFEDEAF1)),
      boxShadow: [
        BoxShadow(
          color: AcademyColors.deepPurple.withValues(alpha: .035),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 11,
                  color: AcademyColors.muted,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(icon, size: 17, color: color.withValues(alpha: .8)),
          ],
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontSize: value.length > 10 ? 17 : 22,
            fontWeight: FontWeight.w800,
            color: color,
            letterSpacing: -.6,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          hint,
          style: const TextStyle(fontSize: 10, color: AcademyColors.muted),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    ),
  );
}

class _ActionChip extends StatelessWidget {
  const _ActionChip(this.icon, this.label, this.onTap);
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext c) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(15),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFFEDEAF1)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AcademyColors.purple, size: 17),
          const SizedBox(width: 7),
          Text(
            label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    ),
  );
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.icon,
    required this.title,
    required this.text,
  });
  final IconData icon;
  final String title, text;
  @override
  Widget build(BuildContext c) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(15),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: const Color(0xFFEDEAF1)),
    ),
    child: Row(
      children: [
        Icon(icon, color: AcademyColors.purple),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                text,
                style: const TextStyle(
                  color: AcademyColors.muted,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _AttendanceSummary extends StatelessWidget {
  const _AttendanceSummary({
    required this.present,
    required this.total,
    required this.absent,
  });
  final int present, total, absent;
  @override
  Widget build(BuildContext c) {
    final p = total == 0 ? 0.0 : present / total;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFEDEAF1)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.groups_rounded, color: AcademyColors.purple),
              const SizedBox(width: 9),
              const Expanded(
                child: Text(
                  'Academy wide',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              Text(
                '${(p * 100).round()}%',
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  color: AcademyColors.purple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: p,
              minHeight: 7,
              backgroundColor: AcademyColors.lilac,
              color: AcademyColors.purple,
            ),
          ),
          const SizedBox(height: 9),
          Row(
            children: [
              Text(
                '$present present',
                style: const TextStyle(
                  color: AcademyColors.green,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                '$absent absent  ·  ${total - present - absent} unmarked',
                style: const TextStyle(
                  color: AcademyColors.muted,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
