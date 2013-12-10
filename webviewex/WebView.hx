package webviewex;
import msignal.Signal;
import flash.errors.Error;
	
class WebView 
{
	private static var APIInit:Dynamic=null;
	private static var APINavigate:Dynamic=null;
	private static var APIDestroy:Dynamic=null;
	
	private static var listener:WebViewListener;
	
	public static var onDestroyed:Signal0 = new Signal0();
	public static var onURLChanging:Signal1<String> = new Signal1<String>();
	
	private static function checkAPI():Void
	{
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
		trace("CHECK API OK!");
		}catch(e:Dynamic){
			trace("INIT Exception: "+e);
		}
	}
	
	private static function APICall(method:String, args:Array<Dynamic> = null):Void
	{
		checkAPI();
		#if android
            if (method == "init") APIInit(args[0], args[1] == true);
            if (method == "navigate") APINavigate(args[0]);
            if (method == "destroy") APIDestroy();
		#elseif iphone
			if (method == "init") APIInit(args[0].onDestroyed, args[0].onURLChanging, args[1]);
            if (method == "navigate") APINavigate(args[0]);
            if (method == "destroy") APIDestroy();
		#end
	}
	
	public static function init(withPopup:Bool = false):Void
	{
		if (listener == null)
		{
			listener = new WebViewListener();
			listener.onDestroyedSignal.add(function ():Void
			{
				listener = null;
			});
			
			listener.onDestroyedSignal.add(onDestroyed.dispatch);
			listener.onURLChangingSignal.add(onURLChanging.dispatch);
			
			APICall("init", [listener, withPopup]);
		}
	}
	
	public static function navigate(url:String):Void
	{
		if (listener == null) init();
		APICall("navigate", [url]);
	}
	
	public static function destroy():Void
	{
		if (listener != null) APICall("destroy");
	}
}

class WebViewListener
{
	public var onDestroyedSignal:Signal0;
	public var onURLChangingSignal:Signal1<String>;
	
	public function new() 
	{
		onDestroyedSignal = new Signal0();
		onURLChangingSignal = new Signal1<String>();
	}
	
	public function onDestroyed():Void
	{
		onDestroyedSignal.dispatch();
	}
	
	public function onURLChanging(url:String):Void
	{
		onURLChangingSignal.dispatch(url);
	}
}
