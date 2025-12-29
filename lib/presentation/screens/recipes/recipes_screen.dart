import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../data/models/recipe_model.dart';
import '../../../data/models/ingredient_model.dart';
import '../../providers/recipe_provider.dart';
import '../../providers/pantry_provider.dart';
import '../../providers/ingredient_provider.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/empty_state_widget.dart';
import '../../widgets/common/error_widget.dart';

/// Recipes screen
class RecipesScreen extends ConsumerStatefulWidget {
  const RecipesScreen({super.key});

  @override
  ConsumerState<RecipesScreen> createState() => _RecipesScreenState();
}

class _RecipesScreenState extends ConsumerState<RecipesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      ref
          .read(recipeProvider.notifier)
          .setShowOnlyCanCook(_tabController.index == 1);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(recipeProvider.notifier).loadRecipes();
      ref.read(ingredientProvider.notifier).loadIngredients();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showAddRecipeModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _AddRecipeModal(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final recipeState = ref.watch(recipeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.recipesTitle),
        backgroundColor: AppColors.primaryDark,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          tabs: const [
            Tab(text: AppStrings.allRecipes),
            Tab(text: AppStrings.canCook),
          ],
        ),
      ),
      body: Column(
        children: [
          // Filters (only for "All" tab)
          if (_tabController.index == 0)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: recipeState.selectedCategory,
                      decoration: const InputDecoration(
                        labelText: AppStrings.category,
                        contentPadding: EdgeInsets.symmetric(horizontal: 12),
                      ),
                      isExpanded: true,
                      items: [
                        const DropdownMenuItem(
                          value: null,
                          child: Text('Semua Kategori'),
                        ),
                        ...RecipeCategories.all.map(
                          (c) => DropdownMenuItem(
                            value: c,
                            child: Text(RecipeCategories.displayNames[c] ?? c),
                          ),
                        ),
                      ],
                      onChanged: (value) {
                        ref.read(recipeProvider.notifier).setCategory(value);
                        ref.read(recipeProvider.notifier).loadRecipes();
                      },
                    ),
                  ),
                  if (recipeState.selectedCategory != null) ...[
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: () {
                        ref.read(recipeProvider.notifier).clearFilters();
                        ref.read(recipeProvider.notifier).loadRecipes();
                      },
                      child: const Text(AppStrings.clearFilters),
                    ),
                  ],
                ],
              ),
            ),

          // Content
          Expanded(child: _buildContent(recipeState)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'recipes_fab',
        onPressed: _showAddRecipeModal,
        icon: const Icon(Icons.add),
        label: const Text(AppStrings.addRecipe),
      ),
    );
  }

  Widget _buildContent(RecipeState state) {
    if (state.isLoading) {
      return const ShimmerListLoader();
    }

    if (state.error != null) {
      return AppErrorWidget(
        message: state.error,
        onRetry: () => ref.read(recipeProvider.notifier).loadRecipes(),
      );
    }

    final recipes = state.filteredRecipes;
    if (recipes.isEmpty) {
      return EmptyStateWidget.recipes(onAddRecipe: _showAddRecipeModal);
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(recipeProvider.notifier).loadRecipes(),
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: recipes.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          return _RecipeCard(recipe: recipes[index]);
        },
      ),
    );
  }
}

class _RecipeCard extends ConsumerWidget {
  final Recipe recipe;

  const _RecipeCard({required this.recipe});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recipeState = ref.watch(recipeProvider);
    final isCooking = recipeState.cookingRecipeId == recipe.id;

    return InkWell(
      onTap: () => context.push('/recipes/${recipe.id}'),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Recipe image
                Container(
                  width: 80,
                  height: 80,
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
                              size: 32,
                            ),
                          ),
                        )
                      : const Icon(
                          Icons.restaurant,
                          color: AppColors.textMuted,
                          size: 32,
                        ),
                ),
                const SizedBox(width: 16),
                // Title and description
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
                          _MatchBadge(percentage: recipe.matchPercentage ?? 0),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        recipe.description,
                        style: Theme.of(context).textTheme.bodySmall,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                // Delete button
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 20),
                  color: AppColors.textMuted,
                  onPressed: () => _showDeleteDialog(context, ref),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Info row
            Row(
              children: [
                _InfoChip(
                  icon: Icons.schedule,
                  label: recipe.formattedCookingTime,
                ),
                const SizedBox(width: 12),
                _InfoChip(
                  icon: Icons.restaurant_menu,
                  label:
                      '${recipe.actualIngredientCount} ${AppStrings.ingredientCount}',
                ),
                const SizedBox(width: 12),
                _InfoChip(
                  icon: Icons.people,
                  label: '${recipe.servings ?? '-'} ${AppStrings.servings}',
                ),
              ],
            ),
            // Missing ingredients warning
            if (recipe.missingCount != null && recipe.missingCount! > 0) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.warningAmber.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.warning_amber,
                      size: 16,
                      color: AppColors.warningAmber,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Kurang ${recipe.missingCount} bahan lagi',
                      style: TextStyle(
                        color: AppColors.warningAmber,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 12),
            // Cook button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: recipe.canCook == true && !isCooking
                    ? () async {
                        final success = await ref
                            .read(recipeProvider.notifier)
                            .cookRecipe(recipe.id);
                        if (success) {
                          await ref.read(pantryProvider.notifier).refresh();
                          await ref.read(recipeProvider.notifier).loadRecipes();
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Resep berhasil dimasak! Bahan telah dikurangi dari pantry.',
                                ),
                                backgroundColor: AppColors.successGreen,
                              ),
                            );
                          }
                        }
                      }
                    : null,
                icon: isCooking
                    ? const SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.local_fire_department),
                label: Text(isCooking ? 'Memasak...' : AppStrings.cookNow),
                style: ElevatedButton.styleFrom(
                  backgroundColor: recipe.canCook == true
                      ? AppColors.successGreen
                      : AppColors.textMuted,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Resep'),
        content: Text('Yakin ingin menghapus resep "${recipe.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await ref
                  .read(recipeProvider.notifier)
                  .deleteRecipe(recipe.id);
              if (success && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Resep berhasil dihapus'),
                    backgroundColor: AppColors.successGreen,
                  ),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.dangerRed),
            child: const Text(AppStrings.delete),
          ),
        ],
      ),
    );
  }
}

class _MatchBadge extends StatelessWidget {
  final int percentage;

  const _MatchBadge({required this.percentage});

  @override
  Widget build(BuildContext context) {
    final color = AppColors.getMatchColor(percentage);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        '$percentage%',
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.textMuted),
        const SizedBox(width: 4),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

/// Add Recipe Modal
class _AddRecipeModal extends ConsumerStatefulWidget {
  const _AddRecipeModal();

  @override
  ConsumerState<_AddRecipeModal> createState() => _AddRecipeModalState();
}

class _AddRecipeModalState extends ConsumerState<_AddRecipeModal> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _instructionsController = TextEditingController();
  final _cookingTimeController = TextEditingController();
  final _servingsController = TextEditingController();
  final _toolsController = TextEditingController();

  final List<String> _selectedCategories = [];
  final List<_RecipeIngredientItem> _ingredients = [];
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _instructionsController.dispose();
    _cookingTimeController.dispose();
    _servingsController.dispose();
    _toolsController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    // Prevent double-tap
    if (_isLoading) return;

    if (!_formKey.currentState!.validate()) return;
    if (_ingredients.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tambahkan minimal 1 bahan')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final success = await ref
          .read(recipeProvider.notifier)
          .createRecipe(
            title: _titleController.text.trim(),
            description: _descriptionController.text.trim(),
            instructions: _instructionsController.text.trim(),
            cookingTime: int.parse(_cookingTimeController.text),
            servings: _servingsController.text.isNotEmpty
                ? int.parse(_servingsController.text)
                : null,
            categories: _selectedCategories.isNotEmpty
                ? _selectedCategories
                : null,
            ingredients: _ingredients
                .map(
                  (i) => {
                    'id': i.ingredient.id,
                    'quantity_needed': i.quantity,
                    'unit': i.unit,
                  },
                )
                .toList(),
          );

      if (mounted) {
        setState(() => _isLoading = false);

        if (success) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Resep berhasil ditambahkan'),
              backgroundColor: AppColors.successGreen,
            ),
          );
          // Reload recipes
          ref.read(recipeProvider.notifier).loadRecipes();
        } else {
          final error = ref.read(recipeProvider).error;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(error ?? 'Gagal menyimpan resep'),
              backgroundColor: AppColors.dangerRed,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.dangerRed,
          ),
        );
      }
    }
  }

  void _addIngredient() {
    final ingredientState = ref.read(ingredientProvider);

    showDialog(
      context: context,
      builder: (context) => _AddIngredientDialog(
        availableIngredients: ingredientState.ingredients,
        onAdd: (ingredient, quantity, unit) {
          setState(() {
            _ingredients.add(
              _RecipeIngredientItem(
                ingredient: ingredient,
                quantity: quantity,
                unit: unit,
              ),
            );
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            // Handle
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.borderMedium,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            // Title
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Text(
                    AppStrings.addRecipe,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Title
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Nama Resep *',
                        prefixIcon: Icon(Icons.restaurant_menu),
                      ),
                      textCapitalization: TextCapitalization.words,
                      validator: (v) =>
                          v?.isEmpty == true ? 'Wajib diisi' : null,
                    ),
                    const SizedBox(height: 16),

                    // Description
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Deskripsi *',
                        prefixIcon: Icon(Icons.description),
                      ),
                      maxLines: 2,
                      validator: (v) =>
                          v?.isEmpty == true ? 'Wajib diisi' : null,
                    ),
                    const SizedBox(height: 16),

                    // Cooking time & servings
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _cookingTimeController,
                            decoration: const InputDecoration(
                              labelText: 'Waktu Masak (menit) *',
                              prefixIcon: Icon(Icons.schedule),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (v) {
                              if (v?.isEmpty == true) return 'Wajib diisi';
                              if (int.tryParse(v!) == null)
                                return 'Angka tidak valid';
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _servingsController,
                            decoration: const InputDecoration(
                              labelText: 'Porsi',
                              prefixIcon: Icon(Icons.people),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Categories
                    Text(
                      'Kategori',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: RecipeCategories.all.map((cat) {
                        final isSelected = _selectedCategories.contains(cat);
                        return FilterChip(
                          label: Text(
                            RecipeCategories.displayNames[cat] ?? cat,
                          ),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                _selectedCategories.add(cat);
                              } else {
                                _selectedCategories.remove(cat);
                              }
                            });
                          },
                          selectedColor: AppColors.primaryDark,
                          labelStyle: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : AppColors.textPrimary,
                            fontSize: 12,
                          ),
                          showCheckmark: false,
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),

                    // Ingredients section
                    Row(
                      children: [
                        Text(
                          'Bahan-bahan *',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        const Spacer(),
                        TextButton.icon(
                          onPressed: _addIngredient,
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text('Tambah'),
                        ),
                      ],
                    ),
                    if (_ingredients.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceBg,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.borderLight),
                        ),
                        child: const Center(
                          child: Text('Belum ada bahan ditambahkan'),
                        ),
                      )
                    else
                      ...List.generate(_ingredients.length, (index) {
                        final item = _ingredients[index];
                        return ListTile(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceBg,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.kitchen, size: 20),
                          ),
                          title: Text(item.ingredient.name),
                          subtitle: Text('${item.quantity} ${item.unit}'),
                          trailing: IconButton(
                            icon: const Icon(Icons.close, size: 18),
                            onPressed: () {
                              setState(() => _ingredients.removeAt(index));
                            },
                          ),
                        );
                      }),
                    const SizedBox(height: 16),

                    // Instructions
                    TextFormField(
                      controller: _instructionsController,
                      decoration: const InputDecoration(
                        labelText: 'Langkah-langkah Memasak *',
                        prefixIcon: Icon(Icons.list_alt),
                        alignLabelWithHint: true,
                      ),
                      maxLines: 5,
                      validator: (v) =>
                          v?.isEmpty == true ? 'Wajib diisi' : null,
                    ),
                    const SizedBox(height: 16),

                    // Tools
                    TextFormField(
                      controller: _toolsController,
                      decoration: const InputDecoration(
                        labelText: 'Alat yang Dibutuhkan',
                        prefixIcon: Icon(Icons.kitchen),
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 24),

                    // Actions
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text(AppStrings.cancel),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _handleSave,
                            child: _isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text(AppStrings.save),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecipeIngredientItem {
  final Ingredient ingredient;
  final double quantity;
  final String unit;

  _RecipeIngredientItem({
    required this.ingredient,
    required this.quantity,
    required this.unit,
  });
}

class _AddIngredientDialog extends StatefulWidget {
  final List<Ingredient> availableIngredients;
  final Function(Ingredient, double, String) onAdd;

  const _AddIngredientDialog({
    required this.availableIngredients,
    required this.onAdd,
  });

  @override
  State<_AddIngredientDialog> createState() => _AddIngredientDialogState();
}

class _AddIngredientDialogState extends State<_AddIngredientDialog> {
  Ingredient? _selectedIngredient;
  final _quantityController = TextEditingController();
  String _selectedUnit = 'g';

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Tambah Bahan'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField<Ingredient>(
            value: _selectedIngredient,
            decoration: const InputDecoration(labelText: 'Pilih Bahan'),
            items: widget.availableIngredients.map((i) {
              return DropdownMenuItem(value: i, child: Text(i.name));
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedIngredient = value;
                if (value?.defaultUnit != null) {
                  _selectedUnit = value!.defaultUnit!;
                }
              });
            },
            isExpanded: true,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: TextFormField(
                  controller: _quantityController,
                  decoration: const InputDecoration(labelText: 'Jumlah'),
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedUnit,
                  decoration: const InputDecoration(labelText: 'Satuan'),
                  items: ['g', 'kg', 'ml', 'L', 'pcs', 'tbsp', 'tsp'].map((u) {
                    return DropdownMenuItem(value: u, child: Text(u));
                  }).toList(),
                  onChanged: (v) => setState(() => _selectedUnit = v!),
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(AppStrings.cancel),
        ),
        ElevatedButton(
          onPressed: () {
            if (_selectedIngredient == null ||
                _quantityController.text.isEmpty) {
              return;
            }
            widget.onAdd(
              _selectedIngredient!,
              double.parse(_quantityController.text),
              _selectedUnit,
            );
            Navigator.pop(context);
          },
          child: const Text('Tambah'),
        ),
      ],
    );
  }
}
