import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'dart:ui';

import '../../core/app_export.dart';
import '../../services/transaction_service.dart';

// Palette constants (matching dashboard design system)
const Color kBaseBackground = Color(0xFFF9FAFB);
const Color kCard = Color(0xFFFFFFFF);
const Color kBorder = Color(0xFFE0E5EB);
const Color kBaseText = Color(0xFF131720);
const Color kPrimary = Color(0xFF29A385);

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

  // Controllers for form-like inputs
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _paymentMethodController = TextEditingController();

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
    _descriptionController.dispose();
    _amountController.dispose();
    _categoryController.dispose();
    _paymentMethodController.dispose();
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

  // Removed unused handlers after form conversion

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
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Gradient background
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF29A385).withOpacity(0.85),
                    const Color(0xFF0EA5E9).withOpacity(0.7),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: SlideTransition(
              position: _slideAnimation,
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 2.h),
                      // Header with back button
                      Row(
                        children: [
                          GestureDetector(
                            onTap: _closeScreen,
                            child: Container(
                              padding: EdgeInsets.all(2.w),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.arrow_back,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                          ),
                          SizedBox(width: 3.w),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                transactionType == 'income' ? 'Add Income' : 'Add Expense',
                                style: TextStyle(
                                  fontSize: 22.sp,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                transactionType == 'income'
                                    ? 'Record your earnings'
                                    : 'Track your spending',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: Colors.white.withOpacity(0.8),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 3.h),
                      // Form card
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Container(
                            padding: EdgeInsets.all(4.w),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.95),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.2),
                                width: 1.5,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Transaction Details',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        color: kBaseText,
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                                SizedBox(height: 2.h),
                                // Transaction Type Selector
                                Row(
                                  children: [
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            transactionType = 'expense';
                                          });
                                        },
                                        child: Container(
                                          padding: EdgeInsets.symmetric(vertical: 1.5.h),
                                          decoration: BoxDecoration(
                                            color: transactionType == 'expense' ? const Color(0xFFDC2828) : Colors.white,
                                            borderRadius: BorderRadius.circular(12),
                                            border: Border.all(
                                              color: transactionType == 'expense' ? const Color(0xFFDC2828) : kBorder,
                                              width: 1,
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.remove_circle_outline,
                                                color: transactionType == 'expense' ? Colors.white : kBaseText,
                                                size: 18,
                                              ),
                                              SizedBox(width: 2.w),
                                              Text(
                                                'Expense',
                                                style: TextStyle(
                                                  color: transactionType == 'expense' ? Colors.white : kBaseText,
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 14.sp,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 3.w),
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            transactionType = 'income';
                                          });
                                        },
                                        child: Container(
                                          padding: EdgeInsets.symmetric(vertical: 1.5.h),
                                          decoration: BoxDecoration(
                                            color: transactionType == 'income' ? kPrimary : Colors.white,
                                            borderRadius: BorderRadius.circular(12),
                                            border: Border.all(
                                              color: transactionType == 'income' ? kPrimary : kBorder,
                                              width: 1,
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.add_circle_outline,
                                                color: transactionType == 'income' ? Colors.white : kBaseText,
                                                size: 18,
                                              ),
                                              SizedBox(width: 2.w),
                                              Text(
                                                'Income',
                                                style: TextStyle(
                                                  color: transactionType == 'income' ? Colors.white : kBaseText,
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 14.sp,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 2.h),
                                // Amount
                                Text('Amount', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.lightTheme.colorScheme.onSurfaceVariant)),
                                SizedBox(height: 0.8.h),
                                TextFormField(
                                  controller: _amountController,
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                  decoration: InputDecoration(
                                    hintText: 'e.g. 12.50',
                                    filled: true,
                                    fillColor: Colors.white,
                                    contentPadding: EdgeInsets.symmetric(vertical: 1.6.h, horizontal: 3.w),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(color: kBorder, width: 1),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(color: kPrimary, width: 1),
                                    ),
                                  ),
                                  validator: (v) {
                                    final val = double.tryParse((v ?? '').trim());
                                    if (val == null || val <= 0) return 'Enter a valid amount';
                                    return null;
                                  },
                                  onChanged: (v) {
                                    final val = double.tryParse(v.trim());
                                    if (val != null) _onAmountChanged(val);
                                  },
                                ),
                                SizedBox(height: 2.h),
                                // Category
                                Text('Category', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.lightTheme.colorScheme.onSurfaceVariant)),
                                SizedBox(height: 0.8.h),
                                TextFormField(
                                  controller: _categoryController,
                                  decoration: InputDecoration(
                                    hintText: 'e.g. Food & Dining',
                                    filled: true,
                                    fillColor: Colors.white,
                                    contentPadding: EdgeInsets.symmetric(vertical: 1.6.h, horizontal: 3.w),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(color: kBorder, width: 1),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(color: kPrimary, width: 1),
                                    ),
                                  ),
                                  validator: (v) {
                                    if ((v ?? '').trim().isEmpty) return 'Category is required';
                                    return null;
                                  },
                                  onChanged: (v) {
                                    _onCategorySelected({'id': 1, 'name': v.trim()});
                                  },
                                ),
                                SizedBox(height: 2.h),
                                // Description
                                Text('Description', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.lightTheme.colorScheme.onSurfaceVariant)),
                                SizedBox(height: 0.8.h),
                                TextFormField(
                                  controller: _descriptionController,
                                  decoration: InputDecoration(
                                    hintText: 'e.g. Coffee at Starbucks',
                                    filled: true,
                                    fillColor: Colors.white,
                                    contentPadding: EdgeInsets.symmetric(vertical: 1.6.h, horizontal: 3.w),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(color: kBorder, width: 1),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(color: kPrimary, width: 1),
                                    ),
                                  ),
                                  validator: (v) {
                                    if ((v ?? '').trim().isEmpty) return 'Description is required';
                                    return null;
                                  },
                                  onChanged: _onDescriptionChanged,
                                ),
                                SizedBox(height: 2.h),
                                // Payment Method
                                Text('Payment Method', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.lightTheme.colorScheme.onSurfaceVariant)),
                                SizedBox(height: 0.8.h),
                                TextFormField(
                                  controller: _paymentMethodController,
                                  decoration: InputDecoration(
                                    hintText: 'e.g. Credit Card',
                                    filled: true,
                                    fillColor: Colors.white,
                                    contentPadding: EdgeInsets.symmetric(vertical: 1.6.h, horizontal: 3.w),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(color: kBorder, width: 1),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(color: kPrimary, width: 1),
                                    ),
                                  ),
                                  validator: (v) {
                                    if ((v ?? '').trim().isEmpty) return 'Payment method is required';
                                    return null;
                                  },
                                  onChanged: (v) {
                                    moreDetails = {
                                      ...moreDetails,
                                      'paymentMethod': v.trim(),
                                    };
                                  },
                                ),
                                SizedBox(height: 2.h),
                                // Date
                                Text('Date', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.lightTheme.colorScheme.onSurfaceVariant)),
                                SizedBox(height: 0.8.h),
                                InkWell(
                                  onTap: () async {
                                    final picked = await showDatePicker(
                                      context: context,
                                      initialDate: selectedDate,
                                      firstDate: DateTime(2020),
                                      lastDate: DateTime(2030),
                                      builder: (context, child) {
                                        return Theme(
                                          data: Theme.of(context).copyWith(
                                            colorScheme: ColorScheme.light(
                                              primary: kPrimary,
                                              onPrimary: Colors.white,
                                              surface: Colors.white,
                                              onSurface: kBaseText,
                                            ),
                                          ),
                                          child: child!,
                                        );
                                      },
                                    );
                                    if (picked != null) {
                                      _onDateSelected(picked);
                                    }
                                  },
                                  child: Container(
                                    padding: EdgeInsets.symmetric(vertical: 1.6.h, horizontal: 3.w),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: kBorder, width: 1),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(Icons.calendar_today, color: kPrimary, size: 20),
                                        SizedBox(width: 3.w),
                                        Text(
                                          '${selectedDate.month}/${selectedDate.day}/${selectedDate.year}',
                                          style: TextStyle(
                                            color: kBaseText,
                                            fontSize: 12.sp,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(height: 2.h),
                                // Notes (Optional)
                                Text('Notes (optional)', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.lightTheme.colorScheme.onSurfaceVariant)),
                                SizedBox(height: 0.8.h),
                                TextFormField(
                                  maxLines: 3,
                                  decoration: InputDecoration(
                                    hintText: 'Add any additional notes...',
                                    filled: true,
                                    fillColor: Colors.white,
                                    contentPadding: EdgeInsets.symmetric(vertical: 1.6.h, horizontal: 3.w),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(color: kBorder, width: 1),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(color: kPrimary, width: 1),
                                    ),
                                  ),
                                  onChanged: (v) {
                                    moreDetails = {
                                      ...moreDetails,
                                      'notes': v.trim(),
                                    };
                                  },
                                ),
                                SizedBox(height: 2.h),
                                // Location
                                Text('Location', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.lightTheme.colorScheme.onSurfaceVariant)),
                                SizedBox(height: 0.8.h),
                                TextFormField(
                                  decoration: InputDecoration(
                                    hintText: 'e.g. Starbucks, Main Street',
                                    filled: true,
                                    fillColor: Colors.white,
                                    contentPadding: EdgeInsets.symmetric(vertical: 1.6.h, horizontal: 3.w),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(color: kBorder, width: 1),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(color: kPrimary, width: 1),
                                    ),
                                  ),
                                  onChanged: (v) {
                                    moreDetails = {
                                      ...moreDetails,
                                      'location': v.trim(),
                                    };
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 10.h), // Space for floating button
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: _buildSaveButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
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
          backgroundColor: Colors.white,
          foregroundColor: kBaseText,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Color(0xFFE0E5EB), width: 1),
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
                      color: Color(0xFF29A385),
                    ),
                  ),
                  SizedBox(width: 3.w),
                  Text(
                    'Saving...',
                    style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                      color: kBaseText,
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
                    color: kBaseText,
                    size: 5.w,
                  ),
                  SizedBox(width: 3.w),
                  Text(
                    transactionType == 'income' ? 'Save Income' : 'Save Expense',
                    style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                      color: kBaseText,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

