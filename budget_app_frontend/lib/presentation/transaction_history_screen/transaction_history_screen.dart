import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:file_picker/file_picker.dart';
import 'package:excel/excel.dart' hide Border;
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

import '../../core/app_export.dart';
import '../../services/transaction_service.dart';
import '../../services/app_state.dart';
import './widgets/empty_state_widget.dart';
import './widgets/filter_chips_widget.dart';
import './widgets/search_bar_widget.dart';
import './widgets/transaction_card_widget.dart';
import './widgets/transaction_filter_widget.dart';
import '../../widgets/loading_list.dart';
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

class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  State<TransactionHistoryScreen> createState() =>
      _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen>
    with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  List<Map<String, dynamic>> _allTransactions = [];
  List<Map<String, dynamic>> _filteredTransactions = [];
  Map<String, dynamic> _activeFilters = {};
  final Set<String> _selectedTransactionIds = {};
  bool _isMultiSelectMode = false;
  bool _isLoading = false;
  String _searchQuery = '';
  bool _useLiveData = false;

  late AnimationController _fabAnimationController;
  late Animation<double> _fabAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _scrollController.addListener(_onScroll);

    // Listen to global app state
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final appState = AppStateProvider.of(context);
      if (appState != null) {
        setState(() {
          _useLiveData = appState.useLiveData;
        });
        if (_useLiveData) {
          _fetchLiveTransactions();
        } else {
          _loadMockData();
        }
        // Listen to changes
        appState.addListener(_onAppStateChanged);
      } else {
        _loadMockData();
      }
    });
  }

  @override
  void dispose() {
    final appState = AppStateProvider.of(context);
    appState?.removeListener(_onAppStateChanged);
    _scrollController.dispose();
    _searchController.dispose();
    _fabAnimationController.dispose();
    super.dispose();
  }

  void _initializeAnimations() {
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fabAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fabAnimationController, curve: Curves.easeInOut),
    );
    _fabAnimationController.forward();
  }

  void _onAppStateChanged() {
    final appState = AppStateProvider.of(context);
    if (appState != null && mounted) {
      final newValue = appState.useLiveData;
      if (_useLiveData != newValue) {
        setState(() {
          _useLiveData = newValue;
        });
        if (newValue) {
          _fetchLiveTransactions();
        } else {
          _loadMockData();
        }
      }
    }
  }

  void _loadMockData() {
    setState(() {
      _isLoading = true;
    });

    // Mock transaction data
    _allTransactions = [
      {
        "id": "1",
        "description": "Starbucks Coffee",
        "amount": 5.75,
        "type": "expense",
        "category": "Food & Dining",
        "paymentMethod": "Credit Card",
        "date": DateTime.now().subtract(const Duration(hours: 2)),
        "isFavorite": false,
      },
      {
        "id": "2",
        "description": "Salary Deposit",
        "amount": 3500.00,
        "type": "income",
        "category": "Income",
        "paymentMethod": "Bank Transfer",
        "date": DateTime.now().subtract(const Duration(days: 1)),
        "isFavorite": true,
      },
      {
        "id": "3",
        "description": "Uber Ride",
        "amount": 12.50,
        "type": "expense",
        "category": "Transportation",
        "paymentMethod": "Digital Wallet",
        "date": DateTime.now().subtract(const Duration(hours: 5)),
        "isFavorite": false,
      },
      {
        "id": "4",
        "description": "Amazon Purchase",
        "amount": 89.99,
        "type": "expense",
        "category": "Shopping",
        "paymentMethod": "Credit Card",
        "date": DateTime.now().subtract(const Duration(days: 2)),
        "isFavorite": false,
      },
      {
        "id": "5",
        "description": "Netflix Subscription",
        "amount": 15.99,
        "type": "expense",
        "category": "Entertainment",
        "paymentMethod": "Credit Card",
        "date": DateTime.now().subtract(const Duration(days: 3)),
        "isFavorite": false,
      },
      {
        "id": "6",
        "description": "Electricity Bill",
        "amount": 125.00,
        "type": "expense",
        "category": "Bills & Utilities",
        "paymentMethod": "Bank Transfer",
        "date": DateTime.now().subtract(const Duration(days: 5)),
        "isFavorite": false,
      },
      {
        "id": "7",
        "description": "Freelance Payment",
        "amount": 750.00,
        "type": "income",
        "category": "Income",
        "paymentMethod": "Bank Transfer",
        "date": DateTime.now().subtract(const Duration(days: 7)),
        "isFavorite": true,
      },
      {
        "id": "8",
        "description": "Grocery Shopping",
        "amount": 67.43,
        "type": "expense",
        "category": "Food & Dining",
        "paymentMethod": "Debit Card",
        "date": DateTime.now().subtract(const Duration(days: 8)),
        "isFavorite": false,
      },
      {
        "id": "9",
        "description": "Gas Station",
        "amount": 45.00,
        "type": "expense",
        "category": "Transportation",
        "paymentMethod": "Credit Card",
        "date": DateTime.now().subtract(const Duration(days: 10)),
        "isFavorite": false,
      },
      {
        "id": "10",
        "description": "Movie Tickets",
        "amount": 28.00,
        "type": "expense",
        "category": "Entertainment",
        "paymentMethod": "Cash",
        "date": DateTime.now().subtract(const Duration(days: 12)),
        "isFavorite": false,
      },
    ];

    _applyFilters();

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _fetchLiveTransactions() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final service = TransactionService();
      final live = await service.fetchTransactions();

      // Map service transactions into the shape expected by TransactionHistory widgets
      // Expected keys: id, description, amount, type, category, paymentMethod, date (DateTime), isFavorite
      final mapped = <Map<String, dynamic>>[];
      for (var i = 0; i < live.length; i++) {
        final t = live[i];
        final id = (t['id']?.toString().isNotEmpty == true)
            ? t['id'].toString()
            : (i + 1).toString();

        final description = (t['description'] ?? t['title'] ?? 'No title').toString();
        final category = (t['category'] ?? 'General').toString();
        final type = (t['type'] ?? 'expense').toString();
        final amountRaw = t['amount'];
        final amount = (amountRaw is num)
            ? amountRaw.toDouble()
            : double.tryParse(amountRaw?.toString() ?? '') ?? 0.0;
        final dateRaw = t['date'];
        DateTime date;
        if (dateRaw is DateTime) {
          date = dateRaw;
        } else if (dateRaw != null) {
          date = DateTime.tryParse(dateRaw.toString()) ?? DateTime.now();
        } else {
          date = DateTime.now();
        }

        mapped.add({
          'id': id,
          'description': description,
          'amount': amount,
          'type': type,
          'category': category,
          'paymentMethod': 'Bank Transfer',
          'date': date,
          'isFavorite': false,
        });
      }

      setState(() {
        _allTransactions = mapped;
      });
      _applyFilters();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load live transactions: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels > 100) {
      if (!_fabAnimationController.isCompleted) {
        _fabAnimationController.forward();
      }
    } else {
      if (_fabAnimationController.isCompleted) {
        _fabAnimationController.reverse();
      }
    }
  }

  void _applyFilters() {
    List<Map<String, dynamic>> filtered = List.from(_allTransactions);

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((transaction) {
        final description =
            (transaction['description'] as String).toLowerCase();
        final category = (transaction['category'] as String).toLowerCase();
        final query = _searchQuery.toLowerCase();
        return description.contains(query) || category.contains(query);
      }).toList();
    }

    // Apply date range filter
    if (_activeFilters.containsKey('startDate') &&
        _activeFilters.containsKey('endDate')) {
      final DateTime startDate = _activeFilters['startDate'];
      final DateTime endDate = _activeFilters['endDate'];
      filtered = filtered.where((transaction) {
        final DateTime transactionDate = transaction['date'];
        return transactionDate
                .isAfter(startDate.subtract(const Duration(days: 1))) &&
            transactionDate.isBefore(endDate.add(const Duration(days: 1)));
      }).toList();
    }

    // Apply category filter
    if (_activeFilters.containsKey('category')) {
      filtered = filtered.where((transaction) {
        return transaction['category'] == _activeFilters['category'];
      }).toList();
    }

    // Apply payment method filter
    if (_activeFilters.containsKey('paymentMethod')) {
      filtered = filtered.where((transaction) {
        return transaction['paymentMethod'] == _activeFilters['paymentMethod'];
      }).toList();
    }

    // Apply amount range filter
    if (_activeFilters.containsKey('minAmount') ||
        _activeFilters.containsKey('maxAmount')) {
      final double minAmount = _activeFilters['minAmount'] ?? 0;
      final double maxAmount = _activeFilters['maxAmount'] ?? double.infinity;
      filtered = filtered.where((transaction) {
        final double amount = (transaction['amount'] as num).toDouble();
        return amount >= minAmount && amount <= maxAmount;
      }).toList();
    }

    // Sort by date (newest first)
    filtered.sort(
        (a, b) => (b['date'] as DateTime).compareTo(a['date'] as DateTime));

    setState(() {
      _filteredTransactions = filtered;
    });
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
    _applyFilters();
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TransactionFilterWidget(
        currentFilters: _activeFilters,
        onFiltersApplied: (filters) {
          setState(() {
            _activeFilters = filters;
          });
          _applyFilters();
        },
      ),
    );
  }

  void _removeFilter(String filterKey) {
    setState(() {
      switch (filterKey) {
        case 'dateRange':
          _activeFilters.remove('startDate');
          _activeFilters.remove('endDate');
          break;
        case 'amountRange':
          _activeFilters.remove('minAmount');
          _activeFilters.remove('maxAmount');
          break;
        default:
          _activeFilters.remove(filterKey);
      }
    });
    _applyFilters();
  }

  void _clearAllFilters() {
    setState(() {
      _activeFilters.clear();
      _searchQuery = '';
      _searchController.clear();
    });
    _applyFilters();
  }

  void _toggleTransactionSelection(String transactionId) {
    setState(() {
      if (_selectedTransactionIds.contains(transactionId)) {
        _selectedTransactionIds.remove(transactionId);
      } else {
        _selectedTransactionIds.add(transactionId);
      }

      if (_selectedTransactionIds.isEmpty) {
        _isMultiSelectMode = false;
      }
    });
  }

  void _enterMultiSelectMode(String transactionId) {
    HapticFeedback.mediumImpact();
    setState(() {
      _isMultiSelectMode = true;
      _selectedTransactionIds.add(transactionId);
    });
  }

  void _exitMultiSelectMode() {
    setState(() {
      _isMultiSelectMode = false;
      _selectedTransactionIds.clear();
    });
  }

  void _deleteSelectedTransactions() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Transactions'),
          content: Text(
              'Are you sure you want to delete ${_selectedTransactionIds.length} selected transactions? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _allTransactions.removeWhere((transaction) =>
                      _selectedTransactionIds.contains(transaction['id']));
                });
                _applyFilters();
                _exitMultiSelectMode();
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.lightTheme.colorScheme.error,
              ),
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _exportTransactions() async {
    // Show export dialog with theme styling
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: kCard,
        title: Text('Export Transactions', style: TextStyle(color: kBaseText)),
        content: Text(
          'Export ${_selectedTransactionIds.length} selected transactions to Excel?',
          style: TextStyle(color: kCardText),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: kMutedText)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _performExport(_filteredTransactions.where((t) => 
                _selectedTransactionIds.contains(t['id'])).toList());
              _exitMultiSelectMode();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: kPrimary,
              foregroundColor: kPrimaryText,
            ),
            child: const Text('Export'),
          ),
        ],
      ),
    );
  }

  Future<void> _performExport(List<Map<String, dynamic>> transactions) async {
    if (transactions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('No transactions to export'),
          backgroundColor: kMuted,
        ),
      );
      return;
    }

    try {
      // Create Excel workbook
      var excel = Excel.createExcel();
      Sheet sheetObject = excel['Transactions'];
      
      // Add headers
      sheetObject.appendRow([
        TextCellValue('ID'),
        TextCellValue('Description'),
        TextCellValue('Amount'),
        TextCellValue('Type'),
        TextCellValue('Category'),
        TextCellValue('Payment Method'),
        TextCellValue('Date'),
      ]);

      // Add transaction data
      for (final t in transactions) {
        sheetObject.appendRow([
          TextCellValue((t['id'] ?? '').toString()),
          TextCellValue((t['description'] ?? '').toString()),
          DoubleCellValue((t['amount'] as num?)?.toDouble() ?? 0.0),
          TextCellValue((t['type'] ?? '').toString()),
          TextCellValue((t['category'] ?? '').toString()),
          TextCellValue((t['paymentMethod'] ?? '').toString()),
          TextCellValue((t['date'] is DateTime) 
              ? (t['date'] as DateTime).toIso8601String() 
              : (t['date'] ?? '').toString()),
        ]);
      }

      // Save to file
      var fileBytes = excel.save();
      if (fileBytes != null) {
        if (kIsWeb) {
          // Web platform: trigger download
          final blob = html.Blob([fileBytes], 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
          final url = html.Url.createObjectUrlFromBlob(blob);
          final anchor = html.AnchorElement(href: url)
            ..setAttribute('download', 'transactions_export_${DateTime.now().millisecondsSinceEpoch}.xlsx')
            ..click();
          html.Url.revokeObjectUrl(url);
        } else {
          // Mobile/Desktop platform: use file picker
          String? outputPath = await FilePicker.platform.saveFile(
            dialogTitle: 'Save Excel File',
            fileName: 'transactions_export_${DateTime.now().millisecondsSinceEpoch}.xlsx',
            type: FileType.custom,
            allowedExtensions: ['xlsx'],
          );

          if (outputPath == null) {
            // User cancelled
            return;
          }

          File(outputPath)
            ..createSync(recursive: true)
            ..writeAsBytesSync(fileBytes);
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Exported ${transactions.length} transactions to Excel'),
            backgroundColor: kPrimary,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to export: ${e.toString()}'),
          backgroundColor: kDestructive,
        ),
      );
    }
  }

  Future<void> _exportAllTransactions() async {
    await _performExport(_filteredTransactions);
  }

  Future<void> _refreshTransactions() async {
    HapticFeedback.lightImpact();
    if (_useLiveData) {
      await _fetchLiveTransactions();
    } else {
      await Future.delayed(const Duration(milliseconds: 300));
      _loadMockData();
    }
  }

  void _showEditTransactionDialog(Map<String, dynamic> transaction) {
    final titleController = TextEditingController(text: transaction['description'] ?? '');
    final amountController = TextEditingController(text: transaction['amount']?.toString() ?? '');
    final dateController = TextEditingController(
      text: transaction['date'] is DateTime
          ? '${(transaction['date'] as DateTime).month}/${(transaction['date'] as DateTime).day}'
          : 'Dec 10',
    );
    final notesController = TextEditingController(text: transaction['notes'] ?? '');
    String selectedCategory = transaction['category'] ?? 'Income';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Edit Transaction'),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.pop(context),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              SizedBox(height: 2.h),
              // Category
              StatefulBuilder(
                builder: (context, setState) => DropdownButtonFormField<String>(
                  value: selectedCategory,
                  decoration: InputDecoration(
                    labelText: 'Category',
                    prefixIcon: const Icon(Icons.account_balance_wallet),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'Income', child: Text('Income')),
                    DropdownMenuItem(value: 'Food', child: Text('Food')),
                    DropdownMenuItem(value: 'Transport', child: Text('Transport')),
                    DropdownMenuItem(value: 'Shopping', child: Text('Shopping')),
                    DropdownMenuItem(value: 'Entertainment', child: Text('Entertainment')),
                  ],
                  onChanged: (value) => setState(() => selectedCategory = value ?? 'Income'),
                ),
              ),
              SizedBox(height: 2.h),
              // Amount and Date
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: amountController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: 'Amount',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: TextField(
                      controller: dateController,
                      decoration: InputDecoration(
                        labelText: 'Date',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 2.h),
              // Notes
              TextField(
                controller: notesController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Notes (optional)',
                  hintText: 'Add any notes...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Transaction "${titleController.text}" updated'),
                  backgroundColor: kPrimary,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: kPrimary,
            ),
            child: const Text('Update Transaction'),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildGroupedTransactions() {
    if (_filteredTransactions.isEmpty) {
      return [
        EmptyStateWidget(
          title: _searchQuery.isNotEmpty || _activeFilters.isNotEmpty
              ? 'No Matching Transactions'
              : 'No Transactions Found',
          subtitle: _searchQuery.isNotEmpty || _activeFilters.isNotEmpty
              ? 'Try adjusting your search or filters to find what you\'re looking for.'
              : 'Start tracking your expenses and income to see your transaction history here.',
          onButtonPressed: () {
            Navigator.pushNamed(context, '/add-expense-screen');
          },
        ),
      ];
    }

    final List<Widget> widgets = [];
    final Map<String, List<Map<String, dynamic>>> groupedTransactions = {};

    // Group transactions by date
    for (final transaction in _filteredTransactions) {
      final date = transaction['date'] as DateTime;
      final dateKey =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

      if (!groupedTransactions.containsKey(dateKey)) {
        groupedTransactions[dateKey] = [];
      }
      groupedTransactions[dateKey]!.add(transaction);
    }

    // Build grouped transaction widgets
    final sortedDates = groupedTransactions.keys.toList()
      ..sort((a, b) => b.compareTo(a));

    for (final dateKey in sortedDates) {
      final transactions = groupedTransactions[dateKey]!;
      final date = DateTime.parse(dateKey);

      // Date header
      widgets.add(
        Container(
          margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
          child: Text(
            _formatDateHeader(date),
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      );

      // Transaction cards
      for (final transaction in transactions) {
        widgets.add(
          TransactionCardWidget(
            transaction: transaction,
            isSelected: _selectedTransactionIds.contains(transaction['id']),
            onTap: _isMultiSelectMode
                ? () => _toggleTransactionSelection(transaction['id'])
                : () => _showEditTransactionDialog(transaction),
            onLongPress: () => _enterMultiSelectMode(transaction['id']),
            onEdit: () {
              _showEditTransactionDialog(transaction);
            },
            onDuplicate: () {
              // Duplicate transaction logic
            },
            onDelete: () {
              setState(() {
                _allTransactions
                    .removeWhere((t) => t['id'] == transaction['id']);
              });
              _applyFilters();
            },
            onFavorite: () {
              setState(() {
                transaction['isFavorite'] =
                    !(transaction['isFavorite'] as bool? ?? false);
              });
            },
          ),
        );
      }
    }

    return widgets;
  }

  String _formatDateHeader(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final transactionDate = DateTime(date.year, date.month, date.day);

    if (transactionDate == today) {
      return 'Today';
    } else if (transactionDate == yesterday) {
      return 'Yesterday';
    } else {
      final months = [
        'January',
        'February',
        'March',
        'April',
        'May',
        'June',
        'July',
        'August',
        'September',
        'October',
        'November',
        'December'
      ];
      return '${months[date.month - 1]} ${date.day}, ${date.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    // Calculate total income and expenses
    double totalIncome = 0;
    double totalExpenses = 0;
    for (final transaction in _allTransactions) {
      final amount = (transaction['amount'] as num?)?.toDouble() ?? 0.0;
      final type = transaction['type'] as String?;
      if (type == 'income') {
        totalIncome += amount;
      } else if (type == 'expense') {
        totalExpenses += amount;
      }
    }

    return Scaffold(
      backgroundColor: kBaseBackground,
      appBar:
          _isMultiSelectMode ? _buildMultiSelectAppBar() : _buildNormalAppBar(),
      body: Column(
        children: [
          // Summary Cards - Total Income and Total Expenses
          if (!_isMultiSelectMode)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.all(3.w),
                      decoration: BoxDecoration(
                        color: kCard,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: kBorder, width: 1),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.10),
                            blurRadius: 3.0,
                            spreadRadius: 0.0,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Total Income',
                            style: TextStyle(
                              color: kMutedText,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 0.5.h),
                          Text(
                            '+\$${totalIncome.toStringAsFixed(2)}',
                            style: TextStyle(
                              color: const Color(0xFF10B981),
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.all(3.w),
                      decoration: BoxDecoration(
                        color: kCard,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: kBorder, width: 1),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.10),
                            blurRadius: 3.0,
                            spreadRadius: 0.0,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Total Expenses',
                            style: TextStyle(
                              color: kMutedText,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 0.5.h),
                          Text(
                            '-\$${totalExpenses.toStringAsFixed(2)}',
                            style: TextStyle(
                              color: kDestructive,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Export Button
          if (!_isMultiSelectMode)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _importTransactions,
                      icon: const Icon(Icons.upload_file, size: 18),
                      label: const Text('Import Excel'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: kBaseText,
                        side: const BorderSide(color: kBorder, width: 1),
                        backgroundColor: kCard,
                        padding: EdgeInsets.symmetric(vertical: 1.5.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _exportAllTransactions,
                      icon: const Icon(Icons.download, size: 18),
                      label: const Text('Export Transactions'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: kBaseText,
                        side: const BorderSide(color: kBorder, width: 1),
                        backgroundColor: kCard,
                        padding: EdgeInsets.symmetric(vertical: 1.5.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Search bar
          if (!_isMultiSelectMode)
            SearchBarWidget(
              onSearchChanged: _onSearchChanged,
              onFilterTap: _showFilterBottomSheet,
              activeFiltersCount: _activeFilters.length,
              onVoiceSearch: () {
                // Voice search functionality
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Voice search activated')),
                );
              },
            ),

          // Active filters
          FilterChipsWidget(
            activeFilters: _activeFilters,
            onFilterRemoved: _removeFilter,
            onClearAll: _clearAllFilters,
          ),

          // Transaction list
          Expanded(
            child: _isLoading
                ? const LoadingList(itemCount: 6)
                : RefreshIndicator(
                    onRefresh: _refreshTransactions,
                    child: ListView(
                      controller: _scrollController,
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: _buildGroupedTransactions(),
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton:
          _isMultiSelectMode ? null : _buildFloatingActionButton(),
      bottomNavigationBar: AppBottomNav(
        currentIndex: 1,
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
              // current screen
              break;
            case 2:
              Navigator.pushNamed(context, '/budget-screen');
              break;
            case 3:
              Navigator.pushNamed(context, '/reports-screen');
              break;
          }
        },
      ),
    );
  }

  Future<void> _importTransactions() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx'],
        withData: true,
      );

      if (result == null) {
        // User cancelled
        return;
      }

      Uint8List? bytes;
      if (kIsWeb) {
        bytes = result.files.first.bytes;
      } else {
        final path = result.files.first.path;
        if (path != null) {
          bytes = await File(path).readAsBytes();
        }
      }

      if (bytes == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Unable to read selected file'),
            backgroundColor: kDestructive,
          ),
        );
        return;
      }

      final excel = Excel.decodeBytes(bytes);
      final sheetNames = excel.tables.keys.toList();
      if (sheetNames.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('No sheets found in Excel file'),
            backgroundColor: kDestructive,
          ),
        );
        return;
      }

      final table = excel.tables[sheetNames.first];
      if (table == null || table.rows.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Selected sheet is empty'),
            backgroundColor: kDestructive,
          ),
        );
        return;
      }

      // Expect first row to be headers matching our export
      int importedCount = 0;
      for (int i = 1; i < table.rows.length; i++) {
        final row = table.rows[i];
        String id = (row.isNotEmpty ? (row[0]?.value?.toString() ?? '') : '');
        String description = (row.length > 1 ? (row[1]?.value?.toString() ?? '') : '');
        double amount = 0.0;
        if (row.length > 2) {
          final rawStr = row[2]?.value?.toString();
          amount = double.tryParse(rawStr ?? '') ?? 0.0;
        }
        String type = (row.length > 3 ? (row[3]?.value?.toString() ?? 'expense') : 'expense');
        String category = (row.length > 4 ? (row[4]?.value?.toString() ?? 'General') : 'General');
        String paymentMethod = (row.length > 5 ? (row[5]?.value?.toString() ?? 'Bank Transfer') : 'Bank Transfer');
        DateTime date = DateTime.now();
        if (row.length > 6) {
          final rawStr = row[6]?.value?.toString();
          final parsed = DateTime.tryParse(rawStr ?? '');
          if (parsed != null) {
            date = parsed;
          }
        }

        final transaction = {
          'id': id.isNotEmpty ? id : DateTime.now().millisecondsSinceEpoch.toString(),
          'description': description.isNotEmpty ? description : 'Imported Item',
          'amount': amount,
          'type': type,
          'category': category,
          'paymentMethod': paymentMethod,
          'date': date,
          'isFavorite': false,
        };

        _allTransactions.add(transaction);
        importedCount++;
      }

      _applyFilters();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Imported $importedCount transactions from Excel'),
          backgroundColor: kPrimary,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to import: ${e.toString()}'),
          backgroundColor: kDestructive,
        ),
      );
    }
  }

  PreferredSizeWidget _buildNormalAppBar() {
    return BrandAppBar(
      backgroundColor: Colors.white,
      elevation: 2,
      leading: IconButton(
        onPressed: () {
          Navigator.pop(context);
        },
        icon: const Icon(Icons.arrow_back),
      ),
      title: Text('Transaction History'),
    );
  }

  PreferredSizeWidget _buildMultiSelectAppBar() {
    return BrandAppBar(
      backgroundColor: Colors.white,
      elevation: 2,
      leading: IconButton(
        onPressed: _exitMultiSelectMode,
        icon: CustomIconWidget(
          iconName: 'close',
          color: AppTheme.lightTheme.colorScheme.onSurface,
          size: 24,
        ),
      ),
      title: Text('${_selectedTransactionIds.length} selected'),
      actions: [
        IconButton(
          onPressed: _exportTransactions,
          icon: CustomIconWidget(
            iconName: 'share',
            color: AppTheme.lightTheme.colorScheme.onSurface,
            size: 24,
          ),
        ),
        IconButton(
          onPressed: _deleteSelectedTransactions,
          icon: CustomIconWidget(
            iconName: 'delete',
            color: AppTheme.lightTheme.colorScheme.error,
            size: 24,
          ),
        ),
      ],
    );
  }

  Widget _buildFloatingActionButton() {
    return ScaleTransition(
      scale: _fabAnimation,
      child: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/add-expense-screen');
        },
        backgroundColor: kPrimary,
        child: CustomIconWidget(
          iconName: 'add',
          color: Colors.black,
          size: 24,
        ),
      ),
    );
  }
}
