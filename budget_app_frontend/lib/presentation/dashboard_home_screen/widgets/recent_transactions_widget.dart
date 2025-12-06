
import 'package:flutter/material.dart';
import '../../../widgets/pressable.dart';
import '../../../widgets/loading_list.dart';
import '../../../theme/app_theme.dart';
import '../../../core/design_tokens.dart';

class RecentTransactionsWidget extends StatelessWidget {
  final List<Map<String, dynamic>> transactions;
  final Function(Map<String, dynamic>) onEditTransaction;
  final Function(Map<String, dynamic>) onDeleteTransaction;
  final Function(Map<String, dynamic>) onCategorizeTransaction;
  final bool isLoading;

  const RecentTransactionsWidget({
    super.key,
    required this.transactions,
    required this.onEditTransaction,
    required this.onDeleteTransaction,
    required this.onCategorizeTransaction,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const LoadingList(itemCount: 5);
    }

    if (transactions.isEmpty) {
      return Center(
        child: Text(
          'No recent transactions.',
          style: TextStyle(fontSize: 16, color: Theme.of(context).textTheme.bodyMedium?.color),
        ),
      );
    }
    // NOTE: This widget is rendered inside a SingleChildScrollView on the dashboard.
    // To avoid "Vertical viewport was given unbounded height" and similar layout
    // exceptions, disable inner scrolling and enable shrinkWrap here.
    return Container(
      margin: EdgeInsets.symmetric(horizontal: kSpacingXL),
      padding: EdgeInsets.all(kSpacingM),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.cardColor,
        borderRadius: BorderRadius.circular(kRadiusL),
        boxShadow: [
          BoxShadow(
            color: AppTheme.shadowLight,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: transactions.length,
        separatorBuilder: (context, index) => Divider(
          height: 1,
          color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.12),
        ),
        itemBuilder: (context, index) {
          final txn = transactions[index];
          final isIncome = (txn['type'] ?? 'expense').toString().toLowerCase() == 'income';
          return _HoverableTransactionItem(
            child: Pressable(
              borderRadius: BorderRadius.circular(kRadiusM),
              padding: EdgeInsets.symmetric(vertical: kSpacingS, horizontal: kSpacingM),
              onTap: () => onEditTransaction(txn),
              onLongPress: () => onDeleteTransaction(txn),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: kRadiusS,
                    backgroundColor: (txn['categoryColor'] is Color)
                        ? txn['categoryColor'] as Color
                        : AppTheme.categoryColors[0],
                    child: Icon(
                      isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                      color: Theme.of(context).colorScheme.onPrimary,
                      size: 18,
                    ),
                  ),
                  SizedBox(width: kSpacingM),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          (txn['title'] ?? '').toString(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: kSpacingXS),
                        Text(
                          (txn['category'] ?? '').toString(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: kSpacingM),
                  Text(
                    '${isIncome ? '+' : '-'} ${(txn['amount'] is num) ? (txn['amount'] as num).toStringAsFixed(2) : '0.00'}',
                    style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                      color: isIncome ? AppTheme.successLight : AppTheme.errorLight,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _HoverableTransactionItem extends StatefulWidget {
  final Widget child;
  const _HoverableTransactionItem({required this.child});

  @override
  State<_HoverableTransactionItem> createState() => _HoverableTransactionItemState();
}

class _HoverableTransactionItemState extends State<_HoverableTransactionItem>
    with SingleTickerProviderStateMixin {
  bool _hovering = false;
  late AnimationController _controller;
  late Animation<Offset> _offset;
  late Animation<Color?> _bgColor;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 140),
    );
    _offset = Tween<Offset>(begin: Offset.zero, end: const Offset(0, -0.02)).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _bgColor = ColorTween(
      begin: Colors.transparent,
      end: AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.05),
    ).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() => _hovering = true);
        _controller.forward();
      },
      onExit: (_) {
        setState(() => _hovering = false);
        _controller.reverse();
      },
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return Container(
            decoration: BoxDecoration(
              color: _bgColor.value,
              borderRadius: BorderRadius.circular(kRadiusM),
              boxShadow: _hovering
                  ? [
                      BoxShadow(
                        color: AppTheme.shadowLight,
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : [],
            ),
            child: Transform.translate(
              offset: _offset.value * 10, // subtle lift
              child: widget.child,
            ),
          );
        },
      ),
    );
  }
}
