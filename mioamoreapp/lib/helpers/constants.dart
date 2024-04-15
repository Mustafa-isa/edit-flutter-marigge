import 'package:flutter/material.dart';
import 'package:mioamoreapp/config/config.dart';

class AppConstants {
  AppConstants._();

  static Color primaryColor = AppConfig.primaryColor;
  static const double defaultNumericValue = 16.0;

  static const String logo = 'assets/images/logo.png';

  static LinearGradient defaultGradient = LinearGradient(
    colors: [
      AppConstants.primaryColor.withOpacity(0.8),
      AppConstants.primaryColor,
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}

class FirebaseConstants {
  FirebaseConstants._();

  static const String userProfileCollection = "userProfile";
  static const String userInteractionCollection = "userInteraction";
  static const String matchCollection = "matches";
  static const String chatCollection = "chat";
  static const String verificationFormsCollection = "verificationForms";
  static const String feedsCollection = "feeds";
  static const String deviceTokensCollection = "deviceTokens";
  static const String notificationsCollection = "notifications";
  static const String blockedUsersCollection = "blockedUsers";
  static const String reportsCollection = "reports";
  static const String bannedUsersCollection = "bannedUsers";
  static const String accountDeleteRequestCollection = "accountDeleteRequest";
  static const String appSettingsCollection = "appSettings";
}

class HiveConstants {
  HiveConstants._();

  static const String hiveBox = "hiveBox";

  static const String chatWallpaper = "chatWallpaper";
  static const String showCompleteDialog = "showCompleteDialog";
  static const String guidedTour = "guidedTour";
}

///Json
const String countryCodeJson = "assets/json/country_code.json";

/// Lottie Json
const String lottieNoItemFound = "assets/json/lottie/no_item_found.json";

///Images
const String appleLogo = "assets/logos/apple.png";
const String facebookLogo = "assets/logos/facebook.png";
const String googleLogo = "assets/logos/google.png";
const String twitterLogo = "assets/logos/twitter.png";

final emailVerificationRedExp = RegExp(
    r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
