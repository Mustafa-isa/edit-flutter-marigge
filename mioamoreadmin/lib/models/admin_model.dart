import 'dart:convert';
import 'package:collection/collection.dart';

const String verificationPermission = "Verfication";
const String reportPermission = "Report";
const String accountDeletePermission = "Account Delete";

const List<String> permissions = [
  verificationPermission,
  reportPermission,
  accountDeletePermission,
];

class AdminModel {
  String id;
  String name;
  String email;
  List<String> permissions;
  bool isSuperAdmin;
  DateTime createdAt;
  AdminModel({
    required this.id,
    required this.name,
    required this.email,
    required this.permissions,
    required this.isSuperAdmin,
    required this.createdAt,
  });

  AdminModel copyWith({
    String? id,
    String? name,
    String? email,
    List<String>? permissions,
    bool? isSuperAdmin,
    DateTime? createdAt,
  }) {
    return AdminModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      permissions: permissions ?? this.permissions,
      isSuperAdmin: isSuperAdmin ?? this.isSuperAdmin,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'id': id});
    result.addAll({'name': name});
    result.addAll({'email': email});
    result.addAll({'permissions': permissions});
    result.addAll({'isSuperAdmin': isSuperAdmin});
    result.addAll({'createdAt': createdAt.millisecondsSinceEpoch});

    return result;
  }

  factory AdminModel.fromMap(Map<String, dynamic> map) {
    return AdminModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      permissions: List<String>.from(map['permissions']),
      isSuperAdmin: map['isSuperAdmin'] ?? false,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
    );
  }

  String toJson() => json.encode(toMap());

  factory AdminModel.fromJson(String source) =>
      AdminModel.fromMap(json.decode(source));

  @override
  String toString() {
    return 'AdminModel(id: $id, name: $name, email: $email, permissions: $permissions, isSuperAdmin: $isSuperAdmin, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    final listEquals = const DeepCollectionEquality().equals;

    return other is AdminModel &&
        other.id == id &&
        other.name == name &&
        other.email == email &&
        listEquals(other.permissions, permissions) &&
        other.isSuperAdmin == isSuperAdmin &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        email.hashCode ^
        permissions.hashCode ^
        isSuperAdmin.hashCode ^
        createdAt.hashCode;
  }
}
