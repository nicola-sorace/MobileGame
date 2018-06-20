#!/bin/bash

montage out/$1*.png -tile 60 -geometry 100x200+0+0 -background transparent sheet.png
