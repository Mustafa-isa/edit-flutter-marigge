import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mioamoreadmin/helpers/demo_constants.dart';
import 'package:mioamoreadmin/helpers/email_verifier.dart';
import 'package:mioamoreadmin/models/admin_model.dart';
import 'package:mioamoreadmin/providers/admin_provider.dart';
import 'package:mioamoreadmin/providers/auth_provider.dart';

class ChangeEmailDialog extends ConsumerStatefulWidget {
  final AdminModel admin;
  const ChangeEmailDialog({
    super.key,
    required this.admin,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ChangeEmailDialogState();
}

class _ChangeEmailDialogState extends ConsumerState<ChangeEmailDialog> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return ContentDialog(
      title: const Text('Change Email'),
      content: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormBox(
                controller: _emailController,
                // header: "Email",
                placeholder: "Enter your new email",
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter your email';
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
                placeholder: "Enter your current password",
                obscureText: true,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter your password';
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
                        password: _passwordController.text.trim())
                    .then((value) async {
                  if (value) {
                    await AuthProvider.changeEmail(
                            email: _emailController.text.trim())
                        .then((value) async {
                      if (value) {
                        final AdminModel newModel = widget.admin.copyWith(
                          email: _emailController.text.trim(),
                        );
                        await AdminProvider.updateAdmin(admin: newModel)
                            .then((value) {
                          if (value) {
                            ref.invalidate(currentAdminProvider);
                            Navigator.of(context).pop();
                          }
                        });
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
