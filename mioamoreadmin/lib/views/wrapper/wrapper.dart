import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mioamoreadmin/models/admin_model.dart';
import 'package:mioamoreadmin/providers/admin_provider.dart';
import 'package:mioamoreadmin/views/others/other_widgets.dart';
import 'package:mioamoreadmin/views/tabs/account_delete_requests/account_delete_requests_page.dart';
import 'package:mioamoreadmin/views/tabs/admins/admins_page.dart';
import 'package:mioamoreadmin/views/tabs/dashboard/dashboard_page.dart';
import 'package:mioamoreadmin/views/tabs/reports/reports_page.dart';
import 'package:mioamoreadmin/views/tabs/settings/settings_page.dart';
import 'package:mioamoreadmin/views/tabs/users/users_page.dart';
import 'package:mioamoreadmin/views/tabs/verifications/verification_page.dart';

class Wrapper extends ConsumerStatefulWidget {
  const Wrapper({super.key});

  @override
  ConsumerState<Wrapper> createState() => _WrapperState();
}

class _WrapperState extends ConsumerState<Wrapper> {
  int _selectedIndex = 0;
  final _scrollController = ScrollController();
  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentAdminProvider);

    return currentUser.when(
      data: (user) {
        return user != null
            ? NavigationView(
                pane: NavigationPane(
                  scrollController: _scrollController,
                  selected: _selectedIndex,
                  onChanged: (index) => setState(() => _selectedIndex = index),
                  header: ListTile(
                    title: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: Text(user.name)),
                        Text(
                          user.isSuperAdmin ? ' (Super Admin)' : '',
                          style: FluentTheme.of(context).typography.caption,
                        )
                      ],
                    ),
                    subtitle: Text(user.email),
                  ),
                  items: [
                    PaneItem(
                      icon: const Icon(FluentIcons.view_dashboard),
                      title: const Text('Dashboard'),
                      body: const DashboardPage(),
                    ),

                    // Admins

                    if (user.isSuperAdmin)
                      PaneItem(
                        icon: const Icon(FluentIcons.people),
                        title: const Text('Admins'),
                        body: const AdminsPage(),
                      ),

                    //Users
                    PaneItem(
                      icon: const Icon(FluentIcons.people),
                      title: const Text('Users'),
                      body: const UsersPage(),
                    ),

                    // Verifications
                    if (user.permissions.contains(verificationPermission))
                      PaneItem(
                        icon: const Icon(FluentIcons.list),
                        title: const Text('Verifications'),
                        body: const VerificationsPage(),
                      ),

                    // Reports

                    if (user.permissions.contains(reportPermission))
                      PaneItem(
                        icon: const Icon(FluentIcons.list),
                        title: const Text('Reports'),
                        body: const ReportsPage(),
                      ),
                    if (user.permissions.contains(accountDeletePermission))
                      PaneItem(
                        icon: const Icon(FluentIcons.delete),
                        title: const Text('Account Delete Requests'),
                        body: const AccountDeleteRequestsPage(),
                      ),
                  ],
                  footerItems: [
                    PaneItem(
                      icon: const Icon(FluentIcons.settings),
                      title: const Text('Settings'),
                      body: const SettingsPage(),
                    ),
                  ],
                ),
              )
            : const MyErrorWidget();
      },
      loading: () => const MyLoadingWidget(),
      error: (error, stack) => const MyErrorWidget(),
    );
  }
}
