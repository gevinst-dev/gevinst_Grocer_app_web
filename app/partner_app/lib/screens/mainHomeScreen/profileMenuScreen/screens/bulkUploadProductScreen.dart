import 'dart:io' as io;

import 'package:external_path/external_path.dart';
import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import 'package:project/helper/utils/generalImports.dart';
import 'package:project/provider/productBulkOperationsProvider.dart';

class ProductBulkUploadScreen extends StatefulWidget {
  final String from;

  ProductBulkUploadScreen({Key? key, required this.from}) : super(key: key);

  @override
  State<ProductBulkUploadScreen> createState() =>
      _ProductBulkUploadScreenState();
}

class _ProductBulkUploadScreenState extends State<ProductBulkUploadScreen> {
  String selectedPath = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: getAppBar(
        context: context,
        title: CustomTextLabel(
          jsonKey: widget.from == "upload"
              ? "title_products_bulk_upload"
              : "title_products_bulk_update",
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  getSizedBox(height: 10),
                  CustomTextLabel(
                    jsonKey: "bulk_upload_title",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: ColorsRes.mainTextColor,
                      fontSize: 22,
                    ),
                  ),
                  getSizedBox(height: 20),
                  buildNumberedList(
                    context: context,
                    items: [
                      {"title": "point_1", "message": "step_1"},
                      {"title": "point_2", "message": "step_2"},
                      {"title": "point_3", "message": "step_3"},
                    ],
                  ),
                  getSizedBox(height: 20),
                  // Display note for mandatory fields
                  CustomTextLabel(
                    jsonKey: "mandatory_fields_note",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: ColorsRes.appColorRed,
                    ),
                  ),
                  getSizedBox(height: 20),
                  // Display the bulleted list with the product fields and descriptions
                  buildBulletList(context: context, items: [
                    {
                      "title": "product_name_title",
                      "message": "product_name_message"
                    },
                    {
                      "title": "category_id_title",
                      "message": "category_id_message"
                    },
                    {
                      "title": "indicator_title",
                      "message": "indicator_message"
                    },
                    {
                      "title": "manufacturer_title",
                      "message": "manufacturer_message"
                    },
                    {"title": "made_in_title", "message": "made_in_message"},
                    {
                      "title": "is_returnable_title",
                      "message": "is_returnable_message"
                    },
                    {
                      "title": "is_cancelable_title",
                      "message": "is_cancelable_message"
                    },
                    {
                      "title": "till_status_title",
                      "message": "till_status_message"
                    },
                    {
                      "title": "description_title",
                      "message": "description_message"
                    },
                    {"title": "image_title", "message": "image_message"},
                    {
                      "title": "seller_id_title",
                      "message": "seller_id_message"
                    },
                    {
                      "title": "is_approved_title",
                      "message": "is_approved_message"
                    },
                    {"title": "tax_id_title", "message": "tax_id_message"},
                    {"title": "fssai_no_title", "message": "fssai_no_message"},
                    {
                      "title": "variant_type_title",
                      "message": "variant_type_message"
                    },
                    {
                      "title": "variant_measurement_title",
                      "message": "variant_measurement_message"
                    },
                    {
                      "title": "variant_measurement_unit_id_title",
                      "message": "variant_measurement_unit_id_message"
                    },
                    {
                      "title": "variant_price_title",
                      "message": "variant_price_message"
                    },
                    {
                      "title": "variant_discounted_price_title",
                      "message": "variant_discounted_price_message"
                    },
                    {
                      "title": "variant_availability_title",
                      "message": "variant_availability_message"
                    },
                    {
                      "title": "variant_stock_title",
                      "message": "variant_stock_message"
                    },
                    {
                      "title": "variant_stock_unit_id_title",
                      "message": "variant_stock_unit_id_message"
                    },
                    {
                      "title": "deliverable_note_title",
                      "message": "deliverable_note_message"
                    },
                    {
                      "title": "empty_field_note_title",
                      "message": "empty_field_note_message"
                    },
                  ]),
                  getSizedBox(height: 130),
                ],
              ),
            ),
          ),
          PositionedDirectional(
            bottom: 0,
            start: 0,
            end: 0,
            child: Container(
              padding: EdgeInsetsDirectional.all(10),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                ),
                boxShadow: [
                  BoxShadow(
                    color: ColorsRes.subTitleTextColor.withOpacity(0.5),
                    spreadRadius: 5,
                    blurRadius: 7,
                    offset: Offset(0, 3), // changes position of shadow
                  ),
                ],
              ),
              child: Column(
                children: [
                  getSizedBox(height: 15),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () async {
                          // Single file path
                          FilePicker.platform
                              .pickFiles(
                            allowMultiple: false,
                            allowCompression: true,
                            type: FileType.custom,
                            allowedExtensions: ["csv"],
                            lockParentWindow: true,
                          )
                              .then(
                            (value) {
                              if (value != null) {
                                selectedPath = value.paths.first.toString();
                                setState(() {});
                              }
                            },
                          );
                        },
                        child: Container(
                          padding: EdgeInsetsDirectional.only(
                              start: 15, end: 15, top: 10, bottom: 10),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: ColorsRes.appColor,
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          alignment: Alignment.center,
                          child: CustomTextLabel(
                            jsonKey: "select_file",
                            style: TextStyle(
                              color: ColorsRes.appColor,
                            ),
                          ),
                        ),
                      ),
                      getSizedBox(width: 10),
                      Expanded(
                        child: CustomTextLabel(
                          text: selectedPath.isEmpty
                              ? getTranslatedValue(context, 'no_file_chosen')
                              : selectedPath.split("/").last,
                        ),
                      ),
                      if (selectedPath.isNotEmpty) getSizedBox(width: 10),
                      if (selectedPath.isNotEmpty)
                        IconButton(
                          onPressed: () {
                            selectedPath = "";
                            setState(() {});
                          },
                          icon: Icon(
                            Icons.cancel,
                            color: ColorsRes.subTitleTextColor,
                          ),
                        )
                    ],
                  ),
                  getSizedBox(height: 5),
                  Divider(
                    thickness: 1,
                    color: ColorsRes.subTitleTextColor.withOpacity(0.2),
                  ),
                  getSizedBox(height: 5),
                  Consumer<ProductBulkOperationsProvider>(
                    builder: (__, productBulkOperationsProvider, _) {
                      return Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () async {
                                productBulkOperationsProvider
                                    .getProductDownloadExcel(
                                  context: context,
                                  from : widget.from,
                                ).then(
                                  (htmlContent) async {
                                    try {
                                      if (htmlContent != null) {
                                        final appDocDirPath = io
                                                .Platform.isAndroid
                                            ? (await ExternalPath
                                                .getExternalStoragePublicDirectory(
                                                    ExternalPath
                                                        .DIRECTORY_DOWNLOADS))
                                            : (await getApplicationDocumentsDirectory())
                                                .path;

                                        final targetFileName =
                                            "${getTranslatedValue(context, widget.from == "upload" ? "sample_products_csv_file_do_not_add_space_in_this_value_use_underscore_or_dash" : "all_products_csv_file_do_not_add_space_in_this_value_use_underscore_or_dash")}_${DateTime.now().microsecondsSinceEpoch}.csv";

                                        io.File file = io.File(
                                            "$appDocDirPath/$targetFileName");

                                        // Write down the file as bytes from the bytes got from the HTTP request.
                                        await file.writeAsBytes(htmlContent,
                                            flush: false);
                                        await file.writeAsBytes(htmlContent);

                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(SnackBar(
                                          action: SnackBarAction(
                                            label: getTranslatedValue(
                                                context, "show_file"),
                                            textColor: ColorsRes.mainTextColor,
                                            onPressed: () {
                                              OpenFilex.open(file.path);
                                            },
                                          ),
                                          content: CustomTextLabel(
                                            jsonKey: "file_saved_successfully",
                                            softWrap: true,
                                            style: TextStyle(
                                                color: ColorsRes.mainTextColor),
                                          ),
                                          duration: const Duration(seconds: 5),
                                          backgroundColor: Theme.of(context)
                                              .scaffoldBackgroundColor,
                                        ));
                                      }
                                    } catch (_) {}
                                  },
                                );
                              },
                              child: Container(
                                padding: EdgeInsetsDirectional.only(
                                    start: 10, end: 10, top: 10, bottom: 10),
                                alignment: Alignment.center,
                                child: productBulkOperationsProvider
                                            .productSampleFileState ==
                                        ProductSampleFileState.loading
                                    ? SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          color: ColorsRes.appColor,
                                        ),
                                      )
                                    : CustomTextLabel(
                                        jsonKey: widget.from == "upload"
                                            ? "download_sample_file"
                                            : "download_product_data",
                                        style: TextStyle(
                                          color: ColorsRes.appColor,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                          getSizedBox(width: 15),
                          Expanded(
                            child: GestureDetector(
                              onTap: () async {
                                if (selectedPath.isNotEmpty) {
                                  productBulkOperationsProvider
                                      .productBulkOperation(
                                    context: context,
                                    fileParamsFilesPath: selectedPath,
                                    isUpload: widget.from == "upload",
                                  );
                                }
                              },
                              child: Container(
                                padding: EdgeInsetsDirectional.only(
                                    start: 10, end: 10, top: 10, bottom: 10),
                                decoration: BoxDecoration(
                                  color: ColorsRes.appColor,
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                alignment: Alignment.center,
                                child: productBulkOperationsProvider
                                            .productBulkOperationsState ==
                                        ProductBulkOperationsState.loading
                                    ? SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          color: ColorsRes.appColorWhite,
                                        ),
                                      )
                                    : CustomTextLabel(
                                        jsonKey: widget.from == "upload"
                                            ? "upload"
                                            : "update",
                                        style: TextStyle(
                                          color: ColorsRes.appColorWhite,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget buildBulletList(
      {required BuildContext context,
      required List<Map<String, String>> items,
      bool? isNumbered}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items
          .map(
            (item) => Padding(
              padding: EdgeInsetsDirectional.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomTextLabel(
                    text: isNumbered == true ? "" : "• ",
                  ),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: TextStyle(
                          color: ColorsRes.mainTextColor,
                        ),
                        children: [
                          TextSpan(
                            text:
                                "${getTranslatedValue(context, item['title']!)}: ",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          TextSpan(
                            text: getTranslatedValue(context, item['message']!),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }

  Widget buildNumberedList({
    required BuildContext context,
    required List<Map<String, String>> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items
          .map(
            (item) => Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomTextLabel(
                  jsonKey: item['title'],
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: ColorsRes.mainTextColor,
                  ),
                ),
                Expanded(
                  child: CustomTextLabel(
                    jsonKey: item['message'],
                    style: TextStyle(
                      color: ColorsRes.mainTextColor,
                    ),
                  ),
                ),
              ],
            ),
          )
          .toList(),
    );
  }
}
