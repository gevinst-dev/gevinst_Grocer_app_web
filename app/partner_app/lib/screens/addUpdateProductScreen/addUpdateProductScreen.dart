import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:open_filex/open_filex.dart';
import 'package:project/helper/utils/generalImports.dart';
import 'package:project/models/brand.dart';
import 'package:project/models/countries.dart';
import 'package:project/models/measurementUnit.dart';
import 'package:project/models/productDetail.dart';
import 'package:project/models/productList.dart';
import 'package:project/models/tags.dart';
import 'package:project/models/tax.dart';
import 'package:project/provider/addProductProvider.dart';
import 'package:project/provider/productDeleteProvider.dart';
import 'package:project/provider/productStockStatusProvider.dart';
import 'package:project/screens/addUpdateProductScreen/widget/stepperCounter.dart';
import 'package:quill_html_editor/quill_html_editor.dart';

class ProductAddScreen extends StatefulWidget {
  final String productId;
  final String from;

  ProductAddScreen({Key? key, required this.productId, required this.from})
      : super(key: key);

  @override
  State<ProductAddScreen> createState() => _ProductAddScreenState();
}

enum Returnable { no, yes }

enum Cancellable { no, yes }

enum IsCodAllowed { no, yes }

enum ProductPackType { packet, loose }

enum ProductStockType { limited, unlimited }

class _ProductAddScreenState extends State<ProductAddScreen> {
  ProductListItem? product = null;

  PageController pageController = PageController();
  int currentPage = 0;
  late bool isLoading = false;
  String selectedProductMainImage = "";
  String htmlDescription = "";
  List<String> selectedProductOtherImages = [];

  TextEditingController edtProductName = TextEditingController();
  TextEditingController edtProductFssaiNumber = TextEditingController();
  TextEditingController edtProductManufacturer = TextEditingController();
  TextEditingController edtProductTagsAdd = TextEditingController();

  String productTax = "";
  String productTaxId = "";

  String productBrand = "";
  String productBrandId = "";

  String productMadeIn = "";
  String productMadeInId = "";

  String productCategory = "";
  String productCategoryId = "";

  String productType = "";

  Returnable returnable = Returnable.no;
  TextEditingController edtProductReturnDays = TextEditingController();

  Cancellable cancellable = Cancellable.no;

  String productCancellableStatus = "";
  String productCancellableStatusId = "";

  TextEditingController edtProductTotalAllowedQuantity =
      TextEditingController();

  IsCodAllowed isCodAllowed = IsCodAllowed.no;

  ProductPackType productPackType = ProductPackType.packet;

  ProductStockType productStockType = ProductStockType.limited;

  TextEditingController edtProductStock = TextEditingController();

  String productMainUnit = "";
  String productMainUnitId = "";

  String productMainStockStatus = "";

  List<TextEditingController> edtProductVariantMeasurement = [];
  List<TextEditingController> edtProductVariantStock = [];
  List<TextEditingController> edtProductVariantPrice = [];
  List<TextEditingController> edtProductVariantDiscountedPrice = [];

  List<String> productVariantUnit = [];
  List<String> productVariantUnitId = [];

  List<String> productVariantStockStatus = [];
  List<String> productVariantStockStatusId = [];

  int variantsLength = 1;

  // Only for edit product params
  String productId = "";
  List<String> variantIds = [];
  String productMainImage = "";
  List<ProductDetailImages> productOtherImages = [];
  List<String> productDeletedOtherImages = [];

  List<ProductDetailVariants> variantsList = [];

  List<TagsData> selectedTags = [];

  @override
  void initState() {
    Future.delayed(Duration.zero).then((value) {
      callApi();
    });
    super.initState();
  }

  callApi() {
    if (widget.productId.isEmpty) {
      addNewVariant();
    } else {
      context.read<AddUpdateProductProvider>().productById(
          params: {"product_id": widget.productId.checkNullString()},
          context: context).then((value) {
        if (value is ProductDetail) {
          ProductDetailData productDetailData = value.data!;
          variantsLength = productDetailData.variants?.length ?? 0;

          selectedTags = productDetailData.tags ?? [];

          for (ProductDetailVariants variant
              in productDetailData.variants ?? []) {
            addExistVariant(variant: variant);
          }

          productMainImage =
              productDetailData.imageUrl?.checkNullString() ?? "";
          htmlDescription =
              productDetailData.description?.checkNullString() ?? "";
          for (ProductDetailImages otherImage
              in productDetailData.images ?? []) {
            productOtherImages.add(otherImage);
          }

          if (widget.from == "duplicate") {
            productOtherImages.clear();
            productMainImage = "";
          }

          edtProductName = TextEditingController(
              text: productDetailData.name?.checkNullString() ?? "");
          edtProductFssaiNumber = TextEditingController(
              text: productDetailData.fssaiLicNo.toString().checkNullString());
          edtProductManufacturer = TextEditingController(
              text: productDetailData.manufacturer?.checkNullString() ?? "");

          productTax = productDetailData.tax?.title?.checkNullString() ?? "";
          productTaxId = productDetailData.tax?.id?.checkNullString() ?? "";

          productBrand = productDetailData.brand?.name ?? "";
          productBrandId = productDetailData.brand?.id?.checkNullString() ?? "";

          productMadeIn =
              productDetailData.madeInCountry?.name?.checkNullString() ?? "";
          productMadeInId = productDetailData.madeIn?.checkNullString() ?? "";

          productCategory =
              productDetailData.category?.name?.checkNullString() ?? "";
          productCategoryId =
              productDetailData.categoryId?.checkNullString() ?? "";

          productType = productDetailData.indicator?.checkNullString() == "1"
              ? "Veg"
              : productDetailData.indicator?.checkNullString() == "2"
                  ? "Non Veg"
                  : "None";

          returnable = productDetailData.returnStatus?.checkNullString() == "0"
              ? Returnable.no
              : Returnable.yes;
          edtProductReturnDays = TextEditingController(
              text: productDetailData.returnDays?.checkNullString());

          cancellable =
              productDetailData.cancelableStatus?.checkNullString() == "0"
                  ? Cancellable.no
                  : Cancellable.yes;

          productCancellableStatusId =
              productDetailData.tillStatus?.checkNullString() ?? "";

          switch (productDetailData.tillStatus?.checkNullString() ?? "") {
            case '1':
              productCancellableStatus = getTranslatedValue(
                  context, "order_status_display_names_awaiting");
              break;
            case '2':
              productCancellableStatus = getTranslatedValue(
                  context, "order_status_display_names_received");
              break;
            case '3':
              productCancellableStatus = getTranslatedValue(
                  context, "order_status_display_names_processed");
              break;
            case '4':
              productCancellableStatus = getTranslatedValue(
                  context, "order_status_display_names_shipped");
              break;
            case '5':
              productCancellableStatus = getTranslatedValue(
                  context, "order_status_display_names_out_for_delivery");
              break;
            case '6':
              productCancellableStatus = getTranslatedValue(
                  context, "order_status_display_names_delivered");
              break;
            case '7':
              productCancellableStatus = getTranslatedValue(
                  context, "order_status_display_names_cancelled");
              break;
            case '8':
              productCancellableStatus = getTranslatedValue(
                  context, "order_status_display_names_returned");
              break;
            default:
              "";
          }

          edtProductTotalAllowedQuantity = TextEditingController(
              text: productDetailData.totalAllowedQuantity
                  .toString()
                  .checkNullString());

          isCodAllowed =
              productDetailData.codAllowed.toString().checkNullString() == "0"
                  ? IsCodAllowed.no
                  : IsCodAllowed.yes;

          productPackType =
              productDetailData.type.toString().checkNullString() == "packet"
                  ? ProductPackType.packet
                  : ProductPackType.loose;

          productStockType =
              productDetailData.isUnlimitedStock.toString().checkNullString() ==
                      "0"
                  ? ProductStockType.limited
                  : ProductStockType.unlimited;

          edtProductStock = TextEditingController(
              text: productPackType == ProductPackType.loose
                  ? productDetailData.variants?.first.stock
                  : "0");

          productMainUnit = productPackType == ProductPackType.loose
              ? productDetailData.variants?.first.unit?.shortCode
                      .toString()
                      .checkNullString() ??
                  ""
              : "";
          productMainUnitId = productPackType == ProductPackType.loose
              ? productDetailData.variants?.first.unit?.id
                      .toString()
                      .checkNullString() ??
                  ""
              : "";

          productMainStockStatus = productDetailData.status == "1"
              ? context.read<ProductStockStatusProvider>().productStockStatus[0]
              : context
                  .read<ProductStockStatusProvider>()
                  .productStockStatus[1];
          setState(() {});
        }
      });
    }
  }

  // Helper function to build the tag ID string
  String _buildTagIdString(List<TagsData> selectedTags) {
    List<String> tagIdStrings = selectedTags.map((tag) {
      return tag.id != null ? tag.id.toString() : tag.name!;
    }).toList();
    return tagIdStrings.join(',');
  }

  void addNewVariant({Variants? variant}) {
    edtProductVariantMeasurement.add(TextEditingController());
    edtProductVariantStock.add(TextEditingController());
    edtProductVariantPrice.add(TextEditingController());
    edtProductVariantDiscountedPrice.add(TextEditingController());
    productVariantUnit.add("");
    productVariantUnitId.add("");
    productVariantStockStatus.add("");
    productVariantStockStatusId.add("");
    context.read<AddUpdateProductProvider>().updateProductDataLoadingState();
    variantsList.add(ProductDetailVariants());
    setState(() {});
  }

  void removeVariant(int index) {
    variantsList.removeAt(index);
    edtProductVariantMeasurement.removeAt(index);
    edtProductVariantStock.removeAt(index);
    edtProductVariantPrice.removeAt(index);
    edtProductVariantDiscountedPrice.removeAt(index);
    productVariantUnit.removeAt(index);
    productVariantUnitId.removeAt(index);
    productVariantStockStatus.removeAt(index);
    productVariantStockStatusId.removeAt(index);
  }

  void addExistVariant({ProductDetailVariants? variant}) {
    variantIds.add(variant?.id?.toString() ?? "");
    edtProductVariantMeasurement
        .add(TextEditingController(text: variant?.measurement.toString()));
    edtProductVariantStock
        .add(TextEditingController(text: variant?.stock.toString()));
    edtProductVariantPrice
        .add(TextEditingController(text: variant?.price.toString()));
    edtProductVariantDiscountedPrice
        .add(TextEditingController(text: variant?.discountedPrice.toString()));
    productVariantUnit.add(variant?.unit?.shortCode?.toString() ?? "");
    productVariantStockStatus
        .add(variant?.status.toString() == "1" ? "Available" : "Sold-out");
    productVariantStockStatusId.add(variant?.status.toString() ?? "0");

    productVariantUnitId.add(variant?.stockUnitId.toString() ?? "0");

    variantsList.add(variant!);
  }

  backendApiProcess() async {
    List<String> measurement = [];
    List<String> price = [];
    List<String> discountedPrice = [];
    List<String> stock = [];
    List<String> stockUnitId = [];
    List<String> stockStatus = [];

    String type =
        productPackType == ProductPackType.packet ? "packet" : "loose";

    Map<String, String> params = {};

    if (widget.productId.isNotEmpty || widget.from != "duplicate") {
      params[ApiAndParams.id] = widget.productId;
    }

    for (int index = 0; index < variantsLength; index++) {
      if (variantsList[index].id != null) {
        params["variant_id[$index]"] = variantIds[index].toString();
      } else {
        params["variant_id[$index]"] = "0";
      }
      params["${type}_measurement[$index]"] =
          edtProductVariantMeasurement[index].text.toString();
      params["${type}_price[$index]"] =
          edtProductVariantPrice[index].text.toString();
      if (type == "packet") {
        params["discounted_price[$index]"] =
            edtProductVariantDiscountedPrice[index].text.toString();
      } else {
        params["${type}_discounted_price[$index]"] =
            edtProductVariantDiscountedPrice[index].text.toString();
      }
      if (type == "packet") {
        params["${type}_stock[$index]"] =
            productStockType == ProductStockType.unlimited
                ? "1"
                : edtProductVariantStock[index].text.toString();
        params["${type}_stock_unit_id[$index]"] = productVariantUnitId[index];
        params["${type}_status[$index]"] =
            productVariantStockStatus[index].toLowerCase() == "available"
                ? "1"
                : "0";
      }

      measurement.add(edtProductVariantMeasurement[index].text.toString());
      price.add(edtProductVariantPrice[index].text.toString());
      discountedPrice.add(
          edtProductVariantDiscountedPrice[index].text.toString().isEmpty
              ? "0"
              : edtProductVariantDiscountedPrice[index].text.toString());
      stock.add(productStockType == ProductStockType.unlimited
          ? "0"
          : edtProductVariantStock[index].text.toString());
      stockUnitId.add(productVariantUnitId[index]);
      stockStatus.add(
          productVariantStockStatus[index].toLowerCase() == "available"
              ? "1"
              : "0");
    }

    params["name"] = "${edtProductName.text.toString()}";
    params["tag_ids"] = _buildTagIdString(selectedTags);
    params["tax_id"] = productTaxId.isEmpty ? "0" : productTaxId;
    params["brand_id"] = productBrandId.isEmpty ? "0" : productBrandId;
    params["description"] = htmlDescription;
    params["type"] =
        productPackType == ProductPackType.packet ? "packet" : "loose";
    params["seller_id"] = Constant.session.getData("user_id");
    params["is_unlimited_stock"] =
        productStockType == ProductStockType.unlimited ? "1" : "0";
    params["fssai_lic_no"] = edtProductFssaiNumber.text.toString();

    if (type == "loose") {
      params["loose_stock"] = productStockType == ProductStockType.unlimited
          ? "0"
          : edtProductStock.text.toString();
      params["loose_stock_unit_id"] = productMainUnitId.toString();
      params["status"] =
          productMainStockStatus.toLowerCase() == "available" ? "1" : "0";
    }
    params["category_id"] = productCategoryId;
    params["product_type"] = productType.toLowerCase() == "none"
        ? "0"
        : productType.toLowerCase() == "veg"
            ? "1"
            : "2";
    params["manufacturer"] = edtProductManufacturer.text.toString();
    params["made_in"] = productMadeInId;
    params["shipping_type"] = "undefined";
    params["pincode_ids_exc"] = "undefined";
    params["return_status"] = returnable == Returnable.yes ? "1" : "0";
    params["return_days"] = returnable == Returnable.yes
        ? edtProductReturnDays.text.toString()
        : "0";
    params["cancelable_status"] = cancellable == Cancellable.yes ? "1" : "0";
    params["till_status"] =
        (cancellable == Cancellable.no && productCancellableStatusId.isEmpty)
            ? "0"
            : productCancellableStatusId;
    ;
    params["cod_allowed_status"] = isCodAllowed == IsCodAllowed.yes ? "1" : "0";
    params["max_allowed_quantity"] =
        edtProductTotalAllowedQuantity.text.toString();
    params["tax_included_in_price"] = "0";
    params["deleteImageIds"] = "${productDeletedOtherImages.toString()}";

    List<String> fileParamsNames = [];
    List<String> fileParamsFilesPath = [];

    if (selectedProductMainImage.isNotEmpty) {
      fileParamsNames.add("image");
    }

    for (int i = 0; i < selectedProductOtherImages.length; i++) {
      fileParamsNames.add("other_images[$i]");
    }

    if (selectedProductMainImage.isNotEmpty) {
      fileParamsFilesPath.add(selectedProductMainImage);
    }

    if (selectedProductOtherImages.isNotEmpty) {
      fileParamsFilesPath.addAll(selectedProductOtherImages);
    }

    await context
        .read<AddUpdateProductProvider>()
        .addOrUpdateProducts(
          params: params,
          fileParamsNames: fileParamsNames,
          fileParamsFilesPath: fileParamsFilesPath,
          context: context,
          isAdd: (widget.productId.isEmpty || widget.from == "duplicate"),
        )
        .then((value) async {
      if (value != null) {
        Navigator.pop(context, true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AddUpdateProductProvider>(
      builder: (context, addUpdateProductProvider, child) {
        return Scaffold(
          appBar: getAppBar(
            context: context,
            title: CustomTextLabel(
              jsonKey: (widget.productId.isEmpty || widget.from == "duplicate")
                  ? "title_add_products"
                  : "title_update_products",
              style: TextStyle(color: ColorsRes.mainTextColor),
            ),
          ),
          bottomNavigationBar: (addUpdateProductProvider
                          .sellerGetProductByIdState ==
                      SellerGetProductByIdState.loaded &&
                  addUpdateProductProvider.tagsState == TagsState.loaded)
              ? Row(
                  children: [
                    Expanded(
                      child: CustomShimmer(
                        height: 40,
                        width: context.width,
                        borderRadius: 10,
                        margin: EdgeInsetsDirectional.only(start: 10),
                      ),
                    ),
                    Expanded(
                      child: CustomShimmer(
                        height: 40,
                        width: context.width,
                        borderRadius: 10,
                        margin: EdgeInsetsDirectional.only(start: 10, end: 10),
                      ),
                    ),
                    Expanded(
                      child: CustomShimmer(
                        height: 40,
                        width: context.width,
                        borderRadius: 10,
                        margin: EdgeInsetsDirectional.only(end: 10),
                      ),
                    ),
                  ],
                )
              : Container(
                  constraints: BoxConstraints(
                    maxHeight: 60,
                  ),
                  padding: EdgeInsetsDirectional.symmetric(horizontal: 15),
                  child: StepperCounter(
                    firstCounterText: "back",
                    firstItemVoidCallback: () {
                      if (currentPage == 0) {
                        Navigator.pop(context);
                      } else {
                        currentPage--;
                        pageController.animateToPage(currentPage,
                            duration: Duration(milliseconds: 500),
                            curve: Curves.ease);
                      }
                    },
                    secondCounterText: "${currentPage + 1}/4",
                    thirdCounterText: currentPage == 3
                        ? (widget.productId.isEmpty ||
                                widget.from == "duplicate")
                            ? "add_product"
                            : "update_product"
                        : "next",
                    thirdItemVoidCallback: () =>
                        pageChangeValidation(currentPage),
                  ),
                ),
          body: addUpdateProductProvider.sellerGetProductByIdState ==
                  SellerGetProductByIdState.loading
              ? Container(
                  child: CustomShimmer(
                    width: context.width,
                    height: context.height,
                    margin: EdgeInsetsDirectional.all(10),
                    borderRadius: 10,
                  ),
                )
              : addUpdateProductProvider.sellerGetProductByIdState ==
                      SellerGetProductByIdState.loaded
                  ? PageView(
                      physics: NeverScrollableScrollPhysics(),
                      onPageChanged: (value) {
                        currentPage = value;
                        setState(
                          () {},
                        );
                      },
                      controller: pageController,
                      children: [
// 2. Product images screen
                        Container(
                          padding: EdgeInsetsDirectional.all(15),
                          alignment: Alignment.center,
                          child: Center(
                            child: ListView(
                              shrinkWrap: true,
                              physics: const ClampingScrollPhysics(),
                              children: [
                                productInfoWidgets(),
                              ],
                            ),
                          ),
                        ),
// 2. Product images screen
                        Container(
                          padding: EdgeInsetsDirectional.all(15),
                          alignment: Alignment.center,
                          child: Center(
                            child: ListView(
                              shrinkWrap: true,
                              physics: const ClampingScrollPhysics(),
                              children: [
                                productImagesSelectionWidgets(),
                              ],
                            ),
                          ),
                        ),
// 2. Product images screen
                        Container(
                          padding: EdgeInsetsDirectional.all(15),
                          alignment: Alignment.center,
                          child: Center(
                            child: ListView(
                              shrinkWrap: true,
                              physics: const ClampingScrollPhysics(),
                              children: [
                                productVariantsWidgets(),
                              ],
                            ),
                          ),
                        ),
// 4. Product other settings screen
                        Container(
                          padding: EdgeInsetsDirectional.all(15),
                          alignment: Alignment.center,
                          child: Center(
                            child: ListView(
                              shrinkWrap: true,
                              physics: const ClampingScrollPhysics(),
                              children: [
                                productOtherSettingsWidgets(),
                              ],
                            ),
                          ),
                        ),
                      ],
                    )
                  : DefaultBlankItemMessageScreen(
                      height: context.height,
                      image: "something_went_wrong",
                      title: getTranslatedValue(context, "oops_error"),
                      description:
                          getTranslatedValue(context, "oops_error_message"),
                      buttonTitle: getTranslatedValue(context, "try_again"),
                      callback: () async {
                        await callApi();
                      },
                    ),
        );
      },
    );
  }

// 1. PRODUCT INFO SCREEN
  Widget productInfoWidgets() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CustomTitleTextLabel(
              jsonKey: "product_name",
            ),
            requiredFieldSign(),
          ],
        ),
        getSizedBox(
          height: 5,
        ),
        editBoxWidget(
          maxlines: 1,
          context: context,
          edtController: edtProductName,
          validationFunction: emptyValidation,
          label: getTranslatedValue(context, "product_name"),
          hint: getTranslatedValue(context, "product_name_hint"),
          bgcolor: Theme.of(context).cardColor,
          inputType: TextInputType.text,
        ),
        getSizedBox(
          height: 15,
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ItemSelectionWidget(
                labelJsonKey: "product_tax",
                labelJsonKeyHint: "product_tax_hint",
                selectedValue: productTax,
                selectedValueId: productTaxId,
                voidCallback: () {
                  Navigator.pushNamed(context, taxesListScreen).then(
                    (value) {
                      if (value is TaxesData) {
                        productTax = "${value.title} (${value.percentage}%)";
                        productTaxId = "${value.id}";
                      }
                      setState(() {});
                    },
                  );
                },
                voidCallbackForClearField: () {
                  productTax = "";
                  productTaxId = "";
                  setState(() {});
                },
              ),
            ),
            getSizedBox(width: 10),
            Expanded(
              child: ItemSelectionWidget(
                labelJsonKey: "product_brand",
                labelJsonKeyHint: "product_brand_hint",
                selectedValue: productBrand,
                selectedValueId: productBrandId,
                voidCallback: () {
                  Navigator.pushNamed(context, brandListScreen).then(
                    (value) {
                      if (value is BrandData) {
                        productBrand = "${value.name}";
                        productBrandId = "${value.id}";
                      }
                      setState(() {});
                    },
                  );
                },
                voidCallbackForClearField: () {
                  productBrand = "";
                  productBrandId = "";
                  setState(() {});
                },
              ),
            )
          ],
        ),
        getSizedBox(
          height: 15,
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ItemSelectionWidget(
                labelJsonKey: "product_made_in",
                labelJsonKeyHint: "product_made_in_hint",
                selectedValue: productMadeIn,
                selectedValueId: productMadeInId,
                voidCallback: () {
                  Navigator.pushNamed(context, countriesListScreen).then(
                    (value) {
                      if (value is CountriesData) {
                        productMadeIn = "${value.name}";
                        productMadeInId = "${value.id}";
                        setState(() {});
                      }
                    },
                  );
                },
                voidCallbackForClearField: () {
                  productMadeIn = "";
                  productMadeInId = "";
                  setState(() {});
                },
              ),
            ),
            getSizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomTitleTextLabel(
                    jsonKey: "product_fssai_number",
                  ),
                  getSizedBox(
                    height: 5,
                  ),
                  editBoxWidget(
                    maxlines: 1,
                    context: context,
                    edtController: edtProductFssaiNumber,
                    validationFunction: optionalFieldValidation,
                    label: getTranslatedValue(context, "product_fssai_number"),
                    hint: getTranslatedValue(
                        context, "product_fssai_number_hint"),
                    bgcolor: Theme.of(context).cardColor,
                    inputType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      CustomNumberTextInputFormatter()
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
        getSizedBox(
          height: 15,
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ItemSelectionWidget(
                labelJsonKey: "product_category",
                labelJsonKeyHint: "product_category_hint",
                selectedValue: productCategory,
                selectedValueId: productCategoryId,
                isFieldRequired: true,
                voidCallback: () {
                  Navigator.pushNamed(context, categoryListScreen,
                          arguments: "product_add")
                      .then(
                    (value) {
                      if (value is CategoryData) {
                        productCategory = "${value.name}";
                        productCategoryId = "${value.id}";
                        setState(() {});
                      }
                    },
                  );
                },
              ),
            ),
            getSizedBox(width: 10),
            Expanded(
              child: ItemSelectionWidget(
                labelJsonKey: "product_type",
                labelJsonKeyHint: "product_type_hint",
                selectedValue: productType,
                selectedValueId: "0",
                voidCallback: () {
                  Navigator.pushNamed(context, productTypeScreen).then(
                    (value) {
                      if (value is String) {
                        productType = "${value}";
                        setState(() {});
                      }
                    },
                  );
                },
                voidCallbackForClearField: () {
                  productType = "";
                  setState(() {});
                },
              ),
            ),
          ],
        ),
        getSizedBox(
          height: 15,
        ),
        CustomTitleTextLabel(
          jsonKey: "product_tags",
        ),
        getSizedBox(
          height: 5,
        ),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(5),
          ),
          padding: EdgeInsets.only(left: 10, right: 10, top: 15, bottom: 15),
          width: MediaQuery.of(context).size.width,
          child: Row(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: List.generate(
                      selectedTags.length,
                      (index) {
                        return Container(
                          padding: EdgeInsetsDirectional.only(
                              start: 10, end: 10, top: 5, bottom: 5),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            color: ColorsRes.appColor,
                          ),
                          child: Row(
                            children: [
                              CustomTextLabel(
                                text: selectedTags[index].name!,
                                style: TextStyle(
                                  color: ColorsRes.appColorWhite,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, tagsListScreen,
                      arguments: selectedTags).then(
                    (value) {
                      if (value is List<TagsData>) {
                        selectedTags.clear();
                        selectedTags = value;
                      }
                      print("");
                      setState(() {});
                    },
                  );
                },
                child: Icon(
                  Icons.edit,
                  color: ColorsRes.appColor,
                ),
              ),
            ],
          ),
        ),
        getSizedBox(
          height: 15,
        ),
        CustomTitleTextLabel(
          jsonKey: "product_manufacturer",
        ),
        getSizedBox(
          height: 5,
        ),
        editBoxWidget(
          maxlines: 1,
          context: context,
          edtController: edtProductManufacturer,
          validationFunction: optionalFieldValidation,
          label: getTranslatedValue(context, "product_manufacturer"),
          hint: getTranslatedValue(context, "product_manufacturer_hint"),
          bgcolor: Theme.of(context).cardColor,
          inputType: TextInputType.text,
        ),
        getSizedBox(
          height: 15,
        ),
        Row(
          children: [
            CustomTitleTextLabel(
              jsonKey: "product_description",
            ),
            requiredFieldSign(),
          ],
        ),
        getSizedBox(
          height: 5,
        ),
        Container(
          constraints: BoxConstraints(
            minWidth: MediaQuery.sizeOf(context).width,
            minHeight: 65,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Theme.of(context).cardColor,
          ),
          child: Stack(
            children: [
              Container(
                padding: EdgeInsetsDirectional.all(10),
                child: QuillHtmlEditor(
                  text: htmlDescription.isEmpty
                      ? getTranslatedValue(context, "description_goes_here")
                      : htmlDescription,
                  hintText:
                      getTranslatedValue(context, "description_goes_here"),
                  isEnabled: false,
                  ensureVisible: false,
                  minHeight: 10,
                  autoFocus: false,
                  textStyle: TextStyle(color: ColorsRes.mainTextColor),
                  hintTextStyle: TextStyle(color: ColorsRes.subTitleTextColor),
                  hintTextAlign: TextAlign.start,
                  padding: const EdgeInsets.only(left: 10, top: 10),
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
                            arguments: htmlDescription)
                        .then(
                      (value) {
                        if (value != null) {
                          htmlDescription = value.toString();
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
      ],
    );
  }

// 2. PRODUCT IMAGE SCREEN
  Widget productImagesSelectionWidgets() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
//Product Main Image
        Row(
          children: [
            CustomTitleTextLabel(
              jsonKey: "product_main_image",
            ),
            requiredFieldSign(),
          ],
        ),
        getSizedBox(
          height: 10,
        ),
        Row(
          children: [
            if (selectedProductMainImage.isNotEmpty)
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
                  child: imgWidget(
                      fileName: selectedProductMainImage,
                      height: 90,
                      width: 90),
                ),
              ),
            if (selectedProductMainImage.isEmpty && productMainImage.isNotEmpty)
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
                  child: ClipRRect(
                    borderRadius: Constant.borderRadius10,
                    clipBehavior: Clip.antiAliasWithSaveLayer,
                    child: setNetworkImg(
                      image: productMainImage.toString(),
                      width: 90,
                      height: 90,
                      boxFit: BoxFit.fill,
                    ),
                  ),
                ),
              ),
            if (selectedProductMainImage.isNotEmpty ||
                productMainImage.isNotEmpty)
              getSizedBox(width: 10),
            Expanded(
              child: GestureDetector(
                onTap: () async {
                  hasStoragePermissionGiven().then((value) {
                    if (value) {
// Single file path
                      FilePicker.platform
                          .pickFiles(
                              type: FileType.custom,
                              allowedExtensions: ["jpg", "jpeg", "png"],
                              allowMultiple: false,
                              allowCompression: true,
                              lockParentWindow: true)
                          .then(
                        (value) {
                          selectedProductMainImage =
                              value!.paths.first.toString();
                          setState(
                            () {},
                          );
                        },
                      );
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
                            jsonKey: "upload_image_here",
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
          height: 20,
        ),
//Product Other Image
        CustomTitleTextLabel(
          jsonKey: "product_other_images",
        ),
        getSizedBox(
          height: 10,
        ),
        GestureDetector(
          onTap: () async {
            hasStoragePermissionGiven().then((value) {
              if (value) {
                // Single file path
                FilePicker.platform
                    .pickFiles(
                  allowMultiple: true,
                  allowCompression: true,
                  type: FileType.custom,
                  allowedExtensions: ["jpg", "jpeg", "png"],
                  lockParentWindow: true,
                )
                    .then(
                  (value) {
                    for (int i = 0; i < value!.files.length; i++) {
                      selectedProductOtherImages
                          .add(value.files[i].path.toString());
                    }
                    setState(
                      () {},
                    );
                  },
                );
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
                      jsonKey: "upload_images_here",
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
        if (selectedProductOtherImages.isNotEmpty ||
            productOtherImages.isNotEmpty)
          getSizedBox(
            height: 15,
          ),
        if (selectedProductOtherImages.isNotEmpty)
          LayoutBuilder(
            builder: (context, constraints) => Wrap(
              runSpacing: 15,
              spacing: constraints.maxWidth * 0.05,
              children: List.generate(
                selectedProductOtherImages.length,
                (index) => Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: ColorsRes.subTitleTextColor,
                          ),
                          color: Theme.of(context).cardColor),
                      width: constraints.maxWidth * 0.3,
                      height: constraints.maxWidth * 0.3,
                      child: Center(
                        child: imgWidget(
                            fileName: selectedProductOtherImages[index],
                            width: 105,
                            height: 105),
                      ),
                    ),
                    PositionedDirectional(
                      end: -10,
                      top: -10,
                      child: IconButton(
                        onPressed: () {
                          selectedProductOtherImages.removeAt(index);
                          setState(() {});
                        },
                        icon: CircleAvatar(
                          backgroundColor: ColorsRes.appColorRed,
                          maxRadius: 10,
                          child: Icon(
                            Icons.close_rounded,
                            color: ColorsRes.appColorWhite,
                            size: 15,
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        if (selectedProductOtherImages.isEmpty && productOtherImages.isNotEmpty)
          LayoutBuilder(
            builder: (context, constraints) => Wrap(
              runSpacing: 15,
              spacing: constraints.maxWidth * 0.05,
              children: List.generate(
                productOtherImages.length,
                (index) => Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: ColorsRes.subTitleTextColor,
                          ),
                          color: Theme.of(context).cardColor),
                      width: constraints.maxWidth * 0.3,
                      height: constraints.maxWidth * 0.3,
                      child: Center(
                        child: ClipRRect(
                          borderRadius: Constant.borderRadius10,
                          clipBehavior: Clip.antiAliasWithSaveLayer,
                          child: setNetworkImg(
                            image:
                                productOtherImages[index].imageUrl.toString(),
                            width: 110,
                            height: 110,
                            boxFit: BoxFit.fill,
                          ),
                        ),
                      ),
                    ),
                    PositionedDirectional(
                      end: -10,
                      top: -10,
                      child: IconButton(
                        onPressed: () {
                          productDeletedOtherImages
                              .add(productOtherImages[index].id.toString());
                          productOtherImages.removeAt(index);
                          setState(() {});
                        },
                        icon: CircleAvatar(
                          backgroundColor: ColorsRes.appColorRed,
                          maxRadius: 10,
                          child: Icon(
                            Icons.close_rounded,
                            color: ColorsRes.appColorWhite,
                            size: 15,
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget ItemSelectionWidget({
    required String labelJsonKey,
    required String labelJsonKeyHint,
    required VoidCallback voidCallback,
    required String selectedValue,
    required String selectedValueId,
    bool? titleRequired = true,
    bool? isFieldRequired,
    VoidCallback? voidCallbackForClearField,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (titleRequired == true)
          Row(
            children: [
              CustomTitleTextLabel(
                jsonKey: labelJsonKey,
              ),
              if (isFieldRequired == true) requiredFieldSign(),
            ],
          ),
        if (titleRequired == true)
          getSizedBox(
            height: 5,
          ),
        Container(
          height: 60,
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Expanded(
                child: Padding(
                  padding: EdgeInsetsDirectional.only(start: 10),
                  child: CustomTextLabel(
                    text:
                        (selectedValue.isNotEmpty && selectedValueId.isNotEmpty)
                            ? selectedValue
                            : getTranslatedValue(context, labelJsonKeyHint),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: selectedValue.isNotEmpty
                          ? ColorsRes.mainTextColor
                          : ColorsRes.subTitleTextColor,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
              IconButton(
                padding: EdgeInsets.zero,
                visualDensity: VisualDensity.compact,
                onPressed: voidCallback,
                icon: Icon(
                  Icons.edit_rounded,
                  color: ColorsRes.subTitleTextColor,
                  size: 20,
                ),
              ),
              if (isFieldRequired != true)
                IconButton(
                  padding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                  onPressed: voidCallbackForClearField ?? () {},
                  icon: Icon(
                    Icons.clear,
                    color: ColorsRes.subTitleTextColor,
                    size: 20,
                  ),
                )
            ],
          ),
        ),
      ],
    );
  }

// 3. PRODUCT VARIANTS SCREEN
  Widget productVariantsWidgets() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTitleTextLabel(
          jsonKey: "product_pack_type",
        ),
        getSizedBox(
          height: 5,
        ),
        Container(
          height: 60,
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    productPackType = ProductPackType.packet;
                    setState(() {});
                  },
                  child: Row(
                    children: [
                      Expanded(
                        child: Radio<ProductPackType>(
                          value: productPackType,
                          groupValue: ProductPackType.packet,
                          onChanged: (value) {
                            productPackType = ProductPackType.packet;
                            setState(() {});
                          },
                          visualDensity: VisualDensity.compact,
                        ),
                      ),
                      Expanded(
                        child: CustomTextLabel(
                          jsonKey: "product_pack_type_packet",
                          overflow: TextOverflow.ellipsis,
                        ),
                      )
                    ],
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    productPackType = ProductPackType.loose;
                    setState(() {});
                  },
                  child: Row(
                    children: [
                      Expanded(
                        child: Radio<ProductPackType>(
                          value: productPackType,
                          groupValue: ProductPackType.loose,
                          onChanged: (value) {
                            productPackType = ProductPackType.loose;
                            setState(() {});
                          },
                          visualDensity: VisualDensity.compact,
                        ),
                      ),
                      Expanded(
                        child: CustomTextLabel(
                          jsonKey: "product_pack_type_loose",
                          overflow: TextOverflow.ellipsis,
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        getSizedBox(height: 15),
        CustomTitleTextLabel(
          jsonKey: "product_stock_type",
        ),
        getSizedBox(
          height: 5,
        ),
        Container(
          height: 60,
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    productStockType = ProductStockType.limited;
                    setState(() {});
                  },
                  child: Row(
                    children: [
                      Expanded(
                        child: Radio<ProductStockType>(
                          value: productStockType,
                          groupValue: ProductStockType.limited,
                          onChanged: (value) {
                            productStockType = ProductStockType.limited;
                            setState(() {});
                          },
                          visualDensity: VisualDensity.compact,
                        ),
                      ),
                      Expanded(
                        child: CustomTextLabel(
                          jsonKey: "product_stock_type_limited",
                          overflow: TextOverflow.ellipsis,
                        ),
                      )
                    ],
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    productStockType = ProductStockType.unlimited;
                    setState(() {});
                  },
                  child: Row(
                    children: [
                      Expanded(
                        child: Radio<ProductStockType>(
                          value: productStockType,
                          groupValue: ProductStockType.unlimited,
                          onChanged: (value) {
                            productStockType = ProductStockType.unlimited;
                            setState(() {});
                          },
                          visualDensity: VisualDensity.compact,
                        ),
                      ),
                      Expanded(
                        child: CustomTextLabel(
                          jsonKey: "product_stock_type_unlimited",
                          overflow: TextOverflow.ellipsis,
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        getSizedBox(
          height: 15,
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List.generate(
            variantsLength,
            (index) {
              return Container(
                margin: EdgeInsetsDirectional.only(bottom: 15),
                padding: EdgeInsetsDirectional.all(15),
                decoration: BoxDecoration(
                  border: Border.all(color: ColorsRes.grey, width: 2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CustomTitleTextLabel(
                                    jsonKey: "product_measurement",
                                  ),
                                  requiredFieldSign(),
                                ],
                              ),
                              getSizedBox(
                                height: 5,
                              ),
                              editBoxWidget(
                                maxlines: 1,
                                context: context,
                                edtController:
                                    edtProductVariantMeasurement[index],
                                validationFunction: optionalFieldValidation,
                                label: getTranslatedValue(
                                    context, "product_measurement"),
                                hint: getTranslatedValue(
                                    context, "product_measurement_hint"),
                                bgcolor: Theme.of(context).cardColor,
                                inputType: TextInputType.numberWithOptions(
                                    decimal: true),
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                      RegExp(r'^\d+\.?\d*')),
                                ],
                              ),
                            ],
                          ),
                        ),
                        if (productPackType == ProductPackType.packet &&
                            productStockType == ProductStockType.limited)
                          getSizedBox(
                            width: 10,
                          ),
                        if (productPackType == ProductPackType.packet &&
                            productStockType == ProductStockType.limited)
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    CustomTitleTextLabel(
                                      jsonKey: "product_stock",
                                    ),
                                    requiredFieldSign(),
                                  ],
                                ),
                                getSizedBox(
                                  height: 5,
                                ),
                                editBoxWidget(
                                  maxlines: 1,
                                  context: context,
                                  edtController: edtProductVariantStock[index],
                                  validationFunction: optionalFieldValidation,
                                  label: getTranslatedValue(
                                      context, "product_stock"),
                                  hint: getTranslatedValue(
                                      context, "product_stock_hint"),
                                  bgcolor: Theme.of(context).cardColor,
                                  inputType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                    CustomNumberTextInputFormatter()
                                  ],
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    getSizedBox(
                      height: 15,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CustomTitleTextLabel(
                                    jsonKey: "product_price",
                                  ),
                                  requiredFieldSign(),
                                ],
                              ),
                              getSizedBox(
                                height: 5,
                              ),
                              editBoxWidget(
                                maxlines: 1,
                                context: context,
                                edtController: edtProductVariantPrice[index],
                                validationFunction: optionalFieldValidation,
                                label: getTranslatedValue(
                                    context, "product_price"),
                                hint: getTranslatedValue(
                                    context, "product_price_hint"),
                                bgcolor: Theme.of(context).cardColor,
                                inputType: TextInputType.numberWithOptions(
                                    decimal: true),
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                      RegExp(r'^\d+\.?\d*')),
                                ],
                              ),
                            ],
                          ),
                        ),
                        getSizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CustomTitleTextLabel(
                                jsonKey: "product_discount_price",
                              ),
                              getSizedBox(
                                height: 5,
                              ),
                              editBoxWidget(
                                maxlines: 1,
                                context: context,
                                edtController:
                                    edtProductVariantDiscountedPrice[index],
                                validationFunction: optionalFieldValidation,
                                label: getTranslatedValue(
                                    context, "product_discount_price"),
                                hint: getTranslatedValue(
                                    context, "product_discount_price_hint"),
                                bgcolor: Theme.of(context).cardColor,
                                inputType: TextInputType.numberWithOptions(
                                  decimal: true,
                                ),
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                    RegExp(r'^\d+\.?\d*'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    getSizedBox(
                      height: 15,
                    ),
                    if (productPackType == ProductPackType.packet)
                      Row(
                        children: [
                          Expanded(
                            child: ItemSelectionWidget(
                              labelJsonKey: "measurement_units",
                              labelJsonKeyHint: "measurement_units_hint",
                              voidCallback: () {
                                Navigator.pushNamed(
                                        context, measurementUnitListScreen)
                                    .then(
                                  (value) {
                                    if (value is MeasurementUnitData) {
                                      productVariantUnit[index] =
                                          "${value.shortCode}";
                                      productVariantUnitId[index] =
                                          "${value.id}";
                                      setState(() {});
                                    }
                                  },
                                );
                              },
                              selectedValue: productVariantUnit[index],
                              selectedValueId: productVariantUnitId[index],
                              isFieldRequired: true,
                            ),
                          ),
                          getSizedBox(
                            width: 10,
                          ),
                          Expanded(
                            child: ItemSelectionWidget(
                              labelJsonKey: "product_stock_status",
                              labelJsonKeyHint: "product_stock_status_hint",
                              voidCallback: () {
                                Navigator.pushNamed(
                                        context, productStockStatusScreen)
                                    .then(
                                  (value) {
                                    if (value is String) {
                                      productVariantStockStatus[index] =
                                          "${value}";
                                      setState(() {});
                                    }
                                  },
                                );
                              },
                              selectedValue: productVariantStockStatus[index],
                              selectedValueId: "0",
                              isFieldRequired: true,
                            ),
                          ),
                        ],
                      ),
                    getSizedBox(
                      height: 15,
                    ),
                    Row(
                      children: [
                        Spacer(),
                        if (variantsLength != 1)
                          GestureDetector(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: CustomTextLabel(
                                      jsonKey: "delete_variant",
                                    ),
                                    backgroundColor:
                                        Theme.of(context).cardColor,
                                    surfaceTintColor: Colors.transparent,
                                    content: CustomTextLabel(
                                      jsonKey:
                                          "are_you_sure_you_want_to_delete_variant_this_will_not_undone_again_even_you_discard_update_also",
                                      style: TextStyle(
                                        color: ColorsRes.mainTextColor,
                                        fontSize: 15,
                                      ),
                                    ),
                                    actions: [
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.pop(context);
                                        },
                                        child: CustomTextLabel(
                                          jsonKey: "cancel",
                                          softWrap: true,
                                          style: TextStyle(
                                              color:
                                                  ColorsRes.subTitleTextColor,
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      getSizedBox(width: 10),
                                      ChangeNotifierProvider(
                                        create: (context) =>
                                            DeleteProductProvider(),
                                        child: Consumer<DeleteProductProvider>(
                                          builder: (context,
                                              deleteProductProvider, child) {
                                            return GestureDetector(
                                              onTap: () async {
                                                await deleteProductProvider
                                                    .deleteProducts(
                                                        params: {
                                                      "id": variantsList[index]
                                                          .id
                                                          .toString()
                                                    },
                                                        context: context,
                                                        from:
                                                            "update_product").then(
                                                  (value) {
                                                    if (value != null) {
                                                      Navigator.pop(context);
                                                      removeVariant(index);
                                                      variantsLength--;
                                                      setState(() {});
                                                    }
                                                  },
                                                );
                                              },
                                              child: deleteProductProvider
                                                          .sellerProductDeleteState ==
                                                      SellerDeleteProductState
                                                          .loading
                                                  ? Container(
                                                      height: 24,
                                                      width: 24,
                                                      child:
                                                          CircularProgressIndicator(
                                                        color:
                                                            ColorsRes.appColor,
                                                      ),
                                                    )
                                                  : CustomTextLabel(
                                                      jsonKey: "ok",
                                                      style: TextStyle(
                                                        color:
                                                            ColorsRes.appColor,
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: ColorsRes.appColorRed,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.delete_forever_rounded,
                                    weight: 5,
                                    color: ColorsRes.appColorWhite,
                                    size: 20,
                                  ),
                                  getSizedBox(width: 5),
                                  CustomTextLabel(
                                    jsonKey: "remove",
                                    style: TextStyle(
                                      color: ColorsRes.appColorWhite,
                                    ),
                                  ),
                                ],
                              ),
                              padding: EdgeInsetsDirectional.only(
                                top: 5,
                                bottom: 5,
                                start: 20,
                                end: 20,
                              ),
                            ),
                          ),
                        if (variantsLength != 1)
                          getSizedBox(
                            width: 10,
                          ),
                        if (variantsLength - 1 == index)
                          GestureDetector(
                            onTap: () {
                              addNewVariant();
                              variantsLength++;
                              setState(() {});
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: ColorsRes.appColorGreen,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.add_circle_rounded,
                                    weight: 5,
                                    color: ColorsRes.appColorWhite,
                                    size: 20,
                                  ),
                                  getSizedBox(width: 5),
                                  CustomTextLabel(
                                    jsonKey: "add",
                                    style: TextStyle(
                                      color: ColorsRes.appColorWhite,
                                    ),
                                  ),
                                ],
                              ),
                              padding: EdgeInsetsDirectional.only(
                                top: 5,
                                bottom: 5,
                                start: 20,
                                end: 20,
                              ),
                            ),
                          ),
                        Spacer(),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        getSizedBox(
          height: 15,
        ),
        if (productPackType == ProductPackType.loose &&
            productStockType == ProductStockType.limited)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CustomTextLabel(
                    jsonKey: "product_stock",
                  ),
                  requiredFieldSign(),
                ],
              ),
              getSizedBox(
                height: 5,
              ),
              editBoxWidget(
                maxlines: 1,
                context: context,
                edtController: edtProductStock,
                validationFunction: optionalFieldValidation,
                label: getTranslatedValue(context, "product_stock"),
                hint: getTranslatedValue(context, "product_stock_hint"),
                bgcolor: Theme.of(context).cardColor,
                inputType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  CustomNumberTextInputFormatter()
                ],
              ),
            ],
          ),
        if (productPackType == ProductPackType.loose)
          getSizedBox(
            height: 15,
          ),
        if (productPackType == ProductPackType.loose)
          Row(
            children: [
              Expanded(
                child: ItemSelectionWidget(
                  labelJsonKey: "product_unit",
                  labelJsonKeyHint: "product_unit_hint",
                  voidCallback: () {
                    Navigator.pushNamed(context, measurementUnitListScreen)
                        .then(
                      (value) {
                        if (value is MeasurementUnitData) {
                          productMainUnit = "${value.shortCode}";
                          productMainUnitId = "${value.id}";
                          setState(() {});
                        }
                      },
                    );
                  },
                  selectedValue: productMainUnit,
                  selectedValueId: productMainUnitId,
                  isFieldRequired: true,
                ),
              ),
              getSizedBox(
                width: 10,
              ),
              Expanded(
                child: ItemSelectionWidget(
                  labelJsonKey: "product_stock_status",
                  labelJsonKeyHint: "product_stock_status_hint",
                  voidCallback: () {
                    Navigator.pushNamed(context, productStockStatusScreen).then(
                      (value) {
                        if (value is String) {
                          productMainStockStatus = "${value}";
                          setState(() {});
                        }
                      },
                    );
                  },
                  selectedValue: productMainStockStatus,
                  selectedValueId: "0",
                  isFieldRequired: true,
                ),
              ),
            ],
          ),
      ],
    );
  }

// 4. PRODUCT OTHER SETTING SCREEN VALIDATION
  Widget productOtherSettingsWidgets() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTitleTextLabel(
          jsonKey: "is_returnable",
        ),
        getSizedBox(
          height: 5,
        ),
        Row(
          children: [
            Expanded(
              child: Container(
                height: 60,
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    GestureDetector(
                      onTap: () {
                        returnable = Returnable.no;
                        setState(() {});
                      },
                      child: Row(
                        children: [
                          Radio<Returnable>(
                            value: returnable,
                            groupValue: Returnable.no,
                            onChanged: (value) {
                              returnable = Returnable.no;
                              setState(() {});
                            },
                            visualDensity: VisualDensity.compact,
                          ),
                          CustomTextLabel(
                            jsonKey: "no",
                          )
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        returnable = Returnable.yes;
                        setState(() {});
                      },
                      child: Row(
                        children: [
                          Radio<Returnable>(
                            value: returnable,
                            groupValue: Returnable.yes,
                            onChanged: (value) {
                              returnable = Returnable.yes;
                              setState(() {});
                            },
                            visualDensity: VisualDensity.compact,
                          ),
                          CustomTextLabel(
                            jsonKey: "yes",
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            getSizedBox(width: 10),
            Expanded(
              child: editBoxWidget(
                maxlines: 1,
                context: context,
                isEditable: returnable == Returnable.yes,
                edtController: edtProductReturnDays,
                validationFunction: optionalFieldValidation,
                label: getTranslatedValue(context, "return_days"),
                hint: getTranslatedValue(context, "return_days_hint"),
                bgcolor: Theme.of(context).cardColor,
                inputType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  CustomNumberTextInputFormatter()
                ],
              ),
            )
          ],
        ),
        getSizedBox(
          height: 15,
        ),
        CustomTitleTextLabel(
          jsonKey: "is_cancellable",
        ),
        getSizedBox(
          height: 5,
        ),
        Row(
          children: [
            Expanded(
              child: Container(
                height: 60,
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    GestureDetector(
                      onTap: () {
                        cancellable = Cancellable.no;
                        setState(() {});
                      },
                      child: Row(
                        children: [
                          Radio<Cancellable>(
                            value: cancellable,
                            groupValue: Cancellable.no,
                            onChanged: (value) {
                              cancellable = Cancellable.no;
                              setState(() {});
                            },
                            visualDensity: VisualDensity.compact,
                          ),
                          CustomTextLabel(
                            jsonKey: "no",
                          )
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        cancellable = Cancellable.yes;
                        setState(() {});
                      },
                      child: Row(
                        children: [
                          Radio<Cancellable>(
                            value: cancellable,
                            groupValue: Cancellable.yes,
                            onChanged: (value) {
                              cancellable = Cancellable.yes;
                              setState(() {});
                            },
                            visualDensity: VisualDensity.compact,
                          ),
                          CustomTextLabel(
                            jsonKey: "yes",
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            getSizedBox(width: 10),
            Expanded(
              child: ItemSelectionWidget(
                labelJsonKey: "till_which_status",
                labelJsonKeyHint: "till_which_status_hint",
                selectedValue: productCancellableStatus,
                selectedValueId: productCancellableStatusId,
                titleRequired: false,
                isFieldRequired: true,
                voidCallback: () {
                  if (cancellable == Cancellable.yes) {
                    Navigator.pushNamed(context, statusesListScreen).then(
                      (value) {
                        if (value is OrderStatusesData) {
                          productCancellableStatus = "${value.status}";
                          productCancellableStatusId = "${value.id}";
                          setState(() {});
                        }
                      },
                    );
                  } else {
                    showMessage(
                        context,
                        getTranslatedValue(
                            context, "select_cancellable_yes_first"),
                        MessageType.error);
                  }
                },
              ),
            ),
          ],
        ),
        getSizedBox(
          height: 15,
        ),
        CustomTitleTextLabel(
          jsonKey: "total_allowed_quantity",
        ),
        getSizedBox(
          height: 5,
        ),
        editBoxWidget(
          maxlines: 1,
          context: context,
          edtController: edtProductTotalAllowedQuantity,
          validationFunction: optionalFieldValidation,
          label: getTranslatedValue(context, "total_allowed_quantity"),
          hint: getTranslatedValue(context, "total_allowed_quantity_hint"),
          bgcolor: Theme.of(context).cardColor,
          inputType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            CustomNumberTextInputFormatter()
          ],
        ),
        getSizedBox(
          height: 15,
        ),
        CustomTitleTextLabel(
          jsonKey: "is_cod_allow",
        ),
        getSizedBox(
          height: 5,
        ),
        Container(
          height: 60,
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              GestureDetector(
                onTap: () {
                  isCodAllowed = IsCodAllowed.no;
                  setState(() {});
                },
                child: Row(
                  children: [
                    Radio<IsCodAllowed>(
                      value: isCodAllowed,
                      groupValue: IsCodAllowed.no,
                      onChanged: (value) {
                        isCodAllowed = IsCodAllowed.no;
                        setState(() {});
                      },
                      visualDensity: VisualDensity.compact,
                    ),
                    CustomTextLabel(
                      jsonKey: "no",
                    )
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  isCodAllowed = IsCodAllowed.yes;
                  setState(() {});
                },
                child: Row(
                  children: [
                    Radio<IsCodAllowed>(
                      value: isCodAllowed,
                      groupValue: IsCodAllowed.yes,
                      onChanged: (value) {
                        isCodAllowed = IsCodAllowed.yes;
                        setState(() {});
                      },
                      visualDensity: VisualDensity.compact,
                    ),
                    CustomTextLabel(
                      jsonKey: "yes",
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  pageChangeValidation(int currentPage) {
    switch (currentPage) {
      case 0:
        // 1. PRODUCT INFO SCREEN VALIDATION
        productInfoValidation();
      case 1:
        // 2. PRODUCT IMAGE SCREEN VALIDATION
        productImageValidation();
      case 2:
        // 3. PRODUCT VARIANT SCREEN VALIDATION
        productVariantValidation();
      case 3:
        // 4. PRODUCT OTHER SETTING SCREEN VALIDATION
        productOtherSettingsValidation();
      default:
        showMessage(context, "something_went_wrong", MessageType.error);
    }
  }

  // 1. PRODUCT INFO SCREEN VALIDATION
  void productInfoValidation() async {
    try {
      if (edtProductName.text.isEmpty) {
        showMessage(
            context,
            getTranslatedValue(context, "product_name_validation_message"),
            MessageType.error);
      } else if (productCategory.isEmpty) {
        showMessage(
            context,
            getTranslatedValue(context, "product_category_validation_message"),
            MessageType.error);
      } else if (htmlDescription.isEmpty) {
        showMessage(
            context,
            getTranslatedValue(
                context, "product_description_validation_message"),
            MessageType.error);
      } else if (edtProductFssaiNumber.text.isNotEmpty &&
          edtProductFssaiNumber.text.length != 14) {
        showMessage(
            context,
            getTranslatedValue(context, "product_fssai_validation_message"),
            MessageType.error);
      } else {
        currentPage++;
        pageController.animateToPage(currentPage,
            duration: Duration(milliseconds: 500), curve: Curves.ease);
      }
    } catch (e) {
      showMessage(context, e.toString(), MessageType.error);
    }
  }

  // 2. PRODUCT IMAGE SCREEN VALIDATION
  void productImageValidation() async {
    try {
      if (selectedProductMainImage.isEmpty &&
          (widget.productId.isEmpty || widget.from == "duplicate")) {
        showMessage(
            context,
            getTranslatedValue(
                context, "product_main_image_validation_message"),
            MessageType.error);
      } else {
        currentPage++;
        pageController.animateToPage(currentPage,
            duration: Duration(milliseconds: 500), curve: Curves.ease);
      }
    } catch (e) {
      showMessage(context, e.toString(), MessageType.error);
    }
  }

  // 3. PRODUCT VARIANTS SCREEN VALIDATION
  void productVariantValidation() async {
    try {
      await allVariantFieldsValidation().then((value) {
        if (value == true) {
          if (productPackType == ProductPackType.loose &&
              productStockType == ProductStockType.limited &&
              edtProductStock.text.isEmpty) {
            showMessage(
                context,
                getTranslatedValue(context, "stock_empty_validation_message"),
                MessageType.error);
          } else if (productPackType == ProductPackType.loose &&
              productMainUnitId.isEmpty) {
            showMessage(
                context,
                getTranslatedValue(
                    context, "measurement_unit_validation_message"),
                MessageType.error);
          } else if (productPackType == ProductPackType.loose &&
              productMainStockStatus.isEmpty) {
            showMessage(
                context,
                getTranslatedValue(context, "stock_status_validation_message"),
                MessageType.error);
          } else {
            currentPage++;
            pageController.animateToPage(currentPage,
                duration: Duration(milliseconds: 500), curve: Curves.ease);
          }
        }
      });
    } catch (e) {
      showMessage(context, e.toString(), MessageType.error);
    }
  }

  Future<bool> allVariantFieldsValidation() async {
    for (int index = 0; index < variantsLength; index++) {
      if (edtProductVariantMeasurement[index].text.isEmpty) {
        showMessage(
            context,
            "${getTranslatedValue(context, "in_variant")} ${index + 1} ${getTranslatedValue(context, "variant_measurement_empty_validation_message")}",
            MessageType.error);
        return false;
      } else if (edtProductVariantMeasurement[index].text.toDouble! <= 0.0) {
        showMessage(
            context,
            "${getTranslatedValue(context, "in_variant")} ${index + 1} ${getTranslatedValue(context, "variant_measurement_zero_validation_message")}",
            MessageType.error);
        return false;
      } else if (productPackType == ProductPackType.packet &&
          productStockType == ProductStockType.limited &&
          edtProductVariantStock[index].text.isEmpty) {
        showMessage(
            context,
            "${getTranslatedValue(context, "in_variant")} ${index + 1} ${getTranslatedValue(context, "variant_stock_zero_validation_message")}",
            MessageType.error);
        return false;
      } else if (productPackType == ProductPackType.packet &&
          productStockType == ProductStockType.limited &&
          edtProductVariantStock[index].text.toDouble! <= 0.0) {
        showMessage(
            context,
            "${getTranslatedValue(context, "in_variant")} ${index + 1} ${getTranslatedValue(context, "variant_stock_empty_validation_message")}",
            MessageType.error);
        return false;
      } else if (edtProductVariantPrice[index].text.isEmpty) {
        showMessage(
            context,
            "${getTranslatedValue(context, "in_variant")} ${index + 1} ${getTranslatedValue(context, "variant_price_empty_validation_message")}",
            MessageType.error);
        return false;
      } else if (edtProductVariantPrice[index].text.toDouble! <= 0.0) {
        showMessage(
            context,
            "${getTranslatedValue(context, "in_variant")} ${index + 1} please add price!",
            MessageType.error);
        return false;
      } else if (edtProductVariantDiscountedPrice[index].text.isNotEmpty &&
          (edtProductVariantDiscountedPrice[index].text.toString().toDouble! >=
              edtProductVariantPrice[index].text.toString().toDouble!)) {
        showMessage(
            context,
            "${getTranslatedValue(context, "in_variant")} ${index + 1} ${getTranslatedValue(context, "variant_discounted_price_and_price_validation_message")}",
            MessageType.error);
        return false;
      } else if (productPackType == ProductPackType.packet &&
          productVariantUnitId[index].isEmpty) {
        showMessage(
            context,
            "${getTranslatedValue(context, "in_variant")} ${index + 1} ${getTranslatedValue(context, "variant_measurement_unit_empty_validation_message")}",
            MessageType.error);
        return false;
      } else if (productPackType == ProductPackType.packet &&
          productVariantStockStatus[index].isEmpty) {
        showMessage(
            context,
            "${getTranslatedValue(context, "in_variant")} ${index + 1} ${getTranslatedValue(context, "variant_stock_status_empty_validation_message")}",
            MessageType.error);
        return false;
      }
    }
    return true;
  }

  // 4. PRODUCT IMAGE SCREEN VALIDATION
  void productOtherSettingsValidation() async {
    try {
      if (cancellable == Cancellable.yes &&
          productCancellableStatusId.isEmpty) {
        showMessage(
            context,
            getTranslatedValue(context,
                "product_cancelable_status_selection_validation_message"),
            MessageType.error);
      } else if (returnable == Returnable.yes &&
          edtProductReturnDays.text.isEmpty) {
        showMessage(
            context,
            getTranslatedValue(context,
                "product_returnable_status_selection_validation_message"),
            MessageType.error);
      } else {
        backendApiProcess();
      }
    } catch (e) {
      showMessage(context, e.toString(), MessageType.error);
    }
  }

  imgWidget({required String fileName, double? height, double? width}) {
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
              child: Image.file(
                File(fileName),
                width: width ?? 90,
                height: height ?? 90,
                fit: BoxFit.fill,
              ),
            ),
    );
  }

  Widget requiredFieldSign() {
    return CustomTextLabel(
      text: " * ",
      style:
          TextStyle(color: ColorsRes.appColorRed, fontWeight: FontWeight.bold),
    );
  }

  Widget CustomTitleTextLabel({required String jsonKey}) {
    return CustomTextLabel(
      jsonKey: jsonKey,
      style: TextStyle(
        color: ColorsRes.mainTextColor.withOpacity(0.8),
      ),
    );
  }
}
