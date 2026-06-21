class Doctor {
  final String id;
  final String firstName;
  final String lastName;
  final String? specialty;
  final String? photo;
  final String? location;
  final double? rate;
  final int? experienceYears;
  final double? consultationFee;

  Doctor({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.specialty,
    this.photo,
    this.location,
    this.rate,
    this.experienceYears,
    this.consultationFee,
  });

  factory Doctor.fromJson(Map<String, dynamic> json) {
    return Doctor(
      id: json['id'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      specialty: json['specialization'] ?? '',
      photo: json['photo'],
      location: json['location'],
      rate: (json['rate'] as num?)?.toDouble(),
      experienceYears: json['experience'] as int?,
      consultationFee: (json['consultationFee'] as num?)?.toDouble(),
    );
  }

  String get fullName => '$firstName $lastName';

  String getPlaceholder() =>
      'https://ui-avatars.com/api/?name=${Uri.encodeComponent(fullName)}&background=0D8ABC&color=ffffff&size=256&rounded=true';
}
