import 'dart:async';

import 'package:ads_manager/ads_service.dart';
import 'package:ads_manager/logger_utils.dart';
import 'package:ads_manager/plus_card_container.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';

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
        HasRewardedAdsMixin ,HasBannerAd{
  Timer? timer;
  int timeStep = 2;
  int type = 0;

  AdsInitConfig? adsInitConfig;

  @override
  void onInit() async {

    initIntervalAds();
    change(null, status: RxStatus.success());

    super.onInit();
  }

  @override
  void onClose() {
    disposeNativeAds();
    disposeRewordAds();
    timer?.cancel();
    super.onClose();
  }

  initIntervalAds(){

    loadInterstitialAdAd(interstitialAdId: adsInitConfig?.interstitialAdUnitId);

    loadAdRewarded(logger: Logger(),forceUseId: adsInitConfig?.rewardedAdUnitId);

    loadBannerAd(forceUseId: adsInitConfig?.bannerAdUnitId);

    initAds(adUnitIds:adsInitConfig?.nativeAdUnitIds?? [
      'ca-app-pub-8107574011529731/1677462684',
      'ca-app-pub-8107574011529731/3520897512',
      'ca-app-pub-8107574011529731/9695984706',
      'ca-app-pub-8107574011529731/9894734170',
      'ca-app-pub-8107574011529731/3876120737',
      'ca-app-pub-8107574011529731/6893898838',
      'ca-app-pub-8107574011529731/1305797714',
      'ca-app-pub-8107574011529731/7123260860',
      'ca-app-pub-8107574011529731/3403507702',
      'ca-app-pub-8107574011529731/6303534606',
      'ca-app-pub-8107574011529731/5899648847'
    ]);

    adInterval = adsInitConfig?.adInterval??1;
  }

  void startAdsTimer() async {
    Logger().i("runs every $timeStep minutes $timer");
    if (timer != null && timer?.isActive == true) {
      timer?.cancel();
    }

    // runs every 1 second
    timer = Timer.periodic( Duration(seconds: timeStep), (timer) async {
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
}

class AdsInterval extends GetView<AdsIntervalController> {
  const AdsInterval({super.key});

  @override
  Widget build(BuildContext context) {
    return controller.obx(
      (state) => Scaffold(
        appBar: AppBar(
          title: Text(
              "${controller.formattedTime(timeInSecond: controller.timer?.tick ?? 1)} - (${controller.timeStep})"),
          actions: [
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
            IconButton(onPressed: () {
              controller.startAdsTimer();
              controller.update();
            }, icon: const Icon(Icons.check_circle_outline))
          ],
        ),
        // floatingActionButton: FloatingActionButton(onPressed: controller.startAdsTimer,),
        body: Column(
          children: [
            controller.loadBannerWidget()??const SizedBox.shrink(),
            Expanded(
              child: ListView.builder(
                itemCount: controller.loadedSuccessfullyAds.length,
                itemBuilder: (context, index) {

                  return Column(
                    children: [
                      controller.nativeAdWidget(index,useAd: controller.loadedSuccessfullyAds[index]),
                     SizedBox(
                       width: Get.width,
                       height:80,
                       child:  PlusCardContainer(child: Center(child: Text("Item $index"),),),

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
