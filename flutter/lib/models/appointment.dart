class Appointment {
  final String id;
  final String patientId;
  final String doctorId;
  final DateTime appointmentDate;
  final int? duration;
  final int? type;
  final int? status;
  final String? reason;
  final String? notes;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DoctorInfo? doctor;
  final PatientInfo? patient;

  Appointment({
    required this.id,
    required this.patientId,
    required this.doctorId,
    required this.appointmentDate,
    this.duration,
    this.type,
    this.status,
    this.reason,
    this.notes,
    this.createdAt,
    this.updatedAt,
    this.doctor,
    this.patient,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['id'] as String? ?? '',
      patientId: json['patientId'] as String? ?? '',
      doctorId: json['doctorId'] as String? ?? '',
      appointmentDate: json['appointmentDate'] != null
          ? DateTime.parse(json['appointmentDate'] as String)
          : DateTime.now(),
      duration: json['duration'] as int?,
      type: json['type'] as int?,
      status: json['status'] as int?,
      reason: json['reason'] as String?,
      notes: json['notes'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      doctor: json['doctor'] != null
          ? DoctorInfo.fromJson(json['doctor'] as Map<String, dynamic>)
          : null,
      patient: json['patient'] != null
          ? PatientInfo.fromJson(json['patient'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patientId': patientId,
      'doctorId': doctorId,
      'appointmentDate': appointmentDate.toIso8601String(),
      'duration': duration,
      'type': type,
      'status': status,
      'reason': reason,
      'notes': notes,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'doctor': doctor?.toJson(),
      'patient': patient?.toJson(),
    };
  }
}

class DoctorInfo {
  final String id;
  final String? name;
  final String? specialty;

  DoctorInfo({
    required this.id,
    this.name,
    this.specialty,
  });

  factory DoctorInfo.fromJson(Map<String, dynamic> json) {
    return DoctorInfo(
      id: json['id'] as String? ?? '',
      name: json['name'] as String?,
      specialty: json['specialty'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'specialty': specialty,
    };
  }
}

class PatientInfo {
  final String id;
  final String? name;

  PatientInfo({
    required this.id,
    this.name,
  });

  factory PatientInfo.fromJson(Map<String, dynamic> json) {
    return PatientInfo(
      id: json['id'] as String? ?? '',
      name: json['name'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}
