import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mioamoreadmin/models/verification_form_model.dart';
import 'package:mioamoreadmin/providers/user_verification_forms_provider.dart';
import 'package:mioamoreadmin/views/others/other_widgets.dart';
import 'package:mioamoreadmin/views/tabs/users/user_short_card.dart';
import 'package:mioamoreadmin/views/tabs/verifications/verification_details_page.dart';

class VerificationsPage extends ConsumerWidget {
  const VerificationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final verificationsref = ref.watch(pendingVerificationFormsStreamProvider);
    return NavigationView(
      appBar: const NavigationAppBar(
        title: Text('Verifications'),
        leading: Icon(FluentIcons.list),
      ),
      content: verificationsref.when(
        data: (data) {
          if (data.isEmpty) {
            return const Center(
              child: Text('No Pending Verifications'),
            );
          } else {
            return VerificationFormsBody(pendingForms: data);
          }
        },
        error: (error, stackTrace) => const MyErrorWidget(),
        loading: () => const MyLoadingWidget(),
      ),
    );
  }
}

class VerificationFormsBody extends ConsumerWidget {
  final List<VerificationFormModel> pendingForms;
  const VerificationFormsBody({
    super.key,
    required this.pendingForms,
  });

  @override
  Widget build(BuildContext context, ref) {
    pendingForms.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: pendingForms.length,
      itemBuilder: (context, index) {
        final form = pendingForms[index];
        return Card(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                child: UserShortCard(userId: form.userId),
              ),
              const Spacer(),
              const SizedBox(width: 16),
              Text(
                'Pending Verification!',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 16),
              FilledButton(
                child: const Text("Take Action"),
                onPressed: () {
                  Navigator.of(context).push(FluentPageRoute(
                    builder: (context) {
                      return VerificationDetailsPage(form: form);
                    },
                  ));
                },
              ),
              const SizedBox(width: 16),
            ],
          ),
        );
      },
    );
  }
}
