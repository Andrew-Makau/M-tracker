import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
// import 'package:sizer/sizer.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../core/app_export.dart';
// Removed gradient background for minimal/flat design
import '../../core/design_tokens.dart';
import '../../widgets/app_bottom_nav.dart';
// import 'package:dot_curved_bottom_nav/dot_curved_bottom_nav.dart'; // enable after pub get
import '../../services/transaction_service.dart';
import '../../services/auth_service.dart';
import './widgets/balance_card_widget.dart';
import './widgets/recent_transactions_widget.dart';
import './widgets/spending_summary_widget.dart';

class DashboardHomeScreen extends StatefulWidget {
  const DashboardHomeScreen({super.key});

  @override
  State<DashboardHomeScreen> createState() => _DashboardHomeScreenState();
}

class _DashboardHomeScreenState extends State<DashboardHomeScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _refreshAnimationController;
  late Animation<double> _refreshAnimation;

  bool _isBalanceVisible = true;
  bool _isRefreshing = false;
  // int _selectedTabIndex = 0; // removed, unused
  int _currentPage = 0; // for dot curved nav
  // final ScrollController _scrollController = ScrollController();
  String _userName = "Andrew"; // default fallback until loaded from storage
  // Removed unused field: _lastUpdated
  bool _useLiveData = false;

  // Mock data
  final double _totalBalance = 4250.75;
  final double _monthlyBudget = 3000.00;
  final double _spentAmount = 1847.32;

  final List<Map<String, dynamic>> _categoryBreakdown = [
    {
      "name": "Food & Dining",
      "amount": 687.50,
      "color": AppTheme.categoryColors[6],
    },
    {
      "name": "Transportation",
      "amount": 425.80,
      "color": AppTheme.categoryColors[2],
    },
    {
      "name": "Shopping",
      "amount": 312.45,
      "color": AppTheme.categoryColors[5],
    },
    {
      "name": "Entertainment",
      "amount": 234.67,
      "color": AppTheme.categoryColors[0],
    },
    {
      "name": "Bills & Utilities",
      "amount": 186.90,
      "color": AppTheme.categoryColors[4],
    },
  ];

  // Immutable mock data we can restore when Live is off
  final List<Map<String, dynamic>> _initialMockTransactions = [
    {
      "id": 1,
      "title": "Starbucks Coffee",
      "category": "Food",
      "amount": 12.50,
      "date": DateTime.now().subtract(const Duration(hours: 2)),
      "type": "expense",
      "categoryColor": AppTheme.categoryColors[6],
    },
    {
      "id": 2,
      "title": "Uber Ride",
      "category": "Transport",
      "amount": 18.75,
      "date": DateTime.now().subtract(const Duration(hours: 5)),
      "type": "expense",
      "categoryColor": AppTheme.categoryColors[2],
    },
    {
      "id": 3,
      "title": "Salary Deposit",
      "category": "Income",
      "amount": 2500.00,
      "date": DateTime.now().subtract(const Duration(days: 1)),
      "type": "income",
      "categoryColor": AppTheme.categoryColors[0],
    },
    {
      "id": 4,
      "title": "Amazon Purchase",
      "category": "Shopping",
      "amount": 89.99,
      "date": DateTime.now().subtract(const Duration(days: 2)),
      "type": "expense",
      "categoryColor": AppTheme.categoryColors[5],
    },
    {
      "id": 5,
      "title": "Netflix Subscription",
      "category": "Entertainment",
      "amount": 15.99,
      "date": DateTime.now().subtract(const Duration(days: 3)),
      "type": "expense",
      "categoryColor": AppTheme.categoryColors[4],
    },
  ];

  // The list currently displayed (mock by default)
  List<Map<String, dynamic>> _recentTransactions = [];

  bool _isLoadingLive = false;
  double? _liveSpent;
  double? _liveIncome;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(_handleTabSelection);

    _refreshAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _refreshAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
          parent: _refreshAnimationController, curve: Curves.easeInOut),
    );

    // Initialize with mock data on first load
    _recentTransactions = List<Map<String, dynamic>>.from(_initialMockTransactions);

    // Debug: check if token is stored
    AuthService().getToken().then((token) {
      debugPrint("🔑 Stored token: $token");
    });

    // Load name from secure storage to reflect Profile updates
    _loadUserNameFromStorage();
  }


  @override
  void dispose() {
    _tabController.dispose();
    _refreshAnimationController.dispose();
    super.dispose();
  }

  void _handleTabSelection() {
    if (_tabController.indexIsChanging) {
      setState(() {
        // _selectedTabIndex = _tabController.index; // removed, unused
      });
      HapticFeedback.lightImpact();
    }
  }

  Future<void> _handleRefresh() async {
    if (_isRefreshing) return;

    setState(() {
      _isRefreshing = true;
    });

    _refreshAnimationController.forward();
    HapticFeedback.mediumImpact();

    if (_useLiveData) {
      await _fetchAndSetTransactions();
    } else {
      // Simulate work
      await Future.delayed(const Duration(seconds: 1));
    }

    setState(() {
      _isRefreshing = false;
    });

    _refreshAnimationController.reset();

    Fluttertoast.showToast(
      msg: _useLiveData ? "Live data updated" : "Data updated",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: AppTheme.successLight,
      textColor: Theme.of(context).colorScheme.onPrimary,
    );
  }

  Future<void> _fetchAndSetTransactions() async {
    setState(() => _isLoadingLive = true);
    try {
      final service = TransactionService();
      final items = await service.fetchTransactions();
      setState(() {
        _recentTransactions = items;
      });
      // Also fetch summary (spent/income) for the current month
      try {
        final summary = await service.fetchSummary();
        setState(() {
          _liveSpent = summary['spent'];
          _liveIncome = summary['income'];
        });
      } catch (_) {
        // non-fatal — fall back to client-side computation
        setState(() {
          _liveSpent = null;
          _liveIncome = null;
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to fetch transactions: $e'),
          backgroundColor: AppTheme.lightTheme.colorScheme.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoadingLive = false);
    }
  }

  void _toggleBalanceVisibility() {
    setState(() {
      _isBalanceVisible = !_isBalanceVisible;
    });
    HapticFeedback.lightImpact();
  }

  void _handleAddExpense() {
    HapticFeedback.lightImpact();
    Navigator.pushNamed(
      context,
      '/add-expense-screen',
      arguments: {'type': 'expense'},
    );
  }

  void _handleAddIncome() {
    HapticFeedback.lightImpact();
    Navigator.pushNamed(
      context,
      '/add-expense-screen',
      arguments: {'type': 'income'},
    );
  }

  void _handleViewBudgets() {
    HapticFeedback.lightImpact();
    Navigator.pushNamed(context, '/budget-categories-screen');
  }

  void _handleViewReports() {
    HapticFeedback.lightImpact();
    Navigator.pushNamed(context, '/reports-screen');
  }

  // Removed unused history handler after cleaning AppBar actions

  void _toggleLiveData() {
    HapticFeedback.lightImpact();
    setState(() {
      _useLiveData = !_useLiveData;
    });
    if (_useLiveData) {
      // Optionally kick off a refresh when switching to live
      _handleRefresh();
    }
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: DateTime(now.year - 2),
      lastDate: DateTime(now.year + 2),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = DateTime(picked.year, picked.month, picked.day);
      });
    }
  }

  // Removed bottom sheet quick actions in favor of side drawer

  void _handleEditTransaction(Map<String, dynamic> transaction) {
    HapticFeedback.lightImpact();
    Fluttertoast.showToast(
      msg: "Edit transaction: ${transaction['title']}",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

  void _handleDeleteTransaction(Map<String, dynamic> transaction) {
    HapticFeedback.mediumImpact();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Transaction'),
        content:
            Text('Are you sure you want to delete "${transaction['title']}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _recentTransactions
                    .removeWhere((t) => t['id'] == transaction['id']);
              });
              Fluttertoast.showToast(
                msg: "Transaction deleted",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
                backgroundColor: AppTheme.errorLight,
                textColor: Theme.of(context).colorScheme.onPrimary,
              );
            },
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _handleCategorizeTransaction(Map<String, dynamic> transaction) {
    HapticFeedback.lightImpact();
    Fluttertoast.showToast(
      msg: "Categorize transaction: ${transaction['title']}",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

  Future<void> _loadUserNameFromStorage() async {
    try {
      const storage = FlutterSecureStorage();
      final storedName = await storage.read(key: 'user_name');
      // Normalize and guard against null/empty values coming from storage
      String nameToUse = (storedName ?? '').trim();
      if (nameToUse.isEmpty) {
        final email = await storage.read(key: 'user_email');
        nameToUse = _deriveNameFromEmail(email).trim();
      }
      final String safeName = nameToUse;
      if (mounted && safeName.isNotEmpty) {
        setState(() {
          _userName = safeName;
        });
      }
    } catch (_) {
      // keep default name on failure
    }
  }

  String _deriveNameFromEmail(String? email) {
    if (email == null || email.isEmpty) return _userName;
    final beforeAt = (email.split('@').isNotEmpty) ? email.split('@').first : email;
    final parts = beforeAt.replaceAll(RegExp(r'[._-]+'), ' ').split(' ');
    final capped = parts
        .where((p) => p.isNotEmpty)
        .map((p) => p[0].toUpperCase() + (p.length > 1 ? p.substring(1) : ''))
        .join(' ');
    return capped.isEmpty ? _userName : capped;
  }

  // Removed unused UI helpers (_getGreeting, _buildAvatar, _formatLastUpdated)

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Dashboard', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
        leading: Builder(
          builder: (context) => IconButton(
            tooltip: 'Quick Actions',
            icon: const Icon(Icons.grid_view, color: Colors.white),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.secondary,
              ],
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x33000000),
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
        ),
        actions: [
          // Date picker for indexed search by day
          IconButton(
            tooltip: _selectedDate == null
                ? 'Pick Date'
                : 'Selected: ${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}',
            icon: const Icon(Icons.calendar_month, color: Colors.white),
            onPressed: _pickDate,
          ),
          // Settings
          IconButton(
            tooltip: 'Settings',
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () => Navigator.pushNamed(context, '/profile-screen'),
          ),
          // Live/Mock toggle
          IconButton(
            tooltip: _useLiveData ? 'Live Data: ON' : 'Live Data: OFF',
            icon: Icon(_useLiveData ? Icons.wifi : Icons.storage, color: Colors.white),
            onPressed: _toggleLiveData,
          ),
          // Removed Add Expense and Add Income from AppBar actions
          // Removed Budgets, Reports, and History icons from AppBar
        ],
      ),
      drawer: Drawer(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context).colorScheme.secondary,
                    ],
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Quick Actions',
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: LayoutBuilder(builder: (context, constraints) {
                    final double width = constraints.maxWidth;
                    final int cols = width < 360 ? 2 : 3;
                    return GridView.count(
                      crossAxisCount: cols,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      children: [
                        _QuickActionButton(
                          iconData: Icons.remove_circle_outline,
                          label: 'Add Expense',
                          color: AppTheme.errorLight,
                          onTap: () {
                            Navigator.pop(context);
                            _handleAddExpense();
                          },
                        ),
                        _QuickActionButton(
                          iconData: Icons.add_circle_outline,
                          label: 'Add Income',
                          color: AppTheme.successLight,
                          onTap: () {
                            Navigator.pop(context);
                            _handleAddIncome();
                          },
                        ),
                        _QuickActionButton(
                          iconData: Icons.receipt_long,
                          label: 'Recent Transactions',
                          color: AppTheme.lightTheme.primaryColor,
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.pushNamed(context, '/transaction-history-screen');
                          },
                        ),
                        _QuickActionButton(
                          iconData: Icons.pie_chart_outline,
                          label: 'Budgets',
                          color: AppTheme.categoryColors[2],
                          onTap: () {
                            Navigator.pop(context);
                            _handleViewBudgets();
                          },
                        ),
                        _QuickActionButton(
                          iconData: Icons.bar_chart,
                          label: 'Reports',
                          color: AppTheme.categoryColors[5],
                          onTap: () {
                            Navigator.pop(context);
                            _handleViewReports();
                          },
                        ),
                      ],
                    );
                  }),
                ),
              ),
            ],
          ),
        ),
      ),
      body: SafeArea(
            child: Column(
          children: [
            // Header moved to AppTopBar

            // Main Content
            Expanded(
              child: RefreshIndicator(
                onRefresh: _handleRefresh,
                color: AppTheme.lightTheme.primaryColor,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final isWide = constraints.maxWidth >= 800;
                      final tileSpacing = kSpacingM;
                      return Wrap(
                        spacing: tileSpacing,
                        runSpacing: tileSpacing,
                        alignment: WrapAlignment.start,
                        children: [
                      SizedBox(height: kSpacingM),
                          // Balance Card (full-width or half on wide)
                          SizedBox(
                            width: isWide ? (constraints.maxWidth - tileSpacing) / 2 : constraints.maxWidth,
                            child: Builder(builder: (context) {
                              double displayedBalance = _totalBalance;
                              if (_useLiveData) {
                                if (_liveIncome != null && _liveSpent != null) {
                                  displayedBalance = (_liveIncome ?? 0.0) - (_liveSpent ?? 0.0);
                                } else if (_recentTransactions.isNotEmpty) {
                                  double sum = 0.0;
                                    final Iterable<Map<String, dynamic>> sourceTx = _selectedDate == null
                                      ? _recentTransactions
                                      : _recentTransactions.where((tx) {
                                        final DateTime d = (tx['date'] is DateTime)
                                          ? tx['date'] as DateTime
                                          : DateTime.tryParse(tx['date'].toString()) ?? DateTime.now();
                                        return d.year == _selectedDate!.year &&
                                          d.month == _selectedDate!.month &&
                                          d.day == _selectedDate!.day;
                                      });
                                  for (final tx in sourceTx) {
                                    final amt = (tx['amount'] is num) ? (tx['amount'] as num).toDouble() : 0.0;
                                    final type = (tx['type'] ?? 'expense').toString().toLowerCase();
                                    if (type == 'income') {
                                      sum += amt;
                                    } else {
                                      sum -= amt;
                                    }
                                  }
                                  displayedBalance = sum;
                                }
                              }
                              return BalanceCardWidget(
                                totalBalance: displayedBalance,
                                isBalanceVisible: _isBalanceVisible,
                                onToggleVisibility: _toggleBalanceVisibility,
                                useLiveData: _useLiveData,
                                userName: _userName,
                              );
                            }),
                          ),

                          // Quick Actions moved to AppBar actions

                          // Spending Summary (tile)
                          SizedBox(
                            width: isWide ? (constraints.maxWidth - tileSpacing) / 2 : constraints.maxWidth,
                            child: Builder(builder: (context) {
                              double computedSpent = _spentAmount;
                              List<Map<String, dynamic>> computedBreakdown = List<Map<String, dynamic>>.from(_categoryBreakdown);
                              final List<Map<String, dynamic>> filteredTx = _selectedDate == null
                                  ? _recentTransactions
                                  : _recentTransactions.where((tx) {
                                      final DateTime d = (tx['date'] is DateTime)
                                          ? tx['date'] as DateTime
                                          : DateTime.tryParse(tx['date'].toString()) ?? DateTime.now();
                                      return d.year == _selectedDate!.year &&
                                          d.month == _selectedDate!.month &&
                                          d.day == _selectedDate!.day;
                                    }).toList();

                              if (_useLiveData && filteredTx.isNotEmpty) {
                                double spent = (_liveSpent != null) ? _liveSpent! : 0.0;
                                final Map<String, double> catSums = {};
                                final Map<String, Color> catColors = {};
                                if (_liveSpent == null) {
                                  for (final tx in filteredTx) {
                                    final amt = (tx['amount'] is num) ? (tx['amount'] as num).toDouble() : 0.0;
                                    final type = (tx['type'] ?? 'expense').toString().toLowerCase();
                                    final catName = (tx['category'] ?? 'Uncategorized').toString();
                                    final catColor = (tx['categoryColor'] is Color) ? tx['categoryColor'] as Color : Theme.of(context).dividerColor;
                                    if (type == 'expense') {
                                      spent += amt;
                                      catSums[catName] = (catSums[catName] ?? 0.0) + amt;
                                      catColors[catName] = catColor;
                                    }
                                  }
                                  computedSpent = spent;
                                  computedBreakdown = catSums.entries.map((e) {
                                    return {
                                      'name': e.key,
                                      'amount': e.value,
                                      'color': catColors[e.key] ?? Theme.of(context).dividerColor,
                                    };
                                  }).toList()
                                    ..sort((a, b) => (b['amount'] as double).compareTo(a['amount'] as double));
                                } else {
                                  final Map<String, double> localCatSums = {};
                                  final Map<String, Color> localCatColors = {};
                                  for (final tx in filteredTx) {
                                    final amt = (tx['amount'] is num) ? (tx['amount'] as num).toDouble() : 0.0;
                                    final type = (tx['type'] ?? 'expense').toString().toLowerCase();
                                    final catName = (tx['category'] ?? 'Uncategorized').toString();
                                    final catColor = (tx['categoryColor'] is Color) ? tx['categoryColor'] as Color : Theme.of(context).dividerColor;
                                    if (type == 'expense') {
                                      localCatSums[catName] = (localCatSums[catName] ?? 0.0) + amt;
                                      localCatColors[catName] = catColor;
                                    }
                                  }
                                  computedBreakdown = localCatSums.entries.map((e) {
                                    return {
                                      'name': e.key,
                                      'amount': e.value,
                                      'color': localCatColors[e.key] ?? Theme.of(context).dividerColor,
                                    };
                                  }).toList()
                                    ..sort((a, b) => (b['amount'] as double).compareTo(a['amount'] as double));
                                }
                              }
                              return SpendingSummaryWidget(
                                monthlyBudget: _monthlyBudget,
                                spentAmount: computedSpent,
                                categoryBreakdown: computedBreakdown,
                              );
                            }),
                          ),

                          // Recent Transactions (full-width tile)
                          SizedBox(
                            width: constraints.maxWidth,
                            child: Column(
                              children: [
                                if (_isLoadingLive)
                                  Padding(
                                    padding: EdgeInsets.symmetric(vertical: kSpacingS),
                                    child: LinearProgressIndicator(
                                      minHeight: 4,
                                      color: AppTheme.lightTheme.primaryColor,
                                    ),
                                  ),
                                RecentTransactionsWidget(
                                  transactions: _selectedDate == null
                                      ? _recentTransactions
                                      : _recentTransactions.where((tx) {
                                          final DateTime d = (tx['date'] is DateTime)
                                              ? tx['date'] as DateTime
                                              : DateTime.tryParse(tx['date'].toString()) ?? DateTime.now();
                                          return d.year == _selectedDate!.year &&
                                              d.month == _selectedDate!.month &&
                                              d.day == _selectedDate!.day;
                                        }).toList(),
                                  onEditTransaction: _handleEditTransaction,
                                  onDeleteTransaction: _handleDeleteTransaction,
                                  onCategorizeTransaction: _handleCategorizeTransaction,
                                ),
                              ],
                            ),
                          ),

                          SizedBox(width: constraints.maxWidth, height: kSpacingXL),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),

      // Bottom Tab Navigation
      bottomNavigationBar: AppBottomNav(
        currentIndex: _currentPage,
        onTap: (index) {
          setState(() => _currentPage = index);
          switch (index) {
            case 0:
              break;
            case 1:
              Navigator.pushNamed(context, '/transaction-history-screen');
              break;
            case 2:
              Navigator.pushNamed(context, '/budget-categories-screen');
              break;
            case 3:
              Navigator.pushNamed(context, '/reports-screen');
              break;
          }
        },
      ),

      // Floating Action Button
      floatingActionButton: FloatingActionButton(
        onPressed: _handleAddExpense,
        backgroundColor: AppTheme.lightTheme.primaryColor,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        elevation: 8,
        child: AnimatedBuilder(
          animation: _refreshAnimation,
          builder: (context, child) {
            return Transform.rotate(
              angle: _refreshAnimation.value * 2 * 3.14159,
              child: CustomIconWidget(
                iconName: _isRefreshing ? 'refresh' : 'add',
                color: Theme.of(context).colorScheme.onPrimary,
                size: 28,
              ),
            );
          },
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  // removed unused helper

}

class _QuickActionButton extends StatelessWidget {
  final IconData iconData;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.iconData,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: color.withAlpha(26),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withAlpha(77), width: 1),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(iconData, color: cs.onPrimary, size: 24),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              textAlign: TextAlign.center,
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HoverableNavIcon extends StatefulWidget {
  final IconData iconData;
  final bool isActive;
  final Color baseColor;

  const _HoverableNavIcon({
    required this.iconData,
    required this.isActive,
    required this.baseColor,
  });

  @override
  State<_HoverableNavIcon> createState() => _HoverableNavIconState();
}

class _HoverableNavIconState extends State<_HoverableNavIcon>
    with SingleTickerProviderStateMixin {
  bool _hovering = false;
  late AnimationController _controller;
  late Animation<double> _scale;
  late Animation<double> _bubbleOpacity;
  late Animation<double> _bubbleSize;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 140),
    );
    _scale = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _bubbleOpacity = Tween<double>(begin: 0.0, end: 0.35).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _bubbleSize = Tween<double>(begin: 0.0, end: 26.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hoverColor = widget.isActive
        ? AppTheme.lightTheme.primaryColor
        : AppTheme.lightTheme.primaryColor.withValues(alpha: 0.6);

    return MouseRegion(
      onEnter: (_) {
        setState(() => _hovering = true);
        _controller.forward();
      },
      onExit: (_) {
        setState(() => _hovering = false);
        _controller.reverse();
      },
      cursor: SystemMouseCursors.click,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return Stack(
            alignment: Alignment.center,
            children: [
              // Soft circular bubble behind icon
              Container(
                width: _bubbleSize.value,
                height: _bubbleSize.value,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: hoverColor.withValues(alpha: _bubbleOpacity.value),
                ),
              ),
              ScaleTransition(
                scale: _scale,
                child: Icon(
                  widget.iconData,
                  size: 24,
                  color: _hovering ? hoverColor : widget.baseColor,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
