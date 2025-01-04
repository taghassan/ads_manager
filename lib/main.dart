import 'package:ads_manager/ads_interval.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

export 'package:ads_manager/main.dart';

export 'ads_interval.dart';
export 'ads_service.dart';

enum AdsButtonType { textButton, floatingActionButton }

class AdsManagerHelper {
  static openAdsPage({bool? stayAwake, bool? isTestDevice = true}) async {
    await initGoogleAdsService(
        stayAwake: stayAwake, isTestDevice: isTestDevice);
    if (!Get.isRegistered<AdsIntervalController>()) {
      Get.lazyPut(
        () => AdsIntervalController(),
      );
    }
    Get.find<AdsIntervalController>().fetchGithubAds();
    Get.to(() => const AdsInterval());
  }

 static Widget openAdsButton(
      {bool? stayAwake=true,
      bool? isTestDevice = true,
      AdsButtonType adsButtonType = AdsButtonType.textButton}) {
    var child = const Text("إدعمنا في مركز الإعلانات");
    var onPressed = openAdsPage(
      stayAwake: true,
    );

    switch (adsButtonType) {
      case AdsButtonType.textButton:
        return TextButton(
          onPressed:  onPressed,
          child: child,
        );
      case AdsButtonType.floatingActionButton:
        return FloatingActionButton(
          onPressed: onPressed,
          child: const Icon(Icons.ads_click),
        );
    }
  }
}

openAdsPage({bool? stayAwake, bool? isTestDevice = true}) async {
  await initGoogleAdsService(stayAwake: stayAwake, isTestDevice: isTestDevice);
  if (!Get.isRegistered<AdsIntervalController>()) {
    Get.lazyPut(
      () => AdsIntervalController(),
    );
  }
  Get.find<AdsIntervalController>().fetchGithubAds();
  Get.to(() => const AdsInterval());
}

void main() async {
  await initGoogleAdsService(stayAwake: true);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: '',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialBinding: AdsIntervalBinding(),
      home: const AdsInterval(),
    );
  }
}

initGoogleAdsService({bool? stayAwake, bool? isTestDevice = true}) async {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  if (stayAwake == true) {
    WakelockPlus.enable();
  }
  if (kDebugMode && isTestDevice == true) {
    // Initialize the Mobile Ads SDK
    MobileAds.instance.updateRequestConfiguration(
      RequestConfiguration(
        testDeviceIds: [
          '27ACCEE25984546D8700BEBC3B937FE8'
        ], // Replace with your device ID
      ),
    );
    MobileAds.instance.setAppMuted(false);
    MobileAds.instance.setAppVolume(1.0);
  }
}
