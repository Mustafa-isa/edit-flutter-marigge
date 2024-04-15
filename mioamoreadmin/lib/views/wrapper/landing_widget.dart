import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mioamoreadmin/providers/admin_provider.dart';
import 'package:mioamoreadmin/providers/auth_provider.dart';
import 'package:mioamoreadmin/views/auth/login_page.dart';
import 'package:mioamoreadmin/views/auth/super_admin_registration_page.dart';
import 'package:mioamoreadmin/views/others/other_widgets.dart';
import 'package:mioamoreadmin/views/wrapper/wrapper.dart';

class SuperAdminLandingWidget extends ConsumerWidget {
  const SuperAdminLandingWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final superAdminRef = ref.watch(superAdminProvider);
    return superAdminRef.when(
      data: (data) {
        return data == null
            ? const SuperAdminRegistrationPage()
            : const NormalLandingWidget();
      },
      error: (error, stackTrace) => const MyErrorWidget(),
      loading: () => const MyLoadingWidget(),
    );
  }
}

class NormalLandingWidget extends ConsumerWidget {
  const NormalLandingWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authStateRef = ref.watch(authstateChangesProvider);

    return authStateRef.when(
      data: (data) {
        if (data == null) {
          return const LoginPage();
        } else {
          final isUserAdminRef = ref.watch(isUserAdminProvider(data.uid));

          return isUserAdminRef.when(
            data: (isAdmin) {
              if (isAdmin) {
                final isEmailVerifiedRef = ref.watch(isEmailVerifiedProvider);

                return isEmailVerifiedRef.when(
                  data: (isEmailVerified) {
                    if (isEmailVerified) {
                      return const Wrapper();
                    } else {
                      return const NotEmailVerifiedWidget();
                    }
                  },
                  error: (error, stackTrace) => const MyErrorWidget(),
                  loading: () => const MyLoadingWidget(),
                );
              } else {
                return const NotAdminWidget();
              }

              // return data ? const Wrapper() : const NotAdminWidget();
            },
            error: (error, stackTrace) => const MyErrorWidget(),
            loading: () => const MyLoadingWidget(),
          );
        }
      },
      error: (error, stackTrace) => const MyErrorWidget(),
      loading: () => const MyLoadingWidget(),
    );
  }
}
