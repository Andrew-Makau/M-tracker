import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../services/transaction_service.dart';
import './widgets/empty_state_widget.dart';
import './widgets/filter_chips_widget.dart';
import './widgets/monthly_summary_widget.dart';
import './widgets/search_bar_widget.dart';
import './widgets/transaction_card_widget.dart';
import './widgets/transaction_filter_widget.dart';
import '../../widgets/loading_list.dart';
import '../../widgets/app_bottom_nav.dart';

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
    _loadMockData();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
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

  void _exportTransactions() {
    // Mock export functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            Text('Exporting ${_selectedTransactionIds.length} transactions...'),
        action: SnackBarAction(
          label: 'View',
          onPressed: () {},
        ),
      ),
    );
    _exitMultiSelectMode();
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

  Map<String, dynamic> _getMonthlySummary() {
    final now = DateTime.now();
    final currentMonth = DateTime(now.year, now.month, 1);
    final nextMonth = DateTime(now.year, now.month + 1, 1);

    final monthlyTransactions = _allTransactions.where((transaction) {
      final date = transaction['date'] as DateTime;
      return date.isAfter(currentMonth.subtract(const Duration(days: 1))) &&
          date.isBefore(nextMonth);
    }).toList();

    double totalIncome = 0;
    double totalExpenses = 0;
    Map<String, double> categoryBreakdown = {};

    for (final transaction in monthlyTransactions) {
      final amount = (transaction['amount'] as num).toDouble();
      final type = transaction['type'] as String;
      final category = transaction['category'] as String;

      if (type == 'income') {
        totalIncome += amount;
      } else {
        totalExpenses += amount;
        categoryBreakdown[category] =
            (categoryBreakdown[category] ?? 0) + amount;
      }
    }

    return {
      'month': 'December 2024',
      'totalIncome': totalIncome,
      'totalExpenses': totalExpenses,
      'categoryBreakdown': categoryBreakdown,
    };
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

    // Add monthly summary at the top
    widgets.add(MonthlySummaryWidget(
      summaryData: _getMonthlySummary(),
      onTap: () {
        // Navigate to detailed analytics
      },
    ));

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
                : null,
            onLongPress: () => _enterMultiSelectMode(transaction['id']),
            onEdit: () {
              // Navigate to edit transaction
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
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar:
          _isMultiSelectMode ? _buildMultiSelectAppBar() : _buildNormalAppBar(),
      body: Column(
        children: [
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
              Navigator.pushNamed(context, '/budget-categories-screen');
              break;
            case 3:
              Navigator.pushNamed(context, '/profile-screen');
              break;
          }
        },
      ),
    );
  }

  PreferredSizeWidget _buildNormalAppBar() {
    return BrandAppBar(
      leading: IconButton(
        onPressed: () {
          Navigator.pushNamedAndRemoveUntil(
            context,
            AppRoutes.dashboardHome,
            (route) => false,
          );
        },
        icon: const Icon(Icons.home),
      ),
      title: Text('Transaction History'),
      actions: [
        Row(
          children: [
            Text(
              _useLiveData ? 'Live' : 'Mock',
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurface,
              ),
            ),
            Switch(
              value: _useLiveData,
              onChanged: (val) async {
                setState(() {
                  _useLiveData = val;
                });
                if (val) {
                  await _fetchLiveTransactions();
                } else {
                  _loadMockData();
                }
              },
              activeThumbColor: AppTheme.lightTheme.colorScheme.primary,
            ),
          ],
        ),
        IconButton(
          onPressed: () {
            // Navigate to settings or more options
          },
          icon: CustomIconWidget(
            iconName: 'more_vert',
            color: AppTheme.lightTheme.colorScheme.onSurface,
            size: 24,
          ),
        ),
      ],
    );
  }

  PreferredSizeWidget _buildMultiSelectAppBar() {
    return BrandAppBar(
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
        child: CustomIconWidget(
          iconName: 'add',
          color: Colors.white,
          size: 24,
        ),
      ),
    );
  }
}
