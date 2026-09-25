import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/account.dart';
import '../models/budget.dart';
import '../models/category.dart';
import '../models/goal.dart';
import '../models/transaction.dart';
import '../utils/sample_data.dart';

class FinanceProvider with ChangeNotifier {
  List<TransactionModel> _transactions = [];
  List<CategoryModel> _categories = [];
  List<AccountModel> _accounts = [];
  List<BudgetModel> _budgets = [];
  List<GoalModel> _goals = [];
  bool _isLoading = true;

  List<TransactionModel> get transactions => _transactions;
  List<CategoryModel> get categories => _categories;
  List<AccountModel> get accounts => _accounts;
  List<BudgetModel> get budgets => _budgets;
  List<GoalModel> get goals => _goals;
  bool get isLoading => _isLoading;

  FinanceProvider() {
    loadData();
  }

  Future<void> loadData() async {
    _isLoading = true;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();

    // Transactions
    final txnsRaw = prefs.getString('transactions');
    if (txnsRaw != null) {
      try {
        final List list = jsonDecode(txnsRaw) as List;
        _transactions = list.map((e) => TransactionModel.fromJson(e as Map<String, dynamic>)).toList();
      } catch (e) {
        _transactions = SampleData.getSampleTransactions();
      }
    } else {
      _transactions = SampleData.getSampleTransactions();
    }

    // Categories
    final catsRaw = prefs.getString('categories');
    if (catsRaw != null) {
      try {
        final List list = jsonDecode(catsRaw) as List;
        _categories = list.map((e) => CategoryModel.fromJson(e as Map<String, dynamic>)).toList();
      } catch (e) {
        _categories = SampleData.defaultCategories;
      }
    } else {
      _categories = SampleData.defaultCategories;
    }

    // Accounts
    final accsRaw = prefs.getString('accounts');
    if (accsRaw != null) {
      try {
        final List list = jsonDecode(accsRaw) as List;
        _accounts = list.map((e) => AccountModel.fromJson(e as Map<String, dynamic>)).toList();
      } catch (e) {
        _accounts = SampleData.defaultAccounts;
      }
    } else {
      _accounts = SampleData.defaultAccounts;
    }

    // Budgets
    final budgRaw = prefs.getString('budgets');
    if (budgRaw != null) {
      try {
        final List list = jsonDecode(budgRaw) as List;
        _budgets = list.map((e) => BudgetModel.fromJson(e as Map<String, dynamic>)).toList();
      } catch (e) {
        _budgets = SampleData.defaultBudgets;
      }
    } else {
      _budgets = SampleData.defaultBudgets;
    }

    // Goals
    final goalsRaw = prefs.getString('goals');
    if (goalsRaw != null) {
      try {
        final List list = jsonDecode(goalsRaw) as List;
        _goals = list.map((e) => GoalModel.fromJson(e as Map<String, dynamic>)).toList();
      } catch (e) {
        _goals = SampleData.defaultGoals;
      }
    } else {
      _goals = SampleData.defaultGoals;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _saveAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('transactions', jsonEncode(_transactions.map((e) => e.toJson()).toList()));
    await prefs.setString('categories', jsonEncode(_categories.map((e) => e.toJson()).toList()));
    await prefs.setString('accounts', jsonEncode(_accounts.map((e) => e.toJson()).toList()));
    await prefs.setString('budgets', jsonEncode(_budgets.map((e) => e.toJson()).toList()));
    await prefs.setString('goals', jsonEncode(_goals.map((e) => e.toJson()).toList()));
  }

  // --- Financial Calculations ---

  double get totalBalance {
    double total = 0;
    for (var acc in _accounts) {
      total += acc.balance;
    }
    return total;
  }

  double get totalIncomeMonth {
    final now = DateTime.now();
    return _transactions
        .where((t) =>
            t.type == TransactionType.income &&
            t.date.year == now.year &&
            t.date.month == now.month)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double get totalExpenseMonth {
    final now = DateTime.now();
    return _transactions
        .where((t) =>
            t.type == TransactionType.expense &&
            t.date.year == now.year &&
            t.date.month == now.month)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double get totalSavingsMonth {
    final income = totalIncomeMonth;
    final expense = totalExpenseMonth;
    return (income - expense).clamp(0.0, double.infinity);
  }

  double get availableBalance => totalBalance;

  // --- Transaction Operations ---

  Future<void> addTransaction(TransactionModel txn) async {
    _transactions.insert(0, txn);

    // Update account balances
    _adjustAccountBalanceForTxn(txn, isAdd: true);

    await _saveAll();
    notifyListeners();
  }

  Future<void> updateTransaction(TransactionModel updatedTxn) async {
    final index = _transactions.indexWhere((t) => t.id == updatedTxn.id);
    if (index != -1) {
      // Revert old transaction's impact
      _adjustAccountBalanceForTxn(_transactions[index], isAdd: false);
      
      _transactions[index] = updatedTxn;
      
      // Apply new transaction's impact
      _adjustAccountBalanceForTxn(updatedTxn, isAdd: true);

      await _saveAll();
      notifyListeners();
    }
  }

  Future<void> deleteTransaction(String id) async {
    final index = _transactions.indexWhere((t) => t.id == id);
    if (index != -1) {
      final txn = _transactions[index];
      _adjustAccountBalanceForTxn(txn, isAdd: false);
      _transactions.removeAt(index);
      await _saveAll();
      notifyListeners();
    }
  }

  void _adjustAccountBalanceForTxn(TransactionModel txn, {required bool isAdd}) {
    final factor = isAdd ? 1.0 : -1.0;
    if (txn.type == TransactionType.income) {
      final accIndex = _accounts.indexWhere((a) => a.id == txn.accountId);
      if (accIndex != -1) {
        final acc = _accounts[accIndex];
        _accounts[accIndex] = acc.copyWith(
          balance: acc.balance + (txn.amount * factor),
          updatedAt: DateTime.now(),
        );
      }
    } else if (txn.type == TransactionType.expense) {
      final accIndex = _accounts.indexWhere((a) => a.id == txn.accountId);
      if (accIndex != -1) {
        final acc = _accounts[accIndex];
        _accounts[accIndex] = acc.copyWith(
          balance: acc.balance - (txn.amount * factor),
          updatedAt: DateTime.now(),
        );
      }
    } else if (txn.type == TransactionType.transfer && txn.toAccountId != null) {
      final fromIndex = _accounts.indexWhere((a) => a.id == txn.accountId);
      final toIndex = _accounts.indexWhere((a) => a.id == txn.toAccountId);
      if (fromIndex != -1) {
        final acc = _accounts[fromIndex];
        _accounts[fromIndex] = acc.copyWith(
          balance: acc.balance - (txn.amount * factor),
          updatedAt: DateTime.now(),
        );
      }
      if (toIndex != -1) {
        final acc = _accounts[toIndex];
        _accounts[toIndex] = acc.copyWith(
          balance: acc.balance + (txn.amount * factor),
          updatedAt: DateTime.now(),
        );
      }
    }
  }

  // --- Category Operations ---

  CategoryModel? getCategoryById(String categoryId) {
    try {
      return _categories.firstWhere((c) => c.id == categoryId);
    } catch (_) {
      return null;
    }
  }

  Future<void> addCategory(CategoryModel cat) async {
    _categories.add(cat);
    await _saveAll();
    notifyListeners();
  }

  Future<void> updateCategory(CategoryModel cat) async {
    final idx = _categories.indexWhere((c) => c.id == cat.id);
    if (idx != -1) {
      _categories[idx] = cat;
      await _saveAll();
      notifyListeners();
    }
  }

  Future<void> deleteCategory(String id) async {
    _categories.removeWhere((c) => c.id == id);
    await _saveAll();
    notifyListeners();
  }

  // --- Account Operations ---

  AccountModel? getAccountById(String accountId) {
    try {
      return _accounts.firstWhere((a) => a.id == accountId);
    } catch (_) {
      return null;
    }
  }

  Future<void> addAccount(AccountModel acc) async {
    _accounts.add(acc);
    await _saveAll();
    notifyListeners();
  }

  Future<void> updateAccount(AccountModel acc) async {
    final idx = _accounts.indexWhere((a) => a.id == acc.id);
    if (idx != -1) {
      _accounts[idx] = acc;
      await _saveAll();
      notifyListeners();
    }
  }

  Future<void> deleteAccount(String id) async {
    _accounts.removeWhere((a) => a.id == id);
    await _saveAll();
    notifyListeners();
  }

  // --- Budget Operations ---

  double getCategorySpentCurrentMonth(String categoryId) {
    final now = DateTime.now();
    return _transactions
        .where((t) =>
            t.categoryId == categoryId &&
            t.type == TransactionType.expense &&
            t.date.year == now.year &&
            t.date.month == now.month)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  Future<void> addBudget(BudgetModel budget) async {
    _budgets.add(budget);
    await _saveAll();
    notifyListeners();
  }

  Future<void> updateBudget(BudgetModel budget) async {
    final idx = _budgets.indexWhere((b) => b.id == budget.id);
    if (idx != -1) {
      _budgets[idx] = budget;
      await _saveAll();
      notifyListeners();
    }
  }

  Future<void> deleteBudget(String id) async {
    _budgets.removeWhere((b) => b.id == id);
    await _saveAll();
    notifyListeners();
  }

  // --- Goal Operations ---

  Future<void> addGoal(GoalModel goal) async {
    _goals.add(goal);
    await _saveAll();
    notifyListeners();
  }

  Future<void> updateGoal(GoalModel goal) async {
    final idx = _goals.indexWhere((g) => g.id == goal.id);
    if (idx != -1) {
      _goals[idx] = goal;
      await _saveAll();
      notifyListeners();
    }
  }

  Future<void> addMoneyToGoal(String goalId, double amount, {String? accountId}) async {
    final idx = _goals.indexWhere((g) => g.id == goalId);
    if (idx != -1) {
      final goal = _goals[idx];
      _goals[idx] = goal.copyWith(currentAmount: goal.currentAmount + amount);

      // Deduct from account if accountId provided
      if (accountId != null) {
        final accIdx = _accounts.indexWhere((a) => a.id == accountId);
        if (accIdx != -1) {
          final acc = _accounts[accIdx];
          _accounts[accIdx] = acc.copyWith(
            balance: acc.balance - amount,
            updatedAt: DateTime.now(),
          );
        }
      }

      await _saveAll();
      notifyListeners();
    }
  }

  Future<void> deleteGoal(String id) async {
    _goals.removeWhere((g) => g.id == id);
    await _saveAll();
    notifyListeners();
  }

  // --- Reset Sample Data ---

  Future<void> resetToSampleData() async {
    _transactions = SampleData.getSampleTransactions();
    _categories = List.from(SampleData.defaultCategories);
    _accounts = List.from(SampleData.defaultAccounts);
    _budgets = List.from(SampleData.defaultBudgets);
    _goals = List.from(SampleData.defaultGoals);
    await _saveAll();
    notifyListeners();
  }
}
