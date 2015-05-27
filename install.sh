#!/bin/bash
dir=`dirname "$0"`
cd "$dir"
haxelib remove extension-webview
haxelib local extension-webview.zip
