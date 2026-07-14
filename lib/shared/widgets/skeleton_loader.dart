import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';

class SkeletonBox extends StatelessWidget {
  final double? width;
  final double height;
  final BorderRadius? borderRadius;

  const SkeletonBox({
    super.key,
    this.width,
    this.height = 16,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: isDark ? Colors.white : Colors.black,
        borderRadius: borderRadius ?? BorderRadius.circular(8),
      ),
    );
  }
}

/// Wraps skeleton placeholder content in a shimmer effect.
class ShimmerWrap extends StatelessWidget {
  final Widget child;

  const ShimmerWrap({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Shimmer.fromColors(
      baseColor: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.06),
      highlightColor: isDark ? Colors.white.withValues(alpha: 0.16) : Colors.black.withValues(alpha: 0.14),
      child: child,
    );
  }
}

/// A generic skeleton for a card-style list item (icon + two lines of text).
class SkeletonListCard extends StatelessWidget {
  const SkeletonListCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSpacing.largeCardRadius),
          color: Colors.black.withValues(alpha: 0.02),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SkeletonBox(width: 46, height: 46, borderRadius: BorderRadius.all(Radius.circular(14))),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SkeletonBox(width: double.infinity, height: 16),
                  const SizedBox(height: 8),
                  SkeletonBox(width: MediaQuery.of(context).size.width * 0.5, height: 12),
                  const SizedBox(height: 8),
                  const SkeletonBox(width: 100, height: 12),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A list of skeleton cards, shimmering as a group.
class SkeletonListLoader extends StatelessWidget {
  final int count;

  const SkeletonListLoader({super.key, this.count = 4});

  @override
  Widget build(BuildContext context) {
    return ShimmerWrap(
      child: Column(
        children: List.generate(count, (_) => const SkeletonListCard()),
      ),
    );
  }
}

/// Skeleton for the small metric/summary cards used in grids.
class SkeletonMetricCard extends StatelessWidget {
  const SkeletonMetricCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSpacing.largeCardRadius),
        color: Colors.black.withValues(alpha: 0.02),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SkeletonBox(width: 42, height: 42, borderRadius: BorderRadius.all(Radius.circular(12))),
          Spacer(),
          SkeletonBox(width: 60, height: 20),
          SizedBox(height: 8),
          SkeletonBox(width: 80, height: 12),
        ],
      ),
    );
  }
}

class SkeletonMetricGrid extends StatelessWidget {
  final int count;

  const SkeletonMetricGrid({super.key, this.count = 3});

  @override
  Widget build(BuildContext context) {
    return ShimmerWrap(
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: AppSpacing.md,
        mainAxisSpacing: AppSpacing.md,
        childAspectRatio: 1.1,
        children: List.generate(count, (_) => const SkeletonMetricCard()),
      ),
    );
  }
}

/// Small centered spinner replacement kept for spots where a skeleton
/// doesn't make sense (e.g. inline refresh indicators).
class InlineLoader extends StatelessWidget {
  const InlineLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator(color: AppColors.primary));
  }
}
