import 'package:flutter/material.dart';
import '../dashboard/dashboard_screen.dart';
import '../students/students_screen.dart';
import '../attendance/attendance_screen.dart';
import '../fees/fees_screen.dart';
import '../more/more_screen.dart';
import '../../core/theme/app_theme.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});
  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int index = 0;
  List<Widget> get pages => [
    DashboardScreen(onNavigate: (v) => setState(() => index = v)),
    const AttendanceScreen(),
    const StudentsScreen(),
    const FeesScreen(),
    const MoreScreen(),
  ];
  static const names = ['Home', 'Attendance', 'Students', 'Fees', 'More'];
  static const icons = [
    Icons.home_rounded,
    Icons.event_available_rounded,
    Icons.school_rounded,
    Icons.account_balance_wallet_rounded,
    Icons.grid_view_rounded,
  ];
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: PreferredSize(
      preferredSize: const Size.fromHeight(66),
      child: AppBar(
        titleSpacing: 16,
        title: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: .16),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withValues(alpha: .35)),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(
                  'assets/skypro_logo.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 11),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'SkyPro',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -.3,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Mandi Shah Jewana  •  0345-7885004',
                    style: TextStyle(
                      fontSize: 10,
                      color: Color(0xFFD9C8ED),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () => setState(() => index = 4),
            icon: const Icon(Icons.notifications_none_rounded),
            tooltip: 'Notices',
          ),
          const SizedBox(width: 5),
        ],
      ),
    ),
    body: IndexedStack(index: index, children: pages),
    bottomNavigationBar: NavigationBar(
      selectedIndex: index,
      onDestinationSelected: (v) => setState(() => index = v),
      destinations: List.generate(
        5,
        (i) => NavigationDestination(
          icon: Icon(icons[i]),
          selectedIcon: Icon(icons[i], color: AcademyColors.purple),
          label: names[i],
        ),
      ),
    ),
  );
}
