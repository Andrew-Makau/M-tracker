import 'package:flutter/material.dart';
import '../presentation/add_expense_screen/add_expense_screen.dart';
import '../presentation/transaction_history_screen/transaction_history_screen.dart';
import '../presentation/dashboard_home_screen/dashboard_home_screen.dart';
import '../presentation/dashboard_screen.dart';
import '../presentation/login_screen/login_screen.dart';
import '../presentation/budget_screen/budget_screen.dart';
import '../presentation/categories_screen/categories_screen.dart';
import '../presentation/registration_screen/registration_screen.dart';
import '../presentation/settings_screen/settings_screen.dart';
import '../presentation/reports_screen/reports_screen.dart';
import '../presentation/goals_screen/goals_screen.dart';

class AppRoutes {
  // TODO: Add your routes here
  static const String initial = '/';
  static const String addExpense = '/add-expense-screen';
  static const String transactionHistory = '/transaction-history-screen';
  static const String dashboardHome = '/dashboard-home-screen';
  static const String login = '/login-screen';
  static const String budget = '/budget-screen';
  static const String categories = '/categories-screen';
  static const String registration = '/registration-screen';
  static const String signup = '/signup-screen';
  static const String settings = '/settings-screen';
  static const String reports = '/reports-screen';
  static const String dashboard = '/dashboard-screen';
  static const String goals = '/goals-screen';

  static Map<String, WidgetBuilder> routes = {
    initial: (context) => const LoginScreen(),
    addExpense: (context) => const AddExpenseScreen(),
    transactionHistory: (context) => const TransactionHistoryScreen(),
    dashboardHome: (context) => const DashboardHomeScreen(),
    dashboard: (context) => DashboardScreen(),
    login: (context) => const LoginScreen(),
    budget: (context) => const BudgetScreen(),
    categories: (context) => const CategoriesScreen(),
    registration: (context) => const RegistrationScreen(),
    signup: (context) => const RegistrationScreen(),
    settings: (context) => const SettingsScreen(),
    reports: (context) => const ReportsScreen(),
    goals: (context) => const GoalsScreen(),
    // TODO: Add your other routes here
  };
}
