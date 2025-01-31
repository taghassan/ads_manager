import 'dart:io';
import 'dart:isolate';

import 'package:ads_manager/consent_manager.dart';
import 'package:app_logger/app_logger.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:logger/src/logger.dart';

class ListNativeAdUnits {
  //='ca-app-pub-8107574011529731/1677462684'
  ListNativeAdUnits(
      {required this.adUnitId, this.onAdLoaded, this.onAdFailedToLoad});

  NativeAd? nativeAd;
  final String adUnitId;
  final void Function(Ad, NativeAd?)? onAdLoaded;
  final dynamic Function(Ad, LoadAdError)? onAdFailedToLoad;
  bool nativeAdIsLoaded = false;

  /// Loads a native ad.
  void loadAd() {
    nativeAd = NativeAd(
        adUnitId: adUnitId,
        listener: NativeAdListener(
          onAdLoaded: (ad) {
            debugPrint('$NativeAd loaded.');

            nativeAdIsLoaded = true;
            if (onAdLoaded != null) {
              onAdLoaded!(ad, nativeAd);
            }
          },
          onAdFailedToLoad: (ad, error) {
            if (onAdFailedToLoad != null) {
              onAdFailedToLoad!(ad, error);
            }
            // Dispose the ad here to free resources.
            debugPrint('$NativeAd failed to load: $error');
            ad.dispose();
          },
        ),
        request: const AdManagerAdRequest(),
        // Styling
        nativeTemplateStyle: NativeTemplateStyle(
            // Required: Choose a template.
            templateType: TemplateType.medium,
            // Optional: Customize the ad's style.
            mainBackgroundColor: Colors.purple,
            cornerRadius: 10.0,
            callToActionTextStyle: NativeTemplateTextStyle(
                textColor: Colors.cyan,
                backgroundColor: Colors.red,
                style: NativeTemplateFontStyle.monospace,
                size: 16.0),
            primaryTextStyle: NativeTemplateTextStyle(
                textColor: Colors.red,
                backgroundColor: Colors.cyan,
                style: NativeTemplateFontStyle.italic,
                size: 16.0),
            secondaryTextStyle: NativeTemplateTextStyle(
                textColor: Colors.green,
                backgroundColor: Colors.black,
                style: NativeTemplateFontStyle.bold,
                size: 16.0),
            tertiaryTextStyle: NativeTemplateTextStyle(
                textColor: Colors.brown,
                backgroundColor: Colors.amber,
                style: NativeTemplateFontStyle.normal,
                size: 16.0)))
      ..load();
  }
}

mixin InterstitialAdState {
  InterstitialAd? interstitialAd;

  //العادي
  // ca-app-pub-8107574011529731/1224238366
  //اسعار الشريك
  //ca-app-pub-8107574011529731/2613902731
  var interstitialAdUnitId = Platform.isAndroid
      ? 'ca-app-pub-8107574011529731/1224238366'
      : 'ca-app-pub-8107574011529731/1224238366';

  /// Loads an interstitial ad.
  void loadInterstitialAdAd({String? interstitialAdId}) {
    InterstitialAd.load(
        adUnitId: interstitialAdId ?? interstitialAdUnitId,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          // Called when an ad is successfully received.
          onAdLoaded: (ad) {
            debugPrint('$ad loaded.');
            // Keep a reference to the ad so you can show it later.
            interstitialAd = ad;
          },

          // Called when an ad request failed.
          onAdFailedToLoad: (LoadAdError error) {
            debugPrint('InterstitialAd failed to load: $error');
          },
        ));
  }

  void showAlert(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text('Game Over'),
              content: const Text('You lasted '),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    interstitialAd?.show();
                  },
                  child: const Text('OK'),
                )
              ],
            ));
  }
}

mixin HasRewardedAdsMixin {
  RewardedAd? rewardedAd;
  var loadTry = 0;
  var rewardedAdUnitId = Platform.isAndroid
      ? 'ca-app-pub-8107574011529731/9783786052'
      : 'ca-app-pub-8107574011529731/9783786052';

  /// Loads a rewarded ad.
  void loadAdRewarded({Logger? logger, String? forceUseId}) {
    RewardedAd.load(
        adUnitId: forceUseId ?? rewardedAdUnitId,
        request: const AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          // Called when an ad is successfully received.
          onAdLoaded: (ad) {
            ad.fullScreenContentCallback = FullScreenContentCallback(
                // Called when the ad showed the full screen content.
                onAdShowedFullScreenContent: (ad) {},
                // Called when an impression occurs on the ad.
                onAdImpression: (ad) {},
                // Called when the ad failed to show full screen content.
                onAdFailedToShowFullScreenContent: (ad, err) {
                  // Dispose the ad here to free resources.
                  ad.dispose();
                },
                // Called when the ad dismissed full screen content.
                onAdDismissedFullScreenContent: (ad) {
                  // Dispose the ad here to free resources.
                  ad.dispose();
                },
                // Called when a click is recorded for an ad.
                onAdClicked: (ad) {});

            logger?.i('$ad loaded.');
            // Keep a reference to the ad so you can show it later.
            rewardedAd = ad;
          },
          // Called when an ad request failed.
          onAdFailedToLoad: (LoadAdError error) {
            logger?.e('RewardedAd failed to load: $error');

            loadTry = loadTry + 1;

            if (loadTry <= 5) {
              loadAdRewarded();
            } else {
              loadTry = 0;
            }
          },
        ));
  }

  showRewardedAd(
      {required void Function(AdWithoutView, RewardItem)
          onUserEarnedReward}) async {
    await rewardedAd?.show(onUserEarnedReward: onUserEarnedReward);
  }

  disposeRewordAds() {
    rewardedAd?.dispose();
  }
}

//

mixin HasBannerAd {
  /**
   *
   */

  BannerAd? bannerAd;
  bool isLoaded = false;

  // TODO: replace this test ad unit with your own ad unit.
  String bannerAdUnitId = Platform.isAndroid
      ? 'ca-app-pub-8107574011529731/2912692739'
      : 'ca-app-pub-8107574011529731/2912692739';

  /// Loads a banner ad.
  void loadBannerAd({String? forceUseId}) {
    bannerAd = BannerAd(
      adUnitId: forceUseId ?? bannerAdUnitId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        // Called when an ad is successfully received.
        onAdLoaded: (ad) {
          debugPrint('$ad loaded.');

          isLoaded = true;
        },
        // Called when an ad request failed.
        onAdFailedToLoad: (ad, err) {
          debugPrint('BannerAd failed to load: $err');
          // Dispose the ad here to free resources.
          ad.dispose();
        },
      ),
    )..load();
  }

  BannerAd createAndLoadBannerAd({String? forceUseId}) {
    return BannerAd(
      adUnitId: forceUseId ?? bannerAdUnitId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        // Called when an ad is successfully received.
        onAdLoaded: (ad) {
          debugPrint('$ad loaded.');

          isLoaded = true;
        },
        // Called when an ad request failed.
        onAdFailedToLoad: (ad, err) {
          debugPrint('BannerAd failed to load: $err');
          // Dispose the ad here to free resources.
          ad.dispose();
        },
      ),
    )..load();
  }

  Widget loadBannerWidget({BannerAd? banner}) {
    if (bannerAd != null && isLoaded == true || banner != null) {
      BannerAd? bannerAdToUse = banner ?? bannerAd;

      return bannerAdToUse != null
          ? Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: SizedBox(
                width: bannerAdToUse.size.width.toDouble(),
                height: bannerAdToUse.size.height.toDouble(),
                child: AdWidget(ad: bannerAdToUse),
              ),
            )
          : const SizedBox.shrink();
    }
    return const SizedBox.shrink();
  }

  disposeBannerAd() {
    bannerAd?.dispose();
  }
}

class AddModel {
  final String? adUnitId;
  final Ad? adUnit;
  final NativeAd? nativeAd;
  final int? code;
  final LoadAdError? error;

  AddModel({this.adUnitId, this.adUnit, this.nativeAd, this.code, this.error});
}

mixin HasNativeAdsMixin on GetxController {
  Logger adsMixinLogger = Logger();
  List<String> adUnitId = [];
  List<String?> loadedToScreenAdIds = [];
  List<AddModel> loadedSuccessfullyAds = [];
  List<AddModel> failedToLoadAds = [];
  num adInterval = 10;

  int loadedAdIndex(int index) => ((index / adInterval) - 1).toInt();

  AddModel? getAdItem(int index) {
    int loadedAdIndexValue = loadedAdIndex(index);
    // AppLogger.it.logWarning("loadedAdIndexValue $index $loadedAdIndexValue");
    // controller.bregAraabSongs.logger.i("loadedAdIndex $loadedAdIndex $adItem ${controller.loadedSuccessfullyAds.length}");
    return loadedAdIndexValue < loadedSuccessfullyAds.length
        ? loadedSuccessfullyAds[loadedAdIndexValue]
        : null;
  }

  initAds({List<String>? adUnitIds}) async {
    loadedToScreenAdIds.clear();
    final receivePort = ReceivePort();
    Isolate.spawn(prepareAdData, receivePort.sendPort);

    adUnitId = adUnitIds ?? [];

    try {
      // Listen for data from the isolate
      receivePort.listen((data) {
        if (data is AdRequest) {
          AppLogger.it.logInfo("adUnitIds ${adUnitIds?.length}");
          for (String adId in adUnitId) {
            try {
              adsMixinLogger.w("adId = $adId");
              ListNativeAdUnits adUnits = ListNativeAdUnits(
                adUnitId: adId,
                onAdLoaded: (p0, p1) {
                  adsMixinLogger.w("p0.adUnitId ${p0.adUnitId}");
                  loadedSuccessfullyAds.add(AddModel(
                      adUnitId: p0.adUnitId, adUnit: p0, nativeAd: p1));

                  //***************** created by TajEldeen *****************//
                  // remove loaded ads from failed ads
                  //********************************************************//
                  failedToLoadAds.removeWhere(
                    (element) => element.adUnitId == p0.adUnitId,
                  );

                  update();
                },
                onAdFailedToLoad: (p0, error) {
                  failedToLoadAds.add(
                    AddModel(
                        adUnitId: p0.adUnitId,
                        adUnit: p0,
                        code: error.code,
                        error: error),
                  );

                  adsMixinLogger.e("p0.adUnitId error ${p0.adUnitId}");
                  adsMixinLogger.e("message ${error.message}");
                  adsMixinLogger.e("code ${error.code}");
                  adsMixinLogger.e("domain ${error.domain}");
                  adsMixinLogger.e("responseInfo ${error.responseInfo}");
                },
              );
              adUnits.loadAd();
            } catch (e) {
              AppLogger.it.logError("adUnit error $adId\n$e ");
            }
          }

          //end of data from the isolate
        }
      });
    } catch (_) {}
  }

  static void prepareAdData(SendPort sendPort) {
    // Prepare the AdRequest or other ad-related data here
    const adRequest = AdRequest(); // You can configure this as needed

    // Send the data back to the main isolate
    sendPort.send(adRequest);
  }

  Widget nativeAdWidget(int index, {AddModel? useAd}) {
    AddModel? adItem;
    if (useAd == null) {
      adItem = getAdItem(index);
    } else {
      adItem = useAd;
    }

    if (adItem != null) {
      loadedToScreenAdIds.add(adItem.adUnitId);

      return adItem.nativeAd != null
          ? ConstrainedBox(
              constraints: const BoxConstraints(
                minWidth: 320, // minimum recommended width
                minHeight: 90, // minimum recommended height
                maxWidth: 400,
                maxHeight: 200,
              ),
              child: AdWidget(
                ad: adItem.nativeAd!,
              ),
            )
          : const SizedBox.shrink();
    }
    return const SizedBox.shrink();
  }

// Helper method to get the original item index for non-ad indices
  int getOriginalItemIndex(int index) {
    return index - (index ~/ (adInterval + 1));
  }

// Helper method to determine if an index should contain an ad
  bool isAdIndex(int index) {
    return (index + 1) % (adInterval + 1) ==
        0; // Every 10 items (0-based index, so every 11th item in the view)
  }

  disposeNativeAds() {
    for (AddModel ad in loadedSuccessfullyAds) {
      try {
        ad.nativeAd?.dispose();
      } catch (e) {}
    }
  }
}

class BannerAdWidget extends StatelessWidget {
  final String placementId;
  final String? placementIdIos;

  const BannerAdWidget(
      {super.key, required this.placementId, this.placementIdIos});

  @override
  Widget build(BuildContext context) {
    return Container();
    // return Container(
    //   alignment: const Alignment(0.5, 1),
    //   child: banner_ad.BannerAd(
    //     placementId: Platform.isAndroid
    //         ? placementId
    //         : placementIdIos??'',
    //     bannerSize: banner_ad.BannerSize.STANDARD,
    //     listener: banner_ad.BannerAdListener(
    //       onError: (code, message) => AppLogger.it.logError('error $code $message'),
    //       onLoaded: () => AppLogger.it.logInfo('loaded'),
    //       onClicked: () => AppLogger.it.logInfo('clicked'),
    //       onLoggingImpression: () => AppLogger.it.logInfo('logging impression'),
    //     ),
    //   ),
    // );
  }
}

class ShowNativeAdWidget extends StatelessWidget {
  final String placementId;
  final String? placementIdIos;

  const ShowNativeAdWidget(
      {super.key, required this.placementId, this.placementIdIos});

  @override
  Widget build(BuildContext context) {
    return Container();
    // return   native_ad.NativeAd(
    //   placementId: placementId,
    //   adType: native_ad.NativeAdType.NATIVE_AD,
    //   bannerAdSize: native_ad.NativeBannerAdSize.HEIGHT_100,
    //   width: double.infinity,
    //   backgroundColor: Colors.blue,
    //   titleColor: Colors.white,
    //   descriptionColor: Colors.white,
    //   buttonColor: Colors.deepPurple,
    //   buttonTitleColor: Colors.white,
    //   buttonBorderColor: Colors.white,
    //   listener: native_ad.NativeAdListener(
    //     onError: (code, message) => AppLogger.it.logError('error $code $message'),
    //     onLoaded: () => AppLogger.it.logInfo('loaded'),
    //     onClicked: () => AppLogger.it.logInfo('clicked'),
    //     onLoggingImpression: () => AppLogger.it.logInfo('logging impression'),
    //     onMediaDownloaded: () => AppLogger.it.logInfo('media downloaded'),
    //   ),
    // );
  }
}

mixin AppOpenAdManager {
  /// Maximum duration allowed between loading and showing the ad.
  final Duration maxCacheDuration = const Duration(hours: 4);

  /// Keep track of load time so we don't show an expired ad.
  DateTime? _appOpenLoadTime;

  String appOpenAdUnitId = Platform.isAndroid
      ? 'ca-app-pub-8107574011529731/1312576117'
      : 'ca-app-pub-8107574011529731/1312576117';

  AppOpenAd? _appOpenAd;
  bool _isShowingAd = false;

  /// Load an [AppOpenAd].
  void appOpenLoadAd({String? adUnitId}) async {
    // Only load an ad if the Mobile Ads SDK has gathered consent aligned with
    // the app's configured messages.
    var canRequestAds = await ConsentManager.instance.canRequestAds();
    if (!canRequestAds) {
      return;
    }

    AppOpenAd.load(
      adUnitId: adUnitId ?? appOpenAdUnitId,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          AppLogger.it.logInfo('$ad loaded');
          _appOpenLoadTime = DateTime.now();
          _appOpenAd = ad;
        },
        onAdFailedToLoad: (error) {
          AppLogger.it.logError('AppOpenAd failed to load: $error');
        },
      ),
    );
  }

  /// Whether an ad is available to be shown.
  bool get isAdAvailable {
    return _appOpenAd != null;
  }

  /// Shows the ad, if one exists and is not already being shown.
  ///
  /// If the previously cached ad has expired, this just loads and caches a
  /// new ad.
  void showAdIfAvailable() {
    if (!isAdAvailable) {
      AppLogger.it.logError('Tried to show ad before available.');
      appOpenLoadAd();
      return;
    }
    if (_isShowingAd) {
      AppLogger.it.logError('Tried to show ad while already showing an ad.');
      return;
    }
    if (DateTime.now().subtract(maxCacheDuration).isAfter(_appOpenLoadTime!)) {
      AppLogger.it
          .logError('Maximum cache duration exceeded. Loading another ad.');
      _appOpenAd!.dispose();
      _appOpenAd = null;
      appOpenLoadAd();
      return;
    }
    // Set the fullScreenContentCallback and show the ad.
    _appOpenAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        _isShowingAd = true;
        AppLogger.it.logInfo('$ad onAdShowedFullScreenContent');
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        AppLogger.it.logError('$ad onAdFailedToShowFullScreenContent: $error');
        _isShowingAd = false;
        ad.dispose();
        _appOpenAd = null;
      },
      onAdDismissedFullScreenContent: (ad) {
        AppLogger.it.logInfo('$ad onAdDismissedFullScreenContent');
        _isShowingAd = false;
        ad.dispose();
        _appOpenAd = null;
        appOpenLoadAd();
      },
    );
    _appOpenAd!.show();
  }
}

mixin RewardedInterstitialAdMixin {
  RewardedInterstitialAd? _rewardedInterstitialAd;
  bool _isAdLoaded = false;

  /// Loads a rewarded interstitial ad with the given [adUnitId].
  void loadRewardedInterstitialAd({required String adUnitId}) {
    RewardedInterstitialAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      rewardedInterstitialAdLoadCallback: RewardedInterstitialAdLoadCallback(
        onAdLoaded: (RewardedInterstitialAd ad) {
          _rewardedInterstitialAd = ad;
          _isAdLoaded = true;
          _rewardedInterstitialAd?.fullScreenContentCallback =
              FullScreenContentCallback(
            onAdDismissedFullScreenContent: (RewardedInterstitialAd ad) {
              ad.dispose();
              _rewardedInterstitialAd = null;
              _isAdLoaded = false;
              debugPrint('Ad dismissed.');
            },
            onAdFailedToShowFullScreenContent:
                (RewardedInterstitialAd ad, AdError error) {
              ad.dispose();
              _rewardedInterstitialAd = null;
              _isAdLoaded = false;
              debugPrint('Ad failed to show: $error');
            },
          );
          debugPrint('Ad loaded successfully.');
        },
        onAdFailedToLoad: (LoadAdError error) {
          debugPrint('Failed to load ad: $error');
          _isAdLoaded = false;
        },
      ),
    );
  }

  /// Checks if the rewarded interstitial ad is loaded.
  bool isRewardedInterstitialAdLoaded() => _isAdLoaded;

  /// Shows the rewarded interstitial ad if it's loaded.
  void showRewardedInterstitialAd({required VoidCallback onAdRewarded}) {
    if (_rewardedInterstitialAd == null) {
      debugPrint('Ad is not loaded yet.');
      return;
    }

    _rewardedInterstitialAd?.show(
        onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
      debugPrint('User earned reward: ${reward.amount} ${reward.type}');
      onAdRewarded();
    });
    _rewardedInterstitialAd = null;
    _isAdLoaded = false;
  }

  /// Dispose of the ad when it's no longer needed.
  void disposeRewardedInterstitialAd() {
    _rewardedInterstitialAd?.dispose();
    _rewardedInterstitialAd = null;
  }
}
