import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' as material;
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mioamoreadmin/config/config.dart';
import 'package:mioamoreadmin/models/admin_model.dart';
import 'package:mioamoreadmin/providers/admin_provider.dart';
import 'package:mioamoreadmin/providers/auth_provider.dart';
import 'package:mioamoreadmin/views/auth/login_page.dart';

class SuperAdminRegistrationPage extends ConsumerStatefulWidget {
  const SuperAdminRegistrationPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _SuperAdminRegistrationPageState();
}

class _SuperAdminRegistrationPageState
    extends ConsumerState<SuperAdminRegistrationPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _showPassword = false;
  bool _showConfirmPassword = false;

  @override
  Widget build(BuildContext context) {
    return NavigationView(
      content: Center(
        child: SizedBox(
          width: 400,
          child: Card(
            borderRadius: BorderRadius.circular(8),
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: AutofillGroup(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const LogoWiget(),
                    Text(
                      AppConstants.appName,
                      textAlign: TextAlign.center,
                      style: FluentTheme.of(context).typography.bodyStrong,
                    ),
                    const SizedBox(height: 32),
                    Text(
                      'Super Admin Registration',
                      textAlign: TextAlign.center,
                      style: FluentTheme.of(context).typography.bodyStrong,
                    ),
                    const SizedBox(height: 24),
                    material.TextFormField(
                      controller: _nameController,
                      textInputAction: TextInputAction.next,
                      decoration: material.InputDecoration(
                        labelText: 'Full Name',
                        labelStyle: FluentTheme.of(context).typography.body,
                        border: material.OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter your name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    material.TextFormField(
                      controller: _emailController,
                      textInputAction: TextInputAction.next,
                      decoration: material.InputDecoration(
                        labelText: 'Email',
                        labelStyle: FluentTheme.of(context).typography.body,
                        border: material.OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter your email';
                        } else if (!value.contains('@') ||
                            !value.contains('.')) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    material.TextFormField(
                      controller: _passwordController,
                      textInputAction: TextInputAction.done,
                      obscureText: !_showPassword,
                      decoration: material.InputDecoration(
                        labelText: 'Password',
                        labelStyle: FluentTheme.of(context).typography.body,
                        border: material.OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _showPassword
                                ? material.Icons.visibility
                                : material.Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              _showPassword = !_showPassword;
                            });
                          },
                        ),
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter your password';
                        } else if (value.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    material.TextFormField(
                      controller: _confirmPasswordController,
                      textInputAction: TextInputAction.done,
                      obscureText: !_showConfirmPassword,
                      decoration: material.InputDecoration(
                        labelText: 'Confirm Password',
                        labelStyle: FluentTheme.of(context).typography.body,
                        border: material.OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _showConfirmPassword
                                ? material.Icons.visibility
                                : material.Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              _showConfirmPassword = !_showConfirmPassword;
                            });
                          },
                        ),
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please confirm your password';
                        } else if (value != _passwordController.text) {
                          return 'Passwords do not match';
                        } else if (value.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    FilledButton(
                      child: const Padding(
                        padding: EdgeInsets.all(16 / 2),
                        child: Text("Register"),
                      ),
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          await AuthProvider.registerWithEmailAndPass(
                            email: _emailController.text.trim(),
                            password: _passwordController.text.trim(),
                          ).then((user) async {
                            if (user != null) {
                              EasyLoading.show(
                                  status: "Generating Super Admin...");

                              final AdminModel admin = AdminModel(
                                id: user.uid,
                                name: _nameController.text.trim(),
                                email: _emailController.text.trim(),
                                permissions: permissions,
                                isSuperAdmin: true,
                                createdAt: DateTime.now(),
                              );

                              await AdminProvider.addAdmin(admin: admin)
                                  .then((value) {
                                ref.invalidate(superAdminProvider);
                                ref.invalidate(isUserAdminProvider(user.uid));
                                EasyLoading.dismiss();
                              });
                            }
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
