import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mioamoreadmin/helpers/number_formatter.dart';
import 'package:mioamoreadmin/providers/account_delete_request_provider.dart';
import 'package:mioamoreadmin/providers/banned_users_provider.dart';
import 'package:mioamoreadmin/providers/devices_provider.dart';
import 'package:mioamoreadmin/providers/interactions_provider.dart';
import 'package:mioamoreadmin/providers/matches_provider.dart';
import 'package:mioamoreadmin/providers/user_profiles_provider.dart';
import 'package:mioamoreadmin/providers/user_reports_provider.dart';
import 'package:mioamoreadmin/providers/user_verification_forms_provider.dart';
import 'package:mioamoreadmin/views/tabs/dashboard/dashboard_card.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final totalUsersRef = ref.watch(usersShortStreamProvider);
    final totalInteractionsRef = ref.watch(totalInteractionsProvider);
    final totalMatchesRef = ref.watch(totalMatchesProvider);
    final totalDevicesRef = ref.watch(totalDevicesProvider);
    final allReportsRef = ref.watch(allReportsProvider);
    final bannedUsersRef = ref.watch(bannedUsersProvider);
    final verificationsref = ref.watch(pendingVerificationFormsStreamProvider);
    final allAccountDeleteRequests = ref.watch(accountDeleteRequestsProvider);

    return NavigationView(
      appBar: const NavigationAppBar(
        title: Text('Dashboard'),
        leading: Icon(FluentIcons.view_dashboard),
      ),
      content: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Align(
          alignment: Alignment.topLeft,
          child: Wrap(
            alignment: WrapAlignment.start,
            spacing: 16,
            runSpacing: 16,
            children: [
              totalUsersRef.when(
                data: (totalUsers) {
                  final male = totalUsers
                      .where((element) => element.gender == "male")
                      .toList();
                  final female = totalUsers
                      .where((element) => element.gender == "female")
                      .toList();
                  return DashboardCard(
                    title: 'Total Users',
                    value: NumberFormatter.formatNumber(totalUsers.length),
                    icon: FluentIcons.people,
                    color: Colors.blue,
                    subtitle:
                        "Male: ${NumberFormatter.formatNumber(male.length)} | Female: ${NumberFormatter.formatNumber(female.length)}",
                  );
                },
                loading: () => const SizedBox(),
                error: (error, stack) => const SizedBox(),
              ),
              totalUsersRef.when(
                data: (totalUsers) {
                  final verified = totalUsers
                      .where((element) => element.isVerified)
                      .toList();
                  return DashboardCard(
                    title: 'Total Verified Users',
                    value: NumberFormatter.formatNumber(verified.length),
                    icon: FluentIcons.people,
                    color: Colors.green.light,
                    subtitle:
                        "Verified: ${NumberFormatter.formatNumber(verified.length)}",
                  );
                },
                loading: () => const SizedBox(),
                error: (error, stack) => const SizedBox(),
              ),
              totalInteractionsRef.when(
                data: (totalInteractions) {
                  final likes = totalInteractions
                      .where((element) => element.isLike)
                      .toList();

                  final dislikes = totalInteractions
                      .where((element) => element.isDislike)
                      .toList();

                  final superLikes = totalInteractions
                      .where((element) => element.isSuperLike)
                      .toList();

                  return DashboardCard(
                    title: 'Total Interactions',
                    value:
                        NumberFormatter.formatNumber(totalInteractions.length),
                    icon: FluentIcons.add_connection,
                    color: Colors.red.light,
                    subtitle:
                        "Likes: ${NumberFormatter.formatNumber(likes.length)} | Dislikes: ${NumberFormatter.formatNumber(dislikes.length)} | Super Likes: ${NumberFormatter.formatNumber(superLikes.length)}",
                  );
                },
                loading: () => const SizedBox(),
                error: (error, stack) => const SizedBox(),
              ),
              totalMatchesRef.when(
                data: (totalMatches) => DashboardCard(
                  title: 'Total Matches',
                  value: NumberFormatter.formatNumber(totalMatches.length),
                  icon: FluentIcons.connect_contacts,
                  color: Colors.magenta,
                ),
                loading: () => const SizedBox(),
                error: (error, stack) => const SizedBox(),
              ),
              totalDevicesRef.when(
                data: (totalDevices) => DashboardCard(
                  title: 'Total Logged In Devices',
                  value: NumberFormatter.formatNumber(totalDevices),
                  icon: FluentIcons.cell_phone,
                  color: Colors.orange,
                ),
                loading: () => const SizedBox(),
                error: (error, stack) => const SizedBox(),
              ),
              allReportsRef.when(
                data: (allReports) {
                  return DashboardCard(
                    title: 'Total Reported Users',
                    value: NumberFormatter.formatNumber(allReports.length),
                    icon: FluentIcons.people,
                    color: Colors.red,
                  );
                },
                loading: () => const SizedBox(),
                error: (error, stack) => const SizedBox(),
              ),
              bannedUsersRef.when(
                data: (bannedUsers) {
                  return DashboardCard(
                    title: 'Total Banned Users',
                    value: NumberFormatter.formatNumber(bannedUsers.length),
                    icon: FluentIcons.people,
                    color: Colors.red,
                  );
                },
                loading: () => const SizedBox(),
                error: (error, stack) => const SizedBox(),
              ),
              verificationsref.when(
                data: (verifications) {
                  return DashboardCard(
                    title: 'Pending Verification Forms',
                    value: NumberFormatter.formatNumber(verifications.length),
                    icon: FluentIcons.verified_brand,
                    color: Colors.blue.dark,
                  );
                },
                loading: () => const SizedBox(),
                error: (error, stack) => const SizedBox(),
              ),
              allAccountDeleteRequests.when(
                data: (allAccountDeleteRequests) {
                  return DashboardCard(
                    title: 'Account Delete Requests',
                    value: NumberFormatter.formatNumber(
                        allAccountDeleteRequests.length),
                    icon: FluentIcons.delete,
                    color: Colors.red.dark,
                  );
                },
                loading: () => const SizedBox(),
                error: (error, stack) => const SizedBox(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
