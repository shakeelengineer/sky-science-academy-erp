import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/academy_calculations.dart';
import '../../widgets/section_title.dart';
import '../app_state.dart';

class FeesScreen extends StatelessWidget {
  const FeesScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final s = context.watch<AcademyState>();
    final pending = s.fees.fold<int>(
      0,
      (sum, r) =>
          sum +
          (((r['monthly_fee'] as int) - (r['paid'] as int)).clamp(0, 1 << 30)),
    );
    final collected = s.fees.fold<int>(0, (sum, r) => sum + (r['paid'] as int));
    final billed = s.fees.fold<int>(
      0,
      (sum, r) => sum + (r['monthly_fee'] as int),
    );
    final month = DateTime.now();
    final monthTitle = '${_month(month.month)} ${month.year}';
    return PagePad(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionTitle(
            'Fees',
            subtitle: 'Collection • $monthTitle',
            trailing: IconButton(
              onPressed: () => _explain(context),
              icon: const Icon(Icons.info_outline_rounded),
            ),
          ),
          const SectionTitle(
            'Fee collection',
            subtitle: 'Record payments and track this month’s dues.',
          ),
          Row(
            children: [
              Expanded(
                child: _FeeMetric('Collected', collected, AcademyColors.green),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _FeeMetric('Pending', pending, AcademyColors.red),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _FeeMetric('Billed', billed, AcademyColors.purple),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AcademyColors.lilac,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.donut_small_rounded,
                  color: AcademyColors.purple,
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: Text(
                    billed == 0
                        ? 'Add students and their monthly fee amounts to start collection.'
                        : '${(collected * 100 / billed).round()}% collected in ${_month(month.month)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
                Text(
                  'Rs ${_fmt(collected)}',
                  style: const TextStyle(
                    color: AcademyColors.purple,
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 13),
          if (s.fees.isEmpty)
            const EmptyState(
              icon: Icons.account_balance_wallet_outlined,
              title: 'No fee records yet',
              message:
                  'Add students and set their monthly fee to see balances here.',
            )
          else
            ...s.fees.map((r) {
              final fee = r['monthly_fee'] as int,
                  paid = r['paid'] as int,
                  due = outstandingFee(fee, paid);
              return _FeeStudent(
                row: r,
                due: due,
                onPay: due == 0 ? null : () => _pay(context, r, due),
              );
            }),
        ],
      ),
    );
  }

  Future<void> _pay(
    BuildContext context,
    Map<String, Object?> row,
    int due,
  ) async {
    final controller = TextEditingController(text: due.toString());
    final form = GlobalKey<FormState>();
    final amount = await showDialog<int>(
      context: context,
      builder: (ctx) => _FeeDialogControllerOwner(
        controller: controller,
        child: AlertDialog(
          title: const Text('Receive payment'),
          content: Form(
            key: form,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${row['name']}  •  Due Rs ${_fmt(due)}',
                  style: const TextStyle(fontSize: 13),
                ),
                const SizedBox(height: 13),
                TextFormField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Amount (Rs)'),
                  validator: (v) {
                    final n = int.tryParse(v ?? '');
                    return n == null || !isValidFeePayment(amount: n, due: due)
                        ? 'Enter an amount up to Rs ${_fmt(due)}'
                        : null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                if (form.currentState?.validate() ?? false) {
                  Navigator.pop(ctx, int.parse(controller.text));
                }
              },
              child: const Text('Record'),
            ),
          ],
        ),
      ),
    );
    if (amount != null && context.mounted) {
      try {
        await context.read<AcademyState>().pay(row['id'] as int, amount);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Payment of Rs ${_fmt(amount)} recorded.')),
          );
        }
      } catch (_) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not record the payment.')),
          );
        }
      }
    }
  }

  void _explain(BuildContext c) => showDialog<void>(
    context: c,
    builder: (ctx) => AlertDialog(
      title: const Text('Fee totals'),
      content: const Text(
        'Amounts are calculated from active student fee settings and payment transactions recorded for the current month. Each receipt is stored as a separate transaction.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Got it'),
        ),
      ],
    ),
  );
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
  String _fmt(int n) => n.toString().replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (_) => ',',
  );
}

class _FeeDialogControllerOwner extends StatefulWidget {
  const _FeeDialogControllerOwner({
    required this.controller,
    required this.child,
  });

  final TextEditingController controller;
  final Widget child;

  @override
  State<_FeeDialogControllerOwner> createState() =>
      _FeeDialogControllerOwnerState();
}

class _FeeDialogControllerOwnerState extends State<_FeeDialogControllerOwner> {
  @override
  Widget build(BuildContext context) => widget.child;

  @override
  void dispose() {
    widget.controller.dispose();
    super.dispose();
  }
}

class _FeeMetric extends StatelessWidget {
  const _FeeMetric(this.label, this.value, this.color);
  final String label;
  final int value;
  final Color color;
  @override
  Widget build(BuildContext c) => Container(
    padding: const EdgeInsets.all(11),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(15),
      border: Border.all(color: const Color(0xFFEDEAF1)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: AcademyColors.muted),
        ),
        const SizedBox(height: 5),
        Text(
          'Rs ${value >= 100000
              ? '${(value / 100000).toStringAsFixed(1)}L'
              : value >= 1000
              ? '${(value / 1000).toStringAsFixed(value % 1000 == 0 ? 0 : 1)}k'
              : '$value'}',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
      ],
    ),
  );
}

class _FeeStudent extends StatelessWidget {
  const _FeeStudent({required this.row, required this.due, this.onPay});
  final Map<String, Object?> row;
  final int due;
  final VoidCallback? onPay;
  @override
  Widget build(BuildContext c) {
    final fee = row['monthly_fee'] as int;
    final paid = row['paid'] as int;
    return Container(
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
            radius: 19,
            backgroundColor: AcademyColors.lilac,
            child: Icon(
              due == 0 ? Icons.check_rounded : Icons.person_outline_rounded,
              color: due == 0 ? AcademyColors.green : AcademyColors.purple,
              size: 19,
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
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
                Text(
                  'Class ${row['grade']}  •  Rs ${_fmt(fee)} / month',
                  style: const TextStyle(
                    color: AcademyColors.muted,
                    fontSize: 10,
                  ),
                ),
                if (paid > 0)
                  Text(
                    'Rs ${_fmt(paid)} received',
                    style: const TextStyle(
                      color: AcademyColors.green,
                      fontSize: 10,
                    ),
                  ),
              ],
            ),
          ),
          if (due > 0)
            FilledButton.tonal(
              onPressed: onPay,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 11),
                visualDensity: VisualDensity.compact,
              ),
              child: Text(
                'Receive\nRs ${_fmt(due)}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            )
          else
            const Icon(Icons.check_circle, color: AcademyColors.green),
        ],
      ),
    );
  }

  String _fmt(int n) => n.toString().replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (_) => ',',
  );
}
