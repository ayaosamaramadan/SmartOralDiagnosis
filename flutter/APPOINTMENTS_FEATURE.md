# Appointments Feature Documentation

## Overview
تم إنشاء صفحة appointments كاملة في Flutter بنفس التصميم والوظائف من صفحة Next.js في Frontend.

## الملفات الجديدة

### 1. Models
- **`lib/models/appointment.dart`**: يحتوي على نموذج `Appointment` و `DoctorInfo` و `PatientInfo`
  - تحويل JSON ↔ Dart objects
  - معالجة التواريخ والأوقات

### 2. Services
- **`lib/services/appointment_service.dart`**: خدمة API للـ appointments
  - `getAll()`: جلب جميع الـ appointments
  - `getByPatientId(patientId)`: جلب appointments المريض
  - `getByDoctorId(doctorId)`: جلب appointments الدكتور
  - `getById(id)`: جلب تفاصيل appointment معين
  - `delete(id)`: إلغاء appointment

### 3. UI Screens
- **`lib/screen/appointments_screen.dart`**: الصفحة الرئيسية للـ appointments
  - عرض قائمة الـ appointments
  - Status badges (Pending, Confirmed, Completed, Cancelled)
  - معلومات الدكتور والمريض
  - زر Book Appointment
  - زر Cancel للـ patients
  - Navigation إلى التفاصيل

- **`lib/screen/appointment_details_screen.dart`**: صفحة تفاصيل الـ appointment
  - عرض جميع معلومات الـ appointment
  - Status, Date, Time, Duration
  - معلومات الدكتور والمريض
  - الملاحظات

## المميزات

### ✅ العمليات المدعومة:
1. **عرض الـ Appointments**:
   - المرضى يرون appointments خاصتهم
   - الأطباء يرون appointments مرضاهم
   - الـ Admin يرى جميع الـ appointments

2. **الفلترة حسب الحالة**:
   - Pending (أصفر) - قيد الانتظار
   - Confirmed (أزرق) - مؤكد
   - Completed (أخضر) - مكتمل
   - Cancelled (أحمر) - ملغى

3. **إلغاء الـ Appointment**:
   - المرضى يمكنهم إلغاء الـ appointments غير المكتملة
   - تأكيد قبل الإلغاء

4. **عرض التفاصيل**:
   - معلومات كاملة عن الـ appointment
   - التاريخ والوقت والمدة
   - معلومات الدكتور والمريض
   - الملاحظات

## Navigation Routes

| Route | الوصف |
|-------|------|
| `/appointments` | قائمة الـ appointments |
| `/appointments-details` | تفاصيل appointment محدد (يأخذ appointmentId) |

## الاستخدام

### من الـ Navigation Drawer:
- انقر على "Appointments" في القائمة الجانبية

### من الـ Code:
```dart
// الانتقال لقائمة الـ appointments
Navigator.pushNamed(context, '/appointments');

// الانتقال لتفاصيل appointment محدد
Navigator.pushNamed(
  context,
  '/appointments-details',
  arguments: appointmentId,
);
```

## التنسيق والألوان

### Status Colors:
- **Pending** (0): أصفر (#FEF3C7) مع أيقونة warning
- **Confirmed** (1): أزرق (#DEEAF6) مع أيقونة check
- **Completed** (2): أخضر (#DCFCE7) مع أيقونة check
- **Cancelled** (3): أحمر (#FEE2E2) مع أيقونة cancel

### Layout:
- Responsive design - يعمل على mobile و tablet
- Dark mode support
- Material Design 3

## Backend Requirements

يجب أن يكون Backend يدعم الـ endpoints التالية:

```
GET /api/appointments
GET /api/appointments/:id
GET /api/appointments/patient/:patientId
GET /api/appointments/doctor/:doctorId
DELETE /api/appointments/:id
```

## التكامل مع الـ Authentication

الخدمة تستخدم `getAuthHeaders()` من `services/auth.dart` لإضافة JWT token إلى جميع الـ requests.

## المتطلبات

- `intl` package لمعالجة التاريخ والوقت
- `http` package للـ API calls
- `flutter_secure_storage` لتخزين بيانات المستخدم

## الخطوات التالية

1. التأكد من أن Backend يدعم الـ endpoints المطلوبة
2. اختبار الـ integration مع الـ real API
3. إضافة advanced features مثل:
   - Scheduling جديد
   - تعديل الـ appointments
   - Notifications عند تغيير الحالة
