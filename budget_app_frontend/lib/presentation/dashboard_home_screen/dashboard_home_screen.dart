import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
// import 'package:sizer/sizer.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../core/app_export.dart';
// Removed gradient background for minimal/flat design
import '../../core/design_tokens.dart';
import '../../widgets/app_bottom_nav.dart';
import '../../widgets/brand_app_bar.dart';
// import 'package:dot_curved_bottom_nav/dot_curved_bottom_nav.dart'; // enable after pub get
import '../../services/transaction_service.dart';
import '../../services/auth_service.dart';
import './widgets/recent_transactions_widget.dart';
import './widgets/spending_summary_widget.dart';
import './widgets/summary_stat_card.dart';

// Palette constants
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

  String _formatAmount(double value) {
    final bool isNegative = value < 0;
    final double absVal = value.abs();
    // Simplified formatting to avoid external deps
    String formatted;
    if (absVal >= 1000) {
      formatted = absVal.toStringAsFixed(0);
    } else {
      formatted = absVal.toStringAsFixed(2);
    }
    return isNegative ? '-\$${formatted}' : '\$${formatted}';
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
      backgroundColor: kBaseBackground,
      appBar: BrandAppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 34,
              width: 34,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: kPrimary,
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
                child: Center(
                  child: Icon(Icons.account_balance_wallet_outlined, color: Colors.white, size: 18),
                ),
              ),
            ),
            SizedBox(width: 10),
            Text(
              'BudgetFlow',
              style: TextStyle(
                color: kBaseText,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        leading: const SizedBox.shrink(),
        actions: [
          IconButton(
            tooltip: _selectedDate == null
                ? 'Pick Date'
                : 'Selected: ${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}',
            icon: const Icon(Icons.calendar_month, color: Colors.black),
            onPressed: _pickDate,
          ),
          IconButton(
            tooltip: 'Settings',
            icon: const Icon(Icons.settings, color: Colors.black),
            onPressed: () => Navigator.pushNamed(context, '/profile-screen'),
          ),
          IconButton(
            tooltip: _useLiveData ? 'Live Data: ON' : 'Live Data: OFF',
            icon: Icon(_useLiveData ? Icons.wifi : Icons.storage, color: Colors.black),
            onPressed: _toggleLiveData,
          ),
          Builder(
            builder: (ctx) => IconButton(
              tooltip: 'Quick Actions',
              icon: const Icon(Icons.grid_view, color: Colors.black),
              onPressed: () => Scaffold.of(ctx).openEndDrawer(),
            ),
          ),
        ],
      ),
      endDrawer: Drawer(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            bottomLeft: Radius.circular(20),
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
      body: Stack(
        children: [
          // Glassmorphism background layer
          const Positioned.fill(child: _GlassBackground()),
          SafeArea(
            child: RefreshIndicator(
              onRefresh: _handleRefresh,
              color: AppTheme.lightTheme.primaryColor,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isWide = constraints.maxWidth >= 800;
                    final tileSpacing = kSpacingM;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Greeting moved under AppBar, now scrolls with content
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _greeting(),
                                    style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                                      color: kBaseText,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 20,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _formattedDateTime(),
                                    style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                                      color: kMutedText,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              GestureDetector(
                                onTap: () => Navigator.pushNamed(context, '/profile-screen'),
                                child: CircleAvatar(
                                  radius: 20,
                                  backgroundColor: kPrimary,
                                  child: Text(
                                    _userInitial(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: kSpacingM),
                        Wrap(
                          spacing: tileSpacing,
                          runSpacing: tileSpacing,
                          alignment: WrapAlignment.start,
                          children: [
                            Builder(builder: (context) {
                              final Iterable<Map<String, dynamic>> filteredTx = _selectedDate == null
                                  ? _recentTransactions
                                  : _recentTransactions.where((tx) {
                                      final DateTime d = (tx['date'] is DateTime)
                                          ? tx['date'] as DateTime
                                          : DateTime.tryParse(tx['date'].toString()) ?? DateTime.now();
                                      return d.year == _selectedDate!.year &&
                                          d.month == _selectedDate!.month &&
                                          d.day == _selectedDate!.day;
                                    });

                              double income = _liveIncome ?? 0.0;
                              double expenses = _liveSpent ?? 0.0;
                              if (_liveIncome == null || _liveSpent == null) {
                                income = 0.0;
                                expenses = 0.0;
                                for (final tx in filteredTx) {
                                  final amt = (tx['amount'] is num) ? (tx['amount'] as num).toDouble() : 0.0;
                                  final type = (tx['type'] ?? 'expense').toString().toLowerCase();
                                  if (type == 'income') {
                                    income += amt;
                                  } else {
                                    expenses += amt;
                                  }
                                }
                              }

                              double displayedBalance = income - expenses;
                              if (!_useLiveData && displayedBalance == 0.0) {
                                displayedBalance = _totalBalance;
                              }

                              final double savingsRate = income > 0
                                  ? ((income - expenses) / income).clamp(0.0, 1.0)
                                  : 0.68;

                              // Force a 2x2 grid even on mobile; tighten aspect on narrow widths to avoid overflow
                              final int crossAxisCount = 2;
                              // Make cards wider relative to height so they appear shorter on screen
                              final double aspectRatio = constraints.maxWidth < 420 ? 2.2 : 2.6;
                              final cards = <SummaryStatCard>[
                                SummaryStatCard(
                                  title: 'Current Balance',
                                  value: _formatAmount(displayedBalance),
                                  changeText: '+12.5% from last month',
                                  changeColor: Colors.white,
                                  gradient: const [Color(0xFF1FB887), Color(0xFF16A084)],
                                  icon: Icons.account_balance_wallet_rounded,
                                  iconBg: Colors.white24,
                                  titleColor: Colors.white,
                                  valueColor: Colors.white,
                                  subtleShadow: true,
                                ),
                                SummaryStatCard(
                                  title: 'Total Income',
                                  value: _formatAmount(income),
                                  changeText: '+8.2% from last month',
                                  changeColor: const Color(0xFF1F7A63),
                                  gradient: const [Color(0xFFF7FFFB), Color(0xFFECF9F5)],
                                  icon: Icons.trending_up_rounded,
                                  iconBg: const Color(0xFFD9F3E7),
                                  titleColor: kBaseText,
                                  valueColor: kBaseText,
                                  borderColor: const Color(0xFFE0E5EB),
                                ),
                                SummaryStatCard(
                                  title: 'Total Expenses',
                                  value: _formatAmount(expenses),
                                  changeText: '+3.1% from last month',
                                  changeColor: const Color(0xFFDE3B3B),
                                  gradient: const [Color(0xFFFCECEC), Color(0xFFF8E5E5)],
                                  icon: Icons.trending_down_rounded,
                                  iconBg: const Color(0xFFF4D8D8),
                                  titleColor: kBaseText,
                                  valueColor: const Color(0xFF0F172A),
                                  borderColor: const Color(0xFFE0E5EB),
                                ),
                                SummaryStatCard(
                                  title: 'Savings Goal',
                                  value: '${(savingsRate * 100).round()}%',
                                  changeText: '+5.4% from last month',
                                  changeColor: const Color(0xFF1F7A63),
                                  gradient: const [Colors.white],
                                  icon: Icons.savings_rounded,
                                  iconBg: const Color(0xFFE9EDF5),
                                  titleColor: kMutedText,
                                  valueColor: kBaseText,
                                  borderColor: const Color(0xFFE0E5EB),
                                  subtleShadow: false,
                                ),
                              ];

                              return SizedBox(
                                width: constraints.maxWidth,
                                child: GridView.count(
                                  physics: const NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  crossAxisCount: crossAxisCount,
                                  mainAxisSpacing: tileSpacing,
                                  crossAxisSpacing: tileSpacing,
                                  childAspectRatio: aspectRatio,
                                  children: cards,
                                ),
                              );
                            }),

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
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ],
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

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning, ${_userName}!';
    if (hour < 17) return 'Good Afternoon, ${_userName}!';
    return 'Good Evening, ${_userName}!';
  }

  String _formattedDateTime() {
    final now = DateTime.now();
    const monthNames = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    final month = monthNames[now.month - 1];
    final day = now.day.toString();
    final year = now.year.toString();
    final hour12 = now.hour % 12 == 0 ? 12 : now.hour % 12;
    final minute = now.minute.toString().padLeft(2, '0');
    final amPm = now.hour >= 12 ? 'PM' : 'AM';
    final tz = now.timeZoneName; // e.g., EAT / GMT+3
    return '$month $day, $year · $hour12:$minute $amPm $tz';
  }

  String _userInitial() {
    final trimmed = _userName.trim();
    if (trimmed.isEmpty) return 'A';
    return trimmed[0].toUpperCase();
  }

  // unused legacy bottom-sheet quick actions removed

}

class _GlassBackground extends StatelessWidget {
  const _GlassBackground({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Soft gradient base
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFEEF7FF), Color(0xFFFFFFFF)],
            ),
          ),
        ),

        // Backdrop blur with translucent overlay to create glass effect
        Positioned.fill(
          child: ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 24.0, sigmaY: 24.0),
              child: Container(
                color: Colors.white.withOpacity(0.06),
              ),
            ),
          ),
        ),

        // Decorative soft circles (subtle highlights)
        Positioned(
          left: -60,
          top: -40,
          child: Container(
            width: 220,
            height: 220,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(colors: [Colors.white.withOpacity(0.14), Colors.transparent]),
            ),
          ),
        ),
        Positioned(
          right: -80,
          bottom: -60,
          child: Container(
            width: 260,
            height: 260,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(colors: [Colors.white.withOpacity(0.12), Colors.transparent]),
            ),
          ),
        ),
      ],
    );
  }
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
