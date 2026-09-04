import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // ============================================================
  // BACKEND URL
  // ============================================================

  static const String baseUrl =
      "http://localhost:8080";

  // ============================================================
  // TOKEN
  // ============================================================

  static const String _tokenKey =
      "auth_token";

  // ============================================================
  // GET TOKEN
  // ============================================================

  static Future<String?> getToken() async {
    final prefs =
        await SharedPreferences.getInstance();

    return prefs.getString(
      _tokenKey,
    );
  }

  // ============================================================
  // SAVE TOKEN
  // ============================================================

  static Future<void> saveToken(
    String token,
  ) async {
    final prefs =
        await SharedPreferences.getInstance();

    await prefs.setString(
      _tokenKey,
      token,
    );
  }

  // ============================================================
  // CLEAR TOKEN
  // ============================================================

  static Future<void> clearToken() async {
    final prefs =
        await SharedPreferences.getInstance();

    await prefs.remove(
      _tokenKey,
    );
  }

  // ============================================================
  // SIGN UP
  // ============================================================

  static Future<Map<String, dynamic>> signup({
    required String name,
    required String email,
    required String password,
  }) async {

    final response =
        await http.post(
      Uri.parse(
        "$baseUrl/api/auth/signup",
      ),
      headers: {
        "Content-Type":
            "application/json",
      },
      body: jsonEncode({
        "name":
            name.trim(),
        "email":
            email.trim(),
        "password":
            password,
      }),
    );

    final data =
        _decodeResponse(
      response,
    );

    if (!_isSuccess(
      response.statusCode,
    )) {

      throw Exception(
        data["message"] ??
            data["error"] ??
            "Sign up failed.",
      );
    }

    final token =
        data["token"];

    if (token == null ||
        token.toString().isEmpty) {

      throw Exception(
        "Sign up succeeded but no authentication token was returned.",
      );
    }

    await saveToken(
      token.toString(),
    );

    return data;
  }

  // ============================================================
  // SIGN IN
  // ============================================================

  static Future<Map<String, dynamic>> signin({
    required String email,
    required String password,
  }) async {

    final response =
        await http.post(
      Uri.parse(
        "$baseUrl/api/auth/signin",
      ),
      headers: {
        "Content-Type":
            "application/json",
      },
      body: jsonEncode({
        "email":
            email.trim(),
        "password":
            password,
      }),
    );

    final data =
        _decodeResponse(
      response,
    );

    if (!_isSuccess(
      response.statusCode,
    )) {

      throw Exception(
        data["message"] ??
            data["error"] ??
            "Sign in failed.",
      );
    }

    final token =
        data["token"];

    if (token == null ||
        token.toString().isEmpty) {

      throw Exception(
        "Sign in succeeded but no authentication token was returned.",
      );
    }

    await saveToken(
      token.toString(),
    );

    return data;
  }

  // ============================================================
  // ANALYZE IMAGE
  // ============================================================

  static Future<Map<String, dynamic>> analyzeImage(
    Uint8List imageBytes,
  ) async {

    final token =
        await getToken();

    if (token == null ||
        token.isEmpty) {

      throw Exception(
        "session has expired",
      );
    }

    final response =
        await http.post(
      Uri.parse(
        "$baseUrl/api/image/analyze",
      ),
      headers: {
        "Content-Type":
            "application/octet-stream",
        "Authorization":
            "Bearer $token",
      },
      body:
          imageBytes,
    );

    if (response.statusCode == 401 ||
        response.statusCode == 403) {

      await clearToken();

      throw Exception(
        "session has expired",
      );
    }

    final data =
        _decodeResponse(
      response,
    );

    if (!_isSuccess(
      response.statusCode,
    )) {

      throw Exception(
        data["message"] ??
            data["error"] ??
            "Image analysis failed.",
      );
    }

    return data;
  }

  // ============================================================
  // SAVE RECEIPT
  // ============================================================

  static Future<Map<String, dynamic>> saveReceipt({
    required String merchant,
    required String totalCost,
    required String currency,
    String? paymentTime,
    String? notes,
    String? source,
    Map<String, dynamic>? qwenResult,
    double? generationConfidence,
  }) async {

    final token =
        await getToken();

    if (token == null ||
        token.isEmpty) {

      throw Exception(
        "session has expired",
      );
    }

    final response =
        await http.post(
      Uri.parse(
        "$baseUrl/api/receipt/save",
      ),
      headers: {
        "Content-Type":
            "application/json",

        "Authorization":
            "Bearer $token",
      },
      body: jsonEncode({
        "merchant":
            merchant,

        "amount":
            totalCost,

        "currency":
            currency,

        "payment_time":
            paymentTime,

        "notes":
            notes,

        "source":
            source,

        "qwen_result":
            qwenResult,

        "generation_confidence":
            generationConfidence,
      }),
    );

    if (response.statusCode == 401 ||
        response.statusCode == 403) {

      await clearToken();

      throw Exception(
        "session has expired",
      );
    }

    final data =
        _decodeResponse(
      response,
    );

    if (!_isSuccess(
      response.statusCode,
    )) {

      throw Exception(
        data["message"] ??
            data["error"] ??
            "Could not save receipt.",
      );
    }

    return data;
  }

  // ============================================================
  // RECENT RECEIPTS
  // ============================================================

  static Future<List<Map<String, dynamic>>>
      getRecentReceipts() async {

    final token =
        await getToken();

    if (token == null ||
        token.isEmpty) {

      throw Exception(
        "session has expired",
      );
    }

    final response =
        await http.get(
      Uri.parse(
        "$baseUrl/api/analysis/recent",
      ),
      headers: {
        "Authorization":
            "Bearer $token",
      },
    );

    if (response.statusCode == 401 ||
        response.statusCode == 403) {

      await clearToken();

      throw Exception(
        "session has expired",
      );
    }

    if (!_isSuccess(
      response.statusCode,
    )) {

      final data =
          _decodeResponse(
        response,
      );

      throw Exception(
        data["message"] ??
            data["error"] ??
            "Could not load recent receipts.",
      );
    }

    return _decodeList(
      response.body,
      "Invalid recent receipts response.",
    );
  }

  // ============================================================
  // FULL HISTORY
  // ============================================================

  static Future<List<Map<String, dynamic>>>
      getReceiptHistory({
    required String period,
    required String currency,
  }) async {

    final token =
        await getToken();

    if (token == null ||
        token.isEmpty) {

      throw Exception(
        "session has expired",
      );
    }

    final uri =
        Uri.parse(
          "$baseUrl/api/analysis/history",
        ).replace(
      queryParameters: {
        "period":
            period,

        "currency":
            currency,
      },
    );

    final response =
        await http.get(
      uri,
      headers: {
        "Authorization":
            "Bearer $token",
      },
    );

    if (response.statusCode == 401 ||
        response.statusCode == 403) {

      await clearToken();

      throw Exception(
        "session has expired",
      );
    }

    if (!_isSuccess(
      response.statusCode,
    )) {

      final data =
          _decodeResponse(
        response,
      );

      throw Exception(
        data["message"] ??
            data["error"] ??
            "Could not load receipt history.",
      );
    }

    return _decodeList(
      response.body,
      "Invalid receipt history response.",
    );
  }

  // ============================================================
  // SPENDING ANALYSIS
  // ============================================================

  static Future<Map<String, dynamic>>
      getSpendingAnalysis({
    required String period,
    required String currency,
  }) async {

    final token =
        await getToken();

    if (token == null ||
        token.isEmpty) {

      throw Exception(
        "session has expired",
      );
    }

    final uri =
        Uri.parse(
          "$baseUrl/api/analysis/spending",
        ).replace(
      queryParameters: {
        "period":
            period,

        "currency":
            currency,
      },
    );

    final response =
        await http.get(
      uri,
      headers: {
        "Authorization":
            "Bearer $token",
      },
    );

    if (response.statusCode == 401 ||
        response.statusCode == 403) {

      await clearToken();

      throw Exception(
        "session has expired",
      );
    }

    final data =
        _decodeResponse(
      response,
    );

    if (!_isSuccess(
      response.statusCode,
    )) {

      throw Exception(
        data["message"] ??
            data["error"] ??
            "Could not load spending analysis.",
      );
    }

    return data;
  }

  // ============================================================
  // MERCHANT SUMMARY
  // ============================================================

  static Future<List<Map<String, dynamic>>>
      getMerchantSummary({
    required String period,
    required String currency,
  }) async {

    final token =
        await getToken();

    if (token == null ||
        token.isEmpty) {

      throw Exception(
        "session has expired",
      );
    }

    final uri =
        Uri.parse(
          "$baseUrl/api/analysis/merchants",
        ).replace(
      queryParameters: {
        "period":
            period,

        "currency":
            currency,
      },
    );

    final response =
        await http.get(
      uri,
      headers: {
        "Authorization":
            "Bearer $token",
      },
    );

    if (response.statusCode == 401 ||
        response.statusCode == 403) {

      await clearToken();

      throw Exception(
        "session has expired",
      );
    }

    if (!_isSuccess(
      response.statusCode,
    )) {

      final data =
          _decodeResponse(
        response,
      );

      throw Exception(
        data["message"] ??
            data["error"] ??
            "Could not load merchant analysis.",
      );
    }

    return _decodeList(
      response.body,
      "Invalid merchant analysis response.",
    );
  }

  // ============================================================
  // MERCHANT HISTORY
  // ============================================================

  static Future<Map<String, dynamic>>
      getMerchantHistory({
    required int receiverId,
    String period = "all",
    required String currency,
  }) async {

    final token =
        await getToken();

    if (token == null ||
        token.isEmpty) {

      throw Exception(
        "session has expired",
      );
    }

    final uri =
        Uri.parse(
          "$baseUrl/api/analysis/merchants/$receiverId",
        ).replace(
      queryParameters: {
        "period":
            period,

        "currency":
            currency,
      },
    );

    final response =
        await http.get(
      uri,
      headers: {
        "Authorization":
            "Bearer $token",
      },
    );

    if (response.statusCode == 401 ||
        response.statusCode == 403) {

      await clearToken();

      throw Exception(
        "session has expired",
      );
    }

    final data =
        _decodeResponse(
      response,
    );

    if (!_isSuccess(
      response.statusCode,
    )) {

      throw Exception(
        data["message"] ??
            data["error"] ??
            "Could not load merchant history.",
      );
    }

    return data;
  }

  // ============================================================
  // ACCOUNT - GET
  // ============================================================

  static Future<Map<String, dynamic>>
      getAccount() async {

    final token =
        await getToken();

    if (token == null ||
        token.isEmpty) {

      throw Exception(
        "session has expired",
      );
    }

    final response =
        await http.get(
      Uri.parse(
        "$baseUrl/api/account",
      ),
      headers: {
        "Authorization":
            "Bearer $token",
      },
    );

    if (response.statusCode == 401 ||
        response.statusCode == 403) {

      await clearToken();

      throw Exception(
        "session has expired",
      );
    }

    final data =
        _decodeResponse(
      response,
    );

    if (!_isSuccess(
      response.statusCode,
    )) {

      throw Exception(
        data["message"] ??
            data["error"] ??
            "Could not load account information.",
      );
    }

    return data;
  }

  // ============================================================
  // ACCOUNT - UPDATE PROFILE
  // ============================================================

  static Future<Map<String, dynamic>>
      updateProfile({
    required String name,
    required String email,
  }) async {

    final token =
        await getToken();

    if (token == null ||
        token.isEmpty) {

      throw Exception(
        "session has expired",
      );
    }

    final response =
        await http.put(
      Uri.parse(
        "$baseUrl/api/account/profile",
      ),
      headers: {
        "Content-Type":
            "application/json",

        "Authorization":
            "Bearer $token",
      },
      body: jsonEncode({
        "name":
            name.trim(),

        "email":
            email.trim(),
      }),
    );

    if (response.statusCode == 401 ||
        response.statusCode == 403) {

      await clearToken();

      throw Exception(
        "session has expired",
      );
    }

    final data =
        _decodeResponse(
      response,
    );

    if (!_isSuccess(
      response.statusCode,
    )) {

      throw Exception(
        data["message"] ??
            data["error"] ??
            "Could not update profile.",
      );
    }

    return data;
  }

  // ============================================================
  // ACCOUNT - CHANGE PASSWORD
  // ============================================================

  static Future<Map<String, dynamic>>
      changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {

    final token =
        await getToken();

    if (token == null ||
        token.isEmpty) {

      throw Exception(
        "session has expired",
      );
    }

    final response =
        await http.put(
      Uri.parse(
        "$baseUrl/api/account/password",
      ),
      headers: {
        "Content-Type":
            "application/json",

        "Authorization":
            "Bearer $token",
      },
      body: jsonEncode({
        "current_password":
            currentPassword,

        "new_password":
            newPassword,
      }),
    );

    if (response.statusCode == 401 ||
        response.statusCode == 403) {

      await clearToken();

      throw Exception(
        "session has expired",
      );
    }

    final data =
        _decodeResponse(
      response,
    );

    if (!_isSuccess(
      response.statusCode,
    )) {

      throw Exception(
        data["message"] ??
            data["error"] ??
            "Could not change password.",
      );
    }

    return data;
  }

  // ============================================================
  // LOGOUT
  // ============================================================

  static Future<void> logout() async {
    await clearToken();
  }

  // ============================================================
  // AUTH STATUS
  // ============================================================

  static Future<bool> isLoggedIn() async {

    final token =
        await getToken();

    return token != null &&
        token.isNotEmpty;
  }

  // ============================================================
  // RESPONSE HELPERS
  // ============================================================

  static bool _isSuccess(
    int statusCode,
  ) {
    return statusCode >= 200 &&
        statusCode < 300;
  }

  static Map<String, dynamic>
      _decodeResponse(
    http.Response response,
  ) {

    if (response.body.isEmpty) {
      return {};
    }

    try {

      final decoded =
          jsonDecode(
        response.body,
      );

      if (decoded
          is Map<String, dynamic>) {

        return decoded;
      }

      return {
        "message":
            decoded.toString(),
      };

    } catch (_) {

      return {
        "message":
            response.body,
      };
    }
  }

  static List<Map<String, dynamic>>
      _decodeList(
    String body,
    String errorMessage,
  ) {

    if (body.isEmpty) {
      return [];
    }

    try {

      final decoded =
          jsonDecode(
        body,
      );

      if (decoded is! List) {
        return [];
      }

      return decoded
          .map(
            (item) =>
                Map<String, dynamic>.from(
              item as Map,
            ),
          )
          .toList();

    } catch (_) {

      throw Exception(
        errorMessage,
      );
    }
  }
}