import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/app_constants.dart';

class ApiService {
  static const String _base = AppConstants.baseUrl;

  // LOGIN
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse("$_base/mobile-login/"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": email,
          "password": password,
        }),
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {
        "success": false,
        "message": "Network error: $e",
      };
    }
  }

  // REGISTER
  static Future<Map<String, dynamic>> register({
    required String name,
    required String phone,
    required String email,
    required String password,
    required String vehicle,
  }) async {
    try {
      final response = await http.post(
        Uri.parse("$_base/mobile-register/"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "name": name,
          "phone": phone,
          "email": email,
          "password": password,
          "vehicle": vehicle,
        }),
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {
        "success": false,
        "message": "Network error: $e",
      };
    }
  }

  // PARKING LIST
  static Future<List> getParkings() async {
    try {
      final response = await http.get(
        Uri.parse("$_base/mobile-parkings/"),
      );

      final data = jsonDecode(response.body);

      return data["parkings"] ?? [];
    } catch (e) {
      return [];
    }
  }

   // CREATE BOOKING
  static Future<Map<String, dynamic>> createBooking({
    required Map<String, dynamic> bookingData,
  }) async {
    try {
      final response = await http.post(
        Uri.parse("$_base/mobile-create-booking/"),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode(bookingData),
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {
        "success": false,
        "message": e.toString(),
      };
    }
  }

  // GET USER RECORDS
  static Future<List> getUserRecords(
    String userId,
  ) async {
    try {
      final response = await http.get(
        Uri.parse(
          "$_base/mobile-user-records/?user_id=$userId",
        ),
      );

      final data = jsonDecode(response.body);

      return data["records"] ?? [];
    } catch (e) {
      return [];
    }
  }
    // GET ALL USERS
  static Future<List> getAllUsers() async {
    try {
      final response = await http.get(
        Uri.parse(
          "$_base/mobile-users/",
        ),
      );

      final data = jsonDecode(
        response.body,
      );

      return data["users"] ?? [];
    } catch (e) {
      return [];
    }
  }
  // GET ALL OWNERS
static Future<List> getOwners() async {
  try {
    final response = await http.get(
      Uri.parse(
        "$_base/mobile-owners/",
      ),
    );

    final data = jsonDecode(
      response.body,
    );

    return data["owners"] ?? [];
  } catch (e) {
    return [];
  }
}

// GET OWNER RECORDS
static Future<List> getOwnerRecords(
  String ownerId,
) async {
  try {
    final response = await http.get(
      Uri.parse(
        "$_base/mobile-owner-records/?owner_id=$ownerId",
      ),
    );

    final data = jsonDecode(
      response.body,
    );

    return data["records"] ?? [];
  } catch (e) {
    return [];
  }
}
}  