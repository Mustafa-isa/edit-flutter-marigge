import 'package:cached_network_image/cached_network_image.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mioamoreadmin/helpers/date_formater.dart';
import 'package:mioamoreadmin/models/admin_model.dart';
import 'package:mioamoreadmin/models/user_profile_model.dart';
import 'package:mioamoreadmin/providers/admin_provider.dart';
import 'package:mioamoreadmin/providers/user_profiles_provider.dart';
import 'package:mioamoreadmin/providers/user_reports_provider.dart';
import 'package:mioamoreadmin/views/others/other_widgets.dart';
import 'package:mioamoreadmin/views/tabs/reports/reports_page.dart';
import 'package:mioamoreadmin/views/tabs/users/user_short_card.dart';

class UserDetailsPage extends ConsumerStatefulWidget {
  final String userId;
  const UserDetailsPage({
    super.key,
    required this.userId,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _UserDetailsPageState();
}

class _UserDetailsPageState extends ConsumerState<UserDetailsPage> {
  @override
  Widget build(BuildContext context) {
    final userProfileRef = ref.watch(userProfileProvider(widget.userId));
    final currentAdminRef = ref.watch(currentAdminProvider);

    return userProfileRef.when(
      data: (profile) {
        return NavigationView(
          appBar: NavigationAppBar(
            title: Row(
              children: [
                Text(profile.fullName),
                const SizedBox(width: 16),
                IconButton(
                  icon: const Icon(FluentIcons.refresh),
                  onPressed: () {
                    ref.invalidate(userProfileProvider(widget.userId));
                    ref.invalidate(userReportsProvider(widget.userId));
                  },
                )
              ],
            ),
          ),
          content: Align(
            alignment: Alignment.topLeft,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  UserDetailsProfileCard(profile: profile),
                  UserDetailsAccountSettingsCard(profile: profile),
                  currentAdminRef.when(
                    data: (data) {
                      if (data != null &&
                          data.permissions.contains(reportPermission)) {
                        return UserDetailsReportsSection(
                            userId: profile.userId);
                      } else {
                        return const SizedBox();
                      }
                    },
                    error: (error, stackTrace) => const SizedBox(),
                    loading: () => const SizedBox(),
                  )
                ],
              ),
            ),
          ),
        );
      },
      error: (error, stackTrace) => const MyErrorWidget(),
      loading: () => const MyLoadingWidget(),
    );
  }
}

class UserDetailsAccountSettingsCard extends StatelessWidget {
  final UserProfileModel profile;
  const UserDetailsAccountSettingsCard({
    Key? key,
    required this.profile,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 400,
      child: Card(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "User Account Settings",
              style: FluentTheme.of(context).typography.subtitle,
            ),
            const SizedBox(height: 16),
            // const TextBox(
            //   readOnly: true,
            //   // header: 'Location',
            //   maxLines: null,
            //   // initialValue:
            //   // profile.userAccountSettingsModel.location.addressText,

            // ),
            ListTile.selectable(
              title: const Text("Location"),
              subtitle: Text(
                profile.userAccountSettingsModel.location.addressText,
              ),
              selected: true,
            ),
            const SizedBox(height: 8),
            // const TextBox(
            //   readOnly: true,
            //   // header: "Interested In",
            //   // initialValue:
            //   // profile.userAccountSettingsModel.interestedIn ?? "All",
            // ),
            ListTile.selectable(
              title: const Text("Interested In"),
              subtitle: Text(
                profile.userAccountSettingsModel.interestedIn ?? "All",
              ),
              selected: true,
            ),
            const SizedBox(height: 8),
            // const TextBox(
            //   readOnly: true,
            //   // header: "Age Range",
            //   // initialValue:
            //   // "${profile.userAccountSettingsModel.minimumAge} - ${profile.userAccountSettingsModel.maximumAge}",
            // ),
            ListTile.selectable(
              title: const Text("Age Range"),
              subtitle: Text(
                "${profile.userAccountSettingsModel.minimumAge} - ${profile.userAccountSettingsModel.maximumAge}",
              ),
              selected: true,
            ),
            const SizedBox(height: 8),
            // Distance Range
            // const TextBox(
            //   readOnly: true,
            //   // header: "Distance Radius",
            //   // initialValue:
            //   // "${profile.userAccountSettingsModel.distanceInKm ?? "Unknown"} km",
            // ),
            ListTile.selectable(
              title: const Text("Distance Radius"),
              subtitle: Text(
                "${profile.userAccountSettingsModel.distanceInKm ?? "Unknown"} km",
              ),
              selected: true,
            ),
          ],
        ),
      ),
    );
  }
}

class UserDetailsProfileCard extends StatelessWidget {
  final UserProfileModel profile;
  const UserDetailsProfileCard({
    Key? key,
    required this.profile,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 500,
      child: Card(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "User Details",
              style: FluentTheme.of(context).typography.subtitle,
            ),
            const SizedBox(height: 16),
            if (profile.profilePicture != null)
              Center(
                child: CircleAvatar(
                  backgroundImage: CachedNetworkImageProvider(
                    profile.profilePicture!,
                  ),
                  radius: 70,
                ),
              ),
            if (profile.profilePicture == null)
              Center(
                child: CircleAvatar(
                  radius: 50,
                  child: Text(
                    profile.fullName[0],
                    style: const TextStyle(fontSize: 30),
                  ),
                ),
              ),
            const SizedBox(height: 8),
            Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      spreadRadius: 2,
                      offset: const Offset(0, 2),
                    ),
                  ],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      profile.isVerified
                          ? FluentIcons.verified_brand_solid
                          : FluentIcons.clear,
                      color: profile.isVerified ? Colors.green : Colors.red,
                    ),
                    const SizedBox(width: 16),
                    Text(
                      profile.isVerified ? "Verified" : "Not Verified",
                      style: FluentTheme.of(context).typography.bodyStrong,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // const TextBox(
            //   readOnly: true,
            //   // header: 'Full Name',
            //   // initialValue: profile.fullName,
            // ),
            ListTile.selectable(
              title: const Text("Full Name"),
              subtitle: Text(profile.fullName),
              selected: true,
            ),
            const SizedBox(height: 8),
            // const TextBox(
            //   readOnly: true,
            //   // header: 'Email',
            //   // initialValue: profile.email,
            // ),
            ListTile.selectable(
              title: const Text("Email"),
              subtitle: Text(profile.email ?? "Unknown"),
              selected: true,
            ),
            const SizedBox(height: 8),
            // const TextBox(
            //   readOnly: true,
            //   // header: 'Phone Number',
            //   // initialValue: profile.phoneNumber,
            // ),
            ListTile.selectable(
              title: const Text("Phone Number"),
              subtitle: Text(profile.phoneNumber ?? "Unknown"),
              selected: true,
            ),
            const SizedBox(height: 8),
            // const TextBox(
            //   readOnly: true,
            //   maxLines: null,
            //   // header: 'About',
            //   // initialValue: profile.about,
            // ),
            ListTile.selectable(
              title: const Text("About"),
              subtitle: Text(profile.about ?? "Unknown"),
              selected: true,
            ),
            const SizedBox(height: 8),
            // const TextBox(
            //   readOnly: true,
            //   // initialValue: profile.interests.join(', '),
            //   // header: 'Interests',
            // ),
            ListTile.selectable(
              title: const Text("Interests"),
              subtitle: Text(profile.interests.join(', ')),
              selected: true,
            ),
            const SizedBox(height: 8),
            const Text("Images"),
            const SizedBox(height: 8),
            Wrap(
              alignment: WrapAlignment.start,
              spacing: 4,
              runSpacing: 4,
              children: profile.mediaFiles
                  .map(
                    (e) => CachedNetworkImage(
                      imageUrl: e,
                      width: 200,
                      height: 250,
                      fit: BoxFit.cover,
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class UserDetailsReportsSection extends ConsumerWidget {
  final String userId;
  const UserDetailsReportsSection({
    super.key,
    required this.userId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userReportsRef = ref.watch(userReportsProvider(userId));
    return SizedBox(
      width: 400,
      height: MediaQuery.of(context).size.height * 0.8,
      child: Card(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    "User Reports",
                    style: FluentTheme.of(context).typography.subtitle,
                  ),
                ),
                userReportsRef.when(
                  data: (data) {
                    return Row(
                      children: [
                        Text(
                          "Total: ${data.length}",
                          style: FluentTheme.of(context).typography.body,
                        ),
                        const SizedBox(width: 8),
                        if (data.isNotEmpty)
                          FilledButton(
                            child: const Text('Ban User'),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return BanUserDialog(userId: userId);
                                },
                              );
                            },
                          ),
                      ],
                    );
                  },
                  error: (error, stackTrace) {
                    return const SizedBox();
                  },
                  loading: () => const SizedBox(),
                )
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: userReportsRef.when(
                data: (data) {
                  if (data.isEmpty) {
                    return const Center(
                      child: Text(
                        "No reports found!",
                        textAlign: TextAlign.center,
                      ),
                    );
                  } else {
                    return ListView.builder(
                      itemCount: data.length,
                      itemBuilder: (context, index) {
                        final report = data[index];

                        return Card(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    "${index + 1}.",
                                    style: FluentTheme.of(context)
                                        .typography
                                        .bodyStrong,
                                  ),
                                  Expanded(
                                      child: UserShortCard(
                                          userId: report.reportedByUserId)),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Padding(
                                padding: const EdgeInsets.all(8),
                                child: Text(report.reason),
                              ),
                              if (report.images.isNotEmpty)
                                Wrap(
                                  spacing: 4,
                                  runSpacing: 4,
                                  children: report.images
                                      .map(
                                        (e) => CachedNetworkImage(
                                          imageUrl: e,
                                          width: 120,
                                          height: 180,
                                          fit: BoxFit.cover,
                                        ),
                                      )
                                      .toList(),
                                ),
                              Padding(
                                padding: const EdgeInsets.all(8),
                                child: Text(
                                  "Reported at: ${DateFormatter.toWholeDateTime(report.createdAt)}",
                                  style: FluentTheme.of(context)
                                      .typography
                                      .caption,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  }
                },
                error: (error, stackTrace) {
                  return const SizedBox();
                },
                loading: () => const Center(child: ProgressRing()),
              ),
            )
          ],
        ),
      ),
    );
  }
}
