import 'package:cached_network_image/cached_network_image.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mioamoreadmin/providers/user_profiles_provider.dart';
import 'package:mioamoreadmin/views/tabs/users/user_details_page.dart';

class UserShortCard extends ConsumerWidget {
  final String userId;
  const UserShortCard({
    super.key,
    required this.userId,
  });

  @override
  Widget build(BuildContext context, ref) {
    final userRef = ref.watch(userProfileProvider(userId));

    return userRef.when(
      data: (user) {
        return ListTile(
          onPressed: () {
            Navigator.of(context).push(FluentPageRoute(
              builder: (context) {
                return UserDetailsPage(userId: userId);
              },
            ));
          },
          title: Row(
            children: [
              Text(user.fullName),
              const SizedBox(width: 8),
              user.isVerified
                  ? Icon(
                      FluentIcons.verified_brand_solid,
                      color: Colors.green,
                      size: 14,
                    )
                  : Icon(
                      FluentIcons.clear,
                      color: Colors.red,
                      size: 14,
                    )
            ],
          ),
          leading: CircleAvatar(
            radius: 16,
            backgroundImage: user.profilePicture != null
                ? CachedNetworkImageProvider(user.profilePicture!)
                : null,
            child: user.profilePicture == null ? Text(user.fullName[0]) : null,
          ),
          subtitle: Text(user.gender.toUpperCase()),
        );
      },
      error: (error, stackTrace) => const Text("Error loading user!"),
      loading: () => const Text("Loading..."),
    );
  }
}
