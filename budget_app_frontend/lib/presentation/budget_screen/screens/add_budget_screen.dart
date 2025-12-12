import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../../core/app_export.dart';
import '../../login_screen/widgets/animated_gradient_background.dart';

class AddBudgetScreen extends StatefulWidget {
  const AddBudgetScreen({super.key});

  @override
  State<AddBudgetScreen> createState() => _AddBudgetScreenState();
}

class _AddBudgetScreenState extends State<AddBudgetScreen>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _budgetAmountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  String _selectedIcon = 'shopping_cart';
  int _selectedColor = 0xFF3B82F6;
  bool _isFormValid = false;

  final List<String> _categoryIcons = [
    'shopping_cart',
    'restaurant',
    'local_gas_station',
    'home',
    'directions_car',
    'medical_services',
    'school',
    'sports_esports',
    'movie',
    'fitness_center',
    'pets',
    'flight',
    'shopping_bag',
    'phone',
    'electric_bolt',
  ];

  final List<int> _categoryColors = [
    0xFF3B82F6, // Blue
    0xFF10B981, // Green
    0xFFF59E0B, // Yellow
    0xFFEF4444, // Red
    0xFF8B5CF6, // Purple
    0xFFF97316, // Orange
    0xFF06B6D4, // Cyan
    0xFFEC4899, // Pink
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _nameController.addListener(_validateForm);
    _budgetAmountController.addListener(_validateForm);
  }

  void _initializeAnimations() {
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    ));

    _slideController.forward();
    _fadeController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    _nameController.dispose();
    _budgetAmountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _validateForm() {
    setState(() {
      _isFormValid = _nameController.text.isNotEmpty &&
          _budgetAmountController.text.isNotEmpty &&
          double.tryParse(_budgetAmountController.text) != null;
    });
  }

  void _handleAddBudget() {
    if (!_isFormValid) return;

    final budget = {
      'name': _nameController.text,
      'amount': double.parse(_budgetAmountController.text),
      'description': _descriptionController.text,
      'icon': _selectedIcon,
      'color': _selectedColor,
    };

    Navigator.pop(context, budget);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.colorScheme.surface,
      body: Stack(
        children: [
          const AnimatedGradientBackground(),
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                child: SlideTransition(
                  position: _slideAnimation,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Back button
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: Container(
                                padding: EdgeInsets.all(2.5.w),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.2),
                                  ),
                                ),
                                child: CustomIconWidget(
                                  iconName: 'arrow_back',
                                  color: Colors.white,
                                  size: 6.w,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 3.h),
                        // Header
                        Text(
                          'Create Budget',
                          style: AppTheme.lightTheme.textTheme.headlineLarge
                              ?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 1.h),
                        Text(
                          'Set up a new budget to track your spending',
                          style:
                              AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                            color: Colors.white70,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        // Form
                        Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Budget Name
                              _buildFloatingTextField(
                                controller: _nameController,
                                label: 'Budget Name',
                                iconName: 'tag',
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter a budget name';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: 3.h),
                              // Budget Amount
                              _buildFloatingTextField(
                                controller: _budgetAmountController,
                                label: 'Budget Amount',
                                iconName: 'attach_money',
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter a budget amount';
                                  }
                                  if (double.tryParse(value) == null) {
                                    return 'Please enter a valid amount';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: 3.h),
                              // Description
                              _buildFloatingTextField(
                                controller: _descriptionController,
                                label: 'Description (Optional)',
                                iconName: 'description',
                                maxLines: 3,
                              ),
                              SizedBox(height: 3.h),
                              // Icon Selection
                              Text(
                                'Select Icon',
                                style: AppTheme.lightTheme.textTheme
                                    .titleMedium
                                    ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: 2.h),
                              _buildIconSelector(),
                              SizedBox(height: 3.h),
                              // Color Selection
                              Text(
                                'Select Color',
                                style: AppTheme.lightTheme.textTheme
                                    .titleMedium
                                    ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: 2.h),
                              _buildColorSelector(),
                              SizedBox(height: 4.h),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.all(4.w),
        child: SlideTransition(
          position: _slideAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: _buildCreateButton(),
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingTextField({
    required TextEditingController controller,
    required String label,
    required String iconName,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    int? maxLines,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 1.5.h),
      child: Material(
        color: AppTheme.lightTheme.colorScheme.surface.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(16),
        elevation: 6,
        child: TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines ?? 1,
          style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onPrimary,
          ),
          validator: validator,
          autovalidateMode: AutovalidateMode.disabled,
          decoration: InputDecoration(
            labelText: label,
            isDense: true,
            prefixIcon: Padding(
              padding: EdgeInsets.all(3.w),
              child: CustomIconWidget(
                iconName: iconName,
                size: 20,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
            filled: true,
            fillColor: Colors.transparent,
            contentPadding: EdgeInsets.fromLTRB(4.w, 2.h, 4.w, 2.2.h),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: Colors.white.withValues(alpha: 0.25),
                width: 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: Colors.white.withValues(alpha: 0.25),
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: AppTheme.lightTheme.colorScheme.primary,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: AppTheme.lightTheme.colorScheme.error,
                width: 1,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: AppTheme.lightTheme.colorScheme.error,
                width: 2,
              ),
            ),
            errorStyle: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.lightTheme.colorScheme.error,
              fontWeight: FontWeight.w600,
              height: 1.0,
            ),
            labelStyle: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: Colors.white70,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIconSelector() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _categoryIcons.map((icon) {
          final isSelected = icon == _selectedIcon;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedIcon = icon;
              });
            },
            child: Container(
              margin: EdgeInsets.only(right: 2.w),
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: isSelected
                    ? Color(_selectedColor)
                    : Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? Color(_selectedColor)
                      : Colors.white.withValues(alpha: 0.2),
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: CustomIconWidget(
                iconName: icon,
                color: isSelected ? Colors.white : Colors.white70,
                size: 6.w,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildColorSelector() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _categoryColors.map((color) {
          final isSelected = color == _selectedColor;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedColor = color;
              });
            },
            child: Container(
              margin: EdgeInsets.only(right: 2.w),
              width: 12.w,
              height: 12.w,
              decoration: BoxDecoration(
                color: Color(color),
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? Colors.white
                      : Colors.white.withValues(alpha: 0.3),
                  width: isSelected ? 3 : 1,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCreateButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _isFormValid ? _handleAddBudget : null,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 2.h),
          decoration: BoxDecoration(
            gradient: _isFormValid
                ? LinearGradient(
                    colors: [
                      AppTheme.lightTheme.colorScheme.primary,
                      AppTheme.lightTheme.colorScheme.tertiary,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : LinearGradient(
                    colors: [
                      Colors.grey.withValues(alpha: 0.5),
                      Colors.grey.withValues(alpha: 0.3),
                    ],
                  ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: _isFormValid
                ? [
                    BoxShadow(
                      color:
                          AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ]
                : [],
          ),
          child: Center(
            child: Text(
              'Create Budget',
              style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
