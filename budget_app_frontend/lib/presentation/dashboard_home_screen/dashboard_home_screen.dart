import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sizer/sizer.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../core/app_export.dart';
import '../login_screen/widgets/animated_gradient_background.dart';
import '../../services/transaction_service.dart';
import '../../services/auth_service.dart';
import './widgets/balance_card_widget.dart';
import './widgets/quick_actions_widget.dart';
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
  int _selectedTabIndex = 0;
  String _userName = "Andrew"; // default fallback until loaded from storage
  DateTime _lastUpdated = DateTime.now();
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
        _selectedTabIndex = _tabController.index;
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
      _lastUpdated = DateTime.now();
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
    Navigator.pushNamed(context, '/add-expense-screen');
  }

  void _handleAddIncome() {
    HapticFeedback.lightImpact();
    Navigator.pushNamed(context, '/add-expense-screen');
  }

  void _handleViewBudgets() {
    HapticFeedback.lightImpact();
    Navigator.pushNamed(context, '/budget-categories-screen');
  }

  void _handleViewReports() {
    HapticFeedback.lightImpact();
    Navigator.pushNamed(context, '/transaction-history-screen');
  }

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

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning';
    } else if (hour < 17) {
      return 'Good Afternoon';
    } else {
      return 'Good Evening';
    }
  }

  String _formatLastUpdated() {
    final now = DateTime.now();
    final difference = now.difference(_lastUpdated);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          const AnimatedGradientBackground(),
          SafeArea(
            child: Column(
          children: [
            // Sticky Header
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.cardColor,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.shadowLight,
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${_getGreeting()}, $_userName!',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTheme.lightTheme.textTheme.headlineSmall
                              ?.copyWith(
                            fontSize: 22.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 0.5.h),
                        Text(
                          'Last updated: ${_formatLastUpdated()}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style:
                              AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                            fontSize: 13.sp,
                            color:
                                AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: 18.w),
                        child: Text(
                          _useLiveData ? 'Live' : 'Mock',
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                            fontSize: 11.sp,
                            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                      Switch(
                        value: _useLiveData,
                        activeThumbColor: AppTheme.lightTheme.primaryColor,
                        onChanged: (val) async {
                          HapticFeedback.lightImpact();
                          setState(() => _useLiveData = val);
                          if (val) {
                            // switching to Live → fetch
                            await _fetchAndSetTransactions();
                          } else {
                            // switching back to Mock → restore initial mock list
                            setState(() {
                              _recentTransactions = List<Map<String, dynamic>>.from(_initialMockTransactions);
                            });
                          }
                        },
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      Fluttertoast.showToast(
                        msg: "No new notifications",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                      );
                    },
                        child: Container(
                      padding: EdgeInsets.all(3.w),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary.withAlpha(26),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Stack(
                        children: [
                          CustomIconWidget(
                            iconName: 'notifications',
                            color: AppTheme.lightTheme.primaryColor,
                            size: 24,
                          ),
                          Positioned(
                            right: 0,
                            top: 0,
                              child: Container(
                              width: 2.w,
                              height: 2.w,
                              decoration: BoxDecoration(
                                color: AppTheme.errorLight,
                                borderRadius: BorderRadius.circular(1.w),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Main Content
            Expanded(
              child: RefreshIndicator(
                onRefresh: _handleRefresh,
                color: AppTheme.lightTheme.primaryColor,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    children: [
                      SizedBox(height: 2.h),

                      // Balance Card
                      Builder(builder: (context) {
                        // When live data is enabled, compute the total from recent transactions.
                        double displayedBalance = _totalBalance;
                        if (_useLiveData) {
                          if (_liveIncome != null && _liveSpent != null) {
                            displayedBalance = (_liveIncome ?? 0.0) - (_liveSpent ?? 0.0);
                          } else if (_recentTransactions.isNotEmpty) {
                            double sum = 0.0;
                            for (final tx in _recentTransactions) {
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
                        );
                      }),

                      // Quick Actions
                      QuickActionsWidget(
                        onAddExpense: _handleAddExpense,
                        onAddIncome: _handleAddIncome,
                        onViewBudgets: _handleViewBudgets,
                        onViewReports: _handleViewReports,
                      ),

                      // Spending Summary
                      Builder(builder: (context) {
                        // When live data is enabled, compute spent amount and category breakdown
                        double computedSpent = _spentAmount;
                        List<Map<String, dynamic>> computedBreakdown = List<Map<String, dynamic>>.from(_categoryBreakdown);

                        if (_useLiveData && _recentTransactions.isNotEmpty) {
                          // Prefer server-provided summary if available
                          double spent = (_liveSpent != null) ? _liveSpent! : 0.0;
                          final Map<String, double> catSums = {};
                          final Map<String, Color> catColors = {};
                          // If the backend didn't provide a breakdown, compute per-category sums locally.
                          if (_liveSpent == null) {
                            for (final tx in _recentTransactions) {
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

                            // Convert map to list sorted by amount desc
                            computedBreakdown = catSums.entries.map((e) {
                              return {
                                'name': e.key,
                                'amount': e.value,
                                'color': catColors[e.key] ?? Theme.of(context).dividerColor,
                              };
                            }).toList()
                              ..sort((a, b) => (b['amount'] as double).compareTo(a['amount'] as double));
                          } else {
                            // We have a server-provided spent value; still compute breakdown locally
                            final Map<String, double> localCatSums = {};
                            final Map<String, Color> localCatColors = {};
                            for (final tx in _recentTransactions) {
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

                      // Recent Transactions
                      if (_isLoadingLive)
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 1.h),
                          child: LinearProgressIndicator(
                            minHeight: 4,
                            color: AppTheme.lightTheme.primaryColor,
                          ),
                        ),
                      RecentTransactionsWidget(
                        transactions: _recentTransactions,
                        onEditTransaction: _handleEditTransaction,
                        onDeleteTransaction: _handleDeleteTransaction,
                        onCategorizeTransaction: _handleCategorizeTransaction,
                      ),

                      SizedBox(height: 10.h), // Bottom padding for tab bar
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
          ),
        ],
      ),

      // Bottom Tab Navigation
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
                color: AppTheme.shadowLight,
                blurRadius: 20,
                offset: const Offset(0, -5),
              ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedTabIndex,
          onTap: (index) {
            setState(() {
              _selectedTabIndex = index;
            });
            HapticFeedback.lightImpact();

            // Navigate to different screens based on tab
            switch (index) {
              case 0:
                // Already on home
                break;
              case 1:
                Navigator.pushNamed(context, '/transaction-history-screen');
                break;
              case 2:
                Navigator.pushNamed(context, '/budget-categories-screen');
                break;
              case 3:
                Navigator.pushNamed(context, '/profile-screen');
                break;
            }
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: AppTheme.lightTheme.cardColor,
          selectedItemColor: AppTheme.lightTheme.primaryColor,
          unselectedItemColor: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
          selectedLabelStyle:
              AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
            fontSize: 11.sp,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle:
              AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
            fontSize: 11.sp,
            fontWeight: FontWeight.w400,
          ),
          items: [
            BottomNavigationBarItem(
              icon: CustomIconWidget(
                iconName: 'home',
                color: _selectedTabIndex == 0
                    ? AppTheme.lightTheme.primaryColor
                    : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                size: 24,
              ),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: CustomIconWidget(
                iconName: 'history',
                color: _selectedTabIndex == 1
                    ? AppTheme.lightTheme.primaryColor
                    : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                size: 24,
              ),
              label: 'History',
            ),
            BottomNavigationBarItem(
              icon: CustomIconWidget(
                iconName: 'pie_chart',
                color: _selectedTabIndex == 2
                    ? AppTheme.lightTheme.primaryColor
                    : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                size: 24,
              ),
              label: 'Budget',
            ),
            BottomNavigationBarItem(
              icon: CustomIconWidget(
                iconName: 'person',
                color: _selectedTabIndex == 3
                    ? AppTheme.lightTheme.primaryColor
                    : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                size: 24,
              ),
              label: 'Profile',
            ),
          ],
        ),
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
}
