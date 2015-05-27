#!/bin/bash
dir=`dirname "$0"`
cd "$dir"
rm -rf project/obj
lime rebuild . ios
rm -rf project/obj
rm -f extension-webview.zip
zip -r extension-webview.zip extension dependencies assets haxelib.json include.xml project ndll android 
