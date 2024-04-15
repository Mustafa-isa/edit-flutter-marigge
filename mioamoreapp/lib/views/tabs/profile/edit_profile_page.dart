import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mioamoreapp/config/config.dart';
import 'package:mioamoreapp/helpers/constants.dart';
import 'package:mioamoreapp/helpers/media_picker_helper.dart';
import 'package:mioamoreapp/models/user_profile_model.dart';
import 'package:mioamoreapp/providers/user_profile_provider.dart';
import 'package:mioamoreapp/views/custom/custom_button.dart';

class EditProfilePage extends ConsumerStatefulWidget {
  final UserProfileModel userProfileModel;
  const EditProfilePage({Key? key, required this.userProfileModel})
      : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _aboutController = TextEditingController();
  String? _profilePicture;
  final List<String> _interests = [];
  final List<String> _medias = [
    for (var i = 0; i < AppConfig.maxNumOfMedia; i++) ""
  ];

  @override
  void initState() {
    _fullNameController.text = widget.userProfileModel.fullName;
    _emailController.text = widget.userProfileModel.email ?? "";
    _phoneNumberController.text = widget.userProfileModel.phoneNumber ?? "";
    _aboutController.text = widget.userProfileModel.about ?? "";
    _profilePicture = widget.userProfileModel.profilePicture;
    _interests.addAll(widget.userProfileModel.interests);
    for (var i = 0; i < _medias.length; i++) {
      if (widget.userProfileModel.mediaFiles.length > i) {
        _medias[i] = widget.userProfileModel.mediaFiles[i];
      }
    }

    super.initState();
  }

  void _onSave() async {
    if (_formKey.currentState!.validate()) {
      final newUserProfileModel = widget.userProfileModel.copyWith(
        fullName: _fullNameController.text.trim(),
        email: _emailController.text.trim(),
        phoneNumber: _phoneNumberController.text.trim(),
        about: _aboutController.text.trim(),
        profilePicture: _profilePicture,
        interests: _interests,
        mediaFiles: _medias,
      );
      EasyLoading.show(status: "Saving...");

      await ref
          .read(userProfileNotifier)
          .updateUserProfile(newUserProfileModel)
          .then((value) {
        EasyLoading.dismiss();
        ref.invalidate(userProfileFutureProvider);
        Navigator.pop(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Edit Profile"),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.defaultNumericValue),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: AppConstants.defaultNumericValue),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(
                        AppConstants.defaultNumericValue * 10),
                  ),
                  child: Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(
                          AppConstants.defaultNumericValue * 10),
                      child: GestureDetector(
                        onTap: () async {
                          void setProfilePicture() async {
                            final imagePath = await pickMedia();
                            if (imagePath != null) {
                              setState(() {
                                _profilePicture = imagePath;
                              });
                            }
                          }

                          if (_profilePicture != null &&
                              _profilePicture != "") {
                            showModalBottomSheet(
                                context: context,
                                builder: (context) {
                                  return Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      ListTile(
                                        title: const Text(
                                            "Set New Profile Picture"),
                                        leading: const Icon(Icons.image),
                                        onTap: () {
                                          Navigator.pop(context);
                                          setProfilePicture();
                                        },
                                      ),
                                      ListTile(
                                        title: const Text(
                                            "Remove Profile Picture"),
                                        leading: const Icon(Icons.delete),
                                        onTap: () {
                                          setState(() {
                                            _profilePicture = "";
                                          });
                                          Navigator.pop(context);
                                        },
                                      ),
                                    ],
                                  );
                                });
                          } else {
                            setProfilePicture();
                          }
                        },
                        child: SizedBox(
                          width: AppConstants.defaultNumericValue * 7,
                          height: AppConstants.defaultNumericValue * 7,
                          child: _profilePicture == null ||
                                  _profilePicture!.isEmpty
                              ? CircleAvatar(
                                  backgroundColor:
                                      Theme.of(context).scaffoldBackgroundColor,
                                  child: Icon(
                                    CupertinoIcons.person_circle_fill,
                                    color: AppConstants.primaryColor,
                                    size: AppConstants.defaultNumericValue * 7,
                                  ),
                                )
                              : Uri.parse(_profilePicture!).isAbsolute
                                  ? CachedNetworkImage(
                                      imageUrl: _profilePicture!,
                                      placeholder: (context, url) =>
                                          const CircularProgressIndicator
                                              .adaptive(),
                                      errorWidget: (context, url, error) =>
                                          const Icon(Icons.error),
                                      fit: BoxFit.cover,
                                    )
                                  : Image.file(
                                      File(_profilePicture!),
                                      fit: BoxFit.cover,
                                    ),
                        ),
                      ),
                    ),
                  ),
                ),
                if (AppConfig.canChangeName)
                  const SizedBox(height: AppConstants.defaultNumericValue),
                if (AppConfig.canChangeName)
                  TextFormField(
                    controller: _fullNameController,
                    decoration: const InputDecoration(
                      labelText: "Full Name",
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "Please enter your full name";
                      }
                      return null;
                    },
                  ),
                const SizedBox(height: AppConstants.defaultNumericValue),
                TextFormField(
                  controller: _emailController,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  decoration: const InputDecoration(
                    labelText: "Email",
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return null;
                    } else if (!emailVerificationRedExp.hasMatch(value)) {
                      return "Please enter a valid email";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppConstants.defaultNumericValue),
                TextFormField(
                  controller: _phoneNumberController,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(
                    labelText: "Phone Number",
                  ),
                ),
                const SizedBox(height: AppConstants.defaultNumericValue),
                TextFormField(
                  controller: _aboutController,
                  maxLines: null,
                  decoration: const InputDecoration(
                    labelText: "About",
                  ),
                ),
                const SizedBox(height: AppConstants.defaultNumericValue),
                Text(
                  "Interests",
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: AppConstants.defaultNumericValue / 2),
                Wrap(
                  spacing: AppConstants.defaultNumericValue / 2,
                  children: AppConfig.interests
                      .map(
                        (interest) => ChoiceChip(
                          label: Text(interest[0].toUpperCase() +
                              interest.substring(1)),
                          selected: _interests.contains(interest),
                          shape: _interests.contains(interest)
                              ? RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      AppConstants.defaultNumericValue * 2),
                                  side: BorderSide(
                                      color: AppConstants.primaryColor,
                                      width: 1),
                                )
                              : null,
                          selectedColor:
                              AppConstants.primaryColor.withOpacity(0.3),
                          onSelected: (notSelected) {
                            setState(() {
                              if (notSelected) {
                                if (_interests.length >=
                                    AppConfig.maxNumOfInterests) {
                                  EasyLoading.showToast(
                                      "You can only select ${AppConfig.maxNumOfInterests} interests",
                                      toastPosition:
                                          EasyLoadingToastPosition.bottom);
                                } else {
                                  _interests.add(interest);
                                }
                              } else {
                                _interests.remove(interest);
                              }
                            });
                          },
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: AppConstants.defaultNumericValue / 2),
                Text(
                  "You can select up to ${AppConfig.maxNumOfInterests} interests",
                  textAlign: TextAlign.end,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: AppConstants.defaultNumericValue),
                Text(
                  "Images",
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: AppConstants.defaultNumericValue / 2),
                Wrap(
                  spacing: AppConstants.defaultNumericValue / 2.1,
                  runSpacing: AppConstants.defaultNumericValue / 2.1,
                  alignment: WrapAlignment.center,
                  children: _medias
                      .map(
                        (image) => GestureDetector(
                          onTap: () async {
                            void selecImage() async {
                              final imagePath = await pickMedia();
                              if (imagePath != null) {
                                setState(() {
                                  _medias[_medias.indexOf(image)] = imagePath;
                                });
                              }
                            }

                            if (image != "") {
                              showModalBottomSheet(
                                  context: context,
                                  builder: (context) {
                                    return Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        ListTile(
                                          title: const Text("Select New Image"),
                                          leading: const Icon(Icons.image),
                                          onTap: () {
                                            Navigator.pop(context);
                                            selecImage();
                                          },
                                        ),
                                        ListTile(
                                          title: const Text(
                                              "Remove Current Image"),
                                          leading: const Icon(Icons.delete),
                                          onTap: () {
                                            setState(() {
                                              _medias[_medias.indexOf(image)] =
                                                  "";
                                            });
                                            Navigator.pop(context);
                                          },
                                        ),
                                      ],
                                    );
                                  });
                            } else {
                              selecImage();
                            }
                          },
                          child: SizedBox(
                            width: (MediaQuery.of(context).size.width -
                                    AppConstants.defaultNumericValue * 3) /
                                3,
                            height: (MediaQuery.of(context).size.width -
                                    AppConstants.defaultNumericValue * 3) /
                                3,
                            child: image.isEmpty
                                ? Container(
                                    decoration: const BoxDecoration(
                                        color: Colors.black12),
                                    child: const Center(
                                        child: Icon(CupertinoIcons.photo)),
                                  )
                                : Uri.parse(image).isAbsolute
                                    ? CachedNetworkImage(
                                        imageUrl: image,
                                        placeholder: (context, url) =>
                                            const Center(
                                                child: CircularProgressIndicator
                                                    .adaptive()),
                                        errorWidget: (context, url, error) =>
                                            const Center(
                                                child:
                                                    Icon(CupertinoIcons.photo)),
                                        fit: BoxFit.cover,
                                      )
                                    : Image.file(
                                        File(image),
                                        fit: BoxFit.cover,
                                      ),
                          ),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: AppConstants.defaultNumericValue / 2),
                Text(
                  "You can add up to ${AppConfig.maxNumOfMedia} images",
                  textAlign: TextAlign.end,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: AppConstants.defaultNumericValue),
                CustomButton(
                  onPressed: _onSave,
                  text: "Save",
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
