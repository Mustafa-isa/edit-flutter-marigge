import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:mioamoreapp/config/config.dart';
import 'package:mioamoreapp/helpers/constants.dart';
import 'package:mioamoreapp/models/user_profile_model.dart';
import 'package:mioamoreapp/providers/interaction_provider.dart';
import 'package:mioamoreapp/providers/other_users_provider.dart';
import 'package:mioamoreapp/views/custom/custom_app_bar.dart';
import 'package:mioamoreapp/views/custom/custom_headline.dart';
import 'package:mioamoreapp/views/custom/custom_icon_button.dart';
import 'package:mioamoreapp/views/custom/lottie/no_item_found_widget.dart';
import 'package:mioamoreapp/views/custom/subscription_builder.dart';
import 'package:mioamoreapp/views/others/user_image_card.dart';

class ExplorePage extends ConsumerStatefulWidget {
  final int? index;
  const ExplorePage({
    super.key,
    this.index,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ExplorePageState();
}

class _ExplorePageState extends ConsumerState<ExplorePage> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearchBarVisible = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 0,
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: AppConstants.defaultNumericValue),
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.defaultNumericValue),
            child: CustomAppBar(
              leading: CustomIconButton(
                  icon: CupertinoIcons.back,
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  padding: const EdgeInsets.all(
                      AppConstants.defaultNumericValue / 1.5)),
              title: Center(
                child: CustomHeadLine(
                  text: 'Explore Users',
                  secondPartColor: AppConstants.primaryColor,
                ),
              ),
              trailing: CustomIconButton(
                icon: CupertinoIcons.search,
                onPressed: () {
                  setState(() {
                    _isSearchBarVisible = !_isSearchBarVisible;
                    _searchController.clear();
                  });
                },
                padding: const EdgeInsets.all(
                    AppConstants.defaultNumericValue / 1.5),
              ),
            ),
          ),
          _isSearchBarVisible
              ? const SizedBox(height: AppConstants.defaultNumericValue)
              : const SizedBox(height: 0),
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.defaultNumericValue),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return SizeTransition(sizeFactor: animation, child: child);
              },
              child: _isSearchBarVisible
                  ? Container(
                      key: const Key('searchBar'),
                      padding: const EdgeInsets.all(
                          AppConstants.defaultNumericValue / 3),
                      decoration: BoxDecoration(
                        color: AppConstants.primaryColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(
                          AppConstants.defaultNumericValue,
                        ),
                      ),
                      child: TextField(
                        controller: _searchController,
                        autofocus: true,
                        onChanged: (_) {
                          setState(() {});
                        },
                        decoration: InputDecoration(
                          hintText: 'Search here...',
                          border: InputBorder.none,
                          prefixIcon: Icon(
                            CupertinoIcons.search,
                            color: AppConstants.primaryColor,
                          ),
                        ),
                      ),
                    )
                  : const SizedBox(key: Key('noSearchBar')),
            ),
          ),
          _isSearchBarVisible
              ? const SizedBox(height: AppConstants.defaultNumericValue)
              : const SizedBox(height: 0),
          Expanded(
            child: SubscriptionBuilder(
              builder: (context, isPremiumUser) {
                return ExploreUsersBody(
                  index: widget.index,
                  query: _searchController.text,
                  isPremiumUser: isPremiumUser,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class ExploreUsersBody extends ConsumerStatefulWidget {
  final String? query;
  final bool isPremiumUser;
  final int? index;
  const ExploreUsersBody({
    super.key,
    this.query,
    required this.isPremiumUser,
    this.index,
  });

  @override
  ConsumerState<ExploreUsersBody> createState() => _ExploreUsersBodyState();
}

class _ExploreUsersBodyState extends ConsumerState<ExploreUsersBody> {
  int? _index;
  @override
  void initState() {
    _index = widget.index;
    if (!widget.isPremiumUser && isAdmobAvailable) {
      InterstitialAd.load(
        adUnitId: Platform.isAndroid
            ? AndroidAdUnits.interstitialId
            : IOSAdUnits.interstitialId,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (ad) async {
            debugPrint('InterstitialAd loaded.');

            await Future.delayed(const Duration(seconds: 4)).then((value) {
              ad.show();
            });
          },
          onAdFailedToLoad: (error) {},
        ),
      );
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final filteredUsers = ref.watch(filteredOtherUsersProvider);

    return filteredUsers.when(
      data: (users) {
        final interactionProvider = ref.watch(interactionFutureProvider);

        return interactionProvider.when(
          data: (data) {
            final List<UserProfileModel> filteredUsers = [];

            for (final user in users) {
              if (!data.any(
                  (element) => element.intractToUserId.contains(user.userId))) {
                filteredUsers.add(user);
              }
            }

            return DefaultTabController(
              initialIndex: _index ?? 0,
              length: AppConfig.interests.length,
              child: Column(
                children: [
                  TabBar(
                    isScrollable: true,
                    labelColor: AppConstants.primaryColor,
                    tabs: AppConfig.interests
                        .map((e) => Tab(text: e.toUpperCase()))
                        .toList(),
                  ),
                  Expanded(
                    child: TabBarView(
                      children: AppConfig.interests.map((e) {
                        final filteredUsers = users
                            .where((element) => element.interests.contains(e))
                            .toList();

                        if (widget.query != null && widget.query!.isNotEmpty) {
                          filteredUsers.retainWhere((element) => element
                              .fullName
                              .toLowerCase()
                              .contains(widget.query!.toLowerCase()));
                        }

                        return filteredUsers.isEmpty
                            ? const NoItemFoundWidget()
                            : GridView(
                                padding: const EdgeInsets.all(
                                    AppConstants.defaultNumericValue),
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  childAspectRatio: 0.75,
                                  crossAxisSpacing:
                                      AppConstants.defaultNumericValue,
                                  mainAxisSpacing:
                                      AppConstants.defaultNumericValue,
                                ),
                                children: filteredUsers.map((user) {
                                  return UserImageCard(user: user);
                                }).toList(),
                              );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            );
          },
          error: (_, __) => const Center(
            child: Text("Something Went Wrong!"),
          ),
          loading: () => const Center(
            child: CircularProgressIndicator.adaptive(),
          ),
        );
      },
      error: (_, __) => const Center(
        child: Text("Something Went Wrong!"),
      ),
      loading: () => const Center(
        child: CircularProgressIndicator.adaptive(),
      ),
    );
  }
}
