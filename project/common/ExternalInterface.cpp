#include <hx/CFFI.h>
#include <hxcpp.h>

#include "WebViewEx.h"
	
using namespace webviewex;

#ifdef HX_WINDOWS
	typedef wchar_t OSChar;
	#define val_os_string val_wstring
#else
	typedef char OSChar;
	#define val_os_string val_string
#endif

extern "C" {
    int webviewex_register_prims(){
        return 0;
    }
}

void webviewAPIInit (value _onDestroyedCallback, value _onURLChangingCallback, value withPopup) { init(_onDestroyedCallback, _onURLChangingCallback, val_bool(withPopup)); }
DEFINE_PRIM (webviewAPIInit, 3);

void webviewAPINavigate (value url) { navigate(val_string(url)); }
DEFINE_PRIM (webviewAPINavigate, 1);

void webviewAPILoadHtml (value html) { loadHtml(val_string(html)); }
DEFINE_PRIM (webviewAPILoadHtml, 1);

void webviewAPIDestroy(){ destroy(); }
DEFINE_PRIM (webviewAPIDestroy, 0);
