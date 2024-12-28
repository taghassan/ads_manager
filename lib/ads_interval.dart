import 'dart:async';
import 'dart:math';

import 'package:ads_manager/ads_service.dart';
import 'package:ads_manager/logger_utils.dart';
import 'package:ads_manager/models/ads_init_config.dart';
import 'package:ads_manager/native_ads_list.dart';
import 'package:ads_manager/plus_card_container.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:github_client/base_data_model.dart';
import 'package:github_client/github_client.dart';
import 'package:logger/logger.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AdsIntervalBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => AdsIntervalController());
  }
}

class AdsIntervalController extends FullLifeCycleController
    with
        FullLifeCycleMixin,
        StateMixin,
        HasNativeAdsMixin,
        InterstitialAdState,
        HasRewardedAdsMixin,
        HasBannerAd {
  Timer? timer;
  int timeStep = 2;
  int type = 0;

  PackageInfo? packageInfo;

  AdsInitConfig? adsInitConfig;

  final ScrollController scrollController = ScrollController();
  Timer? scrollTimer;
  bool isScrolling = false;
  @override
  void onInit() async {
    packageInfo = await PackageInfo.fromPlatform();
    AppLogger.it.logInfo("packageInfo appName ${packageInfo?.appName}");
    update();

    await fetchGithubAds();

    // initIntervalAds();
    change(null, status: RxStatus.success());

    super.onInit();
  }

  @override
  void onClose() {
    disposeNativeAds();
    disposeRewordAds();
    timer?.cancel();

    scrollTimer?.cancel(); // Cancel the timer to prevent memory leaks
    scrollController.dispose(); // Dispose of the controller

    super.onClose();
  }

  initIntervalAds({bool? useManagerNativeAds = false, AdsInitConfig? adsConfig}) {
    loadInterstitialAdAd(interstitialAdId: adsConfig?.interstitialAdUnitId);

    loadAdRewarded(
        logger: Logger(), forceUseId: adsConfig?.rewardedAdUnitId);

    loadBannerAd(forceUseId: adsConfig?.bannerAdUnitId);

    if(adsConfig?.nativeAdUnitIds!=null){
      initAds(adUnitIds: adsConfig?.nativeAdUnitIds);
    }

    adInterval = adsConfig?.adInterval ?? 1;
    try {
      startAutoScroll();
    } catch (_) {}
  }

  initInterval({bool? useManagerNativeAds = false}) {
    // AppLogger.it.logInfo("uniqueAdsList $uniqueAdsList");
    // uniqueAdsList.shuffle(Random());
    // initAds(
    //     adUnitIds: useManagerNativeAds == false
    //         ? uniqueAdsList
    //         : (adsInitConfig?.nativeAdUnitIds ??
    //             [
    //               'ca-app-pub-8107574011529731/1677462684',
    //               'ca-app-pub-8107574011529731/3520897512',
    //               'ca-app-pub-8107574011529731/9695984706',
    //               'ca-app-pub-8107574011529731/9894734170',
    //               'ca-app-pub-8107574011529731/3876120737',
    //               'ca-app-pub-8107574011529731/6893898838',
    //               'ca-app-pub-8107574011529731/1305797714',
    //               'ca-app-pub-8107574011529731/7123260860',
    //               'ca-app-pub-8107574011529731/3403507702',
    //               'ca-app-pub-8107574011529731/6303534606',
    //               'ca-app-pub-8107574011529731/5899648847'
    //             ]));

  }

    fetchGithubAds() async {
    try {
      packageInfo = await PackageInfo.fromPlatform();
      update();
      GithubClient client = GithubClient(
          owner: "taghassan",
          token: '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');

      late BaseDataModel? response;
      if (packageInfo != null) {
        response = await client.fetchGithubData<AdsInitConfig>(
            model: AdsInitConfig(),
            pathInRepo: "apps/${packageInfo?.appName.replaceAll(" ", "_")}.json",
            repositoryName: "ads_keys",
            folder: "ads_list");
      } else {
        response = await client.fetchGithubData<AdsInitConfig>(
            model: AdsInitConfig(),
            pathInRepo: "lib/ads_list.json",
            repositoryName: "aghanilyrics_package",
            folder: "ads_list");
      }

      if (response is AdsInitConfig) {
        adsInitConfig = response;
        update();
        AppLogger.it.logDeveloper("adsInitConfig : ${adsInitConfig?.toJson()}");
        AppLogger.it.logInfo("adsInitConfig nativeAdUnitIds: ${adsInitConfig?.nativeAdUnitIds?.length}");

        update();
        Future.delayed(
          const Duration(seconds: 1),
          () => initIntervalAds(useManagerNativeAds: true,adsConfig:adsInitConfig),
        );
      }
    } catch (e) {
      AppLogger.it.logError("GithubClient response error $e");
    }
  }

  void startAutoScroll() {
    isScrolling = true;
    update();
    // if (scrollTimer == null || !scrollTimer!.isActive) {
    scrollTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (isScrolling != true) return;
      if (scrollController.hasClients) {
        double maxScroll = scrollController.position.maxScrollExtent;
        double currentScroll = scrollController.offset;
        double delta = 2.0; // Adjust this value for scroll speed

        if (currentScroll + delta >= maxScroll) {
          scrollController.jumpTo(0); // Reset to the top
        } else {
          scrollController.jumpTo(currentScroll + delta);
        }
      }
    });

    // }
  }

  void startAdsTimer() async {
    Logger().i("runs every $timeStep minutes $timer");
    if (timer != null && timer?.isActive == true) {
      timer?.cancel();
    }

    // runs every 1 second
    timer = Timer.periodic(Duration(seconds: timeStep), (timer) async {
      AppLogger.it.logInfo(timer.tick.toString());
      if (timer.tick % 60 == 0) {
        if (type % 2 == 0) {
          await showRewardedAd(
            onUserEarnedReward: (p0, p1) {
              loadAdRewarded(logger: Logger());
            },
          );
        } else {
          await interstitialAd?.show();
          loadInterstitialAdAd();
        }

        type++;
        update();
      }

      update();
    });
  }

  formattedTime({required int timeInSecond}) {
    int sec = timeInSecond % 60;
    int min = (timeInSecond / 60).floor();
    String minute = min.toString().length <= 1 ? "0$min" : "$min";
    String second = sec.toString().length <= 1 ? "0$sec" : "$sec";
    return "$minute : $second";
  }

  void stopAutoScroll() {
    scrollTimer?.cancel(); // Cancel the timer
    scrollTimer = null; // Nullify the timer

    isScrolling = false;
    update();
  }

  @override
  void onDetached() {
    // TODO: implement onDetached
    // timer?.cancel();
  }

  @override
  void onHidden() {
    // TODO: implement onHidden
    // timer?.cancel();
  }

  @override
  void onInactive() {
    // TODO: implement onInactive
    // timer?.cancel();
  }

  @override
  void onPaused() {
    // TODO: implement onPaused
    // timer?.cancel();
  }

  @override
  void onResumed() {
    // TODO: implement onResumed

    //startAdsTimer();
  }

  bool isAdLoaded({required String adId}) {
    return loadedSuccessfullyAds.firstWhereOrNull(
          (element) => element.adUnitId == adId,
        ) !=
        null;
  }
}

class AdsInterval extends GetView<AdsIntervalController> {
  const AdsInterval({super.key});

  @override
  Widget build(BuildContext context) {
    return controller.obx(
      (state) => Scaffold(
        // floatingActionButton: FloatingActionButton(onPressed: controller.fetchGithubAds),
        appBar: AppBar(
           backgroundColor: Colors.white,
          title: Text(
              "${controller.formattedTime(timeInSecond: controller.timer?.tick ?? 1)} - (${controller.timeStep})"),
          actions: [
            IconButton(
                onPressed: () => Get.defaultDialog(
                    title:
                        "Total (${controller.loadedSuccessfullyAds.length}/${controller.adsInitConfig?.nativeAdUnitIds?.length ?? 0})",
                    content: SizedBox(
                      height: Get.height * 0.7,
                      width: Get.width,
                      child: ListView.builder(
                        itemCount:
                            (controller.adsInitConfig?.nativeAdUnitIds ?? [])
                                .length,
                        itemBuilder: (context, index) => Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(15),
                              decoration: BoxDecoration(
                                  color: controller.isAdLoaded(
                                          adId: controller.adsInitConfig
                                                  ?.nativeAdUnitIds?[index] ??
                                              '')
                                      ? Colors.green
                                      : Colors.white),
                              child: Text(
                                "$index - ${controller.adsInitConfig?.nativeAdUnitIds?[index] ?? ''}",
                                style: TextStyle(
                                    color: controller.isAdLoaded(
                                            adId: controller.adsInitConfig
                                                    ?.nativeAdUnitIds?[index] ??
                                                '')
                                        ? Colors.white
                                        : null),
                              ),
                            ),
                            const Divider(),
                          ],
                        ),
                      ),
                    )),
                icon: const Icon(Icons.list_alt)),
            controller.isScrolling
                ? IconButton(
                    onPressed: () => controller.stopAutoScroll(),
                    icon: const Icon(Icons.public_off_sharp))
                : IconButton(
                    onPressed: () => controller.startAutoScroll(),
                    icon: const Icon(Icons.public)),
            controller.timer?.isActive == true
                ? IconButton(
                    onPressed: () {
                      controller.timer?.cancel();
                      controller.update();
                    },
                    icon: const Icon(Icons.stop_circle_outlined))
                : IconButton(
                    onPressed: () {
                      controller.startAdsTimer();
                      controller.update();
                    },
                    icon: const Icon(Icons.play_arrow_outlined)),
            Text(controller.type % 2 == 0 ? " R " : " I ")
          ],
        ),
        bottomNavigationBar: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              onPressed: () {
                controller.timeStep++;
                controller.update();
              },
              icon: const Icon(Icons.plus_one),
            ),
            Text("${controller.timeStep}"),
            IconButton(
              onPressed: () {
                if (controller.timeStep != 1) {
                  controller.timeStep--;
                  controller.update();
                }
              },
              icon: const Icon(Icons.exposure_minus_1),
            ),
            IconButton(
                onPressed: () {
                  controller.startAdsTimer();
                  controller.update();
                },
                icon: const Icon(Icons.check_circle_outline))
          ],
        ),
        // floatingActionButton: FloatingActionButton(onPressed: controller.startAdsTimer,),
        body: Column(
          children: [
            controller.loadBannerWidget() ?? const SizedBox.shrink(),
            Expanded(
              child: ListView.builder(
                controller: controller.scrollController,
                itemCount: controller.loadedSuccessfullyAds.length,
                itemBuilder: (context, index) {
                  AppLogger.it.logInfo(
                      "loadedSuccessfullyAds : ${controller.loadedSuccessfullyAds.length}");
                  return Column(
                    children: [
                      controller.nativeAdWidget(index,
                          useAd: controller.loadedSuccessfullyAds[index]),
                      SizedBox(
                        width: Get.width,
                        height: 80,
                        child: PlusCardContainer(
                          child: Center(
                            child: Text(
                                "Item $index (${controller.loadedSuccessfullyAds.length}/${controller.adsInitConfig?.nativeAdUnitIds?.length ?? 0})"),
                          ),
                        ),
                      )
                    ],
                  );
                  // if (controller.isAdIndex(index)) {
                  //   return controller.nativeAdWidget(index);
                  // }
                  //
                  // final itemIndex = controller.getOriginalItemIndex(index);
                  //
                  // return PlusCardContainer(child: Text("Item $itemIndex"));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
