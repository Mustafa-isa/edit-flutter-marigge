import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mioamoreadmin/providers/admin_provider.dart';
import 'package:mioamoreadmin/providers/app_settings_provider.dart';
import 'package:mioamoreadmin/providers/auth_provider.dart';
import 'package:mioamoreadmin/providers/reset_database_provider.dart';
import 'package:mioamoreadmin/views/others/other_widgets.dart';
import 'package:mioamoreadmin/views/tabs/settings/app_settings.dart';
import 'package:mioamoreadmin/views/tabs/settings/change_email.dart';
import 'package:mioamoreadmin/views/tabs/settings/change_name.dart';
import 'package:mioamoreadmin/views/tabs/settings/change_password.dart';
import 'package:restart_app/restart_app.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final adminProfile = ref.watch(currentAdminProvider);
    final appSettingsRef = ref.watch(appSettingsProvider);

    return NavigationView(
      appBar: const NavigationAppBar(
        title: Text("Settings"),
        leading: Icon(FluentIcons.settings),
      ),
      content: adminProfile.when(
        data: (data) {
          if (data != null) {
            return Align(
              alignment: Alignment.topLeft,
              child: Container(
                padding: const EdgeInsets.all(16),
                width: 400,
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // App Settings
                            appSettingsRef.when(
                              data: (data) {
                                return Card(
                                  child: ListTile(
                                    title: const Text("App Settings"),
                                    subtitle:
                                        const Text("Update app settings here"),
                                    leading: const Icon(FluentIcons.edit),
                                    trailing:
                                        const Icon(FluentIcons.chevron_right),
                                    onPressed: () {
                                      showDialog(
                                          context: context,
                                          builder: (context) =>
                                              AppSettingsDialog(
                                                  appSettingsModel: data));
                                    },
                                  ),
                                );
                              },
                              error: (error, stackTrace) => const SizedBox(),
                              loading: () => const SizedBox(),
                            ),

                            const Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              child: Text("Account Settings"),
                            ),

                            Card(
                              child: ListTile(
                                title: const Text("Change Name"),
                                subtitle: const Text("Change your full name"),
                                leading: const Icon(FluentIcons.edit),
                                trailing: const Icon(FluentIcons.chevron_right),
                                onPressed: () {
                                  showDialog(
                                      context: context,
                                      builder: (context) =>
                                          ChangeNameDialog(admin: data));
                                },
                              ),
                            ),
                            Card(
                              child: ListTile(
                                title: const Text("Change Email"),
                                subtitle:
                                    const Text("Change your email address"),
                                leading: const Icon(FluentIcons.edit_mail),
                                trailing: const Icon(FluentIcons.chevron_right),
                                onPressed: () {
                                  showDialog(
                                      context: context,
                                      builder: (context) =>
                                          ChangeEmailDialog(admin: data));
                                },
                              ),
                            ),
                            Card(
                              child: ListTile(
                                title: const Text("Change Password"),
                                subtitle: const Text("Change your password"),
                                leading: const Icon(FluentIcons.password_field),
                                trailing: const Icon(FluentIcons.chevron_right),
                                onPressed: () {
                                  showDialog(
                                      context: context,
                                      builder: (context) =>
                                          const ChangePasswordDialog());
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Card(
                      child: ListTile(
                        title: const Text("Logout"),
                        subtitle: const Text("Logout of your account"),
                        leading: const Icon(FluentIcons.sign_out),
                        trailing: const Icon(FluentIcons.chevron_right),
                        onPressed: () async {
                          EasyLoading.show(status: 'Logging out...');

                          await AuthProvider.logout().then((value) async {
                            if (value) {
                              await Restart.restartApp();
                            }
                          });

                          EasyLoading.dismiss();
                        },
                      ),
                    ),
                    // if (data.isSuperAdmin) const SizedBox(height: 16),
                    // if (data.isSuperAdmin)
                    //   Card(
                    //     child: ListTile(
                    //       title: const Text("RESET to DEFAULT"),
                    //       subtitle:
                    //           const Text("Reset the database to default."),
                    //       leading: const Icon(FluentIcons.reset),
                    //       trailing: const Icon(FluentIcons.chevron_right),
                    //       onPressed: () async {
                    //         showDialog(
                    //           context: context,
                    //           builder: (context) {
                    //             return ContentDialog(
                    //               title: const Text("Reset to default?"),
                    //               content: const Text(
                    //                   "Are you sure you want to reset the database to default?"),
                    //               actions: [
                    //                 FilledButton(
                    //                   child: const Text("Cancel"),
                    //                   onPressed: () {
                    //                     Navigator.of(context).pop();
                    //                   },
                    //                 ),
                    //                 FilledButton(
                    //                   child: const Text("Yes"),
                    //                   onPressed: () async {
                    //                     Navigator.of(context).pop();
                    //                     EasyLoading.show(
                    //                         status: 'Resetting database...');
                    //                     await ResetDatabaseProvider.start()
                    //                         .then((value) {
                    //                       if (value) {
                    //                         EasyLoading.showSuccess(
                    //                             'Database reset to default!\nReload the app to see changes!');
                    //                       } else {
                    //                         EasyLoading.showError(
                    //                             'Failed to reset database!');
                    //                       }
                    //                     });
                    //                   },
                    //                 ),
                    //               ],
                    //             );
                    //           },
                    //         );
                    //       },
                    //     ),
                    //   ),
                  ],
                ),
              ),
            );
          } else {
            return const Center(child: Text("No data"));
          }
        },
        error: (error, stackTrace) => const MyErrorWidget(),
        loading: () => const MyLoadingWidget(),
      ),
    );
  }
}
