package extensions.webview;
	
class WebView {

	/*
	 * Public interface
	 */

	/**
	 * Opens a new web view.
	 *
	 *
	 * If urlWhitelist is provided, every time the web view navigates to 
	 * another URL, it will verify the URL matches at least one of the
	 * patterns in urlWhitelist. If it doesn't match any, the web view will
	 * exit and onClose handler will be called with
	 * reason = "NAVIGATION_NOT_WHITELISTED".
	 * If urlWhitelist is an empty array or null, any page will pass the
	 * whitelist check.
	 *
	 * If urlBlacklist is provided, every time a new URL passes the
	 * whitelist check, it will be checked against all the regular
	 * expressions in urlBlacklist. If it matches any of the patterns
	 * the web view will close and your onClose handler will be called with
	 * reason = "NAVIGATION_BLACKLISTED".
	 * If urlBlacklist is empty or null, any page will pass the blacklist
	 * check.
	 * 
	 * Setting both whitelist and blacklist to null lets the user
	 * navigate to any website inside this view.
	 *
	 */
	public static function open (url: String = null, floating :Bool = false, ?urlWhitelist :Array<String>, ?urlBlacklist :Array<String>) :Void {

		 init();

		 _open(url, floating, urlWhitelist, urlBlacklist);

	}


	/* 
	 * Private methods and fields
	 */

	private static var initialized :Bool = false;

	private static var _open :String -> Bool -> Array<String> -> Array<String> -> Void = null;
	//private static var _open :String -> Bool -> Void = null;

	// public static var onClose:Void->Void=null;
	// public static var onURLChanging:String->Void=null;



	private static function init() :Void {
		
		if (! initialized) {

			#if android
			_open = openfl.utils.JNI.createStaticMethod("extensions/webview/WebViewExtension", "open", "(Ljava/lang/String;Z[Ljava/lang/String;[Ljava/lang/String;)V");
			#end

			initialized = true;

		}

	}
	
/*	
	private static function init():Void {
		try {
			#if android
			APIInit     = openfl.utils.JNI.createStaticMethod("webviewex/WebViewEx", "APIInit", "(Z)V");
			APINavigate = openfl.utils.JNI.createStaticMethod("webviewex/WebViewEx", "APINavigate", "(Ljava/lang/String;)V");
			APIDestroy  = openfl.utils.JNI.createStaticMethod("webviewex/WebViewEx", "APIDestroy", "()V");
			// APISetCallback = openfl.utils.JNI.createStaticMethod("webviewex/WebViewEx", "APISetCallback", "(Lorg/haxe/nme/HaxeObject;)V");
			// APILastURL  = openfl.utils.JNI.createStaticMethod("webviewex/WebViewEx", "APILastURL", "()Ljava/lang/String;");
			// APIIsDisplaying = openfl.utils.JNI.createStaticMethod("webviewex/WebViewEx", "APIIsDisplaying", "()Z");
			#elseif ios
            APIInit     = cpp.Lib.load("webviewex","webviewAPIInit", 3);
			APINavigate = cpp.Lib.load("webviewex","webviewAPINavigate", 1);
			APIDestroy  = cpp.Lib.load("webviewex","webviewAPIDestroy", 0);
			#end
		} catch (e :Dynamic) {
			trace("INIT Exception: " + e);
		}
	}
	
	private static function APICall(method:String, args:Array<Dynamic> = null):Void	{
		
		if (! ready) {
			init();
			ready = true;
		}

		try {
			#if android
			if (method == "init") {
				try {
					APIInit(args[0] == true);
				} catch (e :Dynamic) {
					APIInit(args[0] == true);
				}
			}
//            if (method == "callback") APISetCallback(args[0]);
            if (method == "navigate") APINavigate(args[0]);
            if (method == "destroy") APIDestroy();
			#elseif iphone
			if (method == "init") APIInit(args[0].onClose, args[0].onURLChanging, args[1]);
            if (method == "navigate") APINavigate(args[0]);
            if (method == "destroy") APIDestroy();
			#end
		} catch(e:Dynamic) {
			trace("APICall Exception [" + method + ", " + args + "]: "+e);
		}
	}
*/
	
}