package extension.webview;

import haxe.Json;
	
class WebView  {

	private static var initialized :Bool = false;

	private static var APIInit:Dynamic=null;
	private static var APISetCallback:Dynamic=null;
	private static var APINavigate:Dynamic=null;
	private static var APIDestroy:Dynamic=null;
	private static var APILoadHtml:Dynamic=null;
	
	#if ios
	private static var listener:WebViewListener;
	#end

	#if android
	private static var _open :String -> Void = null;
	private static var _openHtml :String -> Void = null;
	#end

	////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	public static var onClose:Void->Void=null;
	public static var onURLChanging:String->Void=null;

	////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	public static function open (
		url: String = null,
		floating :Bool = false,
		?urlWhitelist :Array<String>,
		?urlBlacklist :Array<String>,
		?useWideViewPort :Bool = false,						// Android only
		?mediaPlaybackRequiresUserGesture :Bool = true		// Android only
	) :Void {
		init();
		if(urlWhitelist!=null) urlWhitelist.push(url);
		
		#if android
			if (urlWhitelist==null) {
				urlWhitelist = [];
			}
			if (urlBlacklist==null) {
				urlBlacklist = [];
			}
			var obj = {
				url : url,
				floating : floating,
				urlWhitelist : urlWhitelist,
				urlBlacklist : urlBlacklist,
				useWideViewPort : useWideViewPort,
				mediaPlaybackRequiresUserGesture : mediaPlaybackRequiresUserGesture
			}
			_open(Json.stringify(obj));
		#elseif ios
			if (listener == null) listener = new WebViewListener(urlWhitelist, urlBlacklist);
			APICall("init", [listener, floating]);
			navigate(url);
		#end
	}

	public static function openHtml(
		html:String, 
		floating:Bool=false,
		?useWideViewPort :Bool = false,						// Android only
		?mediaPlaybackRequiresUserGesture :Bool = true		// Android only
	) :Void {
		init();
		#if android
			var obj = {
				html : html,
				floating : floating,
				useWideViewPort : useWideViewPort,
				mediaPlaybackRequiresUserGesture : mediaPlaybackRequiresUserGesture
			}
			_openHtml(Json.stringify(obj));
		#elseif ios
			if (listener == null) listener = new WebViewListener(null, null);
			APICall("init", [listener, floating]);
			APICall("loadHtml", [html]);
		#end
	}

	#if ios
	public static function navigate(url:String):Void {
		if (url==null) return;
		if (listener != null) APICall("navigate", [url]);
	}
	
	public static function close():Void {
		if (listener != null) APICall("destroy");
	}
	#end

	////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	private static function init():Void {
		if(initialized == true) return;
		initialized = true;
		try {
			#if android
			_open = lime.system.JNI.createStaticMethod("extensions/webview/WebViewExtension", "open", "(Ljava/lang/String;)V");
			_openHtml = lime.system.JNI.createStaticMethod("extensions/webview/WebViewExtension", "openHtml", "(Ljava/lang/String;)V");
			var _callbackFunc = lime.system.JNI.createStaticMethod("extensions/webview/WebViewExtension", "setCallback", "(Lorg/haxe/lime/HaxeObject;)V");
			_callbackFunc(new AndroidCallbackHelper());

			#elseif ios
            APIInit     = cpp.Lib.load("webviewex","webviewAPIInit", 3);
			APINavigate = cpp.Lib.load("webviewex","webviewAPINavigate", 1);
			APILoadHtml  = cpp.Lib.load("webviewex","webviewAPILoadHtml", 1);
			APIDestroy  = cpp.Lib.load("webviewex","webviewAPIDestroy", 0);
			#end

		} catch(e:Dynamic) {
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
			#elseif ios
			if (method == "init") APIInit(args[0].onClose, args[0].onURLChanging, args[1]);
            if (method == "navigate") APINavigate(args[0]);
            if (method == "loadHtml") APILoadHtml(args[0]);
            if (method == "destroy") APIDestroy();
			#end
		} catch(e:Dynamic) {
			trace("APICall Exception [" + method + ", " + args + "]: "+e);
		}
	}
	
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#if ios
class WebViewListener {

	public var urlWhitelist :Array<String>;
	public var urlBlacklist :Array<String>;

	public function new(urlWhitelist :Array<String>, urlBlacklist :Array<String>) {
		this.urlBlacklist=urlBlacklist;
		this.urlWhitelist=urlWhitelist;
	}
	
	public function onClose():Void {
		if(WebView.onClose!=null) WebView.onClose();
	}

	private function find(urls :Array<String>, url:String):Bool{
		for(regex in urls){
			var r = new EReg(regex,"");
			if(r.match(url)) return true;
		}
		return false;
	}
	
	public function onURLChanging(url:Dynamic):Void {	
		if(urlWhitelist!=null){	
			if(!find(urlWhitelist,url)){
				WebView.close();
				return;
			}
		}
		if(urlBlacklist!=null){
			if(find(urlBlacklist,url)){
				WebView.close();
				return;
			}
		}
		if(WebView.onURLChanging!=null) WebView.onURLChanging(url);
	}
}
#end
