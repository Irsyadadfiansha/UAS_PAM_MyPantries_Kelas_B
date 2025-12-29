import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../../core/constants/app_colors.dart';

/// Loading widget with shimmer effect
class LoadingWidget extends StatelessWidget {
  final String? message;

  const LoadingWidget({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(color: AppColors.primaryDark),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(message!, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ],
      ),
    );
  }
}

/// Shimmer loading card
class ShimmerCard extends StatelessWidget {
  final double height;
  final double? width;

  const ShimmerCard({super.key, this.height = 120, this.width});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}

/// Shimmer list loader
class ShimmerListLoader extends StatelessWidget {
  final int itemCount;
  final double itemHeight;

  const ShimmerListLoader({
    super.key,
    this.itemCount = 5,
    this.itemHeight = 100,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: itemCount,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, __) => ShimmerCard(height: itemHeight),
    );
  }
}

/// Shimmer grid loader
class ShimmerGridLoader extends StatelessWidget {
  final int itemCount;
  final int crossAxisCount;
  final double itemHeight;

  const ShimmerGridLoader({
    super.key,
    this.itemCount = 6,
    this.crossAxisCount = 2,
    this.itemHeight = 150,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        mainAxisExtent: itemHeight,
      ),
      itemCount: itemCount,
      itemBuilder: (_, __) => ShimmerCard(height: itemHeight),
    );
  }
}
