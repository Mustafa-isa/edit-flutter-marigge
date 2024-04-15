import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:mioamoreapp/models/user_account_settings_model.dart';

class UserProfileModel {
  String id;
  String userId;
  String fullName;
  String? email;
  String? profilePicture;
  String? phoneNumber;
  String gender;
  String? about;
  DateTime birthDay;
  List<String> mediaFiles;
  List<String> interests;
  UserAccountSettingsModel userAccountSettingsModel;
  bool isVerified;
  bool isOnline;
  UserProfileModel({
    required this.id,
    required this.userId,
    required this.fullName,
    this.email,
    this.profilePicture,
    this.phoneNumber,
    required this.gender,
    this.about,
    required this.birthDay,
    required this.mediaFiles,
    required this.interests,
    required this.userAccountSettingsModel,
    required this.isVerified,
    this.isOnline = false,
  });

  UserProfileModel copyWith({
    String? id,
    String? userId,
    String? fullName,
    String? email,
    String? profilePicture,
    String? phoneNumber,
    String? gender,
    String? about,
    DateTime? birthDay,
    List<String>? mediaFiles,
    List<String>? interests,
    UserAccountSettingsModel? userAccountSettingsModel,
    bool? isVerified,
    bool? isOnline,
  }) {
    return UserProfileModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      profilePicture: profilePicture ?? this.profilePicture,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      gender: gender ?? this.gender,
      about: about ?? this.about,
      birthDay: birthDay ?? this.birthDay,
      mediaFiles: mediaFiles ?? this.mediaFiles,
      interests: interests ?? this.interests,
      userAccountSettingsModel:
          userAccountSettingsModel ?? this.userAccountSettingsModel,
      isVerified: isVerified ?? this.isVerified,
      isOnline: isOnline ?? this.isOnline,
    );
  }

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'id': id});
    result.addAll({'userId': userId});
    result.addAll({'fullName': fullName});
    if (email != null) {
      result.addAll({'email': email});
    }
    if (profilePicture != null) {
      result.addAll({'profilePicture': profilePicture});
    }
    if (phoneNumber != null) {
      result.addAll({'phoneNumber': phoneNumber});
    }
    result.addAll({'gender': gender});
    if (about != null) {
      result.addAll({'about': about});
    }
    result.addAll({'birthDay': birthDay.millisecondsSinceEpoch});
    result.addAll({'mediaFiles': mediaFiles});
    result.addAll({'interests': interests});
    result
        .addAll({'userAccountSettingsModel': userAccountSettingsModel.toMap()});
    result.addAll({'isVerified': isVerified});
    result.addAll({'isOnline': isOnline});

    return result;
  }

  factory UserProfileModel.fromMap(Map<String, dynamic> map) {
    return UserProfileModel(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      fullName: map['fullName'] ?? '',
      email: map['email'],
      profilePicture: map['profilePicture'],
      phoneNumber: map['phoneNumber'],
      gender: map['gender'] ?? '',
      about: map['about'],
      birthDay: DateTime.fromMillisecondsSinceEpoch(map['birthDay']),
      mediaFiles: List<String>.from(map['mediaFiles']),
      interests: List<String>.from(map['interests']),
      userAccountSettingsModel:
          UserAccountSettingsModel.fromMap(map['userAccountSettingsModel']),
      isVerified: map['isVerified'] ?? false,
      isOnline: map['isOnline'] ?? false,
    );
  }

  String toJson() => json.encode(toMap());

  factory UserProfileModel.fromJson(String source) =>
      UserProfileModel.fromMap(json.decode(source));

  @override
  String toString() {
    return 'UserProfileModel(id: $id, userId: $userId, fullName: $fullName, email: $email, profilePicture: $profilePicture, phoneNumber: $phoneNumber, gender: $gender, about: $about, birthDay: $birthDay, mediaFiles: $mediaFiles, interests: $interests, userAccountSettingsModel: $userAccountSettingsModel, isVerified: $isVerified, isOnline: $isOnline)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    final listEquals = const DeepCollectionEquality().equals;

    return other is UserProfileModel &&
        other.id == id &&
        other.userId == userId &&
        other.fullName == fullName &&
        other.email == email &&
        other.profilePicture == profilePicture &&
        other.phoneNumber == phoneNumber &&
        other.gender == gender &&
        other.about == about &&
        other.birthDay == birthDay &&
        listEquals(other.mediaFiles, mediaFiles) &&
        listEquals(other.interests, interests) &&
        other.userAccountSettingsModel == userAccountSettingsModel &&
        other.isVerified == isVerified &&
        other.isOnline == isOnline;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        userId.hashCode ^
        fullName.hashCode ^
        email.hashCode ^
        profilePicture.hashCode ^
        phoneNumber.hashCode ^
        gender.hashCode ^
        about.hashCode ^
        birthDay.hashCode ^
        mediaFiles.hashCode ^
        interests.hashCode ^
        userAccountSettingsModel.hashCode ^
        isVerified.hashCode ^
        isOnline.hashCode;
  }
}
