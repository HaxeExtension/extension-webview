package extension.webview;

class AndroidCallbackHelper {

	public function new() {

	}

	public function onClose() {
		
	}

	public function onURLChanging(url : String) {
		if (WebView.onURLChanging!=null) {
			WebView.onURLChanging(url);
		}
	}

}