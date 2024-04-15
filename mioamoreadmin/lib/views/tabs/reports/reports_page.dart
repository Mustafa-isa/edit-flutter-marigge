import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' as material;
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mioamoreadmin/models/banned_user_model.dart';
import 'package:mioamoreadmin/providers/banned_users_provider.dart';
import 'package:mioamoreadmin/providers/user_reports_provider.dart';
import 'package:mioamoreadmin/views/others/other_widgets.dart';
import 'package:mioamoreadmin/views/tabs/users/user_short_card.dart';

class ReportsPage extends ConsumerWidget {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allReportsRef = ref.watch(allReportsProvider);

    return NavigationView(
      appBar: const NavigationAppBar(
        title: Row(
          children: [
            Text('Reports'),
            SizedBox(width: 16),
          ],
        ),
        leading: Icon(FluentIcons.list),
      ),
      content: allReportsRef.when(
        data: (data) {
          data.sort((a, b) => b.reportsCount.compareTo(a.reportsCount));

          if (data.isEmpty) {
            return const Center(
              child: Text('No reports'),
            );
          } else {
            return ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: data.length,
              itemBuilder: (context, index) {
                final userReports = data[index];
                return Card(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Expanded(
                        child: UserShortCard(userId: userReports.userId),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        '${userReports.reportsCount} ${userReports.reportsCount == 1 ? 'report' : 'reports'}',
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 16),
                      FilledButton(
                        child: const Text('Ban User'),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return BanUserDialog(userId: userReports.userId);
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

class BanUserDialog extends ConsumerStatefulWidget {
  final String userId;
  const BanUserDialog({
    super.key,
    required this.userId,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _BanUserDialogState();
}

class _BanUserDialogState extends ConsumerState<BanUserDialog> {
  int? _banDays;
  bool _isLifetimeBan = false;

  @override
  Widget build(BuildContext context) {
    return ContentDialog(
      title: const Text('Ban User'),
      content: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Are you sure you want to ban this user?'),
            const SizedBox(height: 16),
            const Text('Ban for:'),
            Wrap(
              children: _banForDays
                  .map(
                    (days) => Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: material.ChoiceChip(
                        selectedColor: Colors.blue,
                        label: Text('$days ${days == 1 ? 'day' : 'days'}'),
                        selected: _banDays == days,
                        onSelected: (selected) {
                          setState(() {
                            _banDays = selected ? days : null;
                          });
                        },
                      ),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 16),
            Checkbox(
                checked: _isLifetimeBan,
                content: const Text('Ban for life'),
                onChanged: (value) {
                  setState(() {
                    _isLifetimeBan = value!;
                  });
                })
          ],
        ),
      ),
      actions: [
        FilledButton(
            child: const Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop();
            }),
        FilledButton(
          child: const Text('Ban'),
          onPressed: () async {
            if (_banDays == null) {
              EasyLoading.showInfo('Please select a ban duration');
            } else {
              final DateTime now = DateTime.now();
              final DateTime bannedUntil = now.add(Duration(days: _banDays!));

              final BannedUserModel model = BannedUserModel(
                userId: widget.userId,
                bannedAt: now,
                bannedUntil: bannedUntil,
                isLifetimeBan: _isLifetimeBan,
              );

              EasyLoading.show(status: 'Banning user...');
              await BanUserProvider.banUser(model).then((value) async {
                if (value) {
                  ref.invalidate(bannedUsersProvider);
                  EasyLoading.show(status: 'Deleting reports...');
                  await UserReportsProvider.deleteReports(widget.userId)
                      .then((value) {
                    if (value) {
                      ref.invalidate(allReportsProvider);
                      EasyLoading.dismiss();
                      Navigator.of(context).pop();
                    } else {
                      EasyLoading.showError('Failed to delete reports');
                    }
                  });
                } else {
                  EasyLoading.showError('Failed to ban user');
                }
              });
            }
          },
        ),
      ],
    );
  }
}

List<int> _banForDays = [1, 3, 7, 14, 30, 60, 90, 180, 365];
