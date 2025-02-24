import 'package:flutter/material.dart';
import 'package:project/helper/utils/generalImports.dart';
import 'package:project/models/userProfile.dart';

class EditDeliveryBoyProfileScreen extends StatefulWidget {
  final String from;

  EditDeliveryBoyProfileScreen({Key? key, required this.from})
      : super(key: key);

  @override
  State<EditDeliveryBoyProfileScreen> createState() =>
      _EditDeliveryBoyProfileScreenState();
}

class _EditDeliveryBoyProfileScreenState
    extends State<EditDeliveryBoyProfileScreen> {
  bool isLoading = false;
  String selectedImagePath = "";

  final globalKeyPersonalInformationWidgetState =
      GlobalKey<DeliveryBoyPersonalInformationWidgetState>();
  final globalKeyBankInformationWidgetState =
      GlobalKey<DeliveryBoyBankInformationWidgetState>();

  Map<String, String> registrationData = {};
  Map<String, String> registrationDataFiles = {};
  late Timer timer;
  int logoutTimerSeconds = 10;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero).then((value) {
      if (widget.from.isEmpty) {
        registrationData[ApiAndParams.email] =
            Constant.session.getData(SessionManager.email);
        context
            .read<UserProfileProvider>()
            .getProfile(context: context)
            .then((value) {
          if (value is UserProfile) {
            // 'name' => 'required',
            // 'email' => 'email|required|unique:admins,email,'.$request->admin_id,
            // 'mobile' => 'required',
            // 'confirm_password' => 'same:password',
            // 'dob' => 'required',
            // 'bonus_percentage' => 'required',
            // 'ifsc_code' => 'required',
            // 'bank_name' => 'required',
            // 'bank_account_number' => 'required',
            // 'account_name' => 'required',
            // 'address' => 'required',
            // 'city_id' => 'required',
            // 'status' => 'required',

            UserProfileDeliveryBoy? deliveryBoy =
                value.data?.admin?.deliveryBoy!;

            registrationData["admin_id"] =
                deliveryBoy?.adminId?.toString() ?? "";
            registrationData["id"] = deliveryBoy?.id?.toString() ?? "";
            registrationData["name"] = deliveryBoy?.name?.toString() ?? "";
            registrationData["email"] =
                value.data?.admin?.email?.toString() ?? "";
            registrationData["mobile"] = deliveryBoy?.mobile?.toString() ?? "";
            registrationData["dob"] = deliveryBoy?.dob?.toString() ?? "";
            registrationData["bonus_percentage"] =
                deliveryBoy?.bonusPercentage?.toString() ?? "";
            registrationData["ifsc_code"] =
                deliveryBoy?.ifscCode?.toString() ?? "";
            registrationData["bank_name"] =
                deliveryBoy?.bankName?.toString() ?? "";
            registrationData["bank_account_number"] =
                deliveryBoy?.bankAccountNumber?.toString() ?? "";
            registrationData["account_name"] =
                deliveryBoy?.accountName?.toString() ?? "";
            registrationData["address"] =
                deliveryBoy?.address?.toString() ?? "";
            registrationData["city_id"] = deliveryBoy?.cityId?.toString() ?? "";
            registrationData["status"] = deliveryBoy?.status?.toString() ?? "";
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: getAppBar(
        context: context,
        title: CustomTextLabel(
          jsonKey: "title_profile",
          style: TextStyle(
            color: ColorsRes.mainTextColor,
          ),
        ),
      ),
      body: Consumer<UserProfileProvider>(
        builder: (context, userProfileProvider, _) {
          if (userProfileProvider.profileState == ProfileState.loaded ||
              (userProfileProvider.profileState == ProfileState.initial ||
                  widget.from.isNotEmpty)) {
            return Stack(
              children: [
                Column(
                  children: [
                    if (widget.from.isEmpty)
                      Padding(
                        padding: EdgeInsetsDirectional.all(7),
                        child: Card(
                          color: Theme.of(context).cardColor,
                          surfaceTintColor: Colors.transparent,
                          margin: EdgeInsetsDirectional.zero,
                          shape: DesignConfig.setRoundedBorder(7),
                          elevation: 0,
                          child: Padding(
                            padding: EdgeInsetsDirectional.all(10),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 12,
                                  backgroundColor:
                                      userProfileProvider.currentPage >= 0
                                          ? ColorsRes.appColor
                                          : ColorsRes.grey,
                                  child: CustomTextLabel(
                                    text: "1",
                                    style: TextStyle(
                                      color: ColorsRes.appColorWhite,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Divider(
                                    color: userProfileProvider.currentPage >= 1
                                        ? ColorsRes.appColor
                                        : ColorsRes.grey,
                                    height: 5,
                                    thickness: 5,
                                  ),
                                ),
                                CircleAvatar(
                                  radius: 12,
                                  backgroundColor:
                                      userProfileProvider.currentPage >= 1
                                          ? ColorsRes.appColor
                                          : ColorsRes.grey,
                                  child: CustomTextLabel(
                                    text: "2",
                                    style: TextStyle(
                                      color: ColorsRes.appColorWhite,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    Expanded(
                      child: ListView(
                        padding: EdgeInsetsDirectional.only(start: 5, end: 5),
                        children: [
                          if (widget.from.isNotEmpty)
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.red.shade100,
                                borderRadius: BorderRadius.circular(7),
                              ),
                              padding: EdgeInsetsDirectional.only(
                                  start: 10, end: 10, top: 5, bottom: 5),
                              margin: EdgeInsetsDirectional.only(
                                  start: 5, end: 5, bottom: 5),
                              child: CustomTextLabel(
                                jsonKey: "all_fields_are_mandatory",
                                softWrap: true,
                                style: TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          if (userProfileProvider.currentPage == 0)
                            DeliveryBoyPersonalInformationWidget(
                              key: globalKeyPersonalInformationWidgetState,
                              personalData: registrationData,
                              personalDataFile: registrationDataFiles,
                              from: widget.from,
                            ),
                          if (userProfileProvider.currentPage == 1 &&
                              widget.from.isEmpty)
                            DeliveryBoyBankInformationWidget(
                              key: globalKeyBankInformationWidgetState,
                              personalData: registrationData,
                              from: widget.from,
                            ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsetsDirectional.all(10),
                      child: Row(
                        children: [
                          if (userProfileProvider.currentPage != 0 &&
                              widget.from.isEmpty)
                            Expanded(
                              child: gradientBtnWidget(
                                context,
                                10,
                                title: getTranslatedValue(context, "previous"),
                                callback: () {
                                  userProfileProvider.moveBack();
                                },
                              ),
                            ),
                          if (userProfileProvider.currentPage != 0)
                            getSizedBox(width: 10),
                          Expanded(
                            child: gradientBtnWidget(
                              context,
                              10,
                              title: (userProfileProvider.currentPage == 1 ||
                                      widget.from.isNotEmpty)
                                  ? getTranslatedValue(context, "save")
                                  : getTranslatedValue(context, "next"),
                              callback: () {
                                // id:2
                                // admin_id:7
                                // name:delivery
                                // dob:8852-11-18
                                // mobile:9876543210
                                // email:delivery@gmail.com
                                // ifsc_code:123
                                // bank_name:123
                                // bank_account_number:132
                                // account_name:123
                                // city_id:31
                                // address:123
                                // bonus_type:0
                                // status:1
                                // bonus_percentage:0

                                if (userProfileProvider.currentPage == 0 &&
                                    globalKeyPersonalInformationWidgetState
                                            .currentState?.formKey.currentState
                                            ?.validate() ==
                                        true) {
                                  //Personal information store action here

                                  registrationData[ApiAndParams.name] =
                                      globalKeyPersonalInformationWidgetState
                                              .currentState
                                              ?.edtDeliveryBoyUsername
                                              .text ??
                                          "";
                                  registrationData[ApiAndParams.email] =
                                      globalKeyPersonalInformationWidgetState
                                              .currentState
                                              ?.edtDeliveryBoyEmail
                                              .text ??
                                          "";

                                  registrationData[ApiAndParams.mobile] =
                                      globalKeyPersonalInformationWidgetState
                                              .currentState
                                              ?.edtDeliveryBoyMobile
                                              .text ??
                                          "";

                                  registrationData[ApiAndParams.dob] =
                                      globalKeyPersonalInformationWidgetState
                                              .currentState
                                              ?.edtDeliveryBoyDateOfBirth
                                              .text ??
                                          "";

                                  if (globalKeyPersonalInformationWidgetState
                                          .currentState?.earningType ==
                                      EarningType.commission) {
                                    registrationData[
                                            ApiAndParams.bonusPercentage] =
                                        globalKeyPersonalInformationWidgetState
                                                .currentState
                                                ?.edtDeliveryBoyCommission
                                                .text ??
                                            "";
                                  }

                                  registrationData[ApiAndParams.bonusType] =
                                      globalKeyPersonalInformationWidgetState
                                                  .currentState?.earningType ==
                                              EarningType.commission
                                          ? "1"
                                          : "0";

                                  registrationData[ApiAndParams.address] =
                                      globalKeyPersonalInformationWidgetState
                                              .currentState
                                              ?.edtDeliveryBoyAddress
                                              .text ??
                                          "";
                                  if (globalKeyPersonalInformationWidgetState
                                          .currentState!
                                          .edtPassword
                                          .text
                                          .isNotEmpty &&
                                      globalKeyPersonalInformationWidgetState
                                          .currentState!
                                          .edtConfirmPassword
                                          .text
                                          .isNotEmpty) {
                                    registrationData[ApiAndParams.password] =
                                        globalKeyPersonalInformationWidgetState
                                                .currentState
                                                ?.edtPassword
                                                .text ??
                                            "";

                                    registrationData[
                                            ApiAndParams.confirm_password] =
                                        globalKeyPersonalInformationWidgetState
                                                .currentState
                                                ?.edtConfirmPassword
                                                .text ??
                                            "";
                                  } else if (widget.from.isNotEmpty &&
                                      globalKeyPersonalInformationWidgetState
                                              .currentState!
                                              .edtConfirmPassword
                                              .text
                                              .length <
                                          6) {
                                    showMessage(
                                        context,
                                        getTranslatedValue(context,
                                            "password_must_be_six_characters"),
                                        MessageType.error);
                                  } else if (!registrationDataFiles[ApiAndParams.national_identity_card]!
                                          .contains("https://") ||
                                      !registrationDataFiles[ApiAndParams.national_identity_card]!
                                          .contains("http://")) {
                                    registrationDataFiles[ApiAndParams
                                            .national_identity_card] =
                                        globalKeyPersonalInformationWidgetState
                                                .currentState
                                                ?.selectedNationalIdProof ??
                                            "";
                                  } else if (!registrationDataFiles[ApiAndParams.driving_license]!
                                          .contains("https://") ||
                                      !registrationDataFiles[ApiAndParams.driving_license]!
                                          .contains("http://")) {
                                    registrationDataFiles[
                                            ApiAndParams.driving_license] =
                                        globalKeyPersonalInformationWidgetState
                                                .currentState
                                                ?.selectedDrivingLicense ??
                                            "";
                                  }

                                  if (widget.from.isEmpty) {
                                    userProfileProvider.moveNext();
                                  } else {
                                    if ((!registrationDataFiles[ApiAndParams.national_identity_card]!
                                                .contains("https://") ||
                                            !registrationDataFiles[ApiAndParams.national_identity_card]!
                                                .contains("http://")) &&
                                        globalKeyPersonalInformationWidgetState
                                            .currentState!
                                            .selectedNationalIdProof
                                            .isEmpty) {
                                      showMessage(
                                          context,
                                          getTranslatedValue(context,
                                              "national_id_card_required"),
                                          MessageType.error);
                                    } else if ((!registrationDataFiles[ApiAndParams.driving_license]!
                                                .contains("https://") ||
                                            !registrationDataFiles[ApiAndParams.driving_license]!
                                                .contains("http://")) &&
                                        globalKeyPersonalInformationWidgetState
                                            .currentState!
                                            .selectedDrivingLicense
                                            .isEmpty) {
                                      showMessage(
                                          context,
                                          getTranslatedValue(context,
                                              "driving_license_is_required"),
                                          MessageType.error);
                                    } else if (globalKeyPersonalInformationWidgetState
                                        .currentState!
                                        .edtDeliveryBoyCommission
                                        .text
                                        .isEmpty) {
                                      showMessage(
                                          context,
                                          getTranslatedValue(
                                              context, "enter_commission"),
                                          MessageType.error);
                                    } else if (double.parse(globalKeyPersonalInformationWidgetState.currentState!.edtDeliveryBoyCommission.text) >
                                        100) {
                                      showMessage(
                                          context,
                                          getTranslatedValue(context,
                                              "commission_should_be_less_than_or_equal_to_100"),
                                          MessageType.error);
                                    } else if (double.parse(globalKeyPersonalInformationWidgetState.currentState!.edtDeliveryBoyCommission.text) <=
                                        0) {
                                      showMessage(
                                          context,
                                          getTranslatedValue(context,
                                              "commission_should_be_greater_than_0"),
                                          MessageType.error);
                                    } else {
                                      /*
                                  1. Personal Information
                                    name
                                    mobile
                                    dob
                                    address
                                    driving_license //file
                                    national_identity_card //file

                                  2. Store Information
                                    bank_name
                                    ifsc_code
                                    account_name
                                    bank_account_number
                                */

                                      if (!registrationDataFiles[ApiAndParams
                                                  .national_identity_card]!
                                              .contains("https://") ||
                                          !registrationDataFiles[ApiAndParams
                                                  .national_identity_card]!
                                              .contains("http://")) {
                                        registrationDataFiles[ApiAndParams
                                                .national_identity_card] =
                                            globalKeyPersonalInformationWidgetState
                                                    .currentState
                                                    ?.selectedNationalIdProof ??
                                                "";
                                      }

                                      if (!registrationDataFiles[
                                                  ApiAndParams.driving_license]!
                                              .contains("https://") ||
                                          !registrationDataFiles[
                                                  ApiAndParams.driving_license]!
                                              .contains("http://")) {
                                        registrationDataFiles[
                                                ApiAndParams.driving_license] =
                                            globalKeyPersonalInformationWidgetState
                                                    .currentState
                                                    ?.selectedDrivingLicense ??
                                                "";
                                      }

                                      userProfileProvider
                                          .updateUserApiProvider(
                                              context: context,
                                              params: registrationData,
                                              from: widget.from,
                                              fileParamsFilesPath:
                                                  registrationDataFiles)
                                          .then((value) {
                                        if (value == true) {
                                          Navigator.pop(context);
                                        }
                                      });
                                    }
                                  }
                                } else if (userProfileProvider.currentPage ==
                                        1 &&
                                    globalKeyBankInformationWidgetState
                                            .currentState?.formKey.currentState
                                            ?.validate() ==
                                        true) {
                                  //Bank information store action here

                                  registrationData[ApiAndParams.bank_name] =
                                      globalKeyBankInformationWidgetState
                                              .currentState?.edtBankName.text ??
                                          "";

                                  registrationData[ApiAndParams.ifsc_code] =
                                      globalKeyBankInformationWidgetState
                                              .currentState?.edtIFSCCode.text ??
                                          "";

                                  registrationData[ApiAndParams.account_name] =
                                      globalKeyBankInformationWidgetState
                                              .currentState
                                              ?.edtAccountName
                                              .text ??
                                          "";

                                  registrationData[
                                          ApiAndParams.bank_account_number] =
                                      globalKeyBankInformationWidgetState
                                              .currentState
                                              ?.edtAccountNumber
                                              .text ??
                                          "";

                                  /*
                                  1. Personal Information
                                    name
                                    mobile
                                    dob
                                    address
                                    driving_license //file
                                    national_identity_card //file

                                  2. Store Information
                                    bank_name
                                    ifsc_code
                                    account_name
                                    bank_account_number
                                */

                                  userProfileProvider
                                      .updateUserApiProvider(
                                    context: context,
                                    params: registrationData,
                                    from: widget.from,
                                  )
                                      .then((value) {
                                    if (value == true) {
                                      if (registrationData
                                              .containsKey("password") &&
                                          widget.from.isEmpty) {
                                        timer = Timer.periodic(
                                            Duration(seconds: 1), (time) {
                                          logoutTimerSeconds--;

                                          if (logoutTimerSeconds == 0) {
                                            if (timer.isActive) {
                                              timer.cancel();
                                            }
                                            Navigator.pop(context);
                                            Constant.session.logoutUser(context,
                                                confirmationRequired: false);
                                          }
                                        });

                                        showDialog(
                                          context: context,
                                          barrierDismissible: false,
                                          builder: (context) {
                                            return AlertDialog(
                                              backgroundColor:
                                                  Theme.of(context).cardColor,
                                              surfaceTintColor:
                                                  Theme.of(context).cardColor,
                                              title: CustomTextLabel(
                                                jsonKey: "logout",
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              actions: [
                                                GestureDetector(
                                                  onTap: () {
                                                    if (timer.isActive) {
                                                      timer.cancel();
                                                    }
                                                    Navigator.pop(context);
                                                    Constant.session.logoutUser(
                                                        context,
                                                        confirmationRequired:
                                                            false);
                                                  },
                                                  child: CustomTextLabel(
                                                    softWrap: true,
                                                    jsonKey: "logout_now",
                                                    style: TextStyle(
                                                        color:
                                                            ColorsRes.appColor,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ),
                                              ],
                                              content: CustomTextLabel(
                                                softWrap: true,
                                                text:
                                                    "${getTranslatedValue(context, "app_will_logout_in")} $logoutTimerSeconds ${getTranslatedValue(context, "seconds_because_your_account_password_have_been_changed_you_need_to_re_login")}",
                                              ),
                                            );
                                          },
                                        );
                                      } else {
                                        Navigator.pop(context);
                                      }
                                    }
                                  });
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (userProfileProvider.updateProfileState ==
                    UpdateProfileState.loading)
                  PositionedDirectional(
                    top: 0,
                    end: 0,
                    start: 0,
                    bottom: 0,
                    child: Container(
                      color: ColorsRes.appColorBlack.withOpacity(0.2),
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  ),
              ],
            );
          } else if (userProfileProvider.profileState == ProfileState.loading) {
            return CustomShimmer(
              height: context.height,
              width: context.width,
              margin: EdgeInsets.all(10),
            );
          } else {
            return Container();
          }
        },
      ),
    );
  }
}
