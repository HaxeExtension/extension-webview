#!/bin/bash
dir=`dirname "$0"`
cd "$dir"
project/build.sh
rm -f openfl-webview-extension.zip
zip -0r openfl-webview-extension.zip extensions assets haxelib.json include.xml project ndll dependencies
