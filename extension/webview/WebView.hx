package extension.webview;
	
class WebView  {

	private static var initialized :Bool = false;

	private static var APIInit:Dynamic=null;
	private static var APISetCallback:Dynamic=null;
	private static var APINavigate:Dynamic=null;
	private static var APIDestroy:Dynamic=null;
	private static var listener:WebViewListener;

	#if android
	private static var _open :String -> Bool -> Array<String> -> Array<String> -> Void = null;
	#end

	////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	public static var onClose:Void->Void=null;
	public static var onURLChanging:String->Void=null;

	////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	public static function open (url: String = null, floating :Bool = false, ?urlWhitelist :Array<String>, ?urlBlacklist :Array<String>) :Void {
		init();
		#if android
			_open(url, floating, urlWhitelist, urlBlacklist);
		#else
			if (listener == null) listener = new WebViewListener();
			APICall("init", [listener, floating]);
			navigate(url);
		#end
	}

	
	public static function navigate(url:String):Void {
		if (url==null) return;
		if (listener != null) APICall("navigate", [url]);
	}
	
	public static function close():Void {
		if (listener != null) APICall("destroy");
	}

	////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	private static function init():Void {
		if(initialized == true) return;
		initialized = true;
		try{
			#if android
			_open = openfl.utils.JNI.createStaticMethod("extensions/webview/WebViewExtension", "open", "(Ljava/lang/String;Z[Ljava/lang/String;[Ljava/lang/String;)V");
			#elseif ios
            APIInit     = cpp.Lib.load("webviewex","webviewAPIInit", 3);
			APINavigate = cpp.Lib.load("webviewex","webviewAPINavigate", 1);
			APIDestroy  = cpp.Lib.load("webviewex","webviewAPIDestroy", 0);
			#end
		}catch(e:Dynamic){
			trace("INIT Exception: "+e);
		}
	}
	
	private static function APICall(method:String, args:Array<Dynamic> = null):Void	{
		init();
		try{
			#if android
			if (method == "init") {
				try {
					APIInit(args[1] == true);
				} catch (e :Dynamic) {
					APIInit(args[1] == true);
				}
			}
            if (method == "callback") APISetCallback(args[0]);
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
	
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////

class WebViewListener {

	public function new() {}
	
	public function onClose():Void {
		if(WebView.onClose!=null) WebView.onClose();
	}
	
	public function onURLChanging(url:Dynamic):Void {
		if(WebView.onURLChanging!=null) WebView.onURLChanging(url);
	}
}
