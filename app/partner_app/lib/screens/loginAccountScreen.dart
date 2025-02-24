import 'package:flutter/material.dart';
import 'package:project/helper/utils/awsomeNotification.dart';
import 'package:project/helper/utils/generalImports.dart';

class LoginAccountScreen extends StatefulWidget {
  LoginAccountScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<LoginAccountScreen> createState() => _LoginAccountState();
}

class _LoginAccountState extends State<LoginAccountScreen> {
  final _formKey = GlobalKey<FormState>();

  // TODO REMOVE DEMO EMAIL FROM HERE
  late TextEditingController edtEmail = TextEditingController();

  // TODO REMOVE DEMO PASSWORD FROM HERE
  late TextEditingController edtPassword =
      TextEditingController();
  bool isLoading = false;

  @override
  void initState() {
    Future.delayed(Duration.zero).then((value) async {
      try {
        await LocalAwesomeNotification().init(context);

        await FirebaseMessaging.instance.getToken().then((token) {
          Constant.session.setData(SessionManager.keyFCMToken, token!, false);
        });
        FirebaseMessaging.onBackgroundMessage(
            LocalAwesomeNotification.onBackgroundMessageHandler);
      } catch (ignore) {}
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: getAppBar(
        context: context,
        title: CustomTextLabel(
          jsonKey: "login",
          style: TextStyle(color: ColorsRes.mainTextColor),
        ),
      ),
      body: ListView(
        children: [
          Container(
            height: MediaQuery.sizeOf(context).width * 0.5,
            child: defaultImg(image: "logo"),
          ),
          Card(
            color: Theme.of(context).cardColor,
            surfaceTintColor: Colors.transparent,
            shape: DesignConfig.setRoundedBorder(10),
            margin: EdgeInsets.symmetric(
                horizontal: Constant.paddingOrMargin15,
                vertical: Constant.paddingOrMargin15),
            child: Container(
              padding: EdgeInsets.symmetric(
                  horizontal: Constant.paddingOrMargin15,
                  vertical: Constant.paddingOrMargin15),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsetsDirectional.all(10),
                      decoration: DesignConfig.boxDecoration(
                          Theme.of(context).scaffoldBackgroundColor, 10),
                      child: Row(
                        children: [
                          defaultImg(
                              image: "mail_icon",
                              iconColor: ColorsRes.grey,
                              width: 25,
                              height: 24),
                          SizedBox(
                            width: 10.0,
                          ),
                          Flexible(
                            child: TextField(
                              controller: edtEmail,
                              keyboardType: TextInputType.emailAddress,
                              style: TextStyle(
                                color: ColorsRes.mainTextColor,
                              ),
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                isDense: true,
                                hintStyle: TextStyle(color: Colors.grey[300]),
                                hintText: getTranslatedValue(context, "email"),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    SizedBox(height: 15),
                    Consumer<UserProfileProvider>(
                      builder: (context, userProfileProvider, _) {
                        return Container(
                          padding: EdgeInsetsDirectional.all(10),
                          decoration: DesignConfig.boxDecoration(
                              Theme.of(context).scaffoldBackgroundColor, 10),
                          child: Row(
                            children: [
                              defaultImg(
                                  image: "password_icon",
                                  iconColor: ColorsRes.grey,
                                  width: 25,
                                  height: 24),
                              SizedBox(
                                width: 10.0,
                              ),
                              Flexible(
                                child: TextField(
                                  controller: edtPassword,
                                  obscureText: userProfileProvider.hidePassword,
                                  keyboardType: TextInputType.text,
                                  style: TextStyle(
                                    color: ColorsRes.mainTextColor,
                                  ),
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    isDense: true,
                                    hintStyle:
                                        TextStyle(color: Colors.grey[300]),
                                    hintText:
                                        getTranslatedValue(context, "password"),
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  userProfileProvider.showHidePassword();
                                },
                                child: defaultImg(
                                  image:
                                      userProfileProvider.hidePassword == true
                                          ? "hide_password"
                                          : "show_password",
                                  iconColor: ColorsRes.grey,
                                  width: 20,
                                  height: 21,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    SizedBox(height: 40),
                    RichText(
                      textAlign: TextAlign.start,
                      text: TextSpan(
                        style: Theme.of(context).textTheme.titleSmall!.merge(
                              TextStyle(
                                fontWeight: FontWeight.w400,
                                color: ColorsRes.subTitleTextColor,
                              ),
                            ),
                        text:
                            "${getTranslatedValue(context, "agreement_message_1")}\t",
                        children: <TextSpan>[
                          TextSpan(
                              text: getTranslatedValue(
                                  context, "terms_of_service"),
                              style: TextStyle(
                                color: ColorsRes.appColor,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  Navigator.pushNamed(context, webViewScreen,
                                      arguments: getTranslatedValue(
                                          context, "terms_of_service"));
                                }),
                          TextSpan(
                              text: "\t${getTranslatedValue(context, "and")}\t",
                              style: TextStyle(
                                color: ColorsRes.subTitleTextColor,
                              )),
                          TextSpan(
                            text: getTranslatedValue(context, "privacy_policy"),
                            style: TextStyle(
                              color: ColorsRes.appColor,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                Navigator.pushNamed(context, webViewScreen,
                                    arguments: getTranslatedValue(
                                        context, "privacy_policy"));
                              },
                          ),
                        ],
                      ),
                    ),
                    getSizedBox(height: 40),
                    Consumer<UserProfileProvider>(
                      builder: (context, userProfileProvider, _) {
                        return gradientBtnWidget(
                          context,
                          10,
                          otherWidgets: userProfileProvider.loginState ==
                                  LoginState.loading
                              ? Center(
                                  child: CircularProgressIndicator(
                                      color: ColorsRes.appColorWhite),
                                )
                              : CustomTextLabel(
                                  jsonKey: "login",
                                  softWrap: true,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium!
                                      .merge(
                                        TextStyle(
                                          color: Colors.white,
                                          letterSpacing: 0.5,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                ),
                          callback: () {
                            if (edtPassword.text.toString().isEmpty) {
                              showMessage(
                                  context,
                                  "${getTranslatedValue(context, "enter_valid")} ${getTranslatedValue(context, "password")}",
                                  MessageType.error);
                            } else if (edtEmail.text.toString().isEmpty ||
                                validateEmail(
                                      edtEmail.text.toString(),
                                    ) !=
                                    null) {
                              showMessage(
                                  context,
                                  "${getTranslatedValue(context, "enter_valid")} ${getTranslatedValue(context, "email")}",
                                  MessageType.error);
                            } else {
                              Map<String, String> params = {};
                              Constant.session.setData(SessionManager.password,
                                  edtPassword.text.toString(), false);
                              params[ApiAndParams.email] =
                                  edtEmail.text.toString();
                              params[ApiAndParams.password] =
                                  edtPassword.text.toString();
                              params[ApiAndParams.type] =
                                  Constant.session.isSeller() ? "3" : "4";
                              params[ApiAndParams.fcmToken] = Constant.session
                                  .getData(SessionManager.keyFCMToken);
                              params[ApiAndParams.platform] =
                                  Platform.isAndroid ? "android" : "ios";

                              userProfileProvider
                                  .loginApiProvider(params, context)
                                  .then(
                                (value) async {
                                  UserLogin userLogin =
                                      UserLogin.fromJson(value!);
                                  if (value.isNotEmpty) {
                                    Constant.session.setData(
                                        SessionManager.email,
                                        userLogin.data?.user?.email
                                                .toString() ??
                                            "",
                                        false);
                                    if (Constant.session
                                        .getData(SessionManager.appThemeName)
                                        .isEmpty) {
                                      Constant.session.setData(
                                          SessionManager.appThemeName,
                                          Constant.themeList[0],
                                          true);
                                    }
                                    Constant.session
                                        .setUserData(
                                            data: Constant.session.isSeller()
                                                ? userLogin.data?.user?.seller
                                                    ?.toJson()
                                                : userLogin
                                                    .data?.user?.deliveryBoy
                                                    ?.toJson())
                                        .then(
                                      (value) {
                                        Navigator.of(context)
                                            .pushNamedAndRemoveUntil(
                                          mainHomeScreen,
                                          (Route<dynamic> route) => false,
                                        );
                                      },
                                    );
                                  }
                                },
                              );
                            }
                          },
                        );
                      },
                    ),
                    getSizedBox(height: 40),
                    Consumer<UserProfileProvider>(
                      builder: (context, userProfileProvider, _) {
                        return gradientBtnWidget(
                          context,
                          10,
                          otherWidgets: CustomTextLabel(
                            jsonKey: "register",
                            softWrap: true,
                            style:
                                Theme.of(context).textTheme.titleMedium!.merge(
                                      TextStyle(
                                          color: Colors.white,
                                          letterSpacing: 0.5,
                                          fontWeight: FontWeight.w500),
                                    ),
                          ),
                          callback: () {
                            if (Constant.session.isSeller()) {
                              Navigator.pushNamed(
                                  context, editSellerProfileScreen,
                                  arguments: "registration");
                            } else {
                              Navigator.pushNamed(
                                  context, editDeliveryBoyProfileScreen,
                                  arguments: "registration");
                            }
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
