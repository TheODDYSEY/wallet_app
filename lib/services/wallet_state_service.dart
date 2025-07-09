import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../models/wallet_model.dart';
import '../models/transaction_model.dart';
import 'api_service.dart';

class WalletStateService extends ChangeNotifier {
  static final WalletStateService _instance = WalletStateService._internal();
  factory WalletStateService() => _instance;
  WalletStateService._internal();

  final ApiService _apiService = ApiService();

  // State variables
  UserModel? _currentUser;
  WalletModel? _wallet;
  List<TransactionModel> _transactions = [];
  bool _isLoading = false;
  String? _error;
  bool _isLoggedIn = false;

  // Getters
  UserModel? get currentUser => _currentUser;
  WalletModel? get wallet => _wallet;
  List<TransactionModel> get transactions => _transactions;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _isLoggedIn;
  double get balance => _wallet?.balance ?? 0.0;
  String get formattedBalance => _wallet?.formattedBalance ?? '\$0.00';

  // Authentication methods
  Future<bool> login(String phoneNumber, String pin) async {
    try {
      _setLoading(true);
      _clearError();

      final response = await _apiService.login(phoneNumber, pin);

      if (response['success']) {
        await _loadUserData();
        _isLoggedIn = true;

        // Save login state
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('is_logged_in', true);
        await prefs.setString('user_phone', phoneNumber);

        notifyListeners();
        return true;
      }

      _setError(response['message'] ?? 'Login failed');
      return false;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> register(Map<String, dynamic> userData) async {
    try {
      _setLoading(true);
      _clearError();

      final response = await _apiService.register(userData);

      if (response['success']) {
        await _loadUserData();
        _isLoggedIn = true;

        // Save login state
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('is_logged_in', true);
        await prefs.setString('user_phone', userData['phoneNumber']);

        notifyListeners();
        return true;
      }

      _setError(response['message'] ?? 'Registration failed');
      return false;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    try {
      await _apiService.logout();

      // Clear local state
      _currentUser = null;
      _wallet = null;
      _transactions.clear();
      _isLoggedIn = false;

      // Clear saved login state
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('is_logged_in');
      await prefs.remove('user_phone');

      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }

  Future<bool> checkLoginStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isLoggedIn = prefs.getBool('is_logged_in') ?? false;

      if (isLoggedIn) {
        await _loadUserData();
        _isLoggedIn = true;
        notifyListeners();
        return true;
      }

      return false;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  // Data loading methods
  Future<void> _loadUserData() async {
    try {
      final userFuture = _apiService.getUserProfile();
      final walletFuture = _apiService.getWalletBalance();
      final transactionsFuture = _apiService.getTransactions(limit: 50);

      final results = await Future.wait([
        userFuture,
        walletFuture,
        transactionsFuture,
      ]);

      _currentUser = results[0] as UserModel;
      _wallet = results[1] as WalletModel;
      _transactions = results[2] as List<TransactionModel>;
    } catch (e) {
      _setError('Failed to load user data: ${e.toString()}');
    }
  }

  Future<void> refreshData() async {
    try {
      _setLoading(true);
      await _loadUserData();
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }

  Future<void> refreshWallet() async {
    try {
      _wallet = await _apiService.getWalletBalance();
      notifyListeners();
    } catch (e) {
      _setError('Failed to refresh wallet: ${e.toString()}');
    }
  }

  Future<void> refreshTransactions() async {
    try {
      _transactions = await _apiService.getTransactions(limit: 50);
      notifyListeners();
    } catch (e) {
      _setError('Failed to refresh transactions: ${e.toString()}');
    }
  }

  // Transaction methods
  Future<bool> sendMoney({
    required String recipientPhone,
    required double amount,
    String? description,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      if (amount <= 0) {
        _setError('Amount must be greater than zero');
        return false;
      }

      if (!(_wallet?.canAfford(amount) ?? false)) {
        _setError('Insufficient funds');
        return false;
      }

      final response = await _apiService.sendMoney(
        recipientPhone: recipientPhone,
        amount: amount,
        description: description,
      );

      if (response['success']) {
        await refreshWallet();
        await refreshTransactions();
        return true;
      }

      _setError(response['message'] ?? 'Failed to send money');
      return false;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> payBill({
    required String billType,
    required String accountNumber,
    required double amount,
    String? description,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      if (amount <= 0) {
        _setError('Amount must be greater than zero');
        return false;
      }

      if (!(_wallet?.canAfford(amount) ?? false)) {
        _setError('Insufficient funds');
        return false;
      }

      final response = await _apiService.payBill(
        billType: billType,
        accountNumber: accountNumber,
        amount: amount,
        description: description,
      );

      if (response['success']) {
        await refreshWallet();
        await refreshTransactions();
        return true;
      }

      _setError(response['message'] ?? 'Failed to pay bill');
      return false;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> withdraw({
    required double amount,
    required String withdrawalMethod,
    String? accountDetails,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      if (amount <= 0) {
        _setError('Amount must be greater than zero');
        return false;
      }

      if (!(_wallet?.canAfford(amount) ?? false)) {
        _setError('Insufficient funds');
        return false;
      }

      final response = await _apiService.withdraw(
        amount: amount,
        withdrawalMethod: withdrawalMethod,
        accountDetails: accountDetails,
      );

      if (response['success']) {
        await refreshWallet();
        await refreshTransactions();
        return true;
      }

      _setError(response['message'] ?? 'Failed to withdraw');
      return false;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> topUpWallet({
    required double amount,
    required String paymentMethod,
    Map<String, dynamic>? paymentDetails,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      if (amount <= 0) {
        _setError('Amount must be greater than zero');
        return false;
      }

      final response = await _apiService.topUpWallet(
        amount: amount,
        paymentMethod: paymentMethod,
        paymentDetails: paymentDetails,
      );

      if (response['success']) {
        await refreshWallet();
        await refreshTransactions();
        return true;
      }

      _setError(response['message'] ?? 'Failed to top up wallet');
      return false;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Profile management
  Future<bool> updateProfile(Map<String, dynamic> userData) async {
    try {
      _setLoading(true);
      _clearError();

      final updatedUser = await _apiService.updateUserProfile(userData);
      _currentUser = updatedUser;

      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Utility methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  void clearError() {
    _clearError();
  }

  // Analytics
  List<TransactionModel> getTransactionsByType(TransactionType type) {
    return _transactions.where((t) => t.type == type).toList();
  }

  List<TransactionModel> getRecentTransactions({int limit = 10}) {
    final sorted = List<TransactionModel>.from(_transactions)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return sorted.take(limit).toList();
  }

  double getTotalSpentThisMonth() {
    final now = DateTime.now();
    final thisMonth = DateTime(now.year, now.month, 1);

    return _transactions
        .where((t) =>
            t.createdAt.isAfter(thisMonth) &&
            (t.type == TransactionType.send ||
                t.type == TransactionType.payBill ||
                t.type == TransactionType.withdraw))
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double getTotalReceivedThisMonth() {
    final now = DateTime.now();
    final thisMonth = DateTime(now.year, now.month, 1);

    return _transactions
        .where((t) =>
            t.createdAt.isAfter(thisMonth) &&
            (t.type == TransactionType.receive ||
                t.type == TransactionType.topUp ||
                t.type == TransactionType.refund))
        .fold(0.0, (sum, t) => sum + t.amount);
  }
}
