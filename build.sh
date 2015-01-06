#!/bin/bash
dir=`dirname "$0"`
cd "$dir"
project/build.sh
rm -rf project/obj
lime rebuild . ios
rm -rf project/obj
rm -f openfl-webview.zip
zip -0r openfl-webview.zip extension dependencies assets haxelib.json include.xml project ndll android 
