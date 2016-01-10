#!/bin/sh
gcc -std=c11 -Wall -Wextra -Wpedantic -Werror -fobjc-arc \
    -lobjc \
    -framework AppKit \
    -framework Metal \
    -framework MetalKit \
    -framework QuartzCore \
    *.m -o metal-test
