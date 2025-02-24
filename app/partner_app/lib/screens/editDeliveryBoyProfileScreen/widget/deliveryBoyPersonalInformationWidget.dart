import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:open_filex/open_filex.dart';
import 'package:project/helper/utils/generalImports.dart';
import 'package:project/models/cities.dart';
import 'package:project/provider/passwordShowHideProvider.dart';

enum EarningType { commission, salaried }

class DeliveryBoyPersonalInformationWidget extends StatefulWidget {
  final String from;
  final Map<String, String> personalData;
  final Map<String, String> personalDataFile;

  const DeliveryBoyPersonalInformationWidget(
      {Key? key,
      required this.personalData,
      required this.personalDataFile,
      required this.from})
      : super(key: key);

  @override
  State<DeliveryBoyPersonalInformationWidget> createState() =>
      DeliveryBoyPersonalInformationWidgetState();
}

class DeliveryBoyPersonalInformationWidgetState
    extends State<DeliveryBoyPersonalInformationWidget> {
  late TextEditingController edtDeliveryBoyUsername,
      edtDeliveryBoyEmail,
      edtDeliveryBoyMobile,
      edtDeliveryBoyDateOfBirth,
      edtDeliveryBoyAddress,
      edtPassword,
      edtConfirmPassword,
      edtDeliveryBoyCommission;

  String selectedNationalIdProof = "";
  String selectedDrivingLicense = "";

  final formKey = GlobalKey<FormState>();

  EarningType earningType = EarningType.commission;

  @override
  void initState() {
    edtDeliveryBoyUsername = TextEditingController(
      text: widget.personalData[ApiAndParams.name],
    );
    edtDeliveryBoyMobile = TextEditingController(
      text: widget.personalData[ApiAndParams.mobile],
    );
    edtDeliveryBoyEmail = TextEditingController(
      text: widget.personalData[ApiAndParams.email],
    );
    edtDeliveryBoyDateOfBirth = TextEditingController(
      text: widget.personalData[ApiAndParams.dob],
    );

    widget.personalDataFile[ApiAndParams.national_identity_card] = widget
                .personalDataFile[ApiAndParams.national_identity_card]
                .toString() !=
            "null"
        ? "${Constant.hostUrl}storage/${widget.personalData[ApiAndParams.national_identity_card]}"
        : "";
    widget.personalDataFile[ApiAndParams.driving_license] = widget
                .personalDataFile[ApiAndParams.driving_license]
                .toString() !=
            "null"
        ? "${Constant.hostUrl}storage/${widget.personalData[ApiAndParams.driving_license]}"
        : "";

    selectedNationalIdProof = widget
                .personalData[ApiAndParams.national_identity_card]
                .toString() !=
            "null"
        ? "${Constant.hostUrl}storage/${widget.personalData[ApiAndParams.national_identity_card]}"
        : "";

    selectedDrivingLicense = widget.personalData[ApiAndParams.driving_license]
                .toString() !=
            "null"
        ? "${Constant.hostUrl}storage/${widget.personalData[ApiAndParams.driving_license]}"
        : "";

    edtDeliveryBoyAddress = TextEditingController(
      text: widget.personalData[ApiAndParams.address],
    );

    edtDeliveryBoyCommission = TextEditingController(
        text: widget.personalData[ApiAndParams.bonusPercentage]);

    earningType = widget.personalData[ApiAndParams.bonusType] == "0"
        ? EarningType.salaried
        : EarningType.commission;
    edtPassword = TextEditingController();
    edtConfirmPassword = TextEditingController();
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
                edtController: edtDeliveryBoyUsername,
                validationFunction: emptyValidation,
                label: getTranslatedValue(context, "user_name"),
                inputType: TextInputType.text,
              ),
              getSizedBox(
                height: 10,
              ),
              editBoxWidget(
                context: context,
                edtController: edtDeliveryBoyEmail,
                validationFunction: emailValidation,
                label: getTranslatedValue(context, "email"),
                inputType: TextInputType.text,
              ),
              getSizedBox(
                height: 10,
              ),
              editBoxWidget(
                context: context,
                edtController: edtDeliveryBoyDateOfBirth,
                validationFunction: emptyValidation,
                label: getTranslatedValue(context, "date_of_birth"),
                inputType: TextInputType.none,
                tailIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: () {
                        showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          keyboardType: TextInputType.datetime,
                          firstDate: DateTime(1800),
                          lastDate: DateTime.now(),
                        ).then((selectedDate) {
                          if (selectedDate != null) {
                            // format date in required form here we use yyyy-MM-dd that means time is removed
                            edtDeliveryBoyDateOfBirth.text =
                                DateFormat('yyyy-MM-dd').format(selectedDate);
                          } else {
                            edtDeliveryBoyDateOfBirth.text = "";
                          }
                        });
                      },
                      child: Padding(
                        padding: EdgeInsetsDirectional.all(10),
                        child: defaultImg(
                          image: "date_picker",
                          iconColor: ColorsRes.appColor,
                          height: 25,
                          width: 25,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              getSizedBox(
                height: 10,
              ),
              editBoxWidget(
                context: context,
                edtController: edtDeliveryBoyMobile,
                validationFunction: emptyValidation,
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
              getSizedBox(
                height: 10,
              ),
              if (widget.from.isNotEmpty)
                //National Id Proof
                CustomTextLabel(
                  jsonKey: "national_identification_card",
                  style: TextStyle(
                    color: ColorsRes.mainTextColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              if (widget.from.isNotEmpty)
                getSizedBox(
                  height: 10,
                ),
              if (widget.from.isNotEmpty)
                Row(
                  children: [
                    if (selectedNationalIdProof.isNotEmpty)
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
                          child: imgWidget(selectedNationalIdProof),
                        ),
                      ),
                    if (selectedNationalIdProof.isNotEmpty)
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
                              selectedNationalIdProof =
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
              if (widget.from.isNotEmpty)
                getSizedBox(
                  height: 10,
                ),
              if (widget.from.isNotEmpty)
                //National Id Proof
                CustomTextLabel(
                  jsonKey: "driving_license",
                  style: TextStyle(
                    color: ColorsRes.mainTextColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              if (widget.from.isNotEmpty)
                getSizedBox(
                  height: 10,
                ),
              if (widget.from.isNotEmpty)
                Row(
                  children: [
                    if (selectedDrivingLicense.isNotEmpty)
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
                          child: imgWidget(selectedDrivingLicense),
                        ),
                      ),
                    getSizedBox(
                      height: 10,
                    ),
                    if (selectedDrivingLicense.isNotEmpty)
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
                              selectedDrivingLicense =
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
                                    jsonKey: "upload_driving_license_file_here",
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
              if (widget.from.isNotEmpty)
                getSizedBox(
                  height: 10,
                ),
              getSizedBox(height: 10),
              if (widget.from.isNotEmpty)
                editBoxWidget(
                  context: context,
                  edtController: edtDeliveryBoyAddress,
                  validationFunction: emptyValidation,
                  label: getTranslatedValue(context, "select_city"),
                  inputType: TextInputType.none,
                  tailIcon: IconButton(
                    onPressed: () {
                      Navigator.pushNamed(context, cityListScreen).then(
                        (value) {
                          if (value is Cities) {
                            widget.personalData.addAll({
                              ApiAndParams.city_id: value.id.toString(),
                            });
                            edtDeliveryBoyAddress.text =
                                value.formattedAddress.toString();
                          }
                        },
                      );
                    },
                    icon: Icon(
                      Icons.edit,
                      color: ColorsRes.appColor,
                    ),
                  ),
                ),
              getSizedBox(
                height: 10,
              ),
              getSizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsetsDirectional.only(start: 10, top: 10),
                      child: CustomTextLabel(
                        jsonKey: "earning_type",
                        style: TextStyle(
                          color: ColorsRes.mainTextColor.withOpacity(0.55),
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              earningType = EarningType.commission;
                              setState(() {});
                            },
                            child: Container(
                              color: Colors.transparent,
                              child: Row(
                                children: [
                                  Radio<EarningType>(
                                    value: earningType,
                                    groupValue: EarningType.commission,
                                    onChanged: (value) {
                                      earningType = EarningType.commission;
                                      setState(() {});
                                    },
                                    visualDensity: VisualDensity.compact,
                                  ),
                                  CustomTextLabel(
                                    jsonKey: "earning_type_commission",
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              earningType = EarningType.salaried;
                              setState(() {});
                            },
                            child: Container(
                              color: Colors.transparent,
                              child: Row(
                                children: [
                                  Radio<EarningType>(
                                    value: earningType,
                                    groupValue: EarningType.salaried,
                                    onChanged: (value) {
                                      earningType = EarningType.salaried;
                                      setState(() {});
                                    },
                                    visualDensity: VisualDensity.compact,
                                  ),
                                  CustomTextLabel(
                                    jsonKey: "earning_type_salaried",
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (earningType == EarningType.commission)
                getSizedBox(
                  height: 10,
                ),
              if (earningType == EarningType.commission)
                editBoxWidget(
                  context: context,
                  edtController: edtDeliveryBoyCommission,
                  validationFunction: percentageValidation,
                  label: getTranslatedValue(context, "commission_title"),
                  hint: getTranslatedValue(context, "commission_hint"),
                  inputType: TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d*')),
                  ],
                ),
              if (widget.from.isEmpty)
                getSizedBox(
                  height: 10,
                ),
              if (widget.from.isEmpty)
                editBoxWidget(
                  context: context,
                  edtController: edtDeliveryBoyAddress,
                  validationFunction: emptyValidation,
                  label: getTranslatedValue(context, "select_city"),
                  inputType: TextInputType.none,
                  tailIcon: IconButton(
                    onPressed: () {
                      Navigator.pushNamed(context, confirmLocationScreen,
                          arguments: [null, "location"]).then(
                        (value) {
                          Map<String, String> tempMap =
                              value as Map<String, String>;

                          widget.personalData.addAll({
                            ApiAndParams.address:
                                tempMap[ApiAndParams.formatted_address]
                                    .toString(),
                            ApiAndParams.city_id:
                                tempMap[ApiAndParams.city_id].toString(),
                          });
                          edtDeliveryBoyAddress.text =
                              tempMap[ApiAndParams.formatted_address]
                                  .toString();
                        },
                      );
                    },
                    icon: Icon(
                      Icons.my_location_rounded,
                      color: ColorsRes.appColor,
                    ),
                  ),
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
