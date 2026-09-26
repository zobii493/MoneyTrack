import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/account.dart';
import '../models/budget.dart';
import '../models/category.dart';
import '../models/goal.dart';
import '../models/transaction.dart';
import '../services/firebase_service.dart';
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

    // Check Firebase Firestore if initialized and user logged in
    final uid = FirebaseService.currentUserId;
    if (FirebaseService.isInitialized && uid != null) {
      final firestoreData = await FirebaseService.fetchAllUserData(uid);
      if (firestoreData != null) {
        if (firestoreData['transactions'] != null) {
          _transactions = (firestoreData['transactions'] as List)
              .map((e) => TransactionModel.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList();
        }
        if (firestoreData['accounts'] != null && (firestoreData['accounts'] as List).isNotEmpty) {
          _accounts = (firestoreData['accounts'] as List)
              .map((e) => AccountModel.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList();
        }
        if (firestoreData['budgets'] != null) {
          _budgets = (firestoreData['budgets'] as List)
              .map((e) => BudgetModel.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList();
        }
        if (firestoreData['goals'] != null) {
          _goals = (firestoreData['goals'] as List)
              .map((e) => GoalModel.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList();
        }
        if (firestoreData['categories'] != null && (firestoreData['categories'] as List).isNotEmpty) {
          _categories = (firestoreData['categories'] as List)
              .map((e) => CategoryModel.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList();
        } else {
          _categories = List.from(SampleData.defaultCategories);
        }

        _isLoading = false;
        notifyListeners();
        return;
      }
    }

    // Local Storage Fallback
    final txnsRaw = prefs.getString('transactions');
    if (txnsRaw != null) {
      try {
        final List list = jsonDecode(txnsRaw) as List;
        _transactions = list.map((e) => TransactionModel.fromJson(e as Map<String, dynamic>)).toList();
      } catch (_) {
        _transactions = [];
      }
    } else {
      _transactions = [];
    }

    final catsRaw = prefs.getString('categories');
    if (catsRaw != null) {
      try {
        final List list = jsonDecode(catsRaw) as List;
        _categories = list.map((e) => CategoryModel.fromJson(e as Map<String, dynamic>)).toList();
      } catch (_) {
        _categories = List.from(SampleData.defaultCategories);
      }
    } else {
      _categories = List.from(SampleData.defaultCategories);
    }

    final accsRaw = prefs.getString('accounts');
    if (accsRaw != null) {
      try {
        final List list = jsonDecode(accsRaw) as List;
        _accounts = list.map((e) => AccountModel.fromJson(e as Map<String, dynamic>)).toList();
      } catch (_) {
        _accounts = [
          AccountModel(
            id: 'acc_default',
            name: 'Primary Checking Account',
            type: AccountType.bank,
            balance: 0.0,
            currency: 'USD',
            iconCode: Icons.account_balance.codePoint,
            colorValue: const Color(0xFF0F172A).value,
            updatedAt: DateTime.now(),
          ),
        ];
      }
    } else {
      _accounts = [
        AccountModel(
          id: 'acc_default',
          name: 'Primary Checking Account',
          type: AccountType.bank,
          balance: 0.0,
          currency: 'USD',
          iconCode: Icons.account_balance.codePoint,
          colorValue: const Color(0xFF0F172A).value,
          updatedAt: DateTime.now(),
        ),
      ];
    }

    final budgRaw = prefs.getString('budgets');
    if (budgRaw != null) {
      try {
        final List list = jsonDecode(budgRaw) as List;
        _budgets = list.map((e) => BudgetModel.fromJson(e as Map<String, dynamic>)).toList();
      } catch (_) {
        _budgets = [];
      }
    } else {
      _budgets = [];
    }

    final goalsRaw = prefs.getString('goals');
    if (goalsRaw != null) {
      try {
        final List list = jsonDecode(goalsRaw) as List;
        _goals = list.map((e) => GoalModel.fromJson(e as Map<String, dynamic>)).toList();
      } catch (_) {
        _goals = [];
      }
    } else {
      _goals = [];
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
    _adjustAccountBalanceForTxn(txn, isAdd: true);

    await _saveAll();
    if (FirebaseService.isInitialized) {
      await FirebaseService.saveTransaction(txn);
    }
    notifyListeners();
  }

  Future<void> updateTransaction(TransactionModel updatedTxn) async {
    final index = _transactions.indexWhere((t) => t.id == updatedTxn.id);
    if (index != -1) {
      _adjustAccountBalanceForTxn(_transactions[index], isAdd: false);
      _transactions[index] = updatedTxn;
      _adjustAccountBalanceForTxn(updatedTxn, isAdd: true);

      await _saveAll();
      if (FirebaseService.isInitialized) {
        await FirebaseService.saveTransaction(updatedTxn);
      }
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
      if (FirebaseService.isInitialized) {
        await FirebaseService.deleteTransaction(id);
      }
      notifyListeners();
    }
  }

  void _adjustAccountBalanceForTxn(TransactionModel txn, {required bool isAdd}) {
    final factor = isAdd ? 1.0 : -1.0;
    if (txn.type == TransactionType.income) {
      final accIndex = _accounts.indexWhere((a) => a.id == txn.accountId);
      if (accIndex != -1) {
        final acc = _accounts[accIndex];
        final updatedAcc = acc.copyWith(
          balance: acc.balance + (txn.amount * factor),
          updatedAt: DateTime.now(),
        );
        _accounts[accIndex] = updatedAcc;
        if (FirebaseService.isInitialized) {
          FirebaseService.saveAccount(updatedAcc);
        }
      }
    } else if (txn.type == TransactionType.expense) {
      final accIndex = _accounts.indexWhere((a) => a.id == txn.accountId);
      if (accIndex != -1) {
        final acc = _accounts[accIndex];
        final updatedAcc = acc.copyWith(
          balance: acc.balance - (txn.amount * factor),
          updatedAt: DateTime.now(),
        );
        _accounts[accIndex] = updatedAcc;
        if (FirebaseService.isInitialized) {
          FirebaseService.saveAccount(updatedAcc);
        }
      }
    } else if (txn.type == TransactionType.transfer && txn.toAccountId != null) {
      final fromIndex = _accounts.indexWhere((a) => a.id == txn.accountId);
      final toIndex = _accounts.indexWhere((a) => a.id == txn.toAccountId);
      if (fromIndex != -1) {
        final acc = _accounts[fromIndex];
        final updatedFrom = acc.copyWith(
          balance: acc.balance - (txn.amount * factor),
          updatedAt: DateTime.now(),
        );
        _accounts[fromIndex] = updatedFrom;
        if (FirebaseService.isInitialized) {
          FirebaseService.saveAccount(updatedFrom);
        }
      }
      if (toIndex != -1) {
        final acc = _accounts[toIndex];
        final updatedTo = acc.copyWith(
          balance: acc.balance + (txn.amount * factor),
          updatedAt: DateTime.now(),
        );
        _accounts[toIndex] = updatedTo;
        if (FirebaseService.isInitialized) {
          FirebaseService.saveAccount(updatedTo);
        }
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
    if (FirebaseService.isInitialized) {
      await FirebaseService.saveCategory(cat);
    }
    notifyListeners();
  }

  Future<void> updateCategory(CategoryModel cat) async {
    final idx = _categories.indexWhere((c) => c.id == cat.id);
    if (idx != -1) {
      _categories[idx] = cat;
      await _saveAll();
      if (FirebaseService.isInitialized) {
        await FirebaseService.saveCategory(cat);
      }
      notifyListeners();
    }
  }

  Future<void> deleteCategory(String id) async {
    _categories.removeWhere((c) => c.id == id);
    await _saveAll();
    if (FirebaseService.isInitialized) {
      await FirebaseService.deleteCategory(id);
    }
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
    if (FirebaseService.isInitialized) {
      await FirebaseService.saveAccount(acc);
    }
    notifyListeners();
  }

  Future<void> updateAccount(AccountModel acc) async {
    final idx = _accounts.indexWhere((a) => a.id == acc.id);
    if (idx != -1) {
      _accounts[idx] = acc;
      await _saveAll();
      if (FirebaseService.isInitialized) {
        await FirebaseService.saveAccount(acc);
      }
      notifyListeners();
    }
  }

  Future<void> deleteAccount(String id) async {
    _accounts.removeWhere((a) => a.id == id);
    await _saveAll();
    if (FirebaseService.isInitialized) {
      await FirebaseService.deleteAccount(id);
    }
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
    if (FirebaseService.isInitialized) {
      await FirebaseService.saveBudget(budget);
    }
    notifyListeners();
  }

  Future<void> updateBudget(BudgetModel budget) async {
    final idx = _budgets.indexWhere((b) => b.id == budget.id);
    if (idx != -1) {
      _budgets[idx] = budget;
      await _saveAll();
      if (FirebaseService.isInitialized) {
        await FirebaseService.saveBudget(budget);
      }
      notifyListeners();
    }
  }

  Future<void> deleteBudget(String id) async {
    _budgets.removeWhere((b) => b.id == id);
    await _saveAll();
    if (FirebaseService.isInitialized) {
      await FirebaseService.deleteBudget(id);
    }
    notifyListeners();
  }

  // --- Goal Operations ---

  Future<void> addGoal(GoalModel goal) async {
    _goals.add(goal);
    await _saveAll();
    if (FirebaseService.isInitialized) {
      await FirebaseService.saveGoal(goal);
    }
    notifyListeners();
  }

  Future<void> updateGoal(GoalModel goal) async {
    final idx = _goals.indexWhere((g) => g.id == goal.id);
    if (idx != -1) {
      _goals[idx] = goal;
      await _saveAll();
      if (FirebaseService.isInitialized) {
        await FirebaseService.saveGoal(goal);
      }
      notifyListeners();
    }
  }

  Future<void> addMoneyToGoal(String goalId, double amount, {String? accountId}) async {
    final idx = _goals.indexWhere((g) => g.id == goalId);
    if (idx != -1) {
      final goal = _goals[idx];
      final updatedGoal = goal.copyWith(currentAmount: goal.currentAmount + amount);
      _goals[idx] = updatedGoal;

      if (accountId != null) {
        final accIdx = _accounts.indexWhere((a) => a.id == accountId);
        if (accIdx != -1) {
          final acc = _accounts[accIdx];
          final updatedAcc = acc.copyWith(
            balance: acc.balance - amount,
            updatedAt: DateTime.now(),
          );
          _accounts[accIdx] = updatedAcc;
          if (FirebaseService.isInitialized) {
            FirebaseService.saveAccount(updatedAcc);
          }
        }
      }

      await _saveAll();
      if (FirebaseService.isInitialized) {
        await FirebaseService.saveGoal(updatedGoal);
      }
      notifyListeners();
    }
  }

  Future<void> deleteGoal(String id) async {
    _goals.removeWhere((g) => g.id == id);
    await _saveAll();
    if (FirebaseService.isInitialized) {
      await FirebaseService.deleteGoal(id);
    }
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
