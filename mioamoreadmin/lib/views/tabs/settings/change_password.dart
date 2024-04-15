import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mioamoreadmin/helpers/demo_constants.dart';
import 'package:mioamoreadmin/providers/auth_provider.dart';

class ChangePasswordDialog extends ConsumerStatefulWidget {
  const ChangePasswordDialog({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ChangePasswordState();
}

class _ChangePasswordState extends ConsumerState<ChangePasswordDialog> {
  final _formKey = GlobalKey<FormState>();
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return ContentDialog(
      title: const Text('Change Password'),
      content: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormBox(
                controller: _oldPasswordController,
                // header: "Old Password",
                placeholder: "Enter your old password",
                obscureText: true,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter your old password';
                  } else if (value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormBox(
                controller: _newPasswordController,
                // header: "New Password",
                placeholder: "Enter your new password",
                obscureText: true,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter your new password';
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
                placeholder: "Confirm your new password",
                obscureText: true,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please confirm your new password';
                  } else if (value != _newPasswordController.text) {
                    return 'Passwords do not match';
                  } else if (value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),
            ],
          ),
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
              if (DemoConstants.isDemo) {
                EasyLoading.showInfo(
                    'This feature is not available for public demo!');
              } else {
                await AuthProvider.verifyPassword(
                        password: _oldPasswordController.text.trim())
                    .then((value) async {
                  if (value) {
                    await AuthProvider.changePassword(
                            password: _newPasswordController.text.trim())
                        .then((value) {
                      if (value) {
                        Navigator.of(context).pop();
                      }
                    });
                  }
                });
              }
            }
          },
          child: const Text('Update'),
        ),
      ],
    );
  }
}
