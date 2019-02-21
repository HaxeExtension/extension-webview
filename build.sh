#!/bin/bash
if [ -d "ndll" ]; then
    rm -r ndll
fi
if [ -d "native/obj" ]; then
    rm -r native/obj
fi

(cd project && haxelib run hxcpp Build.xml -Diphoneos -DHXCPP_ARM   -DHXCPP_CLANG -DOBJC_ARC $1)
(cd project && haxelib run hxcpp Build.xml -Diphoneos -DHXCPP_ARMV7 -DHXCPP_CLANG -DOBJC_ARC $1)
(cd project && haxelib run hxcpp Build.xml -Diphoneos -DHXCPP_ARM64 -DHXCPP_CLANG -DOBJC_ARC $1)
(cd project && haxelib run hxcpp Build.xml -Diphonesim -DHXCPP_CPP11 -DHXCPP_CLANG -DOBJC_ARC $1)
(cd project && haxelib run hxcpp Build.xml -Diphonesim -DHXCPP_CPP11 -DHXCPP_M64 -DHXCPP_CLANG -DOBJC_ARC $1)

if [ -d "native/obj" ]; then
    rm -r native/obj
fi