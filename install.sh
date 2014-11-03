#!/bin/bash
dir=`dirname "$0"`
cd "$dir"
haxelib remove openfl-webview
haxelib local openfl-webview.zip
