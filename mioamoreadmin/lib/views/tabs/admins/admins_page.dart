import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mioamoreadmin/helpers/email_verifier.dart';
import 'package:mioamoreadmin/models/admin_model.dart';
import 'package:mioamoreadmin/providers/admin_provider.dart';
import 'package:mioamoreadmin/providers/auth_provider.dart';
import 'package:mioamoreadmin/views/others/other_widgets.dart';

class AdminsPage extends ConsumerWidget {
  const AdminsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final adminsRef = ref.watch(allAdminsProviderProvider);

    return NavigationView(
      appBar: NavigationAppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Admins'),
            const SizedBox(width: 16),
            IconButton(
              icon: const Icon(FluentIcons.add),
              onPressed: () async {
                showDialog(
                    context: context,
                    builder: (context) => const CreateNewAdminPopup());
              },
            ),
          ],
        ),
        leading: const Icon(FluentIcons.people),
      ),
      content: adminsRef.when(
        data: (data) {
          if (data.isEmpty) {
            return const Center(
              child: Text('No admins found'),
            );
          } else {
            return ListView.separated(
              itemCount: data.length,
              itemBuilder: (context, index) {
                final admin = data[index];
                return Card(
                  child: ListTile(
                    title: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(admin.name),
                          const SizedBox(width: 8),
                          Text(
                            "[${admin.permissions.isEmpty ? "Only Insights" : admin.permissions.join(', ')}]",
                            style: FluentTheme.of(context).typography.caption,
                          )
                        ],
                      ),
                    ),
                    subtitle: Text(admin.email),
                    trailing: const Icon(FluentIcons.chevron_right),
                    onPressed: () async {
                      showDialog(
                          context: context,
                          builder: (context) =>
                              EditAdminPermission(admin: admin));
                    },
                  ),
                );
              },
              separatorBuilder: (context, index) => const Divider(),
            );
          }
        },
        error: (error, stackTrace) => const MyErrorWidget(),
        loading: () => const MyLoadingWidget(),
      ),
    );
  }
}

class CreateNewAdminPopup extends ConsumerStatefulWidget {
  const CreateNewAdminPopup({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _CreateNewAdminPopupState();
}

class _CreateNewAdminPopupState extends ConsumerState<CreateNewAdminPopup> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final List<String> _adminPermissions = [];

  @override
  Widget build(BuildContext context) {
    return ContentDialog(
      title: const Text('Create New Admin'),
      content: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormBox(
              controller: _nameController,
              // header: "Name",
              placeholder: 'Enter name',
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Please enter a name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormBox(
              controller: _emailController,
              // header: "Email",
              placeholder: 'Enter email',
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Please enter an email';
                } else if (emailVerifier().hasMatch(value) == false) {
                  return 'Please enter a valid email';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormBox(
              controller: _passwordController,
              // header: "Password",
              obscureText: true,
              placeholder: 'Enter password',
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Please enter a password';
                } else if (value.length < 6) {
                  return 'Password must be at least 6 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormBox(
              controller: _confirmPasswordController,
              // header: "Confirm Password",
              obscureText: true,
              placeholder: 'Confirm password',
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Please confirm your password';
                } else if (value != _passwordController.text) {
                  return 'Passwords do not match';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            Text(
              "Permissions",
              style: FluentTheme.of(context).typography.bodyStrong,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: permissions.map(
                (e) {
                  return Checkbox(
                    checked: _adminPermissions.contains(e),
                    content: Text(e),
                    onChanged: (value) {
                      setState(() {
                        if (value!) {
                          _adminPermissions.add(e);
                        } else {
                          _adminPermissions.remove(e);
                        }
                      });
                    },
                  );
                },
              ).toList(),
            ),
          ],
        ),
      ),
      actions: [
        HyperlinkButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        HyperlinkButton(
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              await AuthProvider.registerNewAdmin(
                      email: _emailController.text.trim(),
                      password: _passwordController.text.trim())
                  .then((value) async {
                if (value != null) {
                  EasyLoading.show(status: "Saving Admin...");

                  final AdminModel newAdmin = AdminModel(
                    id: value.uid,
                    name: _nameController.text.trim(),
                    email: _emailController.text.trim(),
                    permissions: _adminPermissions,
                    isSuperAdmin: false,
                    createdAt: DateTime.now(),
                  );

                  await AdminProvider.addAdmin(admin: newAdmin).then((value) {
                    EasyLoading.dismiss();
                    ref.invalidate(allAdminsProviderProvider);
                    Navigator.of(context).pop();
                  });
                }
              });
            }
          },
          child: const Text('Create'),
        ),
      ],
    );
  }
}

class EditAdminPermission extends ConsumerStatefulWidget {
  final AdminModel admin;
  const EditAdminPermission({
    super.key,
    required this.admin,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _EditAdminPermissionState();
}

class _EditAdminPermissionState extends ConsumerState<EditAdminPermission> {
  final List<String> _adminPermissions = [];

  @override
  void initState() {
    _adminPermissions.addAll(widget.admin.permissions);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ContentDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Edit Admin Permissions',
            style: FluentTheme.of(context).typography.subtitle,
          ),
          IconButton(
            icon: const Icon(FluentIcons.delete),
            style: ButtonStyle(
              backgroundColor: ButtonState.all(Colors.red),
              foregroundColor: ButtonState.all(Colors.white),
            ),
            onPressed: () async {
              showDialog(
                context: context,
                builder: (context) {
                  return ContentDialog(
                    title: const Text('Delete Admin'),
                    content: const Text(
                        'Are you sure you want to delete this admin?'),
                    actions: [
                      HyperlinkButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('Cancel'),
                      ),
                      HyperlinkButton(
                        onPressed: () async {
                          EasyLoading.show(status: "Deleting Admin...");
                          await AdminProvider.deleteAdmin(
                                  adminId: widget.admin.id)
                              .then((value) {
                            EasyLoading.dismiss();
                            ref.invalidate(allAdminsProviderProvider);
                            Navigator.of(context).pop();
                            Navigator.of(context).pop();
                          });
                        },
                        child: const Text('Delete'),
                      ),
                    ],
                  );
                },
              );
            },
          )
        ],
      ),
      content: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Name: ${widget.admin.name}",
              style: FluentTheme.of(context).typography.bodyStrong,
            ),
            const SizedBox(height: 16),
            Text(
              "Permissions",
              style: FluentTheme.of(context).typography.bodyStrong,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: permissions.map(
                (e) {
                  return Checkbox(
                    checked: _adminPermissions.contains(e),
                    content: Text(e),
                    onChanged: (value) {
                      setState(() {
                        if (value!) {
                          _adminPermissions.add(e);
                        } else {
                          _adminPermissions.remove(e);
                        }
                      });
                    },
                  );
                },
              ).toList(),
            ),
          ],
        ),
      ),
      actions: [
        HyperlinkButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        HyperlinkButton(
          onPressed: () async {
            EasyLoading.show(status: "Saving Admin...");

            final AdminModel newAdmin =
                widget.admin.copyWith(permissions: _adminPermissions);

            await AdminProvider.updateAdmin(admin: newAdmin).then((value) {
              EasyLoading.dismiss();
              ref.invalidate(allAdminsProviderProvider);
              Navigator.of(context).pop();
            });
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
