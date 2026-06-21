import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/appointment.dart';
import '../models/user.dart';
import '../services/appointment_service.dart';

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({Key? key}) : super(key: key);

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> {
  late Future<List<Appointment>> futureAppointments;
  User? currentUser;
  bool isLoading = true;
  String? cancellingId;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    try {
      final user = await _getCurrentUser();
      setState(() => currentUser = user);

      if (user != null) {
        futureAppointments = _getAppointments(user);
      } else {
        futureAppointments = Future.value([]);
      }
    } catch (e) {
      debugPrint('Error initializing data: $e');
      futureAppointments = Future.value([]);
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<User?> _getCurrentUser() async {
    try {
      const storage = FlutterSecureStorage();
      final raw = await storage.read(key: 'user');
      if (raw == null || raw.isEmpty) return null;
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return User.fromJson(map);
    } catch (e) {
      debugPrint('Error getting current user: $e');
      return null;
    }
  }

  Future<List<Appointment>> _getAppointments(User user) async {
    final service = AppointmentService();
    if (user.role?.name == 'patient') {
      return service.getByPatientId(user.id ?? '');
    } else if (user.role?.name == 'doctor') {
      return service.getByDoctorId(user.id ?? '');
    } else {
      return service.getAll();
    }
  }

  Future<void> _cancelAppointment(String id) async {
    final confirmed = await _showConfirmDialog(
      'Cancel Appointment',
      'Are you sure you want to cancel this appointment?',
    );

    if (!confirmed) return;

    setState(() => cancellingId = id);

    try {
      await AppointmentService().delete(id);
      if (!mounted) return;
      _initializeData();
      _showSnackBar('Appointment cancelled successfully', isSuccess: true);
    } catch (e) {
      if (!mounted) return;
      _showSnackBar('Failed to cancel appointment: $e', isError: true);
    } finally {
      if (mounted) {
        setState(() => cancellingId = null);
      }
    }
  }

  Future<bool> _showConfirmDialog(String title, String message) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirm', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    ) ??
        false;
  }

  void _showSnackBar(String message,
      {bool isError = false, bool isSuccess = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isSuccess
            ? Colors.green
            : (isError ? Colors.red : Colors.blue),
        duration: const Duration(seconds: 3),
      ), 
     );
   }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    final dateOnly = DateTime(date.year, date.month, date.day);
    
    if (dateOnly == today) {
      return 'Today';
    } else if (dateOnly == tomorrow) {
      return 'Tomorrow';
    } else {
      return DateFormat('MMM d').format(date);
    }
  }

  String _formatTime(DateTime date) {
    return DateFormat('HH:mm').format(date);
  }

  String _getStatusLabel(int? status) {
    switch (status) {
      case 0:
        return 'Pending';
      case 1:
        return 'Confirmed';
      case 2:
        return 'Completed';
      case 3:
        return 'Cancelled';
      default:
        return 'Pending';
    }
  }

  Color _getStatusColor(int? status) {
    switch (status) {
      case 0:
        return const Color(0xFFFEF3C7); 
      case 1:
        return const Color(0xFFDEEAF6); 
      case 2:
        return const Color(0xFFDCFCE7); 
      case 3:
        return const Color(0xFFFEE2E2); 
      default:
        return const Color(0xFFFEF3C7);
    }
  }

  Color _getStatusBorderColor(int? status) {
    switch (status) {
      case 0:
        return const Color(0xFFFCD34D); 
      case 1:
        return const Color(0xFF60A5FA); 
      case 2:
        return const Color(0xFF4ADE80); 
      case 3:
        return const Color(0xFFF87171); 
      default:
        return const Color(0xFFFCD34D);
    }
  }

  Color _getStatusTextColor(int? status) {
    switch (status) {
      case 0:
        return const Color(0xFFB45309); 
      case 1:
        return const Color(0xFF1E40AF); 
      case 2:
        return const Color(0xFF166534);
      case 3:
        return const Color(0xDC2626); 
      default:
        return const Color(0xFFB45309);
    }
  }

  IconData _getStatusIcon(int? status) {
    switch (status) {
      case 0:
        return Icons.warning_rounded;
      case 1:
        return Icons.check_circle_rounded;
      case 2:
        return Icons.check_circle_rounded;
      case 3:
        return Icons.cancel_rounded;
      default:
        return Icons.warning_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
  final isMobile = MediaQuery.of(context).size.width < 600;

  final theme = Theme.of(context);
  final cs = theme.colorScheme;
  final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
     title: const Text('Appointments'),
     elevation: 0,
     backgroundColor: cs.surface,
     foregroundColor: cs.onSurface,
  ),
      body: Container(
        decoration: BoxDecoration(
        gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: isDark
        ? [
            const Color(0xFF0F172A),
            const Color(0xFF1E293B),
          ]
        : [
            const Color(0xFFF0F9FF),
            const Color(0xFFE0E7FF),
          ],
  ),
),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                            Text(
                              'Appointments',
                              style: TextStyle(
                              fontSize: 19,
                             fontWeight: FontWeight.bold,
                         ),
                       ),
                                SizedBox(height: 8),
                                Text(
                                  'Manage your medical appointments',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (currentUser?.role?.name != 'doctor')
                            ElevatedButton.icon(
                              onPressed: () {
                                Navigator.pushNamed(context, '/doctors');
                              },
                              icon: const Icon(Icons.calendar_today),
                              label: const Text('Book Appointment'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: cs.primary,
                                foregroundColor: cs.onPrimary,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      FutureBuilder<List<Appointment>>(
                        future: futureAppointments,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          }

                          if (snapshot.hasError) {
                            return Center(
                              child: Text('Error: ${snapshot.error}'),
                            );
                          }

                          final appointments = snapshot.data ?? [];

                          if (appointments.isEmpty) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 96,
                                    height: 96,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.blue.shade100,
                                    ),
                                    child: Icon(
                                      Icons.calendar_today,
                                      size: 48,
                                      color: cs.primary,
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  const Text(
                                    'No appointments yet',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    "You don't have any scheduled appointments.",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  if (currentUser?.role?.name != 'doctor')
                                    ElevatedButton.icon(
                                      onPressed: () {
                                        Navigator.pushNamed(
                                            context, '/doctors');
                                      },
                                      icon: const Icon(Icons.calendar_today),
                                      label: const Text('Find a Doctor'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: cs.primary,
                                        foregroundColor: cs.onPrimary,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 24,
                                          vertical: 12,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            );
                          }

                          return ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: appointments.length,
                            itemBuilder: (context, index) {
                              final appointment = appointments[index];
                              final isPast =
                                  appointment.appointmentDate.isBefore(DateTime.now());
                              final statusLabel =
                                  _getStatusLabel(appointment.status);
                              final statusColor = _getStatusColor(appointment.status);
                              final statusBorderColor = _getStatusBorderColor(
                                appointment.status,
                              );
                              final statusTextColor =
                                  _getStatusTextColor(appointment.status);
                              final statusIcon =
                                  _getStatusIcon(appointment.status);

                              return Card(
                                margin: const EdgeInsets.only(bottom: 16),
                                elevation: 1,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: BorderSide(
                                    color: statusBorderColor,
                                    width: 4,
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: statusColor,
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              statusIcon,
                                              size: 16,
                                              color: statusTextColor,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              statusLabel,
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                                color: statusTextColor,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 12),

                                      Text(
                                        appointment.reason ?? 'Medical Appointment',
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 12),

                                      Wrap(
                                        spacing: 24,
                                        runSpacing: 8,
                                        children: [
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.calendar_today,
                                                size: 16,
                                                color: cs.primary,
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                _formatDate(
                                                    appointment.appointmentDate),
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              if (isPast)
                                                Container(
                                                  margin: const EdgeInsets.only(
                                                      left: 8),
                                                  padding: const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 2,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: Colors.red.shade100,
                                                    borderRadius:
                                                        BorderRadius.circular(4),
                                                  ),
                                                  child: Text(
                                                    'Past',
                                                    style: TextStyle(
                                                      fontSize: 11,
                                                      color: Colors.red.shade700,
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          ),
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.access_time,
                                                size: 16,
                                                color: cs.primary,
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                _formatTime(
                                                    appointment.appointmentDate),
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              if (appointment.duration != null)
                                                Text(
                                                  ' • ${appointment.duration} min',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: cs.onSurface,
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.person,
                                            size: 16,
                                            color: Colors.grey.shade500,
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Doctor:',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: cs.onSurfaceVariant,
                                                  ),
                                                ),
                                                Text(
                                                  appointment.doctor?.name ??
                                                      'Dr. ${appointment.doctorId.substring(0, 8)}',
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.blue,
                                                  ),
                                                ),
                                                if (appointment.doctor?.specialty !=
                                                    null)
                                                  Text(
                                                    '(${appointment.doctor!.specialty})',
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: cs.tertiary,
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),

                                      if (currentUser?.role?.name == 'doctor')
                                        Padding(
                                          padding: const EdgeInsets.only(top: 12),
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.person,
                                                size: 16,
                                                color: Colors.grey.shade500,
                                              ),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      'Patient:',
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        color: cs.onSurfaceVariant,
                                                      ),
                                                    ),
                                                    Text(
                                                      appointment.patient?.name ??
                                                          appointment.patientId
                                                              .substring(0, 8),
                                                      style: const TextStyle(
                                                        fontWeight: FontWeight.w600,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      if (appointment.notes != null &&
                                          appointment.notes!.isNotEmpty)
                                        Padding(
                                          padding: const EdgeInsets.only(top: 12),
                                          child: Container(
                                            padding: const EdgeInsets.all(12),
                                            decoration: BoxDecoration(
                                              color: isDark
                                                   ? cs.primaryContainer.withOpacity(.3)
                                                   : cs.primaryContainer,
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Icon(
                                                  Icons.description,
                                                  size: 16,
                                                  color: Colors.blue.shade600,
                                                ),
                                                const SizedBox(width: 8),
                                                Expanded(
                                                  child: Text(
                                                    appointment.notes ?? '',
                                                    style: const TextStyle(
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),

                                      const SizedBox(height: 16),

                                      // Actions
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: ElevatedButton(
                                              onPressed: () {
                                                Navigator.pushNamed(
                                                  context,
                                                  '/appointments-details',
                                                  arguments: appointment.id,
                                                );
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: const Color.fromARGB(255, 6, 39, 68),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  vertical: 12,
                                                ),
                                              ),
                                              child: const Text('View Details'),
                                            ),
                                          ),
                                          if (currentUser?.role?.name == 'patient' &&
                                              appointment.status != 3 &&
                                              !isPast)
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 8.0),
                                              child: Expanded(
                                                child: OutlinedButton(
                                                  onPressed: cancellingId ==
                                                          appointment.id
                                                      ? null
                                                      : () => _cancelAppointment(
                                                            appointment.id,
                                                          ),
                                                  style: OutlinedButton.styleFrom(
                                                    side: BorderSide(
                                                      color: Colors.red.shade400,
                                                    ),
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                      vertical: 12,
                                                    ),
                                                  ),
                                                  child: cancellingId ==
                                                          appointment.id
                                                      ? SizedBox(
                                                          height: 20,
                                                          width: 20,
                                                          child:
                                                              CircularProgressIndicator(
                                                            strokeWidth: 2,
                                                            valueColor:
                                                                AlwaysStoppedAnimation(
                                                              Colors.red.shade400,
                                                            ),
                                                          ),
                                                        )
                                                      : Text(
                                                          'Cancel',
                                                          style: TextStyle(
                                                            color: Colors.red
                                                                .shade400,
                                                          ),
                                                        ),
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
