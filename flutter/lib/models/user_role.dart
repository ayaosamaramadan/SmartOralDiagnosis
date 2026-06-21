enum UserRole { unknown, patient, doctor, admin }

extension UserRoleValue on UserRole {
	String get value {
		switch (this) {
			case UserRole.doctor:
				return 'doctor';
			case UserRole.admin:
				return 'admin';
			case UserRole.patient:
				return 'patient';
			default:
				return 'unknown';
		}
	}
}

class UserRoleExt {
	/// Parse a string into a UserRole. Accepts values like 'Doctor', 'doctor', 'PATIENT', or arrays/complex shapes by calling toString.
	static UserRole fromString(String? raw) {
		if (raw == null) return UserRole.unknown;
		final s = raw.toString().trim().toLowerCase();
		if (s.isEmpty) return UserRole.unknown;
		if (s.contains('doctor')) return UserRole.doctor;
		if (s.contains('admin')) return UserRole.admin;
		if (s.contains('patient')) return UserRole.patient;
		// common synonyms
		if (s.contains('doc')) return UserRole.doctor;
		if (s.contains('user')) return UserRole.patient;
		return UserRole.unknown;
	}
}
