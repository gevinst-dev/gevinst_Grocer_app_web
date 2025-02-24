import 'package:flutter/material.dart';
import 'package:project/helper/utils/generalImports.dart';

class SettingsProvider extends ChangeNotifier {
  Future getSettingsApiProvider(
      Map<String, String> params, BuildContext context) async {
    try {
      Map<String, dynamic> settingsApiResponse =
          await getAppSettingsRepository(params: params);
      if (settingsApiResponse[ApiAndParams.status].toString() == "1") {
        if (Constant.session.isUserLoggedIn() && Constant.session.isSeller()) {
          AppSettingsSeller appSettings =
              AppSettingsSeller.fromJson(settingsApiResponse);
          Constant.currency = appSettings.data?.currency ?? "";
          Constant.currencyCode = appSettings.data?.currencyCode ?? "";
          Constant.sellerCommission = appSettings.data?.sellerCommission ?? "";
          Constant.privacyPolicy = appSettings.data?.privacyPolicySeller ?? "";
          Constant.termsConditions =
              appSettings.data?.termsConditionsSeller ?? "";
          Constant.currencyDecimalPoint = appSettings.data?.decimalPoint ?? "";
          Constant.appMaintenanceMode = appSettings.data?.appModeSeller ?? "";
          Constant.appMaintenanceModeRemark =
              appSettings.data?.appModeSellerRemark ?? "";
          Constant.googleApiKey = appSettings.data?.googlePlaceApiKey ?? "";
          Constant.viewCustomerDetail =
              appSettings.data?.viewCustomerDetail ?? "0";
          return true;
        } else {
          AppSettingsDeliveryBoy appSettings =
              AppSettingsDeliveryBoy.fromJson(settingsApiResponse);
          Constant.currency = appSettings.data?.currency ?? "";
          Constant.currencyCode = appSettings.data?.currencyCode ?? "";
          Constant.currencyCode = appSettings.data?.currencyCode ?? "";
          Constant.privacyPolicy =
              appSettings.data?.privacyPolicyDeliveryBoy ?? "";
          Constant.termsConditions =
              appSettings.data?.termsConditionsDeliveryBoy ?? "";
          Constant.currencyDecimalPoint = appSettings.data?.decimalPoint ?? "";
          Constant.appMaintenanceMode =
              appSettings.data?.appModeDeliveryBoy ?? "";
          Constant.appMaintenanceModeRemark =
              appSettings.data?.appModeDeliveryBoyRemark ?? "";
          Constant.googleApiKey = appSettings.data?.googlePlaceApiKey ?? "";
          return true;
        }
      } else {
        showMessage(context, settingsApiResponse[ApiAndParams.message],
            MessageType.warning);
        return false;
      }
    } catch (e) {
      showMessage(context, e.toString(), MessageType.error);
      return false;
    }
  }
}
