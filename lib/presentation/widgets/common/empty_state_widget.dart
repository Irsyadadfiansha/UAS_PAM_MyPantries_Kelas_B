import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';

/// Empty state widget with icon and message
class EmptyStateWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? message;
  final String? actionLabel;
  final VoidCallback? onAction;

  const EmptyStateWidget({
    super.key,
    required this.icon,
    required this.title,
    this.message,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.surfaceBg,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 64, color: AppColors.textMuted),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            if (message != null) ...[
              const SizedBox(height: 8),
              Text(
                message!,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.add),
                label: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Empty pantry state
  factory EmptyStateWidget.pantry({VoidCallback? onAddItem}) {
    return EmptyStateWidget(
      icon: Icons.kitchen,
      title: AppStrings.emptyPantry,
      message: AppStrings.emptyPantryMessage,
      actionLabel: AppStrings.addPantryItem,
      onAction: onAddItem,
    );
  }

  /// No recipes state
  factory EmptyStateWidget.recipes({VoidCallback? onAddRecipe}) {
    return EmptyStateWidget(
      icon: Icons.menu_book,
      title: AppStrings.noData,
      message: 'Belum ada resep yang tersedia',
      actionLabel: AppStrings.addRecipe,
      onAction: onAddRecipe,
    );
  }

  /// No expiring items state
  factory EmptyStateWidget.expiring() {
    return const EmptyStateWidget(
      icon: Icons.check_circle_outline,
      title: AppStrings.allFresh,
      message: null,
    );
  }
}
