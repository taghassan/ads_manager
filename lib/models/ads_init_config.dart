import 'dart:convert';
import 'dart:math';

import 'package:github_client/base_data_model.dart';
/// interstitialAdUnitId : ""
/// rewardedAdUnitId : ""
/// bannerAdUnitId : ""
/// adInterval : 0
/// nativeAdUnitIds : [""]

AdsInitConfig adsInitConfigFromJson(String str) => AdsInitConfig.fromJson(json.decode(str));
String adsInitConfigToJson(AdsInitConfig data) => json.encode(data.toJson());
class AdsInitConfig extends BaseDataModel {
  AdsInitConfig({
      List<String>? interstitialAdUnitId,
      List<String>? rewardedAdUnitId,
      List<String>? bannerAdUnitId,
      num? adInterval, 
      List<String>? nativeAdUnitIds,}){
    _interstitialAdUnitId = interstitialAdUnitId;
    _rewardedAdUnitId = rewardedAdUnitId;
    _bannerAdUnitId = bannerAdUnitId;
    _adInterval = adInterval;
    _nativeAdUnitIds = nativeAdUnitIds;
}

  AdsInitConfig.fromJson(dynamic json) {
    _interstitialAdUnitId = json['interstitialAdUnitId']!= null ? json['interstitialAdUnitId'].cast<String>() : [];
    _rewardedAdUnitId = json['rewardedAdUnitId']!= null ? json['rewardedAdUnitId'].cast<String>() : [];
    _bannerAdUnitId = json['bannerAdUnitId']!= null ? json['bannerAdUnitId'].cast<String>() : [];
    _adInterval = json['adInterval'];
    _nativeAdUnitIds = json['nativeAdUnitIds'] != null ? json['nativeAdUnitIds'].cast<String>() : [];
  }
  List<String>? _interstitialAdUnitId;
  List<String>? _rewardedAdUnitId;
  List<String>? _bannerAdUnitId;
  num? _adInterval;
  List<String>? _nativeAdUnitIds;
AdsInitConfig copyWith({  List<String>? interstitialAdUnitId,
  List<String>? rewardedAdUnitId,
  List<String>? bannerAdUnitId,
  num? adInterval,
  List<String>? nativeAdUnitIds,
}) => AdsInitConfig(  interstitialAdUnitId: interstitialAdUnitId ?? _interstitialAdUnitId,
  rewardedAdUnitId: rewardedAdUnitId ?? _rewardedAdUnitId,
  bannerAdUnitId: bannerAdUnitId ?? _bannerAdUnitId,
  adInterval: adInterval ?? _adInterval,
  nativeAdUnitIds: nativeAdUnitIds ?? _nativeAdUnitIds,
);
// generates a new Random object
  final _random =  Random();
  String? get interstitialAdUnitId => _interstitialAdUnitId?.isNotEmpty==true? ((_interstitialAdUnitId??[])..shuffle(Random())).first :null;
  String? get rewardedAdUnitId => _rewardedAdUnitId?.isNotEmpty==true? ((_rewardedAdUnitId??[])..shuffle(Random())).first :null;
  String? get bannerAdUnitId => _bannerAdUnitId?.isNotEmpty==true? ((_bannerAdUnitId??[])..shuffle(Random())).first :null;
  num? get adInterval => _adInterval;
  List<String>? get nativeAdUnitIds => _nativeAdUnitIds;

  @override
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['interstitialAdUnitId'] = _interstitialAdUnitId;
    map['rewardedAdUnitId'] = _rewardedAdUnitId;
    map['bannerAdUnitId'] = _bannerAdUnitId;
    map['adInterval'] = _adInterval;
    map['nativeAdUnitIds'] = _nativeAdUnitIds;
    return map;
  }

  @override
  BaseDataModel parser(Map<String, dynamic> json) =>AdsInitConfig.fromJson(json);

}