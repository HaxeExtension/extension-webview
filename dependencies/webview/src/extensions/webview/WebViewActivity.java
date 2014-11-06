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
import android.webkit.WebViewClient;
import android.widget.FrameLayout;

public class WebViewActivity extends Activity {
	
	private static final String TAG = "WebViewActivity";
	
	protected FrameLayout webViewPlaceholder;
	protected WebView webView;
	
	protected String url;
	protected boolean floating;
	protected String[] urlWhitelist;
	protected String[] urlBlacklist;
	
	protected int layoutResource;

	@Override
	public void onCreate(Bundle savedInstanceState)
	{
		super.onCreate(savedInstanceState);
		
		// Load parameters from intent
		url = getIntent().getExtras().getString(WebViewExtension.EXTRA_URL);
		floating = getIntent().getExtras().getBoolean(WebViewExtension.EXTRA_FLOATING);
		urlWhitelist = getIntent().getExtras().getStringArray(WebViewExtension.EXTRA_URL_WHITELIST);
		urlBlacklist = getIntent().getExtras().getStringArray(WebViewExtension.EXTRA_URL_BLACKLIST);

		getWindow().requestFeature(Window.FEATURE_NO_TITLE);

		if (floating)
			layoutResource = R.layout.activity_web_view_floating;
		else
			layoutResource = R.layout.activity_web_view_fullscreen;
		
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
			webView.setLayoutParams(new ViewGroup.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT));
			webView.setScrollBarStyle(WebView.SCROLLBARS_OUTSIDE_OVERLAY);
			webView.setScrollbarFadingEnabled(true);
			webView.getSettings().setLoadsImagesAutomatically(true);
			
			// Add the callback to handle new page loads
			webView.setWebViewClient(
				
				new WebViewClient() {
					
					@Override
					public boolean shouldOverrideUrlLoading (WebView view, String url) {
						
						Log.d(TAG, "shouldOverrideUrlLoading(): url = " + url);
						
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
			webView.loadUrl(url);
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
		finish();
	}
	
	
}
