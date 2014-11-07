package extensions.webview;

import java.util.ArrayList;

import android.content.Intent;

import org.haxe.extension.Extension;


public class WebViewExtension extends Extension {

	public static final String EXTRA_URL = "extensions.webviewex.EXTRA_URL";
	public static final String EXTRA_FLOATING = "extensions.webviewex.EXTRA_FLOATING";
	public static final String EXTRA_URL_WHITELIST = "extensions.webviewex.EXTRA_URL_WHITELIST";
	public static final String EXTRA_URL_BLACKLIST = "extensions.webviewex.EXTRA_URL_BLACKLIST";
	public static boolean active = false;

	public static void open(String url, boolean floating, String[] urlWhitelist, String[] urlBlacklist) {

		Intent intent = new Intent(mainActivity, WebViewActivity.class);

		intent.putExtra(EXTRA_URL, url);
		intent.putExtra(EXTRA_FLOATING, floating);
		intent.putExtra(EXTRA_URL_WHITELIST, urlWhitelist);
		intent.putExtra(EXTRA_URL_BLACKLIST, urlBlacklist);
		
		mainActivity.startActivity(intent);
		active = true;
	}

	public static boolean isActive(){
		return active;
	}

}
