package extensions.webview;

import java.util.ArrayList;

import android.content.Intent;

import org.haxe.extension.Extension;


public class WebViewExtension extends Extension {

	public static final String EXTRA_URL = "extensions.webviewex.EXTRA_URL";
	public static final String EXTRA_FLOATING = "extensions.webviewex.EXTRA_FLOATING";
	public static final String EXTRA_URL_WHITELIST = "extensions.webviewex.EXTRA_URL_WHITELIST";
	public static final String EXTRA_URL_BLACKLIST = "extensions.webviewex.EXTRA_URL_BLACKLIST";

	public static void open() {

		Intent intent = new Intent(mainActivity, WebViewActivity.class);

		intent.putExtra(EXTRA_URL, "http://www.google.com/");		
		intent.putExtra(EXTRA_FLOATING, true);
		ArrayList<String> whitelist = new ArrayList<String>();
		whitelist.add("^(https?:\\/\\/)?.*\\.puralax\\.com/.*$");
		whitelist.add("^(https?:\\/\\/)([a-z0-9-_]+\\.)*google\\.com(\\.[a-z]{2}[a-z]*)?(\\/|\\/.*)?$");
		intent.putExtra(EXTRA_URL_WHITELIST, whitelist);
		ArrayList<String> blacklist = new ArrayList<String>();
		blacklist.add("^(https?:\\/\\/)?.*\\.puralax\\.com/$");
		intent.putExtra(EXTRA_URL_BLACKLIST, blacklist);
		
		mainActivity.startActivity(intent);

	}

}
