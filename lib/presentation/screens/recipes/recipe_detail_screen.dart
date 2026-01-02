import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../data/models/recipe_model.dart';
import '../../../data/models/ingredient_model.dart';
import '../../../data/repositories/recipe_repository.dart';
import '../../providers/pantry_provider.dart';
import '../../providers/recipe_provider.dart';
import '../../providers/ingredient_provider.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/error_widget.dart';


class RecipeDetailScreen extends ConsumerStatefulWidget {
  final int recipeId;

  const RecipeDetailScreen({super.key, required this.recipeId});

  @override
  ConsumerState<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends ConsumerState<RecipeDetailScreen> {
  Recipe? _recipe;
  bool _isLoading = true;
  String? _error;
  Set<int> _checkedIngredients = {};

  @override
  void initState() {
    super.initState();
    _loadRecipe();
  }

  Future<void> _loadRecipe() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final recipe = await ref
          .read(recipeRepositoryProvider)
          .getRecipe(widget.recipeId);
      setState(() {
        _recipe = recipe;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _showEditModal() {
    if (_recipe == null) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _EditRecipeModal(
        recipe: _recipe!,
        onUpdated: (updatedRecipe) {
          setState(() {
            _recipe = updatedRecipe;
          });
          // Refresh recipe list
          ref.read(recipeProvider.notifier).loadRecipes();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: LoadingWidget()));
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(),
        body: AppErrorWidget(message: _error, onRetry: _loadRecipe),
      );
    }

    final recipe = _recipe!;
    final pantryItems = ref.watch(pantryProvider).items;
    final userIngredientIds = pantryItems.map((p) => p.ingredientId).toSet();

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Hero image app bar
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: AppColors.primaryDark,
            flexibleSpace: FlexibleSpaceBar(
              background: recipe.imageUrl != null
                  ? Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.network(
                          recipe.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: AppColors.primaryLight,
                            child: const Icon(
                              Icons.restaurant,
                              color: Colors.white54,
                              size: 64,
                            ),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                AppColors.primaryDark.withValues(alpha: 0.8),
                              ],
                            ),
                          ),
                        ),
                      ],
                    )
                  : Container(
                      color: AppColors.primaryLight,
                      child: const Icon(
                        Icons.restaurant,
                        color: Colors.white54,
                        size: 64,
                      ),
                    ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: _showEditModal,
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text(AppStrings.deleteConfirmTitle),
                      content: const Text(AppStrings.deleteConfirmMessage),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: const Text(AppStrings.cancel),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.dangerRed,
                          ),
                          child: const Text(AppStrings.delete),
                        ),
                      ],
                    ),
                  );
                  if (confirmed == true && mounted) {
                    await ref
                        .read(recipeRepositoryProvider)
                        .deleteRecipe(recipe.id);
                    ref.read(recipeProvider.notifier).loadRecipes();
                    if (mounted) context.pop();
                  }
                },
              ),
            ],
          ),

          // Content
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Title
                Text(
                  recipe.title,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),

                // Info badges
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    _InfoBadge(
                      icon: Icons.schedule,
                      label: recipe.formattedCookingTime,
                    ),
                    _InfoBadge(
                      icon: Icons.restaurant_menu,
                      label: '${recipe.actualIngredientCount} bahan',
                    ),
                    if (recipe.servings != null)
                      _InfoBadge(
                        icon: Icons.people,
                        label: '${recipe.servings} porsi',
                      ),
                  ],
                ),
                const SizedBox(height: 16),

                // Description
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.borderLight),
                  ),
                  child: Text(
                    recipe.description,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Ingredients section
                _SectionHeader(
                  icon: Icons.list_alt,
                  title: AppStrings.ingredientsList,
                ),
                const SizedBox(height: 12),
                ...?recipe.ingredients?.map((ingredient) {
                  final hasIngredient = userIngredientIds.contains(
                    ingredient.ingredientId,
                  );
                  final isChecked =
                      _checkedIngredients.contains(ingredient.id) ||
                      hasIngredient;

                  return CheckboxListTile(
                    value: isChecked,
                    onChanged: hasIngredient
                        ? null
                        : (value) {
                            setState(() {
                              if (value == true) {
                                _checkedIngredients.add(ingredient.id);
                              } else {
                                _checkedIngredients.remove(ingredient.id);
                              }
                            });
                          },
                    title: Text(
                      ingredient.name,
                      style: TextStyle(
                        decoration: isChecked
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                        color: isChecked
                            ? AppColors.textMuted
                            : AppColors.textPrimary,
                      ),
                    ),
                    subtitle: Text(
                      ingredient.formattedQuantity,
                      style: TextStyle(
                        color: isChecked
                            ? AppColors.textMuted
                            : AppColors.textSecondary,
                      ),
                    ),
                    secondary: hasIngredient
                        ? const Icon(
                            Icons.check_circle,
                            color: AppColors.successGreen,
                          )
                        : null,
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                  );
                }),
                const SizedBox(height: 24),

                // Instructions section
                _SectionHeader(
                  icon: Icons.format_list_numbered,
                  title: AppStrings.cookingSteps,
                ),
                const SizedBox(height: 12),
                ...recipe.instructionSteps.asMap().entries.map((entry) {
                  return _InstructionStep(
                    stepNumber: entry.key + 1,
                    instruction: entry.value,
                    isLast: entry.key == recipe.instructionSteps.length - 1,
                  );
                }),
                const SizedBox(height: 100),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoBadge extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoBadge({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surfaceBg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.textSecondary),
          const SizedBox(width: 6),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;

  const _SectionHeader({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.primaryDark),
        const SizedBox(width: 8),
        Text(title, style: Theme.of(context).textTheme.titleLarge),
      ],
    );
  }
}

class _InstructionStep extends StatelessWidget {
  final int stepNumber;
  final String instruction;
  final bool isLast;

  const _InstructionStep({
    required this.stepNumber,
    required this.instruction,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Step indicator
        Column(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: AppColors.primaryDark,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '$stepNumber',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 40,
                color: AppColors.borderLight,
                margin: const EdgeInsets.symmetric(vertical: 4),
              ),
          ],
        ),
        const SizedBox(width: 12),
        // Instruction text
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 4, bottom: 16),
            child: Text(
              instruction,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ),
      ],
    );
  }
}

/// Edit Recipe Modal
class _EditRecipeModal extends ConsumerStatefulWidget {
  final Recipe recipe;
  final Function(Recipe) onUpdated;

  const _EditRecipeModal({required this.recipe, required this.onUpdated});

  @override
  ConsumerState<_EditRecipeModal> createState() => _EditRecipeModalState();
}

class _EditRecipeModalState extends ConsumerState<_EditRecipeModal> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _instructionsController;
  late TextEditingController _cookingTimeController;
  late TextEditingController _servingsController;

  late List<String> _selectedCategories;
  late List<_RecipeIngredientItem> _ingredients;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Pre-populate form with existing recipe data
    _titleController = TextEditingController(text: widget.recipe.title);
    _descriptionController = TextEditingController(
      text: widget.recipe.description,
    );
    _instructionsController = TextEditingController(
      text: widget.recipe.instructions,
    );
    _cookingTimeController = TextEditingController(
      text: widget.recipe.cookingTime.toString(),
    );
    _servingsController = TextEditingController(
      text: widget.recipe.servings?.toString() ?? '',
    );

    _selectedCategories = List<String>.from(widget.recipe.categories ?? []);

    // Convert recipe ingredients to editable items
    _ingredients =
        widget.recipe.ingredients?.map((ri) {
          return _RecipeIngredientItem(
            ingredientId: ri.ingredientId ?? ri.id,
            name: ri.name,
            quantity: ri.quantityNeeded,
            unit: ri.unit,
          );
        }).toList() ??
        [];

    // Load ingredients for dropdown
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(ingredientProvider.notifier).loadIngredients();
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _instructionsController.dispose();
    _cookingTimeController.dispose();
    _servingsController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
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
      final updatedRecipe = await ref
          .read(recipeRepositoryProvider)
          .updateRecipe(
            id: widget.recipe.id,
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
                    'id': i.ingredientId,
                    'quantity_needed': i.quantity,
                    'unit': i.unit,
                  },
                )
                .toList(),
          );

      if (mounted) {
        setState(() => _isLoading = false);
        Navigator.pop(context);
        widget.onUpdated(updatedRecipe);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Resep berhasil diperbarui'),
            backgroundColor: AppColors.successGreen,
          ),
        );
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
                ingredientId: ingredient.id,
                name: ingredient.name,
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
                    'Edit Resep',
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
                          title: Text(item.name),
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
  final int ingredientId;
  final String name;
  final double quantity;
  final String unit;

  _RecipeIngredientItem({
    required this.ingredientId,
    required this.name,
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
