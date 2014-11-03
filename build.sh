#!/bin/bash
dir=`dirname "$0"`
cd "$dir"
project/build.sh
rm -f openfl-webview.zip
zip -0r openfl-webview.zip extension android assets haxelib.json include.xml project ndll android 
