import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mioamoreadmin/models/app_settings_model.dart';
import 'package:mioamoreadmin/providers/app_settings_provider.dart';

class AppSettingsDialog extends ConsumerStatefulWidget {
  final AppSettingsModel? appSettingsModel;
  const AppSettingsDialog({
    super.key,
    this.appSettingsModel,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _AppSettingsPageState();
}

class _AppSettingsPageState extends ConsumerState<AppSettingsDialog> {
  late bool _isChattingEnabledBeforeMatch;

  @override
  void initState() {
    if (widget.appSettingsModel != null) {
      _isChattingEnabledBeforeMatch =
          widget.appSettingsModel!.isChattingEnabledBeforeMatch;
    } else {
      _isChattingEnabledBeforeMatch = false;
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return fluent.ContentDialog(
      title: const Text("App Settings"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SwitchListTile(
            title: const Text("Enable Chatting Before Match"),
            subtitle: const Text(
                "Enable this if you want users to chat before they match"),
            value: _isChattingEnabledBeforeMatch,
            onChanged: (value) {
              setState(() {
                _isChattingEnabledBeforeMatch = value;
              });
            },
          ),

          // Save Button
        ],
      ),
      actions: [
        fluent.HyperlinkButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        fluent.HyperlinkButton(
          onPressed: () async {
            AppSettingsModel appSettingsModel = AppSettingsModel(
              isChattingEnabledBeforeMatch: _isChattingEnabledBeforeMatch,
            );

            await AppSettingsProvider.addAppSettings(appSettingsModel)
                .then((value) {
              ref.invalidate(appSettingsProvider);
              Navigator.of(context).pop();
            });
          },
          child: const Text('Update'),
        ),
      ],
    );
  }
}
