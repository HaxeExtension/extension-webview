#!/bin/bash
dir=`dirname "$0"`
cd "$dir"
haxelib remove openfl-webview-extension
haxelib local openfl-webview-extension.zip
