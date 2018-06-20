#!/bin/bash

montage tmp/$1*.png -tile 1 -geometry 6000x100+0+0 -background transparent stitch.png
