import 'package:dotted_border/dotted_border.dart';
import 'package:project/helper/generalWidgets/bottomSheetMultipleCategorySelectionWidget.dart';
import 'package:project/helper/utils/generalImports.dart';
import 'package:project/models/cities.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:open_filex/open_filex.dart';
import 'package:quill_html_editor/quill_html_editor.dart';

class SellerStoreInformationWidget extends StatefulWidget {
  final String from;
  final Map<String, String> personalData;
  final Map<String, String> personalDataFile;

  const SellerStoreInformationWidget(
      {Key? key,
      required this.personalData,
      required this.personalDataFile,
      required this.from})
      : super(key: key);

  @override
  State<SellerStoreInformationWidget> createState() =>
      SellerStoreInformationWidgetState();
}

class SellerStoreInformationWidgetState
    extends State<SellerStoreInformationWidget> {
  late TextEditingController edtCategoriesName,
      edtCategoryIds,
      edtStoreName,
      edtStoreUrl,
      edtTaxName,
      edtTaxNumber,
      edtCommission,
      edtStoreAddress,
      edtSelectCity;

  String edtStoreDescription = "";

  String selectedLogoPath = "";

  final formKey = GlobalKey<FormState>();
  String result = '';
  final QuillEditorController controller = QuillEditorController();

  @override
  void initState() {
    edtCategoriesName = TextEditingController(
      text: widget.personalData[ApiAndParams.categoriesName] == null
          ? Constant.session.getData(SessionManager.categoriesName)
          : widget.personalData[ApiAndParams.categoriesName],
    );
    edtCategoryIds = TextEditingController(
      text: widget.personalData[ApiAndParams.categories] == null
          ? Constant.session.getData(SessionManager.categories)
          : widget.personalData[ApiAndParams.categories],
    );
    edtStoreName = TextEditingController(
      text: widget.personalData[ApiAndParams.storeName] == null
          ? Constant.session.getData(SessionManager.store_name)
          : widget.personalData[ApiAndParams.storeName],
    );
    edtStoreUrl = TextEditingController(
      text: widget.personalData[ApiAndParams.store_url] == null
          ? Constant.session.getData(SessionManager.store_url)
          : widget.personalData[ApiAndParams.store_url],
    );
    selectedLogoPath = widget.personalDataFile[ApiAndParams.store_logo] == null
        ? Constant.session.getData(SessionManager.logo_url)
        : widget.personalDataFile[ApiAndParams.store_logo].toString();

    edtStoreDescription =
        (widget.personalData[ApiAndParams.store_description] == null
            ? Constant.session.getData(SessionManager.store_description)
            : widget.personalData[ApiAndParams.store_description])!;
    ;

    edtCommission = TextEditingController(
      text: Constant.sellerCommission,
    );

    edtTaxName = TextEditingController(
      text: widget.personalData[ApiAndParams.tax_name] == null
          ? Constant.session.getData(SessionManager.tax_name)
          : widget.personalData[ApiAndParams.tax_name],
    );
    edtTaxNumber = TextEditingController(
      text: widget.personalData[ApiAndParams.tax_number] == null
          ? Constant.session.getData(SessionManager.tax_number)
          : widget.personalData[ApiAndParams.tax_number],
    );

    edtSelectCity = TextEditingController(
      text: widget.personalData[ApiAndParams.state] == null
          ? Constant.session.getData(SessionManager.city_id)
          : widget.personalData[ApiAndParams.state],
    );

    edtStoreAddress = TextEditingController();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).cardColor,
      surfaceTintColor: Colors.transparent,
      shape: DesignConfig.setRoundedBorder(7),
      elevation: 0,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: Constant.paddingOrMargin10,
          vertical: Constant.paddingOrMargin10,
        ),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomTextLabel(
                jsonKey: "store_information",
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
              ChangeNotifierProvider(
                create: (context) => CategoryListProvider(),
                child: editBoxWidget(
                  context: context,
                  edtController: edtCategoriesName,
                  validationFunction: emptyValidation,
                  label: getTranslatedValue(context, "category_ids"),
                  inputType: TextInputType.none,
                  tailIcon: GestureDetector(
                    onTap: () {
                      showModalBottomSheet<void>(
                        backgroundColor: Theme.of(context).cardColor,
                        context: context,
                        isScrollControlled: true,
                        shape: DesignConfig.setRoundedBorderSpecific(20,
                            istop: true),
                        builder: (BuildContext context) {
                          return ChangeNotifierProvider(
                            create: (context) => CategoryListProvider(),
                            child: Container(
                              padding: EdgeInsetsDirectional.only(
                                  start: Constant.paddingOrMargin15,
                                  end: Constant.paddingOrMargin15,
                                  top: Constant.paddingOrMargin15,
                                  bottom: Constant.paddingOrMargin15),
                              child: BottomSheetMultipleCategorySelectionWidget(
                                edtCategoryIds: edtCategoryIds,
                                edtCategoriesName: edtCategoriesName,
                              ),
                            ),
                          );
                        },
                      ).then((value) {
                        setState(() {});
                      });
                    },
                    child: Padding(
                      padding: EdgeInsetsDirectional.all(10),
                      child: defaultImg(
                        image: "select_categories",
                        iconColor: ColorsRes.appColor,
                        height: 20,
                        width: 20,
                      ),
                    ),
                  ),
                ),
              ),
              getSizedBox(
                height: 10,
              ),
              editBoxWidget(
                context: context,
                edtController: edtStoreName,
                validationFunction: emptyValidation,
                label: getTranslatedValue(context, "store_name"),
                inputType: TextInputType.text,
              ),
              getSizedBox(
                height: 10,
              ),
              editBoxWidget(
                context: context,
                edtController: edtStoreUrl,
                validationFunction: optionalFieldValidation,
                label: getTranslatedValue(context, "store_url"),
                inputType: TextInputType.text,
              ),
              getSizedBox(
                height: 10,
              ),
              editBoxWidget(
                  context: context,
                  edtController: edtCommission,
                  validationFunction: percentageValidation,
                  label: getTranslatedValue(context, "commission"),
                  inputType: TextInputType.number,
                  isEditable: false),
              getSizedBox(
                height: 10,
              ),
              if (widget.from.isNotEmpty)
                editBoxWidget(
                  context: context,
                  edtController: edtStoreAddress,
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
                            edtStoreAddress.text =
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
              getSizedBox(height: 10),
              editBoxWidget(
                context: context,
                edtController: edtTaxName,
                validationFunction: emptyValidation,
                label: getTranslatedValue(context, "tax_name"),
                inputType: TextInputType.text,
              ),
              getSizedBox(
                height: 10,
              ),
              editBoxWidget(
                context: context,
                edtController: edtTaxNumber,
                validationFunction: emptyValidation,
                label: getTranslatedValue(context, "tax_number"),
                inputType: TextInputType.text,
              ),
              getSizedBox(
                height: 10,
              ),
              Row(
                children: [
                  if (selectedLogoPath.isNotEmpty)
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
                        child: imgWidget(selectedLogoPath),
                      ),
                    ),
                  if (selectedLogoPath.isNotEmpty) getSizedBox(width: 10),
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        // Single file path
                        FilePicker.platform
                            .pickFiles(
                                allowMultiple: false,
                                type: FileType.custom,
                                allowedExtensions: ["jpg", "jpeg", "png"],
                                lockParentWindow: true)
                            .then((value) {
                          if (value != null) {
                            cropImage(value.paths.first.toString());
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
                                  jsonKey: "upload_logo_file_here",
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
              Container(
                constraints: BoxConstraints(
                  minWidth: MediaQuery.sizeOf(context).width,
                  minHeight: 10,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Theme.of(context).cardColor,
                  border: Border.all(
                    color: ColorsRes.subTitleTextColor,
                  ),
                ),
                child: Stack(
                  children: [
                    Container(
                      padding: EdgeInsetsDirectional.all(10),
                      child: QuillHtmlEditor(
                        text: edtStoreDescription.isEmpty
                            ? getTranslatedValue(
                                context, "description_goes_here")
                            : edtStoreDescription,
                        hintText: getTranslatedValue(
                            context, "description_goes_here"),
                        isEnabled: false,
                        ensureVisible: false,
                        minHeight: 10,
                        autoFocus: false,
                        textStyle: TextStyle(color: ColorsRes.mainTextColor),
                        hintTextStyle:
                            TextStyle(color: ColorsRes.subTitleTextColor),
                        hintTextAlign: TextAlign.start,
                        padding:
                            const EdgeInsets.only(left: 10, bottom: 2, top: 2),
                        hintTextPadding: const EdgeInsets.only(left: 20),
                        backgroundColor: Theme.of(context).cardColor,
                        inputAction: InputAction.newline,
                        loadingBuilder: (context) {
                          return Center(
                            child: CircularProgressIndicator(
                              color: ColorsRes.appColor,
                            ),
                          );
                        },
                        controller: QuillEditorController(),
                      ),
                    ),
                    PositionedDirectional(
                      top: 0,
                      end: 0,
                      child: IconButton(
                        onPressed: () {
                          Navigator.pushNamed(context, htmlEditorScreen,
                                  arguments: edtStoreDescription)
                              .then(
                            (value) {
                              if (value != null) {
                                edtStoreDescription = value.toString();
                                setState(
                                  () {},
                                );
                              }
                            },
                          );
                        },
                        icon: Icon(
                          Icons.edit,
                          color: ColorsRes.appColor,
                        ),
                      ),
                    )
                  ],
                ),
              ),
              if (widget.from.isEmpty)
                getSizedBox(
                  height: 10,
                ),
              if (widget.from.isEmpty)
                editBoxWidget(
                  context: context,
                  edtController: edtSelectCity,
                  validationFunction: emptyValidation,
                  label: getTranslatedValue(context, "select_city"),
                  inputType: TextInputType.none,
                  tailIcon: IconButton(
                    onPressed: () {
                      Navigator.pushNamed(context, confirmLocationScreen,
                          arguments: [null, "location"]).then(
                        (value) {
                          widget.personalData
                              .addAll(value as Map<String, String>);
                          edtSelectCity.text =
                              value[ApiAndParams.formatted_address] ?? "";
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

  Future<void> cropImage(String filePath) async {
    await ImageCropper()
        .cropImage(
      sourcePath: filePath,
      compressFormat: ImageCompressFormat.png,
      compressQuality: 100,
      aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
      maxHeight: 1024,
      maxWidth: 1024,
    )
        .then((croppedFile) {
      if (croppedFile != null) {
        setState(() {
          selectedLogoPath = croppedFile.path;
        });
      }
    });
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
