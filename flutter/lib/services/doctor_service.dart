import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/doctor.dart';
import './api.dart';
import './auth.dart';

class DoctorService {
  static final DoctorService _instance = DoctorService._internal();

  factory DoctorService() {
    return _instance;
  }

  DoctorService._internal();

  Future<List<Doctor>> getAll() async {
    try {
      final authHeaders = await getAuthHeaders();
      final headers = {
        'Content-Type': 'application/json',
        ...authHeaders,
      };

      final response = await http.get(
        Uri.parse('${Api.baseUrl}/api/doctors'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Doctor.fromJson(json as Map<String, dynamic>)).toList();
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized - please login again');
      } else {
        throw Exception('Failed to load doctors');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<Doctor?> getById(String id) async {
    try {
      final authHeaders = await getAuthHeaders();
      final headers = {
        'Content-Type': 'application/json',
        ...authHeaders,
      };

      final response = await http.get(
        Uri.parse('${Api.baseUrl}/api/doctors/$id'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return Doctor.fromJson(jsonDecode(response.body));
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw Exception('Failed to load doctor');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getAverageRating(String doctorId) async {
    try {
      final authHeaders = await getAuthHeaders();
      final headers = {
        'Content-Type': 'application/json',
        ...authHeaders,
      };

      final response = await http.get(
        Uri.parse('${Api.baseUrl}/api/doctors/ratings/average/$doctorId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {'average': 0, 'count': 0};
      }
    } catch (e) {
      return {'average': 0, 'count': 0};
    }
  }
}
