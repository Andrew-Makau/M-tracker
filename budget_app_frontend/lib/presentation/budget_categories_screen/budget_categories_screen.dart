import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/add_category_modal_widget.dart';
import './widgets/category_card_widget.dart';
import './widgets/category_search_bar_widget.dart';
import './widgets/empty_state_widget.dart';
import './widgets/time_period_toggle_widget.dart';

class BudgetCategoriesScreen extends StatefulWidget {
  const BudgetCategoriesScreen({super.key});

  @override
  State<BudgetCategoriesScreen> createState() => _BudgetCategoriesScreenState();
}

class _BudgetCategoriesScreenState extends State<BudgetCategoriesScreen>
    with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  String _selectedPeriod = 'monthly';
  List<Map<String, dynamic>> _categories = [];
  List<Map<String, dynamic>> _filteredCategories = [];
  bool _isMultiSelectMode = false;
  final Set<int> _selectedCategoryIds = {};
  late AnimationController _animationController;

  final List<Map<String, dynamic>> _mockCategories = [
    {
      "id": 1,
      "name": "Groceries",
      "icon": "shopping_cart",
      "color": 0xFF10B981,
      "budget": 800.0,
      "spent": 650.0,
      "isCustom": false,
    },
    {
      "id": 2,
      "name": "Dining Out",
      "icon": "restaurant",
      "color": 0xFFF59E0B,
      "budget": 400.0,
      "spent": 420.0,
      "isCustom": false,
    },
    {
      "id": 3,
      "name": "Transportation",
      "icon": "directions_car",
      "color": 0xFF3B82F6,
      "budget": 300.0,
      "spent": 180.0,
      "isCustom": false,
    },
    {
      "id": 4,
      "name": "Entertainment",
      "icon": "movie",
      "color": 0xFF8B5CF6,
      "budget": 200.0,
      "spent": 150.0,
      "isCustom": false,
    },
    {
      "id": 5,
      "name": "Healthcare",
      "icon": "medical_services",
      "color": 0xFFEF4444,
      "budget": 500.0,
      "spent": 320.0,
      "isCustom": false,
    },
    {
      "id": 6,
      "name": "Utilities",
      "icon": "electric_bolt",
      "color": 0xFFF97316,
      "budget": 250.0,
      "spent": 240.0,
      "isCustom": false,
    },
  ];

  @override
  void initState() {
    super.initState();
    _categories = List.from(_mockCategories);
    _filteredCategories = List.from(_categories);
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _filterCategories(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredCategories = List.from(_categories);
      } else {
        _filteredCategories = _categories
            .where((category) => (category['name'] as String)
                .toLowerCase()
                .contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  void _clearSearch() {
    _searchController.clear();
    _filterCategories('');
  }

  void _onPeriodChanged(String period) {
    setState(() {
      _selectedPeriod = period;
      // Update spending data based on period
      _updateSpendingForPeriod(period);
    });
  }

  void _updateSpendingForPeriod(String period) {
    // Simulate different spending amounts for weekly vs monthly
    final multiplier = period == 'weekly' ? 0.25 : 1.0;

    setState(() {
      for (int i = 0; i < _categories.length; i++) {
        final originalSpent = _mockCategories[i]['spent'] as double;
        _categories[i]['spent'] = originalSpent * multiplier;
      }
      _filteredCategories = List.from(_categories);
    });
  }

  void _navigateToCategory(Map<String, dynamic> category) {
    Navigator.pushNamed(context, '/transaction-history-screen');
  }

  void _editCategory(Map<String, dynamic> category) {
    // Show edit category modal
    _showEditCategoryModal(category);
  }

  void _deleteCategory(Map<String, dynamic> category) {
    if (category['isCustom'] == true) {
      _showDeleteConfirmation(category);
    }
  }

  void _viewTransactions(Map<String, dynamic> category) {
    Navigator.pushNamed(context, '/transaction-history-screen');
  }

  void _setAlerts(Map<String, dynamic> category) {
    _showAlertsModal(category);
  }

  void _showAddCategoryModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddCategoryModalWidget(
        onCategoryAdded: (category) {
          setState(() {
            _categories.add(category);
            _filteredCategories = List.from(_categories);
          });
        },
      ),
    );
  }

  void _showEditCategoryModal(Map<String, dynamic> category) {
    // Implementation for edit category modal
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Edit ${category['name']} category'),
        backgroundColor: AppTheme.lightTheme.colorScheme.secondary,
      ),
    );
  }

  void _showDeleteConfirmation(Map<String, dynamic> category) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Category'),
        content: Text('Are you sure you want to delete "${category['name']}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _categories.removeWhere((c) => c['id'] == category['id']);
                _filteredCategories = List.from(_categories);
              });
              Navigator.pop(context);
            },
            child: Text(
              'Delete',
              style: TextStyle(color: AppTheme.lightTheme.colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }

  void _showAlertsModal(Map<String, dynamic> category) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Set alerts for ${category['name']}'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _toggleMultiSelectMode() {
    setState(() {
      _isMultiSelectMode = !_isMultiSelectMode;
      if (!_isMultiSelectMode) {
        _selectedCategoryIds.clear();
      }
    });
  }

  void _onCategoryLongPress(Map<String, dynamic> category) {
    if (!_isMultiSelectMode) {
      _toggleMultiSelectMode();
    }
    _toggleCategorySelection(category['id'] as int);
  }

  void _toggleCategorySelection(int categoryId) {
    setState(() {
      if (_selectedCategoryIds.contains(categoryId)) {
        _selectedCategoryIds.remove(categoryId);
      } else {
        _selectedCategoryIds.add(categoryId);
      }
    });
  }

  void _performBulkAction(String action) {
    switch (action) {
      case 'delete':
        _bulkDeleteCategories();
        break;
      case 'adjust':
        _bulkAdjustBudgets();
        break;
    }
  }

  void _bulkDeleteCategories() {
    setState(() {
      _categories.removeWhere((category) =>
          _selectedCategoryIds.contains(category['id']) &&
          category['isCustom'] == true);
      _filteredCategories = List.from(_categories);
      _selectedCategoryIds.clear();
      _isMultiSelectMode = false;
    });
  }

  void _bulkAdjustBudgets() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            'Bulk budget adjustment for ${_selectedCategoryIds.length} categories'),
        backgroundColor: AppTheme.lightTheme.colorScheme.secondary,
      ),
    );
    setState(() {
      _selectedCategoryIds.clear();
      _isMultiSelectMode = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: BrandAppBar(
        title: Text(
          'Budget Categories',
          style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        // keep transparent background so the gradient shows through
        backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: CustomIconWidget(
            iconName: 'arrow_back',
            color: AppTheme.lightTheme.colorScheme.onSurface,
            size: 6.w,
          ),
        ),
        actions: [
          if (_isMultiSelectMode) ...[
            IconButton(
              onPressed: () => _performBulkAction('adjust'),
              icon: CustomIconWidget(
                iconName: 'tune',
                color: AppTheme.lightTheme.colorScheme.onSurface,
                size: 6.w,
              ),
            ),
            IconButton(
              onPressed: () => _performBulkAction('delete'),
              icon: CustomIconWidget(
                iconName: 'delete',
                color: AppTheme.lightTheme.colorScheme.error,
                size: 6.w,
              ),
            ),
            IconButton(
              onPressed: _toggleMultiSelectMode,
              icon: CustomIconWidget(
                iconName: 'close',
                color: AppTheme.lightTheme.colorScheme.onSurface,
                size: 6.w,
              ),
            ),
          ] else ...[
            IconButton(
              onPressed: _showAddCategoryModal,
              icon: CustomIconWidget(
                iconName: 'add',
                color: AppTheme.lightTheme.colorScheme.secondary,
                size: 6.w,
              ),
            ),
          ],
        ],
      ),
      body: _filteredCategories.isEmpty && _categories.isNotEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomIconWidget(
                    iconName: 'search_off',
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    size: 20.w,
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    'No categories found',
                    style: AppTheme.lightTheme.textTheme.titleMedium,
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    'Try adjusting your search',
                    style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            )
          : _categories.isEmpty
              ? EmptyStateWidget(onCreateCategory: _showAddCategoryModal)
              : RefreshIndicator(
                  onRefresh: () async {
                    await Future.delayed(const Duration(milliseconds: 500));
                    setState(() {
                      _categories = List.from(_mockCategories);
                      _filteredCategories = List.from(_categories);
                    });
                  },
                  child: Column(
                    children: [
                      CategorySearchBarWidget(
                        controller: _searchController,
                        onChanged: _filterCategories,
                        onClear: _clearSearch,
                      ),
                      TimePeriodToggleWidget(
                        selectedPeriod: _selectedPeriod,
                        onPeriodChanged: _onPeriodChanged,
                      ),
                      if (_isMultiSelectMode)
                        Container(
                          margin: EdgeInsets.symmetric(
                              horizontal: 4.w, vertical: 1.h),
                          padding: EdgeInsets.all(3.w),
                          decoration: BoxDecoration(
                            color: AppTheme.lightTheme.colorScheme.secondary
                                .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              CustomIconWidget(
                                iconName: 'info',
                                color:
                                    AppTheme.lightTheme.colorScheme.secondary,
                                size: 5.w,
                              ),
                              SizedBox(width: 2.w),
                              Text(
                                '${_selectedCategoryIds.length} categories selected',
                                style: AppTheme.lightTheme.textTheme.bodyMedium
                                    ?.copyWith(
                                  color:
                                      AppTheme.lightTheme.colorScheme.secondary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      Expanded(
                        child: AnimatedBuilder(
                          animation: _animationController,
                          builder: (context, child) {
                            return ListView.builder(
                              padding: EdgeInsets.only(bottom: 10.h),
                              itemCount: _filteredCategories.length,
                              itemBuilder: (context, index) {
                                final category = _filteredCategories[index];
                                final isSelected = _selectedCategoryIds
                                    .contains(category['id']);

                                return GestureDetector(
                                  onLongPress: () =>
                                      _onCategoryLongPress(category),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? AppTheme
                                              .lightTheme.colorScheme.secondary
                                              .withValues(alpha: 0.1)
                                          : null,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Stack(
                                      children: [
                                        CategoryCardWidget(
                                          category: category,
                                          onTap: () {
                                            if (_isMultiSelectMode) {
                                              _toggleCategorySelection(
                                                  category['id'] as int);
                                            } else {
                                              _navigateToCategory(category);
                                            }
                                          },
                                          onEdit: () => _editCategory(category),
                                          onDelete: () =>
                                              _deleteCategory(category),
                                          onViewTransactions: () =>
                                              _viewTransactions(category),
                                          onSetAlerts: () =>
                                              _setAlerts(category),
                                        ),
                                        if (isSelected)
                                          Positioned(
                                            top: 2.h,
                                            right: 6.w,
                                            child: Container(
                                              width: 6.w,
                                              height: 6.w,
                                              decoration: BoxDecoration(
                                                color: AppTheme.lightTheme
                                                    .colorScheme.secondary,
                                                shape: BoxShape.circle,
                                              ),
                                              child: Center(
                                                child: CustomIconWidget(
                                                  iconName: 'check',
                                                  color: Colors.white,
                                                  size: 4.w,
                                                ),
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
      floatingActionButton: _categories.isNotEmpty && !_isMultiSelectMode
          ? FloatingActionButton(
              onPressed: _showAddCategoryModal,
              backgroundColor: AppTheme.lightTheme.colorScheme.secondary,
              child: CustomIconWidget(
                iconName: 'add',
                color: Colors.white,
                size: 6.w,
              ),
            )
          : null,
    );
  }
}
