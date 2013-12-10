package webviewex;
	
class WebView  {

	private static var APIInit:Dynamic=null;
	private static var APINavigate:Dynamic=null;
	private static var APIDestroy:Dynamic=null;

	private static var listener:WebViewListener;
	
	public static var onDestroyed:Void->Void=null;
	public static var onURLChanging:String->Void=null;
		
	private static function checkAPI():Void {
		if(APIInit != null) return;
		try{
			#if android
			APIDestroy  = openfl.utils.JNI.createStaticMethod("webviewex/WebViewEx", "APIDestroy", "()V");
			APIInit     = openfl.utils.JNI.createStaticMethod("webviewex/WebViewEx", "APIInit", "(Lorg/haxe/nme/HaxeObject;Z)V");
			APINavigate = openfl.utils.JNI.createStaticMethod("webviewex/WebViewEx", "APINavigate", "(Ljava/lang/String;)V");
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
		checkAPI();
		try{
			#if android
            if (method == "init") APIInit(args[0], args[1] == true);
            if (method == "navigate") APINavigate(args[0]);
            if (method == "destroy") APIDestroy();
			#elseif iphone
			if (method == "init") APIInit(args[0].onDestroyed, args[0].onURLChanging, args[1]);
            if (method == "navigate") APINavigate(args[0]);
            if (method == "destroy") APIDestroy();
			#end
		}catch(e:Dynamic){
			trace("APICall Exception: "+e);
		}
	}
	
	public static function init(withPopup:Bool = false):Void {
		if (listener == null) {
			listener = new WebViewListener();
			APICall("init", [listener, withPopup]);
		}
	}
	
	public static function navigate(url:String):Void {
		if (listener == null) init();
		APICall("navigate", [url]);
	}
	
	public static function destroy():Void {
		if (listener != null) APICall("destroy");
	}
}

class WebViewListener {

	public function new() {
	}
	
	public function onDestroyed():Void {
		if(WebView.onDestroyed!=null) WebView.onDestroyed();
	}
	
	public function onURLChanging(url:String):Void {
		if(WebView.onURLChanging!=null) WebView.onURLChanging(url);
	}
}
