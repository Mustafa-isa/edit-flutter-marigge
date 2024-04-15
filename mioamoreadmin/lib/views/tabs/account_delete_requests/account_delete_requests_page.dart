import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mioamoreadmin/helpers/date_formater.dart';
import 'package:mioamoreadmin/providers/account_delete_request_provider.dart';
import 'package:mioamoreadmin/views/others/other_widgets.dart';
import 'package:mioamoreadmin/views/tabs/users/user_short_card.dart';

class AccountDeleteRequestsPage extends ConsumerWidget {
  const AccountDeleteRequestsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allAccountDeleteRequests = ref.watch(accountDeleteRequestsProvider);

    return NavigationView(
      appBar: const NavigationAppBar(
        title: Text('Account Delete Requests'),
        leading: Icon(FluentIcons.delete),
      ),
      content: allAccountDeleteRequests.when(
        data: (data) {
          data.sort((a, b) {
            final aDaysRemaining =
                a.deleteDate.difference(DateTime.now()).inDays;
            final bDaysRemaining =
                b.deleteDate.difference(DateTime.now()).inDays;

            return bDaysRemaining.compareTo(aDaysRemaining);
          });

          if (data.isEmpty) {
            return const Center(
              child: Text('No account delete requests'),
            );
          } else {
            return ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: data.length,
              itemBuilder: (context, index) {
                final userReports = data[index];

                final daysRemaining =
                    userReports.deleteDate.difference(DateTime.now()).inDays;

                return Card(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Expanded(
                        child: UserShortCard(userId: userReports.userId),
                      ),
                      const SizedBox(width: 16),
                      Text(
                          "Requested at: \n${DateFormatter.toYearMonthDay(userReports.requestDate)}"),
                      const SizedBox(width: 16),
                      Text(
                          "Delete at: \n${DateFormatter.toYearMonthDay(userReports.deleteDate)}"),
                      const SizedBox(width: 16),
                      Text(
                        '$daysRemaining ${daysRemaining == 1 ? 'day' : 'days'} remaining',
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 16),
                      if (daysRemaining <= 0)
                        FilledButton(
                          style: ButtonStyle(
                            backgroundColor: ButtonState.all(Colors.red),
                          ),
                          child: const Text("Delete"),
                          onPressed: () async {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return ContentDialog(
                                  title: const Text('Delete user'),
                                  content: const Text(
                                      'Are you sure you want to delete this user?'),
                                  actions: [
                                    HyperlinkButton(
                                      child: const Text('Cancel'),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                    HyperlinkButton(
                                      child: const Text('Delete'),
                                      onPressed: () async {
                                        await AccountDeleteRequestProvider
                                                .deleteUser(userReports.userId)
                                            .then((value) async {
                                          if (value) {
                                            EasyLoading.show(
                                                status:
                                                    'Deleting account delete request...');
                                            await AccountDeleteRequestProvider
                                                    .deleteRequest(
                                                        userReports.userId)
                                                .then((value) {
                                              EasyLoading.dismiss();
                                              ref.invalidate(
                                                  accountDeleteRequestsProvider);
                                              Navigator.of(context).pop();
                                            });
                                          }
                                        });
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        ),
                      const SizedBox(width: 16),
                    ],
                  ),
                );
              },
            );
          }
        },
        error: (error, stackTrace) {
          debugPrintStack(stackTrace: stackTrace);
          debugPrint(error.toString());
          return const MyErrorWidget();
        },
        loading: () => const MyLoadingWidget(),
      ),
    );
  }
}
