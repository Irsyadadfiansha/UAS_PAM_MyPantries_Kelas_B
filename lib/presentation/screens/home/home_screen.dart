import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../data/models/pantry_item_model.dart';
import '../../../data/models/recipe_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/pantry_provider.dart';
import '../../providers/recipe_provider.dart';

/// Home dashboard screen
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    await Future.wait([
      ref.read(pantryProvider.notifier).refresh(),
      ref.read(recipeProvider.notifier).refresh(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final pantryState = ref.watch(pantryProvider);
    final recipeState = ref.watch(recipeProvider);

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: CustomScrollView(
          slivers: [
            // App Bar
            SliverAppBar(
              expandedHeight: 100,
              floating: true,
              pinned: true,
              backgroundColor: AppColors.primaryDark,
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
                title: Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: Colors.white.withValues(alpha: 0.2),
                      child: const Icon(
                        Icons.person,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${AppStrings.greeting}, ${user?.name ?? 'User'}! 👋',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Content
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Stats Cards
                  _buildStatsSection(pantryState, recipeState),
                  const SizedBox(height: 24),

                  // Expiring Soon
                  _buildSectionHeader(
                    AppStrings.expiringSoon,
                    Icons.warning_amber,
                  ),
                  const SizedBox(height: 12),
                  _buildExpiringSection(pantryState.expiringSoon),
                  const SizedBox(height: 24),

                  // Recommendations
                  _buildSectionHeader(
                    AppStrings.recommendations,
                    Icons.auto_awesome,
                  ),
                  const SizedBox(height: 12),
                  _buildRecommendationsSection(recipeState.recommendations),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsSection(PantryState pantryState, RecipeState recipeState) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: Icons.kitchen,
            label: AppStrings.pantryCount,
            value: pantryState.itemCount.toString(),
            color: AppColors.primaryDark,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            icon: Icons.restaurant_menu,
            label: AppStrings.recipesReady,
            value: recipeState.canCookCount.toString(),
            color: AppColors.successGreen,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.primaryDark),
        const SizedBox(width: 8),
        Text(title, style: Theme.of(context).textTheme.titleLarge),
      ],
    );
  }

  Widget _buildExpiringSection(List<PantryItem> items) {
    if (items.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.successGreen.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(Icons.check_circle, color: AppColors.successGreen),
            const SizedBox(width: 12),
            Text(
              AppStrings.allFresh,
              style: TextStyle(color: AppColors.successGreen),
            ),
          ],
        ),
      );
    }

    return SizedBox(
      height: 100,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final item = items[index];
          return _ExpiringItemCard(item: item);
        },
      ),
    );
  }

  Widget _buildRecommendationsSection(List<Recipe> recipes) {
    if (recipes.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.surfaceBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Column(
          children: [
            Icon(Icons.menu_book, size: 48, color: AppColors.textMuted),
            const SizedBox(height: 12),
            Text(
              AppStrings.noRecommendations,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () {
                // Navigate to pantry
              },
              icon: const Icon(Icons.add),
              label: const Text(AppStrings.addIngredients),
            ),
          ],
        ),
      );
    }

    return Column(
      children: recipes.take(3).map((recipe) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _RecommendationCard(
            recipe: recipe,
            onTap: () => context.push('/recipes/${recipe.id}'),
          ),
        );
      }).toList(),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _ExpiringItemCard extends StatelessWidget {
  final PantryItem item;

  const _ExpiringItemCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final daysLeft = item.daysUntilExpiry;
    final color = daysLeft <= 2 ? AppColors.dangerRed : AppColors.warningAmber;

    return Container(
      width: 140,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color:
                      AppColors.categoryColors[item.ingredientCategory] ??
                      AppColors.surfaceBg,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  Icons.egg_alt,
                  size: 16,
                  color: AppColors.categoryIconColors[item.ingredientCategory],
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '$daysLeft ${AppStrings.daysLeft}',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            item.ingredientName,
            style: Theme.of(context).textTheme.titleSmall,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            item.formattedQuantity,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _RecommendationCard extends StatelessWidget {
  final Recipe recipe;
  final VoidCallback onTap;

  const _RecommendationCard({required this.recipe, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Row(
          children: [
            // Recipe image or placeholder
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: AppColors.surfaceBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: recipe.imageUrl != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        recipe.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.restaurant,
                          color: AppColors.textMuted,
                        ),
                      ),
                    )
                  : const Icon(Icons.restaurant, color: AppColors.textMuted),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          recipe.title,
                          style: Theme.of(context).textTheme.titleMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.successGreen,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          AppStrings.canCook,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    recipe.description,
                    style: Theme.of(context).textTheme.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.schedule,
                        size: 14,
                        color: AppColors.textMuted,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        recipe.formattedCookingTime,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(width: 12),
                      Icon(
                        Icons.restaurant_menu,
                        size: 14,
                        color: AppColors.textMuted,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${recipe.actualIngredientCount} bahan',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }
}
