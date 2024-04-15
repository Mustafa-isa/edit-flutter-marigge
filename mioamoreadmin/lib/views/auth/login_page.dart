import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' as material;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mioamoreadmin/config/config.dart';
import 'package:mioamoreadmin/helpers/demo_constants.dart';
import 'package:mioamoreadmin/helpers/email_verifier.dart';
import 'package:mioamoreadmin/providers/admin_provider.dart';
import 'package:mioamoreadmin/providers/auth_provider.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _showPassword = false;

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
                    'Login',
                    textAlign: TextAlign.center,
                    style: FluentTheme.of(context).typography.bodyStrong,
                  ),
                  const SizedBox(height: 24),
                  material.TextFormField(
                    controller: _emailController,
                    autofillHints: const <String>[AutofillHints.email],
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
                      } else if (!value.contains('@') || !value.contains('.')) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  material.TextFormField(
                    controller: _passwordController,
                    autofillHints: const <String>[AutofillHints.password],
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
                  const SizedBox(height: 24),
                  FilledButton(
                    child: const Padding(
                      padding: EdgeInsets.all(16 / 2),
                      child: Text("Login"),
                    ),
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        await AuthProvider.loginWithEmailAndPass(
                          email: _emailController.text.trim(),
                          password: _passwordController.text.trim(),
                        ).then((value) {
                          if (value != null) {
                            ref.invalidate(isUserAdminProvider(value.uid));
                          }
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Forgot password?',
                    textAlign: TextAlign.center,
                    style: FluentTheme.of(context).typography.body,
                  ),
                  HyperlinkButton(
                    onPressed: () {
                      showDialog(
                          context: context,
                          builder: (context) => const ResetPasswordForm());
                    },
                    child: const Text('Reset here'),
                  ),
                  const SizedBox(height: 16),
                  if (DemoConstants.isDemo)
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Demo Email: ",
                                style:
                                    FluentTheme.of(context).typography.caption),
                            Flexible(
                              child: SelectableText(
                                  "incevio.mioamore@gmail.com",
                                  style: FluentTheme.of(context)
                                      .typography
                                      .body!
                                      .copyWith(fontWeight: FontWeight.bold)),
                            ),
                            IconButton(
                                icon: const Icon(FluentIcons.copy),
                                onPressed: () {
                                  _emailController.text =
                                      "incevio.mioamore@gmail.com";
                                })
                          ],
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Demo Password: ",
                                style:
                                    FluentTheme.of(context).typography.caption),
                            Flexible(
                              child: SelectableText("mioamore",
                                  style: FluentTheme.of(context)
                                      .typography
                                      .body!
                                      .copyWith(fontWeight: FontWeight.bold)),
                            ),
                            IconButton(
                                icon: const Icon(FluentIcons.copy),
                                onPressed: () {
                                  _passwordController.text = "mioamore";
                                })
                          ],
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class LogoWiget extends StatelessWidget {
  const LogoWiget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 16),
        Image.asset(
          'assets/logo/logo.jpg',
          width: 100,
          height: 100,
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

class ResetPasswordForm extends ConsumerStatefulWidget {
  const ResetPasswordForm({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ResetPasswordFormState();
}

class _ResetPasswordFormState extends ConsumerState<ResetPasswordForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return ContentDialog(
      title: const Text('Reset Password'),
      content: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: TextFormBox(
            controller: _emailController,
            placeholder: "Enter your email",
            validator: (value) {
              if (value!.isEmpty) {
                return 'Please enter your email';
              } else if (emailVerifier().hasMatch(value) == false) {
                return 'Please enter a valid email';
              }
              return null;
            },
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
              await AuthProvider.forgotPassword(
                      email: _emailController.text.trim())
                  .then((value) {
                Navigator.of(context).pop();
              });
            }
          },
          child: const Text('Reset'),
        ),
      ],
    );
  }
}
