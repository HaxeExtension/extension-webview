#extension-webview

A minimalistic OpenFL extension for displaying native WebViews on iOS and Android outputs.

###Main Features

* Full-screen and Popup mode.
* Popup mode has a close button on the top-left corner.
* Whitelist validation (the webview will close if the user goes to a non-whitelisted URL).
* Blacklist validation (the webview will close if the user goes to a blacklisted URL).
* onClose event (Android and iOS).
* onURLChanging events for controling the WebView (Android and iOS).
* On non-supported platforms, this extensions has no effect (makes nothing).

###Simple use Example

```haxe
// This example show a simple sharing of a text using the Share Class.

import extension.webview.WebView;

class SimpleExample {
	function new(){
		WebView.onClose=onClose;
		WebView.onURLChanging=onURLChanging;
	}

	function onClose(){
		trace("WebView has been closed!");
	}

	function onURLChanging(url:String){
		trace("WebView is about to open: "+url);
	}

	function shareStuff(){
		WebView.open('http://www.puralax.com/help',true);
		
		// Example using whitelist:
		// WebView.open('http://www.puralax.com/help',true,['(http|https)://www.puralax.com/help(.*)','http://www.sempaigames.com/(.*)']);
		
		// Example using blacklist:
		// WebView.open('http://www.puralax.com/help',true,null,['(http|https)://(.*)facebook.com(.*)']);
	}
}

```

###How to Install

```bash
haxelib install extension-webview
```

###License

The MIT License (MIT) - [LICENSE.md](LICENSE.md)

Copyright &copy;  2013 SempaiGames (http://www.sempaigames.com)

Author: Matías Rossi && Federico Bricker
