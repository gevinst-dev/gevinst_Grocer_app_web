import 'package:flutter/material.dart';
import 'package:project/helper/utils/generalImports.dart';
import 'package:project/models/cities.dart';
import 'package:project/provider/citiesProvider.dart';

class CityListScreen extends StatefulWidget {
  const CityListScreen({super.key});

  @override
  State<CityListScreen> createState() => _CityListScreenState();
}

class _CityListScreenState extends State<CityListScreen> {
  late ScrollController scrollController = ScrollController()
    ..addListener(activeOrdersScrollListener);

  void activeOrdersScrollListener() {
    // nextPageTrigger will have a value equivalent to 70% of the list size.
    var nextPageTrigger = 0.7 * scrollController.position.maxScrollExtent;

// _scrollController fetches the next paginated data when the current position of the user on the screen has surpassed
    if (scrollController.position.pixels >= nextPageTrigger) {
      if (mounted) {
        if (context.read<CityProvider>().hasMoreData) {
          context.read<CityProvider>().getCity(context: context);
        }
      }
    }
  }

  @override
  void initState() {
    Future.delayed(Duration.zero).then(
        (value) => context.read<CityProvider>().getCity(context: context));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: getAppBar(
        context: context,
        title: CustomTextLabel(
          jsonKey: "city",
        ),
      ),
      body: Consumer<CityProvider>(
        builder: (context, cityProvider, child) {
          if (cityProvider.cityState == CityState.loading) {
            return ListView(
              children: List.generate(
                20,
                (index) => CustomShimmer(
                  height: 60,
                  width: MediaQuery.sizeOf(context).width,
                  borderRadius: 10,
                  margin: EdgeInsets.all(10),
                ),
              ),
            );
          } else if (cityProvider.cityState == CityState.loaded ||
              cityProvider.cityState == CityState.loadingMore) {
            return ListView(
              controller: scrollController,
              children: List.generate(
                cityProvider.cities.length,
                (index) {
                  Cities? cityData = cityProvider.cities[index];
                  return Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context, cityData);
                        },
                        child: Container(
                          height: 60,
                          padding: EdgeInsets.all(10),
                          margin: EdgeInsets.all(10),
                          width: MediaQuery.sizeOf(context).width,
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: ColorsRes.appColor,
                              width: 2,
                            ),
                          ),
                          child: Center(
                            child: CustomTextLabel(
                              text: "${cityData.name}",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: ColorsRes.mainTextColor,
                              ),
                            ),
                          ),
                        ),
                      ),
                      if (index == (cityProvider.cities.length - 1) &&
                          cityProvider.cityState == CityState.loadingMore)
                        CustomShimmer(
                          height: 60,
                          width: MediaQuery.sizeOf(context).width,
                          borderRadius: 10,
                          margin: EdgeInsets.all(10),
                        ),
                    ],
                  );
                },
              ),
            );
          } else {
            return Container();
          }
        },
      ),
    );
  }
}
