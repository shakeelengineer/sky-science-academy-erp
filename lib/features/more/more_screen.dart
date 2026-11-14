import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../models/academy_notice.dart';
import '../../widgets/section_title.dart';
import '../app_state.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final s = context.watch<AcademyState>();
    return PagePad(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle(
            'More',
            subtitle: 'Academy tools and announcements',
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AcademyColors.purple, AcademyColors.deepPurple],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              children: [
                CircleAvatar(
                  backgroundColor: Color(0x38FFFFFF),
                  foregroundImage: AssetImage('assets/skypro_logo.png'),
                ),
                SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'SkyPro',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 3),
                      Text(
                        'Mandi Shah Jewana',
                        style: TextStyle(
                          color: Color(0xFFD9C8ED),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.verified_user_outlined, color: Colors.white70),
              ],
            ),
          ),
          const SizedBox(height: 22),
          const SectionTitle('Academy operations'),
          _ToolCard(
            icon: Icons.campaign_outlined,
            title: 'Notices & announcements',
            subtitle: '${s.noticesList.length} active notices',
            onTap: () => _notice(context),
          ),
          _ToolCard(
            icon: Icons.groups_2_outlined,
            title: 'Staff directory',
            subtitle: '${s.stats['staff'] ?? 0} active staff members',
            onTap: () => _info(
              context,
              'Staff directory',
              'Staff profile management is queued for the next build.',
            ),
          ),
          _ToolCard(
            icon: Icons.class_outlined,
            title: 'Classes & sections',
            subtitle: '${s.stats['classes'] ?? 0} classes in student records',
            onTap: () => _info(
              context,
              'Classes & sections',
              'Class lists are currently derived from student enrolments. Dedicated subject and teacher assignments are planned.',
            ),
          ),
          const SizedBox(height: 20),
          const SectionTitle('Data & support'),
          _ToolCard(
            icon: Icons.backup_outlined,
            title: 'Local data & backup',
            subtitle: 'Stored on this device • Offline ready',
            onTap: () => _info(
              context,
              'Local data & backup',
              'This first native build stores students, attendance, fees, notices and activity on this device using SQLite. Export and restore tools are not yet available.',
            ),
          ),
          _ToolCard(
            icon: Icons.info_outline_rounded,
            title: 'About this app',
            subtitle: 'Sky Science Academy ERP • v1.0.0',
            onTap: () => _info(
              context,
              'About',
              'A native offline app that follows the Sky Science Academy reference design. Designed for the academy’s primary device.',
            ),
          ),
          const SizedBox(height: 15),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AcademyColors.lilac,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.wifi_off_rounded,
                  color: AcademyColors.purple,
                  size: 18,
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Your records stay on this device. Create regular backups when backup export becomes available.',
                    style: TextStyle(
                      color: AcademyColors.deepPurple,
                      fontSize: 11,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _info(BuildContext c, String title, String body) => showDialog<void>(
    context: c,
    builder: (ctx) => AlertDialog(
      title: Text(title),
      content: Text(body),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Close'),
        ),
      ],
    ),
  );
  Future<void> _notice(BuildContext context) async {
    final title = TextEditingController();
    final body = TextEditingController();
    final form = GlobalKey<FormState>();
    final important = ValueNotifier(false);
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _NoticeFormResourcesOwner(
        resources: [title, body, important],
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 25),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Form(
              key: form,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Create academy notice',
                    style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                    controller: title,
                    decoration: const InputDecoration(
                      labelText: 'Notice title',
                    ),
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Enter a title' : null,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: body,
                    minLines: 3,
                    maxLines: 5,
                    decoration: const InputDecoration(labelText: 'Message'),
                    validator: (v) => v == null || v.trim().isEmpty
                        ? 'Enter a message'
                        : null,
                  ),
                  ValueListenableBuilder<bool>(
                    valueListenable: important,
                    builder: (context, v, child) => CheckboxListTile(
                      value: v,
                      onChanged: (n) => important.value = n ?? false,
                      contentPadding: EdgeInsets.zero,
                      title: const Text(
                        'Mark as important',
                        style: TextStyle(fontSize: 13),
                      ),
                      controlAffinity: ListTileControlAffinity.leading,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () async {
                        if (!(form.currentState?.validate() ?? false)) return;
                        try {
                          await context.read<AcademyState>().addNotice(
                            AcademyNotice(
                              title: title.text.trim(),
                              body: body.text.trim(),
                              date: DateTime.now().toIso8601String().substring(
                                0,
                                10,
                              ),
                              important: important.value,
                            ),
                          );
                          if (ctx.mounted) Navigator.pop(ctx);
                        } catch (_) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Could not publish the notice.'),
                              ),
                            );
                          }
                        }
                      },
                      child: const Text('Publish notice'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NoticeFormResourcesOwner extends StatefulWidget {
  const _NoticeFormResourcesOwner({
    required this.resources,
    required this.child,
  });

  final List<ChangeNotifier> resources;
  final Widget child;

  @override
  State<_NoticeFormResourcesOwner> createState() =>
      _NoticeFormResourcesOwnerState();
}

class _NoticeFormResourcesOwnerState extends State<_NoticeFormResourcesOwner> {
  @override
  Widget build(BuildContext context) => widget.child;

  @override
  void dispose() {
    for (final resource in widget.resources) {
      resource.dispose();
    }
    super.dispose();
  }
}

class _ToolCard extends StatelessWidget {
  const _ToolCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
  final IconData icon;
  final String title, subtitle;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext c) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(16),
    child: Container(
      margin: const EdgeInsets.only(bottom: 9),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEDEAF1)),
      ),
      child: Row(
        children: [
          Container(
            width: 39,
            height: 39,
            decoration: const BoxDecoration(
              color: AcademyColors.lilac,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AcademyColors.purple, size: 20),
          ),
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
                  subtitle,
                  style: const TextStyle(
                    color: AcademyColors.muted,
                    fontSize: 11,
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
