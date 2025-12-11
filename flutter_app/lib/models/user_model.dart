class UserModel {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String course;
  final String role;
  final String? profilePhoto;
  final bool isBlocked;
  final UserPermissions permissions;
  final DateTime? lastLogin;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    required this.course,
    required this.role,
    this.profilePhoto,
    this.isBlocked = false,
    required this.permissions,
    this.lastLogin,
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? json['_id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      course: json['course'] ?? 'Other',
      role: json['role'] ?? 'student',
      profilePhoto: json['profilePhoto'],
      isBlocked: json['isBlocked'] ?? false,
      permissions: UserPermissions.fromJson(json['permissions'] ?? {}),
      lastLogin: json['lastLogin'] != null ? DateTime.parse(json['lastLogin']) : null,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'course': course,
      'role': role,
      'profilePhoto': profilePhoto,
      'isBlocked': isBlocked,
      'permissions': permissions.toJson(),
      'lastLogin': lastLogin?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  bool get isStudent => role == 'student';
  bool get isAdmin => role == 'admin';
  bool get isSuperAdmin => role == 'superadmin';
}

class UserPermissions {
  final bool canAccessNotes;
  final bool canAccessBooks;
  final bool canAccessTests;
  final bool canAccessPPTs;
  final bool canAccessProjects;
  final bool canAccessAssignments;

  UserPermissions({
    this.canAccessNotes = true,
    this.canAccessBooks = true,
    this.canAccessTests = true,
    this.canAccessPPTs = true,
    this.canAccessProjects = true,
    this.canAccessAssignments = true,
  });

  factory UserPermissions.fromJson(Map<String, dynamic> json) {
    return UserPermissions(
      canAccessNotes: json['canAccessNotes'] ?? true,
      canAccessBooks: json['canAccessBooks'] ?? true,
      canAccessTests: json['canAccessTests'] ?? true,
      canAccessPPTs: json['canAccessPPTs'] ?? true,
      canAccessProjects: json['canAccessProjects'] ?? true,
      canAccessAssignments: json['canAccessAssignments'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'canAccessNotes': canAccessNotes,
      'canAccessBooks': canAccessBooks,
      'canAccessTests': canAccessTests,
      'canAccessPPTs': canAccessPPTs,
      'canAccessProjects': canAccessProjects,
      'canAccessAssignments': canAccessAssignments,
    };
  }
}
