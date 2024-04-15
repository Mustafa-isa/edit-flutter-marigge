import 'package:cached_network_image/cached_network_image.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' as material;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mioamoreadmin/models/user_profile_model.dart';
import 'package:mioamoreadmin/providers/user_profiles_provider.dart';
import 'package:mioamoreadmin/views/others/other_widgets.dart';
import 'package:mioamoreadmin/views/tabs/users/user_details_page.dart';

class UsersPage extends ConsumerStatefulWidget {
  const UsersPage({super.key});

  @override
  ConsumerState<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends ConsumerState<UsersPage> {
  final _searchController = TextEditingController();
  bool _sortAscending = true;
  @override
  Widget build(BuildContext context) {
    final totalUsersRef = ref.watch(usersShortStreamProvider);

    return NavigationView(
      appBar: NavigationAppBar(
        title: const Text('Users'),
        leading: const Icon(FluentIcons.people),
        actions: Align(
          alignment: Alignment.centerRight,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 200,
                child: TextBox(
                  controller: _searchController,
                  onChanged: (value) {
                    if (value.isEmpty) {
                      setState(() {});
                    } else if (value.length > 2) {
                      setState(() {});
                    }
                  },
                  placeholder: 'Search By Name',
                ),
              ),
              const SizedBox(width: 16),
              totalUsersRef.when(
                data: (totalUsers) => Text('Total ${totalUsers.length} users'),
                loading: () => const SizedBox(),
                error: (error, stack) => const SizedBox(),
              ),
              const SizedBox(width: 16),
            ],
          ),
        ),
      ),
      content: totalUsersRef.when(
        data: (totalUsers) {
          if (_searchController.text.isNotEmpty) {
            totalUsers = totalUsers
                .where((user) => user.fullName
                    .toLowerCase()
                    .contains(_searchController.text.toLowerCase()))
                .toList();
          }

          if (_sortAscending) {
            totalUsers.sort((a, b) => a.fullName.compareTo(b.fullName));
          } else {
            totalUsers.sort((a, b) => b.fullName.compareTo(a.fullName));
          }

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: DataTable2(
              columnSpacing: 16,
              horizontalMargin: 8,
              minWidth: 600,
              sortAscending: _sortAscending,
              sortColumnIndex: 1,
              columns: [
                const DataColumn2(label: Text("Order"), fixedWidth: 60),
                const DataColumn2(label: Text("Image"), fixedWidth: 100),
                DataColumn2(
                  label: const Text('Full Name'),
                  onSort: (i, b) {
                    setState(() {
                      _sortAscending = !_sortAscending;
                    });
                  },
                ),
                const DataColumn2(label: Text("Gender")),
                const DataColumn2(label: Text('Verification Status')),
                const DataColumn2(label: Text("View"), fixedWidth: 100)
              ],
              rows: List.generate(
                totalUsers.length,
                (index) {
                  final user = totalUsers[index];
                  return userDataRow(index, user);
                },
              ),
            ),
          );
        },
        loading: () => const MyLoadingWidget(),
        error: (error, stack) => const MyErrorWidget(),
      ),
    );
  }

  material.DataRow userDataRow(int index, UserProfileShortModel user) {
    return material.DataRow(
      cells: [
        material.DataCell(Text((index + 1).toString())),
        material.DataCell(
          Padding(
            padding: const EdgeInsets.all(4),
            child: user.profilePicture == null
                ? const Icon(FluentIcons.file_image, size: 20)
                : CachedNetworkImage(
                    imageUrl: user.profilePicture!,
                    imageBuilder: (context, imageProvider) => Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          image: imageProvider,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    placeholder: (context, url) => const ProgressRing(),
                    errorWidget: (context, url, error) =>
                        const Icon(FluentIcons.error),
                  ),
          ),
        ),
        material.DataCell(Text(user.fullName)),
        material.DataCell(Text(user.gender.toUpperCase())),
        material.DataCell(
          Text(
            user.isVerified ? 'Verified' : 'Not verified',
            style: TextStyle(
              color: user.isVerified ? Colors.green : Colors.red,
            ),
          ),
        ),
        material.DataCell(
          FilledButton(
            child: const Text("View"),
            onPressed: () {
              Navigator.of(context).push(FluentPageRoute(builder: (context) {
                return UserDetailsPage(userId: user.userId);
              }));
            },
          ),
        ),
      ],
    );
  }
}
