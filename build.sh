#!/bin/bash
dir=`dirname "$0"`
cd "$dir"
project/build.sh
rm -f webviewex.zip
zip -0r webviewex.zip webviewex android assets haxelib.json include.xml project ndll android 
