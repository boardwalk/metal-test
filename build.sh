#!/bin/sh
gcc -Wall -Wextra -Werror -fobjc-arc \
    -lobjc \
    -framework AppKit \
    -framework Metal \
    -framework MetalKit \
    -framework QuartzCore \
    *.m -o metal-test
