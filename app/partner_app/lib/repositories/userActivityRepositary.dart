import 'package:flutter/material.dart';
import 'package:project/helper/utils/generalImports.dart';

Future updateUserApiRepository(
    {required Map<String, String> params,
    required String from,
    List<String>? fileParamsFilesPath,
    List<String>? fileParamsNames}) async {
  try {
    var response = "{}";
    var apiName = from.isEmpty
        ? "${Constant.hostUrl}api/${Constant.session.isSeller() == true ? "sellers" : "delivery_boys"}/${ApiAndParams.apiUpdateUser}"
        : ApiAndParams.apiRegisterUser;

    if (from.isEmpty) {
      response = await sendApiRequest(
        apiName: apiName,
        params: params,
        isPost: true,
      );
    } else {
      response = await sendApiMultiPartRequest(
        apiName: apiName,
        params: params,
        fileParamsFilesPath: fileParamsFilesPath!,
        fileParamsNames: fileParamsNames!,
      );
    }

    return json.decode(response);
  } catch (e) {
    rethrow;
  }
}

Future<Map<String, dynamic>> getLoginRepository(
    {required Map<String, dynamic> params}) async {
  var response = await sendApiRequest(
      apiName: ApiAndParams.apiLogin, params: params, isPost: true);

  return json.decode(response);
}

Future<Map<String, dynamic>> getProfileApi(
    {required BuildContext context, required String id}) async {
  var response = await sendApiRequest(
    apiName:
        "${Constant.hostUrl}api/${Constant.session.isSeller() == true ? "sellers" : "delivery_boys"}/${ApiAndParams.apiEditProfile}/$id",
    params: {},
    isPost: false,
  );

  return await json.decode(response);
}

Future<Map<String, dynamic>> deleteUserAccount(
    {required Map<String, dynamic> params}) async {
  var response = await sendApiRequest(
      apiName: Constant.session.isSeller()
          ? ApiAndParams.apiSellerDeleteAccount
          : ApiAndParams.apiDeliveryBoyDeleteAccount,
      params: params,
      isPost: false);

  return json.decode(response);
}
