import 'package:flutter/material.dart';
import 'package:project/helper/utils/generalImports.dart';
import 'package:project/models/countries.dart';
import 'package:project/repositories/countriesApi.dart';

enum CountriesState {
  initial,
  loading,
  loadingMore,
  loaded,
  error,
}

class CountriesProvider extends ChangeNotifier {
  String message = '';
  CountriesState countriesState = CountriesState.initial;
  late Countries countries;

  List<CountriesData> countriesList = [];

  bool hasMoreData = false;
  int totalData = 0;
  int offset = 0;

  getCountries({required BuildContext context}) async {
    try {
      if (countriesList.length > 0) {
        countriesState = CountriesState.loadingMore;
        notifyListeners();
      } else {
        countriesState = CountriesState.loading;
        notifyListeners();
      }

      Map<String, String> params = {};
      params[ApiAndParams.limit] =
          Constant.defaultDataLoadLimitAtOnce.toString();
      params[ApiAndParams.offset] = offset.toString();

      Map<String, dynamic> getData =
          (await getCountriesApi(params: params, context: context));

      if (getData[ApiAndParams.status].toString() == "1") {
        countries = Countries.fromJson(getData);
        totalData = int.parse(countries.total.toString());

        List<CountriesData> tempCountriesList = countries.data ?? [];

        countriesList.addAll(tempCountriesList);

        hasMoreData = totalData > countriesList.length;
        if (hasMoreData) {
          offset += Constant.defaultDataLoadLimitAtOnce;
        }

        countriesState = CountriesState.loaded;
        notifyListeners();
      } else {
        countriesState = CountriesState.error;
        notifyListeners();
        showMessage(
            context, getData[ApiAndParams.message], MessageType.warning);
      }
    } catch (e) {
      message = e.toString();
      countriesState = CountriesState.error;
      showMessage(context, message, MessageType.error);
      notifyListeners();
    }
  }
}
