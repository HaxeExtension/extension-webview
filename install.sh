#!/bin/bash
dir=`dirname "$0"`
cd "$dir"
haxelib remove webviewex
haxelib local webviewex.zip
