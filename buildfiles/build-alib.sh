#!/bin/bash
luabundler bundle src/main.lua -p "src/?.lua" -p "?.lua" -o build/source.lua
# im too lazy to manually copy them all

VERSION="0.44"

# https://superuser.com/questions/246837/how-do-i-add-text-to-the-beginning-of-a-file-in-bash
sed -i "1ilocal version = '$VERSION'" build/source.lua