import 'dart:developer';

import 'package:easy_audience_network/easy_audience_network.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


class AdHelper {
  static void init() {
    EasyAudienceNetwork.init(
      testMode: false, // for testing purpose but comment it before making the app live
    );
  }

  static void showInterstitialAd(VoidCallback onComplete, { String? placementId, Function()? showLoading,  Function()? hideLoading}) {
    //show loading

    if(showLoading!=null){
      showLoading();
    }
    final interstitialAd = InterstitialAd(placementId??InterstitialAd.testPlacementId);

    interstitialAd.listener = InterstitialAdListener(onLoaded: () {

      if(hideLoading!=null){
        hideLoading(); 
      }
      
      onComplete();

      interstitialAd.show();
    }, onDismissed: () {
      interstitialAd.destroy();
    }, onError: (i, e) {
      //hide loading
      Get.back();
      onComplete();

      log('interstitial error: $e');
    });

    interstitialAd.load();
  }

  static Widget nativeAd({String? placementId,}) {
    return SafeArea(
      child: NativeAd(
        placementId:placementId?? NativeAd.testPlacementId,
        adType: NativeAdType.NATIVE_AD,
        keepExpandedWhileLoading: false,
        expandAnimationDuraion: 1000,
        listener: NativeAdListener(
          onError: (code, message) => log('error'),
          onLoaded: () => log('loaded'),
          onClicked: () => log('clicked'),
          onLoggingImpression: () => log('logging impression'),
          onMediaDownloaded: () => log('media downloaded'),
        ),
      ),
    );
  }

  static Widget nativeBannerAd({String? placementId,}) {
    return SafeArea(
      child: NativeAd(
        placementId:placementId?? NativeAd.testPlacementId,
        adType: NativeAdType.NATIVE_BANNER_AD,
        bannerAdSize: NativeBannerAdSize.HEIGHT_100,
        keepExpandedWhileLoading: false,
        height: 100,
        expandAnimationDuraion: 1000,
        listener: NativeAdListener(
          onError: (code, message) => log('error'),
          onLoaded: () => log('loaded'),
          onClicked: () => log('clicked'),
          onLoggingImpression: () => log('logging impression'),
          onMediaDownloaded: () => log('media downloaded'),
        ),
      ),
    );
  }
}