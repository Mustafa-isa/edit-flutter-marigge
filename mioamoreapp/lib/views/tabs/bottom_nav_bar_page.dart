import 'package:animations/animations.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mioamoreapp/helpers/constants.dart';
import 'package:mioamoreapp/models/user_profile_model.dart';
import 'package:mioamoreapp/providers/banned_users_provider.dart';
import 'package:mioamoreapp/providers/match_provider.dart';
import 'package:mioamoreapp/providers/subscriptions/init_purchase_conf.dart';
import 'package:mioamoreapp/providers/user_profile_provider.dart';
import 'package:mioamoreapp/views/others/error_page.dart';
import 'package:mioamoreapp/views/others/loading_page.dart';
import 'package:mioamoreapp/views/others/user_is_banned_page.dart';
import 'package:mioamoreapp/views/tabs/matches/matches_page.dart';
import 'package:mioamoreapp/views/tabs/feeds/feeds_page.dart';
import 'package:mioamoreapp/views/tabs/home/home_page.dart';
import 'package:mioamoreapp/views/tabs/interactions/interactions_page.dart';
import 'package:mioamoreapp/views/tabs/messages/messages_page.dart';
import 'package:mioamoreapp/views/tabs/profile/first_time_update_profile_page.dart';

import '../../providers/notifiaction_provider.dart';
import '../custom/custom_icon_button.dart';
import 'home/notification_page.dart';

class BottomNavBarPage extends ConsumerStatefulWidget {
  final String userId;
  const BottomNavBarPage({Key? key, required this.userId}) : super(key: key);

  @override
  ConsumerState<BottomNavBarPage> createState() => _BottomNavBarPageState();
}

class _BottomNavBarPageState extends ConsumerState<BottomNavBarPage>
    with WidgetsBindingObserver {
  int _currentIndex = 0;

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    initPlatformStateForPurchases(widget.userId);
    super.initState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      setUserOnlineStatus(true);
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      setUserOnlineStatus(false);
    }

    super.didChangeAppLifecycleState(state);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void setUserOnlineStatus(bool status) async {
    final userRef = ref.watch(userProfileFutureProvider);

    UserProfileModel? newModel;

    userRef.whenData((value) {
      if (value != null) {
        if (value.userAccountSettingsModel.showOnlineStatus != false) {
          debugPrint("User Online Status: ${value.isOnline}");
          newModel = value.copyWith(isOnline: status);
        }
      }
    });

    if (newModel != null) {
      debugPrint("Updating user online status to $status");

      await ref.read(userProfileNotifier).updateUserProfile(newModel!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isUserAdded = ref.watch(isUserAddedProvider);
    final isMeBanned = ref.watch(isMeBannedProvider);

    return isMeBanned.when(
      data: (data) {
        bool isBanned = false;

        if (data == null) {
          isBanned = false;
        } else {
          if (data.bannedUntil.isAfter(DateTime.now())) {
            isBanned = true;
          } else if (data.isLifetimeBan) {
            isBanned = true;
          } else {
            isBanned = false;
          }
        }

        return isBanned
            ? UserIsBannedPage(bannedUserModel: data!)
            : isUserAdded.when(
                loading: () => const LoadingPage(),
                error: (e, _) => const ErrorPage(),
                data: (data) {
                  return data
                      ? Scaffold(
                          body: PageTransitionSwitcher(
                            duration: const Duration(milliseconds: 300),
                            transitionBuilder:
                                (child, primaryAnimation, secondaryAnimation) =>
                                    FadeThroughTransition(
                              fillColor:
                                  Theme.of(context).scaffoldBackgroundColor,
                              animation: primaryAnimation,
                              secondaryAnimation: secondaryAnimation,
                              child: child,
                            ),
                            child: _navItems[_currentIndex].page,
                          ),
                          bottomNavigationBar: Container(
                            decoration: BoxDecoration(
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(30),
                                topRight: Radius.circular(30),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  spreadRadius: 2,
                                  offset: const Offset(0, -5),
                                ),
                              ],
                              color: Colors.white,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  top: AppConstants.defaultNumericValue / 3),
                              child: BottomNavigationBar(
                                unselectedLabelStyle: const TextStyle(
                                    fontSize: 10, fontWeight: FontWeight.bold),
                                selectedLabelStyle: const TextStyle(
                                    fontSize: 11, fontWeight: FontWeight.bold),
                                backgroundColor: Colors.transparent,
                                elevation: 0,
                                type: BottomNavigationBarType.fixed,
                                currentIndex: _currentIndex,
                                unselectedItemColor: Colors.grey,
                                selectedItemColor: AppConstants.primaryColor,
                                onTap: (index) {
                                  setState(() {
                                    _currentIndex = index;
                                  });
                                },
                                items: _navItems.map((e) {
                                  return BottomNavigationBarItem(
                                    icon: _navItems.indexOf(e) == 2
                                        ? MessageConsumerBottomNavIcon(
                                            icon: e.icon)
                                        : Icon(e.icon),
                                    label: e.title,
                                    activeIcon: _navItems.indexOf(e) == 2
                                        ? MessageConsumerBottomNavIcon(
                                            icon: e.activeIcon)
                                        : Icon(e.activeIcon),
                                  );
                                }).toList(),

                              ),
                            ),
                          ),
                        )
                      : const FirstTimeUserProfilePage();
                },
              );
      },
      error: (error, stackTrace) => const ErrorPage(),
      loading: () => const LoadingPage(),
    );
  }
}

class _BottomNavBarItem {
  final String title;
  final IconData icon;
  final IconData activeIcon;
  final Widget page;
  _BottomNavBarItem({
    required this.title,
    required this.icon,
    required this.activeIcon,
    required this.page,
  });
}

final List<_BottomNavBarItem> _navItems = [
  _BottomNavBarItem(
    title: 'Home',
    icon: CupertinoIcons.home,
    activeIcon: CupertinoIcons.home,
    page: const HomePage(),
  ),
  //Explore
  /*
  _BottomNavBarItem(
    title: 'Feeds',

    icon: Icons.explore_outlined,
    activeIcon: Icons.explore,
    page: const FeedsPage(),
  ),

   */
  //Favourites
  _BottomNavBarItem(
    title: 'Matches',
    icon: CupertinoIcons.heart,
    activeIcon: CupertinoIcons.heart_solid,
    page: const MatchesConsumerPage(),
  ),
  //Messages
  _BottomNavBarItem(
    title: 'Message',
    icon: CupertinoIcons.mail,
    activeIcon: CupertinoIcons.mail_solid,
    page: const MessageConsumerPage(),
  ),
  //Proile
  _BottomNavBarItem(
    title: 'Interactions',
    icon: CupertinoIcons.cube_box,
    activeIcon: CupertinoIcons.cube_box_fill,
    page: const InteractionsPage(),
  ),

  _BottomNavBarItem(
    title: 'Interactions',
    icon:  CupertinoIcons.bell,
    /*
    margin: count > 0
        ? const EdgeInsets.only(
        right: AppConstants.defaultNumericValue / 3)
        : null,

     */
    activeIcon: CupertinoIcons.bell_fill,
    page: const NotificationPage(),
  ),
];
class NotificationButton extends ConsumerWidget {
  const NotificationButton({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, ref) {
    final matchingNotifications = ref.watch(notificationsStreamProvider);

    int count = 0;

    matchingNotifications.whenData((value) {
      for (var element in value) {
        if (element.isRead == false) {
          count++;
        }
      }
    });

    return Stack(
      children: [
        CustomIconButton(
          icon: CupertinoIcons.bell_solid,
          margin: count > 0
              ? const EdgeInsets.only(
              right: AppConstants.defaultNumericValue / 3)
              : null,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const NotificationPage(),
              ),
            );
          },
          padding: const EdgeInsets.all(AppConstants.defaultNumericValue / 1.5),
        ),
        if (count > 0)
          Positioned(
            bottom: 0,
            right: 0,
            child: Badge(
              backgroundColor: AppConstants.primaryColor,
              label: Text(
                count.toString(),
              ),
            ),
          ),
      ],
    );
  }
}

class MessageConsumerBottomNavIcon extends ConsumerWidget {
  final IconData icon;
  const MessageConsumerBottomNavIcon({
    Key? key,
    required this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final matchStream = ref.watch(matchStreamProvider);

    return matchStream.when(
      data: (data) {
        final List<MessageViewModel> messages = [];

        messages.addAll(getAllMessages(ref, data));
        int unreadCount = 0;
        for (var e in messages) {
          unreadCount += e.unreadCount;
        }

        return MessageIcon(unreadCount: unreadCount, icon: icon);
      },
      error: (_, __) => MessageIcon(unreadCount: 0, icon: icon),
      loading: () => MessageIcon(unreadCount: 0, icon: icon),
    );
  }
}
/*
class  NavegtionConsumerBottomNavIcon extends ConsumerWidget {
  final IconData icon;
  const NavegtionConsumerBottomNavIcon({
    Key? key,
    required this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final matchingNotifications = ref.watch(notificationsStreamProvider);

    int count = 0;

    return matchingNotifications.whenData((value) {
      for (var element in value) {
        if (element.isRead == false) {
          count++;
        }
      }
      }



  return MessageIcon(unreadCount: unreadCount, icon: icon);
},
error: (_, __) => MessageIcon(unreadCount: 0, icon: icon),
loading: () => MessageIcon(unreadCount: 0, icon: icon),
);
    );
  }

} */
class MessageIcon extends StatelessWidget {
  final int unreadCount;
  final IconData icon;
  const MessageIcon({
    Key? key,
    required this.unreadCount,
    required this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Icon(
          icon,
        ),
        if (unreadCount > 0)
          Positioned(
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(1),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(6),
              ),
              constraints: const BoxConstraints(minWidth: 12, minHeight: 12),
              child: Center(
                child: Text(
                  '$unreadCount',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 7,
                      fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class NavegtionICon extends StatelessWidget {
  final int unreadCount;
  final IconData icon;
  const NavegtionICon({
    Key? key,
    required this.unreadCount,
    required this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Icon(
          icon,
        ),
        if (unreadCount > 0)
          Positioned(
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(1),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(6),
              ),
              constraints: const BoxConstraints(minWidth: 12, minHeight: 12),
              child: Center(
                child: Text(
                  '$unreadCount',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 7,
                      fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
