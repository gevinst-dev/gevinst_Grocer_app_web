import 'dart:core';
import 'dart:math' as math;

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'package:project/helper/generalWidgets/messageContainer.dart';
import 'package:project/helper/utils/generalImports.dart';

enum MessageType { success, error, warning }

Map<MessageType, Color> messageColors = {
  MessageType.success: Colors.green,
  MessageType.error: Colors.red,
  MessageType.warning: Colors.orange
};

Map<MessageType, Widget> messageIcon = {
  MessageType.success: defaultImg(image: "ic_done", iconColor: Colors.green),
  MessageType.error: defaultImg(image: "ic_error", iconColor: Colors.red),
  MessageType.warning:
      defaultImg(image: "ic_warning", iconColor: Colors.orange),
};

Future<bool> checkInternet() async {
  bool check = false;

  var connectivityResult = await (Connectivity().checkConnectivity());

  if (connectivityResult[0] == ConnectivityResult.mobile ||
      connectivityResult[0] == ConnectivityResult.wifi ||
      connectivityResult[0] == ConnectivityResult.ethernet) {
    check = true;
  }
  return check;
}

NetworkStatus getNetworkStatus(ConnectivityResult status) {
  return status == ConnectivityResult.mobile ||
          status == ConnectivityResult.wifi ||
          status == ConnectivityResult.ethernet
      ? NetworkStatus.Online
      : NetworkStatus.Offline;
}

showMessage(
  BuildContext context,
  String msg,
  MessageType type,
) async {
  FocusScope.of(context).unfocus(); // Unfocused any focused text field
  SystemChannels.textInput.invokeMethod('TextInput.hide'); // Close the keyboard

  OverlayState? overlayState = Overlay.of(context);
  OverlayEntry overlayEntry;
  overlayEntry = OverlayEntry(
    builder: (context) {
      return Positioned(
        left: 5,
        right: 5,
        bottom: 15,
        child: MessageContainer(
          context: context,
          text: msg,
          type: type,
        ),
      );
    },
  );
  overlayState.insert(overlayEntry);
  await Future.delayed(
    Duration(
      milliseconds: Constant.messageDisplayDuration,
    ),
  );

  overlayEntry.remove();
}

Locale getLocaleFromLangCode(String languageCode) {
  List<String> result = languageCode.split("-");
  return result.length == 1
      ? Locale(result.first)
      : Locale(result.first, result.last);
}

String setFirstLetterUppercase(String value) {
  if (value.isNotEmpty) value = value.replaceAll("_", ' ');
  return value.toTitleCase();
}

Future sendApiRequest(
    {required String apiName,
    required Map<String, dynamic> params,
    required bool isPost,
    bool? isRequestedForInvoice}) async {
  try {
    String token = Constant.session.getData(SessionManager.keyAccessToken);
    String baseUrl =
        "${Constant.hostUrl}api/${Constant.session.isSeller() == true ? "seller" : "delivery_boy"}/";

    Map<String, String> headersData = {
      "accept": "application/json",
    };

    if (token.trim().isNotEmpty) {
      headersData["Authorization"] = "Bearer $token";
    }

    headersData["x-access-key"] = "903361";

    String mainUrl = apiName.contains("http") ? apiName : "${baseUrl}$apiName";

    http.Response response;
    if (isPost) {
      response = await http.post(Uri.parse(mainUrl),
          body: params.isNotEmpty ? params : null, headers: headersData);
    } else {
      mainUrl = await Constant.getGetMethodUrlWithParams(
          apiName.contains("http") ? apiName : "${baseUrl}$apiName", params);

      response = await http.get(Uri.parse(mainUrl), headers: headersData);
    }

    if (response.statusCode == 200) {
      if (response.body == "null") {
        return null;
      }
      if (kDebugMode) {
        print(
            "API IS : $mainUrl, PARAMS : $params, CODE : ${response.statusCode}, ${response.body},");
      }
      return isRequestedForInvoice == true ? response.bodyBytes : response.body;
    } else {
      if (kDebugMode) {
        print(
            "ERROR IS API : $mainUrl, PARAMS : $params, CODE : ${response.statusCode}, ${response.body},");
      }
      return null;
    }
  } catch (e) {
    return null;
  }
}

Future sendApiMultiPartRequest(
    {required String apiName,
    required Map<String, String> params,
    required List<String>? fileParamsNames,
    required List<String>? fileParamsFilesPath}) async {
  try {
    Map<String, String> headersData = {};

    String token = Constant.session.getData(SessionManager.keyAccessToken);
    String baseUrl =
        "${Constant.hostUrl}api/${Constant.session.isSeller() == true ? "seller" : "delivery_boy"}/";

    String mainUrl = apiName.contains("http") ? apiName : "${baseUrl}$apiName";

    headersData["Authorization"] = "Bearer $token";
    headersData["x-access-key"] = "903361";
    var request = http.MultipartRequest(
      'POST',
      Uri.parse(mainUrl),
    );

    request.fields.addAll(params);

    if (fileParamsNames!.length > 0) {
      for (int i = 0; i < fileParamsNames.length; i++) {
        if (!fileParamsFilesPath![i].toString().contains("http")) {
          request.files.add(
            await http.MultipartFile.fromPath(
              fileParamsNames[i].toString(),
              fileParamsFilesPath[i].toString(),
            ),
          );
        }
      }
    }
    request.headers.addAll(headersData);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      return await response.stream.bytesToString();
    } else {
      if (kDebugMode) {
        print(
            "ERROR IS : ${json.encode(response.stream.bytesToString())}, API : $baseUrl, PARAMS : $params, CODE : ${response.statusCode}");
      }
      return null;
    }
  } catch (e) {
    if (kDebugMode) {
      print("ERROR IS CACHE : ${e.toString()}");
    }
    rethrow;
  }
}

String? validateEmail(String value) {
  String pattern =
      r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]"
      r"{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]"
      r"{0,253}[a-zA-Z0-9])?)*$";
  RegExp regex = RegExp(pattern);
  if (value.isEmpty || !regex.hasMatch(value))
    return 'Enter a valid email address';
  else
    return null;
}

emailValidation(String val, String msg) {
  return validateEmail(
    val.trim(),
  );
}

percentageValidation(String val, String msg) {
  if (val.isNotEmpty) {
    double percentage = val.toDouble!;
    if (percentage > 100 || percentage < 0) {
      return "Commission should be greater then 0% and less then 100%!";
    } else {
      return null;
    }
  } else {
    return "Commission should not be empty!";
  }
}

emptyValidation(String val, String msg) {
  if (val.trim().isEmpty) {
    return msg;
  }
  return null;
}

optionalFieldValidation(String val, String msg) {
  return null;
}

passwordValidation(String val, String msg) {
  if (val == "false") {
    return "";
  }
  return null;
}

getUserLocation() async {
  LocationPermission permission;

  permission = await Geolocator.checkPermission();

  if (permission == LocationPermission.deniedForever) {
    await Geolocator.openLocationSettings();

    getUserLocation();
  } else if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();

    if (permission != LocationPermission.whileInUse &&
        permission != LocationPermission.always) {
      await Geolocator.openLocationSettings();
      getUserLocation();
    } else {
      getUserLocation();
    }
  }
}

Future<GeoAddress?> displayPrediction(
    Prediction? p, BuildContext context) async {
  if (p != null) {
    GoogleMapsPlaces places = GoogleMapsPlaces(apiKey: Constant.googleApiKey);

    PlacesDetailsResponse detail = await places.getDetailsByPlaceId(p.placeId!);

    String zipcode = "";
    GeoAddress address = GeoAddress();

    address.placeId = p.placeId;

    for (AddressComponent component in detail.result.addressComponents) {
      if (component.types.contains('locality')) {
        address.city = component.longName;
      }
      if (component.types.contains('administrative_area_level_2')) {
        address.district = component.longName;
      }
      if (component.types.contains('administrative_area_level_1')) {
        address.state = component.longName;
      }
      if (component.types.contains('country')) {
        address.country = component.longName;
      }
      if (component.types.contains('postal_code')) {
        zipcode = component.longName;
      }
    }

    final lat = detail.result.geometry!.location.lat;
    final lng = detail.result.geometry!.location.lng;

    //if zipcode not found
    if (zipcode.trim().isEmpty) {
      zipcode = await getZipCode(lat, lng, context);
    }
//
    address.address = detail.result.formattedAddress;
    address.lattitud = lat;
    address.longitude = lng;
    address.zipcode = zipcode;
    return address;
  }
  return null;
}

getZipCode(double lat, double lng, BuildContext context) async {
  String zipcode = "";
  var result = await sendApiRequest(
    apiName: "${Constant.apiGeoCode}$lat,$lng",
    params: {},
    isPost: false,
  );
  if (result != null) {
    var getData = json.decode(result);
    if (getData != null) {
      Map data = getData['results'][0];
      List addressInfo = data['address_components'];
      for (var info in addressInfo) {
        List type = info['types'];
        if (type.contains('postal_code')) {
          zipcode = info['long_name'];
          break;
        }
      }
    }
  }
  return zipcode;
}

getPlaceName(String placeId, BuildContext context) async {
  String placeName = "";
  var result = await sendApiRequest(
    apiName: "${Constant.apiGeoCodePlaceNameByPlaceId}$placeId",
    params: {},
    isPost: false,
  );
  if (result != null) {
    Map<String, dynamic> getData = json.decode(result);
    Map<String, dynamic> data = Map.from(getData['result']);
    placeName = data['name'];
  }
  return placeName;
}

Future<Position> determinePosition() async {
  LocationPermission permission;
  permission = await Geolocator.checkPermission();

  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
  } else if (permission == LocationPermission.deniedForever) {
    return Future.error('Location Not Available');
  }

  return await Geolocator.getCurrentPosition();
}

Future<Map<String, String>> getStoreAddressFromMap(
    LatLng currentLocation, BuildContext context) async {
  try {
    Map<String, dynamic> response = json.decode(
      await sendApiRequest(
        apiName:
            "${Constant.apiGeoCode}${currentLocation.latitude},${currentLocation.longitude}",
        params: {},
        isPost: false,
      ),
    );

    final possibleLocations = response['results'] as List;
    Map location = {};
    String street = '';
    String city_id = Constant.session.getData(SessionManager.city_id);
    String state = '';
    String latitude = currentLocation.latitude.toString();
    String longitude = currentLocation.latitude.toString();
    String place_name = '';
    String formatted_address = '';

    if (possibleLocations.isNotEmpty) {
      for (var locationFullDetails in possibleLocations) {
        Map latLng = Map.from(locationFullDetails['geometry']['location']);
        double lat = double.parse(latLng['lat'].toString());
        double lng = double.parse(latLng['lng'].toString());
        place_name =
            await getPlaceName(locationFullDetails['place_id'], context);
        formatted_address = locationFullDetails['formatted_address'];
        if (lat == currentLocation.latitude &&
            lng == currentLocation.longitude) {
          location = Map.from(locationFullDetails);
          break;
        }
      }
      //If we could not find location with given lat and lng
      if (location.isNotEmpty) {
        final addressComponents = location['address_components'] as List;
        if (addressComponents.isNotEmpty) {
          for (var component in addressComponents) {
            if ((component['types'] as List).contains('sublocality') &&
                street.isEmpty) {
              street = component['long_name'].toString();
            }
            if ((component['types'] as List)
                    .contains('administrative_area_level_1') &&
                state.isEmpty) {
              state = component['long_name'].toString();
            }
          }
        }
      } else {
        location = Map.from(possibleLocations.first);
        final addressComponents = location['address_components'] as List;
        if (addressComponents.isNotEmpty) {
          for (var component in addressComponents) {
            if ((component['types'] as List).contains('sublocality') &&
                street.isEmpty) {
              street = component['long_name'].toString();
            }
            if ((component['types'] as List)
                    .contains('administrative_area_level_1') &&
                state.isEmpty) {
              state = component['long_name'].toString();
            }
          }
        }
      }

      return {
        ApiAndParams.street: street.toString().length > 0
            ? street.toString()
            : place_name.toString(),
        ApiAndParams.city_id: city_id.toString(),
        ApiAndParams.state: state.toString(),
        ApiAndParams.latitude: latitude.toString(),
        ApiAndParams.longitude: longitude.toString(),
        ApiAndParams.place_name: place_name.toString(),
        ApiAndParams.formatted_address: formatted_address.toString()
      };
    } else {
      return {"": ""};
    }
  } catch (e) {
    showMessage(context, e.toString(), MessageType.error);
    return {"": ""};
  }
}

Future<Map<String, dynamic>> getCityNameAndAddress(
    LatLng currentLocation, BuildContext context) async {
  try {
    Map<String, dynamic> response = json.decode(
      await sendApiRequest(
        apiName:
            "${Constant.apiGeoCode}${currentLocation.latitude},${currentLocation.longitude}",
        params: {},
        isPost: false,
      ),
    );

    final possibleLocations = response['results'] as List;
    Map location = {};
    String cityName = '';
    String stateName = '';
    String pinCode = '';
    String countryName = '';
    String landmark = '';
    String area = '';

    if (possibleLocations.isNotEmpty) {
      for (var locationFullDetails in possibleLocations) {
        Map latLng = Map.from(locationFullDetails['geometry']['location']);
        double lat = double.parse(latLng['lat'].toString());
        double lng = double.parse(latLng['lng'].toString());
        if (lat == currentLocation.latitude &&
            lng == currentLocation.longitude) {
          location = Map.from(locationFullDetails);
          break;
        }
      }
      //If we could not find location with given lat and lng
      if (location.isNotEmpty) {
        final addressComponents = location['address_components'] as List;
        if (addressComponents.isNotEmpty) {
          for (var component in addressComponents) {
            if ((component['types'] as List).contains('locality') &&
                cityName.isEmpty) {
              cityName = component['long_name'].toString();
            }
            if ((component['types'] as List)
                    .contains('administrative_area_level_1') &&
                stateName.isEmpty) {
              stateName = component['long_name'].toString();
            }
            if ((component['types'] as List).contains('country') &&
                countryName.isEmpty) {
              countryName = component['long_name'].toString();
            }
            if ((component['types'] as List).contains('postal_code') &&
                pinCode.isEmpty) {
              pinCode = component['long_name'].toString();
            }
            if ((component['types'] as List).contains('sublocality') &&
                landmark.isEmpty) {
              landmark = component['long_name'].toString();
            }
            if ((component['types'] as List).contains('route') &&
                area.isEmpty) {
              area = component['long_name'].toString();
            }
          }
        }
      } else {
        location = Map.from(possibleLocations.first);
        final addressComponents = location['address_components'] as List;
        if (addressComponents.isNotEmpty) {
          for (var component in addressComponents) {
            if ((component['types'] as List).contains('locality') &&
                cityName.isEmpty) {
              cityName = component['long_name'].toString();
            }
            if ((component['types'] as List)
                    .contains('administrative_area_level_1') &&
                stateName.isEmpty) {
              stateName = component['long_name'].toString();
            }
            if ((component['types'] as List).contains('country') &&
                countryName.isEmpty) {
              countryName = component['long_name'].toString();
            }
            if ((component['types'] as List).contains('postal_code') &&
                pinCode.isEmpty) {
              pinCode = component['long_name'].toString();
            }
            if ((component['types'] as List).contains('sublocality') &&
                landmark.isEmpty) {
              landmark = component['long_name'].toString();
            }
            if ((component['types'] as List).contains('route') &&
                area.isEmpty) {
              area = component['long_name'].toString();
            }
          }
        }
      }

      return {
        'address': possibleLocations.first['formatted_address'],
        'city': cityName,
        'state': stateName,
        'pin_code': pinCode,
        'country': countryName,
        'area': area,
        'landmark': landmark,
        'latitude': currentLocation.latitude,
        'longitude': currentLocation.longitude,
      };
    }
    return {};
  } catch (e) {
    showMessage(context, e.toString(), MessageType.error);
    return {};
  }
}

Future getFileFromDevice() async {
  String path = "";
  await FilePicker.platform
      .pickFiles(
          allowMultiple: false,
          allowCompression: true,
          type: FileType.custom,
          allowedExtensions: ["jpg", "jpeg", "png"],
          lockParentWindow: true)
      .then((value) {
    path = value!.paths.first.toString();
  });
  return path;
}

phoneValidation(String value, String msg) {
  String pattern = r'[0-9]';
  RegExp regExp = RegExp(pattern);
  if (value.isEmpty ||
      !regExp.hasMatch(value) ||
      value.trim().length >= 16 ||
      value.trim().length < Constant.minimumRequiredMobileNumberLength) {
    return msg;
  }
  return null;
}

String getCurrencyFormat(double amount) {
  return NumberFormat.currency(
          symbol: Constant.currency,
          decimalDigits: int.parse(Constant.currencyDecimalPoint),
          name: Constant.currencyCode)
      .format(amount);
}

maskSensitiveInformation(text) {}

String getTranslatedValue(BuildContext context, String key) {
  return context.read<LanguageProvider>().currentLanguage[key] ??
      context.read<LanguageProvider>().currentLocalOfflineLanguage[key] ??
      key;
}

Future<bool> hasStoragePermissionGiven() async {
  try {
    if (Platform.isIOS) {
      bool permissionGiven = await Permission.storage.isGranted;
      if (!permissionGiven) {
        permissionGiven = (await Permission.storage.request()).isGranted;
        return permissionGiven;
      }
      return permissionGiven;
    }
//if it is for android
    final deviceInfoPlugin = DeviceInfoPlugin();
    final androidDeviceInfo = await deviceInfoPlugin.androidInfo;
    if (androidDeviceInfo.version.sdkInt < 33) {
      bool permissionGiven = await Permission.storage.isGranted;
      if (!permissionGiven) {
        permissionGiven = (await Permission.storage.request()).isGranted;
        return permissionGiven;
      }
      return permissionGiven;
    } else {
      bool permissionGiven = await Permission.photos.isGranted;
      if (!permissionGiven) {
        permissionGiven = (await Permission.photos.request()).isGranted;
        return permissionGiven;
      }
      return permissionGiven;
    }
  } catch (e) {
    return false;
  }
}

extension StringCasingExtension on String {
  String toCapitalized() =>
      length > 0 ? '${this[0].toUpperCase()}${substring(1).toLowerCase()}' : '';

  String toTitleCase() => replaceAll(RegExp(' +'), ' ')
      .split(' ')
      .map(
        (str) => str.toCapitalized(),
      )
      .join(' ');
}

extension ContextExtension on BuildContext {
  double get width => MediaQuery.sizeOf(this).width;

  double get height => MediaQuery.sizeOf(this).height;
}

extension StringParsing on String {
  double? get toDouble => double.tryParse(this) ?? 0.0;

  double? get toInt => double.tryParse(this) ?? 0;

  int get toStringToInt => int.tryParse(this) ?? 0;

  String get currency => NumberFormat.currency(
          symbol: Constant.currency,
          decimalDigits: int.parse(Constant.currencyDecimalPoint.toString()),
          name: Constant.currencyCode)
      .format(this.toDouble);
}

extension StringToDateTimeFormatting on String {
  DateTime toDate({String format = 'd MMM y, hh:mm a'}) {
    try {
      return DateTime.parse(this).toLocal();
    } catch (e) {
      print('Error parsing date: $e');
      return DateTime.now();
    }
  }

  String formatDate(
      {String inputFormat = 'yyyy-MM-dd',
      String outputFormat = 'd MMM y, hh:mm a'}) {
    try {
      DateTime dateTime = toDate(format: inputFormat);
      return DateFormat(outputFormat).format(dateTime);
    } catch (e) {
      print('Error formatting date: $e');
      return this; // Return the original string if there's an error
    }
  }
}

class CustomNumberTextInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    // Allow only digits (0-9)
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    } else if (RegExp(r'^[0-9]*$').hasMatch(newValue.text)) {
      // Allow a single '0', but prevent multiple leading zeros
      if (newValue.text == '0') {
        return newValue; // Allow the single zero
      } else if (newValue.text.startsWith('0') && newValue.text.length > 1) {
        return oldValue; // Reject if it starts with multiple zeros
      } else {
        return newValue; // Accept valid inputs
      }
    } else {
      return oldValue; // Reject invalid inputs
    }
  }
}

class DecimalTextInputFormatter extends TextInputFormatter {
  DecimalTextInputFormatter({required this.decimalRange})
      : assert(decimalRange > 0);

  final int decimalRange;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue, // unused.
    TextEditingValue newValue,
  ) {
    TextSelection newSelection = newValue.selection;
    String truncated = newValue.text;

    String value = newValue.text;

    if (value.contains(".") &&
        value.substring(value.indexOf(".") + 1).length > decimalRange) {
      truncated = oldValue.text;
      newSelection = oldValue.selection;
    } else if (value == ".") {
      truncated = "0.";

      newSelection = newValue.selection.copyWith(
        baseOffset: math.min(truncated.length, truncated.length + 1),
        extentOffset: math.min(truncated.length, truncated.length + 1),
      );
    }

    return TextEditingValue(
      text: truncated,
      selection: newSelection,
      composing: TextRange.empty,
    );
  }
}

extension ValidateNullString on String {
  String checkNullString() => (this == "null" ? "" : this).toString();
}
