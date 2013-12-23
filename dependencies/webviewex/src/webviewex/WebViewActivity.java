package webviewex;

import android.util.Log;
/*
import android.webkit.WebSettings;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import android.view.View;
import android.view.View.OnKeyListener;
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
import android.os.Bundle;
import org.haxe.lime.GameActivity;
import org.haxe.lime.HaxeObject;
import org.haxe.extension.Extension;
*/

public class WebViewActivity extends Activity {

	/*
	
	public static WebView webView;
	public static View view;
	public static String url;
	public static ImageView closeImageView;
	public static FrameLayout contentFrameLayout;
	public static LinearLayout webViewContainer;
	public static boolean withPopup;
	private static Extension extension;
	private static boolean shouldBeVisible = false;
	
	public void init() {
		Log.d("WebViewEx","APIInit");
		if(WebViewEx.webView != null) WebViewEx.APIDestroy();
		WebViewEx.withPopup=withPopup;
		
		GameActivity.getInstance().runOnUiThread(new Runnable() {public void run() { 
			
			WebViewEx.webView = new WebView(GameActivity.getContext());

			WebViewEx.webView.setOnKeyListener(new OnKeyListener(){
				@Override
				public boolean onKey(View v, int keyCode, KeyEvent event) {
					if(keyCode==KeyEvent.KEYCODE_BACK){
						if(WebViewEx.webView.canGoBack()){
							WebViewEx.webView.goBack();
						}else{
							WebViewEx.APIDestroy();
						}
						return true;
					}
					return false;
				}
			});

			WebViewEx.view = null;
			WebViewEx.webView.setVerticalScrollBarEnabled(false);
	        WebViewEx.webView.setHorizontalScrollBarEnabled(false);
			WebViewEx.webView.setWebViewClient(new WebViewClient() {
				@Override
				public boolean shouldOverrideUrlLoading(WebView view, String url) {
					WebViewEx.url=url;
					Log.d("WebViewEx","onURLChanging: "+url);
					if(WebViewEx.haxeListenerClass!=null) WebViewEx.haxeListenerClass.call1("onURLChanging", url);
					view.loadUrl(WebViewEx.url);
					return true;
				}
			});
			
			WebSettings webSettings = webView.getSettings();
			webSettings.setSavePassword(false);
			webSettings.setSaveFormData(false);
			webSettings.setJavaScriptEnabled(true);
			webSettings.setSupportZoom(false);
			
			if(WebViewEx.withPopup) {
				WebViewEx.webView.setLayoutParams(new FrameLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT));
				
				WebViewEx.closeImageView = new ImageView(GameActivity.getContext());
				WebViewEx.closeImageView.setOnClickListener(new View.OnClickListener() {
					@Override
					public void onClick(View v) {
						WebViewEx.APIDestroy();
					}
				});
				
				DisplayMetrics metrics = new DisplayMetrics();
				GameActivity.getInstance().getWindowManager().getDefaultDisplay().getMetrics(metrics);
				
				String dpi = "mdpi"; // DisplayMetrics.DENSITY_DEFAULT || DisplayMetrics.DENSITY_MEDIUM
				if(metrics.densityDpi == DisplayMetrics.DENSITY_LOW) {
					dpi = "ldpi";
				} else if(metrics.densityDpi == DisplayMetrics.DENSITY_HIGH) {
					dpi = "hdpi";
				} else if(metrics.densityDpi >= 320) {
					dpi = "xhdpi";
				}
				
				byte[] closeBytes = GameActivity.getResource("assets/extensions_webview_close_"+ dpi +".png");
				WebViewEx.closeImageView.setImageBitmap(BitmapFactory.decodeByteArray(closeBytes, 0, closeBytes.length));
				int margin = closeImageView.getDrawable().getIntrinsicWidth() / 2;
				
				WebViewEx.webViewContainer = new LinearLayout(GameActivity.getContext());
				WebViewEx.webViewContainer.setPadding(margin, margin, margin, margin);
				WebViewEx.webViewContainer.addView(WebViewEx.webView);
				
				WebViewEx.contentFrameLayout = new FrameLayout(GameActivity.getContext());
				WebViewEx.contentFrameLayout.setBackgroundColor(Color.TRANSPARENT);
				WebViewEx.contentFrameLayout.addView(WebViewEx.webViewContainer);
				
				WebViewEx.contentFrameLayout.addView(WebViewEx.closeImageView, new ViewGroup.LayoutParams(ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.WRAP_CONTENT));
				WebViewEx.view=contentFrameLayout;
			}else{
				WebViewEx.view=WebViewEx.webView;
			}

		}});

		if (extension == null) {

			extension = new Extension() {

				@Override
				public void onCreate(Bundle _) {
					Log.d("WebViewEx", "onStart");
					WebViewEx.onCreate();
				}

				@Override
				public void onDestroy() {
					Log.d("WebViewEx", "onPause");
					WebViewEx.onDestroy();
				}

			};

			GameActivity.registerExtension (extension);
		}
		
		shouldBeVisible = true;
		
		onCreate();

	}

	private static void onDestroy() {
		if (shouldBeVisible) {
			Log.d("WebView", "onStop(). shouldBeVisible = true. Removing view...");
			
			GameActivity.getInstance().runOnUiThread(

				new Runnable () {

					public void run () {

						try {
							
							ViewGroup parent = (ViewGroup) WebViewEx.view.getParent();
							
							if (parent != null) {

								Log.d("WebViewEx", "ChildCount: " + parent.getChildCount());
								parent.removeView ( WebViewEx.view );

							}

						} catch (ClassCastException ex) {
							
							Log.wtf("WebViewEx", 
								"view.getParent() is an instance of " + WebViewEx.view.getParent().getClass().getName() +
								" which is not a subclass of ViewGroup. Aborting redraw.");
							return;

						}
					}
				}
			);
		}
	}

	private static void onCreate() {
		if (shouldBeVisible) {
			Log.d("WebView", "onStart(). shouldBeVisible = true. Adding view...");

			GameActivity.getInstance().runOnUiThread(
				new Runnable () {

					public void run () {

						GameActivity.pushView(WebViewEx.view);
						WebViewEx.view.requestFocus();

					}

				}
			);
		}
	}
	
	public static void APINavigate(String url) {
		Log.d("WebViewEx","APINavigate");
		WebViewEx.url=url;
		GameActivity.getInstance().runOnUiThread(new Runnable() {public void run() { 
			if(WebViewEx.webView != null) WebViewEx.webView.loadUrl(WebViewEx.url);
		}});
	}
	
	public static void APIDestroy() {
		Log.d("WebViewEx","APIDestroy");
		shouldBeVisible = false;
		if(WebViewEx.view != null) {
			GameActivity.getInstance().runOnUiThread(new Runnable() {public void run() { 
				if(WebViewEx.haxeListenerClass!=null) WebViewEx.haxeListenerClass.call0("onDestroyed");
				WebViewEx.webView.stopLoading();
				GameActivity.popView();
				((View)GameActivity.getMainView()).requestFocus();
				WebViewEx.closeImageView=null;
				WebViewEx.webViewContainer=null;
				WebViewEx.contentFrameLayout=null;
				WebViewEx.view=null;
				WebViewEx.webView.destroy();
				WebViewEx.webView = null;
				Log.d("WebViewEx","APIDestroyed");
			}});
		}
	}

	*/

}
