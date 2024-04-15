import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mioamoreapp/config/config.dart';
import 'package:mioamoreapp/helpers/constants.dart';
import 'package:mioamoreapp/models/country_code.dart';
import 'package:mioamoreapp/providers/auth_providers.dart';
import 'package:mioamoreapp/providers/country_codes_provider.dart';
import 'package:mioamoreapp/providers/get_current_location_provider.dart';
import 'package:mioamoreapp/views/auth/login_with_phone_page.dart';
import 'package:mioamoreapp/views/auth/select_country_page.dart';
import 'package:mioamoreapp/views/company/privacy_policy.dart';
import 'package:mioamoreapp/views/company/terms_and_conditions.dart';
import 'package:mioamoreapp/views/custom/custom_button.dart';
import 'package:mioamoreapp/views/others/error_page.dart';
import 'package:mioamoreapp/views/others/loading_page.dart';

import '../../generated/l10n.dart';

class LoginPage extends ConsumerWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, ref) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(AppConstants.defaultNumericValue * 2),
          height: MediaQuery.of(context).size.height,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.3,
                  maxHeight: MediaQuery.of(context).size.width * 0.3,
                ),
                child: Image.asset(
                  AppConstants.logo,
                  fit: BoxFit.contain,
                ),
              ),
              const Spacer(),
              const SizedBox(height: AppConstants.defaultNumericValue),

              //Google
              if (isGoogleAuthAvailable)
                LoginButton(
                  icon: Image.asset(googleLogo,
                      width: AppConstants.defaultNumericValue * 2),
                  onPressed: () async {
                    EasyLoading.show(status: S.of(context).Logging);
                    await ref.read(authProvider).signInWithGoogle();
                    EasyLoading.dismiss();
                  },
                  text: S.of(context).Logwithgoogle,
                ),
              if (isGoogleAuthAvailable)
                const SizedBox(height: AppConstants.defaultNumericValue),

              //Facebook
              if (isFacebookAuthAvailable)
                LoginButton(
                  icon: Image.asset(facebookLogo,
                      width: AppConstants.defaultNumericValue * 2),
                  onPressed: () async {
                    EasyLoading.show(status: S.of(context).Logging);
                    await ref.read(authProvider).signInWithFacebook();
                  },
                  text: S.of(context).logwithfaceebook,
                ),
              if (isFacebookAuthAvailable)
                const SizedBox(height: AppConstants.defaultNumericValue),

              // //Twitter
              // if (isTwitterAuthAvailable)
              //   LoginButton(
              //     icon: Image.asset(twitterLogo,
              //         width: AppConstants.defaultNumericValue * 2),
              //     onPressed: () {
              //       EasyLoading.showInfo('Coming soon...');
              //     },
              //     text: "Log in with twitter",
              //   ),
              // if (isTwitterAuthAvailable)
              //   const SizedBox(height: AppConstants.defaultNumericValue),

              // //Apple
              // if (isAppleAuthAvailable)
              //   if (Platform.isIOS)
              //     LoginButton(
              //       icon: Image.asset(appleLogo,
              //           width: AppConstants.defaultNumericValue * 2),
              //       onPressed: () {
              //         EasyLoading.showInfo('Coming soon...');
              //       },
              //       text: "Log in with apple",
              //     ),
              // if (isAppleAuthAvailable)
              //   if (Platform.isIOS)
              //     const SizedBox(height: AppConstants.defaultNumericValue),

              //Phone
              if (isPhoneAuthAvailable)
                LoginButton(
                  icon: Icon(
                    CupertinoIcons.phone_circle_fill,
                    color: AppConstants.primaryColor,
                    size: AppConstants.defaultNumericValue * 2,
                  ),
                  onPressed: () async {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PhoneLoginLandingWidget(),
                      ),
                    );
                  },
                  text: S.of(context).Loginwithphone,
                ),
              if (isPhoneAuthAvailable)
                const SizedBox(height: AppConstants.defaultNumericValue),

              // Agree to terms
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.defaultNumericValue * 2),
                // child: Text(
                //   "By logging in you agree to our Terms of Service and Privacy Policy.",
                //   textAlign: TextAlign.center,
                //   style: Theme.of(context).textTheme.subtitle2!.copyWith(),
                // ),
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: S.of(context).Bylogginginyouagreetoour,
                        style:
                            Theme.of(context).textTheme.titleSmall!.copyWith(),
                      ),
                      TextSpan(
                        text: S.of(context).TermsofService,
                        style: Theme.of(context).textTheme.titleSmall!.copyWith(
                              color: AppConstants.primaryColor,
                            ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const TermsAndConditions(),
                                    fullscreenDialog: true));
                          },
                      ),
                      TextSpan(
                        text: S.of(context).and,
                        style:
                            Theme.of(context).textTheme.titleSmall!.copyWith(),
                      ),
                      TextSpan(
                        text: S.of(context).PrivacyPolicy,
                        style: Theme.of(context).textTheme.titleSmall!.copyWith(
                              color: AppConstants.primaryColor,
                            ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const PrivacyPolicy(),
                                    fullscreenDialog: true));
                          },
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: AppConstants.defaultNumericValue),

              // //
              //   TextButton(
              //     onPressed: () {},
              //     child: const Text(
              //       "Trouble logging in?",
              //       style:
              //           TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              //     ),
              //   ),
              //   const SizedBox(height: AppConstants.defaultNumericValue),
            ],
          ),
        ),
      ),
    );
  }
}

class PhoneLoginLandingWidget extends ConsumerWidget {
  const PhoneLoginLandingWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final countryCodesData = ref.watch(countryCodesProvider);
    final currentLocationProviderProvider =
        ref.watch(getCurrentLocationProviderProvider);

    return countryCodesData.when(
        data: (data) {
          return currentLocationProviderProvider.when(
              data: (location) {
                if (location != null) {
                  final List<CountryCode> countryCodes = data
                      .where((element) =>
                          location.addressText.contains(element.name))
                      .toList();

                  return countryCodes.isEmpty
                      ? const SelectCountryPage()
                      : LoginWithPhoneNumberPage(
                          countryCode: countryCodes.first);
                } else {
                  return const SelectCountryPage();
                }
              },
              error: (_, e) {
                return const ErrorPage();
              },
              loading: () => const LoadingPage());
        },
        error: (_, e) {
          return const ErrorPage();
        },
        loading: () => const LoadingPage());
  }
}

class LoginButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget icon;
  final String text;
  const LoginButton({
    Key? key,
    required this.onPressed,
    required this.icon,
    required this.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomButton(
      onPressed: onPressed,
      isWhite: true,
      borderColor: AppConstants.primaryColor,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          icon,
          Text(
            text.toUpperCase(),
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: AppConstants.defaultNumericValue),
        ],
      ),
    );
  }
}
