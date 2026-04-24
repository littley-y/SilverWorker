package com.mustgooutnow.silver_worker_now

import android.content.Context
import android.view.LayoutInflater
import android.view.View
import android.widget.ImageView
import android.widget.TextView
import com.google.android.gms.ads.nativead.NativeAd
import com.google.android.gms.ads.nativead.NativeAdView
import io.flutter.plugins.googlemobileads.GoogleMobileAdsPlugin

class ListTileNativeAdFactory(private val context: Context) :
    GoogleMobileAdsPlugin.NativeAdFactory {

    override fun createNativeAd(
        nativeAd: NativeAd,
        customOptions: Map<String, Any>?
    ): NativeAdView {
        val adView = LayoutInflater.from(context)
            .inflate(R.layout.native_ad_list_tile, null) as NativeAdView

        val headlineView = adView.findViewById<TextView>(R.id.ad_headline)
        val bodyView = adView.findViewById<TextView>(R.id.ad_body)
        val iconView = adView.findViewById<ImageView>(R.id.ad_app_icon)

        headlineView.text = nativeAd.headline
        adView.headlineView = headlineView

        bodyView.text = nativeAd.body ?: ""
        adView.bodyView = bodyView

        nativeAd.icon?.let { icon ->
            iconView.setImageDrawable(icon.drawable)
            iconView.visibility = View.VISIBLE
        } ?: run {
            iconView.visibility = View.INVISIBLE
        }
        adView.iconView = iconView

        adView.setNativeAd(nativeAd)
        return adView
    }
}
