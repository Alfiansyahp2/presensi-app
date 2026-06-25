import 'school_model.dart';

/// User Model dengan RBAC Support
///
/// Model ini mendukung role-based access control dan multi-tenant system
class UserModel {
  final int? id;
  final String fullname;
  final String? nisn;        // Optional (hanya untuk siswa)
  final String? kelas;       // Optional (hanya untuk siswa)
  final String email;
  final String? token;

  // 🆕 RBAC FIELDS
  final String role;         // 'SUPER_ADMIN' | 'SCHOOL_ADMIN' | 'TEACHER' | 'STUDENT'
  final String status;       // 'PENDING' | 'ACTIVE' | 'SUSPENDED'
  final int? schoolId;       // Multi-tenant ID
  final SchoolModel? school; // School object (dari API)
  final List<String> permissions; // Permission list

  UserModel({
    this.id,
    required this.fullname,
    this.nisn,
    this.kelas,
    required this.email,
    this.token,
    required this.role,
    required this.status,
    this.schoolId,
    this.school,
    this.permissions = const [],
  });

  /// Parse dari JSON response API (Login & Profile)
  factory UserModel.fromJson(Map<String, dynamic> json) {
    // Handle both direct user data and nested user.data structure
    final userData = json['user'] is Map ? json['user'] : json;

    return UserModel(
      id: userData['id'],
      fullname: userData['fullname'] ?? '',
      nisn: userData['nisn'], // Nullable untuk non-student roles
      kelas: userData['kelas'], // Nullable untuk non-student roles
      email: userData['email'] ?? '',
      token: userData['token'] ?? json['token'],
      role: userData['role'] ?? 'STUDENT',
      status: userData['status'] ?? 'PENDING',
      schoolId: userData['school_id'],
      school: userData['school'] != null
          ? SchoolModel.fromJson(userData['school'])
          : null,
      permissions: userData['permissions']?.cast<String>() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullname': fullname,
      'nisn': nisn,
      'kelas': kelas,
      'email': email,
      'token': token,
      'role': role,
      'status': status,
      'school_id': schoolId,
      'school': school?.toJson(),
      'permissions': permissions,
    };
  }

  // 🎯 ROLE CHECKERS

  /// Cek apakah user adalah SISWA
  bool get isStudent => role == 'STUDENT';

  /// Cek apakah user adalah GURU
  bool get isTeacher => role == 'TEACHER';

  /// Cek apakah user adalah SCHOOL_ADMIN
  bool get isSchoolAdmin => role == 'SCHOOL_ADMIN';

  /// Cek apakah user adalah SUPER_ADMIN
  bool get isSuperAdmin => role == 'SUPER_ADMIN';

  /// Cek apakah user memiliki role admin (school atau super)
  bool get isAdmin => isSchoolAdmin || isSuperAdmin;

  /// Cek apakah user memiliki role staff (guru atau admin)
  bool get isStaff => isTeacher || isAdmin;

  // ✅ STATUS CHECKERS

  /// Cek apakah account aktif
  bool get isActive => status == 'ACTIVE';

  /// Cek apakah account pending approval
  bool get isPending => status == 'PENDING';

  /// Cek apakah account suspended
  bool get isSuspended => status == 'SUSPENDED';

  // 🔒 PERMISSION CHECKERS

  /// Cek apakah user memiliki permission tertentu
  bool hasPermission(String permission) {
    // Super admin memiliki semua permissions
    if (isSuperAdmin) return true;
    return permissions.contains(permission);
  }

  /// Cek apakah user memiliki salah satu dari beberapa permissions
  bool hasAnyPermission(List<String> requiredPermissions) {
    if (isSuperAdmin) return true;
    return requiredPermissions.any((p) => permissions.contains(p));
  }

  /// Cek apakah user memiliki semua permissions yang dibutuhkan
  bool hasAllPermissions(List<String> requiredPermissions) {
    if (isSuperAdmin) return true;
    return requiredPermissions.every((p) => permissions.contains(p));
  }

  /// Cek apakah user bisa melakukan check-in (STUDENT only)
  bool get canCheckIn => isStudent && isActive;

  /// Cek apakah user bisa melakukan check-out (STUDENT only)
  bool get canCheckOut => isStudent && isActive;

  /// Cek apakah user bisa melihat attendance reports
  bool get canViewReports => hasPermission('report.view') || isAdmin;

  /// Cek apakah user bisa manage users
  bool get canManageUsers => hasPermission('user.create') || isAdmin;

  /// Cek apakah user bisa approve attendance
  bool get canApproveAttendance => hasPermission('attendance.approve');

  /// Cek apakah user bisa manage school settings
  bool get canManageSchool => hasPermission('school.update') && isSchoolAdmin;

  // 🏫 SCHOOL HELPERS

  /// Cek apakah user memiliki school
  bool get hasSchool => school != null && schoolId != null;

  /// Cek apakah school user aktif
  bool get isSchoolActive => school?.isActive() ?? false;

  /// Get school name atau 'System' untuk super admin
  String get displayName => isSuperAdmin ? 'System Admin' :
                            isSchoolAdmin ? 'Admin Sekolah' :
                            isTeacher ? 'Guru' : 'Siswa';

  @override
  String toString() {
    return 'UserModel(id: $id, name: $fullname, role: $role, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
