import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../services/transaction_service.dart';
import './widgets/amount_input_widget.dart';
import './widgets/category_selector_widget.dart';
import './widgets/date_picker_widget.dart';
import './widgets/description_input_widget.dart';
import './widgets/more_details_widget.dart';
import './widgets/receipt_capture_widget.dart';

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  // Form data
  double amount = 0.0;
  String transactionType = 'expense';
  Map<String, dynamic>? selectedCategory;
  String description = '';
  DateTime selectedDate = DateTime.now();
  XFile? capturedReceipt;
  Map<String, dynamic> moreDetails = {
    'paymentMethod': 'Cash',
    'tags': <String>[],
    'notes': '',
    'location': '',
  };

  bool _isSaving = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    // Start slide animation
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _slideController.forward();
    });
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  void _onAmountChanged(double newAmount) {
    setState(() {
      amount = newAmount;
    });
  }

  void _onCategorySelected(Map<String, dynamic> category) {
    setState(() {
      selectedCategory = category;
    });
  }

  void _onDescriptionChanged(String newDescription) {
    setState(() {
      description = newDescription;
    });
  }

  void _onDateSelected(DateTime date) {
    setState(() {
      selectedDate = date;
    });
  }

  void _onTypeSelected(String type) {
    setState(() {
      transactionType = type;
    });
  }

  void _onImageCaptured(XFile? image) {
    setState(() {
      capturedReceipt = image;
    });
  }

  void _onMoreDetailsChanged(Map<String, dynamic> details) {
    setState(() {
      moreDetails = details;
    });
  }

  bool _validateForm() {
    if (amount <= 0) {
      _showErrorMessage('Please enter a valid amount');
      return false;
    }
    if (selectedCategory == null) {
      _showErrorMessage('Please select a category');
      return false;
    }
    if (description.trim().isEmpty) {
      _showErrorMessage('Please add a description');
      return false;
    }
    return true;
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.lightTheme.colorScheme.error,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(4.w),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  void _showSuccessMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            CustomIconWidget(
              iconName: 'check_circle',
              color: Colors.white,
              size: 5.w,
            ),
            SizedBox(width: 3.w),
            Text(transactionType == 'income' ? 'Income saved successfully!' : 'Expense saved successfully!'),
          ],
        ),
        backgroundColor: AppTheme.lightTheme.colorScheme.tertiary,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(4.w),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Future<void> _saveExpense() async {
    if (!_validateForm()) return;

    setState(() {
      _isSaving = true;
    });

    // Haptic feedback
    HapticFeedback.mediumImpact();

    try {
      // Prepare payload for backend
      final int categoryId = (selectedCategory!['id'] as int);
      final String note = description.trim();

      // Create via service
      final txService = TransactionService();
      await txService.createTransaction(
        amount: amount,
        categoryId: categoryId,
        date: selectedDate,
        type: transactionType,
        note: note,
      );

      // Show success message
      _showSuccessMessage();

      // Navigate back to dashboard with success animation
      await Future.delayed(const Duration(milliseconds: 500));

      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/dashboard-home-screen');
      }
    } catch (e) {
      _showErrorMessage('Failed to save ${transactionType == 'income' ? 'income' : 'expense'}: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  void _closeScreen() {
    _slideController.reverse().then((_) {
      if (mounted) {
        Navigator.of(context).pop();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          AppTheme.lightTheme.scaffoldBackgroundColor.withValues(alpha: 0.95),
      body: SlideTransition(
        position: _slideAnimation,
        child: Container(
          height: 100.h,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.05),
                AppTheme.lightTheme.scaffoldBackgroundColor,
              ],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                _buildAppBar(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: 4.w),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 2.h),
                          AmountInputWidget(
                            onAmountChanged: _onAmountChanged,
                            initialAmount: amount > 0 ? amount : null,
                          ),
                          SizedBox(height: 3.h),
                          CategorySelectorWidget(
                            onCategorySelected: _onCategorySelected,
                            selectedCategory: selectedCategory,
                          ),
                          SizedBox(height: 3.h),
                          DescriptionInputWidget(
                            onDescriptionChanged: _onDescriptionChanged,
                            initialDescription:
                                description.isNotEmpty ? description : null,
                          ),
                          SizedBox(height: 3.h),
                          DatePickerWidget(
                            onDateSelected: _onDateSelected,
                            selectedDate: selectedDate,
                          ),
                          SizedBox(height: 3.h),
                          ReceiptCaptureWidget(
                            onImageCaptured: _onImageCaptured,
                            capturedImage: capturedReceipt,
                          ),
                          SizedBox(height: 3.h),
                          MoreDetailsWidget(
                            onDetailsChanged: _onMoreDetailsChanged,
                            initialDetails: moreDetails,
                          ),
                          SizedBox(height: 2.h),
                          SizedBox(height: 2.h),
                          SizedBox(height: 10.h), // Space for floating button
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: _buildSaveButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      child: Row(
        children: [
          GestureDetector(
            onTap: _closeScreen,
            child: Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.lightTheme.colorScheme.outline
                      .withValues(alpha: 0.3),
                ),
              ),
              child: CustomIconWidget(
                iconName: 'close',
                color: AppTheme.lightTheme.colorScheme.onSurface,
                size: 6.w,
              ),
            ),
          ),
          SizedBox(width: 4.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transactionType == 'income' ? 'Add Income' : 'Add Expense',
                  style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  transactionType == 'income' ? 'Record incoming money' : 'Track your spending',
                  style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  ),
                ),
                SizedBox(height: 1.h),
                Row(
                  children: [
                    ChoiceChip(
                      label: const Text('Expense'),
                      selected: transactionType == 'expense',
                      onSelected: (_) => _onTypeSelected('expense'),
                      selectedColor: AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.12),
                    ),
                    SizedBox(width: 3.w),
                    ChoiceChip(
                      label: const Text('Income'),
                      selected: transactionType == 'income',
                      onSelected: (_) => _onTypeSelected('income'),
                      selectedColor: AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.12),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.primary
                  .withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomIconWidget(
                  iconName: 'today',
                  color: AppTheme.lightTheme.colorScheme.primary,
                  size: 4.w,
                ),
                SizedBox(width: 1.w),
                Text(
                  '${selectedDate.month}/${selectedDate.day}',
                  style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return Container(
      width: 90.w,
      height: 7.h,
      margin: EdgeInsets.symmetric(horizontal: 5.w),
      child: ElevatedButton(
        onPressed: _isSaving ? null : _saveExpense,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.lightTheme.colorScheme.primary,
          foregroundColor: Colors.white,
          elevation: 8,
          shadowColor:
              AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: EdgeInsets.symmetric(vertical: 2.h),
        ),
        child: _isSaving
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 5.w,
                    height: 5.w,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: 3.w),
                  Text(
                    'Saving...',
                    style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomIconWidget(
                    iconName: 'save',
                    color: Colors.white,
                    size: 5.w,
                  ),
                  SizedBox(width: 3.w),
                  Text(
                    transactionType == 'income' ? 'Save Income' : 'Save Expense',
                    style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
