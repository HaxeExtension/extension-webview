#ifndef WebViewEx
#define WebViewEx
	
namespace webviewex {
	void init(value _onDestroyedCallback, value _onURLChangingCallback, bool withPopup);
	void navigate(const char *url);
	void loadHtml(const char *html);
	void destroy();
}

#endif