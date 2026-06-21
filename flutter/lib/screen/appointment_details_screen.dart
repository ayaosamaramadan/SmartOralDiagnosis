import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/appointment.dart';
import '../services/appointment_service.dart';

class AppointmentDetailsScreen extends StatefulWidget {
  final String appointmentId;

  const AppointmentDetailsScreen({
    Key? key,
    required this.appointmentId,
  }) : super(key: key);

  @override
  State<AppointmentDetailsScreen> createState() => _AppointmentDetailsScreenState();
}

class _AppointmentDetailsScreenState extends State<AppointmentDetailsScreen> {
  late Future<Appointment?> futureAppointment;

  @override
  void initState() {
    super.initState();
    futureAppointment = AppointmentService().getById(widget.appointmentId);
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Appointment Details'),
        elevation: 0,
      ),
      body: FutureBuilder<Appointment?>(
        future: futureAppointment,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 48,
                    color: Colors.red.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${snapshot.error}',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          final appointment = snapshot.data;

          if (appointment == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.search_off,
                    size: 48,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  const Text('Appointment not found'),
                ],
              ),
            );
          }

          final statusLabel = _getStatusLabel(appointment.status);
          final statusColor = _getStatusColor(appointment.status);
          final statusTextColor = _getStatusTextColor(appointment.status);
          final statusIcon = _getStatusIcon(appointment.status);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        statusIcon,
                        color: statusTextColor,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        statusLabel,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: statusTextColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  appointment.reason ?? 'Medical Appointment',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                _buildSection(
                  title: 'Date & Time',
                  child: Column(
                    children: [
                      _buildDetailRow(
                        icon: Icons.calendar_today,
                        label: 'Date',
                        value: DateFormat('EEEE, MMMM d, yyyy')
                            .format(appointment.appointmentDate),
                      ),
                      const SizedBox(height: 12),
                      _buildDetailRow(
                        icon: Icons.access_time,
                        label: 'Time',
                        value: DateFormat('HH:mm').format(
                          appointment.appointmentDate,
                        ),
                      ),
                      if (appointment.duration != null) ...[
                        const SizedBox(height: 12),
                        _buildDetailRow(
                          icon: Icons.timer,
                          label: 'Duration',
                          value: '${appointment.duration} minutes',
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                _buildSection(
                  title: 'Doctor Information',
                  child: _buildDetailRow(
                    icon: Icons.person_outline,
                    label: 'Doctor',
                    value: appointment.doctor?.name ??
                        'Dr. ${appointment.doctorId.substring(0, 8)}',
                    showDoctor: true,
                    specialty: appointment.doctor?.specialty,
                  ),
                ),
                const SizedBox(height: 24),
                _buildSection(
                  title: 'Patient Information',
                  child: _buildDetailRow(
                    icon: Icons.person_outline,
                    label: 'Patient',
                    value: appointment.patient?.name ??
                        appointment.patientId.substring(0, 8),
                  ),
                ),
                const SizedBox(height: 24),

                if (appointment.notes != null && appointment.notes!.isNotEmpty)
                  _buildSection(
                    title: 'Notes',
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.blue.shade200,
                        ),
                      ),
                      child: Text(
                        appointment.notes ?? '',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: child,
        ),
      ],
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    bool showDoctor = false,
    String? specialty,
  }) {
    return Row(
      children: [
        Icon(icon, color: Colors.blue.shade600),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: const Color.fromARGB(255, 0, 0, 0),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (specialty != null && specialty.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  specialty,
                  style: TextStyle(
                    fontSize: 12,
                    color: const Color.fromARGB(255, 0, 0, 0),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
