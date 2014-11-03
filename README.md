openfl-webview
=======

Native Webview extension for OpenFL

This is a simple webview extension that pops up a WebView on iOS and Android outputs of OpenFL / Lime.

Main Features:
=======
* The popup has a close button on the top-left corner.
* Allows you to set onClose and onURLChanging events.
* It allows the code to specify a list of valid URLs to browse. If the webview tries to access an invalid URL, it'll automatically close.
* On non-supported platforms, this extensions has no effect (makes nothing).

Simple use Example:
=======

```haxe
// This example show a simple sharing of a text using the Share Classs.

import extension.webview.WebView;

class SimpleExample {
	function new(){
		WebView.onClose=onClose;
		WebView.onURLChanging=onURLChanging;
	}

	function onClose(){
		trace("CLOSE!");
	}

	function onURLChanging(url:String){
		trace("WebView is about to open: "+url);
	}

	function shareStuff(){
		WebView.open('http://www.puralax.com/help',true);
	}
}

```

How to Install:
=======

```bash
haxelib install openfl-webview
```

Licence
=======
http://www.gnu.org/licenses/lgpl.html

This library is free software; you can redistribute it and/or
modify it under the terms of the GNU Lesser General Public
License (LGPL) as published by the Free Software Foundation; either
version 3 of the License, or (at your option) any later version.
  
This library is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
Lesser General Public License for more details.
  
You should have received a copy of the GNU Lesser General Public
License along with this library; if not, write to the Free Software
Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA.
  

WebSite: https://github.com/fbricker/openfl-webview | Author: Matías Rossi && Federico Bricker | Copyright (c) 2013 SempaiGames (http://www.sempaigames.com)