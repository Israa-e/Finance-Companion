import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// A single animated shimmer block used to build skeleton screens.
class ShimmerBox extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;

  const ShimmerBox({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 12,
  });

  @override
  State<ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<ShimmerBox>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) {
        final base = Theme.of(context).brightness == Brightness.light
            ? 0.06
            : 0.12;
        final alpha = base + 0.06 * _anim.value;
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: Theme.of(context)
                .colorScheme
                .onSurface
                .withValues(alpha: alpha),
            borderRadius: BorderRadius.circular(widget.borderRadius),
          ),
        );
      },
    );
  }
}

/// Skeleton for a single transaction list item.
class TransactionItemSkeleton extends StatelessWidget {
  const TransactionItemSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const ShimmerBox(width: 48, height: 48, borderRadius: 15),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerBox(
                    width: double.infinity, height: 14, borderRadius: 7),
                const SizedBox(height: 8),
                const ShimmerBox(width: 80, height: 10, borderRadius: 5),
              ],
            ),
          ),
          const SizedBox(width: 14),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              ShimmerBox(width: 60, height: 14, borderRadius: 7),
              SizedBox(height: 8),
              ShimmerBox(width: 40, height: 10, borderRadius: 5),
            ],
          ),
        ],
      ),
    );
  }
}

/// A list of [TransactionItemSkeleton] — drop-in replacement for loading state.
class TransactionListSkeleton extends StatelessWidget {
  final int count;

  const TransactionListSkeleton({super.key, this.count = 6});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      itemCount: count,
      itemBuilder: (_, __) => const TransactionItemSkeleton(),
    );
  }
}

/// Skeleton for the balance card.
class BalanceCardSkeleton extends StatelessWidget {
  const BalanceCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 170,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.4),
            AppColors.primaryDark.withValues(alpha: 0.4),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.all(24),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShimmerBox(width: 80, height: 10, borderRadius: 5),
          SizedBox(height: 12),
          ShimmerBox(width: 160, height: 28, borderRadius: 8),
          SizedBox(height: 28),
          Row(
            children: [
              Expanded(child: ShimmerBox(width: double.infinity, height: 44, borderRadius: 14)),
              SizedBox(width: 12),
              Expanded(child: ShimmerBox(width: double.infinity, height: 44, borderRadius: 14)),
            ],
          ),
        ],
      ),
    );
  }
}