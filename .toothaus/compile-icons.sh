#!/usr/bin/env bash
set -e

for file in app/javascript/icons/favicon-*.png; do
    dims=$(basename "$file" | grep -oE '[0-9]+x[0-9]+' | tr 'x' ':')
    echo  "$file -- $dims"
    svgexport app/javascript/images/logo.svg "$file" png "100%" "$dims"
done

for file in app/javascript/icons/{android,apple}-*.png; do
    dims=$(basename "$file" | grep -oE '[0-9]+x[0-9]+' | tr 'x' ':')
    echo  "$file -- $dims"
    svgexport app/javascript/images/app-icon.svg "$file" png "100%" "$dims"
done

convert app/javascript/icons/favicon-*.png -colors 256 public/favicon.ico
