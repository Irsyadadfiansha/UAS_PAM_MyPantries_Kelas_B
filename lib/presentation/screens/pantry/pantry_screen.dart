import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../data/models/pantry_item_model.dart';
import '../../../data/models/ingredient_model.dart';
import '../../../data/repositories/ingredient_repository.dart';
import '../../providers/pantry_provider.dart';
import '../../providers/ingredient_provider.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/empty_state_widget.dart';
import '../../widgets/common/error_widget.dart';

/// Pantry screen
class PantryScreen extends ConsumerStatefulWidget {
  const PantryScreen({super.key});

  @override
  ConsumerState<PantryScreen> createState() => _PantryScreenState();
}

class _PantryScreenState extends ConsumerState<PantryScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(pantryProvider.notifier).loadPantryItems();
      ref.read(ingredientProvider.notifier).loadIngredients();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showAddItemModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _AddPantryItemModal(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pantryState = ref.watch(pantryProvider);
    final categories = ['Semua', ...IngredientCategories.all];

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.pantryTitle),
        backgroundColor: AppColors.primaryDark,
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                ref.read(pantryProvider.notifier).setSearchQuery(value);
              },
              decoration: InputDecoration(
                hintText: AppStrings.searchIngredients,
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          ref.read(pantryProvider.notifier).setSearchQuery('');
                        },
                      )
                    : null,
              ),
            ),
          ),

          // Category filter
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final category = categories[index];
                final selectedCat = pantryState.selectedCategory;
                final isSelected =
                    (selectedCat == null && category == 'Semua') ||
                    selectedCat == category;
                return FilterChip(
                  label: Text(category),
                  selected: isSelected,
                  onSelected: (_) {
                    // Always allow clicking - toggle off if already selected
                    if (category == 'Semua') {
                      ref.read(pantryProvider.notifier).setCategory(null);
                    } else {
                      ref.read(pantryProvider.notifier).setCategory(category);
                    }
                  },
                  selectedColor: AppColors.primaryDark,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : AppColors.textPrimary,
                    fontSize: 12,
                  ),
                  showCheckmark: false,
                );
              },
            ),
          ),
          const SizedBox(height: 16),

          // Content
          Expanded(child: _buildContent(pantryState)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddItemModal,
        icon: const Icon(Icons.add),
        label: const Text(AppStrings.addPantryItem),
      ),
    );
  }

  Widget _buildContent(PantryState state) {
    if (state.isLoading) {
      return const ShimmerGridLoader();
    }

    if (state.error != null) {
      return AppErrorWidget(
        message: state.error,
        onRetry: () => ref.read(pantryProvider.notifier).loadPantryItems(),
      );
    }

    final items = state.filteredItems;
    if (items.isEmpty) {
      return EmptyStateWidget.pantry(onAddItem: _showAddItemModal);
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(pantryProvider.notifier).loadPantryItems(),
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          mainAxisExtent: 160,
        ),
        itemCount: items.length,
        itemBuilder: (context, index) {
          return _PantryItemCard(item: items[index]);
        },
      ),
    );
  }
}

class _PantryItemCard extends ConsumerWidget {
  final PantryItem item;

  const _PantryItemCard({required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: item.isExpiringSoon
              ? AppColors.warningAmber.withValues(alpha: 0.5)
              : AppColors.borderLight,
        ),
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category icon
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color:
                        AppColors.categoryColors[item.ingredientCategory] ??
                        AppColors.surfaceBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getCategoryIcon(item.ingredientCategory),
                    size: 20,
                    color:
                        AppColors.categoryIconColors[item.ingredientCategory],
                  ),
                ),
                const Spacer(),
                // Name
                Text(
                  item.ingredientName,
                  style: Theme.of(context).textTheme.titleMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                // Quantity
                Text(
                  item.formattedQuantity,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
                ),
                // Price
                if (item.pricePer100g != null) ...[
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(
                        item.formattedPricePer100g!,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      if (item.priceTrend != null) ...[
                        const SizedBox(width: 4),
                        Icon(
                          item.priceTrend == 'up'
                              ? Icons.trending_up
                              : Icons.trending_down,
                          size: 12,
                          color: item.priceTrend == 'up'
                              ? AppColors.dangerRed
                              : AppColors.successGreen,
                        ),
                      ],
                    ],
                  ),
                ],
              ],
            ),
          ),
          // Expiry badge
          if (item.isExpiringSoon)
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.warningAmber,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '${item.daysUntilExpiry}d',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          // Delete button
          Positioned(
            bottom: 8,
            right: 8,
            child: IconButton(
              icon: const Icon(Icons.delete_outline, size: 20),
              color: AppColors.textMuted,
              onPressed: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text(AppStrings.deleteConfirmTitle),
                    content: const Text(AppStrings.deleteConfirmMessage),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text(AppStrings.cancel),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.dangerRed,
                        ),
                        child: const Text(AppStrings.delete),
                      ),
                    ],
                  ),
                );
                if (confirmed == true) {
                  ref.read(pantryProvider.notifier).deleteItem(item.id);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Protein':
        return Icons.egg_alt;
      case 'Sayuran':
        return Icons.grass;
      case 'Susu':
        return Icons.water_drop;
      case 'Biji-Bijian':
        return Icons.grain;
      case 'Buah':
        return Icons.apple;
      case 'Bumbu & Saus':
        return Icons.local_dining;
      case 'Rempah':
        return Icons.spa;
      case 'Mineral':
        return Icons.water_drop;
      default:
        return Icons.kitchen;
    }
  }
}

class _AddPantryItemModal extends ConsumerStatefulWidget {
  const _AddPantryItemModal();

  @override
  ConsumerState<_AddPantryItemModal> createState() =>
      _AddPantryItemModalState();
}

class _AddPantryItemModalState extends ConsumerState<_AddPantryItemModal> {
  final _formKey = GlobalKey<FormState>();
  Ingredient? _selectedIngredient;
  final _quantityController = TextEditingController();
  String _selectedUnit = 'g';
  final _priceController = TextEditingController();
  DateTime? _expiryDate;
  bool _isLoading = false;

  @override
  void dispose() {
    _quantityController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedIngredient == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih bahan terlebih dahulu')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final success = await ref
        .read(pantryProvider.notifier)
        .addItem(
          ingredientId: _selectedIngredient!.id,
          quantity: double.parse(_quantityController.text),
          unit: _selectedUnit,
          price: _priceController.text.isNotEmpty
              ? double.parse(_priceController.text)
              : null,
          expiryDate: _expiryDate,
        );

    setState(() => _isLoading = false);

    if (success && mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bahan berhasil ditambahkan'),
          backgroundColor: AppColors.successGreen,
        ),
      );
    }
  }

  void _showCreateIngredientDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => _CreateIngredientDialog(
        onCreated: (ingredient) async {
          // Refresh ingredient list first
          await ref.read(ingredientProvider.notifier).loadIngredients();

          // Close the add pantry modal and let user re-open
          if (mounted) {
            Navigator.pop(context); // Close add pantry modal
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Bahan "${ingredient.name}" berhasil dibuat. Silakan tambahkan ke pantry.',
                ),
                backgroundColor: AppColors.successGreen,
                action: SnackBarAction(
                  label: 'Tambah',
                  textColor: Colors.white,
                  onPressed: () {
                    // Re-open modal to add the new ingredient
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (context) => const _AddPantryItemModal(),
                    );
                  },
                ),
              ),
            );
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ingredientState = ref.watch(ingredientProvider);

    return Container(
      margin: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 40),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
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
              child: Text(
                AppStrings.addPantryItem,
                style: Theme.of(context).textTheme.headlineSmall,
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
                    // Ingredient dropdown
                    DropdownButtonFormField<Ingredient>(
                      value: _selectedIngredient,
                      decoration: const InputDecoration(
                        labelText: AppStrings.ingredient,
                        prefixIcon: Icon(Icons.restaurant_menu),
                      ),
                      items: ingredientState.ingredients.map((i) {
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
                    const SizedBox(height: 8),

                    // TextButton for creating new ingredient
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
                        onPressed: _showCreateIngredientDialog,
                        icon: const Icon(Icons.add_circle_outline, size: 18),
                        label: const Text('Bahan tidak ada di daftar?'),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.primaryDark,
                          padding: EdgeInsets.zero,
                          textStyle: const TextStyle(fontSize: 13),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Quantity and Unit
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: TextFormField(
                            controller: _quantityController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: AppStrings.quantity,
                              prefixIcon: Icon(Icons.numbers),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Wajib diisi';
                              }
                              if (double.tryParse(value) == null) {
                                return 'Angka tidak valid';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _selectedUnit,
                            decoration: const InputDecoration(
                              labelText: AppStrings.unit,
                            ),
                            items: PantryUnits.all.map((u) {
                              return DropdownMenuItem(value: u, child: Text(u));
                            }).toList(),
                            onChanged: (value) {
                              setState(() => _selectedUnit = value!);
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Price (optional)
                    TextFormField(
                      controller: _priceController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: '${AppStrings.price} (opsional)',
                        prefixIcon: Icon(Icons.attach_money),
                        hintText: 'Rp',
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Expiry date
                    InkWell(
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now().add(
                            const Duration(days: 7),
                          ),
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(
                            const Duration(days: 365),
                          ),
                        );
                        if (date != null) {
                          setState(() => _expiryDate = date);
                        }
                      },
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: AppStrings.expiryDate,
                          prefixIcon: Icon(Icons.calendar_today),
                        ),
                        child: Text(
                          _expiryDate != null
                              ? '${_expiryDate!.day}/${_expiryDate!.month}/${_expiryDate!.year}'
                              : 'Pilih tanggal',
                          style: TextStyle(
                            color: _expiryDate != null
                                ? AppColors.textPrimary
                                : AppColors.textMuted,
                          ),
                        ),
                      ),
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

/// Dialog for creating a new ingredient
class _CreateIngredientDialog extends ConsumerStatefulWidget {
  final Function(Ingredient) onCreated;

  const _CreateIngredientDialog({required this.onCreated});

  @override
  ConsumerState<_CreateIngredientDialog> createState() =>
      _CreateIngredientDialogState();
}

class _CreateIngredientDialogState
    extends ConsumerState<_CreateIngredientDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  String? _selectedCategory;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _handleCreate() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategory == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Pilih kategori bahan')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final ingredient = await ref
          .read(ingredientRepositoryProvider)
          .createIngredient(
            name: _nameController.text.trim(),
            category: _selectedCategory!,
          );

      if (mounted) {
        Navigator.pop(context);
        widget.onCreated(ingredient);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Bahan "${ingredient.name}" berhasil ditambahkan'),
            backgroundColor: AppColors.successGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal membuat bahan: $e'),
            backgroundColor: AppColors.dangerRed,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Tambah Bahan Baru'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nama Bahan',
                prefixIcon: Icon(Icons.restaurant_menu),
              ),
              textCapitalization: TextCapitalization.words,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Nama bahan wajib diisi';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Kategori',
                prefixIcon: Icon(Icons.category),
              ),
              items: IngredientCategories.all.map((c) {
                return DropdownMenuItem(value: c, child: Text(c));
              }).toList(),
              onChanged: (value) {
                setState(() => _selectedCategory = value);
              },
              validator: (value) {
                if (value == null) return 'Pilih kategori';
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(AppStrings.cancel),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _handleCreate,
          child: _isLoading
              ? const SizedBox(
                  height: 16,
                  width: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text('Buat Bahan'),
        ),
      ],
    );
  }
}
