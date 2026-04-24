import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../config/ad_config.dart';

/// AdMob NativeAd 위젯 (ListTile 형식)
class NativeAdCard extends StatefulWidget {
  final String? keyword; // API 호환성 유지 (실제 광고 내용에는 미사용)
  final VoidCallback? onTap; // API 호환성 유지 (광고 클릭은 SDK가 처리)

  const NativeAdCard({
    super.key,
    this.keyword,
    this.onTap,
  });

  @override
  State<NativeAdCard> createState() => _NativeAdCardState();
}

class _NativeAdCardState extends State<NativeAdCard> {
  NativeAd? _nativeAd;
  bool _isLoaded = false;

  // 광고 단위 ID는 AdConfig를 통해 주입 (debug: 테스트 ID, release: 환경변수)
  static String get _adUnitId => AdConfig.nativeAdUnitId;

  @override
  void initState() {
    super.initState();
    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      _loadAd();
    }
  }

  void _loadAd() {
    _nativeAd = NativeAd(
      adUnitId: _adUnitId,
      factoryId: 'listTile',
      listener: NativeAdListener(
        onAdLoaded: (ad) {
          if (mounted) setState(() => _isLoaded = true);
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          _nativeAd = null;
        },
      ),
      request: const AdRequest(),
    )..load();
  }

  @override
  void dispose() {
    _nativeAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLoaded || _nativeAd == null) {
      return const SizedBox.shrink();
    }

    return Container(
      height: 80,
      margin: const EdgeInsets.only(bottom: 12),
      child: AdWidget(ad: _nativeAd!),
    );
  }
}
