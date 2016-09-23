package extensions.webview;

import java.util.regex.PatternSyntaxException;

import android.os.Bundle;
import android.app.Activity;
import android.content.res.Configuration;
import android.util.Log;
import android.view.View;
import android.view.ViewGroup;
import android.view.Window;
import android.webkit.WebView;
import android.webkit.WebSettings;
import android.webkit.WebViewClient;
import android.widget.FrameLayout;
import org.haxe.lime.HaxeObject;

public class WebViewActivity extends Activity {
	
	private static final String TAG = "WebViewActivity";
	
	protected FrameLayout webViewPlaceholder;
	protected WebView webView;
	
	protected String url;
	protected String html;
	protected boolean floating;
	protected String[] urlWhitelist;
	protected String[] urlBlacklist;
	protected boolean useWideViewPort;
	protected boolean mediaPlaybackRequiresUserGesture;
	protected HaxeObject callback;
	
	protected int layoutResource;

	@Override
	public void onCreate(Bundle savedInstanceState)
	{
		super.onCreate(savedInstanceState);
		
		// Load parameters from intent
		Bundle extras = getIntent().getExtras();
		url = extras.getString(WebViewExtension.EXTRA_URL, "about:blank");
		html = extras.getString(WebViewExtension.EXTRA_HTML, "null");
		floating = extras.getBoolean(WebViewExtension.EXTRA_FLOATING);
		urlWhitelist = extras.getStringArray(WebViewExtension.EXTRA_URL_WHITELIST);
		urlBlacklist = extras.getStringArray(WebViewExtension.EXTRA_URL_BLACKLIST);
		useWideViewPort = extras.getBoolean(WebViewExtension.EXTRA_USE_WIDE_PORT);
		mediaPlaybackRequiresUserGesture = extras.getBoolean(WebViewExtension.EXTRA_MEDIA_PLAYBACK_REQUIRES_USER_GESTURE);
		callback = WebViewExtension.callback;

		getWindow().requestFeature(Window.FEATURE_NO_TITLE);

		if (floating) {
			layoutResource = R.layout.activity_web_view_floating;
		} else {
			layoutResource = R.layout.activity_web_view_fullscreen;
		}
		
		// Initialize the UI
		initUI();
	}

	protected void initUI()
	{
		// Load layout from resources
		setContentView(layoutResource);
		
		// Retrieve UI elements
		webViewPlaceholder = ((FrameLayout)findViewById(R.id.webViewPlaceholder));

		// Initialize the WebView if necessary
		if (webView == null)
		{
			// Create the webview
			webView = new WebView(this);
			WebSettings webSettings = webView.getSettings();
			webSettings.setJavaScriptEnabled(true);
			webSettings.setDomStorageEnabled(true);
			webView.setLayoutParams(new ViewGroup.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT));
			webView.setScrollBarStyle(WebView.SCROLLBARS_OUTSIDE_OVERLAY);
			webView.setScrollbarFadingEnabled(true);
			webSettings.setLoadsImagesAutomatically(true);

			webSettings.setUseWideViewPort(useWideViewPort);
			if (android.os.Build.VERSION.SDK_INT>16) {
				//TODO: need to call this using reflection
				//webSettings.setMediaPlaybackRequiresUserGesture(mediaPlaybackRequiresUserGesture);
			}
			
			// Add the callback to handle new page loads
			webView.setWebViewClient(
				
				new WebViewClient() {
					
					@Override
					public boolean shouldOverrideUrlLoading (WebView view, String url) {
						
						Log.d(TAG, "shouldOverrideUrlLoading(): url = " + url);

						callback.call("onURLChanging", new Object[] {url});
						
						if (WebViewActivity.this.urlWhitelist == null) {
							
							Log.d(TAG, "urlWhitelist is null");
							
						} else if (WebViewActivity.this.urlWhitelist.length == 0) {

							Log.d(TAG, "urlWhitelist is empty");

						} else {
							
							boolean whitelisted = false;
							
							for (String whitelistedUrl : WebViewActivity.this.urlWhitelist) {
							
								try {
	
									if (url.matches(whitelistedUrl)) {
										
										Log.d(TAG, "URL matches with whitelist entry: '" + whitelistedUrl + "'.");
										whitelisted = true;
										
									}
																	
								} catch (PatternSyntaxException ex) {
									
									Log.e(TAG, "Regular expression '" + whitelistedUrl + "' is not valid.");
									
								}
								
							}
							
							if (! whitelisted) {
							
								Log.d(TAG, "URL is not whitelisted. Closing view...");
								// call onClose( with args ) ???
								finish();
								return true;
								
							}
							
						}
						
						if (WebViewActivity.this.urlBlacklist == null) {
							
							Log.d(TAG, "urlBlacklist is null");
							
						} else for (String blacklistedUrl : WebViewActivity.this.urlBlacklist) {
							
							try {
							
								if (url.matches(blacklistedUrl)) {
									
									Log.d(TAG, "URL matches with blacklist entry: '" + blacklistedUrl + "'. Closing view...");
									// call onClose( with args ) ???
									finish();
									return true;
									
								}
								
							} catch (PatternSyntaxException ex) {
								
								Log.e(TAG, "Regular expression '" + blacklistedUrl + "' is not valid.");
								
							}
							
						}
						
						return false;
					}
				
				}
				
			);

			// Load the page
			callback.call("onURLChanging", new Object[] {url});
			if(url=="about:blank" && html!="null") webView.loadData(html, "text/html", null);
			else webView.loadUrl(url);
		}

		// Attach the WebView to its placeholder
		webViewPlaceholder.addView(webView);
	}

	@Override
	public void onConfigurationChanged(Configuration newConfig)
	{

		Log.d(TAG, "onConfigurationChanged (newConfig = " + newConfig.toString() + ")");
		
		if (webView != null)
		{
			// Remove the WebView from the old placeholder
			webViewPlaceholder.removeView(webView);
		}

		super.onConfigurationChanged(newConfig);

		// Reinitialize the UI
		initUI();
	}

	@Override
	protected void onSaveInstanceState(Bundle outState)
	{
		super.onSaveInstanceState(outState);

		// Save the state of the WebView
		webView.saveState(outState);
	}

	@Override
	protected void onRestoreInstanceState(Bundle savedInstanceState)
	{
		super.onRestoreInstanceState(savedInstanceState);

		// Restore the state of the WebView
		webView.restoreState(savedInstanceState);
	}

	@Override
	public void onBackPressed() {
		if (webView.canGoBack())
			webView.goBack();
		else
			super.onBackPressed();
	}

	public void onClosePressed(View view) {
		callback.call("onClose", new Object[] {});
		finish();
	}

	@Override
	public void finish(){
		super.finish();
		WebViewExtension.active=false;
		webView.clearHistory();
		webView.loadUrl("about:blank");
		webViewPlaceholder.removeView(webView);
	}
	
	
}
