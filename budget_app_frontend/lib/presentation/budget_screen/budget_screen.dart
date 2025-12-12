import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'dart:ui';

import '../../core/app_export.dart';
import 'widgets/category_search_bar_widget.dart';
import 'widgets/empty_state_widget.dart';
import 'widgets/time_period_toggle_widget.dart';
import '../../widgets/app_bottom_nav.dart';

// Palette constants (matching dashboard design system)
const Color kPrimary = Color(0xFF29A385);
const Color kPrimaryText = Color(0xFFFFFFFF);
const Color kSecondary = Color(0xFFEDF0F3);
const Color kSecondaryText = Color(0xFF303A50);
const Color kAccent = Color(0xFFECF9F5);
const Color kAccentText = Color(0xFF1F7A63);
const Color kBaseBackground = Color(0xFFF9FAFB);
const Color kBaseText = Color(0xFF131720);
const Color kCard = Color(0xFFFFFFFF);
const Color kCardText = Color(0xFF131720);
const Color kMuted = Color(0xFFE8EBEE);
const Color kMutedText = Color(0xFF676F7E);
const Color kDestructive = Color(0xFFDC2828);
const Color kDestructiveText = Color(0xFFFFFFFF);
const Color kBorder = Color(0xFFE0E5EB);
const Color kInput = Color(0xFFE0E5EB);
const Color kFocusRing = Color(0xFF29A385);

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen>
    with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _budgetAmountController = TextEditingController();
  String _selectedPeriod = 'monthly';
  List<Map<String, dynamic>> _categories = [];
  List<Map<String, dynamic>> _filteredCategories = [];
  late AnimationController _animationController;

  final List<Map<String, dynamic>> _mockCategories = [
    {
      "id": 1,
      "name": "Food & Dining",
      "icon": "shopping_cart",
      "color": 0xFF10B981,
      "budget": 800.0,
      "spent": 650.0,
      "isCustom": false,
    },
    {
      "id": 2,
      "name": "Transportation",
      "icon": "directions_car",
      "color": 0xFF3B82F6,
      "budget": 400.0,
      "spent": 280.0,
      "isCustom": false,
    },
    {
      "id": 3,
      "name": "Shopping",
      "icon": "shopping_bag",
      "color": 0xFFEC4899,
      "budget": 300.0,
      "spent": 320.0,
      "isCustom": false,
    },
    {
      "id": 4,
      "name": "Housing",
      "icon": "home",
      "color": 0xFF8B5CF6,
      "budget": 1200.0,
      "spent": 1200.0,
      "isCustom": false,
    },
    {
      "id": 5,
      "name": "Entertainment",
      "icon": "movie",
      "color": 0xFFF59E0B,
      "budget": 200.0,
      "spent": 150.0,
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
    {
      "id": 7,
      "name": "Healthcare",
      "icon": "medical_services",
      "color": 0xFFEF4444,
      "budget": 500.0,
      "spent": 320.0,
      "isCustom": false,
    },
    {
      "id": 8,
      "name": "Other",
      "icon": "category",
      "color": 0xFF6B7280,
      "budget": 300.0,
      "spent": 180.0,
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
    _budgetAmountController.dispose();
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
      _updateSpendingForPeriod(period);
    });
  }

  void _updateSpendingForPeriod(String period) {
    final multiplier = period == 'weekly' ? 0.25 : 1.0;
    setState(() {
      for (int i = 0; i < _categories.length; i++) {
        final originalSpent = _mockCategories[i]['spent'] as double;
        _categories[i]['spent'] = originalSpent * multiplier;
      }
      _filteredCategories = List.from(_categories);
    });
  }

  void _editCategory(Map<String, dynamic> category) {
    _showEditCategoryModal(category);
  }

  void _showAddCategoryModal() {
    String? selectedCategory;
    final TextEditingController budgetController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          padding: EdgeInsets.all(5.w),
          constraints: BoxConstraints(maxWidth: 400),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with close button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Add Budget',
                    style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              SizedBox(height: 3.h),
              // Category Dropdown
              Text(
                'Category',
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: kMutedText,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 1.h),
              StatefulBuilder(
                builder: (context, setDialogState) => DropdownButtonFormField<String>(
                  initialValue: selectedCategory,
                  decoration: InputDecoration(
                    hintText: 'Select category',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: kBorder),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: kBorder),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: kPrimary, width: 2),
                    ),
                    contentPadding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
                  ),
                  items: _mockCategories.map((category) {
                    return DropdownMenuItem<String>(
                      value: category['name'],
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(2.w),
                            decoration: BoxDecoration(
                              color: Color(category['color']).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: CustomIconWidget(
                              iconName: category['icon'],
                              size: 5.w,
                              color: Color(category['color']),
                            ),
                          ),
                          SizedBox(width: 3.w),
                          Text(category['name']),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setDialogState(() {
                      selectedCategory = value;
                    });
                  },
                ),
              ),
              SizedBox(height: 3.h),
              // Budget Amount
              Text(
                'Budget Amount',
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: kMutedText,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 1.h),
              TextField(
                controller: budgetController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  hintText: 'KSh',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: kBorder),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: kBorder),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: kPrimary, width: 2),
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
                ),
              ),
              SizedBox(height: 4.h),
              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.5.h),
                    ),
                    child: Text(
                      'Cancel',
                      style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                        color: kMutedText,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  SizedBox(width: 2.w),
                  ElevatedButton(
                    onPressed: () {
                      if (selectedCategory != null && budgetController.text.isNotEmpty) {
                        final selectedCategoryData = _mockCategories.firstWhere(
                          (cat) => cat['name'] == selectedCategory,
                        );
                        final newBudget = {
                          'id': _categories.length + 1,
                          'name': selectedCategory!,
                          'icon': selectedCategoryData['icon'],
                          'color': selectedCategoryData['color'],
                          'budget': double.parse(budgetController.text),
                          'spent': 0.0,
                          'isCustom': true,
                        };
                        setState(() {
                          _categories.add(newBudget);
                          _filteredCategories = List.from(_categories);
                        });
                        Navigator.pop(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimary,
                      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.5.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Add Budget',
                      style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditCategoryModal(Map<String, dynamic> category) {
    _budgetAmountController.text = category['budget'].toString();
    
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: EdgeInsets.all(5.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Text(
                'Edit Budget',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  color: kBaseText,
                ),
              ),
              SizedBox(height: 3.h),
              
              // Category Dropdown
              Text(
                'Category',
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                  color: kBaseText,
                ),
              ),
              SizedBox(height: 1.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 3.w),
                decoration: BoxDecoration(
                  border: Border.all(color: kBorder, width: 1.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButton<String>(
                  value: category['name'],
                  isExpanded: true,
                  underline: SizedBox.shrink(),
                  items: _categories
                      .map<DropdownMenuItem<String>>((cat) => DropdownMenuItem<String>(
                        value: cat['name'] as String,
                        child: Row(
                          children: [
                            Icon(
                              _getIconForCategory(cat['icon']),
                              color: Color(cat['color']),
                              size: 5.w,
                            ),
                            SizedBox(width: 2.w),
                            Text(
                              cat['name'],
                              style: TextStyle(
                                fontSize: 13.sp,
                                color: kBaseText,
                              ),
                            ),
                          ],
                        ),
                      ))
                      .toList(),
                  onChanged: (value) {},
                ),
              ),
              SizedBox(height: 2.5.h),
              
              // Budget Amount Input
              Text(
                'Budget Amount',
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                  color: kBaseText,
                ),
              ),
              SizedBox(height: 1.h),
              TextField(
                controller: _budgetAmountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Enter budget amount',
                  hintStyle: TextStyle(color: kMutedText),
                  contentPadding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 2.h),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: kBorder, width: 1.5),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: kBorder, width: 1.5),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: kPrimary, width: 2),
                  ),
                ),
                style: TextStyle(
                  fontSize: 15.sp,
                  color: kBaseText,
                ),
              ),
              SizedBox(height: 3.h),
              
              // Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        _budgetAmountController.clear();
                        Navigator.pop(context);
                      },
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 2.h),
                        side: BorderSide(color: kBorder, width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                          color: kBaseText,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        final newBudget = double.tryParse(_budgetAmountController.text);
                        if (newBudget != null) {
                          setState(() {
                            final index = _categories.indexWhere((c) => c['id'] == category['id']);
                            if (index != -1) {
                              _categories[index]['budget'] = newBudget;
                              _filteredCategories = List.from(_categories);
                            }
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Budget updated successfully'),
                              backgroundColor: kPrimary,
                            ),
                          );
                          _budgetAmountController.clear();
                          Navigator.pop(context);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kPrimary,
                        padding: EdgeInsets.symmetric(vertical: 2.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Update Budget',
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getIconForCategory(String iconName) {
    switch (iconName.toLowerCase()) {
      case 'shopping_cart':
        return Icons.shopping_cart;
      case 'shopping_bag':
        return Icons.shopping_bag;
      case 'restaurant':
        return Icons.restaurant;
      case 'directions_car':
        return Icons.directions_car;
      case 'home':
        return Icons.home;
      case 'movie':
        return Icons.movie;
      case 'medical_services':
        return Icons.medical_services;
      case 'electric_bolt':
        return Icons.electric_bolt;
      default:
        return Icons.category;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBaseBackground,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        title: Text(
          'Budgets',
          style: TextStyle(
            color: kBaseText,
            fontSize: 20.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: false,
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 4.w),
            child: ElevatedButton(
              onPressed: _showAddCategoryModal,
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimary,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.add, size: 18),
                  SizedBox(width: 1.w),
                  Text(
                    'Add Category',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: _buildContent(),
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: 2,
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushNamedAndRemoveUntil(
                context,
                AppRoutes.dashboardHome,
                (route) => false,
              );
              break;
            case 1:
              Navigator.pushNamed(context, '/transaction-history-screen');
              break;
            case 2:
              // current screen
              break;
            case 3:
              Navigator.pushNamed(context, '/reports-screen');
              break;
            case 4:
              Navigator.pushNamed(context, '/goals-screen');
              break;
          }
        },
      ),
    );
  }

  Widget _buildContent() {
    // Calculate aggregate stats
    double totalBudget = 0;
    double totalSpent = 0;
    for (var category in _categories) {
      totalBudget += (category['budget'] as double);
      totalSpent += (category['spent'] as double);
    }
    double remaining = totalBudget - totalSpent;
    

    if (_filteredCategories.isEmpty && _categories.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              color: Colors.grey[400],
              size: 64,
            ),
            SizedBox(height: 2.h),
            Text(
              'No categories found',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: kBaseText,
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              'Try adjusting your search',
              style: TextStyle(
                fontSize: 15.sp,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }
    
    if (_categories.isEmpty) {
      return EmptyStateWidget(onCreateCategory: _showAddCategoryModal);
    }
    
    return RefreshIndicator(
      onRefresh: () async {
        await Future.delayed(const Duration(milliseconds: 500));
        setState(() {
          _categories = List.from(_mockCategories);
          _filteredCategories = List.from(_categories);
        });
      },
      child: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 2.h),
            // Summary cards (Dashboard/Goals theme)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Row(
                children: [
                  Expanded(
                    child: _buildSummaryCard(label: 'Total Budget', value: '\$${totalBudget.toStringAsFixed(0)}'),
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: _buildSummaryCard(label: 'Total Spent', value: '\$${totalSpent.toStringAsFixed(0)}'),
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: _buildSummaryCard(label: 'Remaining', value: '\$${remaining.toStringAsFixed(0)}'),
                  ),
                ],
              ),
            ),
            SizedBox(height: 2.5.h),
            // Search and Period controls
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Column(
                children: [
                  CategorySearchBarWidget(
                    controller: _searchController,
                    onChanged: _filterCategories,
                    onClear: _clearSearch,
                  ),
                  SizedBox(height: 1.5.h),
                  TimePeriodToggleWidget(
                    selectedPeriod: _selectedPeriod,
                    onPeriodChanged: _onPeriodChanged,
                  ),
                ],
              ),
            ),
            SizedBox(height: 2.h),
            // Categories Grid
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: GridView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 3.w,
                  mainAxisSpacing: 2.h,
                  childAspectRatio: 0.85,
                ),
                itemCount: _filteredCategories.length,
                itemBuilder: (context, index) {
                  final category = _filteredCategories[index];
                  return _buildCategoryGridCard(category);
                },
              ),
            ),
            SizedBox(height: 4.h),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard({required String label, required String value}) {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kBorder, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16.sp,
              color: kMutedText,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 0.5.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w700,
              color: kBaseText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryGridCard(Map<String, dynamic> category) {
    double percentage = category['budget'] > 0 
        ? (category['spent'] / category['budget']) * 100 
        : 0;
    
    Color progressColor = kPrimary;
    if (percentage > 100) {
      progressColor = Color(0xFFDC2828);
    } else if (percentage > 80) {
      progressColor = Color(0xFFF59E0B);
    }

    return GestureDetector(
      onTap: () => _editCategory(category),
      child: Container(
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: kCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: kBorder, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header - Icon and Edit button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: EdgeInsets.all(2.w),
                  decoration: BoxDecoration(
                    color: Color(category['color']).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getIconForCategory(category['icon']),
                    color: Color(category['color']),
                    size: 24,
                  ),
                ),
                Icon(
                  Icons.more_vert,
                  color: kMutedText,
                  size: 20,
                ),
              ],
            ),
            SizedBox(height: 2.h),
            // Category name
            Text(
              category['name'],
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
                color: kBaseText,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 0.5.h),
            // Percentage display
            Text(
              '${percentage.toStringAsFixed(0)}% used',
              style: TextStyle(
                fontSize: 14.sp,
                color: kMutedText,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 1.5.h),
            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: (percentage / 100).clamp(0.0, 1.0),
                minHeight: 6,
                backgroundColor: kMuted,
                valueColor: AlwaysStoppedAnimation<Color>(progressColor),
              ),
            ),
            SizedBox(height: 1.5.h),
            // Spent / Budget amounts
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Spent',
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: kMutedText,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '\$${category['spent'].toStringAsFixed(0)}',
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w700,
                        color: kBaseText,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Budget',
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: kMutedText,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '\$${category['budget'].toStringAsFixed(0)}',
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w700,
                        color: kBaseText,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
