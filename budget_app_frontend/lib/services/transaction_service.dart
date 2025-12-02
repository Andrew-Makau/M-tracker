import 'dart:ui';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TransactionService {
  // Choose base URL depending on platform (web vs emulator/device)
  static String get _baseUrl {
    if (kIsWeb) {
      return 'http://127.0.0.1:5000';
    } else {
      // Android emulator mapping to host localhost
      return 'http://10.0.2.2:5000';
    }
  }

  final Dio _dio = Dio(BaseOptions(
    baseUrl: _baseUrl,
    // Increase timeouts to tolerate slower local backend responses during
    // development. Adjust as needed for your server/network.
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 15),
    headers: {"Content-Type": "application/json"},
  ));

  /// Fetch all transactions for the current logged-in user
  Future<List<Map<String, dynamic>>> fetchTransactions() async {
    try {
      final storage = const FlutterSecureStorage();
      final token = await storage.read(key: 'jwt_token');

      if (token == null || token.isEmpty) {
        throw Exception("User not logged in — missing token");
      }

      // Try the request with a small retry loop for transient timeouts.
      const int maxAttempts = 3;
      int attempt = 0;
      Response response;
      while (true) {
        attempt++;
        try {
          response = await _dio.get(
            '/transactions',
            options: Options(headers: {'Authorization': 'Bearer $token'}),
          );
          break; // success
        } on DioException catch (e) {
          // If it's a timeout and we have attempts left, wait and retry.
          final isTimeout = e.type == DioExceptionType.connectionTimeout ||
              e.type == DioExceptionType.sendTimeout ||
              e.type == DioExceptionType.receiveTimeout;
          if (isTimeout && attempt < maxAttempts) {
            // exponential backoff (100ms, 300ms, ...)
            final backoffMs = 100 * (1 << (attempt - 1));
            await Future.delayed(Duration(milliseconds: backoffMs));
            continue;
          }
          // rethrow to be handled by outer catch
          rethrow;
        }
      }

      if (response.statusCode == 200) {
        // Convert backend response to List<Map<String, dynamic>>
        final resp = response.data;

        // Normalize possible response shapes:
        // - A List of transaction objects
        // - A Map with a top-level key like 'transactions' or 'data' containing the list
        // - A single transaction Map (wrap into list)
        List items = [];

        if (resp is List) {
          items = resp;
        } else if (resp is Map) {
          // Common keys used by APIs
          if (resp['transactions'] is List) {
            items = resp['transactions'];
          } else if (resp['data'] is List) {
            items = resp['data'];
          } else if (resp.isNotEmpty) {
            // If it's a single object, wrap it so callers still get a list
            items = [resp];
          }
        } else {
          // Unknown shape - throw a descriptive error
          throw Exception('Unexpected response shape: ${resp.runtimeType}');
        }

        return items.map<Map<String, dynamic>>((t) {
          final Map txn = t is Map ? t : {};
          return {
            'id': txn['id'],
            'title': txn['note'] ?? txn['title'] ?? 'No title',
            'category': txn['category'] ?? 'General',
            'amount': (txn['amount'] is num) ? (txn['amount'] as num).toDouble() : 0.0,
            'type': txn['type'],
            'date': txn['date'] != null ? DateTime.tryParse(txn['date'].toString()) : null,
            'categoryColor': (txn['type'] == 'income') ? const Color(0xFF4CAF50) : const Color(0xFFE57373),
          };
        }).toList();
      } else {
        throw Exception('Failed to load transactions: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      // attempt to extract a friendly message from the response body
      final respData = e.response?.data;
      if (respData is Map && respData.isNotEmpty) {
        throw Exception(respData['error'] ?? respData['message'] ?? 'Network or server error');
      }
      throw Exception(e.message ?? 'Network or server error');
    }
  }

  /// Fetch aggregated summary (spent/income) for the current user.
  /// Optional `start` and `end` DateTime can be provided to limit the range.
  Future<Map<String, double>> fetchSummary({DateTime? start, DateTime? end}) async {
    try {
      final storage = const FlutterSecureStorage();
      final token = await storage.read(key: 'jwt_token');

      if (token == null || token.isEmpty) throw Exception('User not logged in — missing token');

      final Map<String, dynamic> query = {};
      if (start != null) {
        query['start_date'] = '${start.year.toString().padLeft(4, '0')}-${start.month.toString().padLeft(2, '0')}-${start.day.toString().padLeft(2, '0')}';
      }
      if (end != null) {
        query['end_date'] = '${end.year.toString().padLeft(4, '0')}-${end.month.toString().padLeft(2, '0')}-${end.day.toString().padLeft(2, '0')}';
      }

      final response = await _dio.get(
        '/transactions/summary',
        queryParameters: query,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        return {
          'spent': (data['spent'] is num) ? (data['spent'] as num).toDouble() : 0.0,
          'income': (data['income'] is num) ? (data['income'] as num).toDouble() : 0.0,
        };
      }

      throw Exception('Failed to fetch summary: ${response.statusMessage}');
    } on DioException catch (e) {
      final respData = e.response?.data;
      if (respData is Map && respData.isNotEmpty) {
        throw Exception(respData['error'] ?? respData['message'] ?? 'Network or server error');
      }
      throw Exception(e.message ?? 'Network or server error');
    }
  }

  /// Create a new transaction for the current logged-in user
  /// Required fields (backend contract):
  /// - amount: number
  /// - type: 'income' | 'expense'
  /// - category_id: integer
  /// - date: 'YYYY-MM-DD'
  /// - note: string (optional)
  Future<void> createTransaction({
    required double amount,
    required int categoryId,
    required DateTime date,
    String type = 'expense',
    String note = '',
  }) async {
    try {
      final storage = const FlutterSecureStorage();
      final token = await storage.read(key: 'jwt_token');
      if (token == null || token.isEmpty) {
        throw Exception('User not logged in — missing token');
      }

      final String ymd =
          '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

      final body = {
        'amount': amount,
        'type': type,
        'category_id': categoryId,
        'date': ymd,
        'note': note,
      };

      final response = await _dio.post(
        '/transactions',
        data: body,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode != 201) {
        throw Exception('Failed to create transaction: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      final respData = e.response?.data;
      if (respData is Map && respData.isNotEmpty) {
        throw Exception(respData['error'] ?? respData['message'] ?? 'Network or server error');
      }
      throw Exception(e.message ?? 'Network or server error');
    }
  }
}
