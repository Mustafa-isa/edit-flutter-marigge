import 'package:cached_network_image/cached_network_image.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' as material;
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mioamoreadmin/models/verification_form_model.dart';
import 'package:mioamoreadmin/providers/user_profiles_provider.dart';
import 'package:mioamoreadmin/providers/user_verification_forms_provider.dart';
import 'package:mioamoreadmin/views/tabs/users/user_short_card.dart';

class VerificationDetailsPage extends ConsumerStatefulWidget {
  final VerificationFormModel form;

  const VerificationDetailsPage({
    super.key,
    required this.form,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _VerificationDetailsPageState();
}

class _VerificationDetailsPageState
    extends ConsumerState<VerificationDetailsPage> {
  late VerificationFormModel form;
  final _statusMessageController = TextEditingController();

  @override
  void initState() {
    form = widget.form;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return NavigationView(
      appBar: const NavigationAppBar(title: Text('Verification Action')),
      content: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 300,
                child: Card(child: UserShortCard(userId: form.userId)),
              ),
              const SizedBox(height: 24),
              const Text("ID Images"),
              const SizedBox(height: 8),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  CachedNetworkImage(
                    imageUrl: form.photoIdFrontViewUrl,
                    width: 300,
                    fit: BoxFit.fitWidth,
                  ),
                  CachedNetworkImage(
                    imageUrl: form.photoIdBackViewUrl,
                    width: 300,
                    fit: BoxFit.fitWidth,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text("Selfie Image"),
              const SizedBox(height: 8),
              CachedNetworkImage(
                imageUrl: form.selfieUrl,
                width: 300,
                fit: BoxFit.fitWidth,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: 400,
                child: TextBox(
                  controller: _statusMessageController,
                  placeholder: "Status Message",
                  maxLines: 5,
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  FilledButton(
                    child: const Text("Approve"),
                    onPressed: () {
                      final VerificationFormModel newForm = form.copyWith(
                        statusMessage:
                            _statusMessageController.text.trim().isEmpty
                                ? null
                                : _statusMessageController.text.trim(),
                        isApproved: true,
                        isPending: false,
                      );

                      showDialog(
                        context: context,
                        builder: (context) {
                          return ContentDialog(
                            title: const Text("Approve Verification"),
                            content: const Text(
                                "Are you sure you want to approve this verification?"),
                            actions: [
                              HyperlinkButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text("Cancel"),
                              ),
                              HyperlinkButton(
                                onPressed: () async {
                                  EasyLoading.show(status: 'Updating...');
                                  await VerificationProvider.updateForm(newForm)
                                      .then((value) async {
                                    if (value) {
                                      await UserProfileProvider.verifyUser(
                                              form.userId)
                                          .then((value) {
                                        if (value) {
                                          EasyLoading.showSuccess('Updated!');
                                          ref.invalidate(userProfileProvider(
                                              newForm.userId));
                                          Navigator.of(context).pop();
                                        }
                                      });
                                    } else {
                                      EasyLoading.showError(
                                          'Failed to update Form!');
                                    }
                                  });
                                },
                                child: const Text("Approve"),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                  FilledButton(
                    style: ButtonStyle(
                      backgroundColor: ButtonState.all(material.Colors.red),
                    ),
                    child: const Text("Reject"),
                    onPressed: () {
                      final VerificationFormModel newForm = form.copyWith(
                        statusMessage:
                            _statusMessageController.text.trim().isEmpty
                                ? null
                                : _statusMessageController.text.trim(),
                        isApproved: false,
                        isPending: false,
                      );

                      showDialog(
                        context: context,
                        builder: (context) {
                          return ContentDialog(
                            title: const Text("Reject Verification"),
                            content: const Text(
                                "Are you sure you want to reject this verification?"),
                            actions: [
                              HyperlinkButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text("Cancel"),
                              ),
                              HyperlinkButton(
                                onPressed: () async {
                                  EasyLoading.show(status: 'Updating...');
                                  await VerificationProvider.updateForm(newForm)
                                      .then((value) {
                                    if (value) {
                                      EasyLoading.showSuccess('Updated!');
                                      ref.invalidate(
                                          userProfileProvider(newForm.userId));
                                      Navigator.of(context).pop();
                                    } else {
                                      EasyLoading.showError(
                                          'Failed to update Form!');
                                    }
                                  });
                                },
                                child: const Text("Reject"),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
