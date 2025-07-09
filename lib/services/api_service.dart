import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../models/transaction_model.dart';
import '../models/wallet_model.dart';

class ApiService {
  static const String baseUrl = 'https://your-mongodb-api-endpoint.com/api';
  // For local development, use: 'http://localhost:3000/api'

  final Dio _dio;

  ApiService() : _dio = Dio() {
    _dio.options.baseUrl = baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 30);

    // Add interceptors for authentication
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _getAuthToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) {
          if (error.response?.statusCode == 401) {
            // Token expired, redirect to login
            _clearAuthToken();
          }
          handler.next(error);
        },
      ),
    );
  }

  // Authentication methods
  Future<String?> _getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<void> _saveAuthToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  Future<void> _clearAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  // User authentication
  Future<Map<String, dynamic>> login(String phoneNumber, String pin) async {
    try {
      final response = await _dio.post('/auth/login', data: {
        'phoneNumber': phoneNumber,
        'pin': pin,
      });

      if (response.data['success']) {
        await _saveAuthToken(response.data['token']);
        return response.data;
      }
      throw Exception(response.data['message'] ?? 'Login failed');
    } catch (e) {
      throw Exception('Login failed: ${e.toString()}');
    }
  }

  Future<Map<String, dynamic>> register(Map<String, dynamic> userData) async {
    try {
      final response = await _dio.post('/auth/register', data: userData);

      if (response.data['success']) {
        await _saveAuthToken(response.data['token']);
        return response.data;
      }
      throw Exception(response.data['message'] ?? 'Registration failed');
    } catch (e) {
      throw Exception('Registration failed: ${e.toString()}');
    }
  }

  Future<void> logout() async {
    await _clearAuthToken();
    try {
      await _dio.post('/auth/logout');
    } catch (e) {
      // Continue with local logout even if server call fails
    }
  }

  // User profile methods
  Future<UserModel> getUserProfile() async {
    try {
      final response = await _dio.get('/user/profile');
      return UserModel.fromJson(response.data['user']);
    } catch (e) {
      throw Exception('Failed to get user profile: ${e.toString()}');
    }
  }

  Future<UserModel> updateUserProfile(Map<String, dynamic> userData) async {
    try {
      final response = await _dio.put('/user/profile', data: userData);
      return UserModel.fromJson(response.data['user']);
    } catch (e) {
      throw Exception('Failed to update profile: ${e.toString()}');
    }
  }

  // Wallet methods
  Future<WalletModel> getWalletBalance() async {
    try {
      final response = await _dio.get('/wallet/balance');
      return WalletModel.fromJson(response.data['wallet']);
    } catch (e) {
      throw Exception('Failed to get wallet balance: ${e.toString()}');
    }
  }

  Future<List<TransactionModel>> getTransactions({
    int page = 1,
    int limit = 20,
    String? type,
  }) async {
    try {
      final response = await _dio.get('/transactions', queryParameters: {
        'page': page,
        'limit': limit,
        if (type != null) 'type': type,
      });

      final List<dynamic> transactionsData = response.data['transactions'];
      return transactionsData
          .map((json) => TransactionModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to get transactions: ${e.toString()}');
    }
  }

  // Transaction methods
  Future<Map<String, dynamic>> sendMoney({
    required String recipientPhone,
    required double amount,
    String? description,
  }) async {
    try {
      final response = await _dio.post('/transactions/send', data: {
        'recipientPhone': recipientPhone,
        'amount': amount,
        'description': description,
      });
      return response.data;
    } catch (e) {
      throw Exception('Failed to send money: ${e.toString()}');
    }
  }

  Future<Map<String, dynamic>> payBill({
    required String billType,
    required String accountNumber,
    required double amount,
    String? description,
  }) async {
    try {
      final response = await _dio.post('/transactions/pay-bill', data: {
        'billType': billType,
        'accountNumber': accountNumber,
        'amount': amount,
        'description': description,
      });
      return response.data;
    } catch (e) {
      throw Exception('Failed to pay bill: ${e.toString()}');
    }
  }

  Future<Map<String, dynamic>> withdraw({
    required double amount,
    required String withdrawalMethod,
    String? accountDetails,
  }) async {
    try {
      final response = await _dio.post('/transactions/withdraw', data: {
        'amount': amount,
        'withdrawalMethod': withdrawalMethod,
        'accountDetails': accountDetails,
      });
      return response.data;
    } catch (e) {
      throw Exception('Failed to withdraw: ${e.toString()}');
    }
  }

  Future<Map<String, dynamic>> topUpWallet({
    required double amount,
    required String paymentMethod,
    Map<String, dynamic>? paymentDetails,
  }) async {
    try {
      final response = await _dio.post('/transactions/top-up', data: {
        'amount': amount,
        'paymentMethod': paymentMethod,
        'paymentDetails': paymentDetails,
      });
      return response.data;
    } catch (e) {
      throw Exception('Failed to top up wallet: ${e.toString()}');
    }
  }

  // Utility methods
  Future<List<Map<String, dynamic>>> getBillProviders() async {
    try {
      final response = await _dio.get('/utility/bill-providers');
      return List<Map<String, dynamic>>.from(response.data['providers']);
    } catch (e) {
      throw Exception('Failed to get bill providers: ${e.toString()}');
    }
  }

  Future<Map<String, dynamic>> validateAccount({
    required String accountNumber,
    required String bankCode,
  }) async {
    try {
      final response = await _dio.post('/utility/validate-account', data: {
        'accountNumber': accountNumber,
        'bankCode': bankCode,
      });
      return response.data;
    } catch (e) {
      throw Exception('Failed to validate account: ${e.toString()}');
    }
  }

  // Analytics methods
  Future<Map<String, dynamic>> getSpendingAnalytics({
    String period = 'month',
  }) async {
    try {
      final response = await _dio.get('/analytics/spending', queryParameters: {
        'period': period,
      });
      return response.data;
    } catch (e) {
      throw Exception('Failed to get analytics: ${e.toString()}');
    }
  }
}
