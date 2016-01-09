#!/bin/sh
gcc -o metal-test -lobjc -fobjc-arc -framework AppKit -framework Metal -framework MetalKit *.m
