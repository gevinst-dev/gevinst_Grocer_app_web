import 'package:flutter/material.dart';
import 'package:project/helper/utils/generalImports.dart';

Future addOrUpdateProductApi(
    {required Map<String, String> params,
    required List<String> fileParamsNames,
    required List<String> fileParamsFilesPath,
    required BuildContext context,
    required bool isAdd}) async {
  try {
    var response;

    if (fileParamsNames.isNotEmpty) {
      response = await sendApiMultiPartRequest(
        apiName:
            isAdd ? ApiAndParams.apiAddProduct : ApiAndParams.apiUpdateProduct,
        params: params,
        fileParamsFilesPath: fileParamsFilesPath,
        fileParamsNames: fileParamsNames,
      );
    } else {
      response = await sendApiRequest(
        apiName:
            isAdd ? ApiAndParams.apiAddProduct : ApiAndParams.apiUpdateProduct,
        params: params,
        isPost: true,
      );
    }

    return json.decode(response);
  } catch (e) {
    rethrow;
  }
}

Future deleteProductApi({
  required Map<String, String> params,
  required BuildContext context,
}) async {
  try {
    var response = await sendApiRequest(
      apiName: ApiAndParams.apiDeleteProduct,
      params: params,
      isPost: true,
    );

    return json.decode(response);
  } catch (e) {
    rethrow;
  }
}

Future getProductById({
  required Map<String, String> params,
  required BuildContext context,
}) async {
  try {
    var response = await sendApiRequest(
      apiName: ApiAndParams.apiGetProductProductById,
      params: params,
      isPost: false,
    );

    return json.decode(response);
  } catch (e) {
    rethrow;
  }
}

Future getTagsApi({
  required Map<String, String> params,
  required BuildContext context,
}) async {
  try {
    var response = await sendApiRequest(
      apiName: ApiAndParams.apiGetTags,
      params: params,
      isPost: false,
    );

    return json.decode(response);
  } catch (e) {
    rethrow;
  }
}
