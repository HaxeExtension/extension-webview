package com.arcademonk.haxe;

import android.util.Log;
import android.webkit.WebSettings;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import android.view.View;
import android.view.KeyEvent;
import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.view.ViewGroup;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.graphics.Color;
import android.util.DisplayMetrics;
import org.haxe.nme.GameActivity;
import org.haxe.nme.HaxeObject;

class NMEWebView
{
	public static HaxeObject HaxeListenerClass;
	public static View view;
	public static WebView webView;
	
	public static void APIInit(HaxeObject _haxeListenerClass, boolean withPopup)
	{
		if(NMEWebView.webView != null) NMEWebView.APIDestroy();
		
		NMEWebView.HaxeListenerClass = _haxeListenerClass;
		
		View view;
		
		WebView webView = new WebView(GameActivity.getContext());
		webView.setVerticalScrollBarEnabled(false);
        webView.setHorizontalScrollBarEnabled(false);
		webView.setWebViewClient(new WebViewClient() {
			@Override
			public boolean shouldOverrideUrlLoading(WebView view, String url) {
				NMEWebView.HaxeListenerClass.call1("onURLChanging", url);
				view.loadUrl(url);
				
				return true;
			}
		});
		
		WebSettings webSettings = webView.getSettings();
		webSettings.setSavePassword(false);
		webSettings.setSaveFormData(false);
		webSettings.setJavaScriptEnabled(true);
		webSettings.setSupportZoom(false);
		
		NMEWebView.webView = webView;
		NMEWebView.view = NMEWebView.webView;
		
		if(withPopup) {
			webView.setLayoutParams(new FrameLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT));
			
			ImageView closeImageView = new ImageView(GameActivity.getContext());
			closeImageView.setOnClickListener(new View.OnClickListener() {
				@Override
				public void onClick(View v) {
					NMEWebView.APIDestroy();
				}
			});
			
			DisplayMetrics metrics = new DisplayMetrics();
			GameActivity.getInstance().getWindowManager().getDefaultDisplay().getMetrics(metrics);
			// Log.d("NME", ""+ metrics.densityDpi);
			
			String dpi = "mdpi"; // DisplayMetrics.DENSITY_DEFAULT || DisplayMetrics.DENSITY_MEDIUM
			if(metrics.densityDpi == DisplayMetrics.DENSITY_LOW) {
				dpi = "ldpi";
			} else if(metrics.densityDpi == DisplayMetrics.DENSITY_HIGH) {
				dpi = "hdpi";
			} else if(metrics.densityDpi >= 320) {
				dpi = "xhdpi";
			}
			
			byte[] closeBytes = GameActivity.getResource("extensions_webview_assets_close_"+ dpi +"_png");
			closeImageView.setImageBitmap(BitmapFactory.decodeByteArray(closeBytes, 0, closeBytes.length));
			int margin = closeImageView.getDrawable().getIntrinsicWidth() / 2;
			
			LinearLayout webViewContainer = new LinearLayout(GameActivity.getContext());
			webViewContainer.setPadding(margin, margin, margin, margin);
			webViewContainer.addView(webView);
			
			FrameLayout contentFrameLayout = new FrameLayout(GameActivity.getContext());
			contentFrameLayout.setBackgroundColor(Color.TRANSPARENT);
			contentFrameLayout.addView(webViewContainer);
			
			contentFrameLayout.addView(closeImageView, new ViewGroup.LayoutParams(ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.WRAP_CONTENT));
			NMEWebView.view = contentFrameLayout;
		}
		
		GameActivity.pushView(NMEWebView.view);
	}
	
	public static void APINavigate(String url)
	{
		if(NMEWebView.webView != null) NMEWebView.webView.loadUrl(url);
	}
	
	public static void APIDestroy()
	{
		NMEWebView.HaxeListenerClass.call0("onDestroyed");
		
		if(NMEWebView.webView != null) {
			NMEWebView.webView.stopLoading();
			NMEWebView.webView.destroy();
			GameActivity.popView();
		}
		NMEWebView.webView = null;
		NMEWebView.HaxeListenerClass = null;
	}
}