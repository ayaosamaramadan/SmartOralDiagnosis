// Common types and interfaces for the Medical Management System

export interface User {
  id: string;
  email: string;
  firstName: string;
  lastName: string;
  phoneNumber: string;
  role: UserRole;
  isActive: boolean;
  createdAt: string;
  updatedAt: string;
}

export enum UserRole {
  Patient = "Patient",
  Doctor = "Doctor",
  Admin = "Admin",
}

export interface Patient extends User {
  dateOfBirth: string;
  address: Address;
  emergencyContact: EmergencyContact;
  medicalHistory: MedicalHistory[];
  assignedDoctorId?: string;
}

export interface Doctor extends User {
  specialization: string;
  licenseNumber: string;
  department: string;
  experience: number;
  availability: DoctorAvailability[];
  consultationFee: number;
}

export interface Admin extends User {
  permissions: string[];
  lastLogin: string;
}

export interface Address {
  street: string;
  city: string;
  state: string;
  zipCode: string;
  country: string;
}

export interface EmergencyContact {
  name: string;
  relationship: string;
  phoneNumber: string;
  email?: string;
}

export interface MedicalHistory {
  condition: string;
  diagnosis: string;
  treatment: string;
  date: string;
  notes?: string;
}

export interface DoctorAvailability {
  dayOfWeek: number; // 0-6 (Sunday-Saturday)
  startTime: string;
  endTime: string;
  isAvailable: boolean;
}

export interface Appointment {
  id: string;
  patientId: string;
  doctorId: string;
  appointmentDate: string;
  duration: number;
  type: AppointmentType;
  status: AppointmentStatus;
  reason: string;
  notes?: string;
  diagnosis?: string;
  prescription?: string;
  createdAt: string;
  updatedAt: string;

  // Populated fields
  patient?: Patient;
  doctor?: Doctor;
}

export enum AppointmentType {
  Consultation = "Consultation",
  FollowUp = "FollowUp",
  Emergency = "Emergency",
  Routine = "Routine",
}

export enum AppointmentStatus {
  Scheduled = "Scheduled",
  Confirmed = "Confirmed",
  InProgress = "InProgress",
  Completed = "Completed",
  Cancelled = "Cancelled",
  NoShow = "NoShow",
}

export interface MedicalRecord {
  id: string;
  patientId: string;
  doctorId: string;
  appointmentId?: string;
  title: string;
  description: string;
  diagnosis: string;
  treatment: string;
  prescription: Prescription[];
  tests: MedicalTest[];
  attachments: MedicalAttachment[];
  recordDate: string;
  createdAt: string;
  updatedAt: string;

  // Populated fields
  patient?: Patient;
  doctor?: Doctor;
  appointment?: Appointment;
}

export interface Prescription {
  medicationName: string;
  dosage: string;
  frequency: string;
  duration: string;
  instructions: string;
}

export interface MedicalTest {
  testName: string;
  testDate: string;
  result: string;
  normalRange?: string;
  status: TestStatus;
  notes?: string;
}

export enum TestStatus {
  Pending = "Pending",
  InProgress = "InProgress",
  Completed = "Completed",
  Cancelled = "Cancelled",
}

export interface MedicalAttachment {
  id: string;
  fileName: string;
  fileType: string;
  fileSize: number;
  filePath: string;
  uploadedAt: string;
}

// API Response Types
export interface ApiResponse<T = any> {
  success: boolean;
  data?: T;
  message?: string;
  errors?: string[];
}

export interface PaginatedResponse<T = any> {
  success: boolean;
  data: T[];
  pagination: {
    currentPage: number;
    totalPages: number;
    totalCount: number;
    pageSize: number;
    hasNext: boolean;
    hasPrevious: boolean;
  };
}

// Authentication Types
export interface LoginRequest {
  email: string;
  password: string;
  role: UserRole;
}

export interface RegisterRequest {
  email: string;
  password: string;
  firstName: string;
  lastName: string;
  phoneNumber: string;
  role: UserRole;
}

export interface AuthResponse {
  token: string;
  user: User;
  expiresAt: string;
}

// Dashboard Types
export interface DashboardStats {
  totalPatients: number;
  totalDoctors: number;
  totalAppointments: number;
  totalMedicalRecords: number;
  todayAppointments: number;
  pendingAppointments: number;
  completedAppointments: number;
  cancelledAppointments: number;
}

export interface PatientDashboardStats {
  upcomingAppointments: number;
  totalAppointments: number;
  medicalRecords: number;
  lastVisit?: string;
}

export interface DoctorDashboardStats {
  todayAppointments: number;
  totalPatients: number;
  completedAppointments: number;
  pendingAppointments: number;
}

// Form Types
export interface AppointmentForm {
  patientId: string;
  doctorId: string;
  appointmentDate: string;
  appointmentTime: string;
  duration: number;
  type: AppointmentType;
  reason: string;
  notes?: string;
}

export interface MedicalRecordForm {
  patientId: string;
  doctorId: string;
  appointmentId?: string;
  title: string;
  description: string;
  diagnosis: string;
  treatment: string;
  prescription: Prescription[];
  tests: MedicalTest[];
}

// Filter and Search Types
export interface AppointmentFilter {
  dateFrom?: string;
  dateTo?: string;
  status?: AppointmentStatus;
  type?: AppointmentType;
  doctorId?: string;
  patientId?: string;
}

export interface PatientFilter {
  search?: string;
  doctorId?: string;
  isActive?: boolean;
}

export interface DoctorFilter {
  search?: string;
  specialization?: string;
  department?: string;
  isActive?: boolean;
}

// Error Types
export interface ValidationError {
  field: string;
  message: string;
}

export interface ApiError {
  message: string;
  statusCode: number;
  errors?: ValidationError[];
}
