import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/appointment.dart';
import './api.dart';
import './auth.dart';

class AppointmentService {
  static final AppointmentService _instance = AppointmentService._internal();

  factory AppointmentService() {
    return _instance;
  }

  AppointmentService._internal();

  Future<List<Appointment>> getAll() async {
    try {
      final authHeaders = await getAuthHeaders();
      final headers = {
        'Content-Type': 'application/json',
        ...authHeaders,
      };

      final response = await http.get(
        Uri.parse('${Api.baseUrl}/api/appointments'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Appointment.fromJson(json as Map<String, dynamic>)).toList();
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized - please login again');
      } else {
        throw Exception('Failed to load appointments');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Appointment>> getByPatientId(String patientId) async {
    try {
      final authHeaders = await getAuthHeaders();
      final headers = {
        'Content-Type': 'application/json',
        ...authHeaders,
      };

      final response = await http.get(
        Uri.parse('${Api.baseUrl}/api/appointments/patient/$patientId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Appointment.fromJson(json as Map<String, dynamic>)).toList();
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized - please login again');
      } else {
        throw Exception('Failed to load appointments');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Appointment>> getByDoctorId(String doctorId) async {
    try {
      final authHeaders = await getAuthHeaders();
      final headers = {
        'Content-Type': 'application/json',
        ...authHeaders,
      };

      final response = await http.get(
        Uri.parse('${Api.baseUrl}/api/appointments/doctor/$doctorId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Appointment.fromJson(json as Map<String, dynamic>)).toList();
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized - please login again');
      } else {
        throw Exception('Failed to load appointments');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<Appointment?> getById(String id) async {
    try {
      final authHeaders = await getAuthHeaders();
      final headers = {
        'Content-Type': 'application/json',
        ...authHeaders,
      };

      final response = await http.get(
        Uri.parse('${Api.baseUrl}/api/appointments/$id'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return Appointment.fromJson(jsonDecode(response.body));
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw Exception('Failed to load appointment');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> delete(String id) async {
    try {
      final authHeaders = await getAuthHeaders();
      final headers = {
        'Content-Type': 'application/json',
        ...authHeaders,
      };

      final response = await http.delete(
        Uri.parse('${Api.baseUrl}/api/appointments/$id'),
        headers: headers,
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to cancel appointment');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<Appointment> create({
    required String patientId,
    required String doctorId,
    required DateTime appointmentDate,
    String? reason,
    String? notes,
    int? duration,
  }) async {
    try {
      final authHeaders = await getAuthHeaders();
      final headers = {
        'Content-Type': 'application/json',
        ...authHeaders,
      };

      final body = {
        'patientId': patientId,
        'doctorId': doctorId,
        'appointmentDate': appointmentDate.toIso8601String(),
        'reason': reason,
        'notes': notes,
        'duration': duration,
      };

      final response = await http.post(
        Uri.parse('${Api.baseUrl}/api/appointments'),
        headers: headers,
        body: jsonEncode(body),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return Appointment.fromJson(jsonDecode(response.body));
      } else if (response.statusCode == 400) {
        throw Exception(response.body);
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized - please login again');
      } else {
        throw Exception('Failed to book appointment');
      }
    } catch (e) {
      rethrow;
    }
  }
}
