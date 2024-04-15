import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mioamoreadmin/models/admin_model.dart';
import 'package:mioamoreadmin/providers/admin_provider.dart';

class ChangeNameDialog extends ConsumerStatefulWidget {
  final AdminModel admin;
  const ChangeNameDialog({
    super.key,
    required this.admin,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ChangeNameDialogState();
}

class _ChangeNameDialogState extends ConsumerState<ChangeNameDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  @override
  void initState() {
    _nameController.text = widget.admin.name;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ContentDialog(
      title: const Text('Change Name'),
      content: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: TextFormBox(
            controller: _nameController,
            // header: "Name",
            placeholder: "Enter your name",
            validator: (value) {
              if (value!.isEmpty) {
                return 'Please enter your name';
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
              final AdminModel newModel = widget.admin.copyWith(
                name: _nameController.text.trim(),
              );

              EasyLoading.show(status: 'Saving...');
              await AdminProvider.updateAdmin(admin: newModel).then((value) {
                if (value) {
                  EasyLoading.dismiss();
                  ref.invalidate(currentAdminProvider);
                  Navigator.of(context).pop();
                } else {
                  EasyLoading.showError('Failed to save');
                }
              });
            }
          },
          child: const Text('Update'),
        ),
      ],
    );
  }
}
