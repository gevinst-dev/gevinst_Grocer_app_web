import 'package:dotted_border/dotted_border.dart';
import 'package:project/helper/utils/generalImports.dart';
import 'package:project/provider/passwordShowHideProvider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:open_filex/open_filex.dart';

class SellerPersonalInformationWidget extends StatefulWidget {
  final String from;
  final Map<String, String> personalData;
  final Map<String, String> personalDataFile;

  const SellerPersonalInformationWidget(
      {Key? key,
      required this.personalData,
      required this.personalDataFile,
      required this.from})
      : super(key: key);

  @override
  State<SellerPersonalInformationWidget> createState() =>
      SellerPersonalInformationWidgetState();
}

class SellerPersonalInformationWidgetState
    extends State<SellerPersonalInformationWidget> {
  TextEditingController edtUsername = TextEditingController();
  TextEditingController edtEmail = TextEditingController();
  TextEditingController edtMobile = TextEditingController();
  TextEditingController edtPanNumber = TextEditingController();
  TextEditingController edtPassword = TextEditingController();
  TextEditingController edtConfirmPassword = TextEditingController();

  String selectedAddressProofPath = "";
  String selectedNationalIdPath = "";

  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    Future.delayed(Duration.zero).then((value) {
      edtUsername = TextEditingController(
        text: widget.personalData[ApiAndParams.name],
      );

      edtEmail = TextEditingController(
        text: widget.personalData[ApiAndParams.email],
      );

      edtMobile = TextEditingController(
        text: widget.personalData[ApiAndParams.mobile],
      );

      edtPanNumber = TextEditingController(
        text: widget.personalData[ApiAndParams.pan_number],
      );

      if (widget.from.isNotEmpty) {
        if (widget.personalDataFile[ApiAndParams.address_proof].toString() ==
            "null") {
          widget.personalDataFile[ApiAndParams.address_proof] = "";
        }
        if (widget.personalDataFile[ApiAndParams.national_id_card].toString() ==
            "null") {
          widget.personalDataFile[ApiAndParams.national_id_card] = "";
        }
        selectedNationalIdPath =
            widget.personalDataFile[ApiAndParams.national_id_card].toString();

        selectedAddressProofPath =
            widget.personalDataFile[ApiAndParams.address_proof].toString();
      }

      edtPassword = TextEditingController(
        text: widget.personalDataFile[ApiAndParams.password],
      );

      edtConfirmPassword = TextEditingController(
        text: widget.personalDataFile[ApiAndParams.confirm_password],
      );
      setState(() {});
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).cardColor,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      child: Padding(
        padding: EdgeInsetsDirectional.all(15),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomTextLabel(
                jsonKey: "personal_information",
                style: TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: 18,
                  color: ColorsRes.mainTextColor,
                ),
              ),
              getSizedBox(height: 10),
              Divider(
                  height: 1,
                  color: ColorsRes.grey.withOpacity(0.5),
                  thickness: 1),
              getSizedBox(height: 10),
              editBoxWidget(
                context: context,
                edtController: edtUsername,
                validationFunction: emptyValidation,
                label: getTranslatedValue(context, "user_name"),
                inputType: TextInputType.text,
              ),
              getSizedBox(
                height: 10,
              ),
              editBoxWidget(
                context: context,
                edtController: edtEmail,
                validationFunction: emailValidation,
                label: getTranslatedValue(context, "email"),
                isEditable: widget.from == "registration" ? true : false,
                inputType: TextInputType.emailAddress,
              ),
              getSizedBox(
                height: 10,
              ),
              editBoxWidget(
                context: context,
                edtController: edtMobile,
                validationFunction: phoneValidation,
                label: getTranslatedValue(context, "mobile"),
                inputType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  CustomNumberTextInputFormatter()
                ],
              ),
              getSizedBox(
                height: 10,
              ),
              if (widget.from.isEmpty)
                CustomTextLabel(
                  jsonKey: "keep_blank_if_you_dont_want_to_change_password",
                  softWrap: true,
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 12,
                  ),
                ),
              if (widget.from.isEmpty)
                getSizedBox(
                  height: 5,
                ),
              ChangeNotifierProvider<PasswordShowHideProvider>(
                create: (context) => PasswordShowHideProvider(),
                child: Consumer<PasswordShowHideProvider>(
                  builder: (context, passwordShowHideProvider, child) {
                    return editBoxWidget(
                      context: context,
                      edtController: edtPassword,
                      validationFunction: optionalFieldValidation,
                      label: getTranslatedValue(context, "password"),
                      inputType: TextInputType.text,
                      tailIcon: GestureDetector(
                        onTap: () {
                          passwordShowHideProvider.showHidePassword();
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: SizedBox(
                            child: defaultImg(
                              image:
                                  passwordShowHideProvider.hidePassword == true
                                      ? "hide_password"
                                      : "show_password",
                              iconColor: ColorsRes.appColor,
                            ),
                            height: 10,
                            width: 10,
                          ),
                        ),
                      ),
                      ishidetext: passwordShowHideProvider.hidePassword == true,
                      maxlines: 1,
                    );
                  },
                ),
              ),
              getSizedBox(
                height: 10,
              ),
              if (widget.from.isEmpty)
                CustomTextLabel(
                  jsonKey: "keep_blank_if_you_dont_want_to_change_password",
                  softWrap: true,
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 12,
                  ),
                ),
              if (widget.from.isEmpty)
                getSizedBox(
                  height: 5,
                ),
              ChangeNotifierProvider<PasswordShowHideProvider>(
                create: (context) => PasswordShowHideProvider(),
                child: Consumer<PasswordShowHideProvider>(
                  builder: (context, passwordShowHideProvider, child) {
                    return editBoxWidget(
                        context: context,
                        edtController: edtConfirmPassword,
                        validationFunction: optionalFieldValidation,
                        label: getTranslatedValue(context, "confirm_password"),
                        inputType: TextInputType.text,
                        tailIcon: GestureDetector(
                          onTap: () {
                            passwordShowHideProvider.showHidePassword();
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: SizedBox(
                              child: defaultImg(
                                image: passwordShowHideProvider.hidePassword ==
                                        true
                                    ? "hide_password"
                                    : "show_password",
                                iconColor: ColorsRes.appColor,
                              ),
                              height: 10,
                              width: 10,
                            ),
                          ),
                        ),
                        ishidetext:
                            passwordShowHideProvider.hidePassword == true,
                        maxlines: 1);
                  },
                ),
              ),
              //National Id Proof
              CustomTextLabel(
                jsonKey: "national_identification_card",
                style: TextStyle(
                  color: ColorsRes.mainTextColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
              getSizedBox(
                height: 10,
              ),
              Row(
                children: [
                  if (selectedNationalIdPath.isNotEmpty)
                    Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: ColorsRes.subTitleTextColor,
                          ),
                          color: Theme.of(context).cardColor),
                      height: 105,
                      width: 105,
                      child: Center(
                        child: imgWidget(selectedNationalIdPath),
                      ),
                    ),
                  if (selectedNationalIdPath.isNotEmpty) getSizedBox(width: 10),
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        // Single file path
                        FilePicker.platform
                            .pickFiles(
                          allowMultiple: false,
                          allowCompression: true,
                          type: FileType.custom,
                          allowedExtensions: ["pdf", "jpg", "jpeg", "png"],
                          lockParentWindow: true,
                        )
                            .then((value) {
                          if (value != null) {
                            selectedNationalIdPath =
                                value.paths.first.toString();
                            setState(() {});
                          }
                        });
                      },
                      child: DottedBorder(
                        dashPattern: [5],
                        strokeWidth: 2,
                        strokeCap: StrokeCap.round,
                        color: ColorsRes.subTitleTextColor,
                        radius: Radius.circular(10),
                        borderType: BorderType.RRect,
                        child: Container(
                          height: 100,
                          color: Colors.transparent,
                          padding: EdgeInsetsDirectional.all(10),
                          child: Center(
                            child: Column(
                              children: [
                                defaultImg(
                                  image: "upload",
                                  iconColor: ColorsRes.subTitleTextColor,
                                  height: 40,
                                  width: 40,
                                ),
                                CustomTextLabel(
                                  jsonKey: "upload_nid_file_here",
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: ColorsRes.subTitleTextColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              getSizedBox(
                height: 10,
              ),
              //National Id Proof
              CustomTextLabel(
                jsonKey: "address_proof",
                style: TextStyle(
                  color: ColorsRes.mainTextColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
              getSizedBox(
                height: 10,
              ),
              Row(
                children: [
                  if (selectedAddressProofPath.isNotEmpty)
                    Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: ColorsRes.subTitleTextColor,
                          ),
                          color: Theme.of(context).cardColor),
                      height: 105,
                      width: 105,
                      child: Center(
                        child: imgWidget(selectedAddressProofPath),
                      ),
                    ),
                  if (selectedAddressProofPath.isNotEmpty)
                    getSizedBox(width: 10),
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        // Single file path
                        FilePicker.platform
                            .pickFiles(
                                allowMultiple: false,
                                allowCompression: true,
                                type: FileType.custom,
                                allowedExtensions: [
                                  "pdf",
                                  "jpg",
                                  "jpeg",
                                  "png"
                                ],
                                lockParentWindow: true)
                            .then((value) {
                          if (value != null) {
                            selectedAddressProofPath =
                                value.paths.first.toString();
                            setState(() {});
                          }
                        });
                      },
                      child: DottedBorder(
                        dashPattern: [5],
                        strokeWidth: 2,
                        strokeCap: StrokeCap.round,
                        color: ColorsRes.subTitleTextColor,
                        radius: Radius.circular(10),
                        borderType: BorderType.RRect,
                        child: Container(
                          height: 100,
                          color: Colors.transparent,
                          padding: EdgeInsetsDirectional.all(10),
                          child: Center(
                            child: Column(
                              children: [
                                defaultImg(
                                  image: "upload",
                                  iconColor: ColorsRes.subTitleTextColor,
                                  height: 40,
                                  width: 40,
                                ),
                                CustomTextLabel(
                                  jsonKey: "upload_address_proof_file_here",
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: ColorsRes.subTitleTextColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              getSizedBox(
                height: 10,
              ),
              getSizedBox(height: 10),
              editBoxWidget(
                context: context,
                edtController: edtPanNumber,
                validationFunction: emptyValidation,
                label: getTranslatedValue(context, "personal_identity_number"),
                inputType: TextInputType.text,
              ),
              if (widget.from.isNotEmpty)
                getSizedBox(
                  height: 10,
                ),
            ],
          ),
        ),
      ),
    );
  }

  imgWidget(String fileName) {
    return GestureDetector(
      onTap: () {
        try {
          OpenFilex.open(fileName);
        } catch (e) {
          showMessage(context, e.toString(), MessageType.error);
        }
      },
      child: fileName.split(".").last == "pdf"
          ? Center(
              child: defaultImg(
                image: "pdf",
                height: 50,
                width: 50,
              ),
            )
          : ClipRRect(
              borderRadius: Constant.borderRadius10,
              clipBehavior: Clip.antiAliasWithSaveLayer,
              child: (fileName.contains("https://") ||
                      fileName.contains("http://"))
                  ? setNetworkImg(
                      image: fileName,
                      width: 90,
                      height: 90,
                      boxFit: BoxFit.fill,
                    )
                  : Image.file(
                      File(fileName),
                      fit: BoxFit.cover,
                    ),
            ),
    );
  }
}
