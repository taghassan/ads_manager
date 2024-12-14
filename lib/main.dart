import 'package:ads_manager/ads_interval.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

export 'ads_interval.dart';
export 'ads_service.dart';
export 'ad_helper.dart';
export 'logger_utils.dart';

void main()async {
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

initGoogleAdsService({bool? stayAwake}) async {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  if (stayAwake == true) {
    WakelockPlus.enable();
  }
}
